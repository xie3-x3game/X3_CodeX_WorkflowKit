[CmdletBinding()]
param(
    [string]$RepositoryUrl = 'https://github.com/xie3-x3game/X3_CodeX_WorkflowKit.git',

    [string]$Branch = 'main',

    [string]$InstallRoot,

    [ValidateSet('PortableKit', 'FullRepo')]
    [string]$InstallMode = 'PortableKit',

    [string]$LocalSourceRoot,

    [string]$SkillsRoot,

    [switch]$NoSkillInstall,

    [switch]$NoValidate,

    [switch]$NoClobber
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($InstallRoot)) {
    $InstallRoot = Join-Path $HOME 'X3_CodeX_Workflow'
}

$InstallRoot = [System.IO.Path]::GetFullPath($InstallRoot)
$Transport = 'unknown'

function Get-GitCommand {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        return $git.Source
    }

    $fallback = 'C:\Program Files\Git\cmd\git.exe'
    if (Test-Path -LiteralPath $fallback -PathType Leaf) {
        return $fallback
    }

    return $null
}

function Get-GitHubZipUrl {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][string]$Ref
    )

    if ($Repo -match 'github\.com[:/](?<owner>[^/\\]+)[/\\](?<name>[^/\\]+?)(\.git)?$') {
        $owner = $Matches.owner
        $name = $Matches.name
        return "https://github.com/$owner/$name/archive/refs/heads/$Ref.zip"
    }

    return $null
}

function Test-DirectoryHasItems {
    param([Parameter(Mandatory = $true)][string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        return $false
    }

    $first = Get-ChildItem -LiteralPath $Path -Force | Select-Object -First 1
    return $null -ne $first
}

function Backup-SourceDirectory {
    param([Parameter(Mandatory = $true)][string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    $leaf = Split-Path -Leaf $fullPath

    if ($leaf -ne '.source') {
        throw "Refusing to replace a non-.source directory without git: $fullPath"
    }

    $parent = Split-Path -Parent $fullPath
    $backupRoot = Join-Path $parent '.source-backups'
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backupPath = Join-Path $backupRoot $timestamp

    New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
    Move-Item -LiteralPath $fullPath -Destination $backupPath

    Write-Output "Previous source snapshot backed up: $backupPath"
}

function Sync-SourceWithGit {
    param([Parameter(Mandatory = $true)][string]$SourceRoot)

    $git = Get-GitCommand
    if (-not $git) {
        return $false
    }

    if (Test-Path -LiteralPath (Join-Path $SourceRoot '.git') -PathType Container) {
        Push-Location $SourceRoot
        try {
            & $git fetch origin $Branch
            if ($LASTEXITCODE -ne 0) { throw "git fetch failed with exit code $LASTEXITCODE" }

            & $git checkout $Branch
            if ($LASTEXITCODE -ne 0) { throw "git checkout failed with exit code $LASTEXITCODE" }

            & $git pull --ff-only origin $Branch
            if ($LASTEXITCODE -ne 0) { throw "git pull failed with exit code $LASTEXITCODE" }
        } finally {
            Pop-Location
        }

        $script:Transport = 'git-pull'
        return $true
    }

    if (Test-DirectoryHasItems -Path $SourceRoot) {
        $leaf = Split-Path -Leaf ([System.IO.Path]::GetFullPath($SourceRoot))
        if ($leaf -eq '.source') {
            Backup-SourceDirectory -Path $SourceRoot
        } else {
            throw "Install root already exists and is not a git repo: $SourceRoot"
        }
    }

    $parent = Split-Path -Parent ([System.IO.Path]::GetFullPath($SourceRoot))
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    & $git clone --branch $Branch $RepositoryUrl $SourceRoot
    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed with exit code $LASTEXITCODE"
    }

    $script:Transport = 'git-clone'
    return $true
}

function Sync-SourceWithZip {
    param([Parameter(Mandatory = $true)][string]$SourceRoot)

    $zipUrl = Get-GitHubZipUrl -Repo $RepositoryUrl -Ref $Branch
    if (-not $zipUrl) {
        throw "Git is not available and RepositoryUrl is not a GitHub URL that can be downloaded as a zip: $RepositoryUrl"
    }

    if (Test-DirectoryHasItems -Path $SourceRoot) {
        Backup-SourceDirectory -Path $SourceRoot
    }

    $parent = Split-Path -Parent ([System.IO.Path]::GetFullPath($SourceRoot))
    New-Item -ItemType Directory -Force -Path $parent | Out-Null

    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("codex-workflow-bootstrap-" + [System.Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null

    try {
        $zipPath = Join-Path $tempRoot 'source.zip'
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
        Expand-Archive -LiteralPath $zipPath -DestinationPath $tempRoot

        $expanded = Get-ChildItem -LiteralPath $tempRoot -Directory | Select-Object -First 1
        if (-not $expanded) {
            throw 'Downloaded source zip did not contain an expanded directory.'
        }

        Move-Item -LiteralPath $expanded.FullName -Destination $SourceRoot
    } finally {
        if (Test-Path -LiteralPath $tempRoot) {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force
        }
    }

    $script:Transport = 'github-zip'
}

function Resolve-SourceRoot {
    if (-not [string]::IsNullOrWhiteSpace($LocalSourceRoot)) {
        if ($InstallMode -eq 'FullRepo') {
            throw 'Use -LocalSourceRoot only with -InstallMode PortableKit.'
        }

        $resolved = (Resolve-Path -LiteralPath $LocalSourceRoot).Path
        $script:Transport = 'local-source'
        return $resolved
    }

    if ($InstallMode -eq 'FullRepo') {
        $sourceRoot = $InstallRoot
    } else {
        $sourceRoot = Join-Path $InstallRoot '.source'
    }

    if (-not (Sync-SourceWithGit -SourceRoot $sourceRoot)) {
        Sync-SourceWithZip -SourceRoot $sourceRoot
    }

    return (Resolve-Path -LiteralPath $sourceRoot).Path
}

$SourceRoot = Resolve-SourceRoot

if ($InstallMode -eq 'PortableKit') {
    $exportScript = Join-Path $SourceRoot 'scripts/export-portable-kit.ps1'
    if (-not (Test-Path -LiteralPath $exportScript -PathType Leaf)) {
        throw "Missing portable kit export script: $exportScript"
    }

    $exportArgs = @{
        Destination = $InstallRoot
        Profile = 'Minimal'
        Root = $SourceRoot
    }

    if ($NoClobber) {
        $exportArgs.NoClobber = $true
    } else {
        $exportArgs.BackupExisting = $true
    }

    & $exportScript @exportArgs
} else {
    if (-not (Test-Path -LiteralPath $InstallRoot -PathType Container)) {
        throw "Install root was not created: $InstallRoot"
    }
}

if (-not $NoSkillInstall) {
    $installSkillScript = Join-Path $InstallRoot 'scripts/install-codex-window-skill.ps1'
    if (-not (Test-Path -LiteralPath $installSkillScript -PathType Leaf)) {
        throw "Missing skill install script: $installSkillScript"
    }

    $skillArgs = @{
        Root = $InstallRoot
    }
    if (-not [string]::IsNullOrWhiteSpace($SkillsRoot)) {
        $skillArgs.SkillsRoot = $SkillsRoot
    }

    if ($NoClobber) {
        $skillArgs.NoClobber = $true
    } else {
        $skillArgs.BackupExisting = $true
    }

    & $installSkillScript @skillArgs
}

if (-not $NoValidate) {
    $windowCheck = Join-Path $InstallRoot 'scripts/validate-window-consistency.ps1'
    $dispatchCheck = Join-Path $InstallRoot 'scripts/validate-dispatch-queue.ps1'

    if (Test-Path -LiteralPath $windowCheck -PathType Leaf) {
        & $windowCheck -Root $InstallRoot
    }

    if (Test-Path -LiteralPath $dispatchCheck -PathType Leaf) {
        & $dispatchCheck -Root $InstallRoot
    }
}

Write-Output 'CodeX workflow bootstrap complete.'
Write-Output "Install mode: $InstallMode"
Write-Output "Transport: $Transport"
Write-Output "Source root: $SourceRoot"
Write-Output "Install root: $InstallRoot"

if (-not $NoSkillInstall) {
    if ([string]::IsNullOrWhiteSpace($SkillsRoot)) {
        Write-Output 'Skill install target: default Codex skills directory'
    } else {
        Write-Output "Skill install target: $SkillsRoot"
    }
}

Write-Output 'Next command in a new Codex window: Use $codex-window-workflow to scaffold or check this project.'
