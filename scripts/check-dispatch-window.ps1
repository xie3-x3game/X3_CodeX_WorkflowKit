[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$WindowName,

    [string]$Root,

    [string[]]$InboxStatuses = @('Inbox', 'Ready'),

    [string[]]$ClosedStatuses = @('Done', 'Dropped', 'Archived')
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

function Write-TaskList {
    param(
        [Parameter(Mandatory = $true)][string]$Heading,
        [object[]]$Tasks = @()
    )

    Write-Output $Heading

    if ($Tasks.Count -eq 0) {
        Write-Output '  None'
        return
    }

    foreach ($task in $Tasks) {
        Write-Output "  $($task.Priority) $($task.TaskId) [$($task.Status)] $($task.Title)"
        Write-Output "    Path: $($task.Path)"
        Write-Output "    Source: $($task.SourceWindow)"
        Write-Output "    Target: $($task.TargetWindow)"
        Write-Output "    Created: $($task.Created)"
    }
}

if (-not (Test-Path -LiteralPath $QueueDir -PathType Container)) {
    throw "Missing dispatch queue directory: $QueueDir"
}

$tasks = @(Get-ChildItem -LiteralPath $QueueDir -Filter '*.md' -File |
    ForEach-Object { Read-DispatchTask -File $_ } |
    Sort-Object PriorityRank, CreatedDate, TaskId)

$inbox = @($tasks | Where-Object {
    $_.TargetWindow -eq $WindowName -and ($InboxStatuses -contains $_.Status)
})

$outbox = @($tasks | Where-Object {
    $_.SourceWindow -eq $WindowName -and ($ClosedStatuses -notcontains $_.Status)
})

Write-Output "Dispatch preflight for window: $WindowName"
Write-Output "Queue: $(ConvertTo-RepoPath $QueueDir)"
Write-Output ''
Write-TaskList -Heading 'Inbox tasks:' -Tasks $inbox
Write-Output ''
Write-TaskList -Heading 'Outbox tasks not closed:' -Tasks $outbox
Write-Output ''

if ($inbox.Count -eq 0 -and $outbox.Count -eq 0) {
    Write-Output 'Recommendation: no open dispatch tasks for this window. Continue with the new request.'
    exit 0
}

if ($inbox.Count -gt 0) {
    $next = $inbox[0]
    Write-Output "Recommendation: consider handling inbox task $($next.TaskId) first, or explicitly keep it Ready while handling the new request."
} else {
    Write-Output 'Recommendation: no inbox task blocks new work. Review outbox status only if relevant.'
}
