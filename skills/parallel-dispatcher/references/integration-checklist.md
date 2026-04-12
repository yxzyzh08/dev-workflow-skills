# Parallel Dispatcher Integration Checklist

Use this file when the parallel batch is ready to merge back.

## Before integrating

- every worker reported completion or blocker status
- each task has diff and local verification evidence
- every worker has `spec-review-{nn}.md` (pass) and `code-review-{nn}.md` (pass) for their task
- integration order is documented
- unresolved conflicts or contract drifts are called out before the first merge

## During integration

- merge one branch at a time
- run the required verification gate after each merge
- stop the queue if regressions appear
- record conflict resolution notes before moving to the next branch

## After integration

- update the batch status summary
- confirm worktree cleanup is complete
- execute the integration task now (after all parallel branches merged and verified), following the `developer` skill's full working loop including TDD and two-stage review. If the plan legally omits the integration task (fully independent tasks with explicit exemption in plan.md), verify the exemption reason is present before skipping.
- refresh progress artifacts (`paths.progress` + `paths.progress_history`) per `workflow-protocol` only after the verified batch is clean (including integration task if applicable)
