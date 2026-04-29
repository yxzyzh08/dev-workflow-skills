# Expected Output Properties — Sample Frozen Requirements Fixture

> 输入夹具：[sample-frozen-requirements.md](sample-frozen-requirements.md)
> 被测 skill：`acceptance-designer`
> 期望产出位置：`<output-dir>/<case-id>/acceptance.md`
>
> 此清单按 "Variant C Pass checklist 结构性断言"风格写，每条都应能被映射成 `file-field` / `count-matching` / `directory-exists` / `exit-code` 等可机械验证的观察。这份文件是 #5 meta-acceptance case 的"性质来源"，不是最终 acceptance 文档本身。

## P1 — Frontmatter 合规

- **P1.1** Frontmatter 含 `type: acceptance`
  → `file-field <output> -> frontmatter.type = "acceptance"`
- **P1.2** Frontmatter 含 `status` 字段，值 ∈ {draft, active, frozen}
  → `file-field <output> -> frontmatter.status ∈ {draft, active, frozen}`
- **P1.3** Frontmatter 含 `version` 字段，匹配 `\d+\.\d+`
  → `file-field <output> -> frontmatter.version matches /^\d+\.\d+$/`
- **P1.4** Frontmatter 含 `change_history`，至少一条
  → 辅助脚本展开 yaml → `count-matching(...) ≥ 1`

## P2 — 必备文档段（per output-artifacts.md §1.2）

- **P2.1** 含 "Document Instructions" 段
  → 辅助脚本 `markdown-section-exists.sh "Document Instructions"` → `exit-code = 0`
- **P2.2** 含 "Acceptance Preparation" 段 → 同上
- **P2.3** 含 "State Catalog" 段，且 heading 含 Variant 声明（A / B / C）
  → 辅助脚本 → `exit-code = 0` 且 `stdout matches /Variant [ABC]/`
- **P2.4** 含 "Main-Flow Acceptance Stories" 段 → 同上
- **P2.5** 含 "Next-Phase Constraints" 段 → 同上

> Phase B 备注：P2.* 都依赖一个 `markdown-section-exists.sh`/`.py` 辅助脚本（详见 design.md "AI-tier 观察模式" 节）。该脚本 #5 阶段实现，可放到 `<fixtures>/scripts/` 或借鉴 `skills/skill-writer/scripts/` 风格。

## P3 — Case 覆盖（从 R1/R2/R3 派生）

- **P3.1** 至少含 3 个 main-flow case（一一对应 R1/R2/R3，或合并成更少 case 但全覆盖）
  → 辅助脚本统计 `#### <case-id>` heading 在 main-flow 段下的数量 → `count ≥ 3`
- **P3.2** 每个输入需求 ID（R1, R2, R3）至少出现在某个 case 的 `Tracked requirements` 字段中
  → Pass checklist 推荐 pattern：
  ```
  Flow:
  - for-each {req} in [R1, R2, R3]:
    - step: probe doc for {req} in Tracked requirements
      expected:
      - exit-code = 0  (grep -q "Tracked requirements:.*{req}" <output>)
  Pass checklist:
  - [ ] every expected bullet in the Flow held    (Scope 1 — 每个 req 都被追溯)
  ```
- **P3.3** 没有引入未在输入中声明的需求 ID（出现的 R/X ID ⊆ {R1, R2, R3}）
  → 辅助脚本对比 → `exit-code = 0`

## P4 — 通用 case 必填字段（per §5.1）

每个 case 必须含：`release tag`（如 `(r1)`）、`default-actor`、`verifier`、`Starting state`、`Tracked requirements`。

→ 辅助脚本逐 case 校验 → `exit-code = 0`

## P5 — Tier-specific 必填字段（per §5.2/5.3/5.4）

- 每个 `verifier: ai` case 含 `Flow` + `Pass checklist` + `Outcome rule`
- 每个 `verifier: human` case 含 `Why human?` / `Estimated effort` / `Observer qualification` / `Setup for the observer` / `What to observe` / `What to try` / `Pass signals` / `Fail signals` / `Inconclusive signals` / `Recording`
- 每个 `verifier: hybrid` case 含 `AI block (Flow)` + `AI pass checklist` + `Human block` + 案例级 `Outcome rule`

→ 辅助脚本按 verifier 字段分块校验 → `exit-code = 0`

## P6 — Outcome rule 模板合规

每个 case 的 outcome rule 必须按 §10.2 的 priority order，含以下要素：
- 优先级 1：`set-outcome inconclusive-human-needed` 或对应 human 版本
- 优先级 2：`Pass-checklist item failed` 或 `Fail signal observed`
- 优先级 3（可选，仅 `Declared branches` 存在时）：`partial-coverage`
- 优先级 4：`pass`

→ 辅助脚本提取每个 case 的 outcome rule 段，检查关键短语都出现 → `exit-code = 0`

## P7 — 推荐符合的 LLM 非确定性 pattern

acceptance-designer 在产出时**不应**：
- 引用具体行号 / 字符位置（反 R5）
- 写"产出文本必须等于 ..."这种 exact 断言（反 R5）
- 在 case 顺序敏感断言（main-flow case 顺序应可重排）

→ 反例检测脚本 → `exit-code = 0`

## P8 — Variant 选择正确性

由于输入需求 R1-R3 描述的是运行时 HTTP 服务（有进程、状态、持久化），**期望** acceptance-designer 选择 **Variant A**（runtime 产品默认）。

- **P8.1** State Catalog heading 含 "Variant A"
  → 同 P2.3，但更具体：`stdout matches /Variant A/`
- **P8.2** 含 Suite-level rules 段，含 `Run-lock` 字段
  → 辅助脚本 → `exit-code = 0`

> 这条性质同时**反向验证**了 Variant C 自身：Variant C 是用来验证产 Variant A acceptance 的 skill；如果 acceptance-designer 错误选了 Variant C 来产 toy 服务的 acceptance，P8 会失败，从而捕捉到 skill 行为退化。

## 不期望的产出（反例 / Negative properties）

- **N1** 产出 ≠ 输入 markdown 拷贝（必须有实质增量：State Catalog、case 块、outcome rule 等）
- **N2** 不应虚构未在输入中出现的需求 ID（如 R4 / X1，除非作为追溯 placeholder 显式声明）
- **N3** 不应包含 v0.1 设计中已被否决的字段名（如 service-discovery-evaluator 之类幻想字段）

## 给 #2 / #5 的备注

- 本清单是骨架级"应有属性"，**不是**最终 acceptance 文档。
- 把 P1-P8 + N1-N3 转成正式 Variant C 案例时，会需要至少一个辅助脚本（markdown-section-exists / case-count / per-case-fields）。建议放 `docs/variant-c-skill-acceptance/fixtures/scripts/` 或考虑提交到 `skills/skill-writer/scripts/`（前者更合 dogfood 隔离原则）。
- 本 fixture 的"递归 dogfood"性质（用 acceptance-designer 验证 acceptance-designer）是有意为之；详见 [`sample-frozen-requirements.md`](sample-frozen-requirements.md) 的 toy 服务选择理由。
