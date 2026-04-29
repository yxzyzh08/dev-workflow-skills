# Variant C — Skill 项目验收：决策与备选

> 沉淀自 2026-04-28 对话。新决策按时间倒序追加。

## D-001 在 acceptance-designer 内加 Variant C，而非新建 skill

- **决策**：在 `skills/acceptance-designer` 内新增 Variant C；详细规则放进 references。
- **日期**：2026-04-28
- **备选**：
  - A. 不动框架，让作者在现有 Variant A/B 下硬撑——State Catalog 仍必填，体验差。
  - **B. ★ 内部分流加 Variant C**（保持单一入口，主 SKILL.md 改动有限）。
  - C. 拆新 skill `acceptance-designer-artifact`——避免污染主 skill，但 skill 库碎片化、调用方需多记一个名字。
- **理由**：保持单一入口，避免 skill 库碎片化；变更主要落在 references/，主 SKILL.md 只加少量分支条件。

## D-002 文档结构：主题目录而非单文件 / 完整 dogfood

- **决策**：`docs/variant-c-skill-acceptance/` 主题目录，含 `requirements.md` / `design.md` / `decisions.md` / `fixtures/` / `reviews/`。
- **日期**：2026-04-28
- **备选**：
  - A. 单文件 `docs/variant-c-skill-acceptance.md`——最省事，但 fixture 多了会膨胀。
  - **B. ★ 主题目录**——容纳 fixture 与多轮评审，仍轻量。
  - C. 完整 dogfood：新建 `workflow-project.yaml` + `docs/projects/.../{requirements,acceptance,design,...}` 走全链路——形式漂亮但有递归路径歧义（见 D-003）。
- **理由**：能容纳 fixture 与多轮评审；不引入 `workflow-project.yaml` 的递归路径歧义。

## D-003 暂不为 dev-workflow-skills 仓库本身加 workflow-project.yaml

- **决策**：本次设计工作不引入仓库级 `workflow-project.yaml`，不走全链路 skill 调用。
- **日期**：2026-04-28
- **理由**：`acceptance-designer` 是被改对象。"用旧版 acceptance-designer 给新版 acceptance-designer 写验收"会让 `paths.acceptance` 含义混乱（新旧两份语义不同）。先靠轻量 docs 推进；Variant C 稳定后再考虑 dogfood 化。

## D-004 D1-D3 解析

- **决策**：
  - **D1** behavioral discovery validation **不纳入** Variant C v1（移入 requirements.md 的"不在范围"）。静态可见性（skill 是否被加载到 agent system prompt）由 `check-skill-discovery.py` 经 R3 的 `exit-code` 观察自然覆盖。
  - **D2** **不扩 grammar**：现有 `matches /regex/` / `count-matching` / `∈ {set}` 已能覆盖 LLM 措辞变化、"M of N"、枚举值；在 `references/variant-c-skill-projects.md` 加 "LLM 非确定性 recipes" 节落地（详见 design.md）。
  - **D3** 沿用 `output-artifacts.md` §2.2 的 `<fixture-root>` 约定（子结构 `<fixture-root>/<scenario>/<input-files>`），由 **acceptance 文档**自身在 Acceptance Preparation 或 State Catalog 段绑定，**非**被验收的 SKILL.md。已并入 R8。
- **日期**：2026-04-28
- **理由**：
  - D1：behavioral discovery 需 evaluator agent + 上下文模拟，与 R3"机械可验证"原则冲突；让 State Catalog 同时承载"workspace 文件态"和"agent 上下文态"会复杂度膨胀。
  - D2：扩 grammar 会破坏与 Variant A/B 的兼容性；现有词汇组合足够，文档化即可。
  - D3：复用现有约定避免引入新机制；acceptance 文档是验收的唯一定义点，被验收 SKILL.md 不应感知夹具组织。

## D-005 改动 3（AI 骨架 Cleanup 注脚）合并进改动 2

- **决策**：design.md 中 SKILL.md 改动 3 不单独实施；其内容并入改动 2 的 "Under Variant C" bullet（位于 Shared structural rules 段，**非**案例骨架代码块内）。
- **日期**：2026-04-29
- **理由**：在 AI/Hybrid 案例骨架的 ` ```markdown ` 代码块内插入 `*(Under Variant C, ...)*` 注脚会让该注脚成为模板文本的一部分，读者会照抄进自己的 case，污染 case 输出。改为：
  - SKILL.md → Shared structural rules → "Under Variant C" bullet 写 `Cleanup defaults to rm -rf <output-dir>/<case-id>`（高密度摘要）
  - `references/variant-c-skill-projects.md` §7 Section Defaults 给详细模板
  两层声明充分。
- **影响**：design.md 5 项改动 → 实际 4 项实施 + 1 项合并；SKILL.md 案例骨架保持原状（与 Variant A/B 一致风格）。
