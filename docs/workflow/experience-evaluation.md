# 经验有效性评分

本文件用于判断其他项目回传经验是否值得进入 `X3_CodeX` 的通用方法、模板、脚本或 WorkflowKit。

核心原则：外部经验先作为样本，不直接变成规则。

## 先做硬性过滤

出现以下任一情况时，经验只能进入 `Raw` 或 `Quarantine`，不能进入候选规则：

- 包含账号、密钥、私人路径、客户资料、原始业务材料。
- 没有明确场景，只是泛泛评价。
- 没有证据，无法判断真实发生过什么。
- 只适用于一个项目的业务偏好，却被包装成通用规则。
- 与现有稳定规则冲突，但没有说明冲突原因。

## 正向评分

每项按 `0-5` 分评分。

| 维度 | 权重 | 含义 |
| --- | ---: | --- |
| `EQ` Evidence Quality | 0.20 | 证据是否具体：文件、命令、截图、结果摘要、前后对比 |
| `RP` Reproducibility | 0.15 | 是否可复现，是否能说明触发条件 |
| `OI` Outcome Impact | 0.20 | 对效率、质量、误操作减少、交付成功率的影响 |
| `TR` Transferability | 0.15 | 是否能迁移到多个项目/窗口，而不是单点场景 |
| `RR` Risk Reduction | 0.10 | 是否降低数据污染、误删、误分流、上下文混乱等风险 |
| `LC` Low Cost | 0.10 | 采纳成本是否低，是否不显著增加用户负担 |
| `CF` Compatibility Fit | 0.10 | 是否与现有窗口边界、脚本和模板兼容 |

正向基础分：

```text
Base = 20 * (0.20*EQ + 0.15*RP + 0.20*OI + 0.15*TR + 0.10*RR + 0.10*LC + 0.10*CF)
```

`Base` 范围是 `0-100`。

## 污染与成本扣分

每项按 `0-5` 分评分，分数越高风险越大。

| 维度 | 权重 | 含义 |
| --- | ---: | --- |
| `PR` Privacy Risk | 0.35 | 隐私、路径、业务内容、账号资料风险 |
| `DR` Dirty Data Risk | 0.30 | 偶发、误读、幻觉、上下文不完整、样本偏差 |
| `SS` Scope Specificity | 0.20 | 是否过度依赖单一项目、单一用户、单一目录结构 |
| `PB` Process Burden | 0.15 | 是否让日常使用变重、步骤变多、维护成本上升 |

扣分：

```text
Penalty = 5 * (0.35*PR + 0.30*DR + 0.20*SS + 0.15*PB)
```

`Penalty` 范围是 `0-25`。

## 置信度系数

置信度从 `0.60` 起步，最多 `1.00`：

```text
Confidence = 0.60
           + 0.10 if there is a concrete artifact
           + 0.10 if the result is reproducible
           + 0.10 if it repeated in the same project
           + 0.10 if it appeared in another project
```

如果经验只来自一次聊天描述，通常不能超过 `0.70`。

## 最终公式

```text
Experience Score = round(max(0, Base - Penalty) * Confidence)
```

## 采纳分级

| 分数 | 等级 | 处理 |
| ---: | --- | --- |
| `0-29` | `Rejected` | 不采纳，只保留拒绝原因 |
| `30-49` | `Raw` | 只存档，等待更多证据 |
| `50-69` | `Candidate` | 进入候选池，可分发专项窗口研究 |
| `70-84` | `Validated` | 可更新研究记录、局部模板或项目内规则 |
| `85-100` | `Stable` | 可考虑更新 WorkflowKit，但必须先通过脚本/模板验证 |

硬性限制：

- `PR >= 4`：必须脱敏后重新评分。
- `EQ <= 1`：最高只能是 `Raw`。
- `DR >= 4`：最高只能是 `Candidate`。
- `PB >= 4`：不能进入 `Stable`。
- 涉及脚本、模板、WorkflowKit 的更新，必须本地验证通过。

## 最低记录格式

```text
Experience Score:
Stage: Raw|Candidate|Validated|Stable|Rejected
EQ:
RP:
OI:
TR:
RR:
LC:
CF:
PR:
DR:
SS:
PB:
Confidence:
Reason:
Next Review:
```

## 使用位置

- 项目总控：给 `docs/project-experience-sync.md` 中的同步包做初评。
- `X3_CodeX` 总控：只负责接收、过滤和分发，不直接采纳。
- 专项窗口：复核评分，并决定是否形成模板、脚本或稳定结论。
- WorkflowKit 发布前：只允许 `Validated` 或 `Stable` 经验进入可复制规则。
