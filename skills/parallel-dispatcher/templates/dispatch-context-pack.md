# Parallel Dispatch Context Pack

Use this template when assigning one worker to one parallel task.

## Task Identity

- release: `r{n}`
- task id: `task-{nn}`
- task file: `<from paths.releases_dir>/r{n}/design/tasks/T{nn}.md` (if split format) or inline in plan.md
- worker owner: `<agent-name>`
- worktree path: `.worktree/r{n}/task-{nn}-{slug}`

## Scope

- objective:
- owned files or modules:
- output locations:
- out-of-scope areas:

## Shared Baseline

- architecture references:
- detail design sections:
- acceptance references:
- frozen interfaces or contracts:

## Local Verification

- required commands:
- expected artifacts:
- report-back format:

## Quality Requirements

Every worker must follow the `developer` skill's full working loop:

- TDD rhythm: RED-GREEN-REFACTOR per `skills/developer/references/tdd-rhythm.md` — no phase skipping
- Two-stage review: spec compliance (stage 1) then code quality (stage 2) per `skills/developer/references/two-stage-review.md`
- Reviewer separation: another worker or dedicated reviewer should run the two-stage review; self-review requires explicit human waiver
- Produce `spec-review-{nn}.md` and `code-review-{nn}.md` in the review directory before reporting task complete

## Escalate When

- dependency or contract mismatch appears
- another worker needs the same write area
- local verification fails and the cause is unclear
