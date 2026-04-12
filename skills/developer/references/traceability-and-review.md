# Developer Traceability And Review

Use this file to keep implementation tied to design.

## Traceability chain

- `detail.md` contract (single authority) -> task steps in `plan.md` or `tasks/T{n}.md` (implementation referencing detail.md) -> code path -> test evidence
- when verifying implementation, check against `detail.md` contracts, not against task-step code in `plan.md` or `tasks/T{n}.md` — if they conflict, detail.md wins
- if the task came from Delivery QA, append the bug analysis path to the chain

## Review focus

Code review should check:

- conformance to interface and data-model definitions
- whether tests prove the intended contract instead of an accidental implementation detail
- whether the change stayed inside the approved scope
- whether lint, type checks, and relevant test suites were actually run

## Two-stage review linkage

The review focus above applies to the code quality stage (stage 2). Spec compliance (stage 1) has its own criteria defined in `two-stage-review.md`. Both stages produce on-disk review artifacts:

- stage 1: `spec-review-{nn}.md` under `<from paths.releases_dir>/r{n}/design/reviews/`
- stage 2: `code-review-{nn}.md` under `<from paths.releases_dir>/r{n}/design/reviews/`

The full traceability chain is: detail.md contract (single authority) -> task steps in plan.md or tasks/T{n}.md -> code path -> test evidence -> spec-review -> code-review.
