---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v7)"
type: review
created: 2026-04-18 05:49
target: "docs/acceptance-designer-plan-2026-04-18-v7.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v7)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-18-v7.md`
- Baseline:
  - prior reviews `docs/acceptance-designer-plan-review-2026-04-17.md`, `docs/acceptance-designer-plan-review-2026-04-17-v2.md`, `docs/acceptance-designer-plan-review-2026-04-18-v3.md`, `docs/acceptance-designer-plan-review-2026-04-18-v5.md`, `docs/acceptance-designer-plan-review-2026-04-18-v6.md`
  - current skill contract in `skills/acceptance-designer/SKILL.md`
  - current artifact contract in `skills/acceptance-designer/references/output-artifacts.md`
- Focus areas:
  - whether v7 resolves the three blockers from v6
  - whether the outcome model is now mechanically complete across all verifier tiers
  - whether the illustrative examples and file-level edits match the declared generic grammar

## Findings

1. [blocker] The closed outcome model is still not representable for `verifier: human` cases, because the template and required-field lists have no way to declare an `inconclusive-human-needed` path.

   §4.8 says every case evaluates to exactly one outcome from the closed set, and it explicitly states that human cases can emit:

   - `fail`
   - `inconclusive-human-needed`
   - `pass`

   at `docs/acceptance-designer-plan-2026-04-18-v7.md:171`.

   But the human-case structure still only provides:

   - `Pass signals`
   - `Fail signals`

   in the template area referenced by `docs/acceptance-designer-plan-2026-04-18-v7.md:175`, and the human-tier required fields in `docs/acceptance-designer-plan-2026-04-18-v7.md:280` through `docs/acceptance-designer-plan-2026-04-18-v7.md:290` likewise omit any `Inconclusive signals` or equivalent rule. As written, a human reviewer cannot encode "observer unable to complete" without inventing an ad hoc convention outside the template.

2. [blocker] The standard AI / hybrid outcome template still does not implement the full declared meaning of `inconclusive-human-needed`.

   The outcome table defines `inconclusive-human-needed` broadly at `docs/acceptance-designer-plan-2026-04-18-v7.md:149`:

   - the Flow hit `set-outcome inconclusive-human-needed`, **or**
   - a failure was attributable to environment/human not the product

   But the normative standard template for AI / hybrid cases only includes the first half:

   - rule 2 checks whether `set-outcome inconclusive-human-needed` fired at `docs/acceptance-designer-plan-2026-04-18-v7.md:164`

   There is no standard rule for a non-product checklist failure that did not go through `set-outcome`. That leaves a mechanical gap: authors who follow the published template still have no canonical way to classify environment-caused checklist failures, even though the vocabulary says those should map to `inconclusive-human-needed`.

3. [blocker] Hybrid-case outcome ownership is still ambiguous between the AI block and the overall case result.

   v7 says outcomes are singular at the case level:

   - `Outcome is singular; never emit more than one outcome for a case` at `docs/acceptance-designer-plan-2026-04-18-v7.md:195`

   It also says AI and hybrid skeletons now require the priority-ordered outcome rule:

   - `The AI and hybrid skeletons now include the priority-ordered outcome rule as a required field` at `docs/acceptance-designer-plan-2026-04-18-v7.md:175`
   - under AI / hybrid required-field lists, replace the old outcome line with the priority-ordered outcome rule at `docs/acceptance-designer-plan-2026-04-18-v7.md:197`

   But the only concrete hybrid guidance later says:

   - `references/illustrative-examples.md`, updated to use the priority-ordered outcome rule format for the AI block at `docs/acceptance-designer-plan-2026-04-18-v7.md:332`

   That wording implies the outcome rule may live at AI-block scope rather than case scope. If the hybrid case has one singular case outcome, the spec needs to say explicitly whether the priority list governs the full case outcome, how the human block feeds into it, and whether `Overall pass` remains a separate field or is replaced by the case-level outcome rule. Right now that ownership is still ambiguous.

## Overall Judgment

v7 does fix the three concrete grammar blockers from v6: the `for-each` placeholder form is now specified, `iteration-start` is no longer left open, and `partial-coverage` is no longer presented as a side annotation. Those are real improvements.

However, the outcome system still is not fully closed across verifier tiers. Human cases can emit `inconclusive-human-needed` in theory but not in the template, the AI / hybrid standard template still under-specifies non-product failures, and hybrid cases still do not clearly state whether the priority-ordered outcome rule belongs to the AI block or to the case as a whole.

Next step: add an explicit human-tier representation for inconclusive outcomes, extend the AI / hybrid standard template with the non-product-failure branch or narrow the vocabulary so `inconclusive-human-needed` only ever comes from `set-outcome`, and make the hybrid template define one case-level outcome rule that incorporates both the AI and human blocks.
