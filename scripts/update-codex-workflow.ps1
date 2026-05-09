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

$bootstrap = Join-Path $PSScriptRoot 'bootstrap-codex-workflow.ps1'
if (-not (Test-Path -LiteralPath $bootstrap -PathType Leaf)) {
    throw "Missing bootstrap script: $bootstrap"
}

$args = @{
    RepositoryUrl = $RepositoryUrl
    Branch = $Branch
    InstallMode = $InstallMode
}

if (-not [string]::IsNullOrWhiteSpace($InstallRoot)) {
    $args.InstallRoot = $InstallRoot
}

if (-not [string]::IsNullOrWhiteSpace($LocalSourceRoot)) {
    $args.LocalSourceRoot = $LocalSourceRoot
}

if (-not [string]::IsNullOrWhiteSpace($SkillsRoot)) {
    $args.SkillsRoot = $SkillsRoot
}

if ($NoSkillInstall) {
    $args.NoSkillInstall = $true
}

if ($NoValidate) {
    $args.NoValidate = $true
}

if ($NoClobber) {
    $args.NoClobber = $true
}

& $bootstrap @args
