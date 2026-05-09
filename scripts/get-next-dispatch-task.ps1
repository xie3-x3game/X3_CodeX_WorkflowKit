[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WindowName,

    [string]$Root,

    [switch]$List,

    [string[]]$ReadyStatuses = @('Ready', 'Inbox')
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

function Get-MetadataValue {
    param(
        [Parameter(Mandatory = $true)][string]$Content,
        [Parameter(Mandatory = $true)][string]$Key
    )

    $pattern = "(?m)^$([regex]::Escape($Key)):\s*(?<value>.+?)\s*$"
    $match = [regex]::Match($Content, $pattern)

    if ($match.Success) {
        return $match.Groups['value'].Value.Trim()
    }

    return ''
}

function Get-PriorityRank {
    param([string]$Priority)

    switch ($Priority) {
        'P0' { return 0 }
        'P1' { return 1 }
        'P2' { return 2 }
        'P3' { return 3 }
        default { return 9 }
    }
}

function Read-DispatchTask {
    param([Parameter(Mandatory = $true)][System.IO.FileInfo]$File)

    $content = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
    $createdValue = Get-MetadataValue -Content $content -Key 'Created'
    $createdDate = [datetime]::MaxValue

    if (-not [datetime]::TryParse($createdValue, [ref]$createdDate)) {
        $createdDate = [datetime]::MaxValue
    }

    [pscustomobject]@{
        TaskId = Get-MetadataValue -Content $content -Key 'Task ID'
        Status = Get-MetadataValue -Content $content -Key 'Status'
        Priority = Get-MetadataValue -Content $content -Key 'Priority'
        PriorityRank = Get-PriorityRank (Get-MetadataValue -Content $content -Key 'Priority')
        SourceWindow = Get-MetadataValue -Content $content -Key 'Source Window'
        TargetWindow = Get-MetadataValue -Content $content -Key 'Target Window'
        Created = $createdValue
        CreatedDate = $createdDate
        Updated = Get-MetadataValue -Content $content -Key 'Updated'
        Title = ($content -split "`r?`n" | Select-Object -First 1).TrimStart('#').Trim()
        Path = ConvertTo-RepoPath $File.FullName
    }
}

if (-not (Test-Path -LiteralPath $QueueDir -PathType Container)) {
    throw "Missing dispatch queue directory: $QueueDir"
}

$tasks = @(Get-ChildItem -LiteralPath $QueueDir -Filter '*.md' -File |
    ForEach-Object { Read-DispatchTask -File $_ } |
    Where-Object {
        $_.TargetWindow -eq $WindowName -and ($ReadyStatuses -contains $_.Status)
    } |
    Sort-Object PriorityRank, CreatedDate, TaskId)

if ($tasks.Count -eq 0) {
    Write-Output "No ready dispatch tasks for window: $WindowName"
    exit 0
}

if ($List) {
    Write-Output "Ready dispatch tasks for window: $WindowName"

    foreach ($task in $tasks) {
        Write-Output "$($task.Priority) $($task.TaskId) [$($task.Status)] $($task.Title)"
        Write-Output "  Path: $($task.Path)"
        Write-Output "  Source: $($task.SourceWindow)"
        Write-Output "  Created: $($task.Created)"
    }

    exit 0
}

$next = $tasks[0]

Write-Output "Next dispatch task for window: $WindowName"
Write-Output "Task ID: $($next.TaskId)"
Write-Output "Status: $($next.Status)"
Write-Output "Priority: $($next.Priority)"
Write-Output "Source Window: $($next.SourceWindow)"
Write-Output "Target Window: $($next.TargetWindow)"
Write-Output "Created: $($next.Created)"
Write-Output "Path: $($next.Path)"
Write-Output "Title: $($next.Title)"
