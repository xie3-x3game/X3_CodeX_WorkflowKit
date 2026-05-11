# Commands Reference

Use these commands from the project root.

## Validate Project Rules

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate-window-consistency.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate-dispatch-queue.ps1
```

## Dispatch Preflight

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\check-dispatch-window.ps1 -WindowName 软件开发
```

List ready tasks:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\get-next-dispatch-task.ps1 -WindowName 软件开发 -List
```

## Portable Kit

Clean test export:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\export-portable-kit.ps1 -Destination .tmp\portable-kit-test -Profile Minimal -Clean
```

Safe merge into an existing project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\export-portable-kit.ps1 -Destination "<existing-project>" -Profile Minimal -BackupExisting
```

## Bootstrap and Update

Install the workflow kit from GitHub on a new computer:

```powershell
$url = 'https://raw.githubusercontent.com/xie3-x3game/X3_CodeX_WorkflowKit/main/scripts/bootstrap-codex-workflow.ps1'
Invoke-WebRequest -Uri $url -OutFile .\bootstrap-codex-workflow.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-codex-workflow.ps1 -InstallRoot "$HOME\X3_CodeX_Workflow" -InstallMode PortableKit
```

Update an installed workflow kit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\update-codex-workflow.ps1"
```

## Rule Update Sync

Append WorkflowKit rule updates to one project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-rule-updates.ps1 -ProjectRoot "<project-dir>"
```

Append updates to multiple projects:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-rule-updates.ps1 -ProjectRoot "<project-a>","<project-b>"
```

Use a JSON project list:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\sync-rule-updates.ps1 -ProjectsFile "<projects.json>"
```

Apply an accepted rule update:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\apply-rule-updates.ps1 -ProjectRoot "<project-dir>" -RuleId RU-20260511-001
```

Dry-run before applying:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\apply-rule-updates.ps1 -ProjectRoot "<project-dir>" -RuleId RU-20260511-001 -DryRun
```

## New Project Scaffold

Clean new project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\new-project-scaffold.ps1 -Destination "<target>" -ProjectName "<name>" -ProjectType Software -ControlMode Standard -Clean
```

Existing project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\new-project-scaffold.ps1 -Destination "<target>" -ProjectName "<name>" -ProjectType Knowledge -ControlMode Standard -BackupExisting
```

Project types:

```text
Software / Writing / Learning / Knowledge / Complex / Mixed
```

Control modes:

```text
Light / Standard / Expanded / ResearchHub
```

## Window Commands

```text
启动：软件开发
检查Dispatch：软件开发
查看队列：软件开发
接Dispatch：软件开发
继续当前窗口任务
执行任务：T-YYYYMMDD-001
```

## Legacy Window Onboarding

Use `docs/templates/legacy-window-onboarding-prompt.md` in the legacy window. After the user pastes the legacy window summary back to total-control:

1. Confirm boundary classification.
2. Create dispatch tasks only for real handoffs.
3. Update the source window task file when needed.
4. Create missing local topic files when needed.
5. Run validation.
