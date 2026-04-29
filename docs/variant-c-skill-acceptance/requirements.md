# Variant C — Skill 项目验收：需求

> 状态：基线 v0.4，**frozen** (2026-04-29 post-Review 01)。
> 修订历史：
> - **v0.4 (2026-04-29)** — Review 01 minor 修复 + 冻结：R10 从"可选/待定"移入"已决议（不在 SKILL.md 主文本）"段，文本更新反映 design + decisions D-005 已决；状态 frozen。
> - **v0.3 (2026-04-28)** — D1-D3 解析落地：D1（behavioral discovery）移入"不在范围"；D2 不扩 grammar、recipes 落 design 阶段；D3 沿用 `output-artifacts.md` §2.2 的 fixture-root 约定，并入 R8。删除"期望但未决"段。详见 [decisions.md](decisions.md) D-004。
> - **v0.2 (2026-04-28)** — 自审计后修订：R1 细化为 Invariants + How-to-reach；R2 拆为 R2a/R2b；R3 给出正反清单并保留 `kind=wait`/`within Ns` 约束；R5 用 §9 Scope 词汇精化；R6 命名典型模式；R7 列出具体不变章节；新增 R8（harness 前提）/ R9（fixture 只读）；R10 列入可选待定。
> - **v0.1 (2026-04-28)** — 初稿，沉淀自对话。
>
> 相关：[design.md](design.md) · [decisions.md](decisions.md)

## 背景

`acceptance-designer` 当前的 State Catalog（Variant A/B）和 AI-tier 观察词汇都隐含
"运行时产品"假设：服务进程、PID 文件、log file、串行 reset。skill 项目的交付物是
markdown 文件本身，没有这些东西，硬塞会让 acceptance 文档大量字段空转。

需要在 acceptance-designer 内提供一个针对"skill / 静态产物 / 夹具驱动"项目的变体。

## 适用场景

- 项目交付物是 skill（SKILL.md + references/ + scripts/）
- 项目交付物是静态文档/文章等纯文本产物（无运行时进程）
- 验收主要观察"产出文件的结构与属性"，而非"运行时行为"

## 必须满足

- **R1** State Catalog 可声明 Variant C。`S<n>` 描述 **workspace 文件态**（fixture 文件 + 产出目录）；`Invariants` 用 AI-tier 文件态观察（`file-exists` / `file-absent` / `directory-exists` / `file-field`）；`How to reach` 描述 fixture 铺设步骤（拷入 / 同步 / 校验存在）。

- **R2a** 服务/进程相关字段不适用：service commands / PID file / log file / state file 等运行时绑定，以及 `process-running` / `socket-listening` 等观察模式，在 Variant C 下不出现。

- **R2b** 串行化 / `run-lock` 重新评估：由"workspace 是否可隔离"决定。默认仍串行（与 Variant A 一致，但用 `flock` 保护输出目录而非共享 home），无 `run-lock` 强制要求；若每案例独立 workspace 目录，可解锁并行（向 Variant B 靠拢，本版本不要求）。

- **R3** AI-tier 观察模式分级：
  - **适用**：`exit-code` / `stdout` / `stderr` / `file-exists` / `file-absent` / `directory-exists` / `directory-absent` / `file-field` / `file-field-delta`
  - **上下文相关**：`log-line` / `log-absent`（仅在 harness 产生日志时使用）
  - **不适用**：`process-running` / `process-absent` / `socket-listening` / `socket-closed`
  - `kind=wait` 仍可用（典型场景：等待 harness 完成 skill 调用并产出文件）；其 `within Ns` 仍强制(与 Variant A 同规则)。

- **R4** Cleanup 形态：默认是"清空产出目录"。Fixture 视为只读，cleanup 不重置 fixture（见 R9）。

- **R5** Pass checklist 三种 scope 都按**结构性断言**写，对齐 `output-artifacts.md` §9：
  - **Scope 1（per-step rollup）**：每步 expected 用 `file-exists` / `file-field` 等结构断言。
  - **Scope 2（case-aggregate）**：用 `at-least-once` / `count-matching` 表达"产出含至少 N 个 case"、"每个输入需求都被追溯"等聚合。
  - **Scope 3（end-state）**：产出目录的最终文件态。
  - **严禁文本相等比较**（LLM 输出非确定，会导致脆弱测试）。

- **R6** Hybrid 案例典型模式：**AI 块**跑 `skills/skill-writer/scripts/*` 等结构脚本（`exit-code` / `file-field`）；**Human 块**对产出做 `quality`（清晰度、可用性）/ `perceived`（"读起来对"）评价。

- **R7** 通用规则保持不变：`output-artifacts.md` §1.3（release tag 约定）/ §1.4（追溯契约）/ §4（case 骨架，包括 ai/human/hybrid 三种）/ §10（outcome 词汇与模板）/ §11（终止语义）/ §12（Declared branches）原样适用，Variant C 不引入任何例外。

- **R8** 调用 harness + Fixture 路径约定（AI 案例共享前提）：
  - 所有 Variant C AI 案例假设存在一个**可重复触发 skill 调用**的 harness（Claude Code CLI / 自定义 runner / 测试 harness 都可），能把 fixture 作为输入、把产出落到指定输出目录。harness 的具体形态在 `Acceptance Preparation` 段（§1.2 #2）绑定。
  - Fixture 路径约定沿用 `output-artifacts.md` §2.2 的 `<fixture-root>` 模式，子结构为 `<fixture-root>/<scenario-name>/<input-files>`，由 **acceptance 文档自身**（非被验收的 SKILL.md）在 Acceptance Preparation 或 State Catalog 段绑定。
  - *没有 R8，AI 案例的"调用 → 观察"链断裂。*

- **R9** Fixture 只读：case 不可修改 fixture 本体；所有产出落到独立输出目录。否则 reset 语义破裂、case 间相互污染。

## 已决议（不在 SKILL.md 主文本）

- **R10** Section Defaults 兼容：§3 Section Defaults 机制对 Variant C 透明。**v0.4 决议（沿用 design.md "R10 处理"、decisions.md D-005）**：不在 SKILL.md 主文本里专门列出 Variant C 的 Section Defaults 默认值；推荐模板（含 `Cleanup` / `default-actor` / `verifier` 默认）由 `skills/acceptance-designer/references/variant-c-skill-projects.md` §7 提供。机制本身（§3 Section Defaults）跨 variant 通用，无需 Variant C 特化文法。

## 不在范围

- 修改 `skill-writer`（验证脚本归 skill-writer 管，不在本次 acceptance-designer 改动里）
- 给整个 `dev-workflow-skills` 仓库本身加 `workflow-project.yaml`（见 decisions.md D-003）
- 重写 Variant A/B（与 Variant C 平行存在，互不影响）
- **Behavioral discovery validation**：判定 agent 在场景 X 下是否真选中该 skill。需独立 evaluator agent，与"给 fixture 看产出"的文件态模型不兼容；归未来独立问题。静态可见性（skill 是否已加载到 agent system prompt）由 `check-skill-discovery.py` 通过 R3 的 `exit-code` 观察自然覆盖，不算 discovery 验收。（D1 解析见 decisions.md D-004）
