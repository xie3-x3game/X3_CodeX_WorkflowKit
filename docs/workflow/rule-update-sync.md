# Rule Update Sync

This workflow sends reusable rule updates from `X3_CodeX_WorkflowKit` to project total-control windows without directly changing project behavior.

## Goal

Rule updates should reach active projects automatically enough that the user does not need to paste the same instruction into every window.

They should not silently rewrite every project. Each project has its own context, risk level, active windows, and unfinished work. The project total-control window decides whether to apply, defer, reject, or locally adapt a rule.

## Flow

```text
X3_CodeX validates a reusable rule
-> WorkflowKit publishes rule-update-manifest.json
-> sync-rule-updates.ps1 appends updates to each project inbox
-> project total-control reviews docs/workflow/rule-update-inbox.md
-> apply-rule-updates.ps1 applies accepted rule changes
-> project total-control distributes refresh prompts to already-open windows
-> project windows follow the local decision
```

## Files

- `docs/workflow/rule-update-manifest.json`: the WorkflowKit rule update feed.
- `docs/workflow/rule-update-inbox.md`: per-project inbox for pending rule updates.
- `scripts/sync-rule-updates.ps1`: deterministic sync script that appends missing updates to project inboxes.
- `scripts/apply-rule-updates.ps1`: deterministic apply script for accepted rule IDs.
- `docs/workflow/rule-update-refresh-prompts.md`: generated local prompts for already-open project windows.

## Update States

- `Pending`: received but not reviewed by project total-control.
- `Applied`: accepted and distributed locally.
- `Deferred`: valid, but not useful for the project right now.
- `Rejected`: not suitable for this project.
- `Superseded`: replaced by a newer update.

## Project Total-Control Duties

When a project receives updates:

1. Read `docs/workflow/rule-update-inbox.md`.
2. Compare the update against the project's `docs/project-control-charter.md`.
3. Decide whether the update affects all windows, only the total-control window, or no current window.
4. Prefer append-only local notes over rewriting existing files.
5. Do not apply a rule if it conflicts with project-specific safety, privacy, or delivery needs.
6. Mark each update as `Applied`, `Deferred`, `Rejected`, or `Superseded`.
7. After applying a rule, send the generated refresh prompt to already-open Codex windows that need the new behavior.

## Sync Versus Apply

`sync-rule-updates.ps1` is low risk. It only appends updates to `docs/workflow/rule-update-inbox.md`.

`apply-rule-updates.ps1` is medium risk. It changes project rule files for explicit rule IDs only. It should be run by project total-control after deciding the rule is suitable for that project.

Current supported apply rule:

```text
RU-20260511-001
```

## Current Stable Rules

### Silent Routine Preflight Output

Routine boundary and dispatch checks should still happen, but should not be narrated every time.

Default behavior:

- Perform lightweight boundary and dispatch preflight silently.
- Reply naturally when there is no issue.
- Explicitly mention preflight only when there are open tasks, handoff decisions, boundary conflicts, file edits, Git/publish actions, privacy risks, or user confusion.

This keeps the workflow safe without making every response feel like a fixed template.

### Mobile-Safe Window Names

When the client UI only shows conversation names, project windows should use a stable prefix:

```text
<Project>｜总控
<Project>｜资料整理
<Project>｜策略拟定
<Project>｜专项｜<role>｜<topic>
<Project>｜临时｜<purpose>
```

This naming rule is practical, not permanent. It can be relaxed if the client later displays project grouping clearly.

## Safety Rules

- The sync script only creates or appends `docs/workflow/rule-update-inbox.md` in target projects.
- The apply script only applies explicit supported rule IDs.
- The apply script appends marked blocks to rule files instead of rewriting whole files.
- The apply script writes backups under `.rule-update-backups/<timestamp>/` unless `-NoBackup` is used.
- Both scripts are safe to run repeatedly; existing `Update ID:` or rule marker entries are not duplicated.
- Local project paths must not be committed to the public WorkflowKit repository.
