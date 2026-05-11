[CmdletBinding()]
param(
    [string]$KitRoot,

    [string[]]$ProjectRoot,

    [string]$ProjectsFile,

    [string[]]$RuleId = @('RU-20260511-001', 'RU-20260511-003', 'RU-20260511-004'),

    [switch]$DryRun,

    [switch]$NoBackup
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($KitRoot)) {
    if ($PSScriptRoot) {
        $KitRoot = Join-Path $PSScriptRoot '..'
    } else {
        $KitRoot = (Get-Location).Path
    }
}

$KitRoot = (Resolve-Path -LiteralPath $KitRoot).Path
$manifestPath = Join-Path $KitRoot 'docs/workflow/rule-update-manifest.json'

if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Missing rule update manifest: $manifestPath"
}

function ConvertTo-ValueArray {
    param([object]$Value)

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [System.Array]) {
        return @($Value)
    }

    return @($Value)
}

function Add-ProjectPath {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$List,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (-not $List.Contains($fullPath)) {
        $List.Add($fullPath)
    }
}

function Add-RuleId {
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.List[string]]$List,

        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return
    }

    $id = $Value.Trim()
    if (-not $List.Contains($id)) {
        $List.Add($id)
    }
}

function Get-SilentPreflightRule {
    return [pscustomobject]@{
        Id = 'RU-20260511-001'
        Title = 'Silent routine preflight output'
        AgentPath = 'AGENTS.md'
        PreflightPath = 'docs/workflow/window-preflight-check.md'
        PromptPath = 'docs/workflow/rule-update-refresh-prompts.md'
        AgentBlock = @(
            '<!-- RULE-UPDATE:RU-20260511-001:START -->',
            '',
            '## Rule Update: Silent Routine Preflight Output',
            '',
            'Routine boundary and dispatch checks still apply, but do not narrate them when there is no issue.',
            '',
            '- Perform lightweight boundary and dispatch preflight silently.',
            '- Reply naturally when there is no open task, boundary conflict, or user-requested check.',
            '- Explicitly mention preflight only when there are open Inbox/Outbox tasks, handoff decisions, boundary conflicts, file edits, Git/publish actions, privacy risks, or context confusion.',
            '- If the user explicitly asks to check dispatch or queue state, show the check result.',
            '',
            '<!-- RULE-UPDATE:RU-20260511-001:END -->'
        )
        PreflightBlock = @(
            '<!-- RULE-UPDATE:RU-20260511-001:START -->',
            '',
            '## Rule Update: Silent Routine Preflight Output',
            '',
            'Routine preflight still applies, but do not show fixed preflight wording when there is no issue.',
            '',
            '- If there is no open Inbox/Outbox task and no boundary conflict, complete the check silently and reply naturally.',
            '- Explicitly mention preflight only when there are open tasks, boundary conflicts, handoff choices, file edits, Git/publish actions, privacy risks, or context confusion.',
            '- If the user explicitly asks to check dispatch, queue state, or window state, show the check result.',
            '',
            '<!-- RULE-UPDATE:RU-20260511-001:END -->'
        )
        RefreshPrompt = @(
            'Rule refresh: reread this project''s AGENTS.md and docs/workflow/window-preflight-check.md, then follow RU-20260511-001 immediately.',
            '',
            'Requirement: keep doing routine boundary and dispatch preflight checks, but do not start ordinary replies with fixed wording such as "I will first run a lightweight dispatch preflight." If there is no open Inbox/Outbox task, no boundary conflict, and no explicit user request to check the queue, handle the new request naturally. Mention preflight only when there is an open task, boundary issue, handoff, file edit, Git/publish action, privacy risk, or context confusion.'
        )
    }
}

function Get-SilentVisibleProgressRule {
    return [pscustomobject]@{
        Id = 'RU-20260511-003'
        Title = 'Silent routine preflight in visible progress updates'
        AgentPath = 'AGENTS.md'
        PreflightPath = 'docs/workflow/window-preflight-check.md'
        PromptPath = 'docs/workflow/rule-update-refresh-prompts.md'
        AgentBlock = @(
            '<!-- RULE-UPDATE:RU-20260511-003:START -->',
            '',
            '## Rule Update: Silent Visible Progress Updates',
            '',
            'User-visible progress or status messages follow the same silence rule as final replies.',
            '',
            '- Do not use progress updates to announce routine dispatch preflight, boundary checks, or rule loading when there is no issue.',
            '- Progress updates should mention concrete work being done, blockers, edits, validation, Git/publish actions, privacy risks, or decisions that require user attention.',
            '- If a routine check finds no issue, neither final replies nor intermediate progress updates need to mention it.',
            '',
            '<!-- RULE-UPDATE:RU-20260511-003:END -->'
        )
        PreflightBlock = @(
            '<!-- RULE-UPDATE:RU-20260511-003:START -->',
            '',
            '## Rule Update: Silent Visible Progress Updates',
            '',
            'User-visible progress or status messages follow the same silence rule as final replies.',
            '',
            '- Do not use progress updates to announce routine dispatch preflight, boundary checks, or rule loading when there is no issue.',
            '- Progress updates should mention concrete work being done, blockers, edits, validation, Git/publish actions, privacy risks, or decisions that require user attention.',
            '- If a routine check finds no issue, neither final replies nor intermediate progress updates need to mention it.',
            '',
            '<!-- RULE-UPDATE:RU-20260511-003:END -->'
        )
        RefreshPrompt = @(
            'Rule refresh: reread this project''s AGENTS.md and docs/workflow/window-preflight-check.md, then follow RU-20260511-003 immediately.',
            '',
            'Requirement: user-visible progress or status messages must also avoid routine preflight narration. Do not use progress updates to say that you are doing ordinary dispatch preflight, boundary checks, or rule loading when there is no issue. Only mention concrete work, blockers, edits, validation, Git/publish actions, privacy risks, or decisions that need attention.'
        )
    }
}

function Get-SimpleFirstRule {
    return [pscustomobject]@{
        Id = 'RU-20260511-004'
        Title = 'Simple first, review before scaling'
        AgentPath = 'AGENTS.md'
        SecondaryPath = 'docs/workflow/project-control-onboarding.md'
        SecondaryLabel = 'project-control-onboarding.md'
        PromptPath = 'docs/workflow/rule-update-refresh-prompts.md'
        AgentBlock = @(
            '<!-- RULE-UPDATE:RU-20260511-004:START -->',
            '',
            '## Rule Update: Simple First, Review Before Scaling',
            '',
            'Start plans, projects, roles, records, and automation with the smallest useful structure.',
            '',
            '- Do not design a complete organization, taxonomy, workflow, or tool before real use requires it.',
            '- Prefer a draft note, template, checklist, or manual process first.',
            '- Expand into rules, scripts, automations, directories, or new windows only after review shows repeated need, higher risk, or clear value.',
            '- Use periodic or event-triggered review to decide when to merge, split, upgrade, archive, transfer, or automate.',
            '',
            '<!-- RULE-UPDATE:RU-20260511-004:END -->'
        )
        SecondaryBlock = @(
            '<!-- RULE-UPDATE:RU-20260511-004:START -->',
            '',
            '## Rule Update: Simple First, Review Before Scaling',
            '',
            'Start project structures, roles, communication records, and automation with the smallest useful version.',
            '',
            '- New projects should start with required total-control, index, and only the few windows that have real recurring work.',
            '- New specialist topics should remain under a parent project until real usage justifies promotion to an independent project.',
            '- New person, AI role, permission, and communication models should start with minimal fields and expand after review.',
            '- Use periodic or event-triggered review to merge, split, promote, archive, transfer, or automate only when real work requires it.',
            '',
            '<!-- RULE-UPDATE:RU-20260511-004:END -->'
        )
        RefreshPrompt = @(
            'Rule refresh: reread this project''s AGENTS.md and docs/workflow/project-control-onboarding.md, then follow RU-20260511-004 immediately.',
            '',
            'Requirement: start new plans, project structures, roles, records, and automation with the smallest useful version. Prefer draft notes, templates, checklists, or manual steps first. Expand into more windows, directories, rules, scripts, or automations only after real use and review show repeated need, higher risk, or clear value.'
        )
    }
}

function Get-RuleDefinition {
    param([Parameter(Mandatory = $true)][string]$Id)

    switch ($Id) {
        'RU-20260511-001' { return Get-SilentPreflightRule }
        'RU-20260511-003' { return Get-SilentVisibleProgressRule }
        'RU-20260511-004' { return Get-SimpleFirstRule }
        default { throw "Unsupported rule id for apply: $Id" }
    }
}

function Backup-ProjectFile {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string]$BackupRoot
    )

    if ($NoBackup -or $DryRun) {
        return
    }

    if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
        return
    }

    $projectFull = [System.IO.Path]::GetFullPath($ProjectPath)
    if (-not $projectFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $projectFull += [System.IO.Path]::DirectorySeparatorChar
    }

    $fileFull = [System.IO.Path]::GetFullPath($FilePath)
    $relative = $fileFull.Substring($projectFull.Length).TrimStart([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $backupTarget = Join-Path $BackupRoot $relative
    $backupParent = Split-Path -Parent $backupTarget
    New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
    Copy-Item -LiteralPath $FilePath -Destination $backupTarget -Force
}

function Add-BlockIfMissing {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Block,
        [Parameter(Mandatory = $true)][string]$StartMarker,
        [Parameter(Mandatory = $true)][string]$BackupRoot
    )

    $target = Join-Path $ProjectPath $RelativePath
    $parent = Split-Path -Parent $target

    $content = ''
    if (Test-Path -LiteralPath $target -PathType Leaf) {
        $content = Get-Content -LiteralPath $target -Raw -Encoding UTF8
    }

    if ($content.Contains($StartMarker)) {
        return 'AlreadyPresent'
    }

    if ($DryRun) {
        return "WouldAppend:$RelativePath"
    }

    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Backup-ProjectFile -ProjectPath $ProjectPath -FilePath $target -BackupRoot $BackupRoot

    if ([string]::IsNullOrWhiteSpace($content)) {
        Set-Content -LiteralPath $target -Value $Block -Encoding UTF8
    } else {
        $newContent = $content.TrimEnd() + [Environment]::NewLine + [Environment]::NewLine + ($Block -join [Environment]::NewLine) + [Environment]::NewLine
        Set-Content -LiteralPath $target -Value $newContent -Encoding UTF8 -NoNewline
    }

    return 'Appended'
}

function Set-InboxRuleStatus {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)][string]$RuleId,
        [Parameter(Mandatory = $true)][string]$BackupRoot
    )

    $inboxPath = Join-Path $ProjectPath 'docs/workflow/rule-update-inbox.md'
    if (-not (Test-Path -LiteralPath $inboxPath -PathType Leaf)) {
        return 'MissingInbox'
    }

    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($line in (Get-Content -LiteralPath $inboxPath -Encoding UTF8)) {
        $lines.Add($line)
    }

    $inside = $false
    $changed = $false
    $foundRule = $false

    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '^##\s+') {
            $inside = ($lines[$i] -match [regex]::Escape($RuleId))
            if ($inside) {
                $foundRule = $true
            }
        }

        if ($inside -and $lines[$i] -match '^Status:\s*') {
            if ($lines[$i] -ne 'Status: Applied') {
                $lines[$i] = 'Status: Applied'
                $changed = $true
            }
            continue
        }

        if ($inside -and $lines[$i] -eq '- [ ] Apply') {
            $lines[$i] = '- [x] Apply'
            $changed = $true
        }
    }

    if (-not $foundRule) {
        return 'RuleNotInInbox'
    }

    if (-not $changed) {
        return 'InboxAlreadyApplied'
    }

    if ($DryRun) {
        return 'WouldMarkInboxApplied'
    }

    Backup-ProjectFile -ProjectPath $ProjectPath -FilePath $inboxPath -BackupRoot $BackupRoot
    Set-Content -LiteralPath $inboxPath -Value $lines.ToArray() -Encoding UTF8
    return 'InboxMarkedApplied'
}

function Set-RefreshPromptFile {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectPath,
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$AppliedRules,
        [Parameter(Mandatory = $true)][string]$BackupRoot
    )

    if ($AppliedRules.Count -eq 0) {
        return 'NoPromptNeeded'
    }

    $promptPath = Join-Path $ProjectPath 'docs/workflow/rule-update-refresh-prompts.md'
    $generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'
    $projectName = Split-Path -Leaf $ProjectPath
    $lines = New-Object System.Collections.Generic.List[string]

    $lines.Add('# Rule Update Refresh Prompts')
    $lines.Add('')
    $lines.Add("Project: $projectName")
    $lines.Add("Generated: $generatedAt")
    $lines.Add('')
    $lines.Add('Send the relevant prompt to already-open Codex windows after applying local rule files.')
    $lines.Add('')

    foreach ($rule in $AppliedRules) {
        $lines.Add("## $($rule.Id) - $($rule.Title)")
        $lines.Add('')
        $lines.Add('```text')
        foreach ($promptLine in $rule.RefreshPrompt) {
            $lines.Add($promptLine)
        }
        $lines.Add('```')
        $lines.Add('')
    }

    if ($DryRun) {
        return 'WouldWriteRefreshPrompts'
    }

    $parent = Split-Path -Parent $promptPath
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    Backup-ProjectFile -ProjectPath $ProjectPath -FilePath $promptPath -BackupRoot $BackupRoot
    Set-Content -LiteralPath $promptPath -Value $lines.ToArray() -Encoding UTF8
    return 'RefreshPromptsWritten'
}

$projectPaths = New-Object System.Collections.Generic.List[string]

foreach ($rawPath in (ConvertTo-ValueArray $ProjectRoot)) {
    foreach ($path in ($rawPath -split ',')) {
        Add-ProjectPath -List $projectPaths -Path $path
    }
}

if (-not [string]::IsNullOrWhiteSpace($ProjectsFile)) {
    $projectsFilePath = [System.IO.Path]::GetFullPath($ProjectsFile)
    if (-not (Test-Path -LiteralPath $projectsFilePath -PathType Leaf)) {
        throw "Projects file does not exist: $projectsFilePath"
    }

    $projectConfig = Get-Content -LiteralPath $projectsFilePath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($project in (ConvertTo-ValueArray $projectConfig.projects)) {
        if ($project.enabled -eq $false) {
            continue
        }

        Add-ProjectPath -List $projectPaths -Path $project.path
    }
}

if ($projectPaths.Count -eq 0) {
    throw 'No target projects provided. Use -ProjectRoot <path> or -ProjectsFile <json-file>.'
}

$ruleIds = New-Object System.Collections.Generic.List[string]
foreach ($rawRuleId in (ConvertTo-ValueArray $RuleId)) {
    foreach ($id in ($rawRuleId -split ',')) {
        Add-RuleId -List $ruleIds -Value $id
    }
}

if ($ruleIds.Count -eq 0) {
    throw 'No rule ids provided.'
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$manifestIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($update in (ConvertTo-ValueArray $manifest.updates)) {
    [void]$manifestIds.Add($update.id)
}

$errors = New-Object System.Collections.Generic.List[string]

foreach ($projectPath in $projectPaths) {
    try {
        if (-not (Test-Path -LiteralPath $projectPath -PathType Container)) {
            throw "Project directory does not exist: $projectPath"
        }

        $projectPath = [System.IO.Path]::GetFullPath($projectPath)
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        $backupRoot = Join-Path $projectPath ".rule-update-backups\$timestamp"
        $appliedRules = New-Object System.Collections.Generic.List[object]

        Write-Output "Project: $projectPath"

        foreach ($id in $ruleIds) {
            if (-not $manifestIds.Contains($id)) {
                throw "Rule id not found in manifest: $id"
            }

            $rule = Get-RuleDefinition -Id $id
            $startMarker = "<!-- RULE-UPDATE:${id}:START -->"
            $secondaryPath = if ($rule.PSObject.Properties.Name -contains 'SecondaryPath') { $rule.SecondaryPath } else { $rule.PreflightPath }
            $secondaryBlock = if ($rule.PSObject.Properties.Name -contains 'SecondaryBlock') { $rule.SecondaryBlock } else { $rule.PreflightBlock }
            $secondaryLabel = if ($rule.PSObject.Properties.Name -contains 'SecondaryLabel') { $rule.SecondaryLabel } else { 'window-preflight-check.md' }
            $agentResult = Add-BlockIfMissing -ProjectPath $projectPath -RelativePath $rule.AgentPath -Block $rule.AgentBlock -StartMarker $startMarker -BackupRoot $backupRoot
            $secondaryResult = Add-BlockIfMissing -ProjectPath $projectPath -RelativePath $secondaryPath -Block $secondaryBlock -StartMarker $startMarker -BackupRoot $backupRoot
            $inboxResult = Set-InboxRuleStatus -ProjectPath $projectPath -RuleId $id -BackupRoot $backupRoot

            if ($agentResult -ne 'AlreadyPresent' -or $secondaryResult -ne 'AlreadyPresent' -or $inboxResult -notin @('InboxAlreadyApplied', 'MissingInbox')) {
                $appliedRules.Add($rule)
            }

            Write-Output "  Rule: $id"
            Write-Output "    AGENTS.md: $agentResult"
            Write-Output "    ${secondaryLabel}: $secondaryResult"
            Write-Output "    inbox: $inboxResult"
        }

        $promptResult = Set-RefreshPromptFile -ProjectPath $projectPath -AppliedRules $appliedRules.ToArray() -BackupRoot $backupRoot
        Write-Output "    refresh prompts: $promptResult"

        if (-not $NoBackup -and -not $DryRun -and (Test-Path -LiteralPath $backupRoot -PathType Container)) {
            Write-Output "    backup: $backupRoot"
        }
    } catch {
        $errors.Add("$projectPath :: $($_.Exception.Message)")
    }
}

Write-Output 'Rule update apply complete.'
Write-Output "Projects checked: $($projectPaths.Count)"
Write-Output "Rules requested: $($ruleIds -join ', ')"

if ($errors.Count -gt 0) {
    Write-Output 'Errors:'
    foreach ($errorItem in $errors) {
        Write-Output "  $errorItem"
    }
    exit 1
}
