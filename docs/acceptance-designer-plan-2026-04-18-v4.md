---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v4)"
type: plan
status: revised
created: 2026-04-18
supersedes: docs/acceptance-designer-plan-2026-04-17-v3.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
  - docs/acceptance-designer-plan-review-2026-04-18-v3.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v4)

## 0. What v4 Changes vs v3

v3 review returned **not pass** with three blockers. All three are accurate; v4 adopts every fix.

| # | v3 blocker | v4 resolution |
| --- | --- | --- |
| V3-B1 | Variant A commands and field names don't match Platform 5 today (`platform status` → `platform service status`, `--name` → positional, `/^platform /` doesn't match the daemon, `verdict` → `result`). | §4.3 Variant A rewritten against the actual CLI in `platform5/cli/main.py` and the `NodeResult.result` schema in `platform5/models.py`. Process detection switched to PID-file checks + `platform5\.server` regex. All field names match the product. |
| V3-B2 | Flow grammar leaks: `kind=wait` bullets missing time budgets; `{stage} in [...]` is a condition form the grammar never defined; aggregate ("across the case") assertions sit inside step-local `expected`. | §4.5 now declares a **Condition sub-grammar** explicitly covering observation-conditions, variable-conditions, and one-operator compounds. §4.8 introduces **aggregate Pass-checklist bullets** with a closed set of operators (`at-least-once`, `for-all-iterations`, `count-matching`). §6.2 flagship example rewritten with `within Ns` on every wait bullet and aggregate assertions moved to the checklist. |
| V3-B3 | `human-gate` used in `actor-mix` but never declared; `actor-mix` treated as both a set *and* something with a "primary value"; `directory-exists` and `process-absent` used without being in the vocabulary; State Catalog used narrative `verify invariants of Sx` pseudo-steps. | §4.1 drops `actor-mix` and `human-gate`; replaces with a single `default-actor` field (one value from `{ai, human, system}`). §4.2 adds `directory-exists` / `directory-absent` / `process-running` / `process-absent` explicitly. §4.3 removes the pseudo-step: the last reach step's `expected` bullets enumerate all state invariants, so reaching the state *is* the verification. |

Unchanged from v3: P1–P7 problem statement, G1–G7 goals, non-goals, two-tier observation philosophy, order-independence-in-serial rule, human and hybrid case templates (headers normalized per V3-B3).

## 1. Problem Statement

(Same as v3 §1.)

## 2. Goals

(Same as v3 §2.)

## 3. Non-Goals

(Same as v3 §3. Parallel execution remains out until Variant B is adoptable.)

## 4. Proposed Structural Changes

### 4.1 Case classification — `default-actor` and `verifier`

Each **case header** declares exactly two classification fields:

**Field 1 — `default-actor`** (one of `ai`, `human`, `system`)
The default executor for every step in the Flow. Individual steps may override with `(actor=<value>)`.

Actor values:

| Value | Meaning |
| --- | --- |
| `ai` | AI executor runs the command autonomously. |
| `human` | A human performs the action (typing a deterministic CLI command like `platform gate freeze`, or a judgment-requiring interaction like observing TUI). The distinction between a gate-typing human and an observing human lives in *what the action is*, not in the actor enum. |
| `system` | No external action — the workflow or platform auto-advances. Always paired with `kind=wait` on the step. |

There is no `human-gate` value. A step where a human types `/freeze` is simply `actor=human` with an action description that states what command to type.

**Field 2 — `verifier`** (one of `ai`, `human`, `hybrid`)
Determined solely by the observation-tier modes used in the Flow's expected bullets:

- every expected bullet uses AI-tier modes → `verifier: ai`
- every expected bullet uses human-tier modes → `verifier: human`
- mix → `verifier: hybrid` (case must split into an AI block and a human block per §4.7)

**Key rule:** actor and verifier are independent. A case with `default-actor: ai`, human-typed gate steps via step-level overrides, and all AI-tier observations is `verifier: ai`. It is **not** forced into `hybrid` by the presence of a `human` step.

**Required header fields when `verifier ∈ {human, hybrid}`:** `Why human?` — one line justifying why no AI-tier mode suffices. Reviewers may challenge and reclassify.

### 4.2 Observation vocabulary, tiered (complete list)

**AI-tier modes** — every mode below is the normative token; examples must use these exact forms:

| Mode | Form |
| --- | --- |
| `exit-code` | `exit-code = N` or `exit-code ∈ {N1, N2, ...}` |
| `stdout` / `stderr` | `stdout equals "..."` / `stdout contains "..."` / `stdout matches /regex/` |
| `file-exists` / `file-absent` | `file-exists <path>` / `file-absent <path>` (both accept optional `within Ns`) |
| `directory-exists` / `directory-absent` | same form as file- variants |
| `file-field` | `file-field <path> -> <dotted-key> = <literal>` or `... matches /regex/` or `... ∈ {...}` |
| `log-line` | `log-line in <path> matching /regex/ within Ns` |
| `log-absent` | `log-absent in <path> matching /regex/ during <named-window>` (window is defined elsewhere, e.g., "the case window") |
| `process-running` / `process-absent` | `process-running matching /regex/` or `process-absent matching /regex/` (may also reference a PID file: `process-running pid-file <path>`) |
| `socket-listening` / `socket-closed` | `socket-listening <path>` / `socket-closed <path>` |

Default time budget when a mode accepts `within Ns` and none is given: **5s**. Override per bullet.

**Human-tier modes** — unchanged from v2/v3 §4.2:

| Mode | Form |
| --- | --- |
| `visual` | `visual: <description>` |
| `perceived` | `perceived: <description> (threshold: <...>)` |
| `quality` | `quality: <description>` |
| `exploratory` | `exploratory: <scenario>` |

Mode names outside these two tables are illegal.

### 4.3 State Catalog — Variant A (serial-only, against real Platform 5 contract)

Adopt now. Variant B (workspace-parameterized) remains the future target, unchanged from v3 §4.3 Variant B.

Platform 5 interface reference (from `platform5/cli/main.py`, `server.py`, `models.py`):
- Commands: `platform service start|stop|status`, `platform template register <path>`, `platform template list`, `platform project create <name> --template <tpl>`, `platform work create <desc>`, `platform work status`, `platform gate freeze|approve|reject` (plus top-level aliases `platform freeze|approve|reject`), `platform node list|show|pause|resume|terminate <id>`, `platform display`.
- Daemon process: `python -m platform5.server` (regex `/platform5\.server/`).
- Files: `~/.platform5/platformd.pid`, `~/.platform5/state.yaml`, `~/.platform5/platform.sock`, `~/.platform5/config.yaml`.
- Node result schema: `NodeResult.result: str` — field name is **`result`**, values include `"pass"` / `"not_pass"`.

```markdown
## 3. State Catalog (Variant A — serial-only, singleton home)

### 3.0 Suite-level rules
- **Run-lock:** take exclusive flock on `<paths.acceptance parent>/.acceptance-run.lock` at case start; release at cleanup. A second lock attempt must block or fail fast.
- **Serialization:** only one case holds the lock at a time. Parallel runs are not supported.
- **Home singleton:** `~/.platform5/` is the shared home directory. Starting-state reset guarantees case independence.
- **Fixture root:** `<paths.acceptance parent>/fixtures/`. Templates live under `<fixture-root>/<template-name>/`.

### S0 — Clean
**Invariants:**
- file-absent `~/.platform5`
- process-absent matching /platform5\.server/

**How to reach (always):**
- step (actor=ai): `platform service stop` (no-op if not running)
  expected:
  - exit-code ∈ {0, 1}
- step (actor=ai): `pkill -f "platform5\.server" || true`
  expected:
  - exit-code ∈ {0, 1}
- step (actor=ai): `rm -rf ~/.platform5`
  expected:
  - exit-code = 0
  - file-absent `~/.platform5`
  - process-absent matching /platform5\.server/ within 5s

### S1 — Service started (extends S0)
**Invariants:**
- file-exists `~/.platform5/platformd.pid`
- file-exists `~/.platform5/state.yaml`
- socket-listening `~/.platform5/platform.sock`
- exit-code = 0 from `platform service status`

**How to reach:** from S0:
- step (actor=ai): `platform service start --daemon`
  expected:
  - exit-code = 0
  - stdout contains "Service started in background."
- step (actor=ai, kind=wait): daemon becomes ready
  expected:
  - file-exists `~/.platform5/platformd.pid` within 5s
  - file-exists `~/.platform5/state.yaml` within 5s
  - socket-listening `~/.platform5/platform.sock` within 5s
  - exit-code = 0 from `platform service status` within 5s

### S2 — Template registered, project created (extends S1; parameters: {tpl}, {proj})
**Invariants:**
- stdout of `platform template list` contains `{tpl}`
- directory-exists `~/.platform5/projects/{proj}`
- file-field `~/.platform5/state.yaml -> projects.{proj}.status = "ready"`

**How to reach:** from S1:
- step (actor=ai): `platform template register <fixture-root>/{tpl}`
  expected:
  - exit-code = 0
  - stdout of `platform template list` contains `{tpl}` within 5s
- step (actor=ai): `platform project create {proj} --template {tpl}`
  expected:
  - exit-code = 0
  - directory-exists `~/.platform5/projects/{proj}` within 5s
  - file-field `~/.platform5/state.yaml -> projects.{proj}.status = "ready"` within 5s

### S3 — Work request frozen (extends S2; parameter: {wr-description}; produces: {wr})
**Invariants:**
- file-field `~/.platform5/state.yaml -> projects.{proj}.active_work_request` matches /.+/ (bound as {wr})
- file-exists `~/.platform5/projects/{proj}/.platform/logs/{wr}.yaml`
- file-field `.platform/logs/{wr}.yaml -> status` ∈ {"running", "awaiting_gate"}

**How to reach:** from S2:
- step (actor=ai): `platform work create "{wr-description}"`
  expected:
  - exit-code = 0
  - file-field `~/.platform5/state.yaml -> projects.{proj}.active_work_request` matches /.+/ within 5s
- step (actor=human, kind=wait): let requirements node complete and produce a pass review, then human runs first `platform gate freeze`
  (note: this state is used as a common starting baseline for §4 and §5 flow cases; acceptance documents may instead start from S2 and include the freeze in the case's own Flow if the freeze itself is under test)
```

Rules:
- State invariants use only AI-tier modes.
- The last reach step's `expected` bullets must enumerate every invariant of the target state. Reaching the state *is* the verification; no separate "verify invariants" pseudo-step.
- State parameters (`{tpl}`, `{proj}`, `{wr}`, `{wr-description}`) are case-local textual bindings.
- Reset to Starting state always climbs from S0 up unless the case explicitly documents an incremental reset with its own invariant re-verification.

### 4.4 Section defaults

Unchanged. Each subsection may declare `Starting state`, `Cleanup`, `Verifier`, `default-actor` defaults; case fields override.

### 4.5 Flow block grammar — 5 primitives, one Condition sub-grammar

**Primitives** (only these are allowed in a Flow block):

**P1. `step`**

```markdown
- step (actor=<ai|human|system>[, kind=wait]): <action description>
  expected:
  - <observation bullet>
  - ...
```

- `actor` defaults to the case's `default-actor`; declare explicitly when different.
- `kind=wait` is required when `actor=system` and forbidden otherwise. A `kind=wait` step's `expected` bullets *are* the wait conditions; **every bullet must carry a `within Ns` time budget** (enforced by reviewers — a bullet without a budget is a finding).
- Action description: for `actor=ai`, an exact shell command. For `actor=human`, an exact operator instruction (e.g., `human runs "platform gate freeze"`). For `actor=system, kind=wait`, a prose description of what the platform will do without operator input.

**P2. `loop-until`**

```markdown
- loop-until <condition>:
  - <inner primitives>
```

- `<condition>` follows the Condition sub-grammar below.
- Loop body may contain any primitive, including nested `loop-until`.

**P3. `if` / `else`**

```markdown
- if <condition>:
  - <inner primitives>
- else:
  - <inner primitives>
```

- `else` is optional. No `elif`; nest `if` inside `else` if needed.

**P4. `for-each`**

```markdown
- for-each {var} in [<literal1>, <literal2>, ...]:
  - <inner primitives, may textually substitute {var}>
```

- The iteration list must be a literal bracketed list of string literals.
- `{var}` substitution is purely textual wherever `{var}` appears inside the block.

**P5. `set-outcome`**

```markdown
- set-outcome <outcome-value>
```

- Terminal: records outcome and exits the Flow.
- `<outcome-value>` must come from the outcome vocabulary (§4.7).

**Nesting:** any primitive may nest inside any other, except `set-outcome` which is a leaf.

**Condition sub-grammar** (used by `loop-until`, `if`, and nested `if`):

```
<condition> ::=
    <observation-condition>
  | <variable-condition>
  | <compound-condition>

<observation-condition> ::=
    any AI-tier observation form from §4.2
    (e.g., `file-field path -> key = "v"`, `exit-code = 0`, `log-line in path matching /r/ within Ns`)

<variable-condition> ::=
    `{var} = <literal>`
  | `{var} in [<literal>, <literal>, ...]`
  | `{var} not in [<literal>, ...]`

<compound-condition> ::=
    `<condition> and <condition>`
  | `<condition> or <condition>`
```

- At most one binary operator per `<compound-condition>`. For more complex logic, nest primitives (`if` inside `else`, or split into two `loop-until`s).
- `{var}` in variable-conditions must be a variable bound by an enclosing `for-each`.

### 4.6 AI case template (normalized header)

```markdown
#### 4.1.1 Service start / stop  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S0 (Variant A)
**Cleanup:** reset to S0

**Flow:**
- step: `platform service start --daemon`
  expected:
  - exit-code = 0
  - stdout contains "Service started in background."
- step (kind=wait): daemon becomes ready
  expected:
  - file-exists `~/.platform5/platformd.pid` within 5s
  - socket-listening `~/.platform5/platform.sock` within 5s
- step: `platform service status`
  expected:
  - exit-code = 0
  - stdout matches /Status:\s*ok/
- step: `platform service stop`
  expected:
  - exit-code = 0
- step (kind=wait): daemon shuts down
  expected:
  - file-absent `~/.platform5/platform.sock` within 5s
  - process-absent matching /platform5\.server/ within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) log-absent in `~/.platform5/logs/platform.log` matching /level=error/ during the case window

**Outcome on checklist-all-true:** `pass`. Otherwise: `fail`.

**Tracked requirements:** `r1-REQ-1.1` `r1-REQ-1.2.7`
```

### 4.7 Outcome vocabulary (first-class, closed set)

Unchanged from v3 §4.7:

| Outcome | Meaning |
| --- | --- |
| `pass` | All Pass-checklist items held. |
| `fail` | A Pass-checklist item failed and the failure is a product issue. |
| `inconclusive-human-needed` | Terminal branch reached where only a human can judge (e.g., `max_retries` reached, mid-run environment break). Not a product failure. |
| `partial-coverage` | Case passed but a declared branch never exercised. Documented gap. |

Every case declares its outcome interpretation in the Pass checklist's closing line.

### 4.8 Pass checklist bullet scopes (new)

A Pass checklist bullet is one of three scopes. Each is explicitly tagged in the bullet.

**Scope 1 — per-step rollup**
```markdown
- [ ] every expected bullet in the Flow held
```
Asserts the conjunction of all step-local `expected` bullets encountered during Flow execution (loop iterations included).

**Scope 2 — case-aggregate**
```markdown
- [ ] (aggregate) <aggregate-form>
```

Where `<aggregate-form>` is one of:

| Operator | Form | Semantics |
| --- | --- | --- |
| `at-least-once` | `at-least-once in <scope>: <observation>` | At least one iteration of the named scope satisfies the observation. Scope is a named `for-each` variable (`for-each {stage}`) or `loop-until`. |
| `for-all-iterations` | `for-all-iterations in <scope>: <observation>` | Every iteration satisfies the observation. |
| `count-matching` | `count-matching(<observation>) in <scope> <op> N` | Count of iterations matching, compared via `op ∈ {=, ≥, ≤, >, <}` to a literal N. |

**Scope 3 — end-state**
```markdown
- [ ] end state: <state-id> with <extra-observation>
```
Asserts the target state's invariants hold at case end, plus any optional extra observation.

Per-step `expected` bullets MUST describe single-step observations only. Aggregate ("across the case") statements MUST live in Pass-checklist bullets at Scope 2. This resolves the V3-B2 leak where aggregates were written inside `expected`.

### 4.9 Independence and the run-lock

Unchanged from v3 §4.8. Serial execution mandated under Variant A; every case resets to its declared Starting state.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

- Content rules require:
  - State Catalog variant declared (A or B)
  - Per-case: `default-actor`, `verifier`, Starting state, Flow block (5-primitive grammar), Pass checklist (scoped bullets), Tracked requirements, release tag
  - `Why human?` required when `verifier ∈ {human, hybrid}`
  - Flow uses only 5 declared primitives
  - Conditions use only the declared sub-grammar
  - Observation modes come from the declared AI-tier or human-tier vocabulary, using the normative token names verbatim
  - Pass-checklist bullets declare their scope (per-step rollup / case-aggregate / end-state)
  - Outcome values come from the closed vocabulary
  - Serial execution + run-lock rule under Variant A
- Add `## Acceptance Item Structure` with three skeletons (ai / human / hybrid).
- Add `## Classifying a Case` with the actor ⟂ verifier rule.
- Working Loop: pick Catalog variant → write State Catalog → classify each case → write Flow referencing states → write Pass checklist → review.

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- Required body sections: Document Instructions, Acceptance Preparation, **State Catalog (Variant A|B)**, **Section Defaults (optional)**, Main-Flow Stories, Independent Acceptance Items, Next-Phase Constraints.
- Full observation vocabulary tables (AI and human).
- Flow grammar spec with all 5 primitives plus the Condition sub-grammar.
- Pass-checklist scope table.
- Outcome vocabulary table.
- Three case templates with filled examples.
- One short snippet per primitive and per condition form.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

New/updated rows:

| Situation | Decision |
| --- | --- |
| Case shares setup with many siblings | Define in State Catalog; cases reference state ID |
| Case cannot use AI-tier modes for a product commitment | `verifier: human` or `hybrid`; never silently omitted |
| Case has human-typed gate but all AI-tier observations | `default-actor: ai`, step override `(actor=human)`, `verifier: ai` (not hybrid) |
| Author claims `human` to avoid writing mechanical assertions | Reviewer challenges `Why human?`; reclassifies if unjustified |
| Case depends on previous case's tail state | Rejected; every case resets to its Starting state |
| Product does not yet support a workspace flag | Use State Catalog Variant A; do not invent the flag |
| Flow needs a construct outside the 5 primitives / Condition grammar | Rewrite using nesting; if truly unavoidable, file a grammar extension RFC against this plan before writing the case |
| "Across the case" assertion needed | Use a Scope-2 aggregate Pass-checklist bullet, not a step-local `expected` |

## 6. Before / After Examples

### 6.1 Linear AI case

Covered by §4.6.

### 6.2 Branch + loop AI case, using only declared syntax (resolves V3-B2)

```markdown
#### 4.2.3 Closed-loop workflow acceptance  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S3 (Variant A, {tpl}=T1, {proj}=P1, {wr-description}="实现一个命令行 TODO 管理工具...")
**Cleanup:** reset to S0

**Flow:**
- for-each {stage} in [acceptance, architecture, design, development, final-acceptance]:
  - step (actor=system, kind=wait): workflow enters and completes producer node `{stage}`
    expected:
    - file-exists `~/.platform5/projects/{proj}/.workflow/results/{stage}.yaml` within 300s
    - file-field `.workflow/results/{stage}.yaml -> result ∈ {"pass", "not_pass"}` within 5s
  - loop-until `file-field .workflow/results/{stage}-review.yaml -> result = "pass"` or `file-field .platform/logs/{wr}.yaml -> nodes.{stage}-review.loop_count ≥ max_retries`:
    - step (actor=system, kind=wait): workflow runs review node `{stage}-review`
      expected:
      - file-exists `.workflow/results/{stage}-review.yaml` within 300s
      - file-field `.workflow/results/{stage}-review.yaml -> result ∈ {"pass", "not_pass"}` within 5s
    - if `file-field .workflow/results/{stage}-review.yaml -> result = "not_pass"`:
      - step (actor=system, kind=wait): workflow auto-routes back to `{stage}` and resumes same session
        expected:
        - file-field `.platform/logs/{wr}.yaml -> nodes.{stage}.sessionId` unchanged within 60s
        - file-field `.platform/logs/{wr}.yaml -> nodes.{stage}.loop_count` incremented within 60s
  - if `file-field .platform/logs/{wr}.yaml -> nodes.{stage}-review.loop_count ≥ max_retries`:
    - set-outcome inconclusive-human-needed
  - else:
    - if `{stage} in ["acceptance"]`:
      - step (actor=human): human runs "platform gate freeze"
        expected:
        - exit-code = 0
        - file-field `.platform/logs/{wr}.yaml -> nodes.{stage}.status = "completed"` within 5s
        - log-line in `.platform/logs/{wr}.yaml` matching /gate\.freeze.*by=human/ within 5s
    - else:
      - step (actor=human): human runs "platform gate approve"
        expected:
        - exit-code = 0
        - file-field `.platform/logs/{wr}.yaml -> nodes.{stage}.status = "completed"` within 5s
        - log-line in `.platform/logs/{wr}.yaml` matching /gate\.approve.*by=human/ within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) at-least-once in for-each {stage}: file-field `.platform/logs/{wr}.yaml -> nodes.{stage}.executor ≠ nodes.{stage}-review.executor`
- [ ] (aggregate) count-matching(file-field `.platform/logs/{wr}.yaml -> nodes.{stage}.executor ≠ "<default-executor>"`) in for-each {stage} ≥ 2
- [ ] (aggregate) log-absent in `~/.platform5/logs/platform.log` matching /level=error/ during the case window
- [ ] end state: file-field `.platform/logs/{wr}.yaml -> status = "completed"` and summary block references all 5 stages

**Outcome on checklist-all-true:** `pass`, unless `set-outcome inconclusive-human-needed` fired (then `inconclusive-human-needed`). Emit `partial-coverage` if no `loop-until` iterated more than once across any stage.

**Tracked requirements:** `r1-REQ-4.2` `r1-REQ-4.3` `r1-REQ-4.6` `r1-REQ-4.7` `r1-REQ-5.1` `r1-REQ-5.2` `r1-REQ-5.3` `r1-REQ-6.1` `r1-REQ-6.2` `X2`
```

Audit of constructs used, against the declared grammar:
- `for-each {stage} in [literal list]` ✓ P4
- `step (actor=system, kind=wait)` ✓ P1, every wait bullet has `within Ns`
- `step (actor=human)` ✓ P1
- `loop-until <compound-condition with or>` ✓ P2 + Condition sub-grammar
- `if <observation-condition>` ✓ P3 + Condition
- `if <variable-condition: {stage} in [...]>` ✓ P3 + Condition
- `set-outcome inconclusive-human-needed` ✓ P5 + outcome vocabulary
- Aggregate `at-least-once in for-each {stage}` ✓ Scope-2 Pass-checklist bullet
- Aggregate `count-matching(...) ≥ 2` ✓ Scope-2
- Observation modes: `file-exists`, `file-field`, `log-line`, `log-absent` — all in §4.2 AI-tier table.

No undeclared construct remains.

### 6.3 Human case

(Same as v3 §4.6 with header normalized: `default-actor: human`, `verifier: human`, `Why human?: ...`.)

### 6.4 Hybrid case

(Same as v3 §4.7 with header normalized: `default-actor: ai`, `verifier: hybrid`, `Why human?: ...`; AI block uses default, human block uses `(actor=human)` step overrides.)

## 7. Migration Impact

- `persona-agents-platform5/docs/acceptance/acceptance.md` — rewrite under v4 during CR-01 continuation. Variant A header in §3; use real CLI; use `result` field consistently.
- Variant A uses only shipped Platform 5 commands, standard shell primitives (`flock`, `pkill`, `rm`), and standard filesystem checks. No tooling blockers.
- Variant B remains a future target; its adoption does not change case bodies, only State Catalog reach commands.

## 8. Open Questions for Codex Review (v4)

Resolved from v3:

- V3-Q1 (`for-each` list source) → §4.5 P4 keeps literal-only; see §8.1 below for reconsideration.
- V3-Q2 (lock granularity) → home-singleton coverage adopted.
- V3-Q3 (human identity audit) → §6.2 example uses `by=human` in the gate log-line regex; skill-level rule documents this as the required audit form.
- V3-Q4 (partial-coverage signaling) → §6.2 shows manual case-level declaration in the outcome interpretation line.

Still open for v4:

1. **`for-each` over derived lists.** The closed-loop case happens to have a fixed stage list. If a future case legitimately needs "every node in the current workflow", the current grammar forces enumeration. Is that acceptable, or should we define one derived form (`for-each {n} in nodes-of(<workflow.yaml>)`)? Recommendation: keep literal-only for v4; revisit if a real case demands it.

2. **S3 authoring path.** §4.3 S3 uses `actor=human, kind=wait` for the initial freeze, which mixes a human-typed action with a wait semantic. Should S3 instead be defined without a built-in freeze (leaving the freeze to be part of the case under test), and cases that need an "already frozen" baseline define a case-local S3'? Recommendation: drop the built-in freeze from S3; cases that need a pre-frozen baseline assemble it explicitly. I will accept this change in the skill writeup unless review pushes otherwise.

3. **`count-matching` operator set.** §4.8 allows `{=, ≥, ≤, >, <}` comparisons. Is that enough, or do we want set-valued predicates (e.g., `count distinct executors ≥ 2`)? Recommendation: add a single additional form `count-distinct(<field>) in <scope> <op> N` if real cases need it; hold off for v4.

## 9. Completion Criteria

- `SKILL.md` includes: State Catalog variant declaration, actor ⟂ verifier rule, 5-primitive Flow grammar, Condition sub-grammar, Pass-checklist scope rule, closed outcome vocabulary, serial+run-lock rule.
- `references/output-artifacts.md` specifies both Catalog variants, both observation tiers with verbatim token names, all 5 primitives, the Condition sub-grammar, Pass-checklist scopes, outcome vocabulary, and three case templates.
- `references/boundary-examples.md` has all §5.3 rows.
- Plan passes codex review on v4.
- Post-implementation spot check: rewriting three platform5 cases (`§3.1.1` linear, `§3.2.3` branch+loop, `§3.5.1` hybrid UX) under v4 passes mechanical review against the published grammar.

## 10. Out of Scope

- Rewriting the platform5 acceptance document.
- Static validator tooling.
- Changes to the review report format.
- Parallel case execution.
- Runner implementation details.
