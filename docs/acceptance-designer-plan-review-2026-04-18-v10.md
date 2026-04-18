---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v10)"
type: review
created: 2026-04-18 06:34
target: "docs/acceptance-designer-plan-2026-04-18-v10.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v10)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-18-v10.md`
- Baseline:
  - prior reviews `docs/acceptance-designer-plan-review-2026-04-17.md`, `docs/acceptance-designer-plan-review-2026-04-17-v2.md`, `docs/acceptance-designer-plan-review-2026-04-18-v3.md`, `docs/acceptance-designer-plan-review-2026-04-18-v5.md`, `docs/acceptance-designer-plan-review-2026-04-18-v6.md`, `docs/acceptance-designer-plan-review-2026-04-18-v7.md`, `docs/acceptance-designer-plan-review-2026-04-18-v8.md`, `docs/acceptance-designer-plan-review-2026-04-18-v9.md`
  - current skill contract in `skills/acceptance-designer/SKILL.md`
  - current artifact contract in `skills/acceptance-designer/references/output-artifacts.md`
- Focus areas:
  - whether v10 resolves the two blockers from v9
  - whether the outcome system is now mechanically closed
  - whether the carried-forward grammar still matches the revised outcome semantics

## Findings

1. [blocker] The grammar still permits `set-outcome` values that the v10 outcome model does not define how to handle.

   v10 says the Flow grammar is unchanged at `docs/acceptance-designer-plan-2026-04-18-v10.md:68`, which means it still inherits the generic `set-outcome <outcome-value>` form from the earlier grammar:

   - `docs/acceptance-designer-plan-2026-04-18-v5.md:227`

   But the revised outcome system and termination semantics now assume only one concrete `set-outcome` value:

   - rule 1 in every tier checks only `set-outcome inconclusive-human-needed`, at `docs/acceptance-designer-plan-2026-04-18-v10.md:92`, `docs/acceptance-designer-plan-2026-04-18-v10.md:112`, and `docs/acceptance-designer-plan-2026-04-18-v10.md:152`
   - the shared rule says `inconclusive-human-needed` is emitted only by declared channels, including `set-outcome inconclusive-human-needed`, at `docs/acceptance-designer-plan-2026-04-18-v10.md:126`
   - the new termination section says the case's outcome rule uses the declared value via rule 1, explicitly calling that rule the inconclusive rule, at `docs/acceptance-designer-plan-2026-04-18-v10.md:137`

   The document itself acknowledges the mismatch as still-open in `docs/acceptance-designer-plan-2026-04-18-v10.md:305`, where it notes that the current grammar accepts any closed-set outcome value and recommends restricting it.

   As long as `set-outcome pass`, `set-outcome fail`, or `set-outcome partial-coverage` remain syntactically legal, the grammar is not mechanically closed: the templates and semantics do not define how those branches should be interpreted. This leaves an implementation-visible hole in the core execution model.

2. [minor] Exercised-condition grammar is still slightly inconsistent about `for-all-iterations`.

   `Declared branches` is said to use the same grammar as Pass-checklist Scope-2 aggregates at `docs/acceptance-designer-plan-2026-04-18-v9.md:98`, and Scope-2 aggregates include `for-all-iterations` in `docs/acceptance-designer-plan-2026-04-18-v5.md:279`.

   But v10's open-questions section now states:

   - `for-all-iterations` in exercised-conditions — disallowed at `docs/acceptance-designer-plan-2026-04-18-v10.md:299`

   This is not blocking because no normative example depends on that form, but the spec should still either forbid it normatively in §4.8.3 or stop describing it as disallowed.

## Overall Judgment

v10 does fix the two explicit v9 blockers: the human outcome template is now unified, and the short-circuit semantics make the inconclusive branch reachable before completion-oriented checklist failures. Those are real improvements.

However, the plan still is not implementation-ready because the carried-forward `set-outcome` grammar remains broader than the outcome system it now feeds. Until the syntax is narrowed or the semantics are expanded to cover all allowed values, the core grammar is still not fully closed.

Next step: make `set-outcome inconclusive-human-needed` the only legal form in the grammar, or explicitly define tier-level handling for every currently allowed `set-outcome <outcome-value>` variant. As a cleanup pass, also make §4.8.3 explicit about whether `for-all-iterations` is allowed in branch exercised-conditions.
