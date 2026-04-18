---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v8)"
type: review
created: 2026-04-18 06:08
target: "docs/acceptance-designer-plan-2026-04-18-v8.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v8)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-18-v8.md`
- Baseline:
  - prior reviews `docs/acceptance-designer-plan-review-2026-04-17.md`, `docs/acceptance-designer-plan-review-2026-04-17-v2.md`, `docs/acceptance-designer-plan-review-2026-04-18-v3.md`, `docs/acceptance-designer-plan-review-2026-04-18-v5.md`, `docs/acceptance-designer-plan-review-2026-04-18-v6.md`, `docs/acceptance-designer-plan-review-2026-04-18-v7.md`
  - current skill contract in `skills/acceptance-designer/SKILL.md`
  - current artifact contract in `skills/acceptance-designer/references/output-artifacts.md`
- Focus areas:
  - whether v8 closes the remaining outcome-model gaps from v7
  - whether the revised templates are now mechanically complete across verifier tiers
  - whether the illustrative examples match the declared generic structure

## Findings

1. [blocker] `partial-coverage` still depends on an undeclared structure, because the spec never defines where a case formally declares its branches.

   The outcome model now says `partial-coverage` applies when a declared branch was not exercised:

   - `docs/acceptance-designer-plan-2026-04-18-v8.md:87`
   - `docs/acceptance-designer-plan-2026-04-18-v8.md:102`
   - `docs/acceptance-designer-plan-2026-04-18-v8.md:214`

   Human cases are even allowed to use that mode in rare branchy cases:

   - `docs/acceptance-designer-plan-2026-04-18-v8.md:117`

   But neither the case templates nor the per-tier required-field lists define any formal `Declared branches` section or equivalent place where those branches must be listed:

   - human and hybrid templates: `docs/acceptance-designer-plan-2026-04-18-v8.md:141`, `docs/acceptance-designer-plan-2026-04-18-v8.md:183`
   - required-field lists: `docs/acceptance-designer-plan-2026-04-18-v8.md:226`

   The only concrete branch declaration appears ad hoc inside the toy example:

   - `docs/acceptance-designer-plan-2026-04-18-v8.md:297`

   That leaves a mechanical hole in the generic contract. Reviewers can see that `partial-coverage` requires declared branches, but the skill still does not define a standard field that records them.

2. [minor] The illustrative hybrid example still uses an unbound run identifier, so it is not fully well-formed under the placeholder/binding rules it is meant to demonstrate.

   The hybrid toy case references `{wr}` repeatedly in paths and checks:

   - `docs/acceptance-designer-plan-2026-04-18-v8.md:358`
   - `docs/acceptance-designer-plan-2026-04-18-v8.md:367`

   But unlike the branch+loop toy case at `docs/acceptance-designer-plan-2026-04-18-v8.md:249`, this hybrid example never declares how `{wr}` is bound — not in `Starting state`, not in `Placeholders`, and not in an `Extra preconditions` line. Since the examples are supposed to teach valid shape, this should be tightened before implementation.

## Overall Judgment

v8 is the strongest version so far. It does fix the three outcome blockers from v7: human cases now have an explicit inconclusive channel, AI/hybrid inconclusive handling is narrowed to declared mechanisms, and hybrid outcome ownership is clearly moved to the case level.

However, the plan still is not implementation-ready because `partial-coverage` depends on "declared branches" without the spec ever defining a standard place to declare them. That prevents the outcome model from being fully mechanical across templates and tiers.

Next step: add an explicit optional `Declared branches` field to the AI, human, and hybrid case schemas whenever rule 3 (`partial-coverage`) is present, and reflect that field in the per-tier required-field lists and output-artifacts reference. Also bind `{wr}` explicitly in the hybrid toy example so the non-normative examples remain syntactically valid.
