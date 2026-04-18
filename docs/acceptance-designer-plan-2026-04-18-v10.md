---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v10)"
type: plan
status: revised
created: 2026-04-18
supersedes: docs/acceptance-designer-plan-2026-04-18-v9.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
  - docs/acceptance-designer-plan-review-2026-04-18-v3.md
  - docs/acceptance-designer-plan-review-2026-04-18-v5.md
  - docs/acceptance-designer-plan-review-2026-04-18-v6.md
  - docs/acceptance-designer-plan-review-2026-04-18-v7.md
  - docs/acceptance-designer-plan-review-2026-04-18-v8.md
  - docs/acceptance-designer-plan-review-2026-04-18-v9.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v10)

## 0. What v10 Changes vs v9

v9 review returned **not pass** with two blockers. Both adopted.

| # | v9 blocker | v10 resolution |
| --- | --- | --- |
| V9-B1 | Two conflicting normative human outcome templates: §4.8.1 (inherited from v8) had 3 rules `fail / inconclusive / pass`, while the v9 human skeleton showed 4 rules adding `partial-coverage`. | §4.8.1 is **rewritten in v10** (no longer "unchanged from v8") with a single authoritative human template in 4-rule form. Rule 3 (`partial-coverage`) is conditional: included when the case declares branches, omitted otherwise. Both the normative template and the skeleton in §4.9 show the same 4-rule order. |
| V9-B2 | `set-outcome inconclusive-human-needed` was shadowed: rule 1 `fail` fired on any Pass-checklist item failure, including checklist items about "completion" that can never hold after an early `set-outcome` short-circuit. The declared inconclusive branch became mechanically unreachable. | §4.8.1 **reorders** outcome rules across all three tiers: the inconclusive channel now takes precedence over the fail channel. For AI: rule 1 is `set-outcome inconclusive-human-needed fired`. For human: rule 1 is `any Inconclusive signal observed`. For hybrid: rule 1 combines both. §4.8.2 updated: "authors must not reorder or weaken" now refers to the new order. §4.8.4 added: formal Flow-termination semantics stating `set-outcome inconclusive-human-needed` short-circuits the Flow and pre-empts Pass-checklist evaluation. §6.2 flagship example outcome rule updated to the new order. |

Carried forward from v9: every structural decision from v7/v8/v9 (skill-vs-project layering, Variant A/B State Catalog, actor ⟂ verifier, AI/Human observation tiers, normalized `kind=wait`, 5-primitive Flow overall shape + list-placeholder P4, Condition sub-grammar, extended `file-field` + `file-field-delta` with locked `iteration-start`, case-level Placeholders, Pass-checklist scopes, per-tier required-field lists, `Declared branches` field, `inconclusive-human-needed` narrowed to author-declared channels). This copy also makes two post-review cleanups explicit: P5 is narrowed to the single legal form `set-outcome inconclusive-human-needed`, and branch exercised-conditions explicitly exclude `for-all-iterations`.

## 1. Problem Statement

(Unchanged.)

## 2. Goals

(Unchanged.)

## 3. Non-Goals

(Unchanged.)

## 4. Proposed Structural Changes

### 4.1 Case classification

Unchanged.

### 4.2 Observation vocabulary

Unchanged.

### 4.2.1 Case-level Placeholders block

Unchanged.

### 4.3 State Catalog — Variant A and Variant B

Unchanged.

### 4.4 Section defaults

Unchanged.

### 4.5 Flow block grammar

Same as v9 **except P5 is narrowed** so the grammar is mechanically aligned with the outcome semantics.

**P5. `set-outcome`**

```markdown
- set-outcome inconclusive-human-needed
```

This is the only legal `set-outcome` form. `pass`, `fail`, and `partial-coverage` are determined by the case's outcome rule and may not be declared directly inside the Flow.

### 4.6 Condition sub-grammar

Unchanged.

### 4.7 Pass-checklist scopes

Unchanged.

### 4.8 Outcome vocabulary and rule templates

§4.8 definitions of `fail`, `inconclusive-human-needed`, `partial-coverage`, and `pass` unchanged from v8/v9. **§4.8.1 is rewritten in v10** with the reordered priority and the unified human 4-rule form. This copy also tightens §4.8.3 and §4.8.4 so the branch grammar and `set-outcome` primitive are fully closed.

#### 4.8.1 Standard outcome-rule templates (v10 reordered — resolves V9-B2)

Each case includes a priority-ordered outcome rule; first match wins. Outcome is singular.

**AI case template:**

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (include iff `Declared branches` is present)
4. Else: `pass`
```

**Human case template** (unified 4-rule form — resolves V9-B1):

```markdown
**Outcome rule (priority order, first match wins):**
1. If any Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any Fail signal was observed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (include iff `Declared branches` is present)
4. Else: `pass`
```

**Hybrid case template:**

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (include iff `Declared branches` is present)
4. Else: `pass`
```

Hybrid cases must not carry a separate `Overall pass:` line.

Rule 3 and `Declared branches` are both included or both omitted. Authors may narrow rule 3 to specific branch IDs (`branches B1 or B2`) but may not invent new branch-exercise conditions outside the `Declared branches` list.

#### 4.8.2 Shared outcome rules (updated wording)

- Outcome is **singular and deterministic** per case. No case emits more than one outcome. No case emits a primary outcome plus a secondary annotation within the closed set.
- Every case's outcome rule MUST follow the tier-specific standard template **in the v10 order**: inconclusive channel first, then fail channel, then partial-coverage (conditional), then pass. Authors may not reorder, remove, or weaken rules 1, 2, or 4. Authors may narrow rule 3 to specific branch IDs.
- `inconclusive-human-needed` is emitted only by the declared channels: `set-outcome inconclusive-human-needed` in an AI Flow, or an Inconclusive signal in a human block. No implicit emission. No other `set-outcome` value is legal.
- Environment/runtime faults that the author did not guard with an explicit inconclusive branch surface as `fail` (because no inconclusive channel fired). Runners may layer a suite-level environment-error annotation outside the case outcome, but that annotation is outside the closed vocabulary and does not change the case outcome.

#### 4.8.3 `Declared branches` field

`Declared branches` remains required iff the outcome rule contains rule 3 (`partial-coverage`), but the exercised-condition grammar is now stated explicitly instead of inheriting the full Scope-2 aggregate set.

```markdown
**Declared branches:**
- `<branch-id>`: <exercised-condition>
- `<branch-id>`: <exercised-condition>
```

Where:

- `<branch-id>` is a case-local identifier (e.g., `B1`, `B2`, `retry-loop-fired`, `reject-path-taken`). IDs are strings of letters, digits, and dashes.
- `<exercised-condition>` may use only the following forms:
  - `at-least-once in <scope>: <observation>`
  - `count-matching(<observation>) in <scope> <op> N`
  - `<observation>` (the simplest form when the branch is "a particular outcome was observed anywhere in the run")
- `for-all-iterations in <scope>: <observation>` is **not allowed** in exercised-conditions. It belongs in Pass-checklist aggregates, not branch-exercise declarations.
- For `verifier: human` cases, the only legal exercised-condition form is a plain human-tier `<observation>`; `at-least-once` and `count-matching` require a Flow-level `<scope>` that human cases do not have.

A branch is **exercised** if its exercised-condition held during the case run. Otherwise it is **unexercised**.

#### 4.8.4 Flow termination semantics (new — makes V9-B2 resolution formal)

Normative semantics for `set-outcome`:

- `set-outcome inconclusive-human-needed` is a **terminal, short-circuiting** primitive. When executed, it records `inconclusive-human-needed` and **stops Flow execution**. No primitive after it in the Flow runs.
- Pass-checklist bullets that would evaluate against Flow state are **not evaluated** when `set-outcome inconclusive-human-needed` fires. The case's outcome rule uses that declared value via rule 1 (inconclusive) of the tier's standard template.
- Expected bullets on steps that already ran before `set-outcome` fired are considered observed; they inform Pass-checklist Scope-1 bullets for audit purposes but do not override the outcome rule's precedence.
- If multiple `set-outcome inconclusive-human-needed` primitives could execute along different paths, only the first one reached fires; subsequent primitives (including further `set-outcome` calls) do not run.

This makes the standard rule 1 mechanically reachable in every shape of AI and hybrid case, resolving V9-B2.

### 4.9 Case templates

All three skeletons (AI, Human, Hybrid) carry the v10 outcome-rule order. The rest of the skeletons is unchanged from v9 §4.9.

**AI case skeleton (outcome rule block, updated):**

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`   (include iff `Declared branches` is present)
4. Else: `pass`
```

**Human case skeleton (outcome rule block, updated to unified 4-rule form):**

```markdown
**Outcome rule (priority order, first match wins):**
1. If any Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any Fail signal was observed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`   (include iff `Declared branches` is present)
4. Else: `pass`
```

**Hybrid case skeleton (outcome rule block, updated):**

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`   (include iff `Declared branches` is present)
4. Else: `pass`
```

All other skeleton fields unchanged from v9 §4.9.

### 4.10 Independence and run-lock

Unchanged.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

Shared structural rules updated:

- Outcome rule uses the **v10 priority order**: inconclusive → fail → partial-coverage (conditional) → pass. Authors may not reorder, remove, or weaken rules 1, 2, or 4.
- `set-outcome` is legal only as `set-outcome inconclusive-human-needed`; it is a short-circuiting terminal primitive (§4.8.4), and Pass-checklist bullets are not evaluated when it fires.
- Unified human outcome template (4-rule form).
- `Declared branches` exercised-conditions allow `at-least-once`, `count-matching`, or plain observation forms; `for-all-iterations` is not allowed there; `verifier: human` cases may use only the plain human-tier observation form.

Per-tier required-field lists unchanged from v9 §5.1 — each tier's required fields include the same list but the outcome-rule block now follows the v10 order.

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- §4.8.1 replaced with the v10 three tier-specific templates.
- §4.8.2 wording updated to reference the new order.
- §4.5 narrows P5 to `set-outcome inconclusive-human-needed` only.
- §4.8.3 makes the exercised-condition subset explicit, excludes `for-all-iterations`, and clarifies that human cases may use only the plain observation form.
- §4.8.4 Flow termination semantics added.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

Add one row:

| Situation | Decision |
| --- | --- |
| Case has both a `set-outcome inconclusive-human-needed` branch and Pass-checklist items about completion | Outcome is `inconclusive-human-needed` when the branch fires (rule 1); the unreached completion-oriented checklist bullets are not evaluated. Authors should review that the declared inconclusive branch really reflects an authorial decision to classify the case as inconclusive rather than fail |

All v8/v9 rows carried forward.

### 5.4 `skills/acceptance-designer/references/illustrative-examples.md`

Updates:

- §6.1 linear AI case outcome rule updated to follow the v10 AI template with rule 3 correctly omitted (no `Declared branches`; no `set-outcome` branch in practice).
- §6.2 branch+loop outcome rule reordered to v10 order (shown in §6 below).
- §6.3 human case outcome rule reordered to v10 unified 4-rule form with rule 3 omitted (no branches declared).
- §6.4 hybrid outcome rule reordered to v10 order.

## 6. Illustrative Examples (non-normative, toy `wfd`)

### 6.1 Linear AI case

Outcome rule block (replaces the v9 form):

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else: `pass`
```

(No `Declared branches`, so rule 3 `partial-coverage` is omitted.)

### 6.2 Branch + loop AI case

Outcome rule block (v10 order):

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`
4. Else: `pass`
```

Behavior check on the flagship shape: when a `{stage}-review` loop reaches `max_retries`, the Flow fires `set-outcome inconclusive-human-needed` and short-circuits. Pass-checklist bullets like "end state: `status` = completed" never evaluate. Rule 1 fires → `inconclusive-human-needed`. This is now mechanically correct (V9-B2 resolved).

If instead no loop hits `max_retries` and every stage completes normally, `set-outcome` never fires, the Pass-checklist evaluates fully, and the outcome is `pass` or `partial-coverage` depending on whether branch `B1` (at-least-once loop-until iteration) was exercised.

Flow body and Pass checklist and `Declared branches` unchanged from v9 §6.2.

### 6.3 Human case

Outcome rule block (v10 unified 4-rule form, rule 3 omitted):

```markdown
**Outcome rule (priority order, first match wins):**
1. If any Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any Fail signal was observed: `fail`
3. Else: `pass`
```

All other fields unchanged from v9 §6.3.

### 6.4 Hybrid case

Outcome rule block (v10 order):

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
3. Else: `pass`
```

All other fields unchanged from v9 §6.4.

## 7. Migration Impact

Unchanged in scope. Additional adopter instruction: existing outcome-rule blocks in any project acceptance document using v6/v7/v8/v9 shape must reorder to inconclusive-first.

## 8. Open Questions for Codex Review (v10)

Resolved in this copy:

- V9-B1 (conflicting human templates) → §4.8.1 single authoritative 4-rule form.
- V9-B2 (`set-outcome` shadowed by rule 1 `fail`) → §4.8.1 priority reordered; §4.8.4 formalizes Flow termination semantics.
- Residual v10 blocker (`set-outcome <outcome-value>` wider than semantics) → §4.5 and §4.8.4 now restrict the primitive to `set-outcome inconclusive-human-needed`.
- Residual v10 exercised-condition inconsistency → §4.8.3 now explicitly excludes `for-all-iterations`.
- Multiple `set-outcome` on different paths → §4.8.4 now makes first-wins normative; no downstream override is allowed once a `set-outcome` fires.

Carried open:

1. Derived `for-each` lists — literal-only.
2. `count-distinct` aggregate — not added.
3. Labeled loop checkpoints — not added.
4. Runner-level environment annotation — left to `delivery-qa`.
5. Author narrowing of rule 1 — disallowed (rule 1 is fixed per tier).
6. Branch-ID uniqueness scope — case-local.

## 9. Completion Criteria

- `SKILL.md` shared structural rules specify the v10 outcome-rule order and the `set-outcome` short-circuit semantics.
- `references/output-artifacts.md` carries the three v10 outcome templates plus the narrowed P5 grammar, the explicit exercised-condition subset, and §4.8.4 termination semantics.
- `references/boundary-examples.md` has the v10 row.
- `references/illustrative-examples.md` outcome-rule blocks are reordered.
- Plan passes codex review on v10.
- Mechanical audit: in every toy example that uses `set-outcome`, the declared inconclusive branch is reachable under the priority rules (not shadowed by `fail`).
- Mechanical audit: no normative syntax permits `set-outcome pass/fail/partial-coverage`, and no branch exercised-condition relies on `for-all-iterations`.

## 10. Out of Scope

(Same as prior revisions.)
