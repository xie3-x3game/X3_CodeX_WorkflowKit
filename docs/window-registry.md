# CodeX 窗口登记表

本文件用于管理左侧对话列表之外的正式窗口索引。左侧列表由用户手动操作；本文件负责记录每个窗口的用途、边界、状态和对应文档。

## 使用规则

- 新窗口建立后，优先发送 [短命令](templates/short-window-commands.md)，例如 `启动：软件开发`。如果没有正确加载，再使用 [统一窗口启动指令](templates/universal-window-start-prompt.md)。
- 新开窗口前，先在这里确认是否已经有对应专项窗口。
- 每个长期窗口只负责一个主要方向。
- 总控窗口只做分流、汇总和复盘，不深入承担专项任务。
- 专项窗口形成稳定结论后，回到总控窗口更新 [研究总索引](codex-research-index.md)。
- 临时实验窗口可以随开随关，但有价值结论必须回填到对应专项文件。

## 窗口类型

- `总控`：维护认知地图、主题边界、阶段复盘。
- `专项`：长期研究一个方向。
- `临时`：验证一个具体问题，完成后归档结论。

## 长期窗口清单

| 左侧窗口 | 类型 | 状态 | 任务安排 | 工作指南 | 研究记录 | 边界 |
| --- | --- | --- | --- | --- | --- | --- |
| 总控 | 总控 | 已建立 | [total-control.md](tasks/total-control.md) | [total-control.md](windows/total-control.md) | [codex-research-index.md](codex-research-index.md) | 只做分流、汇总、复盘和规则维护 |
| 能力边界 | 专项 | 已建立 | [ability-boundary.md](tasks/ability-boundary.md) | [ability-boundary.md](windows/ability-boundary.md) | [01-codex-basics.md](topics/01-codex-basics.md) | 研究 CodeX 能力边界和人工介入条件 |
| 提示描述 | 专项 | 已建立 | [prompt-description.md](tasks/prompt-description.md) | [prompt-description.md](windows/prompt-description.md) | [02-prompting-and-context.md](topics/02-prompting-and-context.md) | 研究任务描述、上下文组织、约束和验收标准 |
| 策略拟定 | 专项 | 已建立 | [strategy-planning.md](tasks/strategy-planning.md) | [strategy-planning.md](windows/strategy-planning.md) | [12-strategy-planning.md](topics/12-strategy-planning.md) | 研究策略框架、方案比较、优先级和路线选择 |
| 长期任务 | 专项 | 已建立 | [long-running-tasks.md](tasks/long-running-tasks.md) | [long-running-tasks.md](windows/long-running-tasks.md) | [08-automation-and-long-running-tasks.md](topics/08-automation-and-long-running-tasks.md) | 研究提醒、周期任务、自动化和长期跟进 |
| 多项代理 | 专项 | 已建立 | [multi-agent.md](tasks/multi-agent.md) | [multi-agent.md](windows/multi-agent.md) | [05-multi-window-and-agents.md](topics/05-multi-window-and-agents.md) | 研究多窗口、多代理、分工合并 |
| 软件开发 | 专项 | 已建立 | [software-development.md](tasks/software-development.md) | [software-development.md](windows/software-development.md) | [03-code-editing-and-verification.md](topics/03-code-editing-and-verification.md) | 研究代码修改、测试、调试、交付 |
| 工具插件 | 专项 | 已建立 | [tools-plugins.md](tasks/tools-plugins.md) | [tools-plugins.md](windows/tools-plugins.md) | [04-tools-skills-plugins.md](topics/04-tools-skills-plugins.md) | 研究工具、Skills、插件和降级方案 |
| 写作剧本 | 专项 | 已建立 | [writing-screenplay.md](tasks/writing-screenplay.md) | [writing-screenplay.md](windows/writing-screenplay.md) | [10-writing-and-screenplay.md](topics/10-writing-and-screenplay.md) | 研究剧本创作、人物、对白、风格控制 |
| 自我学习 | 专项 | 已建立 | [self-learning.md](tasks/self-learning.md) | [self-learning.md](windows/self-learning.md) | [11-self-learning.md](topics/11-self-learning.md) | 研究学习路径、练习、测验、复盘 |
| 资料整理 | 专项 | 已建立 | [knowledge-management.md](tasks/knowledge-management.md) | [knowledge-management.md](windows/knowledge-management.md) | [09-knowledge-management.md](topics/09-knowledge-management.md) | 研究资料整理、摘要、知识库化 |

## 临时窗口登记

临时窗口用于验证具体问题。建议完成后把状态改为 `已归档`。

| 窗口名称 | 状态 | 问题 | 归档到 |
| --- | --- | --- | --- |
| 暂无 | - | - | - |

## 状态说明

- `已建立`：左侧对话中已经存在，并且本文件已登记。
- `建议建立`：近期建议开设。
- `候选`：暂时不急，但未来可能需要。
- `实验中`：正在进行具体研究。
- `已归档`：临时窗口已结束，结论已回填。

## 新窗口命名规则

长期窗口建议使用：

```text
CodeX <方向>：<核心对象>
```

临时窗口建议使用：

```text
CodeX 临时实验：<具体问题>
```
