---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan (v10, post-codex-edit)"
type: review
created: 2026-04-18
target: "docs/acceptance-designer-plan-2026-04-18-v10.md (after codex's direct edits)"
reviewer: claude
prior_review: docs/acceptance-designer-plan-review-2026-04-18-v10.md (codex's review of the pre-edit v10)
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan (v10, post-codex-edit)

## Conclusion

pass (with minor editorial improvements)

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-18-v10.md` in its current state, after codex directly edited the document to address its own prior review.
- Baseline:
  - prior reviews, in order, back to `docs/acceptance-designer-plan-review-2026-04-17.md`.
  - codex's review of the pre-edit v10 at `docs/acceptance-designer-plan-review-2026-04-18-v10.md` — whose two findings (broad `set-outcome` grammar; `for-all-iterations` treatment in exercised-conditions) drove the edits.
  - v9 plan to confirm carried-forward decisions remain intact.
- Focus areas:
  - whether codex's edits actually close the two findings from the prior round.
  - whether the edits introduced any new inconsistency across §4.5 / §4.8.1–4.8.4 / §4.9 / §6.
  - whether the v9 blocker resolutions (V9-B1 unified human template; V9-B2 inconclusive-first ordering + short-circuit semantics) survived intact.

## Findings

### Blockers

None.

### Minor findings

**M1. §8 carried-open #7 is already normatively resolved in §4.8.4; it should move to "Resolved in this copy".**

§4.8.4 line 165 states normatively:

- "If multiple `set-outcome inconclusive-human-needed` primitives could execute along different paths, only the first one reached fires; subsequent primitives (including further `set-outcome` calls) do not run."

§8 line 329 nevertheless lists the same concern under "Carried open":

- "Multiple `set-outcome` on different paths. §4.8.4 says only the first reached fires. Is there ever a reason to allow a downstream `set-outcome` to override an already-fired one? Recommendation: no — first-wins is simplest and matches intuitive Flow execution."

The recommendation is already the normative rule. Leaving the item under "Carried open" misleads future reviewers into thinking an unresolved policy decision remains. Move it to "Resolved in this copy".

**M2. §4.8.3 exercised-condition grammar does not tell authors which forms apply in human cases.**

§4.8.3 allows three exercised-condition forms:

- `at-least-once in <scope>: <observation>`
- `count-matching(<observation>) in <scope> <op> N`
- `<observation>`

`<scope>` is elsewhere defined as a named `for-each` or `loop-until` **inside the Flow**. Human cases have no Flow (confirmed by §5.1 human required-fields and §4.9 human skeleton). So in a human case, only the third form — plain `<observation>`, restricted to human-tier modes — can realistically apply.

v10 allows `Declared branches` on human cases (§4.9 human skeleton notes this is "rare" but legal). Without a clarification, a human-case author following §4.8.3 literally could write `at-least-once in <scope>: <observation>` and reference an undefined `<scope>`. A single sentence in §4.8.3 closes the gap:

- "For `verifier: human` cases, the only legal exercised-condition form is a plain human-tier `<observation>`; `at-least-once` and `count-matching` require a Flow-level `<scope>` that human cases do not have."

**M3. §4.8.3 lost the v9 gloss that helped authors pick the `<observation>` form.**

The v9 §4.8.3 (my draft) included a brief gloss next to the plain `<observation>` form: "the simplest form when the branch is 'a particular outcome was observed anywhere in the run'." The current v10 §4.8.3 (codex's edit) lists only the three form names without that gloss. The form list is correct, but the gloss was useful orientation for first-time authors. Re-adding it does not affect normative surface.

**M4. §5.4 bullet for §6.1 is slightly misleading.**

§5.4 line 244:

- "§6.1 linear AI case outcome rule updated to the v10 order (no `set-outcome` branch in practice, but template form matches)."

The §6.1 rule block shown at lines 257–260 is **3 rules**, not the full 4-rule form, because the case has no `Declared branches` and therefore correctly omits rule 3. Per §4.8.1, rule 3 is conditional — "include iff `Declared branches` is present". So the §6.1 shape is legal. But "template form matches" loosely implies the case uses the full standard template. Rephrasing to "outcome rule follows the v10 tier template with rule 3 correctly omitted" would match §4.8.1's conditional-inclusion rule.

### What v10 (post-edit) got right

- **V9-B1 resolved and still clean after the edit.** §4.8.1 gives one authoritative 4-rule human template; §4.9 human skeleton cites the same 4-rule block. No conflicting normative human template remains.
- **V9-B2 resolved.** All three tier templates lead with the inconclusive channel (§4.8.1), and §4.8.4 formalizes `set-outcome` as a short-circuiting terminal primitive. The flagship §6.2 walkthrough ("when `{stage}-review` loop reaches `max_retries` ... rule 1 fires → `inconclusive-human-needed`") is mechanically correct under these rules.
- **Codex's two cleanups are sound:**
  - **§4.5 P5 narrowed** to the single legal form `set-outcome inconclusive-human-needed`. This is the right call: `pass` / `fail` / `partial-coverage` are derived outcomes; declaring them in the Flow would create two sources of truth for one outcome. Matches §4.8.2 ("No other `set-outcome` value is legal").
  - **§4.8.3 explicit exclusion of `for-all-iterations`** in exercised-conditions. Correct: "branch is exercised iff every iteration matched" collapses the branch concept into a Pass-checklist assertion and defeats `partial-coverage`.
- **Internal token consistency check passes.** `set-outcome inconclusive-human-needed` is used verbatim across §4.5 P5, §4.8.1 rule 1 (all three tiers), §4.8.2, §4.8.4, and all §6 examples that mention it.
- **Illustrative-example audit passes.** Each toy case's outcome rule correctly includes or omits rule 3 based on the presence of `Declared branches`, per §4.8.1's conditional-inclusion rule.

## Overall Judgment

v10 (post-edit) resolves both v9 blockers and closes the two grammar-scope gaps codex found in its own review. No blocker remains. The four minor findings (M1–M4) are editorial: one mis-categorized open question, one missing human-case clarification in §4.8.3, one dropped author gloss, and one imprecise §5.4 sentence.

Recommendation: **accept the plan and proceed to skill-file implementation**. M1–M4 can be applied as a small inline patch to v10 without another full revision round.

## Next Step

1. Apply M1–M4 inline to v10 (or skip if judged immaterial) and freeze v10.
2. Start implementing the three skill files per v10 §5: `skills/acceptance-designer/SKILL.md`, `references/output-artifacts.md`, `references/boundary-examples.md`, plus the new non-normative `references/illustrative-examples.md`.
3. Spot-check implementation against a rewrite of one toy case per tier to confirm the skill artifacts match the plan.
