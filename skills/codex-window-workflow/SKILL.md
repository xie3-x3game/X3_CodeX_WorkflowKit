---
name: codex-window-workflow
description: "Use when Codex needs to operate a portable multi-window workflow for this project style: starting or loading named windows, running dispatch preflight, receiving dispatch tasks, creating or validating cross-window handoffs, onboarding legacy conversations, exporting the portable kit, bootstrapping or updating the workflow kit, scaffolding a new Codex project, or installing the reusable workflow skill. This applies to projects with AGENTS.md, docs/windows, docs/tasks, docs/dispatch, docs/workflow, and scripts/*.ps1."
---

# Codex Window Workflow

Use this skill to keep a Codex multi-window project inside its local rules instead of relying on conversation memory.

## First Checks

1. Treat the current working directory as the project root.
2. Read `AGENTS.md` first when present.
3. Read only the workflow file needed for the request:
   - Window startup: `docs/workflow/window-boot-protocol.md`.
   - Dispatch/preflight: `docs/dispatch/README.md` and `docs/workflow/window-preflight-check.md`.
   - Legacy conversation onboarding: `docs/workflow/legacy-conversation-onboarding.md`.
   - Portable deployment: `docs/workflow/portable-deployment.md`.
   - Bootstrap/update: `docs/workflow/bootstrap-and-update.md`.
   - New project scaffolding: `docs/workflow/new-project-bootstrap.md`.
4. If exact commands are needed, read `references/commands.md`.
5. If file roles or boundaries are unclear, read `references/file-map.md`.

## Decision Flow

- For a startup command such as `start/load <window>`: map the window name, read its task file and guide, then summarize boundary, current tasks, and handoff rules.
- For a new substantive request inside a loaded window: run or simulate dispatch preflight first. Present open Inbox/Outbox items before starting new work.
- For a dispatch check command: inspect `docs/dispatch/queue/*.md`; do not answer only from `docs/tasks`.
- For a dispatch receive command: choose the highest-priority Ready/Inbox task for that target window, confirm it is inside the window boundary, then execute.
- For a continue-current-window-task command: use `docs/tasks/<window>.md`, not the dispatch queue.
- For work outside the current window boundary: stop, identify the correct target window, and create or propose a dispatch task instead of continuing in the wrong window.
- For existing or messy projects: use backup-preserving deployment. Do not clean, move, delete, or rename existing project files unless the user explicitly asks.
- For installing or updating this workflow on another computer: use the bootstrap/update scripts first, then install or refresh the skill.
- For new projects: use the scaffold script and then validate window consistency and dispatch queue format.

## Required Validation

After changing workflow files, dispatch files, window/task files, portable kit scripts, scaffold scripts, or skill files, run the relevant checks:

- `scripts/validate-window-consistency.ps1`
- `scripts/validate-dispatch-queue.ps1`
- `scripts/check-dispatch-window.ps1 -WindowName <window>`
- Skill validation with the skill-creator quick validator when editing this skill.

Report validation results briefly. If validation cannot run, say why and what remains unverified.

## Safety Rules

- Do not assume Codex can read the left-side window title reliably. Prefer explicit window names from the user or command text.
- Do not create empty dispatch tasks. Create dispatch only when a real cross-window task exists.
- Do not reference source-repository-only files from a generated target project dispatch task. Generated projects should usually write results back to their own `docs/project-index.md`.
- Use `-Clean` only for empty or temporary test directories.
- Use `-BackupExisting` for real existing projects or messy directories.
