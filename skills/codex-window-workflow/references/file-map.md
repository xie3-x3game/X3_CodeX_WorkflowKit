# File Map

## Core Files

- `AGENTS.md`: root operating rules and short-command behavior.
- `docs/window-registry.md`: official window registry.
- `docs/windows/*.md`: long-term window guides.
- `docs/tasks/*.md`: current task arrangement for each window.
- `docs/dispatch/README.md`: dispatch protocol.
- `docs/dispatch/queue/*.md`: concrete cross-window task instances.
- `docs/workflow/window-boot-protocol.md`: startup mapping and required startup output.
- `docs/workflow/window-preflight-check.md`: Inbox/Outbox preflight rules.
- `docs/workflow/portable-deployment.md`: portable kit deployment.
- `docs/workflow/bootstrap-and-update.md`: install and update flow for other computers.
- `docs/workflow/experience-evaluation.md`: scoring formula for external project experience.
- `docs/workflow/rule-update-sync.md`: rule update inbox and project distribution workflow.
- `docs/workflow/rule-update-inbox.md`: per-project inbox for received WorkflowKit rule updates.
- `docs/workflow/rule-update-manifest.json`: WorkflowKit rule update feed.
- `docs/workflow/new-project-bootstrap.md`: project scaffold guidance.
- `docs/workflow/project-control-onboarding.md`: project-control permission and onboarding workflow.
- `docs/workflow/legacy-conversation-onboarding.md`: legacy conversation intake.
- `docs/workflow/cross-project-sync.md`: lightweight sync between this workflow project and external real-use projects.
- `docs/external-projects/*.md`: bridge records for external projects.
- `docs/project-index.md`: generated target-project control index.
- `docs/project-control-charter.md`: generated project-control authority boundary.
- `docs/project-window-plan.md`: generated plan for which windows to create or keep.
- `docs/project-experience-sync.md`: generated project lessons to send back to X3_CodeX.

## Script Roles

- `scripts/validate-window-consistency.ps1`: verify task and guide file pairing.
- `scripts/validate-dispatch-queue.ps1`: verify dispatch task format and references.
- `scripts/check-dispatch-window.ps1`: summarize Inbox and Outbox for a window.
- `scripts/get-next-dispatch-task.ps1`: list or select target-window dispatch tasks.
- `scripts/export-portable-kit.ps1`: copy the reusable minimal kit.
- `scripts/bootstrap-codex-workflow.ps1`: install or refresh the workflow kit from GitHub or a local source.
- `scripts/update-codex-workflow.ps1`: wrapper for updating an installed workflow kit.
- `scripts/new-project-scaffold.ps1`: generate a typed new project scaffold.
- `scripts/sync-rule-updates.ps1`: append WorkflowKit rule updates to target project inboxes.
- `scripts/install-codex-window-skill.ps1`: install this skill into the local Codex skills directory when available.

## Window Name Map

```text
总控 -> total-control
能力边界 -> ability-boundary
提示描述 -> prompt-description
策略拟定 -> strategy-planning
长期任务 -> long-running-tasks
多项代理 -> multi-agent
软件开发 -> software-development
工具插件 -> tools-plugins
写作剧本 -> writing-screenplay
自我学习 -> self-learning
资料整理 -> knowledge-management
```

## Dispatch Status

```text
Inbox / Ready / Active / Blocked / Done / Dropped / Archived
```

Only `Inbox` and `Ready` should be selected for receiving work. Outbox is any task where the current window is `Source Window` and status is not `Done`, `Dropped`, or `Archived`.
