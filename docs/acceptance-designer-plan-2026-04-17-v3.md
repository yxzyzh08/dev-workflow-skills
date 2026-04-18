---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v3)"
type: plan
status: revised
created: 2026-04-17
supersedes: docs/acceptance-designer-plan-2026-04-17-v2.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v3)

## 0. What v3 Changes vs v2

v2 review returned **not pass** with three new blockers. All three are legitimate; v3 adopts them in full.

| # | v2 blocker | v3 resolution |
| --- | --- | --- |
| V2-B1 | Verifier tier conflates *who performs* with *how observed*; human-gate cases had nowhere to sit. | §4.1 splits classification into two independent dimensions: **`actor`** per step (who drives the action) and **`verifier`** per case (which observation tier the expected bullets come from). A case with AI-driven setup and human-typed gates with all-AI-observable outcomes is now naturally `actor-mix: ai+human-gate`, `verifier: ai`. |
| V2-B2 | Flow block referenced constructs (`For each stage`, `let workflow execute ...`, `mark outcome ... and exit`) not in the declared 3 primitives. | §4.5 expands the Flow grammar to **5 declared primitives**: `step` (with explicit `kind=wait` variant for system-driven advancement), `loop-until`, `if` / `else`, `for-each`, `set-outcome`. §6.2 rewrites the flagship closed-loop case using only those primitives. |
| V2-B3 | State Catalog normatively required a `--home {ws}` flag the product does not have, while also recommending "adopt now". | §4.3 now provides **two explicitly named Catalog variants**: (A) **Serial-only concrete** (adopt now, uses `~/.platform5` as a singleton with a run-lock), and (B) **Workspace-parameterized** (future, requires product support). Variant A is fully specified with real commands; a skill rule ties adoption choice to product capability. |

Unchanged from v2: problem statement, core goals, non-goals, observation vocabulary tiers (AI / Human), human and hybrid case templates, the human-verification concern H1 raised by the human reviewer, order-independence-in-serial independence model.

## 1. Problem Statement

(Same as v2 §1 — P1 through P7.)

## 2. Goals

(Same as v2 §2 — G1 through G7.)

## 3. Non-Goals

(Same as v2 §3. Parallel case execution remains a non-goal; workspace-parameterized Catalog is a future target.)

## 4. Proposed Structural Changes

### 4.1 Case classification — `actor` ⟂ `verifier`

v3 separates the two dimensions that v2 had fused.

**Dimension A — `actor` (who drives each step).**

Each **step** carries an `actor` annotation. The case header declares the default, then individual steps override it.

| Actor value | Meaning |
| --- | --- |
| `ai` | AI executor runs the command autonomously. |
| `human` | A human performs the action (type a gate command, open a TUI, click, resize). |
| `system` | No external action — the workflow or platform auto-advances. Always pairs with `kind=wait`. |

Case header declares `actor-mix` (informational): the set of actor values used. Typical combinations:

- `actor-mix: ai` — fully autonomous.
- `actor-mix: ai + human-gate` — AI drives; human only types deterministic gate commands like `/freeze`, `/approve`, `/reject`.
- `actor-mix: ai + system` — AI drives setup; workflow auto-advances between nodes.
- `actor-mix: ai + system + human-gate` — common for closed-loop workflow cases.
- `actor-mix: human` — human-only (TUI render quality, exploratory cases).

**Dimension B — `verifier` (which observation tier the expected bullets use).**

Unchanged from v2 §4.1 but now independent from actor:

- `verifier: ai` — every expected bullet uses an AI-tier observation mode (§4.2).
- `verifier: human` — every expected bullet uses a human-tier mode.
- `verifier: hybrid` — some AI-tier, some human-tier; case is split into an AI block + a human block (§4.7).

**The key rule change from v2:**
A case with human-driven gate steps but entirely AI-tier observations is `verifier: ai`. It is **not** forced into `hybrid`. Tier-selection is determined solely by the observation modes in the expected bullets, not by who typed a command.

This resolves V2-B1: gate-driven workflow cases now have a clean home (`actor-mix: ai + human-gate`, `verifier: ai`). Cases that actually need human judgment on an outcome remain `verifier: human` or `verifier: hybrid`.

**Required case header fields:**

| Field | Notes |
| --- | --- |
| `actor-mix` | Informational; lists actor values used in the case. |
| `verifier` | Tier rule above. |
| `Why human?` | **Required only when** `verifier` is `human` or `hybrid`. One line justifying why no AI-tier mode suffices. Reviewers may challenge and reclassify. |

### 4.2 Observation vocabulary, tiered

(Unchanged from v2 §4.2. Reproduced once more for self-contained reference.)

**AI-tier modes** — `exit-code`, `stdout` / `stderr` (equals / contains / matches), `file-exists` / `file-absent`, `file-field` (YAML/JSON path), `log-line` (regex + time budget), `log-absent` (named regex + named window), `process` running/not, `socket` listening/closed.

**Human-tier modes** — `visual`, `perceived` (with stated threshold), `quality`, `exploratory`.

Time-budget default is `within 5s` when a mode accepts one and none is given. Per-bullet overrides are allowed.

### 4.3 State Catalog — two variants

v3 splits the Catalog into two explicitly named variants. Each acceptance document declares which variant it uses at the top of its State Catalog section. Adoption rule: **Variant A is the default**; a document may switch to Variant B only when the product actually supports workspace selection.

#### Variant A — Serial-only concrete (adopt now)

Assumes the product uses a singleton home directory. Enforces serial execution via a run-lock.

```markdown
## 3. State Catalog (Variant A — serial-only, singleton home)

### 3.0 Suite-level rules
- **Run-lock:** at case start, take an exclusive lock on `<paths.acceptance parent>/.acceptance-run.lock` (e.g., `flock` in shell, `portalocker` in Python); release at cleanup. A second lock attempt must block or fail fast.
- **Serialization:** only one case may hold the lock at a time. Parallel runs are not supported.
- **Home singleton:** `~/.platform5/` is the only home directory used. All cases share it; Starting-state reset is what guarantees independence.

### S0 — Clean
**Invariants:**
- file-absent `~/.platform5`
- process: no process matching `/^platform /` running

**How to reach (always):**
- step: `pkill -f "^platform " || true`
  expected: exit-code ∈ {0, 1}
- step: `rm -rf ~/.platform5`
  expected: exit-code = 0
- step: verify invariants of S0
  expected: file-absent `~/.platform5`; process-absent `/^platform /`

### S1 — Platform started (extends S0)
**Invariants:**
- file-exists `~/.platform5/state.yaml`
- socket listening `~/.platform5/platform.sock`
- `platform status` exit-code = 0

**How to reach:** from S0:
- step: `platform start`
  expected: exit-code = 0; file-exists `~/.platform5/platform.sock` within 5s
- step: verify invariants of S1

### S2 — Project ready (extends S1, parameters: {tpl}, {proj})
**Invariants:**
- `platform template list` stdout contains `{tpl}`
- directory-exists `~/.platform5/projects/{proj}/`
- `~/.platform5/state.yaml -> projects.{proj}.status = "ready"`

**How to reach:** from S1:
- step: `platform template register ./fixtures/{tpl}`
  expected: exit-code = 0
- step: `platform project create --template {tpl} --name {proj}`
  expected: exit-code = 0; directory-exists `~/.platform5/projects/{proj}/` within 5s
- step: verify invariants of S2
```

Rules:
- State parameters (`{tpl}`, `{proj}`) are case-local bindings, not workspace paths.
- "How to reach" must be a sequence of `step` entries with actual commands and exit-code/file checks — not narrative.
- Reset to Starting state always includes reaching S0 first, then climbing back up the chain, unless the case explicitly opts into an incremental reset (then the case must prove the starting invariants held).

#### Variant B — Workspace-parameterized (future target)

Adopted only after the product supports a home/workspace flag (e.g., `platform --home {ws}` or `PLATFORM5_HOME={ws}`). Reproduces v2 §4.3 verbatim; enables parallel execution.

**Variant switch rule:** the acceptance document's `## 3. State Catalog` heading must declare `(Variant A)` or `(Variant B)`. Mixing variants in a single document is not permitted.

This resolves V2-B3: Variant A is fully specified with today's commands; Variant B is clearly gated on product capability; reviewers can tell unambiguously which variant a document is using.

### 4.4 Section defaults

Unchanged from v2 §4.4. Section header may declare default `Starting state`, `Cleanup`, `Verifier`, `actor-mix`. Case fields override.

### 4.5 Flow block grammar — 5 primitives

v3 formalizes the full grammar. These are the **only** constructs allowed in a Flow block; anything else is a finding.

**Primitive 1 — `step`**

```markdown
- step (actor=<ai|human|system>[, kind=wait]): <action description or wait description>
  expected:
  - <observation bullet using a declared mode>
  - ...
```

- `actor` defaults to the case's `actor-mix` primary value; declare explicitly when different.
- `kind=wait` is required when `actor=system` (the "action" is passively waiting for a condition). A `kind=wait` step's expected bullets *are* the wait conditions; each must include a `within Ns` time budget.
- Action description for `actor=ai` must be an exact runnable command. For `actor=human`, it must be a deterministic instruction (e.g., `human runs /freeze`). For `actor=system, kind=wait`, it describes what the workflow will do on its own.

**Primitive 2 — `loop-until`**

```markdown
- loop-until <exit-condition-A> [or <exit-condition-B>]:
  - <inner primitives>
```

- Exit conditions are expressed in the observation vocabulary (e.g., `file-field X = "pass"`).
- At most two conditions joined by `or`. If more are needed, the case should be split (v2 §8.3 resolution).
- The loop body may contain any primitive including nested `loop-until`.

**Primitive 3 — `if` / `else`**

```markdown
- if <condition>:
  - <inner primitives>
- else:
  - <inner primitives>
```

- `else` is optional.
- No `elif`; nest `if` inside `else` if needed.

**Primitive 4 — `for-each`**

```markdown
- for-each {var} in [<item1>, <item2>, ...]:
  - <inner primitives, may substitute {var}>
```

- The iteration list must be a literal bracketed list. Arbitrary generated lists are not allowed.
- `{var}` substitution is purely textual: wherever `{var}` appears in an action, expected bullet, or nested condition inside the block, it is replaced with the current item.

**Primitive 5 — `set-outcome`**

```markdown
- set-outcome <outcome-value>
```

- Terminal meta-action: records the case outcome and exits the Flow early.
- `<outcome-value>` must come from the outcome vocabulary (§4.7).
- The Pass checklist must still be evaluated: `set-outcome` predetermines the overall outcome, and pre-outcome bullets on the checklist are reported as observed.

**Nesting rules:** any primitive may nest inside any other, except `set-outcome` which is a leaf (and terminates the Flow).

This resolves V2-B2: the grammar now has a name for every construct the flagship case needs, and §6.2 rewrites that case using only these primitives.

### 4.6 AI case template (updated header)

```markdown
#### 4.1.1 Service start / stop / address switch  (r1)

**actor-mix:** ai
**verifier:** ai
**Starting state:** S0 (Variant A)
**Extra preconditions:** config.yaml listen address = A
**Cleanup:** reset to S0

**Flow:**
- step (actor=ai): `platform start`
  expected:
  - exit-code = 0
  - file-exists `~/.platform5/platform.sock` within 5s
- step (actor=ai): `platform ping`
  expected:
  - stdout matches `/ok address=.*A/`
- step (actor=ai): `platform stop`
  expected:
  - exit-code = 0
  - file-absent `~/.platform5/platform.sock` within 5s
- step (actor=ai): edit config.yaml to set listen address = B
  expected:
  - file-field `~/.platform5/config.yaml -> listen.address = "B"`
- step (actor=ai): `platform start`
  expected:
  - exit-code = 0
  - stdout of `platform ping` matches `/ok address=.*B/` within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] end state: S1 with address = B
- [ ] log-absent: no match for `/level=error/` in `~/.platform5/logs/platform.log` during the case window

**Outcome on checklist-all-true:** `pass`. Otherwise: `fail`.

**Tracked requirements:** `r1-REQ-1.1` `r1-REQ-1.2.7` `r1-REQ-1.3`
```

### 4.7 Outcome vocabulary (first-class)

v3 promotes outcome values to a closed vocabulary. Cases and `set-outcome` may only emit one of:

| Outcome | Meaning |
| --- | --- |
| `pass` | All Pass-checklist items held. |
| `fail` | At least one Pass-checklist item failed, and the failure is a product issue. |
| `inconclusive-human-needed` | Execution hit a terminal branch where a human must intervene (e.g., `max_retries` reached, product asks for judgment, environment broke mid-run). Not a product failure. |
| `partial-coverage` | Case passed but did not exercise a declared branch (e.g., closed-loop run completed without any retry loop firing). A documented gap, not a failure. |

Every case must declare its outcome interpretation in the Pass checklist's closing line ("Outcome on checklist-all-true: `pass`. Otherwise: `fail` unless §X.Y branch reached, in which case ..."). Cases that never use `inconclusive-human-needed` or `partial-coverage` may omit them.

### 4.8 Independence and the run-lock

- Serial execution is mandated for Variant A. The suite runner takes `.acceptance-run.lock` at case start and releases at cleanup. A crashed case must release the lock on lock-timeout or next-suite-start cleanup.
- Order-independence is required: every case begins by reaching its declared Starting state from whatever state the home directory is in (worst case S0 cold-start).
- Parallel execution becomes a goal only under Variant B (future).

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

- Rewrite `## Acceptance Content Rules` to require:
  - State Catalog variant declared (A or B)
  - Per-case: `actor-mix`, `verifier`, Starting state, Flow block, Pass checklist, Tracked requirements, release tag
  - When `verifier ∈ {human, hybrid}`: `Why human?` required
  - Flow block uses only the 5 declared primitives
  - Outcome vocabulary closed (§4.7)
  - Serial execution + run-lock for Variant A
- Add `## Acceptance Item Structure` section inlining the three skeletons.
- Add `## Classifying a Case` section with the actor ⟂ verifier rule and an FAQ (gate-only cases stay `verifier: ai`, etc.).
- Update the Working Loop: pick Catalog variant → write State Catalog → classify each case → write cases referencing states → review.

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- Required body sections: Document Instructions, Acceptance Preparation, **State Catalog (Variant A|B)**, **Section Defaults (optional per subsection)**, Main-Flow Stories, Independent Acceptance Items, Next-Phase Constraints.
- Observation vocabulary: both tiers (from §4.2).
- Flow grammar: all 5 primitives with syntax and constraints.
- Case templates: `ai`, `human`, `hybrid` — each with header fields table.
- Outcome vocabulary table.
- One short filled example per primitive so authors can copy.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

New rows:

| Situation | Owner / decision |
| --- | --- |
| Case shares setup with many siblings | Define in State Catalog; cases reference state ID only |
| Case cannot use AI-tier modes for a product commitment | `verifier: human` or `hybrid`; never silently omitted |
| Case has human-typed gate but all AI-tier observations | `actor-mix: ai + human-gate`, `verifier: ai` (not hybrid) |
| Author claims `human` to avoid writing mechanical assertions | Reviewer challenges `Why human?`; reclassifies if unjustified |
| Case depends on previous case's tail state | Rejected; every case resets to its own Starting state |
| Product does not yet support a workspace flag | Use State Catalog Variant A (serial + run-lock); do not invent the flag |
| Flow needs a construct outside the 5 primitives | Rewrite using nested primitives; if genuinely unavoidable, file as a grammar extension RFC against this plan |

## 6. Before / After Examples

### 6.1 Linear AI case

Covered by §4.6.

### 6.2 Branch + loop AI case, using only declared primitives (resolves V2-B2)

```markdown
#### 4.2.3 Closed-loop workflow acceptance  (r1)

**actor-mix:** ai + system + human-gate
**verifier:** ai
**Starting state:** S2 (Variant A, {tpl}=T1, {proj}=P1)
**Extra preconditions:**
- work request "实现一个命令行 TODO 管理工具..." created (id stored as {wr})
- work request is in frozen state (first gate already passed outside this case)
**Cleanup:** reset to S0

**Flow:**
- for-each {stage} in [requirements, acceptance, architecture, design, development, final-acceptance]:
  - step (actor=system, kind=wait): workflow enters producer node `{stage}` and completes
    expected:
    - file-exists `.workflow/results/{stage}.yaml` within 60s
    - file-field `results/{stage}.yaml -> verdict ∈ {pass, not_pass}`
  - loop-until `results/{stage}-review.yaml -> verdict = "pass"` or `logs/{wr}.yaml -> nodes.{stage}-review.loop_count = max_retries`:
    - step (actor=system, kind=wait): workflow runs review node `{stage}-review`
      expected:
      - file-field `results/{stage}-review.yaml -> verdict ∈ {pass, not_pass}` within 60s
      - file-field `logs/{wr}.yaml -> nodes.{stage}-review.executor ≠ nodes.{stage}.executor` (asserted at least once across the whole case)
    - if `results/{stage}-review.yaml -> verdict = "not_pass"`:
      - step (actor=system, kind=wait): workflow auto-routes back to `{stage}`
        expected:
        - file-field `logs/{wr}.yaml -> nodes.{stage}.sessionId` unchanged across this iteration
        - file-field `logs/{wr}.yaml -> nodes.{stage}.loop_count` incremented by 1 within 60s
  - if `logs/{wr}.yaml -> nodes.{stage}-review.loop_count = max_retries`:
    - set-outcome `inconclusive-human-needed`
  - else:
    - if {stage} in [requirements, acceptance]:
      - step (actor=human): human runs `/freeze` against {wr}
        expected:
        - file-field `logs/{wr}.yaml -> nodes.{stage}.status = "completed"` within 5s
        - log-line in `logs/{wr}.yaml` matching `/gate\.freeze.*by=human/` within 5s
    - else:
      - step (actor=human): human runs `/approve` against {wr}
        expected:
        - file-field `logs/{wr}.yaml -> nodes.{stage}.status = "completed"` within 5s
        - log-line in `logs/{wr}.yaml` matching `/gate\.approve.*by=human/` within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] at least 2 stages used an executor different from the default (per `executors.yaml`)
- [ ] log-absent: no match for `/level=error/` in `~/.platform5/logs/platform.log` during the case window
- [ ] final state: `logs/{wr}.yaml -> status = "completed"` and summary block reflects all 6 stages

**Outcome on checklist-all-true:** `pass` unless `set-outcome inconclusive-human-needed` fired, in which case `inconclusive-human-needed`. Record `partial-coverage` if no `loop-until` iterated more than once across all stages.

**Tracked requirements:** `r1-REQ-4.2` `r1-REQ-4.3` `r1-REQ-4.6` `r1-REQ-4.7` `r1-REQ-5.1` `r1-REQ-5.2` `r1-REQ-5.3` `r1-REQ-6.1` `r1-REQ-6.2` `X2`
```

Every construct here is one of: `for-each`, `step (actor=system, kind=wait)`, `step (actor=human)`, `loop-until`, `if`, `else`, `set-outcome`, plus observation modes from §4.2. No undeclared syntax.

### 6.3 Human case

(Unchanged from v2 §4.6 — TUI render quality. Header gains `actor-mix: human` alongside `verifier: human`.)

### 6.4 Hybrid case

(Unchanged from v2 §4.7 — `/reject` UX. Header: `actor-mix: ai + human`, `verifier: hybrid`; AI block uses actor=ai on its steps, human block uses actor=human.)

## 7. Migration Impact

- `persona-agents-platform5/docs/acceptance/acceptance.md` — rewrite under v3 structure during CR-01 continuation. Declare Variant A at the top of §3.
- No tooling blockers: Variant A uses only commands the product already supports plus standard shell primitives (`flock`, `pkill`, `rm`).
- Variant B remains available as a future upgrade once the product lands a workspace flag; migration from Variant A to Variant B is a mechanical path substitution per state definition.

## 8. Open Questions for Codex Review (v3)

Resolved from v2:

- V2-Q1 (product prerequisite) → §4.3 two-variant split; no prerequisite blocks adoption.
- V2-Q2 (`Why human?` authority) → §5.1 + §5.3: `acceptance-designer` owns during review; `test-engineer` may raise findings.
- V2-Q3 (loop conditions) → §4.5 Primitive 2: two conditions joined by `or`; split case if more needed.
- V2-Q4 (inconclusive outcomes) → §4.7 first-class outcome vocabulary, closed set.
- V2-Q5 (human-run recording path) → standardize in skill reference as `<paths.acceptance parent>/human-runs/<case-id>-<YYYYMMDD>.md`.

Still open for v3:

1. **`for-each` over product-derived lists.** §4.5 Primitive 4 requires a literal bracketed list. If a future case legitimately needs to iterate over, e.g., "every node in the workflow", should we allow a restricted form (`for-each {n} in nodes-of({workflow-yaml})`) or force explicit enumeration? Recommendation: keep literal-only in v3; revisit if a real case demands otherwise.

2. **Locking granularity for Variant A.** The run-lock is suite-wide. Should it also cover the configured fixture directory, or is home-singleton coverage enough? Recommendation: home-singleton is enough; fixtures are read-only inputs.

3. **`actor=human` authentication/identity.** Several cases rely on `human runs /freeze`. Should the skill require the log-line regex to include an identity (`by=<named-human>`) for audit purposes? Recommendation: require `by=human` or a specific role token; do not require named identity at this layer.

4. **Partial-coverage signaling.** §4.7 `partial-coverage` is currently only referenced by the flagship case. Should it always be emitted automatically by a runner, or manually declared per case? Recommendation: manual, case-level, based on observed loop counts; auto-detection is runner work, not acceptance scope.

## 9. Completion Criteria

- `SKILL.md` content rules include: State Catalog variant declaration, actor ⟂ verifier classification, 5-primitive Flow grammar, closed outcome vocabulary, serial+run-lock rule.
- `references/output-artifacts.md` specifies both Catalog variants, both observation tiers, all 5 primitives with example snippets, all three case templates, outcome vocabulary.
- `references/boundary-examples.md` contains all §5.3 rows.
- Plan passes codex review on v3.
- Post-implementation spot check: rewriting three platform5 cases (`§3.1.1` linear, `§3.2.3` branch+loop, `§3.5.1` hybrid UX) yields documents a reviewer can mechanically verify against the skill rules.

## 10. Out of Scope

- Rewriting the platform5 acceptance document.
- Static validator tooling for the new structure.
- Changes to the review report format.
- Parallel case execution (deferred until Variant B is adoptable).
- Runner implementation details (how `flock` is invoked, how AI+human-gate handoff is orchestrated) — these belong to `test-engineer` / `delivery-qa`.
