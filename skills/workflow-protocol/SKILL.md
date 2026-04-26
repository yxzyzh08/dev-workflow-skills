---
name: workflow-protocol
description: Use when working inside workflow skills and the task must follow shared document, review, freeze, and Change Request rules, including 冻结规则/评审规则/CR流程
---

# Workflow Protocol

## Overview

This is the shared contract for all repository workflow skills. Every stage skill, cross-cutting skill, and meta skill reads this file first, then reads repository-root `workflow-project.yaml`, resolves the configured paths and sources, reads the progress dashboard, and only then starts stage-specific work.

## Support Files

Use these quick references for repeatable protocol checks:

- `references/project-config-contract.md`
- `references/review-report-rules.md`
- `references/frontmatter-and-state-flow.md`
- `references/change-request-and-sync-status.md`

This file keeps only the binding shared rules. Repeated checklists, field schema details, YAML examples, and status semantics belong in the reference files above.

## Startup Checklist

1. Read this file completely.
2. Read repository-root `workflow-project.yaml`.
3. Resolve `paths.progress`, `paths.progress_history`, `paths.changes_dir`, and configured `sources.*`.
4. Read the progress dashboard at `paths.progress` before doing stage work. If it does not exist yet, treat the repository as uninitialized and route to the startup path instead of pretending the current stage is known. Do not read `paths.progress_history` during normal routing — it is an append-only log for audit purposes.
5. If `project.current_release` is configured, verify that `paths.requirements` and `progress.md` `current_release` are consistent. If they conflict, stop and warn the human — `project.current_release` is the single source of truth.
6. Check whether a pending or approved CR under `<from paths.changes_dir>` affects the current path.
7. Confirm the authoritative sources before writing or reviewing:
   - `sources.product_prd` (if configured)
   - `sources.raw_workflow` (if configured)
   - `sources.skill_design_spec` (if configured)
   - baselines resolved from `paths.requirements`, `paths.acceptance`, `paths.architecture`, and `paths.progress`

## Shared Collaboration Rules

- Important outputs must be written to disk; do not claim completion only in chat.
- Review, recheck, acceptance, audit, and similar requests must create a review report before any summary.
- Repository documents default to `workflow.default_doc_language` when configured; otherwise default to Chinese unless the human asks otherwise.
- Use the frozen skill IDs from the design spec when naming or referencing skills.
- Treat the progress dashboard at `paths.progress` as the navigation page, but if it conflicts with authoritative documents or actual files, fix the dashboard to match reality.
- When a reviewed artifact exposes an `author`, the `reviewer` should be different unless the human explicitly waives that separation.
- Do not skip the human gates for requirement alignment, acceptance alignment, major change approval, or final delivery approval.

## Progress Update Hook (mandatory, all skills)

Every skill must execute this hook **after completing any round of work that changes workflow state** (creating/modifying artifacts, producing reviews, fixing review findings, confirming gates). This is not optional and must not be deferred to "later".

1. Update `<from paths.progress>` (dashboard): refresh stage status table, blocker list, and next step to reflect current reality.
2. Append to `<from paths.progress_history>` (history): add a timestamped one-line entry (`- HH:mm actor: what changed`) under today's date heading.

Both files must be updated in the same round — updating one without the other is incomplete. If you are unsure whether your work constitutes a state change, update anyway; a redundant progress entry costs less than a missing one.

## Document and Metadata Rules

- Content documents use frontmatter fields such as `title`, `type`, `created`, `status`, `last_modified`, `author`, `upstream`, `downstream`, and `change_history`.
- Review documents use `target` and `reviewer`; the conclusion stays in the body and remains binary: pass or not pass.
- Change Request documents use `targets`, `change_category`, `decision`, `minimum_return_steps`, and `downstream_impact`.
- `doc-guardian` and `completion-verifier` should use `references/frontmatter-and-state-flow.md` as the executable schema baseline for metadata checks.
- Code artifacts do not use frontmatter; trace them through `plan.md`, review reports, and validation command output, following the code-artifact tracking rules in `references/frontmatter-and-state-flow.md`.
- Code review reports must cite the reviewed module, directory, or file list; do not write vague statements such as "reviewed the code".

## State Flow and Freeze Rules

- `draft -> active`: formal writing begins.
- `active -> frozen`: review passes and content becomes the frozen baseline.
- `active -> stable`: only architecture uses this path; `stable` means the baseline is considered current and authoritative but remains open to evolution through review or approved change flow.
- `frozen -> active`: only allowed after a human-approved CR.
- Small adjustments update the frozen document in place and append `change_history`.
- Large adjustments require a CR and a return to the upstream review loop.
- For requirements, adding a third-level item under a frozen second-level item is still a small adjustment only when the capability boundary and acceptance responsibility do not expand.

## Change Request Rules

- Create `<from paths.changes_dir>/cr-{nn}.md` before changing a frozen baseline in any large-adjustment case.
- Follow `paths.change_template` for the CR body.
- `decision: pending` means no skill may unfreeze the target document yet.
- Only the human may set `decision` to `approved` or `rejected`.
- Approved CRs must reopen affected downstream documents by setting their `status` back to `active` and appending a `change_history` entry that references the CR.
- Rejected CRs close without changing the frozen baseline.
- A CR closes only after reopened documents pass review and all affected downstream documents have been re-reviewed or receive explicit human waiver.
- Requirement CRs must at least return to steps 1-6; acceptance CRs must at least return to steps 4-6.

### Cascade Depth Limit

- Every CR must declare its expected cascade scope in `downstream_impact`: which downstream stages will be affected.
- If a CR's cascade impact spans more than 2 stages (e.g., requirements change affecting acceptance, architecture, and design), the CR must be flagged as a **major change** and escalated to the human for a dedicated scope decision before approval.
- When an approved CR causes a downstream document to reopen, and that reopening in turn requires further downstream reopenings, the total cascade depth must not exceed 2 stages without explicit human authorization.
- If cascading reopenings threaten to exceed this limit, stop and escalate to the human with a full impact summary rather than continuing the chain automatically.

## Review and Traceability Rules

- Review reports record scope, issues, severity, and overall judgment.
- Severity is limited to `blocker` and `minor`.
- When a reviewed target contains an `author` field, the default rule is `reviewer != author`; if the human waives that rule, state the waiver explicitly in the review context or report.
- Requirement, acceptance, design, testing, and review artifacts should use stable IDs such as `1`, `1.2`, `1.2.3`, or `X1`.
- `plan.md` must map task IDs to implementation output locations so code remains traceable to design.

## Loop Stop Rules

- Any formal review, revise, recheck, or repair loop on the same artifact or fix direction may run at most 7 consecutive rounds without convergence.
- After 7 unresolved rounds, stop and escalate to the human to decide whether to continue, split scope, reopen an upstream stage, or pause the route.
- Escalate earlier when reviewers conflict on root cause or fix direction, authoritative sources conflict, the repair cost exceeds the current release expectation, or the correct return path is unclear.

## Progress Update Rules

- When a skill's work advances, confirms, or corrects the workflow state, it must update the progress dashboard at `paths.progress` and append a timestamped entry to `paths.progress_history`. Not every skill invocation triggers a progress write — only actual state changes do.
- The dashboard must stay slim: one status row per stage, current blockers, and next step. Do not accumulate historical entries in the dashboard.
- If the dashboard conflicts with frontmatter or actual files, correct the dashboard to match reality and append a correction entry to `paths.progress_history`.
- Do not mark a stage complete before the required outputs, review artifacts, and human gates are all satisfied.

### Dashboard Write Permission Layering

- **Stage advancement**: Only `completion-verifier` with a PASS verdict may advance a stage's status to `frozen` or mark a stage complete on the dashboard.
- **Metadata correction**: `doc-guardian` may correct dashboard entries when they disagree with document frontmatter reality, but it must not advance stage status.
- **Intermediate updates**: Stage skills (e.g., `requirements-analyst`, `developer`) may update their own stage row to reflect intermediate states such as `active`, `in-review`, or `blocked`, but they must not mark the stage as complete.
- **Navigation-only skills**: `workflow-router` must not modify the progress dashboard. When it detects inconsistencies, it reports them and recommends invoking `doc-guardian` for correction.

## Stop and Escalate Rules

Stop and escalate to the human when any of the following is true:

- a pending CR blocks the requested path
- a frozen document is about to change without an approved CR
- a required human gate has not happened yet
- the same formal artifact, review, or repair loop has failed to converge after 7 rounds
- evidence is insufficient to classify a failure and the workflow requires escalation
- the requested action conflicts with the current frozen baseline and no approved reopening path exists

## Single Release Constraint

- Only one release may be active at a time. `project.current_release` in `workflow-project.yaml` is the single active release identifier.
- Parallel release management (e.g., hotfixing r1 while developing r2) is not supported. If a prior release needs correction, the current release work must be paused or completed first.
- To switch releases, update `project.current_release`, create the new release directory under `paths.releases_dir`, and reset the progress dashboard for the new release.
