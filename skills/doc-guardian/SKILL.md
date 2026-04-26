---
name: doc-guardian
description: Use when documents, frozen baselines, frontmatter, or CR state need compliance checks before downstream work continues, including 文档合规检查/基线校验/元数据审查
---

# Doc Guardian

## Overview

Doc Guardian is a passive compliance gate. It does not run on its own but is invoked whenever another skill edits, reviews, or otherwise touches a workflow document. Its job is to keep frontmatter, state transitions, CR references, and progress alignment honest so downstream work can proceed safely.

## Support Files

Use these support assets for document compliance checks:

- `references/boundary-examples.md`
- `skills/workflow-protocol/references/frontmatter-and-state-flow.md`
- `skills/workflow-protocol/references/change-request-and-sync-status.md`
- `skills/workflow-protocol/references/review-report-rules.md`

## First Step

Read `skills/workflow-protocol/SKILL.md`, then repository-root `workflow-project.yaml`. Resolve `paths.progress`, `paths.changes_dir`, and `paths.change_template`, then read the progress dashboard at `paths.progress`. When validating metadata, CR state, or review-document compliance, use the shared protocol references above instead of inventing local variants.

## When to Use

Use this skill when:

- any skill tries to create, modify, or review a workflow document or review report
- a document is about to change its `status`, `upstream`, `downstream`, or `change_history`
- progress or CR state needs validation before downstream work continues
- reviewing a derivation to ensure its sources are legally usable as baselines

Do not invoke Doc Guardian on code-only changes or documents outside the workflow chain unless a document compliance concern has been raised.

## Inputs

- the document(s) being edited or referenced, including their frontmatter
- progress dashboard at `paths.progress`
- any related CRs resolved from `paths.changes_dir` (for example, `<from paths.changes_dir>/cr-{nn}.md`)
- upstream/downstream documents declared in frontmatter
- derived document drafts that claim to follow from an upstream baseline

## Outputs

- blocked edits or derivations when compliance fails, reported with specific violations
- corrected entries in the progress dashboard at `paths.progress` (with a correction entry appended to `paths.progress_history`) when actual document state differs from progress
- explicit reminders or issue candidates documenting illegal frozen edits or missing CR approvals

## Working Loop

1. Gather the frontmatter, CR references, and document state context for the document set.
2. Validate metadata and legal state flow against the shared protocol references.
3. Check upstream/downstream existence and status legality before allowing derivation or downstream use. Only `frozen` documents may serve as baselines for downstream derivation.
4. Repair the progress dashboard at `paths.progress` when it disagrees with frontmatter-derived reality.
5. Block and escalate when frozen edits, missing CR approval, or illegal downstream use is detected.

## Document Compliance Rules

- Frontmatter fields and legal state transitions must follow `workflow-protocol`.
- Only `frozen` documents may be used as downstream baselines. Documents in `draft` or `active` status cannot serve as baselines for downstream derivation.
- Frozen documents may receive only legal small adjustments; larger change paths require an approved CR.
- Validate metadata and evidence against files resolved from `workflow-project.yaml`, never against literal path strings.
- If the progress dashboard at `paths.progress` disagrees with actual document state, frontmatter reality wins and progress must be corrected.
- Illegal frozen edits are blocked and escalated to the human immediately.
- Implementation review artifacts include both `spec-review-{nn}.md` (spec compliance, stage 1) and `code-review-{nn}.md` (code quality, stage 2). Both follow the standard review frontmatter from `workflow-protocol/references/review-report-rules.md`. Spec compliance review must exist before code quality review is considered valid.

## Completion Checklist

- The relevant frontmatter is valid and legal for the current action.
- Upstream/downstream references exist and allow the requested derivation or edit.
- Any frozen-to-active reopening has a matching approved CR.
- The progress dashboard at `paths.progress` matches document reality. Any correction also appended to `paths.progress_history`.
- Any blocked violation has been reported clearly.
