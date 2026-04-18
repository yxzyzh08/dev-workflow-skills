---
name: system-architect
description: Use when frozen requirements and acceptance baselines need to be translated into system architecture or architecture reviews, including 架构设计、架构评审、架构基线修订
---

# System Architect

## Overview

This skill owns workflow Steps 7-9: the transition from frozen requirements and acceptance baselines into a stable system architecture. It defines the architecture baseline, protects its fitness to scope, keeps the baseline consumable for downstream design and development, and handles architecture-side updates triggered by reviews or Delivery QA findings.

## Support Files

Use these support assets instead of overloading the main skill body:

- `references/output-artifacts.md`
- `references/architecture-shape.md`
- `references/review-focus.md`
- `references/impact-analysis-checklist.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work. Before taking ownership of a borderline request, scan `references/boundary-examples.md`.

## When to Use

Use this skill when the human wants to:

- design or revise the configured architecture baseline from `paths.architecture` using frozen requirements and acceptance baselines
- expose the capability structure, product surface, authority model, or decomposition rules that downstream design / development will rely on
- capture business architecture, technical architecture, tech choices, horizontal capabilities, and platform foundations
- review architecture quality or output review reports under `<from paths.architecture parent>/reviews/arch-review-{nn}.md`
- respond to architecture review findings or Delivery QA evidence that points to architecture

Do not use this skill for requirement gathering, acceptance design, detailed design, coding, or E2E execution.

## Inputs

- configured requirements baseline from `paths.requirements`
- configured acceptance baseline from `paths.acceptance`
- existing architecture baseline from `paths.architecture` when iterating
- human alignment feedback or approved CRs that reopen architecture work
- Delivery QA diagnostics that surface architecture as a root cause

## Outputs

- architecture baseline stored at `paths.architecture` (status: `stable`, with `change_history` kept current)
- architecture review reports stored under `<from paths.architecture parent>/reviews/arch-review-{nn}.md`
- impact analysis + fix-task list when architecture changes because of review findings or Delivery QA evidence

## Working Loop

1. Confirm the frozen capability boundaries and read the upstream baselines before proposing any architecture work.
2. Draft or revise the architecture baseline using `references/output-artifacts.md` and `references/architecture-shape.md` so the document covers all required architecture dimensions, exposes a compact capability/navigation layer, and keeps traceability to requirement / acceptance IDs.
3. Review the architecture with `references/review-focus.md`, then publish `arch-review-{nn}.md`. The review must check not only architectural correctness, but also whether downstream design / development can locate the relevant capability slice without rereading the whole baseline. Stop here — do not revise yet.
4. Present review findings to the human. The human decides which findings to accept and whether to adjust the revision direction.
5. Revise from accepted findings, update `change_history`, and present the revised baseline to the human for alignment confirmation. Repeat the review loop (steps 3-5) if needed.
6. If Delivery QA evidence points to architecture, run `references/impact-analysis-checklist.md`, decide whether a CR is required, publish the fix-task list, and then re-enter the review loop.

## Architecture Rules

- Keep the architecture baseline at `paths.architecture` status `stable`; the baseline is considered current and authoritative but stays open to evolution through review or approved change flow, not by switching to `frozen`.
- Every stable architecture baseline must cover business architecture, technical architecture, tech choices, horizontal capabilities, platform foundations, and an explicit capability registry or equivalent exposed-capability section.
- The architecture must include a compact navigation layer near the front (for example, a capability registry, product-surface summary, or decomposition rule) so downstream design / development can find the relevant slice without rereading the entire document.
- When the system exposes multiple human or machine surfaces (for example CLI, API, console, files, gates, or documents), those surfaces must be described explicitly instead of being buried inside component prose.
- When runtime authority, integration contracts, storage authority, or file contracts are architectural commitments, document them explicitly rather than leaving them implicit for downstream design to infer.
- Preserve landing space for `later` / `deferred` work and likely third-level expansions without silently widening the current frozen scope.
- Architecture `change_history` entries should reference the triggering release (e.g., "r2: added batch import module").

## Review and Change Rules

- Use `references/output-artifacts.md` as the minimum artifact contract and `references/review-focus.md` as the default review lens.
- Human alignment is a mandatory gate before the architecture baseline is treated as stable after creation or revision.
- If the same architecture review / revise loop reaches 7 unresolved rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- Architecture updates triggered by review findings or Delivery QA evidence must include impact analysis and a fix-task list.
- If the change exceeds a small adjustment, route it through `<from paths.changes_dir>/cr-{nn}.md` before treating the revised architecture as valid.

## Completion Checklist

- The architecture baseline at `paths.architecture` exists, remains `stable`, and records `change_history`.
- The baseline contains a capability registry or equivalent exposed-capability section that downstream stages can use as an index.
- The baseline makes product surfaces, authority boundaries, and decomposition/navigation rules explicit enough for downstream design / implementation handoff.
- Architecture review reports under `<from paths.architecture parent>/reviews/arch-review-{nn}.md` exist for each formal review cycle.
- Architecture reviews check current fit, future evolution readiness, and downstream navigability.
- Impact analysis + fix-task list exist for architecture changes driven by review or Delivery QA findings.
- Progress artifacts reflect the latest architecture state per `workflow-protocol` (dashboard + history).
