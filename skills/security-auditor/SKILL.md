---
name: security-auditor
description: Use when code changes, architecture decisions, or dependency updates need a scoped security review before the workflow can proceed
---

# Security Auditor

## Overview

Security Auditor performs scoped security reviews for the current change. It checks code, architecture, and dependency risk inside the requested review boundary, records evidence-backed findings, and blocks downstream progress when a security blocker remains open.

## Support Files

Use these support assets when the audit scope or severity boundary needs tightening:

- `references/scoped-audit-focus.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)

## First Step

Read `skills/workflow-protocol/SKILL.md`, then repository-root `workflow-project.yaml`. Resolve `paths.progress`, then read the progress dashboard at `paths.progress`. Before widening or classifying the audit, use `references/scoped-audit-focus.md` and scan `references/boundary-examples.md` if ownership is unclear.

## When to Use

Use this skill when the human or another agent requests a security review for:

- code changes touching authentication, authorization, secrets, transport, or sensitive data handling
- architecture decisions affecting permission models, isolation boundaries, or encryption
- introduced or updated dependencies that may bring vulnerability or license risk
- explicit requests to check unsafe defaults, leaked secrets, or security-critical configuration

Do not use this skill for general functional reviews, unbounded full-repo scans without human approval, or implementation work.

## Inputs

- current diff or requested review scope
- relevant runtime configs, manifests, or dependency files
- affected architecture or design documents when the audit is not code-only
- human instructions about the exact review boundary

## Outputs

- a security review report in the current stage's `reviews/` area
- findings classified only as `blocker` or `minor`
- clear gating notes describing whether downstream work may proceed

## Working Loop

1. Define the requested review boundary and keep it scoped with `references/scoped-audit-focus.md`.
2. Inspect the relevant code, architecture, or dependency changes and collect evidence for each issue.
3. Classify each finding as `blocker` or `minor`, citing exact files, modules, configs, or dependency entries.
4. Publish the review report and state whether the next stage is blocked.

## Mandatory Trigger Conditions

A security audit must be triggered when any of the following applies to the current change:

- authentication, authorization, or session management logic is added or modified
- secrets, tokens, API keys, or credential handling is involved
- encryption, hashing, or transport security is changed
- user input validation, sanitization, or output encoding is affected
- permission models, isolation boundaries, or multi-tenancy logic is touched
- new external dependencies are introduced or existing ones are upgraded
- security-critical configuration (CORS, CSP, TLS, firewall rules) is modified

The human or the owning stage skill is responsible for recognizing these conditions and invoking the audit. If unsure whether a change qualifies, invoke the audit — a scoped no-finding report is low cost.

## Audit Rules

- Tie every finding to the reviewed change unless the human explicitly requested a broader scan.
- `blocker` findings must be fixed in the current stage before the workflow proceeds.
- `minor` findings stay documented for follow-up but do not close the current stage by themselves.
- Review reports must name the reviewed files, modules, documents, or dependencies explicitly.

## Completion Checklist

- The security review report exists with workflow-protocol review frontmatter.
- Each finding is `blocker` or `minor` and cites concrete reviewed scope.
- Any blocker is clearly marked as gating downstream work.
- Any human-requested scope expansion is recorded in the review report.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history) only if the audit result legitimately moves the stage forward.
