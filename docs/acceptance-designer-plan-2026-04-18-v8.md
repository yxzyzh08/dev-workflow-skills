---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v8)"
type: plan
status: revised
created: 2026-04-18
supersedes: docs/acceptance-designer-plan-2026-04-18-v7.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
  - docs/acceptance-designer-plan-review-2026-04-18-v3.md
  - docs/acceptance-designer-plan-review-2026-04-18-v5.md
  - docs/acceptance-designer-plan-review-2026-04-18-v6.md
  - docs/acceptance-designer-plan-review-2026-04-18-v7.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v8)

## 0. What v8 Changes vs v7

v7 review returned **not pass** with three outcome-model blockers. All three are surgical; v8 adopts every fix.

| # | v7 blocker | v8 resolution |
| --- | --- | --- |
| V7-B1 | Human-case structure had `Pass signals` and `Fail signals` only, with no way to declare `inconclusive-human-needed`, despite §4.8 allowing human cases to emit it. | §4.9 human skeleton adds a required `Inconclusive signals` field. §5.1 per-tier required-field list updated. §4.8 human-tier outcome rule consumes all three signal channels. §6.3 toy example adds the section. |
| V7-B2 | §4.8 defined `inconclusive-human-needed` as covering *both* `set-outcome` and "failure attributable to environment/human". The standard AI/hybrid priority template only handled `set-outcome`, leaving a mechanical gap. | §4.8 **narrows** `inconclusive-human-needed`: the outcome is emitted only via author-declared mechanisms — `set-outcome inconclusive-human-needed` in the AI Flow, or an `Inconclusive signals` hit in the human block. The "environment attribution" prose is removed. Environment-caused failures that the author did not guard with an explicit inconclusive branch become `fail`, matching what the checklist literally observed. Runners may still override the whole case with a suite-level environment-error annotation, but that is outside the case's closed outcome set. |
| V7-B3 | Hybrid outcome ownership ambiguous: priority-list said to live on the "AI block", but cases emit a singular overall outcome, and `Overall pass` field suggested a separate computation. | §4.9 hybrid skeleton rewritten: a single **case-level** priority-ordered outcome rule that explicitly references both the AI pass checklist and the Human block signals. The `Overall pass: AI AND human` line is removed (subsumed by the priority rule). §5.1 hybrid required-field list updated. |

Carried forward unchanged from v7: the skill-vs-project layering, Variant A/B State Catalog, actor ⟂ verifier, AI/Human observation tiers, normalized `kind=wait`, 5-primitive Flow + extended list-placeholder in P4, Condition sub-grammar, extended `file-field` + `file-field-delta` with locked `iteration-start` semantics, case-level Placeholders, Pass-checklist scopes, Why-human requirement, per-tier required-field lists, **exclusive** priority-ordered outcome vocabulary.

## 1. Problem Statement

(Unchanged from prior revisions.)

## 2. Goals

(Unchanged.)

## 3. Non-Goals

(Unchanged.)

## 4. Proposed Structural Changes

### 4.1 Case classification — `default-actor` and `verifier`

Unchanged from v7 §4.1.

### 4.2 Observation vocabulary — two tiers

Unchanged from v7 §4.2. `file-field-delta` checkpoint semantics locked: `iteration-start` = innermost enclosing iterator.

### 4.2.1 Case-level Placeholders block

Unchanged from v7 §4.2.1.

### 4.3 State Catalog — Variant A and Variant B

Unchanged from v7 §4.3.

### 4.4 Section defaults

Unchanged.

### 4.5 Flow block grammar — 5 primitives

Unchanged from v7 §4.5. P4 accepts `<literal-list>` or `<list-placeholder>`.

### 4.6 Condition sub-grammar

Unchanged from v7 §4.6.

### 4.7 Pass-checklist scopes

Unchanged from v7 §4.7.

### 4.8 Outcome vocabulary — narrowed and tier-specific (resolves V7-B2, drives V7-B1 and V7-B3)

Every case evaluates to **exactly one** outcome from the closed set below.

| Outcome | Meaning (narrowed) |
| --- | --- |
| `fail` | The case's primary pass condition did not hold. For AI cases: at least one Pass-checklist item failed. For human cases: at least one Fail signal was observed. For hybrid cases: at least one AI Pass-checklist item failed **or** at least one human Fail signal was observed. |
| `inconclusive-human-needed` | The case author **explicitly declared** an inconclusive path that fired. For AI cases: a `set-outcome inconclusive-human-needed` step executed in the Flow. For human cases: an Inconclusive signal was observed. For hybrid cases: either path. No implicit environment-attribution: a raw checklist failure that the author did not guard with an explicit inconclusive branch is `fail`, not `inconclusive-human-needed`. |
| `partial-coverage` | No `fail` or `inconclusive-human-needed` condition held, **but** at least one declared branch was not exercised during the run. Emitted only if the case declared branches; linear cases never emit it. |
| `pass` | None of the above; all primary pass conditions held and every declared branch was exercised. |

Runtime/environment faults that the author did not anticipate (disk full, crash, fixture missing) surface as `fail`. Runners may still layer a suite-level "environment error" annotation on top of the case outcome, but that annotation is **outside** the closed outcome set and does not replace the case's outcome.

#### 4.8.1 Standard outcome-rule template per tier

Each case must include a priority-ordered outcome rule in the form below. The first rule whose condition matches wins. Later rules are shorthand for "if none of the earlier conditions matched".

**AI case template (required):**

```markdown
**Outcome rule (priority order, first match wins):**
1. If any Pass-checklist item failed: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
3. Else if <case-specific under-coverage condition over declared branches>: `partial-coverage`
4. Else: `pass`
```

Cases with no declared branches may drop rule 3.

**Human case template (required):**

```markdown
**Outcome rule (priority order, first match wins):**
1. If any Fail signal was observed: `fail`
2. Else if any Inconclusive signal was observed: `inconclusive-human-needed`
3. Else (all Pass signals observed): `pass`
```

Human cases do not emit `partial-coverage` unless they explicitly declare branches (rare; for symmetry only).

**Hybrid case template (required — single case-level rule that references both blocks):**

```markdown
**Outcome rule (priority order, first match wins):**
1. If any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
3. Else if <case-specific under-coverage condition>: `partial-coverage`
4. Else: `pass`
```

Hybrid cases **must not** carry a separate `Overall pass:` line. The case-level outcome rule above is the only outcome computation.

#### 4.8.2 Shared rules

- Outcome is **singular and deterministic** per case. No case emits more than one outcome. No case emits a primary outcome plus a secondary annotation within the closed set.
- Every AI and hybrid case's rule 1 MUST be the standard `fail` line verbatim (possibly extended with "OR any Human Fail signal was observed" for hybrid). Authors may not rewrite rule 1 to weaken it.
- `inconclusive-human-needed` is emitted only by the declared channels: `set-outcome` in a Flow, or `Inconclusive signals` in a human block. No implicit emission.

### 4.9 Case templates

**AI case skeleton** — unchanged from v7 §4.9. Already carries the priority-ordered outcome rule per §4.8.1.

**Human case skeleton** — updated to include `Inconclusive signals` (resolves V7-B1):

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** human
**verifier:** human
**Why human?** <one-line justification>
**Starting state:** S<n>
**Estimated effort:** <minutes>
**Observer qualification:** <who can do this>

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
<conditions under which the observer cannot reach a pass/fail verdict — e.g., required fixtures unavailable, tooling crashed, observer ran out of allotted effort, access to the environment lost>

**Outcome rule (priority order, first match wins):**
1. If any Fail signal was observed: `fail`
2. Else if any Inconclusive signal was observed: `inconclusive-human-needed`
3. Else: `pass`

**Recording:**
- Notes at `<acceptance-parent>/human-runs/<case-id>-<YYYYMMDD>.md`
- Attach screenshot or recording for any fail or inconclusive signal observed.

**Tracked requirements:** <req ids>
```

**Hybrid case skeleton** — updated to carry case-level outcome rule and drop `Overall pass` (resolves V7-B3):

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** hybrid
**Why human?** <one-line justification for the human block>
**Starting state:** S<n>
**Placeholders:** (optional — case level)
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
3. Else if <declared branch not exercised>: `partial-coverage`
4. Else: `pass`

**Tracked requirements:** <req ids>
```

### 4.10 Independence and run-lock

Unchanged from v7 §4.10.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

Per-tier required-field lists updated:

**Additional required fields when `verifier: ai`** (unchanged):
- `Flow` block using only the 5 primitives (§4.5)
- `Pass checklist` using scoped bullets (§4.7)
- `Outcome rule` in the standard AI priority-list form (§4.8.1)

**Additional required fields when `verifier: human`** (updated — adds Inconclusive signals, adds outcome rule):
- `Why human?`
- `Estimated effort`
- `Observer qualification`
- `Setup for the observer`
- `What to observe` (human-tier modes only)
- `What to try`
- `Pass signals`
- `Fail signals`
- **`Inconclusive signals` (new)**
- **`Outcome rule` in the standard human priority-list form (§4.8.1) (new)**
- `Recording`
- **no Flow block, no Pass checklist**

**Additional required fields when `verifier: hybrid`** (updated — drops Overall pass, moves outcome rule to case level):
- `Why human?`
- `AI block (Flow)` using AI-tier observation modes
- `AI pass checklist` with scoped bullets
- `Human block` with `What to observe` / `What to try` / `Pass signals` / `Fail signals` / `Inconclusive signals` / `Recording`
- **Case-level `Outcome rule` in the standard hybrid priority-list form (§4.8.1)**
- ~~`Overall pass` line~~ (removed — subsumed by the case-level outcome rule)

**Shared structural rules** (v8 additions):
- Outcome rule written as a priority-ordered numbered list (first match wins); outcome is singular.
- `inconclusive-human-needed` is emitted only via declared channels (`set-outcome` in AI Flow or Inconclusive signal in human block).
- `file-field-delta` `iteration-start` binds to the innermost enclosing iterator.

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

Updates from v7:
- §4.8 outcome table uses the v8 narrowed definitions.
- §4.8.1 tier-specific outcome-rule templates appear in full.
- Hybrid case template in the reference file drops `Overall pass`.
- Human case template in the reference file adds `Inconclusive signals` and the human outcome-rule block.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

Add three rows:

| Situation | Decision |
| --- | --- |
| Environment/fixture failure caused a Pass-checklist item to fail | Outcome is `fail` (v8 §4.8). If the author wants an inconclusive outcome, the Flow must explicitly detect the environmental condition and fire `set-outcome inconclusive-human-needed` |
| Hybrid case needs a separate "AI passed but human failed" result | Not allowed as a distinct outcome. Use the case-level priority rule: rule 1 fires `fail` if either channel failed |
| Human case observer cannot complete (environment broke, ran out of time) | Declare a matching Inconclusive signal; the human outcome rule will emit `inconclusive-human-needed` via rule 2 |

### 5.4 `skills/acceptance-designer/references/illustrative-examples.md`

Non-normative. Contains the toy `wfd` examples, updated for v8:
- §6.1 linear — outcome rule unchanged (v7 form already matched v8).
- §6.2 branch + loop — outcome rule unchanged (already in priority-list form).
- §6.3 human — adds `Inconclusive signals` section and the human-tier priority outcome rule.
- §6.4 hybrid — drops `Overall pass`, adds case-level priority outcome rule.

## 6. Illustrative Examples (non-normative, toy `wfd`)

### 6.1 Linear AI case

Unchanged from v7 §6.1.

### 6.2 Branch + loop AI case

Unchanged from v7 §6.2.

### 6.3 Human case (toy, updated with Inconclusive signals)

```markdown
#### W.5.1 TUI render quality on wfd observer  (r1)

**default-actor:** human
**verifier:** human
**Why human?** Render smoothness and visual integrity are perceptual product commitments; the product exposes no stable textual surface that captures rendering artifacts.
**Starting state:** S2
**Estimated effort:** 10 minutes
**Observer qualification:** any engineer familiar with the wfd TUI.

**Setup for the observer:**
1. Open two wfd TUI instances side-by-side.
2. Start a run whose workflow will execute at least 3 nodes.

**What to observe:**
- visual: during a node transition, neither TUI retains stale content from the prior node for more than 1s.
- visual: log stream redraws without partial frames, color bleed, or cursor artifacts.
- perceived: transition feels instant (threshold: perceived lag < 1s).

**What to try:**
- Resize one terminal mid-run.
- Scroll back while the node is producing output.

**Pass signals:**
- All three "What to observe" bullets hold across all transitions and interactions.

**Fail signals:**
- Any "What to observe" bullet fails on any transition.

**Inconclusive signals:**
- One of the two TUI instances fails to start due to a tooling error unrelated to rendering.
- The run does not reach 3 node transitions within the 10-minute effort budget.
- Terminal emulator crashes or loses rendering state during the run.

**Outcome rule (priority order, first match wins):**
1. If any Fail signal was observed: `fail`
2. Else if any Inconclusive signal was observed: `inconclusive-human-needed`
3. Else: `pass`

**Recording:** notes at `<acceptance-parent>/human-runs/W-5-1-<YYYYMMDD>.md`; attach screenshot or recording for any fail or inconclusive signal.

**Tracked requirements:** `r1-REQ-demo-7.1.1`
```

### 6.4 Hybrid case (toy, case-level outcome rule)

```markdown
#### W.4.5 Reject routing + CLI feedback quality  (r1)

**default-actor:** ai
**verifier:** hybrid
**Why human?** Routing outcome is structurally checkable; the reject-feedback message quality (does the CLI clearly convey what was rejected and where routing goes next) is a perceptual commitment.
**Starting state:** S2 (Variant A; parameters {tpl}=T1, {proj}=P1)
**Cleanup:** reset to S0

**AI block (Flow):**
- step (actor=ai): advance workflow until a human-gate node enters `paused_at_gate`
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

No `Overall pass` line. Single case-level outcome rule consumes both the AI checklist and the Human block signals.

## 7. Migration Impact

Unchanged from v7. Acceptance docs rewritten under v8 must:
- Use the tier-specific standard outcome-rule template (§4.8.1).
- Human cases include Inconclusive signals.
- Hybrid cases drop `Overall pass` and carry a case-level outcome rule.

## 8. Open Questions for Codex Review (v8)

Resolved in v8:

- V7-B1 (human inconclusive) → §4.9 human skeleton + §5.1 list.
- V7-B2 (AI/hybrid `inconclusive-human-needed` coverage) → §4.8 narrows the outcome to declared channels only; `fail` covers unguarded environment failures.
- V7-B3 (hybrid outcome ownership) → §4.9 hybrid skeleton carries a single case-level priority rule; `Overall pass` removed.

Carried-open:

1. **Derived `for-each` lists.** Still literal-only.
2. **`count-distinct` aggregate.** Not added.
3. **Labeled loop checkpoints.** Not added.

New in v8:

4. **Runner-level environment annotation.** §4.8 permits runners to layer a suite-level "environment error" annotation *outside* the case's closed outcome set. Should the skill standardize the annotation format (e.g., a separate `<acceptance-parent>/runs/<run-id>/env-annotations.yaml`), or leave annotation entirely to the runner skill (`delivery-qa`)? Recommendation: leave to `delivery-qa`; keep the acceptance skill focused on case-level outcomes only.

5. **Rule 1 uniformity across tiers.** §4.8.2 requires rule 1 to be the standard `fail` line verbatim. Do we allow authors to *narrow* rule 1 (e.g., "any Pass-checklist item failed AND the failure cause is not <external-dependency-X>")? Recommendation: no — narrowing weakens the closed vocabulary. Authors who need conditional `fail` attribution must add explicit `set-outcome inconclusive-human-needed` guards in the Flow.

## 9. Completion Criteria

- `SKILL.md` per-tier required-field lists carry the v8 updates (Inconclusive signals for human; no Overall pass for hybrid; case-level outcome rule for hybrid).
- `references/output-artifacts.md` carries the tier-specific §4.8.1 outcome-rule templates and the updated case skeletons.
- `references/boundary-examples.md` has the three new v8 rows.
- `references/illustrative-examples.md` carries v8 human and hybrid examples.
- Plan passes codex review on v8.
- Mechanical audit: for each verifier tier, the tier's outcome rule covers every legal way to emit every outcome in the closed set.

## 10. Out of Scope

(Same as prior revisions.)
