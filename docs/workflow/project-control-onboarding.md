# 项目总控接入流程

本流程用于每次新建项目或接手改造已有项目时，建立该项目自己的轻量总控和分类对话。

## 核心判断

其他项目通常需要 `项目总控`，但不需要完整复制 `X3_CodeX` 的研究型总控。

`X3_CodeX` 是方法论中枢，负责沉淀通用规则、模板、skill 和 portable kit。

其他项目是实践场，负责具体目标、项目进度、项目资料和本项目经验回收。

## 项目总控权限档位

| 档位 | 适用项目 | 项目总控可以做 | 项目总控不做 |
| --- | --- | --- | --- |
| `Light` | 小项目、短期任务、单窗口项目 | 维护目标、进度、下一步、经验摘要 | 不维护 dispatch，不拆多个长期窗口 |
| `Standard` | 常规项目、已有 2-4 个专项对话 | 分流任务、维护项目索引、创建 dispatch、收集经验同步包 | 不长期承担具体执行 |
| `Expanded` | 长期复杂项目、跨资料/开发/学习/写作 | 可做轻量执行、协调多个窗口、维护复盘和决策记录 | 不替代专项窗口做深度执行 |
| `ResearchHub` | 类似 `X3_CodeX` 的方法论项目 | 维护窗口体系、模板、portable kit、跨项目同步 | 不作为普通业务项目执行场 |

默认选择：

- 新小项目：`Light`
- 普通真实项目：`Standard`
- 长期复杂项目：`Expanded`
- 方法论或工具体系项目：`ResearchHub`

## 新建项目流程

1. 说明项目目标、周期、主要产出和是否长期维护。
2. 选择 `ProjectType`：`Software`、`Writing`、`Learning`、`Knowledge`、`Complex`、`Mixed`。
3. 选择 `ControlMode`：`Light`、`Standard`、`Expanded`、`ResearchHub`。
4. 运行脚手架：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\new-project-scaffold.ps1 -Destination <目标目录> -ProjectName "<项目名>" -ProjectType Software -ControlMode Standard -Clean
```

5. 打开项目总控窗口，发送：

```text
启动：总控
```

6. 根据 `docs/project-window-plan.md` 创建必要专项窗口。
7. 每个专项窗口使用 `启动：<窗口名>`。
8. 项目运行一段时间后，由项目总控生成经验同步包。
9. 同步包必须按 [经验有效性评分](experience-evaluation.md) 给出初评，不确定时标记为 `Raw`。

## 接手旧项目流程

1. 先检查项目目录和 Git 状态。
2. 不使用 `-Clean`。
3. 使用安全合并：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\new-project-scaffold.ps1 -Destination <已有项目目录> -ProjectName "<项目名>" -ProjectType Mixed -ControlMode Standard -BackupExisting
```

4. 如果旧项目对话已经很混乱，使用 `docs/templates/legacy-window-onboarding-prompt.md`。
5. 先只做索引、边界和同步规则，不移动、不删除、不重命名项目文件。
6. 项目总控确认哪些窗口长期保留，哪些只作为临时窗口。

## 项目内对话建立规则

每个项目至少有：

- `项目总控`

按需要增加：

- `策略拟定`：路线、优先级、方案取舍。
- `软件开发`：代码实现、测试、调试。
- `资料整理`：资料索引、摘要、标签、知识库。
- `自我学习`：学习路径、练习、测验、复盘。
- `写作剧本`：创作、设定、文稿。
- `工具插件`：工具、skill、插件、自动化。
- `长期任务`：提醒、周期复盘、持续跟进。
- `多项代理`：多窗口拆分、并行协作。

项目窗口不必像 `X3_CodeX` 一样拆得很细。优先按真实工作量建立窗口。

当前推荐的移动端友好命名：

```text
<项目>｜总控
<项目>｜资料整理
<项目>｜策略拟定
<项目>｜专项｜<角色>｜<主题>
<项目>｜临时｜<目的>
```

这个命名规则服务于“手机端只能看到对话名”的现实问题。后续客户端如果能更清晰展示项目分组，可以再放宽。

## 经验回收闭环

```text
项目实践
-> 项目总控生成经验同步包
-> X3_CodeX 总控分类
-> X3_CodeX 专项窗口提炼方法
-> X3_CodeX 总控更新模板/规则
-> 同步回对应项目
```

## 规则更新回写闭环

当 `X3_CodeX` 把某条规则沉淀为 WorkflowKit 更新后，不直接批量修改项目窗口。

推荐流程：

```text
WorkflowKit rule-update-manifest.json
-> scripts/sync-rule-updates.ps1
-> 项目 docs/workflow/rule-update-inbox.md
-> 项目总控判断 Applied / Deferred / Rejected / Superseded
-> 必要时再分发给项目内窗口
```

项目总控应先判断该规则是否适合本项目，再决定是否更新 `AGENTS.md`、窗口指南或只口头提醒活跃窗口。

## 同步原则

- 同步经验摘要，不同步完整原始资料。
- 同步可复用模板，不同步一次性项目流水。
- 同步失败样本和证据，不只同步成功经验。
- 回写外部项目时，优先追加或新建文件。
- 外部项目有未提交修改时，不覆盖已有文件。
- 经验先评分再回传；只有 `Validated` 或 `Stable` 才能推动通用模板或 WorkflowKit 更新。

## 生成文件

脚手架会生成：

- `docs/project-index.md`
- `docs/project-control-charter.md`
- `docs/project-window-plan.md`
- `docs/project-experience-sync.md`

其中 `docs/project-control-charter.md` 是项目总控权限边界的唯一依据。
