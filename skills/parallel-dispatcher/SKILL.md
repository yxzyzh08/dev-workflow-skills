---
name: parallel-dispatcher
description: Use when developer work for the current release can split into independent plan tasks that should run in parallel under strict dependency and contract controls, including 并行任务拆分/并行开发分派/并行执行协调
---

# Parallel Dispatcher

## Overview

This skill coordinates parallel implementation only after task dependencies, ownership boundaries, and interface contracts are stable enough to keep concurrency safe. It prepares worker context packs, watches the batch, and hands integration back in serial order. Every worker must follow the `developer` skill's full working loop — TDD rhythm and two-stage review are not waived by parallel execution.

## Support Files

Use these support assets during dispatch and integration:

- `references/dispatch-prerequisites.md`
- `references/integration-checklist.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)
- `templates/dispatch-context-pack.md`

## First Step

Read `skills/workflow-protocol/SKILL.md`, then repository-root `workflow-project.yaml`. Resolve `paths.progress` and `paths.releases_dir`, then read the progress dashboard at `paths.progress` and the current release's plan/detail from `paths.releases_dir`. Before opening a parallel batch, use `references/dispatch-prerequisites.md` and scan `references/boundary-examples.md` if task ownership is unclear.

## When to Use

Use this skill when the human wants to:

- run multiple implementation tasks from the same release in parallel
- dispatch one worker per independent task with isolated worktrees
- keep shared contracts frozen while parallel work proceeds
- collect status from the batch and coordinate serial integration back to mainline

Do not use this skill when dependencies are unclear, contracts are still moving, or one worker can finish the scope faster with less coordination overhead.

## Inputs

- `<from paths.releases_dir>/r{n}/design/plan.md`
- `<from paths.releases_dir>/r{n}/design/detail.md`
- configured architecture baseline from `paths.architecture`
- configured acceptance baseline from `paths.acceptance` when user-visible contract promises matter
- frozen interface or data-contract definitions for the dispatched tasks
- human clarification on ownership boundaries when the plan is still ambiguous

## Outputs

- documented worker-to-task assignments and worktree paths
- dispatch context packs per worker
- batch status summary with completion, blockers, and local verification notes
- serial integration notes and progress artifact updates (dashboard + history per `workflow-protocol`) once the batch is verified clean

## Dispatch Loop

1. Use `references/dispatch-prerequisites.md` to confirm the candidate tasks are truly independent.
2. Group the tasks into parallel-safe sets, then prepare one `templates/dispatch-context-pack.md` per worker. Each context pack must include the TDD and two-stage review requirements from the `developer` skill.
3. Pair each worker with `git-manager` worktree isolation and the same canonical architecture / design baseline.
4. Monitor completion, blockers, and local verification notes without letting workers renegotiate contracts ad hoc. Confirm each worker has produced `spec-review-{nn}.md` (pass) and `code-review-{nn}.md` (pass) before accepting their work as complete.
5. Bring completed work back through the serial integration queue using `references/integration-checklist.md` and `completion-verifier` after each merge. The integration task (required for multi-task plans with shared interfaces, or exempted with explicit reason per Phase 8 rules) runs only after all parallel branches are merged and verified — it is never part of the parallel batch.

## Parallel Safety Rules

- Only explicitly independent tasks run in parallel.
- Shared interfaces and data contracts stay frozen during the batch unless the work is formally sent back upstream.
- Each worker uses a dedicated worktree and stays inside its owned write surface.
- If a dependency, overlap, or contract drift appears, stop parallel execution and re-evaluate the batch.
- Every worker follows the `developer` skill's full working loop: TDD rhythm per `skills/developer/references/tdd-rhythm.md` and two-stage review per `skills/developer/references/two-stage-review.md`. Parallel execution does not waive any quality gate.
- Workers should cross-review each other's work when possible (worker A reviews worker B and vice versa). If only one agent is available per task, the human may waive reviewer separation explicitly.

## Integration Rules

- Integrate branches serially even when implementation ran in parallel.
- After each merge, run the required verification gate before touching the next branch.
- If a merge introduces regressions, pause the queue and route the issue back to the responsible worker instead of continuing blindly.
- For multi-task plans with shared interfaces or data flow, the integration task must exist and executes only after all parallel branches are merged and verified — it is never dispatched as part of the parallel batch. For fully independent multi-task plans, the integration task may be omitted only if plan.md states the exemption reason explicitly.

## Completion Checklist

- Each worker has a documented task, context pack, and worktree path.
- Batch monitoring records completion or blocker status for every worker.
- Integration notes record merge order, conflicts, and verification outcomes.
- No worker changed a frozen contract without an approved upstream re-entry.
- Every worker has `spec-review-{nn}.md` (pass) and `code-review-{nn}.md` (pass) for their task before integration begins.
- Integration task requirement is satisfied: either the integration task ran after all parallel merges and its own two-stage review passed, or plan.md contains an explicit exemption reason for fully independent tasks.
- Progress artifacts reflect the verified batch state per `workflow-protocol` (dashboard + history).
