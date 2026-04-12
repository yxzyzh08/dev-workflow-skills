# Two-Stage Review Protocol

Use this file after implementing a task to run spec compliance and code quality reviews.

## Stage 1: Spec Compliance Review

Purpose: verify the implementation matches the contracts defined in detail.md (the single authority) and the task scope declared in plan.md.

### Criteria

- every interface defined in detail.md for this task is implemented as specified (field names, types, behaviors) — detail.md is the authoritative contract, not task-step code in plan.md or `tasks/T{n}.md`
- every data model defined in detail.md for this task is implemented as specified (fields, constraints, defaults)
- the implementation scope matches the task scope declared in plan.md (or the corresponding `tasks/T{n}.md` in split format) — nothing missing, nothing added beyond scope
- output locations match those declared in plan.md
- each step's expected output has been achieved (steps may be inline in plan.md or in `tasks/T{n}.md`)
- if task-step code in plan.md or `tasks/T{n}.md` conflicts with detail.md contract, flag as a blocker — detail.md wins
- for the integration task specifically: verify that all prior task outputs are wired together, integration tests exercise cross-module data flow against detail.md contracts, and no module is left unconnected

### Output

Write `<from paths.releases_dir>/r{n}/design/reviews/spec-review-{nn}.md` with:

- reviewed task ID
- contract references checked (plan.md section, detail.md section)
- findings with severity (blocker or minor)
- verdict: pass or not pass

### Gate rule

Do not proceed to stage 2 until stage 1 verdict is pass. If findings are blocker-level, repair and re-run stage 1. Maximum 3 repair rounds before escalation per workflow-protocol loop stop rules.

## Stage 2: Code Quality Review

Purpose: verify the code is clean, tested, maintainable, and architecturally sound.

### Criteria

- code follows the architecture baseline from `paths.architecture`
- tests prove the intended contract, not accidental implementation details
- test coverage addresses the key paths and edge cases described in the detail.md contracts
- no dead code, no commented-out code, no debugging artifacts left behind
- naming, structure, and patterns are consistent with the existing codebase
- lint and type checks pass with zero warnings in the touched scope
- for the integration task: integration tests are meaningful cross-module verifications (not just smoke tests or duplicated unit tests), and they cover the key data flows identified in detail.md

### Output

Write `<from paths.releases_dir>/r{n}/design/reviews/code-review-{nn}.md` with:

- reviewed modules or files
- test evidence summary
- findings with severity (blocker or minor)
- verdict: pass or not pass

### Gate rule

If findings are blocker-level, repair and re-run stage 2. Maximum 3 repair rounds before escalation per workflow-protocol loop stop rules.

## Reviewer separation

When the implementation is authored by one agent, the review stages should be run by a separate agent or subagent when possible. If only one agent is available, the human may waive this separation explicitly.
