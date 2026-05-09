[CmdletBinding()]
param(
    [string]$Root,

    [string[]]$AllowedWindows = @(),

    [string[]]$AllowedStatuses = @('Inbox', 'Ready', 'Active', 'Blocked', 'Done', 'Dropped', 'Archived'),

    [string[]]$AllowedPriorities = @('P0', 'P1', 'P2', 'P3')
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($Root)) {
    if ($PSScriptRoot) {
        $Root = Join-Path $PSScriptRoot '..'
    } else {
        $Root = (Get-Location).Path
    }
}

$Root = (Resolve-Path -LiteralPath $Root).Path
$QueueDir = Join-Path $Root 'docs/dispatch/queue'
$WindowRegistryPath = Join-Path $Root 'docs/window-registry.md'
$Issues = New-Object System.Collections.Generic.List[object]

function ConvertTo-RepoPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $rootPath = [System.IO.Path]::GetFullPath($Root)

    if (-not $rootPath.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $rootPath += [System.IO.Path]::DirectorySeparatorChar
    }

    if ($fullPath.StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath.Substring($rootPath.Length).Replace('\', '/')
    }

    return $fullPath.Replace('\', '/')
}

function Add-Issue {
    param(
        [Parameter(Mandatory = $true)][string]$Code,
        [Parameter(Mandatory = $true)][string]$File,
        [Parameter(Mandatory = $true)][string]$Message
    )

    $script:Issues.Add([pscustomobject]@{
        Code = $Code
        File = ConvertTo-RepoPath $File
        Message = $Message
    })
}

function Get-MetadataValue {
    param(
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][string]$Key
    )

    $pattern = "(?m)^$([regex]::Escape($Key)):\s*(?<value>.*?)\s*$"
    $match = [regex]::Match($Content, $pattern)

    if ($match.Success) {
        return $match.Groups['value'].Value.Trim()
    }

    return ''
}

function Resolve-DocLink {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$SourceFile,
        [Parameter(Mandatory = $true)][string]$Href
    )

    $cleanHref = ($Href.Trim() -split '#', 2)[0].Trim()

    if ([string]::IsNullOrWhiteSpace($cleanHref)) {
        return $null
    }

    if ($cleanHref -match '^[a-zA-Z][a-zA-Z0-9+.-]*://') {
        return $null
    }

    $pathPart = $cleanHref.Replace('/', [System.IO.Path]::DirectorySeparatorChar)

    if ($pathPart -match '^docs[\\/]') {
        return [System.IO.Path]::GetFullPath((Join-Path $Root $pathPart))
    }

    if ([System.IO.Path]::IsPathRooted($pathPart)) {
        return [System.IO.Path]::GetFullPath($pathPart)
    }

    return [System.IO.Path]::GetFullPath((Join-Path $SourceFile.DirectoryName $pathPart))
}

function Get-RegisteredWindowNames {
    if (-not (Test-Path -LiteralPath $WindowRegistryPath -PathType Leaf)) {
        return @()
    }

    $names = New-Object System.Collections.Generic.List[string]
    $lines = Get-Content -LiteralPath $WindowRegistryPath -Encoding UTF8

    foreach ($line in $lines) {
        if ($line -notmatch '^\|') {
            continue
        }

        if ($line -match '^\|\s*-+') {
            continue
        }

        $columns = @($line.Trim('|') -split '\|' | ForEach-Object { $_.Trim() })

        if ($columns.Count -lt 7) {
            continue
        }

        if ($columns[0] -eq '左侧窗口') {
            continue
        }

        if ($columns[3] -notmatch '\(tasks/') {
            continue
        }

        $names.Add($columns[0])
    }

    return @($names)
}

if (-not (Test-Path -LiteralPath $QueueDir -PathType Container)) {
    throw "Missing dispatch queue directory: $QueueDir"
}

if ($AllowedWindows.Count -eq 0) {
    $AllowedWindows = @(Get-RegisteredWindowNames)
}

if ($AllowedWindows.Count -eq 0) {
    throw "No registered windows found. Provide -AllowedWindows or check docs/window-registry.md."
}

$files = @(Get-ChildItem -LiteralPath $QueueDir -Filter '*.md' -File | Sort-Object Name)
$seenTaskIds = @{}
$requiredFields = @('Task ID', 'Status', 'Priority', 'Source Window', 'Target Window', 'Created', 'Updated')
$linkPattern = '`(?<href>docs/[^`]+\.md)`'

foreach ($file in $files) {
    $content = Get-Content -LiteralPath $file.FullName -Raw -Encoding UTF8

    foreach ($field in $requiredFields) {
        $value = Get-MetadataValue -Content $content -Key $field

        if ([string]::IsNullOrWhiteSpace($value)) {
            Add-Issue -Code 'MISSING_FIELD' -File $file.FullName -Message "Missing required field: $field"
        }
    }

    $taskId = Get-MetadataValue -Content $content -Key 'Task ID'
    if (-not [string]::IsNullOrWhiteSpace($taskId)) {
        if ($seenTaskIds.ContainsKey($taskId)) {
            Add-Issue -Code 'DUPLICATE_TASK_ID' -File $file.FullName -Message "Task ID also used by $($seenTaskIds[$taskId])"
        } else {
            $seenTaskIds[$taskId] = ConvertTo-RepoPath $file.FullName
        }
    }

    $status = Get-MetadataValue -Content $content -Key 'Status'
    if (-not [string]::IsNullOrWhiteSpace($status) -and ($AllowedStatuses -notcontains $status)) {
        Add-Issue -Code 'INVALID_STATUS' -File $file.FullName -Message "Invalid status '$status'. Allowed: $($AllowedStatuses -join ', ')"
    }

    $priority = Get-MetadataValue -Content $content -Key 'Priority'
    if (-not [string]::IsNullOrWhiteSpace($priority) -and ($AllowedPriorities -notcontains $priority)) {
        Add-Issue -Code 'INVALID_PRIORITY' -File $file.FullName -Message "Invalid priority '$priority'. Allowed: $($AllowedPriorities -join ', ')"
    }

    foreach ($windowField in @('Source Window', 'Target Window')) {
        $window = Get-MetadataValue -Content $content -Key $windowField
        if (-not [string]::IsNullOrWhiteSpace($window) -and ($AllowedWindows -notcontains $window)) {
            Add-Issue -Code 'INVALID_WINDOW' -File $file.FullName -Message "$windowField '$window' is not registered."
        }
    }

    foreach ($match in [regex]::Matches($content, $linkPattern)) {
        $href = $match.Groups['href'].Value
        $target = Resolve-DocLink -SourceFile $file -Href $href

        if ($target -and -not (Test-Path -LiteralPath $target -PathType Leaf)) {
            Add-Issue -Code 'BROKEN_DOC_REFERENCE' -File $file.FullName -Message "Referenced file does not exist: $href"
        }
    }
}

Write-Output 'Dispatch queue validation'
Write-Output "Root: $(ConvertTo-RepoPath $Root)"
Write-Output "Dispatch task files checked: $($files.Count)"

if ($Issues.Count -eq 0) {
    Write-Output 'Result: OK - no dispatch queue issues found.'
    exit 0
}

Write-Output "Result: FAIL - found $($Issues.Count) issue(s)."

foreach ($issue in $Issues) {
    Write-Output "[$($issue.Code)] $($issue.File)"
    Write-Output "  $($issue.Message)"
}

exit 1
