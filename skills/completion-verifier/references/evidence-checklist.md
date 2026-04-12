# Completion Verifier Evidence Checklist

Use this file before writing a PASS or NOT PASS verdict.

## Artifact evidence

- every required output path exists
- review reports required by the stage exist
- for implementation tasks: both `spec-review-{nn}.md` (spec compliance) and `code-review-{nn}.md` (code quality) exist with `pass` verdict; spec compliance must have passed before code quality review was run
- for multi-task implementations with shared interfaces or data flow: an integration task must exist with passing integration test evidence (exemption is not allowed). For multi-task implementations with fully independent tasks: an integration task exists, or plan.md contains an explicit exemption reason. Single-task implementations do not require an integration task.
- for parallel batches: every worker has independent `spec-review-{nn}.md` (pass) and `code-review-{nn}.md` (pass) for their task — parallel execution does not waive any review gate
- for design tasks: every task has step-level decomposition with action, code/content, and expected output per step — either inline in `plan.md` (single-file format) or in `tasks/T{n}.md` files (split format); if split format, verify every task listed in plan.md has a corresponding task file
- document metadata matches the claimed state

## TDD evidence (implementation tasks)

- each code change has recorded RED evidence: failing test name, run command, and failure output captured before production code was written
- each code change has recorded GREEN evidence: passing test command and output after minimal implementation
- no production code was written without a prior failing test

## Command evidence

- required verification commands are listed explicitly
- exit status is known
- summary lines or log excerpts are captured
- failing commands are recorded as blockers, not omitted

## Progress evidence

- progress dashboard at `paths.progress` matches the verified artifact set
- no stage is marked `done` before evidence is complete
- state changes are recorded in both `paths.progress` and `paths.progress_history` per `workflow-protocol`
