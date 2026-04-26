---
name: systematic-debugger
description: Use when encountering bugs, test failures, or anomalous behavior that demands evidence-first root-cause diagnosis before proposing a fix, including 问题排查/根因定位/异常分析
---

# Systematic Debugger

## Overview

Systematic Debugger is the diagnosis-first skill for failures, regressions, and anomalous behavior. It drives a hypothesis-and-experiment loop, records the evidence trail, and routes the confirmed issue to the right owner instead of guessing or patching blindly.

## Support Files

Use these support assets during debugging and handoff:

- `references/debug-loop-and-evidence.md`
- `references/routing-and-escalation.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)
- `templates/bug-analysis-template.md`

## First Step

Read `skills/workflow-protocol/SKILL.md`, then repository-root `workflow-project.yaml`. Resolve `paths.progress`, then read the progress dashboard at `paths.progress`. Before proposing any fix direction, use `references/debug-loop-and-evidence.md` and scan `references/boundary-examples.md` if the failure might already belong to another stage.

## When to Use

Use this skill whenever the human or another agent reports:

- a failing test, run, or monitoring alert that needs diagnosis first
- a stack trace, error log, or unexpected behavior without a stable root cause
- a regression that must be narrowed through evidence
- a request for a structured bug analysis before someone chooses the fix owner

Do not use this skill to skip straight to implementation or to fabricate a classification without enough evidence. When invoked by `delivery-qa`, this skill provides the deep diagnosis; classification and routing remain with `delivery-qa`.

## Inputs

- failing test output, logs, traces, screenshots, or monitoring evidence
- reproduction steps from humans or harnesses
- relevant architecture, design, and acceptance baselines
- existing run results or prior bug-analysis artifacts when iterating

## Outputs

- `<from paths.releases_dir>/r{n}/testing/bug-analysis/bug-{nn}.md`
- review-side bug analysis inputs when Delivery QA or another stage needs a diagnosis report
- explicit routing notes to `system-architect`, `tech-lead`, `developer`, or the human when the root-cause layer is confirmed

## Debugging Loop

1. State the expected behavior, actual behavior, and current narrowest hypothesis.
2. Use `references/debug-loop-and-evidence.md` to design and run the next smallest experiment.
3. Record what the evidence confirmed or excluded.
4. Repeat until the root cause is strong enough to route confidently.
5. Write the report with `templates/bug-analysis-template.md`, then hand it off using `references/routing-and-escalation.md`.

## Debugging Rules

- Do not propose or implement fixes before the evidence supports the diagnosis.
- Prefer one hypothesis at a time over shotgun experimentation.
- If the same bug-analysis or diagnosis loop reaches 7 unresolved rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- If the evidence points to architecture, design, or product ambiguity, route or escalate instead of forcing a code-level answer.
- If evidence remains insufficient after another pass, stop and escalate rather than guessing.

## Completion Checklist

- A written bug analysis exists with failing case, repro steps, evidence, root cause, affected scope, and fix direction.
- The evidence trail is explicit enough that another reviewer can follow it.
- The confirmed layer is routed to the correct owner or escalated to the human.
- No fix-first shortcut replaced the diagnosis loop.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history) only if the workflow allows that state change.
