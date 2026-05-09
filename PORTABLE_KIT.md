# CodeX Portable Kit

Profile: Minimal
Source: X3_CodeX_WorkflowKit public distribution package

## Next Steps

1. Install or update this kit with `scripts/bootstrap-codex-workflow.ps1` or `scripts/update-codex-workflow.ps1`.
2. Use `scripts/new-project-scaffold.ps1` for a new or existing project.
3. Run validation in the target project:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate-window-consistency.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\validate-dispatch-queue.ps1
```

4. In Codex, use `Use $codex-window-workflow ...` commands after installing the skill.
