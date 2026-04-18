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

**核心原则**: 产物在发布供评审、交接、或状态变更时 commit，而非每次写入磁盘时。commit 保留的是可审查的里程碑状态，不是中间草稿。

> Review finding 采纳记录:
>
> **Round 1** (docs/phase-10-review-2026-04-12.md):
> - Finding 1 (Blocker): 触发范围从"写入磁盘"收窄为"发布供评审/交接/状态变更"
> - Finding 2 (Blocker): developer commit 点从 GREEN 后移到完整 RED-GREEN-REFACTOR + step 4 验证通过后
> - Finding 3 (High): 定义 artifact-to-commit 映射规则（path + artifact ID + stage action）
> - Finding 4 (High): 要求集成时保留 worker commit（merge --no-ff，禁止 squash/rebase 抹除 worker 历史）
>
> **Round 2** (docs/phase-10-rereview-2026-04-12.md):
> - Finding 1 (Blocker): 验证方法从 `--diff-filter=A`（只查首次添加）改为 `git log --all -- {path}` + message 匹配，可验证同一文件的多次里程碑 commit
> - Finding 2 (High): 扩展 action 词汇表覆盖所有 mandatory trigger（新增 stabilize/activate/reopen/cr/progress）
> - Finding 3 (High): 补齐 5 个遗漏的阶段 skill（requirements-analyst, acceptance-designer, system-architect, test-engineer, delivery-qa）的 Working Loop commit 指令

---

## Phase 10 Detailed Plan

### Commit trigger definition

Commit 的触发条件是产物**发布供评审、交接、或状态变更**，具体包括：

1. **状态变更**: 文档 status 从 draft→active、active→frozen、frozen→active(CR) 时
2. **发布供评审**: 产物提交给 reviewer 或人工确认门之前
3. **交接给下游**: 产物作为下游 skill 的输入基线时
4. **验证通过**: 代码通过完整 TDD cycle + lint/type/test 验证后
5. **审查完成**: review report 写入后

不触发 commit 的场景：
- 阶段内的草稿迭代（draft 中的反复修改）
- review 发现问题后的中间修复（修复完成后再 commit）
- 尚未通过验证的代码

### Commit timing rules by stage

| 阶段 | Commit 时机 |
|---|---|
| requirements-analyst | baseline 发布供评审前; review 通过 + 人工确认后 (frozen) |
| acceptance-designer | baseline 发布供评审前; review 通过 + 人工确认后 (frozen) |
| system-architect | baseline 发布供评审前; review 通过 + 人工确认后 (stable) |
| tech-lead | detail.md 完成并准备交接给 plan.md 时; plan.md (含 task files) 完成并发布供评审前; review 通过 + 人工确认后 |
| developer | 完整 RED-GREEN-REFACTOR cycle + step 4 验证通过后; spec-review report 写入后; code-review report 写入后; integration task 验证通过后 |
| test-engineer | e2e-plan 发布供评审前; e2e suite 可执行后; review 通过后 |
| delivery-qa | 每个 run result 写入后; bug analysis 写入后; review report 写入后 |
| all skills | CR 写入后; progress dashboard 状态变更后 |

### Commit message format

`[r{n}] {skill-name}: {action} {artifact-path-or-id}`

Format 规则:
- `r{n}`: release 编号
- `{skill-name}`: 执行 skill 名称
- `{action}`: 下方 action 词汇表中的一个
- `{artifact-path-or-id}`: 产物的相对路径或 ID（如 `detail.md`、`T1`、`spec-review-01`）

### Action vocabulary

每个 mandatory trigger 对应一个 canonical action label:

| Action | 触发场景 |
|---|---|
| `publish` | 产物发布供评审或交接给下游 |
| `freeze` | 文档 status → frozen（review 通过 + 人工确认） |
| `stabilize` | 架构文档 status → stable |
| `activate` | 文档 status draft → active |
| `reopen` | frozen → active（CR 批准后） |
| `verify` | 代码通过完整 TDD cycle + lint/type/test 验证 |
| `review` | review report 写入 |
| `cr` | Change Request 写入 |
| `progress` | progress dashboard 状态变更 |

Examples:
- `[r1] requirements-analyst: publish requirements baseline`
- `[r1] requirements-analyst: freeze requirements baseline`
- `[r1] system-architect: stabilize architecture baseline`
- `[r1] tech-lead: publish detail.md`
- `[r1] tech-lead: publish plan.md T3`
- `[r1] developer: verify T1`
- `[r1] developer: review T1 spec-review-01 pass`
- `[r1] developer: review T1 code-review-01 pass`
- `[r1] developer: verify integration task`
- `[r1] test-engineer: publish e2e-plan`
- `[r1] delivery-qa: publish run-2026-04-12 result`
- `[r1] requirements-analyst: reopen requirements baseline (cr-01)`
- `[r1] tech-lead: cr cr-02 design scope change`
- `[r1] completion-verifier: progress design stage frozen`

### Artifact-to-commit mapping rule (for verification)

每个 commit 必须可以通过以下三元组定位到具体产物：
- **path**: 产物的文件路径（相对于项目根目录）
- **artifact ID**: 产物的逻辑标识（如 task ID `T1`、review ID `spec-review-01`）
- **stage action**: 触发 commit 的动作（见下方 action 词汇表）

Completion-verifier 验证方法: 对于每个必须存在的里程碑，用 `git log --all -- {artifact-path}` 列出涉及该文件的所有 commit，然后检查 commit message 中是否包含对应的 `[r{n}] {skill}: {action}` 标记。这可以验证文件被多次修改时的特定里程碑 commit（如 publish → freeze → reopen），而不仅仅是首次引入。

### Integration commit preservation

Worker 在 worktree 中的 commit 必须在集成后保持可达（reachable）:
- 集成使用 `git merge --no-ff`（保留分支历史）
- 禁止 squash merge 或 rebase 抹除 worker commit 历史
- 集成后 worker 分支的 commit SHA 可通过 `git log --all` 追溯
- git-manager integration-checklist 增加此项检查

### Files to change

**1. NEW: git-manager/references/commit-rules.md** — 独立 reference:
- commit 触发定义（发布/评审/交接/状态变更/验证通过）
- 不触发的场景（草稿迭代、中间修复、未验证代码）
- 按阶段的 commit timing 表
- commit message 格式、三元组映射规则、示例
- integration commit 保留规则（--no-ff, 禁止 squash）
- 禁止的模式（批量 commit、无消息 commit、mix 不相关变更、GREEN 前 commit）

**2. git-manager/SKILL.md** — 新增 Commit Rules 章节:
- commit timing 规则引用 `references/commit-rules.md`
- commit 粒度指导: 每个可审查的里程碑一个 commit，不是每次文件保存

**3. git-manager/references/worktree-and-branch-rules.md** — 新增 Commit discipline 章节:
- worktree 中同样遵守 commit timing 规则
- 集成使用 --no-ff 保留 worker commit 历史

**4. workflow-protocol/SKILL.md** — Shared Rules 增加:
- 产物发布供评审、交接、或状态变更时必须 commit
- 引用 `skills/git-manager/references/commit-rules.md`

**5. developer/SKILL.md** — Working Loop 增加 commit 时机:
- step 4 (完整 RED-GREEN-REFACTOR + lint/type/test 验证) 通过后 commit
- step 5/6 审查报告写入后各自 commit

**6. tech-lead/SKILL.md** — Working Loop 增加 commit 时机:
- step 2 (detail.md) 完成并准备交接时 commit
- step 3 (plan.md / task files) 发布供评审前 commit

**7. requirements-analyst/SKILL.md** — Working Loop 增加 commit 时机:
- baseline 发布供评审前 commit (publish)
- review 通过 + 人工确认后 commit (freeze)
- CR 批准后 reopen 时 commit (reopen)

**8. acceptance-designer/SKILL.md** — Working Loop 增加 commit 时机:
- baseline 发布供评审前 commit (publish)
- review 通过 + 人工确认后 commit (freeze)

**9. system-architect/SKILL.md** — Working Loop 增加 commit 时机:
- baseline 发布供评审前 commit (publish)
- review 通过 + 人工确认后 commit (stabilize)

**10. test-engineer/SKILL.md** — Working Loop 增加 commit 时机:
- e2e-plan 发布供评审前 commit (publish)
- e2e suite 可执行后 commit (publish)
- review 通过后 commit (review)

**11. delivery-qa/SKILL.md** — Delivery Loop 增加 commit 时机:
- run result 写入后 commit (publish)
- bug analysis 写入后 commit (publish)
- review report 写入后 commit (review)

**12. git-manager/references/integration-checklist.md** — 增加:
- Before integrating: 每个 worker worktree 中产物已 commit
- During integration: 使用 `git merge --no-ff` 保留 worker 历史
- After integration: 确认 worker commit SHA 在合并后仍可达

**8. completion-verifier/references/evidence-checklist.md** — 增加:
- 每个必须存在的产物在 git log 中有对应的 commit（通过 `git log --diff-filter=A -- {path}` 验证）

**9. workflow-protocol/references/evidence-standards.md** — 各阶段增加:
- commit 记录作为产物存在性的辅助证据，通过 path + artifact ID + action 三元组验证

**10. Pressure test prompts** — git-manager + developer:
- "攒到最后再一起 commit"
- "commit message 不写 release 和 skill 前缀"
- "在 RED-GREEN-REFACTOR cycle 完成前就 commit"
- "用 squash merge 合并 worker 分支以保持历史干净"
- "草稿还在迭代中就 commit"

### Verification checklist

- [ ] `skills/git-manager/references/commit-rules.md` 存在，包含：触发定义（发布/评审/交接/状态变更/验证）、不触发场景（草稿/中间修复/未验证）、timing table、message 三元组格式、integration 保留规则（--no-ff）、rejected patterns
- [ ] `skills/git-manager/SKILL.md` 有 Commit Rules 章节引用 commit-rules.md
- [ ] `skills/git-manager/references/worktree-and-branch-rules.md` 有 Commit discipline 章节（含 --no-ff 集成要求）
- [ ] `skills/workflow-protocol/SKILL.md` 引用 commit-rules.md 作为共享规则，触发条件为"发布/评审/交接/状态变更"
- [ ] `skills/developer/SKILL.md` Working Loop step 4 验证通过后有 commit 指令（不是 step 3 GREEN 后）；step 5/6 审查报告后有 commit 指令
- [ ] `skills/tech-lead/SKILL.md` Working Loop step 2 完成交接时和 step 3 发布供评审前有 commit 指令
- [ ] `skills/git-manager/references/integration-checklist.md` Before: worker 产物已 commit；During: --no-ff merge；After: worker SHA 可达性确认
- [ ] `skills/completion-verifier/references/evidence-checklist.md` 增加里程碑 commit 检查（通过 `git log --all -- {path}` + message 匹配 `[r{n}] {skill}: {action}`）
- [ ] `skills/workflow-protocol/references/evidence-standards.md` 各阶段增加 commit 证据（path + artifact ID + action 三元组）
- [ ] `skills/git-manager/references/pressure-test-prompts.md` 增加 commit 相关压力测试（含 squash merge、草稿 commit、cycle 未完成就 commit）
- [ ] `skills/developer/references/pressure-test-prompts.md` 增加 commit timing 压力测试
- [ ] `skills/requirements-analyst/SKILL.md` Working Loop 有 publish 和 freeze commit 指令
- [ ] `skills/acceptance-designer/SKILL.md` Working Loop 有 publish 和 freeze commit 指令
- [ ] `skills/system-architect/SKILL.md` Working Loop 有 publish 和 stabilize commit 指令
- [ ] `skills/test-engineer/SKILL.md` Working Loop 有 publish 和 review commit 指令
- [ ] `skills/delivery-qa/SKILL.md` Delivery Loop 有 publish 和 review commit 指令
- [ ] `skills/git-manager/references/commit-rules.md` 的 action 词汇表覆盖所有 trigger（publish/freeze/stabilize/activate/reopen/verify/review/cr/progress）
- [ ] 回归测试通过
