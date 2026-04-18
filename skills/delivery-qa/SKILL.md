---
name: delivery-qa
description: Use when E2E execution, failure analysis, fix-plan review, or final delivery reporting is needed before human acceptance, including E2E执行/失败分析/修复方案评审
---

# Delivery QA

## Overview

This skill owns workflow Steps 19-24 and Step 26 in the delivery-stage loop after E2E assets exist. It runs E2E checks, records evidence, classifies failures with evidence, enforces the two review gates, routes fixes to the right upstream owner, and publishes the final delivery summary for human acceptance.

## Support Files

Use these support assets during delivery work:

- `references/output-artifacts.md`
- `references/root-cause-and-routing.md`
- `references/review-gates.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work. If the request is close to a coding, test-authoring, or upstream-boundary decision, scan `references/boundary-examples.md` before taking ownership.

## When to Use

Use this skill when the human wants to:

- execute the E2E suite and capture a formal run result
- analyze a failed E2E result and classify the root cause as architecture, design, or code
- review whether a failure analysis is sound at Step 20
- review whether a proposed fix plan is actionable at Step 23
- generate the final delivery report after all E2E checks pass

Do not use this skill to modify production code, rewrite architecture or design, or author the E2E suite itself.

## Inputs

- acceptance baseline from `paths.acceptance`
- `<from paths.releases_dir>/r{n}/design/detail.md`
- architecture baseline from `paths.architecture`
- `<from paths.releases_dir>/r{n}/design/plan.md`
- E2E test code and its execution environment
- prior run results, bug analyses, or review findings when iterating on failed deliveries

## Outputs

- `<from paths.releases_dir>/r{n}/testing/results/run-{date}.md`
- `<from paths.releases_dir>/r{n}/testing/bug-analysis/bug-{nn}.md`
- `<from paths.releases_dir>/r{n}/testing/reviews/result-review-{nn}.md`
- `<from paths.releases_dir>/r{n}/testing/reviews/fix-review-{nn}.md`
- `<from paths.releases_dir>/r{n}/testing/results/final-delivery.md`

## Delivery Loop

1. Run the E2E suite and record the execution evidence using `references/output-artifacts.md`.
2. If the run fails, classify the root cause with `references/root-cause-and-routing.md` and write `bug-{nn}.md`.
3. Run the Step 20 review gate with `references/review-gates.md` and publish the review report. Stop here — do not revise yet.
4. Present the review findings to the human. If the analysis fails review, revise from accepted findings, then return to the review gate (step 3).
5. Once the root cause is accepted, route the fix to the correct owner and publish the Step 23 fix-plan review report. Stop here — present findings to the human before revising the fix plan.
6. At Step 24, if the fix plan passes, release work to the owning upstream skill; if it does not pass, revise the fix plan from accepted findings and return to step 5.
7. After the upstream fix lands and all E2E checks pass, write `final-delivery.md` as the cross-run delivery summary.

## Root-Cause Rules

- Classification must be evidence-based and grounded in acceptance, architecture, detailed design, and observed behavior.
- Every bug analysis records the failing case, reproduction steps, root cause, affected scope, and suggested fix direction.
- If the root cause is not clear after initial analysis, invoke `systematic-debugger` for deep evidence-first diagnosis before classifying. Delivery QA owns classification and routing; `systematic-debugger` owns the hypothesis-and-experiment loop.
- If repeated analysis still cannot justify a category, escalate to the human instead of forcing one.

## Review Gate Rules

- Step 20 and Step 23 are separate review gates and always produce different review files.
- If the same failure-analysis or fix-plan loop reaches 7 unresolved rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- Delivery QA may review and route, but it does not modify production code, architecture, design, or E2E assets directly.
- `final-delivery.md` summarizes the delivery outcome across runs; per-run `run-{date}.md` files remain the detailed records.

## Completion Checklist

- Each E2E execution round has a corresponding `<from paths.releases_dir>/r{n}/testing/results/run-{date}.md`.
- Every failed run has a `bug-{nn}.md` analysis with evidence-backed classification and routing.
- Step 20 and Step 23 each have their own review report when failure recovery was needed.
- Delivery QA did not modify source code, architecture, design, or E2E assets directly.
- `<from paths.releases_dir>/r{n}/testing/results/final-delivery.md` exists once all E2E checks pass.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history) when this stage reaches its latest verified state.
