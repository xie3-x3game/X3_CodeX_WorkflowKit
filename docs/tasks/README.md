# 任务安排目录

本目录用于安排总控窗口和各专项窗口的当前任务、上下文交接和边界分流。

它和已有目录的关系：

- `docs/windows`：窗口怎么工作，偏长期规则。
- `docs/tasks`：窗口现在做什么，偏当前安排。
- `docs/dispatch`：跨窗口转交的具体任务实例，偏队列流转。
- `docs/topics`：研究过程和稳定结论，偏沉淀归档。
- `docs/window-registry.md`：有哪些窗口，偏登记索引。

## 使用原则

- 总控窗口负责创建、分配和调整任务。
- 每个专项窗口首次使用时，先按 [窗口启动协议](../workflow/window-boot-protocol.md) 加载规则。
- 每个专项窗口开始工作前，先读取本目录下自己的任务文件。
- 任务超出当前窗口边界时，不继续展开，先写明应转交给哪个窗口。
- 任务完成后，把结论回填到对应 `docs/topics` 文件，再由总控更新索引。
- 本目录只放任务概要和交接信息，不放长篇过程记录。

## 任务状态

- `Inbox`：已提出但未分配。
- `Ready`：已分配，等待对应窗口处理。
- `Active`：正在处理。
- `Blocked`：被环境、资料或决策阻塞。
- `Handoff`：需要转交其他窗口。
- `Done`：已完成，等待总控归档。
- `Archived`：已归档到主题文件或总索引。

## 当前任务文件

| 窗口 | 任务文件 |
| --- | --- |
| 总控 | [total-control.md](total-control.md) |
| 能力边界 | [ability-boundary.md](ability-boundary.md) |
| 提示描述 | [prompt-description.md](prompt-description.md) |
| 策略拟定 | [strategy-planning.md](strategy-planning.md) |
| 长期任务 | [long-running-tasks.md](long-running-tasks.md) |
| 多项代理 | [multi-agent.md](multi-agent.md) |
| 软件开发 | [software-development.md](software-development.md) |
| 工具插件 | [tools-plugins.md](tools-plugins.md) |
| 写作剧本 | [writing-screenplay.md](writing-screenplay.md) |
| 自我学习 | [self-learning.md](self-learning.md) |
| 资料整理 | [knowledge-management.md](knowledge-management.md) |

## 标准交接格式

```text
任务标题：
来源窗口：
目标窗口：
转交原因：
必要上下文：
应读取文件：
期望产出：
完成后回填：
状态：
```

## Dispatch 队列

跨窗口转交任务优先写入 [Dispatch 任务队列](../dispatch/README.md)，而不是只在对话中口头转交。

常用命令：

```text
查看队列：软件开发
接单：软件开发
执行任务：T-20260509-001
```

## 窗口开始工作时的读取顺序

1. 读取自己的 `docs/tasks/<window>.md`。
2. 读取其中列出的 `docs/windows/<window>.md`。
3. 需要背景时，再读取对应 `docs/topics/<topic>.md`。
4. 只处理任务文件中属于本窗口能力边界内的内容。
