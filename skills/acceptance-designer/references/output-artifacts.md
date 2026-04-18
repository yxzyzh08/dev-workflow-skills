# Acceptance Output Artifacts Reference

Full authoring grammar for acceptance baselines and review reports. Use this file to verify that an acceptance document conforms to the skill contract.

The skill itself is product-agnostic. Commands, paths, and field names in examples below are placeholders (e.g., `<home-dir>`, `<service-start>`, `<result-field>`). Each project binds these placeholders in its own acceptance document. See `illustrative-examples.md` for non-normative worked examples on a toy product.

## 1. Acceptance Baseline (`paths.acceptance`)

### 1.1 Required Frontmatter

| Field | Required | Notes |
| --- | --- | --- |
| `title` | yes | Human-readable document title |
| `type` | yes | Must be `acceptance` |
| `status` | yes | `draft`, `active`, or `frozen` |
| `version` | yes | Document revision number, e.g., `"0.4"` |
| `created` | yes | `YYYY-MM-DD HH:mm` |
| `last_modified` | yes | `YYYY-MM-DD HH:mm` |
| `author` | yes | Agent identifier or `human` |
| `upstream` | recommended | e.g., `paths.requirements` |
| `downstream` | recommended | e.g., `paths.architecture` |
| `change_history` | yes | Each entry: `date`, `author`, `description` |

### 1.2 Required Body Sections

1. **Document Instructions** — usage rules:
   - Default coverage is main flow + formal product commitments only.
   - Non-normal paths appear only when they are product commitments, governance gates, or recovery capabilities.
   - Each case must conform to the per-tier required-field list (§5).
   - Process descriptions in Markdown, not HTML/prototypes.

2. **Acceptance Preparation** — test fixture setup:
   - Fixed acceptance fixtures (templates, workflows, configs).
   - Repository and configuration assets.
   - Observation and fault-injection preparation.

3. **State Catalog (Variant A | Variant B)** — named named states used by cases. The section heading must declare the variant. See §2.

4. **Section Defaults** (optional per subsection) — default `Starting state`, `Cleanup`, `Verifier`, `default-actor` inherited by child cases.

5. **Main-Flow Acceptance Stories** — one case per acceptance item, using the per-tier skeleton (§4).

6. **Independent Formal Acceptance Items** — non-main-flow items meeting the formal inclusion rule (governance gates, recovery capabilities, isolation boundaries, runtime correctness).

7. **Next-Phase Constraints** — constraints for downstream stages.

### 1.3 Release Tag Convention

- Cases carry release origin tags: `(r1)`.
- When modified in a later release: `(r1→r3 modified)` — show origin and latest only.
- Do NOT chain: `(r1→r2→r3 modified)` is illegal.
- Tags go on individual cases, not group headers.

### 1.4 Traceability Contract

- Every formal acceptance item traces to at least one requirement ID or `X` track ID.
- Unbranched requirements track to level 2.
- Branched requirements track to level 3 `must-have` items.

## 2. State Catalog

### 2.1 Variant declaration

The `## 3. State Catalog` heading of the acceptance document must declare one variant:

```markdown
## 3. State Catalog (Variant A — serial-only, singleton home)
```
or
```markdown
## 3. State Catalog (Variant B — workspace-parameterized)
```

Mixing variants in a single document is not permitted.

### 2.2 Variant A — Serial-only, singleton shared state

Use when the product has global/user-level shared state (singleton home, shared socket, shared config) that cannot be isolated per case.

**Required suite-level rules block:**

```markdown
### 3.0 Suite-level rules
- Run-lock: flock on <acceptance-parent>/.acceptance-run.lock at case start; release at cleanup.
- Serialization: one case at a time. Parallel runs are not supported.
- Shared state location: <home-dir>. Reset to Starting state guarantees independence.
- Fixture root: <fixture-root>.
```

**Required schema for each state:**

```markdown
### S<n> — <short semantic name> [(extends S<m>)] [(parameters: {p1}, {p2})]

**Invariants:**
- <AI-tier observation>
- <AI-tier observation>

**How to reach:** [from S<m>:]
- step (actor=ai): <exact command expressed with project's placeholder bindings>
  expected:
  - <observation confirming command succeeded>
- step (actor=ai, kind=wait): <description of what becomes true>
  expected:
  - <every invariant of the target state, each with within Ns>
```

Rules:

- Invariants use only AI-tier observation modes (§6).
- The last reach step's `expected` bullets enumerate **every** invariant of the target state. Reaching the state *is* the verification; no separate "verify invariants" pseudo-step.
- State parameters (`{tpl}`, `{proj}`, `{wr}`, etc.) are case-local textual bindings.
- Reset to Starting state climbs from S0 up unless the case explicitly opts into an incremental reset and re-verifies invariants.

### 2.3 Variant B — Workspace-parameterized

Use only when the product supports a per-workspace home/flag. Same schema as Variant A, but every state signature includes `{ws}` and every command operates on `{ws}`. Enables future parallel execution.

## 3. Section Defaults

A subsection of the acceptance document may declare defaults inherited by all cases inside it. Case-level fields override.

```markdown
**Section defaults:**
- **Starting state:** S<n> (<parameters>)
- **Cleanup:** reset to S0
- **Verifier:** ai
- **default-actor:** ai
```

Section defaults are optional. If absent, each case declares its own.

## 4. Case Structure

### 4.1 Case-level Placeholders block

Every case may declare a Placeholders block in its header. Placeholders become valid literals anywhere the grammar accepts a literal (conditions, expected bullets, `for-each` list sources).

```markdown
**Placeholders:**
- `<name>` = <string-or-number-literal> | [<literal>, ...] | file-field <path> -> <key>
```

Rules:

- Left side is a bare name wrapped in backticks.
- Right side is: a literal, a literal list, or a `file-field <path> -> <key>` reference.
- Placeholders are case-local; they do not leak across cases.
- A list-placeholder (right side = literal list) is the only way to use a non-literal source in `for-each` (§7 P4).

### 4.2 AI case skeleton

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** ai
**Starting state:** S<n> (<parameters if any>)
**Extra preconditions:** <case-specific delta, if any>
**Placeholders:** (optional)
- `<name>` = ...
**Declared branches:** (required iff outcome rule contains rule 3; omit otherwise)
- `<branch-id>`: <exercised-condition>
**Cleanup:** <reset target>

**Flow:**
- <P1..P5 primitives using AI-tier observation modes>

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

### 4.3 Human case skeleton

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
<conditions under which the observer cannot reach a pass/fail verdict — e.g., required fixtures unavailable, tooling crashed, observer ran out of allotted effort>

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

Human cases have **no Flow block and no Pass checklist**. The "signals" sections replace them.

### 4.4 Hybrid case skeleton

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

Hybrid cases must not carry a separate `Overall pass:` line. The case-level outcome rule is the only outcome computation.

## 5. Per-Tier Required Fields

### 5.1 Required for every case

- release tag
- `default-actor`
- `verifier`
- `Starting state`
- Tracked requirements

### 5.2 `verifier: ai` — additional required fields

- `Flow` block (5 primitives only)
- `Pass checklist` (scoped bullets)
- `Outcome rule` in the standard AI priority-list form
- `Declared branches` when rule 3 is present; omitted otherwise

### 5.3 `verifier: human` — additional required fields

- `Why human?`, `Estimated effort`, `Observer qualification`
- `Setup for the observer`, `What to observe`, `What to try`
- `Pass signals`, `Fail signals`, `Inconclusive signals`
- `Outcome rule` in the standard human priority-list form
- `Declared branches` when rule 3 is present; omitted otherwise
- `Recording`
- **no Flow, no Pass checklist**

### 5.4 `verifier: hybrid` — additional required fields

- `Why human?`
- `AI block (Flow)`
- `AI pass checklist`
- `Human block` with `What to observe` / `What to try` / `Pass signals` / `Fail signals` / `Inconclusive signals` / `Recording`
- Case-level `Outcome rule` in the standard hybrid priority-list form
- `Declared branches` when rule 3 is present; omitted otherwise
- **no `Overall pass:` line**

## 6. Observation Vocabulary

Two tiers. The exact token names below are normative; examples must use these spellings verbatim.

### 6.1 AI-tier modes

| Mode | Form |
| --- | --- |
| `exit-code` | `exit-code = N` or `exit-code ∈ {N1, N2, ...}` |
| `stdout` / `stderr` | `stdout equals "..."` / `stdout contains "..."` / `stdout matches /regex/` |
| `file-exists` / `file-absent` | `file-exists <path>` / `file-absent <path>` (optional `within Ns`) |
| `directory-exists` / `directory-absent` | same form |
| `file-field` | `file-field <path> -> <dotted-key> <op> <value>` where `<op> ∈ {=, !=, <, ≤, >, ≥}` and `<value>` is a literal, a named placeholder, a regex via `matches /r/`, a literal set via `∈ {...}`, or a field reference `file-field <path2> -> <key2>` (field-to-field comparison) |
| `file-field-delta` | `file-field-delta <path> -> <dotted-key> <delta-form> since <checkpoint>` (see §6.1.1) |
| `log-line` | `log-line in <path> matching /regex/ within Ns` |
| `log-absent` | `log-absent in <path> matching /regex/ during <named-window>` |
| `process-running` / `process-absent` | `process-running matching /regex/` or `process-running pid-file <path>`; symmetric for `process-absent` |
| `socket-listening` / `socket-closed` | `socket-listening <path>` / `socket-closed <path>` |

Default time budget when `within Ns` is omitted: **5s**. Per-bullet override allowed.

#### 6.1.1 `file-field-delta` form and checkpoints

```
<delta-form> ::=
    unchanged
  | increased by <N>
  | increased by at-least <N>
  | decreased by <N>
  | decreased by at-least <N>

<checkpoint> ::= case-start | step-start | iteration-start | loop-start
```

Checkpoint semantics (normative):

| Checkpoint | Meaning |
| --- | --- |
| `case-start` | Start of the Flow block (before primitive 1 runs). |
| `step-start` | Start of the current step (before its action or wait began). |
| `iteration-start` | **Start of the innermost enclosing `for-each` or `loop-until` iteration.** Authors who need an outer iterator's start must use `loop-start` for the enclosing `loop-until`, use `case-start`, or split the case. |
| `loop-start` | Start of the innermost enclosing `loop-until` primitive as a whole (fixed across its iterations). Distinct from `iteration-start`. If the innermost iterator is a `for-each`, `loop-start` refers to the nearest enclosing `loop-until` above it; if none, it falls back to `case-start`. |

`<N>` is a non-negative integer literal or a named placeholder.

### 6.2 Human-tier modes

| Mode | Form |
| --- | --- |
| `visual` | `visual: <description>` |
| `perceived` | `perceived: <description> (threshold: <...>)` |
| `quality` | `quality: <description>` |
| `exploratory` | `exploratory: <scenario>` |

### 6.3 Mixing

- A `verifier: ai` case or the AI block of a `hybrid` case uses AI-tier modes only.
- A `verifier: human` case or the Human block of a `hybrid` case uses human-tier modes only.
- A case that needs both is `verifier: hybrid` with clearly split blocks.

## 7. Flow Block Grammar — 5 Primitives

Only these constructs are allowed in a Flow block.

### P1. `step`

```markdown
- step (actor=<ai|human|system>[, kind=wait]): <action or wait description>
  expected:
  - <observation bullet>
```

- `actor` defaults to the case's `default-actor` and may be omitted when equal.
- `kind=wait` is a step modality: the actor performs no external action; the step evaluates its expected bullets with time budgets until all pass or any time budget expires.
- `actor=system` **implies** `kind=wait` (system steps have no external action). Writing `kind=wait` alongside `actor=system` is recommended for clarity.
- **Every expected bullet under `kind=wait` must carry `within Ns`.** A missing time budget is a hard error.
- Action text for `actor=ai` must be an exact runnable command.
- Action text for `actor=human` must be a deterministic operator instruction (e.g., `human runs "<command>"`).
- Action text for `actor=system, kind=wait` describes what the product will do unattended.

### P2. `loop-until`

```markdown
- loop-until <condition>:
  - <inner primitives>
```

`<condition>` follows §8.

### P3. `if` / `else`

```markdown
- if <condition>:
  - <inner primitives>
- else:
  - <inner primitives>
```

`else` is optional. No `elif`; nest `if` inside `else` if needed.

### P4. `for-each`

```markdown
- for-each {var} in <list-source>:
  - <inner primitives, may textually substitute {var}>
```

```
<list-source>     ::= <literal-list> | <list-placeholder>
<literal-list>    ::= [<literal>, <literal>, ...]
<list-placeholder>::= `<placeholder-name>`   (must resolve to a literal list via §4.1)
```

- `{var}` substitution is purely textual.
- Derived list sources (e.g., `nodes-of(<yaml>)`) are not allowed. Use a Placeholder whose right-hand side is a literal list, or split the case.

### P5. `set-outcome`

```markdown
- set-outcome inconclusive-human-needed
```

**This is the only legal `set-outcome` form.** `pass` / `fail` / `partial-coverage` are determined by the case's outcome rule and may not be declared directly inside the Flow.

See §11 for termination semantics.

### Nesting

Any primitive may nest inside any other, except `set-outcome` which is a leaf.

## 8. Condition Sub-Grammar

Used by `loop-until`, `if`, and nested `if`.

```
<condition> ::=
    <observation-condition>
  | <variable-condition>
  | <compound-condition>

<observation-condition> ::= any AI-tier observation form from §6.1

<variable-condition> ::=
    `{var} = <literal>`
  | `{var} in [<literal>, <literal>, ...]`
  | `{var} not in [<literal>, ...]`

<compound-condition> ::=
    <condition> and <condition>
  | <condition> or <condition>       (one binary operator only)
```

- `{var}` must be bound by an enclosing `for-each`.
- Conditions may use case-level Placeholders in place of literals.
- For deeper logic, nest primitives (`if` inside `else`, or split into separate loops).

## 9. Pass-Checklist Scopes

Every checklist bullet declares its scope. Applies to `verifier: ai` cases and the AI block of `verifier: hybrid` cases.

### Scope 1 — per-step rollup

```markdown
- [ ] every expected bullet in the Flow held
```

Asserts the conjunction of all step-local expected observations encountered during Flow execution (including loop and `for-each` iterations).

### Scope 2 — case-aggregate

```markdown
- [ ] (aggregate) <aggregate-form>
```

Aggregate operators (closed set):

| Operator | Form | Semantics |
| --- | --- | --- |
| `at-least-once` | `at-least-once in <scope>: <observation>` | At least one iteration of the named scope satisfies the observation. |
| `for-all-iterations` | `for-all-iterations in <scope>: <observation>` | Every iteration satisfies the observation. |
| `count-matching` | `count-matching(<observation>) in <scope> <op> N` | Count compared via `op ∈ {=, ≥, ≤, >, <}` to N. |

`<scope>` is a named `for-each` variable (`for-each {stage}`) or the top-level `loop-until`.

### Scope 3 — end-state

```markdown
- [ ] end state: <state-id> [with <extra-observation>]
```

Asserts the target state's invariants hold at case end, plus any optional extra observation.

Per-step `expected` bullets describe only single-step observations. "Across the case" assertions live in Scope 2. "At completion" assertions live in Scope 3.

## 10. Outcome Vocabulary and Rule Templates

### 10.1 Outcome values (closed set)

| Outcome | Meaning |
| --- | --- |
| `fail` | The case's primary pass condition did not hold. AI: at least one Pass-checklist item failed. Human: at least one Fail signal observed. Hybrid: either channel. |
| `inconclusive-human-needed` | The case author **explicitly declared** an inconclusive path that fired. AI: a `set-outcome inconclusive-human-needed` executed. Human: an Inconclusive signal observed. Hybrid: either. No implicit environment attribution — unguarded environment failures surface as `fail`. |
| `partial-coverage` | No `fail` or `inconclusive-human-needed` condition held, but at least one declared branch was not exercised. Emitted only when the case declares branches. |
| `pass` | None of the above; all primary pass conditions held and every declared branch was exercised. |

Runners may layer a suite-level environment-error annotation outside the case outcome, but that is outside the closed vocabulary and does not change the case outcome.

### 10.2 Standard outcome-rule templates (priority order)

**AI case template:**

```markdown
**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`  (include iff `Declared branches` is present)
4. Else: `pass`
```

**Human case template:**

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

### 10.3 Shared outcome rules

- Outcome is **singular and deterministic** per case. No case emits more than one outcome. No secondary annotation within the closed set.
- Every case's outcome rule MUST follow the tier-specific standard template. Authors may not reorder, remove, or weaken rules 1, 2, or 4. Authors may narrow rule 3 to specific branch IDs (e.g., `branches B1 or B2`).
- `inconclusive-human-needed` is emitted only by declared channels. No other `set-outcome` value is legal.
- Rule 3 and `Declared branches` are both included or both omitted.

## 11. Flow Termination Semantics

Normative semantics for `set-outcome`:

- `set-outcome inconclusive-human-needed` is a **terminal, short-circuiting** primitive. When executed, it records `inconclusive-human-needed` and **stops Flow execution**. No primitive after it runs.
- Pass-checklist bullets that would evaluate against Flow state are **not evaluated** when `set-outcome` fires. The case's outcome rule uses the declared value via rule 1 of the tier template.
- Expected bullets on steps that already ran before `set-outcome` fired are considered observed; they inform Pass-checklist Scope-1 bullets for audit purposes but do not override the outcome rule's precedence.
- If multiple `set-outcome inconclusive-human-needed` primitives could execute along different paths, only the first one reached fires; subsequent primitives (including further `set-outcome` calls) do not run.

This guarantees rule 1 of every AI/hybrid outcome template is mechanically reachable regardless of later completion-oriented checklist bullets.

## 12. Declared Branches

Required when the case's outcome rule contains rule 3 (`partial-coverage`); omitted otherwise.

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
- **`for-all-iterations in <scope>: <observation>` is not allowed** in exercised-conditions. It belongs in Pass-checklist Scope-2 aggregates only.
- For `verifier: human` cases, the only legal exercised-condition form is a plain human-tier `<observation>`; `at-least-once` and `count-matching` require a Flow-level `<scope>` that human cases do not have.

A branch is **exercised** if its exercised-condition held during the case run; otherwise **unexercised**.

Authors may narrow rule 3 of the outcome rule to specific branch IDs, but may not invent new branch-exercise conditions outside this field.

## 13. Independence and Run-Lock

Serial execution is mandated under Variant A. Every case begins by reaching its declared Starting state from whatever state the shared location is in (worst case: S0 cold reset).

- Run-lock covers the shared home location and is acquired at case start, released at cleanup.
- Order-independence is required: case N must not depend on case N-1's tail state.
- Parallel execution is a non-goal until Variant B is adopted.

## Review Reports (`acc-review-{nn}.md`)

### Required Frontmatter

| Field | Required | Notes |
| --- | --- | --- |
| `title` | yes | e.g., "Acceptance Review Report 01" |
| `type` | yes | Must be `review` |
| `created` | yes | `YYYY-MM-DD HH:mm` |
| `target` | yes | Resolved path to acceptance document |
| `reviewer` | yes | Must differ from document `author` unless human waives |

### Required Body

1. **Conclusion** — `pass` or `not pass`
2. **Review Scope** — target, sources, focus areas
3. **Findings** — numbered with `[blocker]` or `[minor]`
4. **Overall Judgment** — summary and next steps

### Review Focus Areas

- Per-tier required-field completeness (ai / human / hybrid per §5)
- Flow uses only the 5 declared primitives (§7)
- Conditions use only the declared sub-grammar (§8)
- Observations use only tokens from the §6 vocabulary (verbatim spelling)
- `kind=wait` steps carry `within Ns` on every expected bullet
- Pass-checklist bullets (ai and hybrid only) declare their scope (§9)
- Outcome rule follows the tier's priority-list template verbatim (§10.2)
- `set-outcome` is only `set-outcome inconclusive-human-needed`; no other value
- `Declared branches` present iff outcome rule contains rule 3; exercised-conditions respect §12
- Tool-checkability of AI-tier expected bullets
- Requirement traceability
- Formal inclusion rule for non-normal paths
- Document stays inside the frozen requirement boundary
- Preparation completeness (fixtures, configs, observation tools)
