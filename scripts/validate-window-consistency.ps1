[CmdletBinding()]
param(
    [string]$Root,
    [string[]]$TaskSupportFiles = @('README.md', 'routing-rules.md'),
    [string[]]$WindowSupportFiles = @('README.md')
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
$TasksDir = Join-Path $Root 'docs/tasks'
$WindowsDir = Join-Path $Root 'docs/windows'
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

function Resolve-DocLink {
    param(
        [Parameter(Mandatory = $true)][System.IO.FileInfo]$SourceFile,
        [Parameter(Mandatory = $true)][string]$Href
    )

    $cleanHref = $Href.Trim()

    if ($cleanHref -match '^[a-zA-Z][a-zA-Z0-9+.-]*://') {
        return $null
    }

    $cleanHref = ($cleanHref -split '#', 2)[0].Trim()

    if ([string]::IsNullOrWhiteSpace($cleanHref)) {
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

function Get-WindowGuideLinks {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$TaskFile)

    $content = Get-Content -LiteralPath $TaskFile.FullName -Raw -Encoding UTF8
    $linksByHref = @{}

    $markdownLinkPattern = '\[[^\]]+\]\((?<href>[^)\s]+)(?:\s+"[^"]+")?\)'
    foreach ($match in [regex]::Matches($content, $markdownLinkPattern)) {
        $href = $match.Groups['href'].Value
        if ($href -match '(^|[/\\])windows[/\\].+\.md(#.*)?$') {
            $linksByHref[$href] = $true
        }
    }

    $plainPathPattern = '(?<href>(?:\.\.[/\\]windows|docs[/\\]windows)[/\\][A-Za-z0-9._-]+\.md(?:#[A-Za-z0-9._-]+)?)'
    foreach ($match in [regex]::Matches($content, $plainPathPattern)) {
        $href = $match.Groups['href'].Value
        $linksByHref[$href] = $true
    }

    foreach ($href in ($linksByHref.Keys | Sort-Object)) {
        [pscustomobject]@{
            Href = $href
            Target = Resolve-DocLink -SourceFile $TaskFile -Href $href
        }
    }
}

if (-not (Test-Path -LiteralPath $TasksDir -PathType Container)) {
    throw "Missing directory: $TasksDir"
}

if (-not (Test-Path -LiteralPath $WindowsDir -PathType Container)) {
    throw "Missing directory: $WindowsDir"
}

$taskFiles = @(Get-ChildItem -LiteralPath $TasksDir -Filter '*.md' -File | Sort-Object Name)
$windowFiles = @(Get-ChildItem -LiteralPath $WindowsDir -Filter '*.md' -File | Sort-Object Name)

$taskWindowFiles = @($taskFiles | Where-Object { $TaskSupportFiles -notcontains $_.Name })
$windowGuideFiles = @($windowFiles | Where-Object { $WindowSupportFiles -notcontains $_.Name })

foreach ($taskFile in $taskWindowFiles) {
    $expectedWindowPath = Join-Path $WindowsDir $taskFile.Name

    if (-not (Test-Path -LiteralPath $expectedWindowPath -PathType Leaf)) {
        Add-Issue `
            -Code 'MISSING_WINDOW_GUIDE' `
            -File $taskFile.FullName `
            -Message "Expected matching guide: $(ConvertTo-RepoPath $expectedWindowPath)"
    }
}

foreach ($windowFile in $windowGuideFiles) {
    $expectedTaskPath = Join-Path $TasksDir $windowFile.Name

    if (-not (Test-Path -LiteralPath $expectedTaskPath -PathType Leaf)) {
        Add-Issue `
            -Code 'MISSING_TASK_FILE' `
            -File $windowFile.FullName `
            -Message "Expected matching task file: $(ConvertTo-RepoPath $expectedTaskPath)"
    }
}

$guideReferenceCount = 0

foreach ($taskFile in $taskFiles) {
    $guideLinks = @(Get-WindowGuideLinks -TaskFile $taskFile)

    foreach ($guideLink in $guideLinks) {
        $guideReferenceCount++

        if (-not $guideLink.Target) {
            continue
        }

        if (-not (Test-Path -LiteralPath $guideLink.Target -PathType Leaf)) {
            Add-Issue `
                -Code 'BROKEN_WINDOW_GUIDE_REFERENCE' `
                -File $taskFile.FullName `
                -Message "Referenced guide does not exist: $($guideLink.Href)"
        }
    }

    if ($TaskSupportFiles -contains $taskFile.Name) {
        continue
    }

    $expectedWindowPath = [System.IO.Path]::GetFullPath((Join-Path $WindowsDir $taskFile.Name))
    $hasExpectedGuideLink = $false

    foreach ($guideLink in $guideLinks) {
        if (-not $guideLink.Target) {
            continue
        }

        $targetPath = [System.IO.Path]::GetFullPath($guideLink.Target)
        if ($targetPath.Equals($expectedWindowPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $hasExpectedGuideLink = $true
            break
        }
    }

    if (-not $hasExpectedGuideLink) {
        Add-Issue `
            -Code 'MISSING_EXPECTED_WINDOW_GUIDE_REFERENCE' `
            -File $taskFile.FullName `
            -Message "Expected a reference to $(ConvertTo-RepoPath $expectedWindowPath)"
    }
}

Write-Output 'Window consistency validation'
Write-Output "Root: $(ConvertTo-RepoPath $Root)"
Write-Output "Window task files checked: $($taskWindowFiles.Count)"
Write-Output "Window guide files checked: $($windowGuideFiles.Count)"
Write-Output "Window guide references checked: $guideReferenceCount"
Write-Output "Ignored task support files: $($TaskSupportFiles -join ', ')"
Write-Output "Ignored window support files: $($WindowSupportFiles -join ', ')"

if ($Issues.Count -eq 0) {
    Write-Output 'Result: OK - no missing, inconsistent, or broken window guide links found.'
    exit 0
}

Write-Output "Result: FAIL - found $($Issues.Count) issue(s)."

foreach ($issue in $Issues) {
    Write-Output "[$($issue.Code)] $($issue.File)"
    Write-Output "  $($issue.Message)"
}

exit 1
