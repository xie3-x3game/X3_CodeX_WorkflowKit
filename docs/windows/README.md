# 窗口工作指南

本目录记录每个长期窗口的工作指南。它和 `docs/topics` 的区别是：

- `docs/windows`：指导某个窗口怎么工作，可迁移到新项目。
- `docs/tasks`：安排某个窗口当前做什么、读什么上下文、何时转交。
- `docs/topics`：记录研究过程、实验观察和结论沉淀。

未来新建项目时，总控窗口可以根据项目类型，从本目录选择合适的指南文件，再配合 `docs/tasks` 生成项目内的任务安排文件。

## 当前窗口

| 左侧窗口 | 指南文件 | 主要用途 |
| --- | --- | --- |
| 总控 | [total-control.md](total-control.md) | 项目认知地图、窗口分流、阶段复盘 |
| 能力边界 | [ability-boundary.md](ability-boundary.md) | 判断 CodeX 能做什么、不能做什么、何时需要人工介入 |
| 提示描述 | [prompt-description.md](prompt-description.md) | 研究如何描述任务、上下文、约束和验收标准 |
| 策略拟定 | [strategy-planning.md](strategy-planning.md) | 研究策略框架、方案比较、优先级和路线选择 |
| 长期任务 | [long-running-tasks.md](long-running-tasks.md) | 研究提醒、自动化、周期任务和长期跟进 |
| 多项代理 | [multi-agent.md](multi-agent.md) | 研究多窗口、多代理、并行拆分和结果合并 |
| 软件开发 | [software-development.md](software-development.md) | 研究代码修改、验证、交付和 GitHub 协作 |
| 工具插件 | [tools-plugins.md](tools-plugins.md) | 研究工具、Skills、插件和外部能力 |
| 写作剧本 | [writing-screenplay.md](writing-screenplay.md) | 研究创作、剧本、人物、对白和审稿 |
| 自我学习 | [self-learning.md](self-learning.md) | 研究学习路径、练习、测验和复盘 |
| 资料整理 | [knowledge-management.md](knowledge-management.md) | 研究资料整理、摘要、知识库化和结构化输出 |

## 每个指南文件必须包含

- 窗口定位。
- 适合处理的问题。
- 不适合在本窗口处理的问题。
- 标准工作流程。
- 产出物。
- 回填总控的格式。

## 与任务安排文件的关系

窗口指南回答“这个窗口如何工作”，任务安排文件回答“这个窗口现在处理什么”。专项窗口启动时，应先读 `docs/tasks/<window>.md`，再按其中链接读取本目录下的工作指南。
