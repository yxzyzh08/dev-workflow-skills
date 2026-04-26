---
name: developer
description: Use when detailed design and implementation tasks are ready for code changes, test-first delivery, code review response, or code-level bug fixes, including 开发实现/代码修改/修Bug/修复测试/代码评审反馈处理
---

# Developer

## Overview

This skill owns workflow Steps 13-15 and Step 25 for implementation once scope and design are ready. It keeps code changes traceable to release artifacts, enforces strict TDD, and treats delivery-stage bug fixes as evidence-driven repair work rather than ad hoc guessing.

## Support Files

Use these support assets for recurring implementation checks:

- `references/output-and-evidence.md`
- `references/traceability-and-review.md`
- `references/boundary-examples.md`
- `references/tdd-rhythm.md`
- `references/two-stage-review.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work. Then read the current release's `<from paths.releases_dir>/r{n}/design/plan.md` and `<from paths.releases_dir>/r{n}/design/detail.md`. If plan.md uses split format, also read the relevant task file from `<from paths.releases_dir>/r{n}/design/tasks/T{n}.md` for the assigned task. If the request arrived without stable design context, scan `references/boundary-examples.md` before touching code.

## When to Use

Use this skill when the human or another agent hands you:

- a release task with stable design artifacts from `<from paths.releases_dir>/r{n}/design/plan.md` and `<from paths.releases_dir>/r{n}/design/detail.md` ready for implementation
- a code-review issue that requires code changes or review replies
- a Delivery QA bug report whose root cause is already classified as a code problem
- a scoped implementation request that must stay inside the approved release boundary

Do not start coding until the design contract and test scaffolding are clear enough to support TDD.

## Inputs

- `<from paths.releases_dir>/r{n}/design/plan.md`
- `<from paths.releases_dir>/r{n}/design/detail.md`
- configured architecture baseline from `paths.architecture`
- Delivery QA bug analysis when fixing E2E failures

## Outputs

- implementation code and corresponding automated tests inside the project source tree
- `<from paths.releases_dir>/r{n}/design/reviews/spec-review-{nn}.md` for each implemented task (mandatory stage 1 of two-stage review)
- `<from paths.releases_dir>/r{n}/design/reviews/code-review-{nn}.md` for each implemented task (mandatory stage 2 of two-stage review)
- command-backed verification evidence for lint, type checks, and tests

## Working Loop

1. Confirm the approved release design, relevant design contracts, and architecture constraints before coding.
2. Write the smallest failing test first and record the intended task / contract linkage with `references/output-and-evidence.md` — this is the RED phase per `references/tdd-rhythm.md`.
3. Run the failing test to confirm RED, implement the minimum code needed to pass (GREEN), then refactor if needed without changing behavior (REFACTOR). Keep the public contract aligned with `detail.md`.
4. Expand regression coverage when the work comes from Delivery QA, then run lint, type checks, and the relevant test suites.
5. Run spec compliance review per `references/two-stage-review.md`: verify implementation matches the task scope (from plan.md or the corresponding `tasks/T{n}.md`) and detail.md contracts. Record the result in `spec-review-{nn}.md`. If the review does not pass, repair and re-run before proceeding.
6. Run code quality review per `references/two-stage-review.md`: check architecture conformance, test quality, and maintainability. Record the result in `code-review-{nn}.md`. If the review does not pass, repair and re-run before proceeding.
7. Use `references/traceability-and-review.md` to record design-to-code-to-test linkage and prepare review artifacts.

## Development Rules

- Strict TDD follows the RED-GREEN-REFACTOR rhythm defined in `references/tdd-rhythm.md`. Every code change must pass through this cycle: write a failing test (RED), implement the minimum code to pass (GREEN), then clean up without changing behavior (REFACTOR). Skipping or reordering phases is not allowed.
- The detailed design from `<from paths.releases_dir>/r{n}/design/detail.md` and the architecture baseline from `paths.architecture` define the contract. If the design is missing or cannot be implemented as written, stop and escalate instead of silently diverging.
- Post-task verification is part of the work, not an optional cleanup step.
- Stay inside the approved scope unless an upstream change path is explicitly reopened.
- When executing the integration task (the last task in multi-task plans with shared interfaces): write integration tests that verify cross-module data flow and interface contracts from detail.md, not just unit-level behavior. Integration tests are developer-perspective cross-module verification, distinct from test-engineer's black-box E2E. The TDD rhythm still applies: write a failing integration test first (RED), wire modules to pass (GREEN), then refactor (REFACTOR).

## Review and Bug-Fix Rules

- Code review checks design conformance, test evidence, and scope discipline; use `references/traceability-and-review.md` as the default review lens.
- Delivery QA bug fixes rely on the provided bug analysis. Do not re-classify the failure or guess at upstream intent.
- If the same code-review, repair, or rework loop reaches 7 unresolved rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- If the reported issue actually exposes a design or architecture gap, route it back upstream instead of patching around the contract.
- Two-stage review is mandatory for each task: spec compliance (stage 1) must pass before code quality review (stage 2) begins. See `references/two-stage-review.md`.

## Completion Checklist

- Tests were written first, observed failing, and now pass for the targeted behavior.
- Each code change followed the RED-GREEN-REFACTOR cycle per `references/tdd-rhythm.md` with no phase skipped.
- Lint, type checks, and relevant test suites ran with zero failures and recorded evidence.
- Implementation matches `<from paths.releases_dir>/r{n}/design/detail.md` and respects the architecture baseline from `paths.architecture`.
- Review artifacts (`spec-review-{nn}.md` and `code-review-{nn}.md`) cite the touched modules or files and the test evidence for each implemented task.
- Delivery QA bug fixes cite the provided bug analysis and include the regression test.
- Spec compliance review (`spec-review-{nn}.md`) passed for each implemented task.
- Code quality review (`code-review-{nn}.md`) passed for each implemented task.
- If an integration task exists: integration tests pass with command output recorded, cross-module data flow verified against detail.md contracts.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history) if this work changes the stage status.
