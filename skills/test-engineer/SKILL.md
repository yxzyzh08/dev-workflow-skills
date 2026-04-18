---
name: test-engineer
description: Use when frozen acceptance and detailed design must be turned into black-box E2E plans, automated setup, and E2E review artifacts
---

# Test Engineer

## Overview

This skill owns workflow Steps 16-18: turning the frozen acceptance baseline and detailed design into black-box E2E assets. It owns the E2E plan, automated setup, executable suite, and review loop that proves the formal acceptance scope is covered without leaning on implementation internals.

## Support Files

Use these support assets when planning, reviewing, or auditing E2E work:

- `references/output-artifacts.md`
- `references/coverage-and-setup.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work. If the request arrived before acceptance or detailed design is stable, scan `references/boundary-examples.md` before taking ownership.

## When to Use

Use this skill when the human wants to:

- convert the acceptance baseline from `paths.acceptance` and `<from paths.releases_dir>/r{n}/design/detail.md` into E2E plans and E2E code
- automate preparation such as browser, environment, account, dependency, or data setup
- review existing E2E plans or E2E code and write `<from paths.releases_dir>/r{n}/testing/reviews/e2e-review-{nn}.md`
- revise E2E assets after review findings

Do not use this skill for writing production code, reading implementation internals, or classifying failed E2E runs after execution.

## Inputs

- acceptance baseline from `paths.acceptance`
- `<from paths.releases_dir>/r{n}/design/detail.md`
- existing `<from paths.releases_dir>/r{n}/testing/e2e-plan.md`, E2E code, or prior review findings when iterating
- human constraints about environments, browsers, accounts, or execution platforms

## Outputs

- `<from paths.releases_dir>/r{n}/testing/e2e-plan.md`
- E2E test code in the project testing area
- `<from paths.releases_dir>/r{n}/testing/reviews/e2e-review-{nn}.md`

## Working Loop

1. Read the frozen acceptance baseline and detailed design, then map every formal acceptance item that needs E2E coverage.
2. Draft `e2e-plan.md` using `references/output-artifacts.md` and `references/coverage-and-setup.md` so coverage, setup, expected observations, and cleanup are explicit.
3. Automate the required environment preparation, then implement the E2E suite while preserving the black-box rule.
4. Review the plan and suite, then publish `e2e-review-{nn}.md`. Stop here — do not revise yet.
5. Present review findings to the human. The human decides which findings to accept and whether to adjust the revision direction.
6. Revise from accepted findings and present the revised plan and suite to the human for confirmation. Repeat the review loop (steps 4-6) if needed until the suite is executable end to end.

## E2E Design Rules

- Keep a black-box viewpoint: assertions come from acceptance behavior and design contracts, not implementation internals.
- Every formal acceptance item needs traceable E2E coverage.
- Setup, dependency installation, seed data, and cleanup must be automated enough for repeatable runs.
- The suite should stay aligned with the formal acceptance scope: main flows by default, non-normal paths only when the acceptance baseline explicitly includes them.

## Review Rules

- Use `references/output-artifacts.md` to judge completeness and `references/coverage-and-setup.md` to judge coverage and automation sufficiency.
- Review findings must flow back into the plan, setup assets, or suite before the next review round.
- If the same E2E review / revise loop reaches 7 unresolved rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- If the review exposes an upstream ambiguity in acceptance or detailed design, stop and route it upstream instead of guessing the behavior.

## Completion Checklist

- `<from paths.releases_dir>/r{n}/testing/e2e-plan.md` exists and traces each planned case to requirement or acceptance IDs.
- Automated setup, dependency installation, data preparation, and cleanup are part of the runnable E2E flow.
- The E2E suite remains black-box and does not depend on implementation code.
- `<from paths.releases_dir>/r{n}/testing/reviews/e2e-review-{nn}.md` exists when review was requested, and findings were incorporated.
- Every formal acceptance item has corresponding E2E coverage.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history) when this skill's work is complete.
