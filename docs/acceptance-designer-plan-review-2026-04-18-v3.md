---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v3)"
type: review
created: 2026-04-18 04:10
target: "docs/acceptance-designer-plan-2026-04-17-v3.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v3)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-17-v3.md`
- Baseline:
  - `docs/acceptance-designer-plan-review-2026-04-17.md`
  - `docs/acceptance-designer-plan-review-2026-04-17-v2.md`
  - `skills/acceptance-designer/SKILL.md`
  - `skills/acceptance-designer/references/output-artifacts.md`
  - current Platform 5 CLI / runtime contract in `../persona-agents-platform5/src/platform5/cli/main.py`, `../persona-agents-platform5/src/platform5/models.py`, and `../persona-agents-platform5/docs/releases/r1/design/detail.md`
- Focus areas:
  - whether v3 resolves the three blockers from v2
  - whether the new actor / verifier / flow / state model is internally consistent
  - whether Variant A is truly adoptable against the current Platform 5 contract

## Findings

1. [blocker] Variant A is still not operationally grounded in the current Platform 5 CLI and runtime contract, so the claimed "adopt now" path is not actually executable as written.

   The plan says Variant A is fully specified with today's commands at `docs/acceptance-designer-plan-2026-04-17-v3.md:100` and claims there are "No tooling blockers" at `docs/acceptance-designer-plan-2026-04-17-v3.md:402`. But several normative examples do not match the current product interface:

   - `platform status` is used as a real command at `docs/acceptance-designer-plan-2026-04-17-v3.md:129`, while the current CLI exposes `platform service status`; there is no top-level `status` command in `../persona-agents-platform5/src/platform5/cli/main.py:94` and `../persona-agents-platform5/src/platform5/cli/main.py:104`.
   - `platform project create --template {tpl} --name {proj}` is specified at `docs/acceptance-designer-plan-2026-04-17-v3.md:145`, but the current CLI takes the project name as a positional argument, not `--name`, in `../persona-agents-platform5/src/platform5/cli/main.py:114`.
   - Variant A cleanup and S0 invariants assume a process matching `/^platform /` at `docs/acceptance-designer-plan-2026-04-17-v3.md:115` and `docs/acceptance-designer-plan-2026-04-17-v3.md:118`, but the service is started as `python -m platform5.server` in `../persona-agents-platform5/src/platform5/cli/main.py:58`, so the proposed `pkill -f "^platform "` does not target the actual daemon model.
   - The flagship case and loop grammar use `verdict` fields at `docs/acceptance-designer-plan-2026-04-17-v3.md:353` and `docs/acceptance-designer-plan-2026-04-17-v3.md:357`, but the current result schema is `NodeResult.result` in `../persona-agents-platform5/src/platform5/models.py:229`, consistent with `result == "pass"` in `../persona-agents-platform5/docs/releases/r1/design/detail.md:350`.

   Because Variant A is the recommended immediate adoption path, these mismatches are blocking: the plan still does not provide a concrete syntax that a reviewer or downstream skill can apply directly to today's product.

2. [blocker] The Flow grammar is still not mechanically closed, because the flagship example violates the grammar's own rules and introduces condition forms that the grammar never defines.

   v3's main claim is that B2 is resolved by a closed 5-primitive grammar at `docs/acceptance-designer-plan-2026-04-17-v3.md:167`. However, the normative example in `docs/acceptance-designer-plan-2026-04-17-v3.md:348` still escapes that contract in multiple places:

   - `kind=wait` requires every expected bullet to include a time budget at `docs/acceptance-designer-plan-2026-04-17-v3.md:181`, but the wait steps at `docs/acceptance-designer-plan-2026-04-17-v3.md:350`, `docs/acceptance-designer-plan-2026-04-17-v3.md:355`, and `docs/acceptance-designer-plan-2026-04-17-v3.md:360` each contain expected bullets without `within Ns`.
   - `if {stage} in [requirements, acceptance]` at `docs/acceptance-designer-plan-2026-04-17-v3.md:367` uses set-membership over a loop variable, but the grammar never defines that condition form. The primitive spec only formalizes observation-style conditions and does not define a variable-expression language.
   - `nodes.{stage}-review.executor ≠ nodes.{stage}.executor (asserted at least once across the whole case)` at `docs/acceptance-designer-plan-2026-04-17-v3.md:358` is an aggregate English assertion, not one of the declared observation forms and not scoped to a single step outcome.

   So while v3 names more constructs than v2, the "closed grammar" promise is still not met. Reviewers and implementers would still need to invent extra validation semantics around variable conditions, aggregate assertions, and wait-step timing rules.

3. [blocker] The actor and observation syntax remains internally inconsistent in the normative templates, so the document still teaches forms that its own rules do not allow.

   v3 improves the actor / verifier split, but the detailed syntax is still self-contradictory:

   - The declared actor values are only `ai`, `human`, and `system` at `docs/acceptance-designer-plan-2026-04-17-v3.md:51`, but the plan repeatedly uses `human-gate` inside `actor-mix` at `docs/acceptance-designer-plan-2026-04-17-v3.md:60`, `docs/acceptance-designer-plan-2026-04-17-v3.md:62`, `docs/acceptance-designer-plan-2026-04-17-v3.md:323`, and `docs/acceptance-designer-plan-2026-04-17-v3.md:340`.
   - `actor-mix` is described as informational at `docs/acceptance-designer-plan-2026-04-17-v3.md:57` and `docs/acceptance-designer-plan-2026-04-17-v3.md:82`, but the grammar then says `actor` defaults to the case's `actor-mix` primary value at `docs/acceptance-designer-plan-2026-04-17-v3.md:180`. A set-like informational field has no defined "primary value", so defaulting remains ambiguous.
   - The AI-tier observation list at `docs/acceptance-designer-plan-2026-04-17-v3.md:90` does not define `directory-exists` or `process-absent`, yet Variant A uses both at `docs/acceptance-designer-plan-2026-04-17-v3.md:123`, `docs/acceptance-designer-plan-2026-04-17-v3.md:139`, and `docs/acceptance-designer-plan-2026-04-17-v3.md:146`.
   - `How to reach` is required to be actual commands, "not narrative", at `docs/acceptance-designer-plan-2026-04-17-v3.md:152`, but the State Catalog then uses narrative pseudo-steps `verify invariants of S0/S1/S2` at `docs/acceptance-designer-plan-2026-04-17-v3.md:122`, `docs/acceptance-designer-plan-2026-04-17-v3.md:134`, and `docs/acceptance-designer-plan-2026-04-17-v3.md:147`.

   This matters because v3's stated goal is a mechanically reviewable structure. As long as the plan's own exemplars keep reintroducing undeclared tokens and pseudo-actions, downstream authors will copy those patterns and reviewers will still have to interpret them ad hoc.

## Overall Judgment

v3 is the strongest revision so far. The actor-versus-verifier split is a real improvement over v2, the two-variant State Catalog is much clearer than the earlier workspace placeholder model, and the plan is moving in the right direction on non-AI-verifiable commitments.

However, it still is not implementation-ready. The immediate Variant A path is not aligned to today's Platform 5 commands and result schema, the flagship Flow example still needs undeclared semantics, and the normative templates still contain syntax that the rules do not actually allow.

Next step: revise v3 so that (1) every Variant A command and field name matches the real Platform 5 contract, (2) the Flow grammar explicitly defines all condition and aggregation forms it wants to allow, and (3) the actor / observation syntax is normalized so the examples use only declared values and observation modes.
