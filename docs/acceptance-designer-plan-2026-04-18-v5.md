---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v5)"
type: plan
status: revised
created: 2026-04-18
supersedes: docs/acceptance-designer-plan-2026-04-18-v4.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
  - docs/acceptance-designer-plan-review-2026-04-18-v3.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v5)

## 0. What v5 Changes vs v4

v4 correctly baked Platform 5 CLI commands, file paths, and field names into the State Catalog and examples so that codex's V3-B1 "not aligned to the real product" would no longer fire. That answered codex but broke a more important constraint: **the acceptance-designer skill is a generic authoring contract, not a Platform-5–specific runbook**. Embedding product specifics in the skill ties the skill to one project and forces every other project to ignore or rewrite the examples.

v5 corrects the layering:

| Layer | Content | Where it lives |
| --- | --- | --- |
| **Skill (normative)** | Classification rules, observation vocabulary, Flow grammar + Condition sub-grammar, Pass-checklist scopes, outcome vocabulary, State Catalog concept with **placeholders**, case templates as **abstract skeletons** | `skills/acceptance-designer/SKILL.md` and `references/*.md` |
| **Skill (illustrative)** | Short worked examples on a **deliberately invented toy product** (`wfd`, a minimal workflow daemon) so authors see a filled shape without any real-project dependency | one reference file, flagged as non-normative |
| **Project acceptance doc** | Real product commands, paths, field names, fixtures, concrete states | in the project's own `paths.acceptance` document — **not** in the skill |

Changes from v4:

| # | What v4 had | What v5 does |
| --- | --- | --- |
| D1 | State Catalog Variant A written with `platform service start`, `~/.platform5/`, `platformd.pid`, etc. | §4.3 writes both Variants as **schemas with placeholders** (`<service-start>`, `<home-dir>`, `<pid-file>`, `<result-field>`). No product specifics. |
| D2 | Flagship branch+loop example used Platform 5 log paths and gate commands. | §6 Illustrative Examples uses the **`wfd` toy product** for all worked cases. Clearly labeled non-normative. |
| D3 | §7 Migration section mentioned platform5 doc rewrite as in-scope migration. | §7 reframes platform5 as **one of many possible renderings**; skill adoption is decoupled from any project migration. |
| D4 | Open questions mixed skill design with Platform 5 realities (e.g., S3 authoring path). | §8 open questions are now skill-level only. |

Carried forward unchanged from v4: actor ⟂ verifier classification, AI/Human observation tiers, 5 Flow primitives, Condition sub-grammar, Pass-checklist scopes, outcome vocabulary, serial+run-lock rule, Why-human requirement, human and hybrid templates.

All three codex blockers from v3 (V3-B1, V3-B2, V3-B3) remain resolved. V3-B1 is resolved in v5 not by aligning to any specific product, but by removing the scope confusion: the skill doesn't claim to match a product — the project's acceptance doc does.

## 1. Problem Statement

(Same as prior revisions — P1 through P7.)

## 2. Goals

(Same as prior revisions — G1 through G7. Reinforced: the skill is generic; project-specific realization lives in project acceptance docs.)

## 3. Non-Goals

- No changes to human gate, freeze, review cadence, release-tag convention, traceability, or skill boundaries.
- No executable DSL; everything stays human-editable Markdown.
- No static validator tooling.
- **No baked-in product.** The skill produces no normative reference to any specific CLI, path, or schema.
- Parallel case execution remains out.

## 4. Proposed Structural Changes

### 4.1 Case classification — `default-actor` and `verifier`

Each case header declares two classification fields.

**`default-actor`** — one of `ai`, `human`, `system`:

| Value | Meaning |
| --- | --- |
| `ai` | AI executor runs each step's action autonomously. |
| `human` | A human performs the action (typing a deterministic CLI command, or observing/interacting with UI). |
| `system` | No external action — the product auto-advances. Always paired with `kind=wait` on the step. |

Individual steps may override with `(actor=<value>)`.

There is no `human-gate` value; typing a gate command is simply `actor=human` with an action description that states the command.

**`verifier`** — one of `ai`, `human`, `hybrid`:

Determined solely by observation-tier modes in the Flow's expected bullets:

- every bullet uses AI-tier modes → `verifier: ai`
- every bullet uses human-tier modes → `verifier: human`
- mix → `verifier: hybrid` (case structured per §4.9 hybrid template)

Actor and verifier are independent. A case with human-typed steps and all AI-tier observations is `verifier: ai`.

When `verifier ∈ {human, hybrid}`, a header field **`Why human?`** is required: one line justifying why no AI-tier mode suffices. Reviewers may challenge.

### 4.2 Observation vocabulary — two tiers (generic)

The vocabulary names universal observation forms; each project instantiates them with its own paths and field names.

**AI-tier modes** (tokens used verbatim):

| Mode | Form |
| --- | --- |
| `exit-code` | `exit-code = N` or `exit-code ∈ {N1, N2, ...}` |
| `stdout` / `stderr` | `stdout equals "..."` / `stdout contains "..."` / `stdout matches /regex/` |
| `file-exists` / `file-absent` | `file-exists <path>` / `file-absent <path>` (optional `within Ns`) |
| `directory-exists` / `directory-absent` | same form |
| `file-field` | `file-field <path> -> <dotted-key> = <literal>` or `... matches /regex/` or `... ∈ {...}` |
| `log-line` | `log-line in <path> matching /regex/ within Ns` |
| `log-absent` | `log-absent in <path> matching /regex/ during <named-window>` |
| `process-running` / `process-absent` | `process-running matching /regex/` or `process-running pid-file <path>` |
| `socket-listening` / `socket-closed` | `socket-listening <path>` / `socket-closed <path>` |

Default time budget when `within Ns` is omitted: **5s**. Per-bullet override allowed.

**Human-tier modes**:

| Mode | Form |
| --- | --- |
| `visual` | `visual: <description>` |
| `perceived` | `perceived: <description> (threshold: <...>)` |
| `quality` | `quality: <description>` |
| `exploratory` | `exploratory: <scenario>` |

Any token outside these two tables is illegal in expected bullets.

### 4.3 State Catalog — two variants, both expressed as placeholders

The skill prescribes a **shape**. Each acceptance document binds the placeholders to its own product.

Every acceptance document's State Catalog section declares which variant it uses:

```
## 3. State Catalog (Variant A — serial-only, singleton home)
```
or
```
## 3. State Catalog (Variant B — workspace-parameterized)
```

#### Variant A — Serial-only, singleton shared state

Use when the product has global/user-level state (singleton home directory, shared socket, shared config) that cannot be isolated per case.

**Required suite-level rules block:**

```markdown
### 3.0 Suite-level rules
- Run-lock: flock on <acceptance-parent>/.acceptance-run.lock at case start; release at cleanup.
- Serialization: one case at a time. Parallel runs not supported.
- Shared state location: <home-dir>. Reset to Starting state guarantees independence.
- Fixture root: <fixture-root>.
```

**Required schema for each state:**

```markdown
### S<n> — <short semantic name> [(extends S<m>)] [(parameters: {p1}, {p2})]

**Invariants:**
- <AI-tier observation>
- <AI-tier observation>
- ...

**How to reach:** [from S<m>:]
- step (actor=ai): <exact command expressed with <placeholder>s bound by this project>
  expected:
  - <observation confirming the command succeeded>
- step (actor=ai, kind=wait): <description of what becomes true>
  expected:
  - <every invariant of the target state, each with within Ns>
```

Rules:

- Invariants use only AI-tier modes.
- The last reach step's `expected` bullets must enumerate **every** invariant of the target state. Reaching the state *is* the verification; no separate "verify invariants" pseudo-step.
- Reach-step actions cite commands via the project's own placeholder bindings (`<service-start>`, `<service-stop>`, `<process-pattern>`, `<home-dir>`, `<pid-file>`, `<state-file>`, etc.). The skill does not enumerate these placeholders exhaustively; each project declares the placeholders it uses at the top of its State Catalog.
- Reset to Starting state always climbs from the catalog's lowest state up unless the case explicitly opts into an incremental reset and re-verifies invariants.

#### Variant B — Workspace-parameterized

Use when the product supports a workspace / home flag so each case can run in an isolated directory. Same schema as Variant A, but every state signature includes `{ws}` and every command is expressed as operating on `{ws}`. Enables future parallel execution (still out of this plan's scope).

The skill does not prefer one variant. Authors choose based on what the product supports.

### 4.4 Section defaults

A subsection of the acceptance document may declare defaults that all its cases inherit. Case-level fields override. Supported keys: `Starting state`, `Cleanup`, `Verifier`, `default-actor`.

### 4.5 Flow block grammar — 5 primitives

Only these constructs are allowed in a Flow block.

**P1. `step`**

```markdown
- step (actor=<ai|human|system>[, kind=wait]): <action description>
  expected:
  - <observation bullet>
```

- `actor` defaults to the case's `default-actor`.
- `kind=wait` is required when `actor=system` and forbidden otherwise. Every `expected` bullet under a `kind=wait` step **must carry a `within Ns` time budget** (enforced by reviewers).
- Action for `actor=ai` is an exact command. For `actor=human` it is a deterministic operator instruction. For `actor=system, kind=wait` it describes what the product will do unattended.

**P2. `loop-until`**

```markdown
- loop-until <condition>:
  - <inner primitives>
```

**P3. `if` / `else`**

```markdown
- if <condition>:
  - <inner primitives>
- else:
  - <inner primitives>
```

`else` is optional. No `elif`; nest `if` inside `else`.

**P4. `for-each`**

```markdown
- for-each {var} in [<literal1>, <literal2>, ...]:
  - <inner primitives, may textually substitute {var}>
```

Iteration list must be literal. `{var}` substitution is purely textual.

**P5. `set-outcome`**

```markdown
- set-outcome <outcome-value>
```

Terminal; value must come from the outcome vocabulary (§4.8).

**Nesting:** any primitive may nest inside any other, except `set-outcome` which is a leaf.

### 4.6 Condition sub-grammar

Used by `loop-until`, `if`, and nested `if`.

```
<condition> ::=
    <observation-condition>
  | <variable-condition>
  | <compound-condition>

<observation-condition> ::= any AI-tier observation form from §4.2

<variable-condition> ::=
    `{var} = <literal>`
  | `{var} in [<literal>, <literal>, ...]`
  | `{var} not in [<literal>, ...]`

<compound-condition> ::=
    `<condition> and <condition>`
  | `<condition> or <condition>`       (one binary operator only)
```

For deeper logic, nest primitives.

`{var}` must be bound by an enclosing `for-each`.

### 4.7 Pass-checklist scopes

Every checklist bullet declares its scope.

**Scope 1 — per-step rollup**

```markdown
- [ ] every expected bullet in the Flow held
```

**Scope 2 — case-aggregate**

```markdown
- [ ] (aggregate) <aggregate-form>
```

Aggregate operators (closed set):

| Operator | Form | Semantics |
| --- | --- | --- |
| `at-least-once` | `at-least-once in <scope>: <observation>` | At least one iteration of the named scope satisfies the observation. |
| `for-all-iterations` | `for-all-iterations in <scope>: <observation>` | Every iteration satisfies it. |
| `count-matching` | `count-matching(<observation>) in <scope> <op> N` | Count compared via `op ∈ {=, ≥, ≤, >, <}` to N. |

Scope is a named `for-each` variable (`for-each {stage}`) or the case's top-level `loop-until`.

**Scope 3 — end-state**

```markdown
- [ ] end state: <state-id> [with <extra-observation>]
```

Per-step `expected` bullets describe only single-step observations. "Across the case" assertions live in Scope 2. "At completion" assertions live in Scope 3.

### 4.8 Outcome vocabulary

Closed set. Cases and `set-outcome` emit only these values:

| Outcome | Meaning |
| --- | --- |
| `pass` | All Pass-checklist items held. |
| `fail` | A Pass-checklist item failed and is a product issue. |
| `inconclusive-human-needed` | Terminal branch where only a human can judge. Not a product failure. |
| `partial-coverage` | Case passed but a declared branch never exercised. Documented gap. |

Every case's Pass checklist closes with an outcome interpretation line.

### 4.9 Case templates — abstract skeletons

Three skeletons. Each project's acceptance doc fills in the placeholders.

**AI case skeleton** — `default-actor: ai`, `verifier: ai`.

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** ai
**Starting state:** S<n> (<parameters if any>)
**Extra preconditions:** <case-specific delta from the state, if any>
**Cleanup:** <reset target, usually S0>

**Flow:**
- <P1..P5 primitives using §4.2 observation modes and §4.6 conditions>

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) <Scope-2 bullets>
- [ ] end state: <Scope-3 bullet>

**Outcome on checklist-all-true:** <pass | conditional outcome rules>.

**Tracked requirements:** <req ids>
```

**Human case skeleton** — `default-actor: human`, `verifier: human`.

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** human
**verifier:** human
**Why human?** <one-line justification>
**Starting state:** S<n>
**Estimated effort:** <minutes>
**Observer qualification:** <who can do this>

**Setup for the observer:**
<numbered steps to prepare the scenario>

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

**Hybrid case skeleton** — `default-actor: ai`, `verifier: hybrid`, AI block + Human block.

```markdown
#### <case-id> <title>  (<release-tag>)

**default-actor:** ai
**verifier:** hybrid
**Why human?** <one-line justification for the human block>
**Starting state:** S<n>
**Cleanup:** <reset target>

**AI block (Flow):**
- <primitives and expected bullets using AI-tier modes>

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

Serial execution mandated under Variant A. Every case starts by reaching its declared Starting state from whatever state the shared location is in. Parallel is a non-goal until the product supports Variant B's workspace flag.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

- `## Acceptance Content Rules` requires:
  - State Catalog variant declaration (A or B) with placeholders
  - Per-case: `default-actor`, `verifier`, Starting state, Flow block (5 primitives), Pass checklist (scoped bullets), Tracked requirements, release tag
  - `Why human?` when `verifier ∈ {human, hybrid}`
  - Observations use only §4.2 tokens
  - Conditions use only §4.6 sub-grammar
  - Pass-checklist bullets use the scope labels from §4.7
  - Outcomes drawn from §4.8 closed set
  - Serial + run-lock rule under Variant A
- Add `## Acceptance Item Structure` with three abstract skeletons (no product specifics).
- Add `## Classifying a Case` with the actor ⟂ verifier rule and the `Why human?` requirement.
- Working Loop: pick variant → write State Catalog with project's placeholders → classify each case → write Flow → write Pass checklist → review.

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- Required body sections: Document Instructions, Acceptance Preparation, **State Catalog (Variant A|B) with placeholder declarations**, **Section Defaults (optional)**, Main-Flow Stories, Independent Acceptance Items, Next-Phase Constraints.
- Both observation-tier vocabulary tables (verbatim tokens).
- Flow grammar and Condition sub-grammar with minimal **generic** snippets (one per primitive, one per condition form) — no product specifics.
- Pass-checklist scope table.
- Outcome vocabulary table.
- Three case skeletons (abstract).

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

Update rows (generic wording):

| Situation | Decision |
| --- | --- |
| Case shares setup with siblings | Define in State Catalog; cases reference state ID |
| Case cannot use AI-tier modes for a product commitment | `verifier: human` or `hybrid`; never omitted |
| Case has human-typed gate but all AI-tier observations | `default-actor: ai`, step override `(actor=human)`, `verifier: ai` (not hybrid) |
| Author claims `human` to avoid writing mechanical assertions | Reviewer challenges `Why human?`; reclassifies if unjustified |
| Case depends on previous case's tail state | Rejected; every case resets to its Starting state |
| Product offers no workspace flag | Variant A; do not invent a flag |
| Flow needs a construct outside the 5 primitives / Condition grammar | Rewrite via nesting; if truly unavoidable, file grammar extension RFC |
| "Across the case" assertion needed | Scope-2 aggregate Pass-checklist bullet, not step-local `expected` |

### 5.4 New non-normative file: `skills/acceptance-designer/references/illustrative-examples.md`

Contains worked cases on a **deliberately invented toy product** (see §6). Header block states:

> **Non-normative.** These examples use a hypothetical toy product `wfd`. The skill itself prescribes no commands, paths, or field names. Each project instantiates the placeholders in §4.3 with its own product's surface.

Authors consult this file for shape only.

## 6. Illustrative Examples (non-normative, toy product only)

All examples below use a hypothetical **`wfd`** ("workflow daemon") CLI. Assume `wfd` exposes:
- `wfd service start|stop|status` with a PID file `<home>/wfd.pid` and socket `<home>/wfd.sock`
- `wfd tmpl register <path>`, `wfd tmpl list`
- `wfd proj create <name> --tmpl <t>`
- `wfd run start <desc>`
- `wfd gate freeze|approve|reject`
- Results under `<home>/proj/<p>/runs/<id>/results/<stage>.yaml` with field `outcome` ∈ `{pass, not_pass}`
- Log under `<home>/proj/<p>/runs/<id>/log.yaml`

This product is not real; the shapes below only exercise the skill's grammar.

### 6.1 Linear AI case (toy)

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
- step (kind=wait): daemon ready
  expected:
  - file-exists ~/.wfd/wfd.pid within 5s
  - socket-listening ~/.wfd/wfd.sock within 5s
  - exit-code = 0 from `wfd service status` within 5s
- step: `wfd service stop`
  expected:
  - exit-code = 0
- step (kind=wait): daemon down
  expected:
  - file-absent ~/.wfd/wfd.sock within 5s
  - process-absent matching /wfd-server/ within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) log-absent in ~/.wfd/logs/wfd.log matching /level=error/ during the case window

**Outcome on checklist-all-true:** `pass`.

**Tracked requirements:** `r1-REQ-demo-1.1`
```

### 6.2 Branch + loop AI case (toy)

```markdown
#### W.2.3 Closed-loop workflow on toy wfd  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S2 (Variant A, parameters {tpl}=T1, {proj}=P1, {wr-description}="toy closed-loop run")
**Cleanup:** reset to S0

**Flow:**
- step: `wfd run start "toy closed-loop run"` against {proj}
  expected:
  - exit-code = 0
  - file-field ~/.wfd/state.yaml -> projects.{proj}.active_run matches /.+/ (bound as {wr}) within 5s
- for-each {stage} in ["req", "design", "impl", "final"]:
  - step (actor=system, kind=wait): workflow completes producer node `{stage}`
    expected:
    - file-exists ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}.yaml within 300s
    - file-field ~/.wfd/proj/{proj}/runs/{wr}/results/{stage}.yaml -> outcome ∈ {"pass", "not_pass"} within 5s
  - loop-until `file-field .../results/{stage}-review.yaml -> outcome = "pass"` or `file-field .../log.yaml -> nodes.{stage}-review.loop_count ≥ max_retries`:
    - step (actor=system, kind=wait): review node completes
      expected:
      - file-exists .../results/{stage}-review.yaml within 300s
      - file-field .../results/{stage}-review.yaml -> outcome ∈ {"pass", "not_pass"} within 5s
    - if `file-field .../results/{stage}-review.yaml -> outcome = "not_pass"`:
      - step (actor=system, kind=wait): workflow routes back to {stage}
        expected:
        - file-field .../log.yaml -> nodes.{stage}.sessionId unchanged within 60s
        - file-field .../log.yaml -> nodes.{stage}.loop_count incremented within 60s
  - if `file-field .../log.yaml -> nodes.{stage}-review.loop_count ≥ max_retries`:
    - set-outcome inconclusive-human-needed
  - else:
    - if `{stage} in ["req"]`:
      - step (actor=human): human runs "wfd gate freeze"
        expected:
        - exit-code = 0
        - file-field .../log.yaml -> nodes.{stage}.status = "completed" within 5s
        - log-line in .../log.yaml matching /gate\.freeze.*by=human/ within 5s
    - else:
      - step (actor=human): human runs "wfd gate approve"
        expected:
        - exit-code = 0
        - file-field .../log.yaml -> nodes.{stage}.status = "completed" within 5s
        - log-line in .../log.yaml matching /gate\.approve.*by=human/ within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) at-least-once in for-each {stage}: file-field .../log.yaml -> nodes.{stage}.executor ≠ nodes.{stage}-review.executor
- [ ] (aggregate) log-absent in ~/.wfd/logs/wfd.log matching /level=error/ during the case window
- [ ] end state: file-field .../log.yaml -> status = "completed"

**Outcome on checklist-all-true:** `pass`, unless `set-outcome inconclusive-human-needed` fired (then `inconclusive-human-needed`). Emit `partial-coverage` if no `loop-until` iterated more than once across any stage.

**Tracked requirements:** `r1-REQ-demo-4.2` `r1-REQ-demo-4.6`
```

Every construct used is declared by §4.2, §4.5, §4.6, §4.7, or §4.8. No construct outside the grammar.

### 6.3 Human case (toy)

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
- All observation bullets hold across all transitions and interactions.

**Fail signals:**
- Any bullet fails on any transition.

**Recording:** notes at `<acceptance-parent>/human-runs/W-5-1-<YYYYMMDD>.md`.

**Tracked requirements:** `r1-REQ-demo-7.1.1`
```

### 6.4 Hybrid case (toy)

(Omitted for brevity in the plan; `references/illustrative-examples.md` carries the full version. Structure: AI block verifies the routing outcome of a reject via file-field and log-line; human block judges the CLI/TUI feedback `quality`.)

## 7. Migration Impact

- The skill itself is generic. Adoption requires only updating the three skill files per §5.
- Projects that want the new shape (e.g., persona-agents-platform5) rewrite their own `paths.acceptance` document to (a) declare a State Catalog variant, (b) instantiate the placeholders with their product's CLI/paths/fields, (c) restructure each case into the per-case template. That rewrite is **each project's** work, guided by the skill.
- The illustrative `wfd` examples in §6 / `references/illustrative-examples.md` are demonstrations only. Copying them wholesale will not produce a valid project acceptance doc; the placeholders must be bound to a real product.

## 8. Open Questions for Codex Review (v5)

Resolved in v5:

- v4-Q2 (S3 authoring path) → no longer applicable; the skill does not prescribe an S3. Each project builds the states it needs from the §4.3 schema.
- v4-Q1 (`for-each` derived lists) and v4-Q3 (`count-matching` operators) remain open as skill-design decisions; see below.

Still open:

1. **Derived `for-each` lists.** The grammar allows only literal lists. If a real project legitimately needs "iterate over every node in a configuration file", is literal enumeration always acceptable, or should one derived form be added (e.g., `for-each {n} in <derived-source>`)? Recommendation: keep literal-only; revisit on first concrete demand.

2. **`count-distinct` aggregate.** The current aggregate set does not express "at least K distinct values". Add `count-distinct(<field>) in <scope> <op> N`, or hold? Recommendation: hold for v5; add later on demand.

3. **Skeleton file vs. inline in SKILL.md.** `§5.1` proposes skeletons inlined in SKILL.md; `§5.2` also has them in `output-artifacts.md`. Keep both, or make `output-artifacts.md` the single source and SKILL.md link to it? Recommendation: inline the skeletons in SKILL.md (authors should see them alongside the rules) and let `output-artifacts.md` carry the fuller spec — accept the small duplication.

4. **Toy product naming.** `wfd` is generic but might still feel suggestive to anyone familiar with workflow-daemon projects. Should the illustrative examples use an even more neutral domain (e.g., a counter CLI, an image converter)? Recommendation: keep `wfd` — it exercises the grammar's richer constructs (daemon, workflow, gates, loops). A counter can't illustrate `loop-until` or gate actions.

## 9. Completion Criteria

- `SKILL.md` carries the generic rules from §4 with no product-specific commands, paths, or field names.
- `references/output-artifacts.md` carries the full vocabulary + grammar spec with generic snippets only.
- `references/boundary-examples.md` has the §5.3 rows using generic wording.
- `references/illustrative-examples.md` exists, is labeled non-normative, and uses the `wfd` toy product.
- Plan passes codex review on v5.
- Independent sanity check: a developer who has never seen Platform 5 can pick up the skill and write a valid acceptance document for any product from scratch, because the skill does not assume any particular product.

## 10. Out of Scope

- Rewriting any project's acceptance document (that is project work, not skill work).
- Static validator tooling.
- Changes to the review report format.
- Parallel case execution.
- Runner implementation details.
