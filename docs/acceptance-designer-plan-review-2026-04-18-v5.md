---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v5)"
type: review
created: 2026-04-18 04:31
target: "docs/acceptance-designer-plan-2026-04-18-v5.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v5)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-18-v5.md`
- Baseline:
  - prior reviews `docs/acceptance-designer-plan-review-2026-04-17.md`, `docs/acceptance-designer-plan-review-2026-04-17-v2.md`, `docs/acceptance-designer-plan-review-2026-04-18-v3.md`
  - current skill contract in `skills/acceptance-designer/SKILL.md`
  - current artifact contract in `skills/acceptance-designer/references/output-artifacts.md`
- Focus areas:
  - whether v5 resolves the internal inconsistencies that remained in v3/v4
  - whether the generic placeholder-based contract is mechanically specifiable
  - whether the examples and file-level edits are consistent with the declared grammar

## Findings

1. [blocker] The State Catalog schema still contradicts the Flow grammar on `kind=wait`, so a reviewer cannot tell what a valid wait step actually looks like.

   In §4.3, the required Variant A state schema explicitly uses:

   - `step (actor=ai, kind=wait)` at `docs/acceptance-designer-plan-2026-04-18-v5.md:162`

   But §4.5 defines `kind=wait` differently:

   - `kind=wait` is required when `actor=system` and forbidden otherwise at `docs/acceptance-designer-plan-2026-04-18-v5.md:197`

   The illustrative examples then introduce a third form:

   - `step (kind=wait)` without any actor at `docs/acceptance-designer-plan-2026-04-18-v5.md:483` and `docs/acceptance-designer-plan-2026-04-18-v5.md:491`

   So v5 currently teaches three incompatible encodings of the same concept. Because State Catalog reachability is part of the normative contract, this is not just an example-quality issue: downstream implementers will not know whether a wait step is `actor=system`, `actor=ai`, or actor-less.

2. [blocker] The observation and condition grammar still cannot express several assertions used in the flagship branch+loop example, despite the plan claiming the example uses only declared constructs.

   §4.2 restricts `file-field` to comparisons against literals, regexes, or literal sets at `docs/acceptance-designer-plan-2026-04-18-v5.md:101`. §4.6 then says conditions can use only AI-tier observation forms or the explicit variable grammar at `docs/acceptance-designer-plan-2026-04-18-v5.md:241`.

   However, the worked loop example in §6.2 still relies on undeclared comparison semantics:

   - `file-field ... -> nodes.{stage}-review.loop_count ≥ max_retries` at `docs/acceptance-designer-plan-2026-04-18-v5.md:525` and `docs/acceptance-designer-plan-2026-04-18-v5.md:535`
   - `file-field ... -> nodes.{stage}.sessionId unchanged` at `docs/acceptance-designer-plan-2026-04-18-v5.md:533`
   - `file-field ... -> nodes.{stage}.loop_count incremented` at `docs/acceptance-designer-plan-2026-04-18-v5.md:534`
   - aggregate comparison of two fields, `nodes.{stage}.executor ≠ nodes.{stage}-review.executor`, at `docs/acceptance-designer-plan-2026-04-18-v5.md:553`

   None of those fit the declared `file-field` forms, and `max_retries` is not introduced as a literal, placeholder, or bound `{var}` in the condition grammar. That means the central example is still not actually representable by the formal vocabulary the plan defines, so the grammar is not yet closed.

3. [blocker] The file-level implementation plan still conflicts with the human-case template, so the skill change cannot be implemented consistently from this spec.

   The planned `SKILL.md` rule change in §5.1 says every case must carry:

   - `Flow block (5 primitives)` and
   - `Pass checklist (scoped bullets)`

   at `docs/acceptance-designer-plan-2026-04-18-v5.md:413` and `docs/acceptance-designer-plan-2026-04-18-v5.md:417`.

   But the human-case skeleton in §4.9 is intentionally different:

   - it has `Setup for the observer`, `What to observe`, `What to try`, `Pass signals`, and `Fail signals`
   - it has no Flow block and no Pass checklist

   see `docs/acceptance-designer-plan-2026-04-18-v5.md:338` through `docs/acceptance-designer-plan-2026-04-18-v5.md:370`.

   This is a direct implementation ambiguity. If the file-level edits are followed literally, human cases must be rewritten into a Flow + Pass-checklist shape that the template does not allow. If the template is authoritative, then §5.1 is over-broad and will cause a wrong SKILL.md rewrite.

## Overall Judgment

v5 makes a real conceptual improvement by separating the generic skill contract from project-specific product surfaces. That is the right direction, and the placeholder plus non-normative toy-example split is cleaner than baking Platform 5 directly into the skill.

However, the plan still is not implementation-ready. The normative State Catalog and Flow grammar disagree on wait-step syntax, the flagship example still depends on undeclared comparison operators, and the file-level edit list still overstates what all case types must contain.

Next step: normalize wait-step syntax in one place and reuse it everywhere, either expand the observation/condition grammar to cover delta and field-to-field assertions or rewrite §6.2 to avoid them, and narrow §5.1 so human cases are explicitly exempt from the Flow + Pass-checklist requirements that only apply to AI/hybrid cases.
