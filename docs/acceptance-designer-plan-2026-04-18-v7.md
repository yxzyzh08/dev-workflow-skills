---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v7)"
type: plan
status: revised
created: 2026-04-18
supersedes: docs/acceptance-designer-plan-2026-04-18-v6.md
prior_reviews:
  - docs/acceptance-designer-plan-review-2026-04-17.md
  - docs/acceptance-designer-plan-review-2026-04-17-v2.md
  - docs/acceptance-designer-plan-review-2026-04-18-v3.md
  - docs/acceptance-designer-plan-review-2026-04-18-v5.md
  - docs/acceptance-designer-plan-review-2026-04-18-v6.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v7)

## 0. What v7 Changes vs v6

v6 review returned **not pass** with three blockers. All three are surgical; v7 adopts every fix.

| # | v6 blocker | v7 resolution |
| --- | --- | --- |
| V6-B1 | `for-each` P4 grammar said "literal list only", but §4.2.1 Placeholders and the flagship example both used a placeholder-bound list. | §4.5 P4 grammar extended: `<list-source> ::= <literal-list> | <list-placeholder>`. A list placeholder is a case-level Placeholder whose right-hand side resolves to a literal list. Authors may use either form. |
| V6-B2 | `file-field-delta` checkpoint `iteration-start` semantics in nested loops was left as an open question, despite the flagship example using it inside nested `for-each` + `loop-until`. | §4.2 now defines `iteration-start` normatively as **the start of the innermost enclosing `for-each` or `loop-until` iteration**. No longer an open question. Authors who need the outer iteration's start must use `loop-start` / `case-start` or split the case. |
| V6-B3 | Outcome rule wording in flagship example ("`pass`, unless ... (then ...). Emit `partial-coverage` if ...") left unclear whether `partial-coverage` replaces `pass`, adds to it, or is a separate channel. | §4.8 redefines outcomes as a **single, exclusive, priority-ordered** closed set. Each case's outcome rule is written as a numbered priority list; the first matching rule wins. `partial-coverage` is a first-class outcome that *replaces* `pass` when declared-but-unexercised branches exist. §6.2 rewritten to use priority-list outcome form. |

Carried forward unchanged from v6: skill-vs-project layering, Variant A/B State Catalog, actor ⟂ verifier, AI/Human observation tiers, normalized `kind=wait` rule, 5-primitive Flow grammar, Condition sub-grammar, extended `file-field`, `file-field-delta` mode (now with resolved semantics), case-level Placeholders, Pass-checklist scopes, Why-human requirement, per-tier required-field lists.

## 1. Problem Statement

(Unchanged from prior revisions — P1 through P7.)

## 2. Goals

(Unchanged — G1 through G7.)

## 3. Non-Goals

(Unchanged. Skill stays product-agnostic. Parallel execution out.)

## 4. Proposed Structural Changes

### 4.1 Case classification — `default-actor` and `verifier`

Unchanged from v6 §4.1.

### 4.2 Observation vocabulary — two tiers

AI-tier modes (same table as v6 §4.2). **Normative update on `file-field-delta`:**

**`file-field-delta` form and checkpoint semantics:**

```
file-field-delta <path> -> <dotted-key> <delta-form> since <checkpoint>

<delta-form> ::=
    unchanged
  | increased by <N>
  | increased by at-least <N>
  | decreased by <N>
  | decreased by at-least <N>

<checkpoint> ::= case-start | step-start | iteration-start | loop-start
```

Checkpoint definitions (normative — resolves V6-B2):

| Checkpoint | Meaning |
| --- | --- |
| `case-start` | Start of the Flow block (before primitive 1 runs). |
| `step-start` | Start of the current step (before its action or wait began). |
| `iteration-start` | **Start of the innermost enclosing `for-each` or `loop-until` iteration.** When nested, the innermost iterator wins. Authors who need an outer iteration's start must use `loop-start` for the enclosing `loop-until`, or split the case. |
| `loop-start` | Start of the innermost enclosing `loop-until` primitive as a whole (before its first iteration). This is distinct from `iteration-start`: `loop-start` is fixed across all iterations of that loop; `iteration-start` advances each iteration. When the innermost enclosing iterator is a `for-each`, `loop-start` refers to the nearest enclosing `loop-until` above it, if any; if no enclosing `loop-until` exists, `loop-start` falls back to `case-start`. |

`<N>` is a non-negative integer literal or a named Placeholder.

`file-field-delta` is legal inside any step-level expected bullet; the evaluation point is when that bullet is checked.

Human-tier modes: unchanged.

Default time budget: **5s** when `within Ns` omitted.

### 4.2.1 Case-level Placeholders block

Unchanged from v6 §4.2.1. A Placeholder's right-hand side can be: a string/number literal, a literal list, or a `file-field <path> -> <key>` reference. Placeholders are case-local and may appear anywhere the grammar accepts a literal — **including `for-each` list sources** (see §4.5 P4).

### 4.3 State Catalog — Variant A and Variant B

Unchanged from v6 §4.3.

### 4.4 Section defaults

Unchanged.

### 4.5 Flow block grammar — 5 primitives (P4 extended)

**P1. `step`** — unchanged from v6 (normalized `kind=wait` rule stands).

**P2. `loop-until`** — unchanged.

**P3. `if` / `else`** — unchanged.

**P4. `for-each`** — grammar extended (resolves V6-B1):

```markdown
- for-each {var} in <list-source>:
  - <inner primitives, may textually substitute {var}>
```

```
<list-source> ::=
    <literal-list>
  | <list-placeholder>

<literal-list>     ::= [<literal>, <literal>, ...]
<list-placeholder> ::= `<placeholder-name>`   (must resolve to a literal list
                                                via a case-level Placeholder
                                                declaration in §4.2.1)
```

Rules:

- `<literal-list>` is an inline bracketed list of string, number, or quoted-identifier literals.
- `<list-placeholder>` must be a name declared in the case's Placeholders block. The declaration's right-hand side must itself be a literal list (not a `file-field` reference, not a computed form). At Flow evaluation time, the placeholder resolves to that literal list.
- `{var}` substitution remains purely textual.

Derived list sources (e.g., `nodes-of(<yaml>)`) are still not allowed. Authors who genuinely need a derived list must enumerate via a Placeholder or split the case.

**P5. `set-outcome`** — unchanged in form, but the outcome vocabulary and exclusivity rules change (see §4.8).

### 4.6 Condition sub-grammar

Unchanged from v6 §4.6.

### 4.7 Pass-checklist scopes

Unchanged from v6 §4.7. Scopes: per-step rollup, case-aggregate, end-state. Aggregate operators: `at-least-once`, `for-all-iterations`, `count-matching`.

### 4.8 Outcome vocabulary — exclusive, priority-ordered (resolves V6-B3)

Every case evaluates to **exactly one** outcome from the closed set below. Outcomes are mutually exclusive; there is no secondary annotation channel.

| Outcome | Meaning |
| --- | --- |
| `fail` | At least one Pass-checklist item failed, attributable to a product issue. |
| `inconclusive-human-needed` | The Flow hit a `set-outcome inconclusive-human-needed` branch, or a failure was attributable to environment/human not the product. Not a product defect. |
| `partial-coverage` | Pass-checklist items all held, **but** at least one declared branch was not exercised during the run (e.g., a retry loop never iterated past 0 though the case declares retry coverage). Not a product defect; a coverage gap. |
| `pass` | Pass-checklist items all held **and** every declared branch was exercised. |

Rules:

- Outcome is **singular and deterministic**. A case never emits more than one outcome.
- Cases declare their outcome rule as a **priority-ordered numbered list**; the first rule whose condition matches wins. Later rules are shorthand for "if none of the earlier conditions matched".
- Linear cases without declared branches never emit `partial-coverage` (there are no declared branches to under-exercise).

**Standard outcome-rule template (for ai and hybrid cases):**

```markdown
**Outcome rule (priority order, first match wins):**
1. If any Pass-checklist item failed for a product reason: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
3. Else if <case-specific under-coverage condition>: `partial-coverage`
4. Else: `pass`
```

Cases without declared branches may drop rule 3 entirely.

Human cases emit outcomes via Pass-signal / Fail-signal evaluation only; the priority list collapses to `fail` (any Fail signal hit), `inconclusive-human-needed` (observer unable to complete), `pass` (all Pass signals hit).

### 4.9 Case templates

Unchanged from v6 §4.9 in structure. The AI and hybrid skeletons now include the priority-ordered outcome rule as a required field (replacing the free-prose "Outcome on checklist-all-true" line).

**AI skeleton outcome-rule line (required):**

```markdown
**Outcome rule (priority order, first match wins):**
1. ...
2. ...
```

### 4.10 Independence and run-lock

Unchanged.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

Unchanged structure from v6 §5.1 (per-tier required-field lists). Two additions:

- Under "Shared structural rules": add `Outcome rule written as a priority-ordered numbered list (first match wins)` and `Outcome is singular; never emit more than one outcome for a case`.
- Under "Shared structural rules": add `file-field-delta checkpoint iteration-start binds to the innermost enclosing iterator`.
- Under AI / hybrid required-field lists: replace the free-prose "outcome interpretation line" with "priority-ordered outcome rule (§4.8 template)".

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

Updates from v6 §5.2:

- §4.2 `file-field-delta` checkpoint table locked with the V7 semantics.
- §4.5 P4 spec includes both `<literal-list>` and `<list-placeholder>` forms.
- §4.8 outcome table includes the priority-list template and the "singular outcome" rule.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

Carried from v6 §5.3. One new row:

| Situation | Decision |
| --- | --- |
| Case needs to iterate a list reused across multiple for-each sites | Declare a list Placeholder (§4.2.1); use `` `placeholder` `` as the P4 list-source |
| Outcome feels like it should be "pass + partial-coverage annotation" | Not allowed; outcomes are singular. Use `partial-coverage` *instead* of `pass`, not alongside |
| `file-field-delta` target is the outer `for-each` iteration, not the inner `loop-until` iteration | Not directly expressible. Use `loop-start` for the outer loop-until if one exists, or split the case, or promote the outer iterator's start to a step-local checkpoint by refactoring |

### 5.4 `skills/acceptance-designer/references/illustrative-examples.md`

Carries the toy `wfd` examples, updated for v7 grammar and outcome form (see §6).

## 6. Illustrative Examples (non-normative, toy product `wfd`)

### 6.1 Linear AI case (toy)

Unchanged from v6 §6.1 except the outcome line. Replace:

```markdown
**Outcome on checklist-all-true:** `pass`.
```

with:

```markdown
**Outcome rule (priority order, first match wins):**
1. If any Pass-checklist item failed for a product reason: `fail`
2. Else: `pass`
```

(Linear case has no declared branches, so no `partial-coverage` rule and no `inconclusive-human-needed` branch.)

### 6.2 Branch + loop AI case (toy, v7 grammar)

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

**Declared branches (for partial-coverage rule):**
- B1: at least one `loop-until` iteration fired (i.e., at least one review came back `not_pass` and triggered a loop-back)

**Outcome rule (priority order, first match wins):**
1. If any Pass-checklist item failed for a product reason: `fail`
2. Else if `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
3. Else if branch B1 was not exercised (every `loop-until` terminated on its first iteration): `partial-coverage`
4. Else: `pass`

**Tracked requirements:** `r1-REQ-demo-4.2` `r1-REQ-demo-4.6`
```

v7 construct audit against the declared grammar:

- `for-each {stage} in \`stage-list\`` ✓ (P4, `<list-placeholder>` form — V6-B1 resolved)
- `step (actor=system, kind=wait)` with `within Ns` on every bullet ✓ (P1 normalized)
- `step (actor=human)` with deterministic command instruction ✓ (P1)
- `loop-until <compound-condition with or>` ✓ (P2 + Condition sub-grammar)
- `file-field X -> k ≥ max_retries` ✓ (§4.2 extended `file-field`; placeholder-bound)
- `file-field-delta ... unchanged since iteration-start within 60s` ✓ (§4.2 with `iteration-start` normatively = innermost iterator — V6-B2 resolved; here the innermost iterator is the `if`-nested step's enclosing `loop-until`)
- `file-field-delta ... increased by at-least 1 since iteration-start within 60s` ✓ (same)
- `{stage} in ["req"]` ✓ (variable-condition)
- `set-outcome inconclusive-human-needed` ✓ (P5 + outcome vocab)
- Scope-2 aggregates `at-least-once` and `count-matching(...) ≥ 2` ✓ (§4.7)
- Field-to-field comparison ✓ (§4.2 extended `file-field`)
- Priority-ordered outcome rule with exclusive values ✓ (§4.8 — V6-B3 resolved)

All constructs declared. No open semantics.

### 6.3 Human case (toy)

Unchanged from v6 §6.3. No Flow, no Pass checklist (per §5.1 per-tier rules).

### 6.4 Hybrid case (toy)

Carried in `references/illustrative-examples.md`, updated to use the priority-ordered outcome rule format for the AI block.

## 7. Migration Impact

Unchanged from v6 §7. Project acceptance docs rewritten under v7 use the priority-ordered outcome template, the list-placeholder form, and the locked `iteration-start` semantics.

## 8. Open Questions for Codex Review (v7)

Resolved in v7:

- v6 wait-step ambiguity → §4.5 P1 normalized (since v6).
- v6 missing numeric/delta/field-to-field semantics → §4.2 extended (since v6).
- V6-B1 `for-each` vs placeholder → §4.5 P4 extended.
- V6-B2 `iteration-start` nested semantics → §4.2 locked.
- V6-B3 outcome ambiguity → §4.8 exclusive priority-ordered closed set.

Still carried open:

1. **Derived `for-each` lists.** Still literal-only (literal-list or list-placeholder whose RHS is a literal list). No derived form. Revisit on first real demand.
2. **`count-distinct` aggregate.** Not added. `count-matching` with field comparison covers most needs.
3. **Labeled loop checkpoints.** If a case genuinely needs `iteration-start of the outer for-each` rather than innermost, the only current options are `loop-start` (nearest enclosing `loop-until` as a whole), `case-start`, or case split. Named checkpoints (`as {label}` on a primitive, referenced later) could be added if real cases demand it; held for now.

New in v7:

4. **Outcome rule enforcement.** The §4.8 priority-list format is normative. Should the skill also require the list to include a `fail` rule as rule 1 (even when there's no obvious product-failure path)? Recommendation: yes — require every AI/hybrid case to start with rule 1 = `fail` on checklist-item failure, even for cases where failure "shouldn't happen" in practice.

## 9. Completion Criteria

- `SKILL.md` carries the per-tier required-field lists; shared structural rules include the priority-ordered outcome rule and the innermost-iterator checkpoint rule; no product specifics.
- `references/output-artifacts.md` locks V7 `file-field-delta` semantics, P4 list-placeholder form, and the §4.8 outcome template.
- `references/boundary-examples.md` has the v6 rows plus the three new v7 rows.
- `references/illustrative-examples.md` uses the v7 outcome format and list-placeholder form.
- Plan passes codex review on v7.
- §6.2 construct audit against the declared grammar passes mechanically (every construct cites a grammar rule).

## 10. Out of Scope

(Same as prior revisions.)
