# X3 CodeX WorkflowKit

Portable CodeX multi-window workflow kit for project onboarding, dispatch, scaffolding, and updates.

This repository is the installable distribution package. The research source of truth is `X3_CodeX`; this kit keeps only the files needed to run the workflow in other projects.

## Install On A New Computer

```powershell
$url = 'https://raw.githubusercontent.com/xie3-x3game/X3_CodeX_WorkflowKit/main/scripts/bootstrap-codex-workflow.ps1'
Invoke-WebRequest -Uri $url -OutFile .\bootstrap-codex-workflow.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-codex-workflow.ps1 -InstallRoot "$HOME\X3_CodeX_Workflow" -InstallMode PortableKit
```

## Update An Existing Install

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\update-codex-workflow.ps1"
```

## Scaffold A Project

New project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\new-project-scaffold.ps1" -Destination "<project-dir>" -ProjectName "<project-name>" -ProjectType Mixed -ControlMode Standard -Clean
```

Existing or messy project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\new-project-scaffold.ps1" -Destination "<project-dir>" -ProjectName "<project-name>" -ProjectType Mixed -ControlMode Standard -BackupExisting
```

## Use In Codex

After installing the skill, open a new Codex window and use:

```text
Use $codex-window-workflow to scaffold a Mixed project in <project-dir>.
```

For an already connected project:

```text
Use $codex-window-workflow to check dispatch for total-control.
```

## Contents

- `AGENTS.md`: root workflow rules.
- `docs/windows/` and `docs/tasks/`: window guides and task boundaries.
- `docs/dispatch/`: cross-window dispatch protocol.
- `docs/workflow/`: boot, onboarding, bootstrap, and deployment rules.
- `scripts/`: deterministic PowerShell commands.
- `skills/codex-window-workflow/`: reusable Codex skill.

No private project data, research history, or external project material should be committed to this repository.
