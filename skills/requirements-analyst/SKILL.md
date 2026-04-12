---
name: requirements-analyst
description: Use when collecting, structuring, reviewing, or revising frozen-track requirements before acceptance design begins, including 需求澄清/需求评审/需求修改
---

# Requirements Analyst

## Overview

This skill owns workflow Steps 1-3: requirement clarification, structuring, review, revision, and freeze decisions for the requirement stage. It defines the requirement baseline that downstream acceptance, architecture, design, testing, and review work depend on.

## Support Files

Use these support assets for repeatable requirement checks:

- `references/output-artifacts.md`
- `references/boundary-examples.md`

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work.

## When to Use

Use this skill when the human wants to:

- collect or clarify requirements
- write or revise the configured requirements baseline from `paths.requirements`
- review requirement quality or output a requirement review report
- respond to requirement review findings
- reopen requirement work after an approved CR

Do not use this skill for acceptance design, architecture design, detailed design, coding, or E2E execution.

## Inputs

- human clarification messages
- configured product fact source from `sources.product_prd`
- optional raw workflow source from `sources.raw_workflow`
- any approved CR that reopens requirement work
- existing requirements baseline from `paths.requirements`, if present
- for r2+ releases: prior release requirements baseline as context (produce a standalone document for the current release)

## Outputs

- requirements baseline stored at `paths.requirements`
- requirement review reports stored under `<from paths.requirements parent>/reviews/req-review-{nn}.md`

## Working Loop

1. Clarify scope, goals, no-goals, and frozen boundary expectations with the human.
2. Structure the requirement tree and the cross-cutting requirement track.
3. Write or revise the configured requirements baseline from `paths.requirements`.
4. Produce a review report when asked to review the requirement document.
5. Revise from review findings.
6. Return to the human confirmation gate after review-driven edits.
7. Freeze the requirement document only after review passes and the human confirms alignment.

## Requirement Structuring Rules

- Default to at most three levels: first level = capability domain, second level = capability unit, third level = scoped deliverable or priority split.
- Simple capability units may stop at level two.
- Freeze the second-level item's capability boundary and acceptance responsibility.
- Third-level items express `must-have`, `later`, or `deferred` scope.
- Use release-qualified stable numbering: prefix each ID with the release tag, e.g., `r1-REQ-1`, `r1-REQ-1.2`, `r1-REQ-1.2.3`.
- Put cross-cutting concerns such as logging, observability, permissions, isolation, security, and governance in the `X` track.
- Keep `change_history` current on every edit.

## Freeze and Change Rules

- Small adjustments modify the frozen document in place and append `change_history`.
- Large adjustments require `<from paths.changes_dir>/cr-{nn}.md` and a return to the requirement clarification and review loop.
- A new third-level item under a frozen second-level item stays small only if the capability boundary and acceptance responsibility do not expand.
- If a requested change cannot be justified as a small adjustment, stop and route through the CR path rather than editing the frozen baseline directly.

## Review and Human Gate Rules

- Review reports must follow the shared review format from `workflow-protocol`.
- Review-driven edits do not go straight back to review; they must pass through human confirmation first.
- If the same requirement artifact or review / revise loop exceeds 3 rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- If the human says the understanding is still misaligned, continue clarification instead of freezing.
- Requirement review focuses on scope clarity, numbering stability, freeze boundaries, traceability, and whether cross-cutting concerns are separated correctly.

## Completion Checklist

- The requirements baseline at `paths.requirements` exists and uses release-qualified stable numbering (e.g., `r1-REQ-1.2`).
- Cross-cutting requirements are separated from the main tree.
- `change_history` is current.
- Any large adjustment has a corresponding approved CR.
- The review report exists when a review task was requested.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history).
