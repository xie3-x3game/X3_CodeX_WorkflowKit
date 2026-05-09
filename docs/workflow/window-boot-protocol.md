# 窗口启动协议

本协议用于让每个 CodeX 专项窗口快速遵循本项目的窗口边界、任务安排和回填规则。

## 推荐方式

日常使用短命令，并显式提供当前窗口名称：

```text
启动：软件开发
```

如果短命令没有触发规则加载，使用兜底命令：

```text
请先读取 AGENTS.md，然后执行：启动：软件开发
```

原因：

- CodeX 通常不能可靠读取左侧 UI 中的窗口名称。
- 显式写出窗口名可以避免加载错任务文件。
- 所有窗口共用同一套启动协议，后续维护成本最低。

完整启动指令见 [统一窗口启动指令](../templates/universal-window-start-prompt.md)。自动化层级见 [窗口启动自动化层级](window-activation-levels.md)。

## 启动指令的工作逻辑

窗口收到短命令、完整启动指令或兜底命令后，应按以下顺序处理：

1. 根据窗口名称查找对应任务文件。
2. 读取 `docs/tasks/<window>.md`。
3. 读取任务文件中列出的 `docs/windows/<window>.md`。
4. 必要时读取对应 `docs/topics/<topic>.md`。
5. 总结本窗口边界、当前任务和不应处理的内容。
6. 只执行任务文件中属于本窗口边界内的工作。

如果窗口名称缺失或无法匹配，应先要求用户补充窗口名称，不应自行展开任务。

## 窗口名称映射

| 左侧窗口名 | 任务文件 | 工作指南 |
| --- | --- | --- |
| 总控 | `docs/tasks/total-control.md` | `docs/windows/total-control.md` |
| 能力边界 | `docs/tasks/ability-boundary.md` | `docs/windows/ability-boundary.md` |
| 提示描述 | `docs/tasks/prompt-description.md` | `docs/windows/prompt-description.md` |
| 策略拟定 | `docs/tasks/strategy-planning.md` | `docs/windows/strategy-planning.md` |
| 长期任务 | `docs/tasks/long-running-tasks.md` | `docs/windows/long-running-tasks.md` |
| 多项代理 | `docs/tasks/multi-agent.md` | `docs/windows/multi-agent.md` |
| 软件开发 | `docs/tasks/software-development.md` | `docs/windows/software-development.md` |
| 工具插件 | `docs/tasks/tools-plugins.md` | `docs/windows/tools-plugins.md` |
| 写作剧本 | `docs/tasks/writing-screenplay.md` | `docs/windows/writing-screenplay.md` |
| 自我学习 | `docs/tasks/self-learning.md` | `docs/windows/self-learning.md` |
| 资料整理 | `docs/tasks/knowledge-management.md` | `docs/windows/knowledge-management.md` |

## 启动后必须输出

每个窗口启动后先输出一段简短确认：

```text
已加载窗口：
任务文件：
工作指南：
当前边界：
当前任务：
如果任务超出边界，将转交给：
```

文件路径优先使用仓库相对路径，例如 `docs/tasks/software-development.md`。只有在需要定位本地文件时，才使用绝对路径。

启动确认只需要简短列出边界和任务，不需要展开完整研究内容。

## 边界处理

如果用户给出的任务超出当前窗口边界，窗口应停止深入展开，并返回：

```text
这个任务超出当前窗口边界。

建议转交窗口：
原因：
必要上下文：
期望产出：
```
