---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v2)"
type: review
created: 2026-04-17 12:17
target: "docs/acceptance-designer-plan-2026-04-17-v2.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v2)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-17-v2.md`
- Baseline:
  - prior review `docs/acceptance-designer-plan-review-2026-04-17.md`
  - current skill contract in `skills/acceptance-designer/SKILL.md`
  - current artifact contract in `skills/acceptance-designer/references/output-artifacts.md`
  - current platform5 acceptance baseline in `../persona-agents-platform5/docs/acceptance/acceptance.md`
- Focus areas:
  - whether v2 resolves the three blockers from v1
  - whether the new tier / state / flow model is internally consistent
  - whether the proposed structure can be applied to the current platform5 cases without inventing extra syntax

## Findings

1. [blocker] The new verifier-tier model still conflates "who performs the action" with "how the result is observed", so core human-gate cases do not fit the declared categories cleanly.

   `docs/acceptance-designer-plan-2026-04-17-v2.md:56` defines `verifier: ai` as autonomously runnable, while `docs/acceptance-designer-plan-2026-04-17-v2.md:57` and `docs/acceptance-designer-plan-2026-04-17-v2.md:58` reserve `human` / `hybrid` for cases that need human judgment. But the document's own AI examples still require a human to execute gate actions:

   - `human runs /freeze` at `docs/acceptance-designer-plan-2026-04-17-v2.md:177`
   - `**Verifier:** ai` with `human runs /approve` or `/freeze` at `docs/acceptance-designer-plan-2026-04-17-v2.md:358` and `docs/acceptance-designer-plan-2026-04-17-v2.md:383`

   Those steps do not require human judgment, but they do require human intervention, which means the current three-tier model is missing an explicit notion of actor/driver. As written, reviewers will still be unable to classify gate-driven workflow cases consistently: either they stay `ai` despite not being autonomous, or they get forced into `hybrid` even when the only human involvement is typing a deterministic gate command.

2. [blocker] The Flow block is still not self-sufficient: the flagship branch+loop example relies on undeclared control syntax and meta-actions outside the three promised primitives.

   v2 says the Flow block supports exactly three primitives at `docs/acceptance-designer-plan-2026-04-17-v2.md:146` and then presents them as the solution to v1 blocker B3. However, the core closed-loop example in `docs/acceptance-designer-plan-2026-04-17-v2.md:363` immediately needs additional, undeclared constructs:

   - `For each stage in [...]` at `docs/acceptance-designer-plan-2026-04-17-v2.md:365`
   - `let workflow execute the stage's producer node` at `docs/acceptance-designer-plan-2026-04-17-v2.md:366`
   - `mark outcome = inconclusive-human-needed and exit` at `docs/acceptance-designer-plan-2026-04-17-v2.md:381`

   None of those are one of `step`, `loop-until`, or `if/else`, and they are not exact product commands either. That means the plan still has not fully defined the language needed to express its own motivating case. Implementers would have to invent an iteration form and execution semantics during rollout, which makes the structure non-mechanical again.

3. [blocker] The recommended "adopt now" path is still operationally undefined for the current product, because the normative State Catalog assumes workspace selection support that the plan also says does not yet exist.

   The State Catalog makes workspace selection normative:

   - every command must run with `PLATFORM5_HOME={ws}` or an equivalent flag at `docs/acceptance-designer-plan-2026-04-17-v2.md:99`
   - state reachability examples use `platform --home {ws} ...` at `docs/acceptance-designer-plan-2026-04-17-v2.md:114` and `docs/acceptance-designer-plan-2026-04-17-v2.md:122`
   - cleanup depends on `pkill -f "platform .*--home={ws}"` at `docs/acceptance-designer-plan-2026-04-17-v2.md:106`

   But the same document then states that the product does not currently support a workspace home flag at `docs/acceptance-designer-plan-2026-04-17-v2.md:414` and still recommends adopting option `(b) now` at `docs/acceptance-designer-plan-2026-04-17-v2.md:417`.

   That fallback is not specified tightly enough to implement. If the product cannot select `{ws}`, the plan needs a second, explicit serial-only State Catalog variant with concrete command forms and reset rules for the real `~/.platform5` world. Without that, the rollout path that v2 recommends for immediate use still depends on unstated substitutions and reviewer guesswork.

## Overall Judgment

v2 does materially improve the proposal: the observation vocabulary is more explicit, the serial-only independence claim is much more honest than v1, and the document now tries to cover non-AI-verifiable commitments instead of dropping them. However, the plan is still not implementation-ready because the core classification and execution model remains incomplete.

Next step: revise v2 to separate verifier tier from action performer, either extend the Flow grammar enough to cover the flagship loop example or rewrite that example using only declared primitives, and define a fully explicit serial-only fallback syntax for products that do not yet support workspace selection.
