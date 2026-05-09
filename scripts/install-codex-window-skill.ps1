[CmdletBinding()]
param(
    [string]$Root,

    [string]$SkillsRoot,

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

if ([string]::IsNullOrWhiteSpace($SkillsRoot)) {
    if (-not [string]::IsNullOrWhiteSpace($env:CODEX_HOME)) {
        $SkillsRoot = Join-Path $env:CODEX_HOME 'skills'
    } else {
        $SkillsRoot = Join-Path $HOME '.codex\skills'
    }
}

$SkillsRoot = [System.IO.Path]::GetFullPath($SkillsRoot)
$SourceSkillDir = Join-Path $Root 'skills/codex-window-workflow'
$TargetSkillDir = Join-Path $SkillsRoot 'codex-window-workflow'

if ($NoClobber -and $BackupExisting) {
    throw 'Use either -NoClobber or -BackupExisting, not both.'
}

if (-not (Test-Path -LiteralPath $SourceSkillDir -PathType Container)) {
    throw "Missing source skill directory: $SourceSkillDir"
}

if (Test-Path -LiteralPath $TargetSkillDir) {
    if ($NoClobber) {
        Write-Output 'Codex window workflow skill already exists. No changes made.'
        Write-Output "Target: $TargetSkillDir"
        exit 0
    }

    if ($BackupExisting) {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $BackupRoot = Join-Path $SkillsRoot ".codex-skill-backups\$timestamp"
        $BackupTarget = Join-Path $BackupRoot 'codex-window-workflow'
        New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
        Copy-Item -LiteralPath $TargetSkillDir -Destination $BackupTarget -Recurse -Force
    }
}

New-Item -ItemType Directory -Force -Path $TargetSkillDir | Out-Null

foreach ($item in Get-ChildItem -LiteralPath $SourceSkillDir -Force) {
    $target = Join-Path $TargetSkillDir $item.Name
    Copy-Item -LiteralPath $item.FullName -Destination $target -Recurse -Force
}

Write-Output 'Codex window workflow skill installed.'
Write-Output "Source: $SourceSkillDir"
Write-Output "Target: $TargetSkillDir"

if ($BackupExisting -and $BackupRoot) {
    Write-Output "Backup: $BackupTarget"
}
