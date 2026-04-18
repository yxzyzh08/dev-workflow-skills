---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v6)"
type: review
created: 2026-04-18 04:38
target: "docs/acceptance-designer-plan-2026-04-18-v6.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v6)

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-18-v6.md`
- Baseline:
  - prior reviews `docs/acceptance-designer-plan-review-2026-04-17.md`, `docs/acceptance-designer-plan-review-2026-04-17-v2.md`, `docs/acceptance-designer-plan-review-2026-04-18-v3.md`, `docs/acceptance-designer-plan-review-2026-04-18-v5.md`
  - current skill contract in `skills/acceptance-designer/SKILL.md`
  - current artifact contract in `skills/acceptance-designer/references/output-artifacts.md`
- Focus areas:
  - whether v6 resolves the three blockers from v5
  - whether the extended generic grammar is mechanically closed
  - whether the illustrative examples and file-level edits are consistent with the declared rules

## Findings

1. [blocker] The `for-each` grammar still does not match the placeholder mechanism that the flagship example depends on.

   §4.2.1 explicitly says placeholders are valid in `for-each` lists at `docs/acceptance-designer-plan-2026-04-18-v6.md:104`, and the worked example uses:

   - `for-each {stage} in \`stage-list\`` at `docs/acceptance-designer-plan-2026-04-18-v6.md:408`

   But the actual P4 grammar still only permits a literal bracketed list:

   - `for-each {var} in [<literal1>, <literal2>, ...]` at `docs/acceptance-designer-plan-2026-04-18-v6.md:220`
   - `Iteration list must be literal` at `docs/acceptance-designer-plan-2026-04-18-v6.md:225`

   The construct audit then claims the placeholder form is valid under P4 at `docs/acceptance-designer-plan-2026-04-18-v6.md:453`. As written, a reviewer still cannot mechanically decide whether `for-each` accepts only inline lists or also placeholder names bound to lists.

2. [blocker] `file-field-delta` still has unresolved checkpoint semantics at the exact place where the flagship example uses it.

   The new delta mode defines `iteration-start` as a legal checkpoint at `docs/acceptance-designer-plan-2026-04-18-v6.md:80`, and the flagship example uses it twice inside a nested `for-each` plus `loop-until` structure:

   - `... sessionId unchanged since iteration-start ...` at `docs/acceptance-designer-plan-2026-04-18-v6.md:421`
   - `... loop_count increased by at-least 1 since iteration-start ...` at `docs/acceptance-designer-plan-2026-04-18-v6.md:422`

   But §8 still leaves the key semantic unresolved:

   - `iteration-start` inside nested loops is still an open question at `docs/acceptance-designer-plan-2026-04-18-v6.md:497`

   Because the grammar does not yet define whether `iteration-start` means the enclosing `for-each` iteration or the inner `loop-until` iteration, the central example still cannot be evaluated unambiguously.

3. [blocker] Outcome semantics are still ambiguous for `partial-coverage`, so the example does not map cleanly onto the closed outcome vocabulary.

   §4.8 presents outcomes as a closed set of case results at `docs/acceptance-designer-plan-2026-04-18-v6.md:155`, including `pass`, `fail`, `inconclusive-human-needed`, and `partial-coverage`.

   However, the flagship example's outcome rule says:

   - `Outcome on checklist-all-true: pass, unless set-outcome inconclusive-human-needed fired...`
   - `Emit partial-coverage if no loop-until iterated more than once...`

   at `docs/acceptance-designer-plan-2026-04-18-v6.md:446`.

   That wording leaves the overall result unclear: is `partial-coverage` a replacement for `pass`, an additional annotation emitted alongside `pass`, or a second result channel? Since the plan treats outcomes as a closed vocabulary rather than free-form metadata, this ambiguity still blocks a mechanical implementation.

## Overall Judgment

v6 is closer than v5. The wait-step normalization is much cleaner, the per-tier field requirements now line up with the human-case template, and the added placeholder and delta concepts move the grammar in the right direction.

However, the plan is still not implementation-ready. The `for-each` grammar still disagrees with placeholder-based list reuse, `file-field-delta` depends on an unresolved nested-loop checkpoint rule, and the outcome model still does not say whether `partial-coverage` replaces `pass` or coexists with it.

Next step: update P4 so it explicitly accepts either a literal list or a list placeholder, resolve `iteration-start` normatively in §4.2 rather than leaving it as an open question, and define `partial-coverage` as either a first-class alternative outcome or a secondary annotation so the case result remains singular and deterministic.
