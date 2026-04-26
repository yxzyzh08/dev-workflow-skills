---
name: completion-verifier
description: Use when a workflow stage is about to be marked complete and outputs, document state, or command-backed evidence must be checked first, including 完成前核对/交付证据校验/阶段完成验收
---

# Completion Verifier

## Overview

Completion Verifier is the final evidence gate before any stage, document, or integration batch claims done. It checks the required outputs, confirms command-backed proof, validates metadata and progress alignment, and blocks optimistic completion claims.

## Support Files

Use these support assets for repeatable completion checks:

- `references/evidence-checklist.md`
- `references/frontmatter-and-progress-checks.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)
- `templates/verification-report.md`

## First Step

Read `skills/workflow-protocol/SKILL.md`, then repository-root `workflow-project.yaml`. Resolve `paths.progress`, then read the progress dashboard at `paths.progress`. Before accepting a completion claim, use `references/evidence-checklist.md` and scan `references/boundary-examples.md` if ownership of the missing work is unclear.

## When to Use

Use this skill when:

- a stage, document, or code task is about to be marked complete
- a document is ready to transition workflow state
- code, tests, or E2E work claims success and needs command-backed confirmation
- the progress dashboard at `paths.progress` is about to be updated to reflect completion

Do not use this skill to do the missing work itself or to waive evidence because progress already claims success.

## Inputs

- the published output checklist from the design spec, plan, or owning skill
- candidate artifacts and their metadata or diffs
- progress dashboard from `paths.progress`
- command logs for lint, type checks, tests, E2E, or other required verification
- approved CRs resolved from `paths.changes_dir`, blocked gates, or linked upstream/downstream documents when relevant

## Outputs

- a verification report that ends with PASS or NOT PASS
- cited artifact and command evidence for every verdict
- progress dashboard updated only when the report is PASS; NOT PASS events are still appended to `paths.progress_history` for audit trail
- explicit blocker notes and next-step routing when the verdict is NOT PASS

## Working Loop

1. Pull the required output list for the claimed completion.
2. Use `references/evidence-checklist.md` to confirm every artifact and command proof is present.
3. Use `references/frontmatter-and-progress-checks.md` when document metadata or progress rows are in scope.
4. Write the verdict with `templates/verification-report.md`, citing evidence instead of assertions.
5. Update progress artifacts per `workflow-protocol`: advance dashboard stage status and append a PASS entry to `paths.progress_history` only after PASS. On NOT PASS, do not change the dashboard, but still append a NOT PASS entry to `paths.progress_history` recording the blockers so the audit trail captures failed verification attempts.

## Verification Rules

- Evidence beats memory: rerun or recite current command output instead of relying on earlier claims.
- Missing artifacts, failing commands, pending CRs, or inconsistent metadata all force NOT PASS.
- Validate metadata and evidence against files resolved from `workflow-project.yaml`, never against literal path strings.
- Treat the progress dashboard at `paths.progress` as downstream bookkeeping that must match verified reality, not as proof by itself.
- If the missing work belongs to another skill, block completion and route it back rather than compensating inside verification.

## Completion Checklist

- The verification report exists and ends with PASS or NOT PASS.
- Every required output is traced to an artifact path or command log.
- Metadata and progress alignment checks are recorded when documents are in scope.
- Dashboard stage advancement happens only after PASS.
- NOT PASS events are appended to `paths.progress_history` with blocker details.
- NOT PASS reports name the blockers and the owning next step.
