# writing-screenplay task plan

## Read Order

- [Window guide](../windows/writing-screenplay.md)
- [Window registry](../window-registry.md)
- [Dispatch protocol](../dispatch/README.md)
- [Window preflight](../workflow/window-preflight-check.md)

## Boundary

Use the matching window guide as the source of truth. If a request is outside this boundary, create or suggest a dispatch handoff instead of continuing in the wrong window.

## Current Tasks

| Status | Task | Output |
| --- | --- | --- |
| Ready | Boot this window | Read the guide, check dispatch, and summarize boundary plus next actions |
| Ready | Receive assigned dispatch work | Use `check-dispatch-window.ps1` and `get-next-dispatch-task.ps1` before starting new work |

## Open Handoffs

None by default. Use `docs/dispatch/queue/` for concrete cross-window tasks.

## Completion Rule

When work produces reusable project knowledge, update the appropriate local project docs before marking the task done.
