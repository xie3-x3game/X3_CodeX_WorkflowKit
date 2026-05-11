# X3_CodeX Workspace Rules

This workspace is used to research how to use CodeX effectively.

When the user sends a short window command such as:

```text
启动：软件开发
```

or:

```text
加载窗口：资料整理
```

follow this protocol:

1. Read `docs/workflow/window-boot-protocol.md`.
2. Match the provided window name to the mapping in that protocol.
3. Read the matching `docs/tasks/<window>.md`.
4. Read the matching `docs/windows/<window>.md`.
5. Read the matching `docs/topics/*.md` only when the task file requires background.
6. Summarize the loaded window boundary, current tasks, and handoff rules.
7. Only handle work inside the loaded window boundary.
8. If the requested work is outside the current window boundary, stop and recommend the correct window.

If the user asks to start, load, or activate a window but does not provide a window name, do not guess. Ask for one of:

```text
总控 / 能力边界 / 提示描述 / 策略拟定 / 长期任务 / 多项代理 / 软件开发 / 工具插件 / 写作剧本 / 自我学习 / 资料整理
```

If the user asks for total-control, routing, project scaffolding, task dispatch, or cross-window coordination, treat it as `总控`.

If the user asks for strategy, options, prioritization, tradeoffs, roadmaps, or decision criteria, treat it as `策略拟定` unless the task is mainly about cross-window governance or project scaffolding.

When the user sends a dispatch command such as:

```text
检查窗口：软件开发
```

or:

```text
检查Dispatch：写作剧本
```

or:

```text
接单：软件开发
```

or:

```text
查看队列：资料整理
```

or:

```text
接Dispatch：写作剧本
```

follow this protocol:

1. Read `docs/dispatch/README.md`.
2. Read `docs/workflow/window-preflight-check.md`.
3. Match the provided window name to the window mapping in `docs/workflow/window-boot-protocol.md`.
4. Read the matching `docs/tasks/<window>.md` and `docs/windows/<window>.md`.
5. Inspect `docs/dispatch/queue/*.md`.
6. For `检查窗口：<window>` or `检查Dispatch：<window>`, summarize both Inbox tasks and Outbox tasks not closed from `docs/dispatch/queue/*.md`.
7. For `查看队列：<window>`, summarize matching Inbox tasks without executing them.
8. For `接单：<window>` or `接Dispatch：<window>`, take the highest-priority matching dispatch task, confirm it is inside the window boundary, then proceed according to that task file and the window's rules.
9. If no task matches, say there is no ready dispatch task for that window.

Important: `接单：<window>` means dispatch queue intake only. Do not treat `docs/tasks/<window>.md` current tasks as dispatch tasks. To continue ordinary window tasks from `docs/tasks`, the user should say:

```text
继续当前窗口任务
```

When the user sends:

```text
执行任务：T-YYYYMMDD-001
```

find the matching file under `docs/dispatch/queue`, read it, confirm the target window, then proceed only if the current window matches the task's `Target Window:` or the user explicitly asks total-control to inspect it.

When the user sends a new substantive request in a loaded window, first do a lightweight dispatch preflight for that window: check Inbox tasks and Outbox tasks not closed. If there are open tasks, briefly present them and ask whether to handle the queued task, continue the new request, or mark a task Dropped/Blocked. Do not force the queued task if the user wants the new request.

Routine output rule: do not narrate normal preflight or boundary checks when there is no issue. Reply naturally unless there are open Inbox/Outbox tasks, boundary conflicts, handoff decisions, file edits, Git/publish actions, privacy risks, or the user explicitly asks for a check.

Visible progress update rule: user-visible progress or status messages follow the same silence rule. Do not use progress updates to announce routine dispatch preflight, boundary checks, or rule loading when there is no issue. Progress updates should mention concrete work being done, blockers, edits, validation, Git/publish actions, or decisions that require the user's attention.

Simple-first rule: start plans, projects, roles, records, and automation with the smallest useful structure. Do not design a complete organization, taxonomy, workflow, or tool before real use requires it. Prefer a draft note, template, checklist, or manual process first; expand into rules, scripts, automations, or new windows only after review shows repeated need, higher risk, or clear value.

Important: `检查窗口：<window>` and `检查Dispatch：<window>` must inspect `docs/dispatch/queue/*.md`. They must not be answered only from `docs/tasks/<window>.md`.
