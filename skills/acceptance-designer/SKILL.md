---
name: acceptance-designer
description: Use when turning frozen requirements into human E2E acceptance documents and acceptance review cycles
---

# Acceptance Designer

## Overview

This skill owns workflow Steps 4-6: turning frozen requirements into the human E2E acceptance baseline. It defines what must be formally accepted before the project can move downstream into implementation and delivery.

## Support Files

Use these support assets for repeatable acceptance checks:

- `references/output-artifacts.md`
- `references/boundary-examples.md`

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work.

## When to Use

Use this skill when the human wants to:

- write or revise the configured acceptance baseline from `paths.acceptance`
- design the human E2E acceptance surface from frozen requirements
- review acceptance quality or output an acceptance review report
- respond to acceptance review findings
- reopen acceptance work after an approved CR

Do not use this skill for requirement clarification, architecture design, detailed design, coding, or E2E execution.

## Inputs

- configured requirements baseline from `paths.requirements`
- human alignment feedback
- any approved CR that reopens acceptance work
- existing acceptance baseline from `paths.acceptance`, if present
- for r2+ releases: prior release requirements baseline as optional context

## Outputs

- acceptance baseline stored at `paths.acceptance`
- acceptance review reports stored under `<from paths.acceptance parent>/reviews/acc-review-{nn}.md`

## Working Loop

1. Read the frozen requirements and identify the formal acceptance surface.
2. Write acceptance preparation work, main-flow user stories, and independent formal acceptance items.
3. Add special formal acceptance items only when non-normal paths are product commitments, governance gates, or recovery capabilities.
4. Produce a review report when asked to review the acceptance document.
5. Revise from review findings.
6. Return to the human confirmation gate after review-driven edits.
7. Freeze the acceptance document only after review passes and the human confirms alignment.

## Acceptance Content Rules

- Human E2E acceptance defaults to the normal main flow only.
- Do not automatically expand the document with exception paths.
- Include non-normal paths only when they are product commitments, governance gates, or recovery capabilities.
- Acceptance items must be tool-checkable rather than purely subjective.
- UI flows are described in Markdown, not HTML or prototypes.
- Every acceptance item must trace back to a requirement ID or an `X` track ID.
- Each acceptance case carries a release tag, e.g., `(r1)` for cases originating in release 1. When the current release modifies a prior case, update the case in place and change its tag to show origin and latest release only, e.g., `(r1→r3 modified)`. Do not chain intermediate releases (NOT `(r1→r2→r3 modified)`). Tags go on individual cases, not on group headers.
- Independent acceptance items may cover areas such as logs, AI interaction monitoring, or workflow monitoring when they are formal acceptance scope.

## Upstream Change Handling

- If acceptance work finds only a small upstream clarification, update the frozen requirements in place with `change_history`.
- If acceptance work finds a large upstream change, create or continue `<from paths.changes_dir>/cr-{nn}.md`, return to the requirement stage, then re-enter acceptance after the upstream loop completes.
- Do not silently widen requirement scope from inside the acceptance document.

## Review and Human Gate Rules

- Review reports must follow the shared review format from `workflow-protocol`.
- Review-driven edits must go back to the human for alignment before another review round.
- If the same acceptance artifact or review / revise loop exceeds 3 rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- If the human rejects the current acceptance framing, continue refinement instead of freezing.
- Acceptance review focuses on tool-checkability, requirement traceability, formal inclusion of non-normal paths, and whether the document stays inside the frozen requirement boundary.

## Completion Checklist

- The acceptance baseline at `paths.acceptance` exists.
- Main-flow stories, preparation work, and independent acceptance items are present.
- Every formal acceptance item traces to a requirement or `X` ID.
- Non-normal paths appear only when they meet the formal inclusion rule.
- The review report exists when a review task was requested.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history).
