---
title: dev-workflow-skills 项目进度
current_focus: Variant C v1 post-shipping (real-world validation)
status: active
last_updated: 2026-04-29 12:00
---

## 当前状态

| 工作 | 状态 | 关键产物 |
|------|------|----------|
| acceptance-designer Variant C | shipped (v1) | commits `a388aad` + `3ca56d7`；`skills/acceptance-designer/references/variant-c-skill-projects.md` (433 行 / 9 章)；`SKILL.md` 4 处增量 + discovery 描述修补 |
| Variant C 设计追溯链 | frozen | `docs/variant-c-skill-acceptance/{requirements (frozen v0.4), design (frozen v0.4), decisions (D-001~D-005), meta-acceptance (active v0.1), reviews/review-01 (PASS)}` |
| Skill 库基线（16 skills） | stable | `skills/{16 个 skill}` + `AGENT.md` 表 |
| Plugin 分发（3 平台） | stable | `.claude-plugin/`, `.agents/plugins/`, `plugins/dev-workflow-skills/` |
| 进度追踪基础设施 | active | `docs/workflow/{progress, progress-history}.md` + `workflow-project.yaml`（仅 progress 路径） |

## 阻塞 / 待决

- **post-shipping 验证未跑**：Variant C 在真实消费方项目里能否被 agent 正确选中、是否对静态产物项目挑 Variant C、是否加载 references、产出是否合规——4 个观察点都还没在真实项目验证过
- **meta-acceptance §2.4 的 5 个 helper scripts 未实现**：`markdown-section-exists.sh` / `markdown-trace-extractor.py` / `markdown-headings-to-json.py` / `per-case-fields-check.py` / `r5-antipattern-check.sh`
- **harness binding UNTESTED**：`meta-acceptance.md` §2.1 选了 Claude Code CLI 形态但未实际验证；备选形态（自定义 runner / Anthropic API）也未验证
- **fixture 未重构到 per-scenario 子目录**：当前 fixture 直接在 `docs/variant-c-skill-acceptance/fixtures/` 下，未按 `<fixture-root>/<scenario>/<input-files>` 约定（meta-acceptance §2.2 已注明 v0.1 简化）

## 下一步

1. 选定一个真实消费方项目（已有 skill 项目 / 文档项目均可），装上 plugin（`/plugin marketplace add github:yxzyzh08/dev-workflow-skills` + `/plugin install dev-workflow-skills`，或本地路径），跑一次"用 acceptance-designer 写 skill 项目验收"，验证 4 个观察点
2. 根据真实跑反馈修订 `SKILL.md` / `references/variant-c-skill-projects.md` / `meta-acceptance.md`
3. 必要时实现 5 个 helper scripts，让 `meta-acceptance.md` 真能机械化跑

## 已完成里程碑

- **2026-04-29** — Variant C v1 ship + discovery 描述修补（commits `a388aad`, `3ca56d7`）；进度追踪基础设施落地（本表 + `progress-history.md` + `workflow-project.yaml`）
- **2026-04-28** — Variant C v0.1 → v0.4 设计闭环（requirements / design / decisions / fixtures / meta-acceptance / review-01 PASS / freeze）
- **<2026-04-27** — pre-Variant C 基线（16 个 skill + 3 平台 plugin 分发）
