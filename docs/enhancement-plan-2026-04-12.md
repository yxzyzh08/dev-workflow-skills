# Enhancement Plan: Skill Library Enhancements (2026-04-12)

**Date**: 2026-04-12
**Status**: Phase 1-9 implemented, Phase 10 pending

---

## Summary of All Phases

### Completed Phases (1-9)

| Phase | Enhancement | Key Changes |
|-------|------------|-------------|
| 1 | TDD Rhythm | Created `developer/references/tdd-rhythm.md`; developer SKILL.md embeds RED-GREEN-REFACTOR into working loop |
| 2 | Step Decomposition | Created `tech-lead/references/step-decomposition-rules.md`; plan.md tasks require 2-5 min steps with code/content/expected-output |
| 3 | Two-Stage Review | Created `developer/references/two-stage-review.md`; developer working loop gains spec compliance (stage 1) + code quality (stage 2) |
| 4 | Cross-Cutting Workflow | evidence-standards, completion-verifier, delivery-qa, doc-guardian, review-report-rules updated to recognize new artifacts |
| 5 | detail.md/plan.md Relationship | detail.md = single contract authority; plan.md steps reference detail.md, not duplicate; detail.md written first |
| 6 | Review Findings Fix | Codex review B1/B2/M1/M2 fixes; frontmatter-and-state-flow, review-report-rules, developer wording alignment |
| 7 | Plan Split Format | Single-file (≤3 tasks) vs split format (>3 tasks or >10 steps): plan.md index + tasks/T{n}.md |
| 8 | Integration Task | Multi-task plans with shared interfaces require integration task as last task; exemption for independent tasks with reason |
| 9 | Parallel Worker Quality | parallel-dispatcher requires every worker to follow developer full working loop (TDD + two-stage review); integration task timing enforced |

### Phase 10: Git Commit Rules (Pending)

**背景**: 整个工作流产出大量文档和代码产物，但没有任何 skill 定义何时应该 git commit。风险包括：产物丢失（agent 崩溃）、审查无基线（无法 diff）、并行冲突、追溯链断裂、回滚困难。

**核心原则**: 关键产物写入磁盘后立即 commit，保证每个可审查的中间状态都有 git 记录。

---

## Phase 10 Detailed Plan

### Commit timing rules by stage

| 阶段 | Commit 时机 |
|---|---|
| requirements-analyst | requirements baseline 写入或修改后 |
| acceptance-designer | acceptance baseline 写入或修改后 |
| system-architect | architecture baseline 写入或修改后 |
| tech-lead | detail.md 写入后; plan.md 写入后 (split format: 每个 task file 写入后) |
| developer | 每个 TDD GREEN 通过后 (代码+测试); 每个审查报告写入后 |
| test-engineer | e2e-plan 写入后; e2e suite 代码写入后 |
| delivery-qa | 每个 run result / bug analysis / review report 写入后 |
| all skills | review report 写入后; CR 写入后; progress dashboard 更新后 |

### Commit message format

`[r{n}] {skill-name}: {artifact description}`

Examples:
- `[r1] requirements-analyst: write requirements baseline`
- `[r1] tech-lead: write detail.md`
- `[r1] tech-lead: write plan.md task T3`
- `[r1] developer: T1 GREEN - user auth module`
- `[r1] developer: T1 spec-review-01 pass`
- `[r1] developer: T1 code-review-01 pass`
- `[r1] developer: integration task GREEN`
- `[r1] test-engineer: write e2e-plan`
- `[r1] delivery-qa: run-2026-04-12 result`

### Files to change

**1. git-manager/SKILL.md** — 新增 Commit Rules 章节:
- commit timing 规则: 关键产物写入后立即 commit
- commit message 格式: `[r{n}] {skill}: {description}`
- commit 粒度指导: 每个可审查的中间状态一个 commit，不要攒到阶段结束才批量 commit

**2. git-manager/references/worktree-and-branch-rules.md** — 新增 Commit discipline 章节:
- 在 worktree 中工作时同样遵守 commit timing 规则
- 每个 GREEN 后 commit，每个审查报告写入后 commit

**3. NEW: git-manager/references/commit-rules.md** — 独立 reference:
- 按阶段的 commit timing 表
- commit message 格式和示例
- 禁止的模式 (批量 commit、无消息 commit、mix 不相关变更)

**4. workflow-protocol/SKILL.md** — Shared Rules 增加:
- 所有 skill 产出的文档产物写入磁盘后必须 commit
- 引用 git-manager/references/commit-rules.md

**5. developer/SKILL.md** — Working Loop 增加 commit 时机:
- step 3 (GREEN) 后 commit
- step 5/6 审查报告写入后 commit

**6. tech-lead/SKILL.md** — Working Loop 增加 commit 时机:
- step 2 (detail.md) 写入后 commit
- step 3 (plan.md / task files) 写入后 commit

**7. parallel-dispatcher/references/integration-checklist.md** — Before integrating 增加:
- 每个 worker 的 worktree 中所有产物已 commit

**8. completion-verifier/references/evidence-checklist.md** — 增加:
- git log 中存在与产物对应的 commit 记录

**9. workflow-protocol/references/evidence-standards.md** — 各阶段增加:
- commit 记录作为产物存在性的辅助证据

**10. Pressure test prompts** — git-manager + developer:
- "攒到最后再一起 commit"
- "commit message 不写 release 和 skill 前缀"
- "在 GREEN 之前就 commit 未通过测试的代码"

### Verification checklist

- [ ] `skills/git-manager/references/commit-rules.md` 存在，包含 timing table、message format、rejected patterns
- [ ] `skills/git-manager/SKILL.md` 有 Commit Rules 章节引用 commit-rules.md
- [ ] `skills/git-manager/references/worktree-and-branch-rules.md` 有 Commit discipline 章节
- [ ] `skills/workflow-protocol/SKILL.md` 引用 commit-rules.md 作为共享规则
- [ ] `skills/developer/SKILL.md` Working Loop step 3 和 step 5/6 后有 commit 指令
- [ ] `skills/tech-lead/SKILL.md` Working Loop step 2 和 step 3 后有 commit 指令
- [ ] `skills/parallel-dispatcher/references/integration-checklist.md` Before integrating 要求所有 worktree 产物已 commit
- [ ] `skills/completion-verifier/references/evidence-checklist.md` 增加 commit 记录检查
- [ ] `skills/workflow-protocol/references/evidence-standards.md` 各阶段增加 commit 证据
- [ ] `skills/git-manager/references/pressure-test-prompts.md` 增加 commit 相关压力测试
- [ ] `skills/developer/references/pressure-test-prompts.md` 增加 commit timing 压力测试
- [ ] 回归测试通过
