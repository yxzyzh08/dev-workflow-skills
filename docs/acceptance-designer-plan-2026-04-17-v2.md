---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan (v2)"
type: plan
status: revised
created: 2026-04-17
supersedes: docs/acceptance-designer-plan-2026-04-17.md
prior_review: docs/acceptance-designer-plan-review-2026-04-17.md
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan (v2)

## 0. How v2 Differs From v1

v1 review returned **not pass** with three blockers, plus the human raised a fourth concern. v2 addresses all four.

| # | Source | Concern | v2 resolution |
| --- | --- | --- | --- |
| B1 | codex | Observation vocabulary inconsistent with template examples (TUI, log-absence). | §4.2 splits observations into AI-tier and Human-tier modes; cases declare `verifier` tier; no step may use a mode outside its tier. |
| B2 | codex | Independence goal conflicts with shared global state (`~/.platform5`). | §4.3 parameterizes State Catalog by `workspace`; §4.8 redefines independence as *order-independence in a serial runner* with explicit reset, and declares parallel execution a non-goal until the product supports workspace isolation. |
| B3 | codex | Linear `Steps` cannot express pass/not_pass branching and unbounded review loops. | §4.5 introduces a **Flow block** with three primitives — `step`, `loop-until`, `if-else` — all still Markdown, all using the defined observation vocabulary. |
| H1 | human | Some scenarios are hard to AI-verify; they should be captured as human-verified with guidance, not omitted. | §4.1 adds a `verifier: ai | human | hybrid` tier; §4.6 defines the human-case template with structured observation/signal/recording guidance. §2 adds goal G7. |

## 1. Problem Statement

(Unchanged from v1 — restated briefly for reviewer convenience.)

- **P1.** Action bundles pack multiple verifications into one sentence.
- **P2.** Pass criteria are narrative, not tool-checkable.
- **P3.** No explicit precondition state per case.
- **P4.** No per-step Action↔Expected pairing.
- **P5.** Heavy precondition duplication across cases.
- **P6.** No boolean pass checklist.
- **P7. (new)** Some product commitments are genuinely not AI-automatable (UI render quality, perceived latency, subjective output quality, exploratory TUI behavior). v1 implicitly pushed those out of formal acceptance. That silently shrinks the acceptance surface and hands the work to nobody.

## 2. Goals

- **G1–G6.** (unchanged from v1: per-step exactness, State Catalog, Action↔Expected pairing, pass checklist, case independence, preserve traceability/release-tag/review flow)
- **G7. (new)** A case that is genuinely not AI-automatable is still captured in the acceptance baseline, but marked `verifier: human` and written in a structured human-guidance template. "Can't be tool-checked by AI" must not mean "omitted from acceptance".

## 3. Non-Goals

- No change to human gate, freeze, review cadence, release-tag convention, traceability, or skill boundaries.
- No executable DSL; everything stays human-editable Markdown.
- No automated static-validator for the new structure (future work, could live in `doc-guardian`).
- **Parallel case execution is explicitly out of scope** (see §4.8).

## 4. Proposed Structural Changes

### 4.1 Verifier tiers per case

Every case declares one of:

- **`verifier: ai`** — all steps observable via AI-tier modes (§4.2). Runnable autonomously.
- **`verifier: human`** — at least one key observation requires human judgment. Written in the human template (§4.6).
- **`verifier: hybrid`** — AI-automatable prefix for setup and mechanical checks, followed by a human guidance block for judgment-based observations. Written in the hybrid template (§4.7).

Tier selection rule:

- If every expected observation fits an AI-tier mode → `ai`.
- If judgment/visual/subjective observations are essential to the product commitment → `human` (pure) or `hybrid` (mixed).
- The author must justify `human`/`hybrid` in a one-line **Why human?** field so reviewers can push back when a case could have been AI-verified with more effort.

### 4.2 Observation vocabulary, tiered

**AI-tier modes** (only these may appear in `verifier: ai` cases or in the AI prefix of `hybrid` cases):

| Mode | Form |
| --- | --- |
| `exit-code` | `exit code = N` |
| `stdout` / `stderr` | `equals "..."` / `contains "..."` / `matches /regex/` |
| `file-exists` / `file-absent` | absolute or workspace-relative path |
| `file-field` | addressed by YAML/JSON path, e.g., `state.yaml -> projects.P1.status = "ready"` |
| `log-line` | regex match against a named log file, with a time budget (`within Ns`) |
| `log-absent` | **required regex** that must *not* appear in a named log file during a named window (replaces "no unexpected errors" narrative — a specific pattern must be named) |
| `process` | `process matching /regex/` running / not running |
| `socket` | unix/tcp endpoint listening / closed |

**Human-tier modes** (only allowed in `verifier: human` cases or in the human block of `hybrid` cases):

| Mode | Form |
| --- | --- |
| `visual` | a UI property the observer must see (layout, frame integrity, color, animation) |
| `perceived` | a latency / smoothness judgment with a stated threshold (e.g., "transition feels < 1s") |
| `quality` | a subjective quality judgment about generated content (coherence, tone, faithfulness) |
| `exploratory` | an outcome from free-form interaction within a bounded scenario |

Mode-mixing is forbidden within a single tier. An `ai` case that sneaks in a `perceived` observation must be re-classified as `hybrid` or `human`.

### 4.3 State Catalog with workspace parameterization

Named states are **parameterized by workspace** so each case can bind to its own isolated environment. State Catalog is declared once in §3 of the acceptance document.

```markdown
## 3. State Catalog

> All states are parameterized by `{ws}` — a per-case workspace path. Every command must run with `PLATFORM5_HOME={ws}` exported, or the product's equivalent workspace flag.

### S0({ws}) — Clean
**Invariants (ai-observable):**
- `{ws}/` does not exist, or is empty
- no process matching `/platform .*--home={ws}/` running

**How to reach:** `rm -rf {ws} && pkill -f "platform .*--home={ws}" || true`

### S1({ws}) — Platform started (extends S0({ws}))
**Invariants:**
- `{ws}/state.yaml` exists
- socket `{ws}/platform.sock` listening
- `platform --home {ws} status` exit code = 0

**How to reach:** from S0({ws}): `platform --home {ws} start`

### S2({ws}, {tpl}, {proj}) — Project ready (extends S1({ws}))
**Invariants:**
- `platform --home {ws} template list` stdout contains `{tpl}`
- directory `{ws}/projects/{proj}/` exists
- `{ws}/state.yaml -> projects.{proj}.status = "ready"`

**How to reach:** from S1({ws}): `platform --home {ws} template register ./fixtures/{tpl} && platform --home {ws} project create --template {tpl} --name {proj}`
```

Rules:

- Every state parameter appearing in invariants or reach commands must be declared in the state header signature.
- Invariants must use only AI-tier modes (since state reach/verify is a mechanical precondition, not a product commitment).
- **Product prerequisite.** Workspace isolation requires the product to accept a home/workspace flag. If the product does not yet support this, the plan flags it as a **pre-requisite** of adopting the new acceptance structure in full. Partial adoption is allowed: cases can share one workspace under serial execution (see §4.8) until the flag lands.

### 4.4 Section defaults

(Unchanged from v1.) Each subsection may declare:

```markdown
**Section defaults:**
- **Starting state:** S2({ws}=~/.platform5-test/{case_id}, {tpl}=T1, {proj}=P1)
- **Cleanup:** reset to S0({ws}) after the case
- **Verifier:** ai
```

Case-level fields override section defaults.

### 4.5 AI case template, with Flow block

The **Flow block** replaces the flat numbered list. It supports three primitives; all are ordinary Markdown with fixed keywords.

**Primitive 1 — `step`** (unchanged linear action)

```markdown
- **step:** run `platform --home {ws} start`
  **expected:**
  - exit-code = 0
  - file-exists `{ws}/platform.sock` within 3s
```

**Primitive 2 — `loop-until`** (bounded or unbounded loop, with exit conditions)

```markdown
- **loop-until** `results/req-review.yaml -> verdict = "pass"` **or** `logs/{wr}.yaml -> nodes.req-review.loop_count = max_retries`:
  - **step:** let workflow run node `req-review`
    **expected:**
    - file-field `results/req-review.yaml -> verdict ∈ {pass, not_pass}`
  - **if** `results/req-review.yaml -> verdict = "not_pass"`:
    - **step:** (workflow auto-routes back to `requirements`)
      **expected:**
      - file-field `logs/{wr}.yaml -> nodes.requirements.sessionId` unchanged across this iteration
      - file-field `logs/{wr}.yaml -> nodes.requirements.loop_count` incremented by 1
```

**Primitive 3 — `if` / `else`** (branch on an observed value)

```markdown
- **if** `logs/{wr}.yaml -> nodes.req-review.loop_count = max_retries`:
  - **step:** mark case outcome = `inconclusive-human-needed` and exit.
- **else** (`verdict = "pass"`):
  - **step:** human runs `/freeze`
    **expected:**
    - file-field `logs/{wr}.yaml -> nodes.requirements.status = "completed"`
    - log-line in `logs/{wr}.yaml` matching `/gate.approve.*by=human/` within 5s
```

**Full AI case skeleton:**

```markdown
#### 4.1.1 Service start / stop / address switch  (r1)

**Verifier:** ai
**Starting state:** S0({ws}=~/.platform5-test/4-1-1)
**Extra preconditions:** config.yaml listen address = A
**Cleanup:** reset to S0({ws})

**Flow:**
- step: ...
  expected: ...
- loop-until / if / else as needed
- step: ...
  expected: ...

**Pass checklist (boolean, all must hold):**
- [ ] every `expected` in the Flow held
- [ ] end state: S1({ws}) with address = B
- [ ] log-absent: no match for `/level=error/` in `{ws}/logs/platform.log` during the case window

**Tracked requirements:** `r1-REQ-1.1` `r1-REQ-1.2.7` `r1-REQ-1.3`
```

### 4.6 Human case template

For cases where a product commitment cannot be mechanically checked. Replaces ambiguous narrative with a structured observation/signal/recording format so any qualified human observer can reach the same verdict.

```markdown
#### 5.4.1 TUI render quality during node transition  (r1)

**Verifier:** human
**Why human?** Transition smoothness and visual integrity are perceptual product commitments; there is no stable textual surface that captures rendering artifacts across terminals.
**Starting state:** S2({ws}=~/.platform5-test/5-4-1, {tpl}=T1, {proj}=P1)
**Estimated effort:** 10 minutes
**Observer qualification:** any engineer familiar with the TUI layout.

**Setup for the observer:**
1. Open two TUI instances connected to the same platform, side-by-side.
2. Create a work request whose workflow will execute at least 3 nodes.
3. Start the workflow.

**What to observe (human-tier modes only):**
- `visual`: during a node transition, neither TUI retains stale content from the prior node for more than 1s.
- `visual`: log stream redraws without partial frames, color bleed, or cursor artifacts.
- `perceived`: node transition feels instant (< 1s perceived lag); if it feels sluggish, it fails.
- `visual`: token counter increments monotonically — never decreases, never resets mid-node.

**What to try:**
- Resize one terminal mid-run.
- Scroll back in the log panel while the node is producing output.
- Detach and re-attach one TUI while the other observes.

**Pass signals:**
- All "What to observe" bullets hold through the full 3-node run and during each "What to try" action.

**Fail signals:**
- Any single bullet fails on any node transition → the case fails.

**Recording:**
- Short note (1–3 lines) per observation bullet: `pass` or `fail` + one sentence.
- Attach a screenshot for any `fail`.
- Save notes as `<paths.acceptance parent>/human-runs/5-4-1-<YYYYMMDD>.md`.

**Tracked requirements:** `r1-REQ-7.1.1` `r1-REQ-7.1.5`
```

Rules:

- `Why human?` is **required** — it forces the author to justify non-automation; reviewers can challenge it.
- Every "What to observe" bullet must use a declared human-tier mode (`visual` / `perceived` / `quality` / `exploratory`).
- Pass/fail signals must be concrete enough that two qualified observers reach the same verdict independently.
- Recording format is required so human verification leaves a durable artifact.

### 4.7 Hybrid case template

For cases with automatable setup + checks but a judgment tail, or vice versa.

```markdown
#### 4.5.1 /reject at human-gate and downstream routing  (r1)

**Verifier:** hybrid
**Why human?** The post-reject routing is structurally checkable, but the CLI/TUI feedback quality to the rejecting human is itself a product commitment.
**Starting state:** S2({ws}=...)
**Cleanup:** reset to S0({ws})

**AI block (Flow):**
- step: advance workflow until node enters `paused_at_gate`
  expected:
  - file-field `logs/{wr}.yaml -> nodes.<gate>.status = "paused_at_gate"`
- step: run `platform --home {ws} reject --work {wr}`
  expected:
  - exit-code = 0
  - log-line in `logs/{wr}.yaml` matching `/gate.reject.*by=human/` within 5s
  - file-field `logs/{wr}.yaml -> nodes.<gate>.status ∈ {failed, rejected-routing-target}`

**AI pass checklist:**
- [ ] every AI-block expected held
- [ ] routing destination matches workflow's configured reject branch

**Human block:**
- What to observe:
  - `quality`: the CLI message returned after `/reject` clearly states (a) the rejection was accepted, (b) which node was rejected, (c) where the workflow goes next
  - `visual`: TUI updates within 1s to reflect the rejected state
- Pass signals: both bullets hold.
- Fail signals: either bullet fails.
- Recording: 2-line note at `<paths.acceptance parent>/human-runs/4-5-1-<YYYYMMDD>.md`.

**Overall pass:** AI checklist passes AND human block passes.

**Tracked requirements:** `r1-REQ-1.2.4` `r1-REQ-4.6` `r1-REQ-4.7` `r1-REQ-6.2`
```

### 4.8 Independence — redefined as *order-independence in a serial runner*

v2 explicitly narrows the independence claim to what is achievable today.

- **Serial execution is assumed.** Cases run one at a time in an acceptance session.
- **Order-independence is required.** Case N must not depend on case N-1's tail state. Each case starts from its declared Starting state via the State Catalog reset.
- **Parallel execution is a non-goal** until the product supports workspace isolation (the home/workspace flag). With that flag, the State Catalog's `{ws}` parameterization makes parallel execution achievable as future work; v2 does not mandate it.
- **Cleanup is strongly recommended** but not required when the case is pure observation of an incoming state (e.g., a read-only `platform status` check). The Starting-state reset at the next case provides a safety net.

This directly resolves codex B2: the rule now matches what the state model can actually guarantee.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

- Rewrite `## Acceptance Content Rules` to require:
  - Verifier tier declared per case
  - State Catalog with workspace parameterization
  - Flow block (step / loop-until / if-else) for AI and hybrid-AI blocks
  - Human template fields for human and hybrid-human blocks
  - Pass checklist required for ai and hybrid cases; Pass/Fail signals required for human cases
  - Serial execution + order-independence rule
- Add `## Acceptance Item Structure` section with three skeletons inlined (ai / human / hybrid).
- Add `## Choosing a Verifier Tier` with the rule from §4.1 (and the "Why human?" justification requirement).
- Working Loop updated: write State Catalog first → classify each case into a tier → write cases referencing states.

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- Required body sections list: Document Instructions, Acceptance Preparation, **State Catalog**, **Section Defaults (optional per-section)**, Main-Flow Stories, Independent Acceptance Items, Next-Phase Constraints.
- Observation vocabulary: both tiers fully listed with forms.
- Three case templates (ai / human / hybrid) in full.
- Flow block syntax with minimal examples for each primitive.
- Review report contract unchanged.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

New/updated rows:

| Situation | Owner / Decision |
| --- | --- |
| Case shares setup with many siblings | Define setup once in State Catalog; cases reference state ID |
| Case cannot be expressed with AI-tier modes | Classify as `human` or `hybrid`; do not silently omit |
| Mix of mechanical checks and judgment | `hybrid` template |
| Author claims `human` to avoid writing mechanical assertions | Reviewer rejects unless `Why human?` survives scrutiny |
| Case depends on previous case's tail state | Reject; every case must start from a State Catalog ID |

### 5.4 No new files.

## 6. Before / After Examples

### 6.1 Linear ai case

Platform5 §3.1.1 "Service start / stop / address switch". v1 before/after is preserved — the v2 ai skeleton in §4.5 already serves as the after.

### 6.2 Branch + loop ai case (answers codex B3)

Platform5 §3.2.3 "Closed-loop workflow acceptance" rewritten under v2:

```markdown
#### 4.2.3 Closed-loop workflow acceptance  (r1)

**Verifier:** ai
**Starting state:** S2({ws}=~/.platform5-test/4-2-3, {tpl}=T1, {proj}=P1)
**Extra preconditions:** work request "实现一个命令行 TODO 管理工具..." created and frozen
**Cleanup:** reset to S0({ws})

**Flow:**

For each stage in [requirements, acceptance, architecture, design, development, final-acceptance]:
- step: let workflow execute the stage's producer node
  expected:
  - file-exists `.workflow/results/{stage}.yaml` within 60s
  - file-field `results/{stage}.yaml -> verdict ∈ {pass, not_pass}`
- loop-until `results/{stage}-review.yaml -> verdict = "pass"` or `logs/{wr}.yaml -> nodes.{stage}-review.loop_count = max_retries`:
  - step: let workflow execute the review node
    expected:
    - file-field `results/{stage}-review.yaml -> verdict ∈ {pass, not_pass}`
    - file-field `logs/{wr}.yaml -> nodes.{stage}-review.executor` ≠ `nodes.{stage}.executor` (at least one stage)
  - if `verdict = "not_pass"`:
    - step: (workflow auto-routes back to producer)
      expected:
      - file-field `logs/{wr}.yaml -> nodes.{stage}.sessionId` unchanged
      - file-field `logs/{wr}.yaml -> nodes.{stage}.loop_count` incremented by 1
- if `logs/{wr}.yaml -> nodes.{stage}-review.loop_count = max_retries`:
  - step: mark outcome = `inconclusive-human-needed` and exit.
- else:
  - step: human runs `/approve` (or `/freeze` for requirements and acceptance)
    expected:
    - file-field `logs/{wr}.yaml -> nodes.{stage}.status = "completed"`
    - log-line matching `/gate\.(approve|freeze).*by=human/` within 5s

**Pass checklist:**
- [ ] all stages reached `completed`
- [ ] at least 2 stages used an executor different from the default (per `executors.yaml`)
- [ ] log-absent: no match for `/level=error/` in `{ws}/logs/platform.log` during the run
- [ ] work request state transitions `running` → `completed` visible in `logs/{wr}.yaml`
- [ ] summary block in `logs/{wr}.yaml` reflects all completed stages

**Inconclusive outcomes (documented, not failures):**
- If no stage naturally looped (`loop_count = 0` for all review nodes), the run is `pass-but-loop-uncovered`; loop verification is then delegated to the independent case §5.1.2.

**Tracked requirements:** `r1-REQ-4.2` `r1-REQ-4.3` `r1-REQ-4.6` `r1-REQ-4.7` `r1-REQ-5.1` `r1-REQ-5.2` `r1-REQ-5.3` `r1-REQ-6.1` `r1-REQ-6.2` `X2`
```

This faithfully expresses branching, loops, session-consistency, max-retries termination, and executor-variation — all within the observation vocabulary.

### 6.3 Human case

§4.6 TUI render example already illustrates.

### 6.4 Hybrid case

§4.7 `/reject` example already illustrates.

## 7. Migration Impact

- `persona-agents-platform5/docs/acceptance/acceptance.md` — currently `active` under CR-01 continuation. Will need a full rewrite under v2 structure. That rewrite is outside this plan's scope.
- The product currently does not support a workspace home flag. Two options:
  - (a) pre-requisite: add the flag first, then adopt v2 with real isolation;
  - (b) interim: adopt v2 with `{ws}` fixed to `~/.platform5` and rely on serial execution + Starting-state reset. §4.8's serial model already accepts this.
  - Recommendation: adopt (b) now; upgrade to (a) when the product adds the flag.

## 8. Open Questions for Codex Review (v2)

Resolved from v1:

- v1 Q1 (State Catalog granularity) → §4.3 chose linear-extension with parameters.
- v1 Q2 (Cleanup required?) → §4.8 answered: strongly recommended, safety net at next Starting-state reset.
- v1 Q3 (Time budget default) → adopted: `within 5s` is the default for log-line and file-exists observations when unspecified; cases may override per bullet.
- v1 Q4 (Log-absent vocabulary) → §4.2 `log-absent` requires a named regex; no more narrative "no unexpected errors".
- v1 Q5 (TUI observations) → §4.2 + §4.6: TUI and similar observations are legal via human-tier modes in `human`/`hybrid` cases.
- v1 Q6 (Boundary vs `test-engineer`) → §5.3 adds the boundary row.

Still open for v2:

1. **Product prerequisite for real isolation.** §4.3 assumes the product will eventually accept a home/workspace flag. If the platform team will not add it, is serial-only execution (§4.8) an acceptable permanent state, or does v2 need to mandate the flag as a product requirement?

2. **`Why human?` reviewer authority.** §4.1 and §5.3 let a reviewer reject `human`/`hybrid` classification. Should the `delivery-qa` skill, `test-engineer`, or `acceptance-designer` own that override? Recommendation: `acceptance-designer` owns it during the acceptance review round; `test-engineer` may raise a finding if an `ai` case turns out not to be automatable in practice.

3. **Loop bound expressiveness.** The Flow block's `loop-until` accepts an `or` of two conditions. Is that sufficient for all realistic acceptance loops, or should the primitive accept an arbitrary disjunction/conjunction? Recommendation: keep the two-condition form; if a case needs more, that is a signal to split the case.

4. **Inconclusive outcomes.** §6.2 introduces `inconclusive-human-needed` as a terminal outcome (e.g., when `max_retries` hits) and `pass-but-loop-uncovered` as a partial outcome. Should these be first-class outcome vocabulary in the skill rules, or left case-local? Recommendation: first-class — add an `Outcomes` vocabulary (`pass`, `fail`, `inconclusive-human-needed`, `partial-coverage`) to the skill and let cases reference it.

5. **Human-run recording path convention.** §4.6 proposes `<paths.acceptance parent>/human-runs/<case-id>-<date>.md`. Should this be standardized in `workflow-project.yaml` alongside `paths.acceptance`, or left to the skill's reference file? Recommendation: standardize in the skill reference for now; promote to `workflow-project.yaml` only if cross-skill needs emerge.

## 9. Completion Criteria

- `SKILL.md` rules cover verifier tiers, State Catalog with workspace params, Flow block, human/hybrid templates, outcome vocabulary, order-independence-in-serial rule.
- `references/output-artifacts.md` specifies all three templates with filled-in examples and the two-tier observation vocabulary.
- `references/boundary-examples.md` has rows for shared setup, non-automatable cases, hybrid cases, `Why human?` challenge, and tail-state dependence.
- Plan passes codex review on v2.
- Post-implementation spot check: rewriting platform5 §3.1.1 (linear), §3.2.3 (branch+loop), §3.5.1 or §4.3.2 (hybrid/human) under the new skill each yields an unambiguously executable or observable case.

## 10. Out of Scope

- Rewriting the platform5 acceptance document.
- Building a static validator for the new structure.
- Changes to the review report format.
- Parallel case execution (gated on product-level workspace isolation).
