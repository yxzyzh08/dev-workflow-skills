---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v6)"
type: plan
status: revised
created: 2026-04-18
supersedes: docs/acceptance-designer-plan-2026-04-18-v5.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
  - docs/acceptance-designer-plan-review-2026-04-18-v3.md
  - docs/acceptance-designer-plan-review-2026-04-18-v5.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v6)

## 0. What v6 Changes vs v5

v5 review returned **not pass** with three blockers. All three are accurate; v6 adopts every fix.

| # | v5 blocker | v6 resolution |
| --- | --- | --- |
| V5-B1 | `kind=wait` had three contradictory encodings: State Catalog used `(actor=ai, kind=wait)`; §4.5 said `kind=wait` is forbidden unless `actor=system`; §6 examples used `(kind=wait)` with no actor. | §4.5 P1 normalized: `kind=wait` means "no action taken by the actor; expected bullets evaluated with time budgets". Any actor value may use it. `actor=system` **implies** `kind=wait`. Every `kind=wait` step must carry `within Ns` on every expected bullet. State Catalog schema and every example normalized to this form. |
| V5-B2 | Flagship example used comparison semantics the grammar did not declare: `≥ max_retries`, `unchanged`, `incremented`, field-to-field `≠`, and undeclared named value `max_retries`. | §4.2 extends `file-field` with numeric comparison operators; adds new mode `file-field-delta` for `unchanged` / `increased by` / `decreased by` against named checkpoints; adds binary field-to-field comparison form. §4.2.1 adds case-level **Placeholders** block for named values (`max_retries`, `default-executor`, etc.). §6.2 flagship example rewritten against the extended grammar; no undeclared token remains. |
| V5-B3 | §5.1 required every case to have Flow + Pass checklist, but the human-case skeleton has neither. | §5.1 rewritten as three per-tier required-field lists (ai / human / hybrid). The Flow + Pass-checklist requirement now explicitly applies to `ai` cases and the AI block of `hybrid` cases only. Human cases and the human block of hybrid cases use the human observation format. |

Carried forward from v5: the skill-vs-project layering (generic skill + non-normative toy examples), Variant A / B State Catalog distinction, actor ⟂ verifier split, AI/Human observation tiers, 5 Flow primitives, Condition sub-grammar, Pass-checklist scopes, outcome vocabulary, serial+run-lock rule, Why-human requirement.

## 1. Problem Statement

(Same as v5 §1.)

## 2. Goals

(Same as v5 §2.)

## 3. Non-Goals

(Same as v5 §3. Skill remains product-agnostic. Parallel execution stays out.)

## 4. Proposed Structural Changes

### 4.1 Case classification — `default-actor` and `verifier`

Unchanged from v5 §4.1.

- `default-actor` ∈ `{ai, human, system}`; steps may override with `(actor=<value>)`.
- `verifier` ∈ `{ai, human, hybrid}`, determined solely by which observation tier the expected bullets use.
- `Why human?` header required when `verifier ∈ {human, hybrid}`.

### 4.2 Observation vocabulary — two tiers

**AI-tier modes** (tokens used verbatim; v6 additions marked **new**):

| Mode | Form |
| --- | --- |
| `exit-code` | `exit-code = N` or `exit-code ∈ {N1, N2, ...}` |
| `stdout` / `stderr` | `stdout equals "..."` / `stdout contains "..."` / `stdout matches /regex/` |
| `file-exists` / `file-absent` | `file-exists <path>` / `file-absent <path>` (optional `within Ns`) |
| `directory-exists` / `directory-absent` | same form |
| `file-field` (extended) | `file-field <path> -> <dotted-key> <op> <value>` where `<op> ∈ {=, !=, <, ≤, >, ≥}` and `<value>` is a literal, a named placeholder, or a regex via `matches /r/`, or a set via `∈ {...}`, or a **field reference** `file-field <path2> -> <dotted-key2>` (enables field-to-field comparison — **new**) |
| `file-field-delta` **(new)** | `file-field-delta <path> -> <dotted-key> <delta-form> since <checkpoint>` |
| `log-line` | `log-line in <path> matching /regex/ within Ns` |
| `log-absent` | `log-absent in <path> matching /regex/ during <named-window>` |
| `process-running` / `process-absent` | `process-running matching /regex/` or `process-running pid-file <path>` |
| `socket-listening` / `socket-closed` | `socket-listening <path>` / `socket-closed <path>` |

**`file-field-delta` forms:**

```
<delta-form> ::=
    unchanged
  | increased by <N>
  | increased by at-least <N>
  | decreased by <N>
  | decreased by at-least <N>

<checkpoint> ::= case-start | step-start | iteration-start | loop-start
```

`<N>` is a non-negative integer literal or a named placeholder. `iteration-start` refers to the start of the current enclosing `for-each` or `loop-until` iteration; `loop-start` refers to the start of the enclosing loop primitive. `step-start` is the moment before the step began evaluating; `case-start` is the moment the Flow block began.

**Human-tier modes:** unchanged (`visual`, `perceived`, `quality`, `exploratory`).

Default time budget when `within Ns` is omitted: **5s**.

### 4.2.1 Case-level Placeholders block (new)

To let cases reference named values (thresholds, configured limits, default executor names) without treating them as bare tokens, every case may declare a Placeholders block in its header:

```markdown
**Placeholders:**
- `max_retries` = file-field <config-path> -> `workflow.max_retries`
- `default-executor` = "claude-code"
- `stage-list` = ["req", "design", "impl", "final"]
```

Rules:

- Left side is a bare name wrapped in backticks.
- Right side is one of: a string/number literal, a literal list, or a `file-field <path> -> <key>` reference (in which case the placeholder resolves to the current file-field value at evaluation time).
- Placeholders are valid anywhere the grammar accepts a literal (conditions, expected bullets, `for-each` lists).
- Placeholders are case-local; they do not leak across cases.

### 4.3 State Catalog — Variant A and Variant B (unchanged structure)

Unchanged from v5 §4.3. Every state schema uses project-bound placeholders (`<home-dir>`, `<service-start>`, etc.) declared at the top of the State Catalog section of each acceptance document.

Wait-step form in reach sequences is normalized per §4.5 P1 below. For example, the "become ready" step of a service-start state uses `step (actor=ai, kind=wait)` (because the AI runner is polling) rather than `step (actor=system, kind=wait)` (which would claim the product auto-advanced without an AI action — usually untrue for daemon startup).

### 4.4 Section defaults

Unchanged from v5 §4.4.

### 4.5 Flow block grammar — 5 primitives (P1 wait rule normalized)

**P1. `step` (wait semantics normalized)**

```markdown
- step (actor=<ai|human|system>[, kind=wait]): <action or wait description>
  expected:
  - <observation bullet>
```

Normalized rules:

- `actor` defaults to the case's `default-actor`. It may be omitted in a step when equal to the default.
- `kind=wait` is a **step modality**, orthogonal to actor. It means **the actor performs no external action; the step only evaluates its expected bullets with time budgets until all pass or any time budget expires**.
- `actor=system` **implies** `kind=wait` (a system step by definition has no external actor action). Authors should still write `kind=wait` alongside `actor=system` for clarity; omitting `kind=wait` when `actor=system` is a lint warning, not a hard error.
- `actor=ai` or `actor=human` may optionally use `kind=wait` when the actor is only polling/observing (e.g., "AI polls for daemon readiness after issuing start").
- **Every expected bullet under `kind=wait` must carry `within Ns`.** Missing `within Ns` on a wait-step bullet is a hard error.
- Non-wait steps must have an action description that is an exact command (for `actor=ai`), a deterministic operator instruction (for `actor=human`), or, rarely, a no-op marker (but prefer `kind=wait` instead).

**P2–P5** unchanged from v5 §4.5 (`loop-until`, `if`/`else`, `for-each`, `set-outcome`).

### 4.6 Condition sub-grammar

Unchanged from v5 §4.6 in structure. Observation-conditions now cover the extended §4.2 forms, including `file-field-delta`, numeric comparisons on `file-field`, and field-to-field comparisons.

```
<condition> ::=
    <observation-condition>       (any AI-tier form from §4.2)
  | <variable-condition>           ({var} = <lit> | {var} in [...] | {var} not in [...])
  | <compound-condition>           (<cond> and <cond> | <cond> or <cond>; one operator only)
```

Conditions may use case-level Placeholders in place of literals.

### 4.7 Pass-checklist scopes

Unchanged from v5 §4.7 (Scope 1 per-step rollup, Scope 2 case-aggregate, Scope 3 end-state). Aggregate operators: `at-least-once`, `for-all-iterations`, `count-matching`.

### 4.8 Outcome vocabulary

Unchanged from v5 §4.8: `pass`, `fail`, `inconclusive-human-needed`, `partial-coverage`.

### 4.9 Case templates — abstract skeletons (header fields aligned to §5.1 per-tier rules)

**AI case skeleton**

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** ai
**Starting state:** S<n> (<parameters if any>)
**Extra preconditions:** <case-specific delta from the state, if any>
**Placeholders:** (optional)
- `<name>` = <literal | list | file-field ref>
**Cleanup:** <reset target, usually S0>

**Flow:**
- <P1..P5 primitives>

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) <Scope-2 bullets>
- [ ] end state: <Scope-3 bullet>

**Outcome on checklist-all-true:** <pass | conditional outcome rules>.

**Tracked requirements:** <req ids>
```

**Human case skeleton**

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

**Recording:**
- Notes at `<acceptance-parent>/human-runs/<case-id>-<YYYYMMDD>.md`
- Attach screenshot for any fail signal.

**Tracked requirements:** <req ids>
```

Human cases have **no Flow block and no Pass checklist**. The "signals" sections replace the Pass checklist for this tier.

**Hybrid case skeleton**

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
- Recording: <notes path>

**Overall pass:** AI checklist passes AND human block passes.

**Tracked requirements:** <req ids>
```

### 4.10 Independence and run-lock

Unchanged from v5 §4.10.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

Replace the old "every case must include X" rule with **three per-tier required-field lists**. The skill rule section looks like:

```markdown
## Acceptance Content Rules — per verifier tier

### Required fields for every case
- release tag (e.g., `(r1)`)
- `default-actor`
- `verifier`
- `Starting state` (from State Catalog)
- Tracked requirements

### Additional required fields when `verifier: ai`
- `Flow` block using only the 5 primitives (§4.5)
- `Pass checklist` using scoped bullets (§4.7)
- outcome interpretation line

### Additional required fields when `verifier: human`
- `Why human?`
- `Estimated effort`
- `Observer qualification`
- `Setup for the observer`
- `What to observe` (human-tier modes only)
- `What to try`
- `Pass signals`
- `Fail signals`
- `Recording`
- **no Flow block, no Pass checklist** — `signals` sections replace them

### Additional required fields when `verifier: hybrid`
- `Why human?`
- `AI block (Flow)` using AI-tier observation modes
- `AI pass checklist` with scoped bullets
- `Human block` with `What to observe` / `What to try` / `Pass signals` / `Fail signals` / `Recording`
- `Overall pass` line combining the two

### Shared structural rules
- State Catalog variant declaration (A or B) at `## 3. State Catalog`
- Observations use only tokens from §4.2 tier tables
- Conditions use only the §4.6 sub-grammar
- `kind=wait` steps must have `within Ns` on every expected bullet (§4.5 P1)
- Pass-checklist bullets (ai and hybrid only) declare their scope (§4.7)
- Outcomes drawn from the closed set in §4.8
- Serial execution + run-lock under Variant A
```

Also in SKILL.md:
- `## Acceptance Item Structure` inlines the three skeletons (§4.9).
- `## Classifying a Case` explains actor ⟂ verifier and the `Why human?` requirement.
- Working Loop: pick variant → write State Catalog with project's placeholder bindings → classify each case by tier → fill the matching skeleton → review.

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- Required body sections: Document Instructions, Acceptance Preparation, **State Catalog (Variant A|B) with project placeholder declarations**, **Section Defaults (optional)**, Main-Flow Stories, Independent Acceptance Items, Next-Phase Constraints.
- Both observation-tier vocabulary tables (including `file-field-delta` and extended `file-field`).
- Case-level Placeholders block spec (§4.2.1).
- Flow grammar: 5 primitives + normalized `kind=wait` rule.
- Condition sub-grammar.
- Pass-checklist scope table.
- Outcome vocabulary table.
- **Per-tier required-field lists (as in §5.1)**, with each skeleton.
- Generic snippets only — no product specifics.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

Rows carried from v5 with wording generalized:

| Situation | Decision |
| --- | --- |
| Case shares setup with siblings | Define in State Catalog; cases reference state ID |
| Case cannot use AI-tier modes for a product commitment | `verifier: human` or `hybrid`; never silently omitted |
| Case has human-typed gate but all AI-tier observations | `default-actor: ai`, step override `(actor=human)`, `verifier: ai` |
| Author claims `human` to avoid writing mechanical assertions | Reviewer challenges `Why human?`; reclassifies |
| Case depends on previous case's tail state | Rejected; every case resets |
| Product offers no workspace flag | Variant A; do not invent a flag |
| Construct outside the 5 primitives / Condition grammar needed | Rewrite via nesting; else file grammar RFC |
| "Across the case" assertion needed | Scope-2 aggregate Pass-checklist bullet |
| Need a numeric threshold (`max_retries`, `timeout_ms`, etc.) in conditions | Declare via case-level Placeholders (§4.2.1); do not use a bare unquoted token |
| Need "session unchanged" or "counter incremented" assertions | Use `file-field-delta` (§4.2); do not invent verbal forms |
| Step has no external action and just waits for state | `kind=wait` with `within Ns` on every expected bullet; actor remains whoever is polling |

### 5.4 `skills/acceptance-designer/references/illustrative-examples.md`

Non-normative. Uses a toy product `wfd` (see §6).

## 6. Illustrative Examples (non-normative, toy product)

Toy product assumptions unchanged from v5 §6. Examples below use the extended v6 grammar.

### 6.1 Linear AI case (toy, wait form normalized)

```markdown
#### W.1.1 Service start/stop  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S0 (Variant A, <home-dir>=~/.wfd, <pid-file>=~/.wfd/wfd.pid, <socket>=~/.wfd/wfd.sock, <process-pattern>=/wfd-server/)
**Cleanup:** reset to S0

**Flow:**
- step: `wfd service start --daemon`
  expected:
  - exit-code = 0
- step (actor=ai, kind=wait): poll until daemon is ready
  expected:
  - file-exists ~/.wfd/wfd.pid within 5s
  - socket-listening ~/.wfd/wfd.sock within 5s
  - exit-code = 0 from `wfd service status` within 5s
- step: `wfd service stop`
  expected:
  - exit-code = 0
- step (actor=ai, kind=wait): poll until daemon is down
  expected:
  - file-absent ~/.wfd/wfd.sock within 5s
  - process-absent matching /wfd-server/ within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) log-absent in ~/.wfd/logs/wfd.log matching /level=error/ during the case window

**Outcome on checklist-all-true:** `pass`.

**Tracked requirements:** `r1-REQ-demo-1.1`
```

Every wait step now carries explicit `actor=ai, kind=wait` and every expected bullet carries `within Ns`. No `(kind=wait)` without actor.

### 6.2 Branch + loop AI case (toy, grammar extensions in use)

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

**Cleanup:** reset to S0

**Flow:**
- for-each {stage} in `stage-list`:
  - step (actor=system, kind=wait): workflow completes producer node `{stage}`
    expected:
    - file-exists ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}.yaml within 300s
    - file-field ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}.yaml -> `outcome` ∈ {"pass", "not_pass"} within 5s
  - loop-until `file-field ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}-review.yaml -> outcome = "pass"` or `file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> nodes.{stage}-review.loop_count ≥ max_retries`:
    - step (actor=system, kind=wait): review node completes
      expected:
      - file-exists ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}-review.yaml within 300s
      - file-field ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}-review.yaml -> `outcome` ∈ {"pass", "not_pass"} within 5s
    - if `file-field ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}-review.yaml -> outcome = "not_pass"`:
      - step (actor=system, kind=wait): workflow routes back to {stage}
        expected:
        - file-field-delta ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> nodes.{stage}.sessionId unchanged since iteration-start within 60s
        - file-field-delta ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> nodes.{stage}.loop_count increased by at-least 1 since iteration-start within 60s
  - if `file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> nodes.{stage}-review.loop_count ≥ max_retries`:
    - set-outcome inconclusive-human-needed
  - else:
    - if `{stage} in ["req"]`:
      - step (actor=human): human runs "wfd gate freeze"
        expected:
        - exit-code = 0
        - file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> nodes.{stage}.status = "completed" within 5s
        - log-line in ~/.wfd/proj/{proj}/runs/{wr}/log.yaml matching /gate\.freeze.*by=human/ within 5s
    - else:
      - step (actor=human): human runs "wfd gate approve"
        expected:
        - exit-code = 0
        - file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> nodes.{stage}.status = "completed" within 5s
        - log-line in ~/.wfd/proj/{proj}/runs/{wr}/log.yaml matching /gate\.approve.*by=human/ within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) at-least-once in for-each {stage}: file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.executor` != file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}-review.executor`
- [ ] (aggregate) count-matching(file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.executor` != default-executor) in for-each {stage} ≥ 2
- [ ] (aggregate) log-absent in ~/.wfd/logs/wfd.log matching /level=error/ during the case window
- [ ] end state: file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `status` = "completed"

**Outcome on checklist-all-true:** `pass`, unless `set-outcome inconclusive-human-needed` fired (then `inconclusive-human-needed`). Emit `partial-coverage` if no `loop-until` iterated more than once across any stage.

**Tracked requirements:** `r1-REQ-demo-4.2` `r1-REQ-demo-4.6`
```

Construct audit vs declared grammar:

- `for-each {stage} in <placeholder>` ✓ (P4; list comes from Placeholder `stage-list`)
- `step (actor=system, kind=wait)` with `within Ns` on every bullet ✓ (P1 normalized)
- `step (actor=human)` with exact command-typing instruction ✓ (P1)
- `loop-until <compound-condition with or>` ✓ (P2 + Condition)
- `file-field ... ≥ max_retries` ✓ (§4.2 extended `file-field`; `max_retries` resolved via Placeholders)
- `file-field-delta ... unchanged since iteration-start within 60s` ✓ (§4.2 new mode)
- `file-field-delta ... increased by at-least 1 since iteration-start within 60s` ✓ (§4.2 new mode)
- `{stage} in ["req"]` ✓ (variable-condition form)
- `set-outcome inconclusive-human-needed` ✓ (P5 + outcome vocab)
- Scope-2 aggregates with `at-least-once` and `count-matching(...) ≥ 2` ✓ (§4.7)
- Field-to-field comparison `file-field ... != file-field ...` ✓ (§4.2 extended `file-field`)

No undeclared token remains.

### 6.3 Human case (toy)

Unchanged from v5 §6.3. Has no Flow block and no Pass checklist (per §5.1 per-tier rules).

### 6.4 Hybrid case (toy)

Carried in `references/illustrative-examples.md`. Header: `default-actor: ai`, `verifier: hybrid`, `Why human?: ...`. Structure: AI block (Flow + AI pass checklist) + Human block (signals format).

## 7. Migration Impact

Unchanged from v5 §7. Skill adoption requires only updating the three skill files (plus the new non-normative `illustrative-examples.md`). Per-project acceptance-doc rewrites are project work.

## 8. Open Questions for Codex Review (v6)

Resolved in v6:

- v5 wait-step ambiguity → §4.5 P1 normalized.
- v5 missing comparison/delta/field-to-field semantics → §4.2 extended.
- v5 unnamed literal `max_retries` → §4.2.1 case-level Placeholders block.
- v5 SKILL.md rule over-broad for human cases → §5.1 per-tier required-field lists.

Carried-open from v5:

1. **Derived `for-each` lists.** Still literal-only (or via a Placeholder bound to a literal list). Revisit on first concrete case that genuinely needs a derived source.
2. **`count-distinct` aggregate.** Not added. `count-matching` with field-to-field comparison covers many cases; distinct counts remain open.

New v6 question:

3. **Placeholder right-hand side types.** §4.2.1 allows literal, list, or `file-field` reference. Should it also allow a computed form (e.g., `stage-list_without_first` = tail of a list)? Recommendation: no — if authors need derived values, compute them by defining additional Placeholders explicitly.

4. **`file-field-delta` checkpoint semantics inside nested loops.** `iteration-start` refers to the nearest enclosing `for-each` **or** `loop-until`. If both are nested, which counts? Recommendation: the **innermost** enclosing iterator. Document this in §4.2.

## 9. Completion Criteria

- `SKILL.md` carries the three per-tier required-field lists and the shared structural rules; no product-specific commands/paths/fields.
- `references/output-artifacts.md` carries the extended vocabulary, Placeholders spec, grammar, per-tier skeletons, and scope tables — all with generic snippets.
- `references/boundary-examples.md` has all §5.3 rows.
- `references/illustrative-examples.md` exists, is flagged non-normative, and uses the toy `wfd`.
- Plan passes codex review on v6.
- A mechanical audit of §6.2 against the declared grammar passes (every construct has a clear grammar rule citation).

## 10. Out of Scope

(Same as v5 §10.)
