# 新项目启动脚手架规范

本文件定义如何从当前 CodeX 研究项目迁移经验，快速为新项目生成适合的目录结构和 Markdown 指南。

更具体的复制清单见 [可复制部署指南](portable-deployment.md)。已有旧对话接入见 [混乱对话接入流程](legacy-conversation-onboarding.md)。

## 总控窗口职责

当用户准备启动新项目时，总控窗口负责：

1. 判断项目类型。
2. 选择需要启用的专项窗口指南。
3. 生成项目目录结构。
4. 生成项目内 Markdown 工作手册。
5. 明确哪些窗口需要长期保留，哪些只作为临时实验窗口。

## 新项目最小目录

```text
docs/
  project-index.md
  window-registry.md
  windows/
    total-control.md
  tasks/
    README.md
    routing-rules.md
    total-control.md
  dispatch/
    README.md
    queue/
    archive/
  workflow/
    operating-rules.md
  templates/
    task-brief-template.md
```

当前推荐优先使用脚本生成，而不是手工创建：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\new-project-scaffold.ps1 -Destination <目标目录> -ProjectName "<项目名>" -ProjectType Software -ControlMode Standard -Clean
```

已有项目或混乱目录使用：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\new-project-scaffold.ps1 -Destination <目标目录> -ProjectName "<项目名>" -ProjectType Knowledge -ControlMode Standard -BackupExisting
```

脚本会复用 Minimal portable kit，并追加项目总控章程、窗口计划、经验同步文件，以及项目类型对应的目录与模板。默认不移动、删除、重命名已有业务文件。

`ControlMode` 用于定义项目总控权限：

- `Light`：小项目，只维护目标、状态和经验摘要。
- `Standard`：常规项目，维护项目索引、分流、轻量 dispatch 和经验同步。
- `Expanded`：长期复杂项目，可协调多个长期窗口并做轻量执行。
- `ResearchHub`：方法论或工具体系项目，类似 `X3_CodeX`。

详细流程见 [项目总控接入流程](project-control-onboarding.md)。

## 按项目类型增加的目录

软件项目建议增加：

```text
docs/
  windows/
    software-development.md
    prompt-description.md
    tools-plugins.md
  tasks/
    software-development.md
    prompt-description.md
    tools-plugins.md
  workflow/
    verification.md
    github-sync.md
```

写作项目建议增加：

```text
docs/
  windows/
    writing-screenplay.md
    knowledge-management.md
    prompt-description.md
  tasks/
    writing-screenplay.md
    knowledge-management.md
    prompt-description.md
  story/
    premise.md
    characters.md
    outline.md
    scenes.md
```

学习项目建议增加：

```text
docs/
  windows/
    self-learning.md
    knowledge-management.md
    long-running-tasks.md
  tasks/
    self-learning.md
    knowledge-management.md
    long-running-tasks.md
  learning/
    roadmap.md
    practice-log.md
    review.md
```

资料整理项目建议增加：

```text
docs/
  windows/
    knowledge-management.md
    prompt-description.md
    tools-plugins.md
  tasks/
    knowledge-management.md
    prompt-description.md
    tools-plugins.md
  knowledge/
    index.md
    sources.md
    glossary.md
```

复杂长期项目建议增加：

```text
docs/
  windows/
    ability-boundary.md
    strategy-planning.md
    multi-agent.md
    long-running-tasks.md
  tasks/
    ability-boundary.md
    strategy-planning.md
    multi-agent.md
    long-running-tasks.md
  operations/
    milestones.md
    decisions.md
    retrospectives.md
```

## 新项目启动流程

1. 用户在总控窗口说明项目目标、类型和预期周期。
2. 总控窗口选择 `ProjectType` 和 `ControlMode`。
3. 总控窗口选择窗口组合。
4. 总控窗口生成目录、窗口指南、任务安排文件和项目总控章程。
5. 总控窗口生成 `docs/dispatch`，用于跨窗口任务转交和接单。
6. 用户根据 `docs/project-window-plan.md` 手动创建需要的专项窗口。
7. 每个专项窗口先读取对应 `docs/tasks/*.md`，再读取 `docs/windows/*.md`。
8. 阶段性结论回填到新项目的 `docs/project-index.md` 和 `docs/project-experience-sync.md`。

## Dispatch 使用规则

新项目中的 dispatch 任务应只引用新项目内存在的文件，例如：

- `docs/project-index.md`
- `docs/tasks/<window>.md`
- `docs/windows/<window>.md`

不要在新项目 dispatch 任务中引用源研究仓库的 `docs/workflow/module-runthrough.md`、主题记录或临时测试文件。总控工程需要记录迁移实验时，由总控窗口单独回填本仓库的模块跑通记录。

## 选择规则

- 任何项目都需要 `总控`。
- 需要产出代码时，启用 `软件开发`。
- 任务描述复杂或多人复用时，启用 `提示描述`。
- 需要制定路线、比较方案或明确优先级时，启用 `策略拟定`。
- 有大量外部资料时，启用 `资料整理`。
- 有持续学习目标时，启用 `自我学习`。
- 有创作内容时，启用 `写作剧本`。
- 需要周期提醒或持续跟进时，启用 `长期任务`。
- 需要多窗口拆分或并行代理时，启用 `多项代理`。
- 涉及插件、工具链、GitHub 或浏览器验证时，启用 `工具插件`。
