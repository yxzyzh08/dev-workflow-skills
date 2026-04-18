---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v9)"
type: plan
status: revised
created: 2026-04-18
supersedes: docs/acceptance-designer-plan-2026-04-18-v8.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
  - docs/acceptance-designer-plan-review-2026-04-18-v3.md
  - docs/acceptance-designer-plan-review-2026-04-18-v5.md
  - docs/acceptance-designer-plan-review-2026-04-18-v6.md
  - docs/acceptance-designer-plan-review-2026-04-18-v7.md
  - docs/acceptance-designer-plan-review-2026-04-18-v8.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v9)

## 0. What v9 Changes vs v8

v8 review returned **not pass** with one blocker and one minor. Both adopted.

| # | v8 finding | v9 resolution |
| --- | --- | --- |
| V8-B1 | `partial-coverage` requires a branch to be "declared", but the schema never defined where or how to declare branches. `Declared branches` appeared only ad hoc inside one toy example. | §4.8.3 formalizes **`Declared branches`** as a standard case-schema field. §4.9 adds the field to the AI, human, and hybrid skeletons as *required when the case's outcome rule contains rule 3* (`partial-coverage`), *optional otherwise*. §5.1 per-tier lists updated. Each branch has a name and an exercised-condition expressed in the existing observation/aggregate grammar. The standard rule 3 is rewritten to reference the field generically: "if any declared branch's exercised-condition did not hold, emit `partial-coverage`". |
| V8-M2 | Hybrid toy example referenced `{wr}` without binding it anywhere — no `Extra preconditions`, no `Placeholders`, no state parameter. | §6.4 hybrid toy example gains an `Extra preconditions` line that creates the run and binds `{wr}`, matching the branch+loop toy case's pattern. |

Carried forward unchanged from v8: every structural decision from v7 and v8 (skill-vs-project layering, Variant A/B State Catalog, actor ⟂ verifier, AI/Human observation tiers, normalized `kind=wait`, 5-primitive Flow + list-placeholder P4, Condition sub-grammar, extended `file-field` + `file-field-delta` with locked `iteration-start`, case-level Placeholders, Pass-checklist scopes, per-tier required-field lists, narrowed `inconclusive-human-needed` channel, case-level singular priority-ordered outcome rules, tier-specific outcome-rule templates).

## 1. Problem Statement

(Unchanged.)

## 2. Goals

(Unchanged.)

## 3. Non-Goals

(Unchanged.)

## 4. Proposed Structural Changes

### 4.1 Case classification

Unchanged from v8 §4.1.

### 4.2 Observation vocabulary

Unchanged from v8 §4.2.

### 4.2.1 Case-level Placeholders block

Unchanged.

### 4.3 State Catalog — Variant A and Variant B

Unchanged.

### 4.4 Section defaults

Unchanged.

### 4.5 Flow block grammar

Unchanged.

### 4.6 Condition sub-grammar

Unchanged.

### 4.7 Pass-checklist scopes

Unchanged.

### 4.8 Outcome vocabulary

§4.8 definitions unchanged from v8. §4.8.1 tier-specific outcome-rule templates unchanged. §4.8.2 shared rules unchanged. **New §4.8.3** introduced below.

### 4.8.3 `Declared branches` field (new, resolves V8-B1)

When a case's outcome rule contains a `partial-coverage` line (rule 3 in the standard templates), the case **must** declare the branches whose coverage that rule protects. The declaration lives in a required field in the case header.

**Schema:**

```markdown
**Declared branches:**
- `<branch-id>`: <exercised-condition>
- `<branch-id>`: <exercised-condition>
```

Where:

- `<branch-id>` is a case-local identifier (e.g., `B1`, `B2`, `retry-loop-fired`, `reject-path-taken`). IDs are strings of letters, digits, and dashes.
- `<exercised-condition>` uses the same grammar as Pass-checklist Scope-2 aggregate bullets (§4.7). Common forms:
  - `at-least-once in <scope>: <observation>`
  - `count-matching(<observation>) in <scope> <op> N`
  - `<observation>` (a plain observation evaluated at case end; simplest form when the branch is "a particular outcome was observed anywhere in the run")

A branch is **exercised** if its exercised-condition held during the case run. Otherwise it is **unexercised**.

**Standard rule 3 (normative wording for all three tiers):**

```markdown
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`
```

Cases may further narrow rule 3 to a specific subset of branch IDs when multiple branches have different criticality. Example:

```markdown
3. Else if branches `B1` or `B2` were not exercised: `partial-coverage`
```

But they may not add new branch-exercise conditions outside the `Declared branches` list.

**Field requiredness:**

- **Required** when the outcome rule contains a `partial-coverage` line (rule 3 in standard templates).
- **Optional** (must be omitted) otherwise. Linear cases without branch coverage concerns omit both rule 3 and the field.

**Visibility in templates:** all three case skeletons (§4.9) add the field at the position `Declared branches:` → after `Placeholders` (if present), before `Flow` / `Setup for the observer` / `AI block`.

### 4.9 Case templates — updated to include `Declared branches`

**AI case skeleton** — updated (new field marked):

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** ai
**Starting state:** S<n> (<parameters if any>)
**Extra preconditions:** <case-specific delta from the state, if any>
**Placeholders:** (optional)
- `<name>` = <literal | list | file-field ref>
**Declared branches:** (required when outcome rule includes rule 3; omit otherwise)
- `<branch-id>`: <exercised-condition>
**Cleanup:** <reset target>

**Flow:**
- <P1..P5 primitives>

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) <Scope-2 bullets>
- [ ] end state: <Scope-3 bullet>

**Outcome rule (priority order, first match wins):**
1. If any Pass-checklist item failed: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`
4. Else: `pass`

**Tracked requirements:** <req ids>
```

Cases without declared branches drop the `Declared branches:` field and rule 3.

**Human case skeleton** — updated:

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** human
**verifier:** human
**Why human?** <one-line justification>
**Starting state:** S<n>
**Estimated effort:** <minutes>
**Observer qualification:** <who can do this>
**Declared branches:** (optional; required only for the rare human case that emits `partial-coverage`)
- `<branch-id>`: <exercised-condition in observable human-tier form>

**Setup for the observer:**
<numbered preparation steps>

**What to observe (human-tier modes only):**
- <visual | perceived | quality | exploratory bullets>

**What to try:**
<bounded interactions to exercise>

**Pass signals:**
<conditions under which the case passes>

**Fail signals:**
<conditions under which the case fails>

**Inconclusive signals:**
<conditions under which the observer cannot reach a verdict>

**Outcome rule (priority order, first match wins):**
1. If any Fail signal was observed: `fail`
2. Else if any Inconclusive signal was observed: `inconclusive-human-needed`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (omit when no branches declared)
4. Else: `pass`

**Recording:**
- Notes at `<acceptance-parent>/human-runs/<case-id>-<YYYYMMDD>.md`
- Attach screenshot or recording for any fail or inconclusive signal observed.

**Tracked requirements:** <req ids>
```

**Hybrid case skeleton** — updated:

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** hybrid
**Why human?** <one-line justification for the human block>
**Starting state:** S<n>
**Extra preconditions:** <case-specific delta, including any {var} bindings used below>
**Placeholders:** (optional — case level)
**Declared branches:** (required when outcome rule includes rule 3; omit otherwise)
- `<branch-id>`: <exercised-condition>
**Cleanup:** <reset target>

**AI block (Flow):**
- <P1..P5 primitives using AI-tier observation modes>

**AI pass checklist:**
- [ ] every AI-block expected bullet held
- [ ] (aggregate) <Scope-2 bullets>
- [ ] end state: <Scope-3 bullet>

**Human block:**
- What to observe: <human-tier bullets>
- What to try: <bounded interactions>
- Pass signals: <...>
- Fail signals: <...>
- Inconclusive signals: <...>
- Recording: <notes path>

**Outcome rule (priority order, first match wins):**
1. If any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (omit when no branches declared)
4. Else: `pass`

**Tracked requirements:** <req ids>
```

### 4.10 Independence and run-lock

Unchanged.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

Per-tier required-field lists gain `Declared branches`:

**Additional required fields when `verifier: ai`** (updated):
- `Flow` block using only the 5 primitives (§4.5)
- `Pass checklist` using scoped bullets (§4.7)
- `Outcome rule` in the standard AI priority-list form (§4.8.1)
- **`Declared branches` when outcome rule contains rule 3** (§4.8.3); omit otherwise

**Additional required fields when `verifier: human`** (updated):
- `Why human?`, `Estimated effort`, `Observer qualification`
- `Setup for the observer`, `What to observe`, `What to try`
- `Pass signals`, `Fail signals`, `Inconclusive signals`
- `Outcome rule` in the standard human priority-list form
- **`Declared branches` when outcome rule contains rule 3; omit otherwise**
- `Recording`
- no Flow block, no Pass checklist

**Additional required fields when `verifier: hybrid`** (updated):
- `Why human?`
- `AI block (Flow)` using AI-tier observation modes
- `AI pass checklist` with scoped bullets
- `Human block` with `What to observe` / `What to try` / `Pass signals` / `Fail signals` / `Inconclusive signals` / `Recording`
- Case-level `Outcome rule` in the standard hybrid priority-list form
- **`Declared branches` when outcome rule contains rule 3; omit otherwise**

**Shared structural rules** (v9 addition):
- `Declared branches` is required iff the outcome rule contains `partial-coverage`. The field lists branch IDs with exercised-conditions in Pass-checklist Scope-2 grammar. Rule 3 then uniformly references "any declared branch's exercised-condition did not hold".

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- §4.8.3 `Declared branches` spec added to the artifact contract with full syntax and the branch-exercise semantics.
- Case skeleton sections (ai / human / hybrid) updated to show the `Declared branches:` field and its positioning.
- No changes to the observation vocabulary, Flow grammar, or Placeholders spec.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

Add one row:

| Situation | Decision |
| --- | --- |
| Case author wants `partial-coverage` but has no branch to declare | Not valid. Either declare at least one branch with a concrete exercised-condition, or drop rule 3 and the `partial-coverage` outcome from the rule list |

### 5.4 `skills/acceptance-designer/references/illustrative-examples.md`

- §6.2 branch+loop toy example: move its informal "Declared branches" block into the formal `Declared branches` field position defined in §4.9 (same content; just positioned correctly).
- §6.4 hybrid toy example: add an `Extra preconditions` line binding `{wr}` (resolves V8-M2). Leaves outcome rule without `partial-coverage`, so the hybrid toy omits the `Declared branches` field.

## 6. Illustrative Examples (non-normative, toy `wfd`)

### 6.1 Linear AI case

Unchanged from v8 §6.1. Has no branches; outcome rule omits rule 3 and the `Declared branches` field.

### 6.2 Branch + loop AI case (formal `Declared branches` now part of schema)

```markdown
#### W.2.3 Closed-loop workflow on toy wfd  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S2 (Variant A; parameters {tpl}=T1, {proj}=P1)
**Extra preconditions:** a run has been created via `wfd run start "toy closed-loop run"`; its id is bound as `{wr}` at case start.

**Placeholders:**
- `max_retries` = file-field ~/.wfd/proj/{proj}/config.yaml -> `workflow.max_retries`
- `default-executor` = "claude-code"
- `stage-list` = ["req", "design", "impl", "final"]

**Declared branches:**
- `B1`: at-least-once in for-each {stage}: file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}-review.loop_count` ≥ 1

**Cleanup:** reset to S0

**Flow:**
(unchanged — see v7 §6.2)

**Pass checklist:**
(unchanged — see v7 §6.2)

**Outcome rule (priority order, first match wins):**
1. If any Pass-checklist item failed: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`
4. Else: `pass`

**Tracked requirements:** `r1-REQ-demo-4.2` `r1-REQ-demo-4.6`
```

`Declared branches` uses the Pass-checklist Scope-2 grammar (`at-least-once in <scope>: <observation>`). Rule 3 references the field uniformly — no case-specific rewording.

### 6.3 Human case

Unchanged from v8 §6.3. No branches; outcome rule omits rule 3; no `Declared branches` field.

### 6.4 Hybrid case (v9: `{wr}` bound, outcome uses 3-rule form without `partial-coverage`)

```markdown
#### W.4.5 Reject routing + CLI feedback quality  (r1)

**default-actor:** ai
**verifier:** hybrid
**Why human?** Routing outcome is structurally checkable; the reject-feedback message quality (does the CLI clearly convey what was rejected and where routing goes next) is a perceptual commitment.
**Starting state:** S2 (Variant A; parameters {tpl}=T1, {proj}=P1)
**Extra preconditions:** a run has been created via `wfd run start "hybrid reject run"` against {proj}; its id is bound as `{wr}` at case start. The workflow has advanced far enough that a human-gate node named `<gate>` exists and can be reached.
**Cleanup:** reset to S0

**AI block (Flow):**
- step (actor=ai): advance workflow until node `<gate>` enters `paused_at_gate`
  expected:
  - file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.<gate>.status` = "paused_at_gate" within 60s
- step (actor=human): human runs "wfd gate reject"
  expected:
  - exit-code = 0
  - log-line in ~/.wfd/proj/{proj}/runs/{wr}/log.yaml matching /gate\.reject.*by=human/ within 5s
  - file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.<gate>.status` ∈ {"failed", "rejected-route"} within 5s

**AI pass checklist:**
- [ ] every AI-block expected bullet held
- [ ] end state: file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.<gate>.routing_target` matches the workflow's configured reject branch

**Human block:**
- What to observe:
  - quality: the CLI message returned after `wfd gate reject` clearly states (a) the rejection was accepted, (b) which node was rejected, (c) where the workflow routes next.
  - visual: the TUI updates within 1s to reflect the rejected state.
- What to try: re-run the reject under an already-failed upstream node (edge).
- Pass signals: both "What to observe" bullets hold.
- Fail signals: either bullet fails.
- Inconclusive signals: the TUI or CLI becomes unresponsive before the observer can evaluate; the rejected node never appears in the visible window within 5s.
- Recording: 2-line note at `<acceptance-parent>/human-runs/W-4-5-<YYYYMMDD>.md`.

**Outcome rule (priority order, first match wins):**
1. If any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
3. Else: `pass`

**Tracked requirements:** `r1-REQ-demo-1.2.4` `r1-REQ-demo-4.6` `r1-REQ-demo-4.7` `r1-REQ-demo-6.2`
```

`{wr}` is now explicitly bound in `Extra preconditions` (resolves V8-M2). Outcome rule has no `partial-coverage` line, so the `Declared branches` field is correctly omitted.

## 7. Migration Impact

Unchanged from v8. Additional instruction for adopters:
- Any AI or hybrid case that previously declared branches informally (e.g., inside a free-prose outcome line) must move those declarations into the formal `Declared branches` field and update rule 3 to reference the field.

## 8. Open Questions for Codex Review (v9)

Resolved in v9:

- V8-B1 (declared branches undefined) → §4.8.3 formalizes the field; §4.9 places it in all three skeletons; §5.1 marks it required-when-rule-3.
- V8-M2 (unbound `{wr}`) → §6.4 binds via `Extra preconditions`.

Still carried open:

1. **Derived `for-each` lists.** Still literal-only.
2. **`count-distinct` aggregate.** Not added.
3. **Labeled loop checkpoints.** Not added.
4. **Runner-level environment annotation format.** Left to `delivery-qa`.
5. **Author narrowing of rule 1.** Disallowed.

New in v9:

6. **Branch-ID uniqueness scope.** §4.8.3 makes IDs case-local. Should cross-case reuse of the same ID (e.g., `B1` in every case in a section) be flagged by review, or is that acceptable since scope is strictly per-case? Recommendation: per-case scope; no cross-case uniqueness check required.

7. **Exercised-condition grammar restriction.** §4.8.3 says exercised-conditions use "Pass-checklist Scope-2 grammar". Scope-2 grammar includes `at-least-once`, `for-all-iterations`, and `count-matching`. Should `for-all-iterations` be explicitly *excluded* from branch exercised-conditions? A for-all branch is structurally strange ("branch is exercised iff every iteration did X") — it collapses the branch concept. Recommendation: exclude `for-all-iterations` from exercised-conditions; allow only `at-least-once`, `count-matching`, and plain single-observation forms.

## 9. Completion Criteria

- `SKILL.md` per-tier required-field lists include `Declared branches` (required-when-rule-3).
- `references/output-artifacts.md` includes §4.8.3 `Declared branches` schema.
- `references/boundary-examples.md` includes the new v9 row.
- `references/illustrative-examples.md` shows the formal `Declared branches` field in the branch+loop case and binds `{wr}` in the hybrid case.
- Plan passes codex review on v9.
- Mechanical audit: every case with rule 3 has a non-empty `Declared branches` field, and rule 3 references it correctly.

## 10. Out of Scope

(Same as prior revisions.)
