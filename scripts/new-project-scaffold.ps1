[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Destination,

    [Parameter(Mandatory = $true)]
    [string]$ProjectName,

    [ValidateSet('Software', 'Writing', 'Learning', 'Knowledge', 'Complex', 'Mixed')]
    [string]$ProjectType = 'Software',

    [ValidateSet('Light', 'Standard', 'Expanded', 'ResearchHub')]
    [string]$ControlMode = 'Standard',

    [string]$Root,

    [switch]$Clean,

    [switch]$NoClobber,

    [switch]$BackupExisting,

    [switch]$SkipPortableKit
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

if ($NoClobber -and $BackupExisting) {
    throw 'Use either -NoClobber or -BackupExisting, not both.'
}

if ($SkipPortableKit -and $Clean) {
    throw 'Use -Clean only when portable kit export is enabled.'
}

$WrittenItems = New-Object System.Collections.Generic.List[string]
$SkippedItems = New-Object System.Collections.Generic.List[string]
$BackedUpItems = New-Object System.Collections.Generic.List[string]
$CreatedDirectories = New-Object System.Collections.Generic.List[string]
$BackupRoot = $null

if ($BackupExisting) {
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $BackupRoot = Join-Path $Destination ".portable-kit-backups\$timestamp-scaffold"
}

function ConvertTo-DisplayPath {
    param([Parameter(Mandatory = $true)][string]$Path)

    return $Path.Replace('\', '/')
}

function New-ScaffoldDirectory {
    param([Parameter(Mandatory = $true)][string]$RelativePath)

    $target = Join-Path $Destination $RelativePath

    if (-not (Test-Path -LiteralPath $target -PathType Container)) {
        New-Item -ItemType Directory -Force -Path $target | Out-Null
        $script:CreatedDirectories.Add((ConvertTo-DisplayPath $RelativePath))
        return
    }

    New-Item -ItemType Directory -Force -Path $target | Out-Null
}

function Set-ScaffoldFile {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string[]]$Value
    )

    $target = Join-Path $Destination $RelativePath
    $targetParent = Split-Path -Parent $target
    New-Item -ItemType Directory -Force -Path $targetParent | Out-Null

    if (Test-Path -LiteralPath $target -PathType Leaf) {
        if ($NoClobber) {
            $script:SkippedItems.Add((ConvertTo-DisplayPath $RelativePath))
            return
        }

        if ($BackupExisting) {
            $backupTarget = Join-Path $BackupRoot $RelativePath
            $backupParent = Split-Path -Parent $backupTarget
            New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
            Copy-Item -LiteralPath $target -Destination $backupTarget -Force
            $script:BackedUpItems.Add((ConvertTo-DisplayPath $RelativePath))
        }
    }

    Set-Content -LiteralPath $target -Value $Value -Encoding UTF8
    $script:WrittenItems.Add((ConvertTo-DisplayPath $RelativePath))
}

function Add-TemplateFile {
    param(
        [Parameter(Mandatory = $true)][string]$RelativePath,
        [Parameter(Mandatory = $true)][string]$Title,
        [Parameter(Mandatory = $true)][string[]]$Sections
    )

    $content = New-Object System.Collections.Generic.List[string]
    $content.Add("# $Title")
    $content.Add('')

    foreach ($section in $Sections) {
        $content.Add("## $section")
        $content.Add('')
        $content.Add('- TODO')
        $content.Add('')
    }

    Set-ScaffoldFile -RelativePath $RelativePath -Value $content.ToArray()
}

function Add-SoftwareScaffold {
    $dirs = @('src', 'tests', 'docs/specs', 'docs/product', 'docs/releases')
    foreach ($dir in $dirs) {
        New-ScaffoldDirectory -RelativePath $dir
    }

    Add-TemplateFile -RelativePath 'src/README.md' -Title 'Source Code' -Sections @('Scope', 'Entry Points', 'Notes')
    Add-TemplateFile -RelativePath 'tests/README.md' -Title 'Tests' -Sections @('Test Strategy', 'Manual Checks', 'Automation')
    Add-TemplateFile -RelativePath 'docs/specs/README.md' -Title 'Specs' -Sections @('Requirements', 'Constraints', 'Acceptance Criteria')
    Add-TemplateFile -RelativePath 'docs/product/README.md' -Title 'Product Notes' -Sections @('Users', 'Workflows', 'Open Questions')
    Add-TemplateFile -RelativePath 'docs/releases/README.md' -Title 'Release Notes' -Sections @('Changes', 'Verification', 'Risks')
}

function Add-WritingScaffold {
    $dirs = @('docs/story', 'docs/story/characters', 'docs/story/scenes', 'docs/research')
    foreach ($dir in $dirs) {
        New-ScaffoldDirectory -RelativePath $dir
    }

    Add-TemplateFile -RelativePath 'docs/story/premise.md' -Title 'Premise' -Sections @('Core Idea', 'Theme', 'Conflict')
    Add-TemplateFile -RelativePath 'docs/story/characters.md' -Title 'Characters' -Sections @('Cast', 'Relationships', 'Arcs')
    Add-TemplateFile -RelativePath 'docs/story/outline.md' -Title 'Outline' -Sections @('Structure', 'Major Beats', 'Open Questions')
    Add-TemplateFile -RelativePath 'docs/story/scenes.md' -Title 'Scenes' -Sections @('Scene List', 'Drafts', 'Revision Notes')
    Add-TemplateFile -RelativePath 'docs/research/README.md' -Title 'Story Research' -Sections @('Sources', 'Notes', 'Usable Details')
}

function Add-LearningScaffold {
    New-ScaffoldDirectory -RelativePath 'docs/learning'

    Add-TemplateFile -RelativePath 'docs/learning/roadmap.md' -Title 'Learning Roadmap' -Sections @('Goal', 'Milestones', 'Daily Plan')
    Add-TemplateFile -RelativePath 'docs/learning/practice-log.md' -Title 'Practice Log' -Sections @('Date', 'Practice', 'Feedback')
    Add-TemplateFile -RelativePath 'docs/learning/review.md' -Title 'Review' -Sections @('Weekly Review', 'Weak Points', 'Next Adjustments')
}

function Add-KnowledgeScaffold {
    New-ScaffoldDirectory -RelativePath 'docs/knowledge'

    Add-TemplateFile -RelativePath 'docs/knowledge/index.md' -Title 'Knowledge Index' -Sections @('Topics', 'Tags', 'Reusable Notes')
    Add-TemplateFile -RelativePath 'docs/knowledge/sources.md' -Title 'Sources' -Sections @('Source List', 'Reliability', 'Follow Up')
    Add-TemplateFile -RelativePath 'docs/knowledge/glossary.md' -Title 'Glossary' -Sections @('Terms', 'Definitions', 'Related Topics')
}

function Add-ComplexScaffold {
    New-ScaffoldDirectory -RelativePath 'docs/operations'

    Add-TemplateFile -RelativePath 'docs/operations/milestones.md' -Title 'Milestones' -Sections @('Current Stage', 'Milestones', 'Risks')
    Add-TemplateFile -RelativePath 'docs/operations/decisions.md' -Title 'Decisions' -Sections @('Decision', 'Context', 'Result')
    Add-TemplateFile -RelativePath 'docs/operations/retrospectives.md' -Title 'Retrospectives' -Sections @('What Happened', 'What Worked', 'Changes')
}

function Get-EnabledWindows {
    param([Parameter(Mandatory = $true)][string]$Type)

    $base = @('total-control')

    switch ($Type) {
        'Software' { return $base + @('software-development', 'prompt-description', 'tools-plugins') }
        'Writing' { return $base + @('writing-screenplay', 'knowledge-management', 'prompt-description') }
        'Learning' { return $base + @('self-learning', 'knowledge-management', 'long-running-tasks') }
        'Knowledge' { return $base + @('knowledge-management', 'prompt-description', 'tools-plugins') }
        'Complex' { return $base + @('ability-boundary', 'strategy-planning', 'multi-agent', 'long-running-tasks') }
        'Mixed' {
            return @(
                'total-control',
                'ability-boundary',
                'strategy-planning',
                'prompt-description',
                'long-running-tasks',
                'multi-agent',
                'software-development',
                'tools-plugins',
                'writing-screenplay',
                'self-learning',
                'knowledge-management'
            )
        }
    }
}

function Get-ControlModeProfile {
    param([Parameter(Mandatory = $true)][string]$Mode)

    switch ($Mode) {
        'Light' {
            return [pscustomobject]@{
                Summary = 'Light project control for small or short-running projects.'
                May = @(
                    'Maintain project goal, current status, next actions, and compact experience notes.',
                    'Recommend one primary execution window when needed.',
                    'Create experience sync packets for reusable observations.'
                )
                MustNot = @(
                    'Maintain a large dispatch queue.',
                    'Create many long-term windows without clear recurring work.',
                    'Act as a method-research hub.'
                )
            }
        }
        'Standard' {
            return [pscustomobject]@{
                Summary = 'Standard project control for ordinary long-running projects.'
                May = @(
                    'Maintain project index, window plan, lightweight dispatch, and experience sync.',
                    'Route work between enabled project windows.',
                    'Create or update project-control docs and append-only decision notes.'
                )
                MustNot = @(
                    'Do deep specialized execution when a dedicated window exists.',
                    'Overwrite existing project files without explicit approval.',
                    'Sync full raw materials to X3_CodeX.'
                )
            }
        }
        'Expanded' {
            return [pscustomobject]@{
                Summary = 'Expanded project control for complex projects with multiple workstreams.'
                May = @(
                    'Coordinate several long-term windows and maintain dispatch discipline.',
                    'Perform light direct execution when it unblocks routing or validation.',
                    'Maintain milestone, decision, retrospective, and experience sync records.'
                )
                MustNot = @(
                    'Replace specialist windows for sustained implementation or content work.',
                    'Let project-control notes become a full raw-data archive.',
                    'Change high-impact project files without validation.'
                )
            }
        }
        'ResearchHub' {
            return [pscustomobject]@{
                Summary = 'Research hub control for projects that maintain reusable methods or tools.'
                May = @(
                    'Maintain reusable workflow rules, templates, scripts, and cross-project sync.',
                    'Create or revise window definitions and project scaffolding.',
                    'Classify incoming experience packets and dispatch method work.'
                )
                MustNot = @(
                    'Become the day-to-day execution window for all downstream projects.',
                    'Mix project-specific raw content into reusable method files.',
                    'Write back to external projects without an explicit sync decision.'
                )
            }
        }
    }
}

$windowLabels = @{
    'total-control' = 'Total Control'
    'ability-boundary' = 'Ability Boundary'
    'strategy-planning' = 'Strategy Planning'
    'prompt-description' = 'Prompt Description'
    'long-running-tasks' = 'Long Running Tasks'
    'multi-agent' = 'Multi Agent'
    'software-development' = 'Software Development'
    'tools-plugins' = 'Tools and Plugins'
    'writing-screenplay' = 'Writing and Screenplay'
    'self-learning' = 'Self Learning'
    'knowledge-management' = 'Knowledge Management'
}

if (-not $SkipPortableKit) {
    $exportScript = Join-Path $Root 'scripts/export-portable-kit.ps1'

    if (-not (Test-Path -LiteralPath $exportScript -PathType Leaf)) {
        throw "Missing portable kit export script: $exportScript"
    }

    $exportArgs = @{
        Destination = $Destination
        Profile = 'Minimal'
        Root = $Root
    }

    if ($Clean) { $exportArgs.Clean = $true }
    if ($NoClobber) { $exportArgs.NoClobber = $true }
    if ($BackupExisting) { $exportArgs.BackupExisting = $true }

    & $exportScript @exportArgs
}

New-Item -ItemType Directory -Force -Path $Destination | Out-Null

switch ($ProjectType) {
    'Software' { Add-SoftwareScaffold }
    'Writing' { Add-WritingScaffold }
    'Learning' { Add-LearningScaffold }
    'Knowledge' { Add-KnowledgeScaffold }
    'Complex' { Add-ComplexScaffold }
    'Mixed' {
        Add-SoftwareScaffold
        Add-WritingScaffold
        Add-LearningScaffold
        Add-KnowledgeScaffold
        Add-ComplexScaffold
    }
}

$enabledWindows = @(Get-EnabledWindows -Type $ProjectType)
$controlProfile = Get-ControlModeProfile -Mode $ControlMode
$generatedAt = Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz'

$index = New-Object System.Collections.Generic.List[string]
$index.Add('# Project Index')
$index.Add('')
$index.Add("Project: $ProjectName")
$index.Add("Type: $ProjectType")
$index.Add("Control Mode: $ControlMode")
$index.Add("Generated: $generatedAt")
$index.Add('')
$index.Add('## Purpose')
$index.Add('')
$index.Add('- TODO: describe the project goal, expected outcome, and time horizon.')
$index.Add('')
$index.Add('## Enabled Windows')
$index.Add('')
$index.Add('| Window | Task File | Guide File |')
$index.Add('| --- | --- | --- |')

foreach ($windowId in $enabledWindows) {
    $label = $windowLabels[$windowId]
    $index.Add('| ' + $label + ' | docs/tasks/' + $windowId + '.md | docs/windows/' + $windowId + '.md |')
}

$index.Add('')
$index.Add('## Startup')
$index.Add('')
$index.Add('1. Review `docs/window-registry.md` and this file.')
$index.Add('2. Review `docs/project-control-charter.md` before giving the project control window broad authority.')
$index.Add('3. Open the Codex windows listed above.')
$index.Add('4. Use startup commands from `docs/templates/short-window-commands.md`.')
$index.Add('5. Before new substantive work, run dispatch preflight for the active window.')
$index.Add('')
$index.Add('## Project Directories')
$index.Add('')

if ($CreatedDirectories.Count -eq 0) {
    $index.Add('- No new directories were needed.')
} else {
    foreach ($dir in ($CreatedDirectories | Sort-Object -Unique)) {
        $index.Add('- ' + $dir)
    }
}

$index.Add('')
$index.Add('## Next Tasks')
$index.Add('')
$index.Add('- Confirm enabled windows.')
$index.Add('- Fill the TODO sections in the generated templates.')
$index.Add('- Create dispatch tasks only when a request must cross window boundaries.')
$index.Add('')
$index.Add('## Notes')
$index.Add('')
$index.Add('- This scaffold does not move, delete, or rename existing project files.')
$index.Add('- Unused generic windows are kept unless removed manually after review.')
$index.Add('- Dispatch tasks in this project should reference local project files, not files from the source kit repository.')

Set-ScaffoldFile -RelativePath 'docs/project-index.md' -Value $index.ToArray()

$charter = New-Object System.Collections.Generic.List[string]
$charter.Add('# Project Control Charter')
$charter.Add('')
$charter.Add("Project: $ProjectName")
$charter.Add("Control Mode: $ControlMode")
$charter.Add("Generated: $generatedAt")
$charter.Add('')
$charter.Add('## Purpose')
$charter.Add('')
$charter.Add('- TODO: describe what the project-control window is responsible for in this project.')
$charter.Add('')
$charter.Add('## Control Mode Summary')
$charter.Add('')
$charter.Add("- $($controlProfile.Summary)")
$charter.Add('')
$charter.Add('## Project Control May')
$charter.Add('')
foreach ($item in $controlProfile.May) {
    $charter.Add("- $item")
}
$charter.Add('')
$charter.Add('## Project Control Must Not')
$charter.Add('')
foreach ($item in $controlProfile.MustNot) {
    $charter.Add("- $item")
}
$charter.Add('')
$charter.Add('## Escalation Rules')
$charter.Add('')
$charter.Add('- Strategy, options, prioritization, tradeoffs, or roadmaps: strategy-planning.')
$charter.Add('- Code implementation, tests, debugging, build, or release: software-development.')
$charter.Add('- Learning paths, practice, quiz, feedback, or review: self-learning.')
$charter.Add('- Knowledge indexing, summaries, source tracking, or tags: knowledge-management.')
$charter.Add('- Writing, story, character, dialogue, or draft work: writing-screenplay.')
$charter.Add('- Tooling, skills, plugins, automation, browser, or GitHub mechanisms: tools-plugins.')
$charter.Add('- Cross-project reusable method updates: X3_CodeX total-control.')
$charter.Add('')
$charter.Add('## Experience Sync Triggers')
$charter.Add('')
$charter.Add('- A repeated failure pattern appears.')
$charter.Add('- A workflow or prompt becomes reusable.')
$charter.Add('- A project-specific workaround should become a general method.')
$charter.Add('- A Codex capability boundary becomes clear.')
$charter.Add('')
$charter.Add('## Safety Rules')
$charter.Add('')
$charter.Add('- Do not copy full raw materials to X3_CodeX.')
$charter.Add('- Do not overwrite existing project files without explicit approval.')
$charter.Add('- Prefer append-only notes for project-control updates.')
$charter.Add('- Keep project-specific content in this project; send only method summaries to X3_CodeX.')
Set-ScaffoldFile -RelativePath 'docs/project-control-charter.md' -Value $charter.ToArray()

$windowPlan = New-Object System.Collections.Generic.List[string]
$windowPlan.Add('# Project Window Plan')
$windowPlan.Add('')
$windowPlan.Add("Project: $ProjectName")
$windowPlan.Add("Project Type: $ProjectType")
$windowPlan.Add("Control Mode: $ControlMode")
$windowPlan.Add('')
$windowPlan.Add('## Enabled Windows')
$windowPlan.Add('')
$windowPlan.Add('| Window | Task File | Guide File | Keep Long-Term | Notes |')
$windowPlan.Add('| --- | --- | --- | --- | --- |')
foreach ($windowId in $enabledWindows) {
    $label = $windowLabels[$windowId]
    $keep = if ($windowId -eq 'total-control') { 'Yes' } else { 'Review' }
    $windowPlan.Add('| ' + $label + ' | docs/tasks/' + $windowId + '.md | docs/windows/' + $windowId + '.md | ' + $keep + ' | TODO |')
}
$windowPlan.Add('')
$windowPlan.Add('## Candidate Temporary Windows')
$windowPlan.Add('')
$windowPlan.Add('- TODO: list temporary windows only when a focused experiment needs a separate conversation.')
$windowPlan.Add('')
$windowPlan.Add('## Review Rules')
$windowPlan.Add('')
$windowPlan.Add('- Remove or ignore windows with no recurring work.')
$windowPlan.Add('- Keep project control lightweight unless the project mode is Expanded or ResearchHub.')
$windowPlan.Add('- Record useful project lessons in `docs/project-experience-sync.md`.')
Set-ScaffoldFile -RelativePath 'docs/project-window-plan.md' -Value $windowPlan.ToArray()

$sync = New-Object System.Collections.Generic.List[string]
$sync.Add('# Project Experience Sync')
$sync.Add('')
$sync.Add("Project: $ProjectName")
$sync.Add("Control Mode: $ControlMode")
$sync.Add('')
$sync.Add('## Purpose')
$sync.Add('')
$sync.Add('Collect concise project lessons that may be useful to X3_CodeX. Do not paste raw project materials here.')
$sync.Add('')
$sync.Add('## Sync Packet Template')
$sync.Add('')
$sync.Add('```markdown')
$sync.Add('# YYYY-MM-DD Project Experience Sync: <title>')
$sync.Add('')
$sync.Add("Source Project: $ProjectName")
$sync.Add("Source Control Mode: $ControlMode")
$sync.Add('Source Path:')
$sync.Add('Target Project: X3_CodeX')
$sync.Add('Suggested Target Window:')
$sync.Add('Priority: P2')
$sync.Add('Status: Proposed')
$sync.Add('')
$sync.Add('## Project Scenario')
$sync.Add('')
$sync.Add('')
$sync.Add('## Problem Or Effective Practice')
$sync.Add('')
$sync.Add('')
$sync.Add('## Evidence')
$sync.Add('')
$sync.Add('- ')
$sync.Add('')
$sync.Add('## Reusable Hypothesis')
$sync.Add('')
$sync.Add('')
$sync.Add('## Do Not Sync')
$sync.Add('')
$sync.Add('- Full raw materials')
$sync.Add('- Private project details')
$sync.Add('- Long conversation transcripts')
$sync.Add('```')
Set-ScaffoldFile -RelativePath 'docs/project-experience-sync.md' -Value $sync.ToArray()

Write-Output 'New project scaffold complete.'
Write-Output "Project: $ProjectName"
Write-Output "Type: $ProjectType"
Write-Output "Control mode: $ControlMode"
Write-Output "Destination: $Destination"
Write-Output "Enabled windows: $($enabledWindows -join ', ')"
Write-Output "Scaffold files written: $($WrittenItems.Count)"

if ($CreatedDirectories.Count -gt 0) {
    Write-Output 'Created directories:'
    foreach ($dir in ($CreatedDirectories | Sort-Object -Unique)) {
        Write-Output "  $dir"
    }
}

if ($SkippedItems.Count -gt 0) {
    Write-Output "Skipped existing files: $($SkippedItems.Count)"
    foreach ($item in ($SkippedItems | Sort-Object -Unique)) {
        Write-Output "  $item"
    }
}

if ($BackedUpItems.Count -gt 0) {
    Write-Output "Backed up existing files: $($BackedUpItems.Count)"
    Write-Output "Backup root: $BackupRoot"
    foreach ($item in ($BackedUpItems | Sort-Object -Unique)) {
        Write-Output "  $item"
    }
}
