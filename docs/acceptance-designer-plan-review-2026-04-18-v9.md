---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v9)"
type: review
created: 2026-04-18 06:17
target: "docs/acceptance-designer-plan-2026-04-18-v9.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v9)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-18-v9.md`
- Baseline:
  - prior reviews `docs/acceptance-designer-plan-review-2026-04-17.md`, `docs/acceptance-designer-plan-review-2026-04-17-v2.md`, `docs/acceptance-designer-plan-review-2026-04-18-v3.md`, `docs/acceptance-designer-plan-review-2026-04-18-v5.md`, `docs/acceptance-designer-plan-review-2026-04-18-v6.md`, `docs/acceptance-designer-plan-review-2026-04-18-v7.md`, `docs/acceptance-designer-plan-review-2026-04-18-v8.md`
  - current skill contract in `skills/acceptance-designer/SKILL.md`
  - current artifact contract in `skills/acceptance-designer/references/output-artifacts.md`
- Focus areas:
  - whether v9 resolves the remaining `partial-coverage` schema hole from v8
  - whether the updated outcome model is now internally consistent across all tiers
  - whether the illustrative examples still match the declared generic rules

## Findings

1. [blocker] The human outcome-rule spec is now internally inconsistent, because v9 adds `partial-coverage` support for human cases in the new schema but still inherits the older 3-line human template from v8.

   v9 says §4.8.1 is unchanged from v8 at `docs/acceptance-designer-plan-2026-04-18-v9.md:81`. That inherited human template still says:

   - rule 1 = `fail`
   - rule 2 = `inconclusive-human-needed`
   - rule 3 = `pass`

   in `docs/acceptance-designer-plan-2026-04-18-v8.md:108`.

   But v9 simultaneously introduces a formal `Declared branches` field for all tiers at `docs/acceptance-designer-plan-2026-04-18-v9.md:83` and updates the human skeleton so that human cases may have:

   - rule 3 = `partial-coverage`
   - rule 4 = `pass`

   at `docs/acceptance-designer-plan-2026-04-18-v9.md:194`.

   Those are two different normative human outcome templates. Since the document treats §4.8.1 as still active while also publishing a new human skeleton, a reviewer still cannot tell which rule order is authoritative for branchy human cases.

2. [blocker] `set-outcome inconclusive-human-needed` is still shadowed by rule 1 `fail` in the standard AI outcome rule whenever the inconclusive branch exits before the pass checklist can succeed.

   The AI skeleton in v9 defines this priority order:

   - rule 1: any Pass-checklist item failed -> `fail`
   - rule 2: `set-outcome inconclusive-human-needed` fired -> `inconclusive-human-needed`

   at `docs/acceptance-designer-plan-2026-04-18-v9.md:151`.

   But the flagship branch+loop example still uses a terminal inconclusive branch inherited from the earlier version:

   - `set-outcome inconclusive-human-needed` in `docs/acceptance-designer-plan-2026-04-18-v7.md:274`

   and v9 keeps that example's pass checklist semantics via "unchanged" references at `docs/acceptance-designer-plan-2026-04-18-v9.md:328`, including the completion-oriented checklist from `docs/acceptance-designer-plan-2026-04-18-v7.md:290`.

   In that shape, once the terminal inconclusive branch fires, the run will generally not satisfy the normal completion checklist, so rule 1 wins before rule 2 is ever considered. That makes the standard inconclusive branch mechanically unreachable in exactly the kind of AI case the template is supposed to support.

## Overall Judgment

v9 does cleanly resolve the explicit v8 blocker around `Declared branches`, and it also fixes the minor example issue around the unbound `{wr}` in the hybrid toy case. The generic schema is closer to implementation-ready than any prior revision.

However, the plan still is not ready to implement because the outcome system remains internally inconsistent in two places: human cases now have two conflicting normative outcome templates, and AI cases still allow `set-outcome inconclusive-human-needed` to be shadowed by the fail-first checklist rule.

Next step: pick one authoritative human outcome template and update every reference to match it, then define how `set-outcome inconclusive-human-needed` interacts with Pass-checklist evaluation so the inconclusive branch cannot be preempted by ordinary checklist failure.
