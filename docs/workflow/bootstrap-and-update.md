# Bootstrap and Update

This file defines the install and update path for the reusable CodeX window workflow.

## Positioning

There are two different things:

- `X3_CodeX`: the research source of truth. It keeps experiments, conclusions, topic notes, scripts, skills, and templates.
- Workflow kit: the minimal installable package copied into other projects or other computers.

Use the full repository when you are researching the method. Use the workflow kit when you only need to run the method in another project.

## Recommended Distribution

Use `X3_CodeX_WorkflowKit` as the upstream distribution repository. `X3_CodeX` publishes to it; normal users and other computers install from it.

The practical model is:

1. GitHub hosts `X3_CodeX_WorkflowKit` as the distribution package.
2. A new computer downloads `scripts/bootstrap-codex-workflow.ps1`.
3. The bootstrap script creates or updates a local tool root, defaulting to `$HOME\X3_CodeX_Workflow`.
4. The script exports the Minimal portable kit into that tool root.
5. The script installs `codex-window-workflow` into the local Codex skills directory.
6. A concrete project uses the installed skill or runs `scripts/new-project-scaffold.ps1`.

This keeps project files separate from method-tool files.

## New Computer Install

Download the bootstrap script first:

```powershell
$url = 'https://raw.githubusercontent.com/xie3-x3game/X3_CodeX_WorkflowKit/main/scripts/bootstrap-codex-workflow.ps1'
Invoke-WebRequest -Uri $url -OutFile .\bootstrap-codex-workflow.ps1
```

Install the minimal workflow kit and skill:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\bootstrap-codex-workflow.ps1 -InstallRoot "$HOME\X3_CodeX_Workflow" -InstallMode PortableKit
```

If Git is available, the script uses Git. If Git is not available and the repository is on GitHub, it falls back to a branch zip download.

## Update Existing Install

From an installed workflow kit:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\update-codex-workflow.ps1"
```

The update command refreshes the source, re-exports the Minimal portable kit, reinstalls the skill, and runs validation.

Use `-InstallMode FullRepo` only when the install root is meant to be a full research checkout:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\update-codex-workflow.ps1" -InstallRoot "<full-research-repo-dir>" -InstallMode FullRepo
```

## Apply to a Project

After the workflow kit is installed, use one of these paths.

For a new project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\new-project-scaffold.ps1" -Destination "<project-dir>" -ProjectName "<project-name>" -ProjectType Mixed -ControlMode Standard -Clean
```

For an existing or messy project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\new-project-scaffold.ps1" -Destination "<project-dir>" -ProjectName "<project-name>" -ProjectType Mixed -ControlMode Standard -BackupExisting
```

For only copying workflow rules into a project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\export-portable-kit.ps1" -Destination "<project-dir>" -Profile Minimal -BackupExisting
```

For sending only new WorkflowKit rule updates to a project total-control inbox:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "$HOME\X3_CodeX_Workflow\scripts\sync-rule-updates.ps1" -ProjectRoot "<project-dir>"
```

This appends missing updates to `docs/workflow/rule-update-inbox.md`. It does not overwrite project rules.

## In Codex

After installing the skill, open a new Codex window and use:

```text
Use $codex-window-workflow to scaffold a Mixed project in <project-dir>.
```

For an already connected project:

```text
Use $codex-window-workflow to check dispatch for 总控.
```

## Release Source

`X3_CodeX_WorkflowKit` is generated from the research repository by `scripts/publish-workflow-kit.ps1`.

The release repository should contain only portable workflow files. It should not contain research notes, dispatch history, private paths, external project bridge records, or temporary files.

Publish from the research repository:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\publish-workflow-kit.ps1 -Destination "<workflow-kit-dir>"
```
