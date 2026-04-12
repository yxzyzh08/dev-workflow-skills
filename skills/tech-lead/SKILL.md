---
name: tech-lead
description: Use when architecture, requirements, and acceptance baselines must be turned into release design, development plan, and detailed design
---

# Tech Lead

## Overview

Tech Lead owns workflow Steps 10-12: bridging stable upstream baselines with execution by producing the release design, sequencing work, and publishing field-level detailed design. `detail.md` is the single authority for interface and data-model contracts; `plan.md` tasks either contain or point to step-level implementation code that references `detail.md` sections instead of duplicating contract definitions.

## Support Files

Use these support assets when the main skill body is not enough:

- `references/output-artifacts.md`
- `references/traceability-rules.md`
- `references/impact-analysis-checklist.md`
- `references/boundary-examples.md`
- `references/step-decomposition-rules.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work. Confirm no blocking CR affects the current release path, then scan `references/boundary-examples.md` if the request is close to another stage boundary.

## When to Use

Use this skill when the human asks you to:

- break frozen requirements, acceptance, and architecture into a concrete release design
- produce `<from paths.releases_dir>/r{n}/design/plan.md` and `<from paths.releases_dir>/r{n}/design/detail.md`
- review or adjust the release plan or detailed design
- respond to design review findings or Delivery QA evidence that points to design
- declare dependencies, parallel task groups, and mappings from tasks to outputs before handing work to developers or test engineers

Do not use this skill for writing code, classifying delivery failures, or authoring architecture-level artifacts.

## Inputs

- configured requirements baseline from `paths.requirements`
- configured acceptance baseline from `paths.acceptance`
- configured architecture baseline from `paths.architecture`
- human guidance on release goals, known dependencies, and high-risk areas
- approved CRs that reopen the release plan or detailed design

## Outputs

- `<from paths.releases_dir>/r{n}/design/plan.md`
- `<from paths.releases_dir>/r{n}/design/detail.md`
- `<from paths.releases_dir>/r{n}/design/tasks/T{n}.md` (split format only, one per task)
- `<from paths.releases_dir>/r{n}/design/reviews/design-review-{nn}.md`
- impact analysis + fix-task list when design updates respond to review or Delivery QA findings

## Working Loop

1. Align on the current release goal and read the frozen requirements, acceptance, and architecture baselines.
2. Draft `<from paths.releases_dir>/r{n}/design/detail.md` first — define interfaces, data models, and validation/error contracts using `references/output-artifacts.md` as the minimum artifact contract. detail.md must be complete enough to serve as the contract authority before task steps in plan.md or `tasks/T{n}.md` can reference it.
3. Draft `<from paths.releases_dir>/r{n}/design/plan.md` — declare tasks, dependencies, and output locations, then apply `references/step-decomposition-rules.md` to decompose each task into implementation-ready steps that reference detail.md sections. If planning reveals missing contracts, update detail.md first, then continue plan.md. After all steps are written, apply the single-file vs split format rule from `references/step-decomposition-rules.md`: if tasks > 3 or any coherent task needs more than 10 steps, move step decompositions to `<from paths.releases_dir>/r{n}/design/tasks/T{n}.md` and keep plan.md as a lightweight index.
4. Apply `references/traceability-rules.md` so task slicing, dependencies, output mapping, interfaces, and data models stay linked.
5. Review the design with `references/output-artifacts.md` and `references/traceability-rules.md`, then publish `design-review-{nn}.md`. Stop here — do not revise yet.
6. Present review findings to the human. The human decides which findings to accept and whether to adjust the revision direction.
7. Revise from accepted findings, update `change_history`, and present the revised design to the human for confirmation before releasing downstream work. Repeat the review loop (steps 5-7) if needed.
8. If review findings or Delivery QA evidence force design updates, run `references/impact-analysis-checklist.md`, publish repair tasks, and then return to the review loop.

## Planning and Detail Rules

- `<from paths.releases_dir>/r{n}/design/detail.md` is the single authority for interface signatures, data-model field definitions, and validation/error contracts. All other artifacts reference it rather than redefining the same contracts.
- `<from paths.releases_dir>/r{n}/design/plan.md` must declare which requirement / acceptance items the release implements, record dependencies, parallel groups, and output locations per task.
- Every task must have a step-level decomposition with 2-5 minute steps. Each step specifies: the action in one sentence, complete implementation code or content (copy-paste ready), and expected output. Steps that implement an interface or data model must cite the corresponding `detail.md` section rather than redefining the contract inline. No step may contain unresolved or deferred content. Steps live inline in plan.md (single-file format) or in `<from paths.releases_dir>/r{n}/design/tasks/T{n}.md` (split format) per `references/step-decomposition-rules.md`.
- When a task is documentation-heavy, the code field in each step may contain file content or configuration text but must still be complete.
- Developers and test engineers should be able to follow the execution path recorded in plan.md — inline steps in single-file format or referenced `tasks/T{n}.md` files in split format — and consult detail.md as the contract reference without inventing missing details in either document.
- When plan.md contains more than one task and tasks have shared interfaces or data flow, the last task must be an integration task. The integration task wires all prior task outputs together, writes integration tests that verify cross-module data flow and interface contracts from detail.md, and produces integration verification evidence. Single-task plans do not need an integration task. Multi-task plans where tasks are fully independent (no shared interfaces or data flow) may omit the integration task if plan.md states the exemption reason explicitly.

## Review and Change Rules

- Use `references/output-artifacts.md` to judge completeness and `references/traceability-rules.md` to judge internal consistency.
- Human confirmation is a mandatory gate before plan or detail is treated as stable for downstream work.
- If the same design artifact loop exceeds 3 rounds without convergence, stop and escalate to the human per `workflow-protocol`.
- Review cycles end only after findings are written down and the human confirms the revised understanding.
- Design changes triggered by review or Delivery QA evidence must include impact analysis and concrete repair tasks.

## Completion Checklist

- `<from paths.releases_dir>/r{n}/design/detail.md` defines interfaces and data models field by field without placeholders and serves as the single contract authority.
- `<from paths.releases_dir>/r{n}/design/plan.md` declares implemented requirement / acceptance IDs, records tasks, dependencies, parallelization notes, and output mappings. Each task's steps reference `detail.md` for contract definitions instead of duplicating them.
- `<from paths.releases_dir>/r{n}/design/reviews/design-review-{nn}.md` records the review loops.
- Required impact analysis + fix-task lists exist when design changes were forced mid-stream.
- Progress artifacts reflect the latest release design status per `workflow-protocol` (dashboard + history).
- Every task has step-level decomposition with code/commands and expected output (inline in plan.md or in `tasks/T{n}.md`); no step contains unresolved or deferred content.
- Multi-task plans with shared interfaces or data flow include an integration task as the last task. Multi-task plans with fully independent tasks (no shared interfaces or data flow) may omit it only if plan.md states the exemption reason. Single-task plans do not need an integration task.
