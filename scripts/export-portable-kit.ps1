[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Destination,

    [ValidateSet('Minimal', 'Recommended', 'Research')]
    [string]$Profile = 'Minimal',

    [string]$Root,

    [switch]$Clean,

    [switch]$NoClobber,

    [switch]$BackupExisting
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
$Destination = [System.IO.Path]::GetFullPath($Destination)
$BackupRoot = $null
$SkippedItems = New-Object System.Collections.Generic.List[string]
$BackedUpItems = New-Object System.Collections.Generic.List[string]

if ($NoClobber -and $BackupExisting) {
    throw 'Use either -NoClobber or -BackupExisting, not both.'
}

if ($Clean -and ($NoClobber -or $BackupExisting)) {
    throw 'Use -Clean only for empty/test exports. Do not combine it with -NoClobber or -BackupExisting.'
}

if ($BackupExisting) {
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $BackupRoot = Join-Path $Destination ".portable-kit-backups\$timestamp"
}

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

function New-PortableDirectory {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    New-Item -ItemType Directory -Force -Path (Join-Path $Destination $RelativePath) | Out-Null
}

function Copy-PortableFile {
    param(
        [Parameter(Mandatory = $true)][string]$SourceFile,
        [Parameter(Mandatory = $true)][string]$RelativePath
    )

    $target = Join-Path $Destination $RelativePath
    $targetParent = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $targetParent | Out-Null

    if (Test-Path -LiteralPath $target -PathType Leaf) {
        if ($NoClobber) {
            $script:SkippedItems.Add($RelativePath)
            return
        }

        if ($BackupExisting) {
            $backupTarget = Join-Path $BackupRoot $RelativePath
            $backupParent = Split-Path -Parent $backupTarget
            New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
            Copy-Item -LiteralPath $target -Destination $backupTarget -Force
            $script:BackedUpItems.Add($RelativePath)
        }
    }

    Copy-Item -LiteralPath $SourceFile -Destination $target -Force
}

function Copy-PortableItem {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $source = Join-Path $Root $RelativePath

    if (-not (Test-Path -LiteralPath $source)) {
        throw "Portable source item does not exist: $RelativePath"
    }

    if (Test-Path -LiteralPath $source -PathType Container) {
        $sourceRoot = [System.IO.Path]::GetFullPath($source)

        foreach ($file in Get-ChildItem -LiteralPath $source -Recurse -File) {
            $fullName = [System.IO.Path]::GetFullPath($file.FullName)
            $relativeFile = $fullName.Substring($sourceRoot.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
            $targetRelative = Join-Path $RelativePath $relativeFile
            Copy-PortableFile -SourceFile $file.FullName -RelativePath $targetRelative
        }

        return
    }

    Copy-PortableFile -SourceFile $source -RelativePath $RelativePath
}

function Set-PortableFileContent {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [AllowEmptyString()][string[]]$Value
    )

    $target = Join-Path $Destination $RelativePath
    $targetParent = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $targetParent | Out-Null

    if (Test-Path -LiteralPath $target -PathType Leaf) {
        if ($NoClobber) {
            $script:SkippedItems.Add($RelativePath)
            return
        }

        if ($BackupExisting) {
            $backupTarget = Join-Path $BackupRoot $RelativePath
            $backupParent = Split-Path -Parent $backupTarget
            New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
            Copy-Item -LiteralPath $target -Destination $backupTarget -Force
            $script:BackedUpItems.Add($RelativePath)
        }
    }

    Set-Content -LiteralPath $target -Value $Value -Encoding UTF8
}

$minimalItems = @(
    'AGENTS.md',
    'docs/window-registry.md',
    'docs/windows',
    'docs/tasks',
    'docs/dispatch/README.md',
    'docs/dispatch/archive/README.md',
    'docs/workflow/window-boot-protocol.md',
    'docs/workflow/window-preflight-check.md',
    'docs/workflow/new-project-bootstrap.md',
    'docs/workflow/legacy-conversation-onboarding.md',
    'docs/workflow/project-control-onboarding.md',
    'docs/workflow/bootstrap-and-update.md',
    'docs/workflow/experience-evaluation.md',
    'docs/templates/short-window-commands.md',
    'docs/templates/dispatch-task-template.md',
    'docs/templates/legacy-window-onboarding-prompt.md',
    'docs/templates/project-control-charter.md',
    'docs/templates/project-experience-sync-packet.md',
    'skills/codex-window-workflow',
    'scripts/export-portable-kit.ps1',
    'scripts/bootstrap-codex-workflow.ps1',
    'scripts/update-codex-workflow.ps1',
    'scripts/check-dispatch-window.ps1',
    'scripts/install-codex-window-skill.ps1',
    'scripts/new-project-scaffold.ps1',
    'scripts/get-next-dispatch-task.ps1',
    'scripts/validate-dispatch-queue.ps1',
    'scripts/validate-window-consistency.ps1'
)

$recommendedItems = @(
    'docs/workflow/research-method.md',
    'docs/workflow/github-sync.md',
    'docs/templates/research-note-template.md',
    'docs/templates/experiment-log-template.md',
    'docs/templates/task-dispatch-template.md',
    'docs/templates/universal-window-start-prompt.md'
)

$researchItems = @(
    'docs/topics',
    'docs/workflow/window-boot-validation.md',
    'docs/workflow/boundary-handoff-test.md',
    'docs/workflow/handoff-receive-test.md',
    'docs/workflow/codex-app-troubleshooting.md'
)

$emptyDirectories = @(
    'docs/dispatch/queue',
    'docs/topics'
)

if ($Clean -and (Test-Path -LiteralPath $Destination)) {
    $resolvedDestination = [System.IO.Path]::GetFullPath($Destination)
    $resolvedRoot = [System.IO.Path]::GetFullPath($Root)

    if ($resolvedDestination.Equals($resolvedRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Refusing to clean repository root.'
    }

    if ($resolvedRoot.StartsWith($resolvedDestination, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw 'Refusing to clean a parent directory of the repository root.'
    }

    Remove-Item -LiteralPath $Destination -Recurse -Force
}

New-Item -ItemType Directory -Force -Path $Destination | Out-Null

$items = New-Object System.Collections.Generic.List[string]
$minimalItems | ForEach-Object { $items.Add($_) }

if ($Profile -in @('Recommended', 'Research')) {
    $recommendedItems | ForEach-Object { $items.Add($_) }
}

if ($Profile -eq 'Research') {
    $researchItems | ForEach-Object { $items.Add($_) }
}

foreach ($item in $items) {
    Copy-PortableItem -RelativePath $item
}

foreach ($dir in $emptyDirectories) {
    if ($Profile -eq 'Research' -and $dir -eq 'docs/topics') {
        continue
    }

    New-PortableDirectory -RelativePath $dir
}

$manifestPath = Join-Path $Destination 'PORTABLE_KIT.md'
$exportedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
$fence = '```'
$manifest = @(
    '# CodeX Portable Kit',
    '',
    "Profile: $Profile",
    "Exported: $exportedAt",
    "Source: $(ConvertTo-RepoPath $Root)",
    '',
    '## Next Steps',
    '',
    '1. Review `docs/window-registry.md` for the target project.',
    '2. Remove window/task files that do not apply.',
    '3. Run:',
    '',
    $fence,
    'powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate-window-consistency.ps1',
    'powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate-dispatch-queue.ps1',
    $fence,
    '',
    '4. In each target Codex window, use the startup command listed in `docs/templates/short-window-commands.md`.',
    '',
    '5. For legacy conversations, use `docs/templates/legacy-window-onboarding-prompt.md` if available, or follow `docs/workflow/new-project-bootstrap.md`.',
    ''
)

Set-PortableFileContent -RelativePath 'PORTABLE_KIT.md' -Value $manifest

Write-Output 'Portable kit export complete.'
Write-Output "Profile: $Profile"
Write-Output "Destination: $Destination"
Write-Output "Files/directories copied: $($items.Count)"
Write-Output 'Created empty directories:'
foreach ($dir in $emptyDirectories) {
    if ($Profile -eq 'Research' -and $dir -eq 'docs/topics') {
        continue
    }

    Write-Output "  $dir"
}

if ($BackupExisting) {
    Write-Output "Backup root: $BackupRoot"
    Write-Output "Existing files backed up: $($BackedUpItems.Count)"
}

if ($NoClobber) {
    Write-Output "Existing files skipped: $($SkippedItems.Count)"
    foreach ($item in $SkippedItems) {
        Write-Output "  $item"
    }
}
