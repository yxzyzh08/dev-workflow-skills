---
name: acceptance-designer
description: Use when turning frozen requirements into human E2E acceptance documents and acceptance review cycles
---

# Acceptance Designer

## Overview

This skill owns workflow Steps 4-6: turning frozen requirements into the human E2E acceptance baseline. It defines what must be formally accepted before the project can move downstream into implementation and delivery.

Acceptance cases produced under this skill are structured for **mechanical verification**: every step pairs an action with tool-checkable expected observations, every case declares an outcome rule with deterministic priority, and every case classifies whether it can be run by AI autonomously, by a human observer, or by both.

## Support Files

Use these assets for the full grammar and repeatable checks:

- `references/output-artifacts.md` — full authoring grammar: observation vocabulary, Flow primitives, Condition sub-grammar, Pass-checklist scopes, outcome templates, State Catalog variants, case skeletons, required-field lists.
- `references/boundary-examples.md` — decisions for edge cases and scope boundaries versus other skills.
- `references/illustrative-examples.md` — non-normative worked examples on a hypothetical toy product, illustrating each case tier.

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before touching stage work.

## When to Use

Use this skill when the human wants to:

- write or revise the configured acceptance baseline from `paths.acceptance`
- design the human E2E acceptance surface from frozen requirements
- review acceptance quality or output an acceptance review report
- respond to acceptance review findings
- reopen acceptance work after an approved CR

Do not use this skill for requirement clarification, architecture design, detailed design, coding, or E2E execution.

## Inputs

- configured requirements baseline from `paths.requirements`
- human alignment feedback
- any approved CR that reopens acceptance work
- existing acceptance baseline from `paths.acceptance`, if present
- for r2+ releases: prior release requirements baseline as optional context

## Outputs

- acceptance baseline stored at `paths.acceptance`
- acceptance review reports stored under `<from paths.acceptance parent>/reviews/acc-review-{nn}.md`

## Working Loop

1. Read the frozen requirements and identify the formal acceptance surface.
2. Pick the **State Catalog variant** based on product capability:
   - Variant A (serial-only, singleton shared state) is the default. Requires a suite-level run-lock.
   - Variant B (workspace-parameterized) only when the product accepts a per-workspace home/flag.
3. Write the State Catalog section first, binding project-specific placeholders (service commands, home directory, PID file, state file, etc.) once.
4. Write acceptance preparation work and main-flow cases.
5. **Classify each case** by `default-actor` and `verifier` (see "Classifying a Case" below).
6. Fill the matching case skeleton (ai / human / hybrid) per `references/output-artifacts.md`.
7. Add independent formal acceptance items only when non-normal paths are product commitments, governance gates, or recovery capabilities.
8. Produce a review report when asked to review the acceptance document.
9. Revise from review findings.
10. Return to the human confirmation gate after review-driven edits.
11. Freeze the acceptance document only after review passes and the human confirms alignment.

## Classifying a Case

Every case declares two independent classification fields:

**`default-actor`** (who drives each step) — one of:
- `ai` — AI executor runs steps autonomously
- `human` — a human performs the action (typing deterministic CLI commands, observing UI, judgment-requiring interaction)
- `system` — no external action; the product or workflow auto-advances. Always pairs with `kind=wait` on the step.

Individual steps may override with `(actor=<value>)`. Gate-typing humans use `actor=human` — there is no separate `human-gate` value.

**`verifier`** (which observation tier the expected bullets use) — one of:
- `ai` — every expected bullet uses AI-tier modes (`exit-code`, `file-field`, `log-line`, etc.)
- `human` — every expected bullet uses human-tier modes (`visual`, `perceived`, `quality`, `exploratory`)
- `hybrid` — mix; case splits into AI block + Human block

**Key rule: actor and verifier are independent.** A case with human-typed gates and all AI-tier observations is `verifier: ai`, not `hybrid`. Tier is determined solely by observation modes, not by who typed a command.

**`Why human?`** is a required header field when `verifier ∈ {human, hybrid}`: one line justifying why no AI-tier mode suffices. Reviewers may challenge.

## Acceptance Content Rules — per verifier tier

### Required for every case

- release tag (e.g., `(r1)`)
- `default-actor`
- `verifier`
- `Starting state` (from the State Catalog)
- Tracked requirements (requirement IDs or `X` track IDs)

### Additional required fields when `verifier: ai`

- `Flow` block using only the 5 declared primitives (`step`, `loop-until`, `if`/`else`, `for-each`, `set-outcome`)
- `Pass checklist` with scoped bullets (per-step rollup / case-aggregate / end-state)
- `Outcome rule` in the standard AI priority-list form
- `Declared branches` when the outcome rule contains rule 3 (`partial-coverage`); omitted otherwise

### Additional required fields when `verifier: human`

- `Why human?`, `Estimated effort`, `Observer qualification`
- `Setup for the observer`, `What to observe` (human-tier modes only), `What to try`
- `Pass signals`, `Fail signals`, **`Inconclusive signals`**
- `Outcome rule` in the standard human priority-list form
- `Declared branches` when the outcome rule contains rule 3; omitted otherwise
- `Recording`
- **no Flow block, no Pass checklist** — the signals sections replace them

### Additional required fields when `verifier: hybrid`

- `Why human?`
- `AI block (Flow)` using AI-tier observation modes
- `AI pass checklist` with scoped bullets
- `Human block` with `What to observe` / `What to try` / `Pass signals` / `Fail signals` / `Inconclusive signals` / `Recording`
- **Case-level `Outcome rule`** in the standard hybrid priority-list form (references both blocks)
- `Declared branches` when the outcome rule contains rule 3; omitted otherwise
- **no `Overall pass:` line** — subsumed by the case-level outcome rule

### Shared structural rules (all tiers)

- `## 3. State Catalog` declares the variant (A or B) in its heading. No mixing variants in one document.
- Observations use only declared tokens from the two tier vocabularies (`references/output-artifacts.md`).
- Conditions use only the declared Condition sub-grammar.
- `kind=wait` steps must have `within Ns` on every expected bullet.
- Pass-checklist bullets (ai and hybrid only) declare their scope.
- **Outcome rule uses the priority order**: inconclusive → fail → partial-coverage (conditional) → pass. Authors may not reorder, remove, or weaken rules 1, 2, or 4. Rule 3 may be narrowed to specific branch IDs.
- **Outcome is singular** per case; no secondary annotation within the closed vocabulary.
- **`set-outcome` is legal only as `set-outcome inconclusive-human-needed`**. It is a terminal, short-circuiting primitive; Pass-checklist bullets are not evaluated when it fires. First-reached wins if multiple paths could fire.
- `inconclusive-human-needed` is emitted only via declared channels (`set-outcome` in AI Flow, or Inconclusive signal in human block). Environment faults unguarded by an explicit inconclusive branch surface as `fail`.
- `Declared branches` exercised-conditions allow `at-least-once`, `count-matching`, or plain `<observation>`; `for-all-iterations` is not allowed. For `verifier: human` cases, only plain human-tier `<observation>` is legal (no Flow-level `<scope>` exists).
- Every formal acceptance item traces back to a requirement ID or `X` track ID. Unbranched requirements track to level 2; branched requirements track to level 3 `must-have` items.
- Each case carries a release tag (e.g., `(r1)`). When modified in a later release: `(r1→r3 modified)` — origin and latest only, never chain intermediates. Tags go on individual cases, not group headers.
- Default coverage is main flow + formal product commitments only. Non-normal paths appear only when they are product commitments, governance gates, or recovery capabilities.
- UI flows are described in Markdown — no HTML, no prototypes.
- Under Variant A: serial execution + run-lock. Every case resets to its Starting state.

## Acceptance Item Structure

Three skeletons follow. Full expanded versions with all optional fields live in `references/output-artifacts.md`.

### AI case skeleton

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** ai
**Starting state:** S<n> (<parameters if any>)
**Extra preconditions:** <case-specific delta, if any>
**Placeholders:** (optional)
- `<name>` = <literal | list | file-field ref>
**Declared branches:** (required iff outcome rule contains rule 3)
- `<branch-id>`: <exercised-condition>
**Cleanup:** <reset target>

**Flow:**
- <P1..P5 primitives>

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) <Scope-2 bullets>
- [ ] end state: <Scope-3 bullet>

**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (include iff `Declared branches` is present)
4. Else: `pass`

**Tracked requirements:** <req ids>
```

### Human case skeleton

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** human
**verifier:** human
**Why human?** <one-line justification>
**Starting state:** S<n>
**Estimated effort:** <minutes>
**Observer qualification:** <who can do this>
**Declared branches:** (optional; required iff outcome rule contains rule 3)
- `<branch-id>`: <plain human-tier observation>

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
<conditions under which the observer cannot reach a pass/fail verdict>

**Outcome rule (priority order, first match wins):**
1. If any Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any Fail signal was observed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (include iff `Declared branches` is present)
4. Else: `pass`

**Recording:**
- Notes at `<acceptance-parent>/human-runs/<case-id>-<YYYYMMDD>.md`
- Attach screenshot or recording for any fail or inconclusive signal.

**Tracked requirements:** <req ids>
```

### Hybrid case skeleton

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** hybrid
**Why human?** <one-line justification for the human block>
**Starting state:** S<n>
**Extra preconditions:** <case-specific delta, including any {var} bindings used below>
**Placeholders:** (optional)
**Declared branches:** (required iff outcome rule contains rule 3)
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
1. If `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (include iff `Declared branches` is present)
4. Else: `pass`

**Tracked requirements:** <req ids>
```

## Upstream Change Handling

- If acceptance work finds only a small upstream clarification, update the frozen requirements in place with `change_history`.
- If acceptance work finds a large upstream change, create or continue `<from paths.changes_dir>/cr-{nn}.md`, return to the requirement stage, then re-enter acceptance after the upstream loop completes.
- Do not silently widen requirement scope from inside the acceptance document.

## Review and Human Gate Rules

- Review reports must follow the shared review format from `workflow-protocol`.
- Review-driven edits must go back to the human for alignment before another review round.
- If the same acceptance artifact or review/revise loop exceeds 3 rounds without convergence, stop and escalate to the human.
- If the human rejects the current acceptance framing, continue refinement instead of freezing.
- Acceptance review focuses on:
  - per-tier required-field completeness (ai / human / hybrid)
  - Flow uses only declared primitives and Condition grammar
  - outcome rule follows the tier's priority-list template verbatim
  - `set-outcome` is only `set-outcome inconclusive-human-needed`; no other value
  - `Declared branches` present iff outcome rule contains rule 3
  - tool-checkability of AI-tier expected bullets
  - requirement traceability
  - formal inclusion of non-normal paths per the rule
  - staying inside the frozen requirement boundary

## Completion Checklist

- The acceptance baseline at `paths.acceptance` exists.
- State Catalog declares its variant (A or B).
- Main-flow cases and preparation work are present; independent acceptance items appear only under the formal inclusion rule.
- Every case carries: release tag, `default-actor`, `verifier`, Starting state, Tracked requirements, plus tier-specific required fields.
- Every case's outcome rule uses the v10 priority order; `set-outcome` (if any) is only `set-outcome inconclusive-human-needed`.
- Every formal acceptance item traces to a requirement or `X` ID.
- `Declared branches` present iff outcome rule contains rule 3.
- The review report exists when a review task was requested.
- Progress artifacts are updated per `workflow-protocol` (dashboard + history).
