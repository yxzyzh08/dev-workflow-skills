---
title: "Acceptance Designer Skill — AI-Readable Restructure Plan"
type: plan
status: draft
created: 2026-04-17
author: claude
target_skill: skills/acceptance-designer/
reviewer: codex
---

# Acceptance Designer Skill — AI-Readable Restructure Plan

## 1. Problem Statement

The current `acceptance-designer` skill produces acceptance documents that read well for humans but are hard for an AI executor to verify step-by-step. Observed on the live output at `../persona-agents-platform5/docs/acceptance/acceptance.md`:

**P1. Action bundles.** A single "验收动作" paragraph packs multiple independent actions. Example — `§3.1.1`:

> 在 `~/.platform5/config.yaml` 中设置 Unix socket 地址 A，执行 `platform start` 启动服务；使用 CLI 和 TUI 分别连接平台；执行 `platform stop` 停止服务并确认连接中断；随后将监听地址改为 Unix socket 地址 B，重新启动服务后再次使用 CLI 和 TUI 访问

Four distinct verifiable actions are merged into one sentence. If action 3 fails, the executor cannot point at a specific step.

**P2. Pass criteria are narrative, not observable.** Example — `§3.1.1` pass criteria says "服务能以常驻进程形式启动并保持运行". An AI must translate this into "which pid file / which process name / which exit code / which log line". Translation is ambiguous and non-reproducible across runs.

**P3. No explicit precondition state.** Cases do not declare the starting state. AI must infer whether `platform start` has already been executed, whether a project exists, whether logs are clean. Inference drifts across runs.

**P4. No per-step expected output.** Actions and criteria are in separate paragraphs rather than paired. AI cannot emit a per-step pass/fail diagnosis.

**P5. Heavy precondition duplication.** Most §3 and §4 cases depend on "platform started + template registered + project created" but each case would repeat that state inline if P3 were fixed naively. This wastes tokens and invites drift between copies.

**P6. No pass decision checklist.** Cases do not end with a concrete boolean checklist. AI cannot mechanically decide the overall case outcome.

## 2. Goals

G1. Every case is executable by an AI without interpretation: each action has an exact command; each expected result is a tool-checkable observation.

G2. Preconditions are declared once as named states (a State Catalog) and referenced by ID per case, eliminating duplication.

G3. Each action step pairs with its own expected observations, so failures localize to a specific step.

G4. Each case ends with a boolean pass checklist the AI can answer yes/no on.

G5. Cases are independent: each case starts from a named state, not from the tail of the previous case. This lets AI execute them in any order or in parallel.

G6. Keep the existing value already in the skill: traceability to requirements/`X` IDs, release-tag convention, formal inclusion rule for non-normal paths, human gate flow, review report format.

## 3. Non-Goals

- No change to the human confirmation gate, freeze semantics, or review cadence.
- No change to release tag convention `(r1)` / `(r1→r3 modified)`.
- No change to the requirement/architecture/test skill boundaries.
- Not producing pseudocode / executable DSL. The document remains human-editable Markdown. The structure just makes it mechanically consumable.

## 4. Proposed Structural Changes

### 4.1 New required body section: **State Catalog**

Inserted after §2 "Acceptance Preparation". Declares named states. Each case references a state ID in its preconditions.

```markdown
## 3. State Catalog

### S0 — Clean
**Invariants (observable):**
- `~/.platform5/` does not exist
- no process named `platform` running

**How to reach:** from any state, run `rm -rf ~/.platform5 && pkill -f 'platform ' || true`

### S1 — Platform started  (extends S0)
**Invariants (observable):**
- file `~/.platform5/state.yaml` exists
- socket `~/.platform5/platform.sock` is listening
- `platform status` exit code = 0

**How to reach:** from S0, run `platform start`

### S2 — Project ready  (extends S1)
**Invariants (observable):**
- template `T1` appears in `platform template list`
- project `P1` directory `~/.platform5/projects/P1/` exists
- `~/.platform5/state.yaml` field `projects.P1.status` = `"ready"`

**How to reach:** from S1, run `platform template register ./fixtures/T1 && platform project create --template T1 --name P1`
```

Rules:
- Each state has an **ID**, **observable invariants**, and **how to reach** (either absolute or as a delta from a parent state).
- Invariants must be tool-checkable (file exists, field equals, command exit code, process name, regex match against stdout).
- States are the *only* place setup commands appear. Cases never re-describe setup, they only name a state.

### 4.2 New required body section: **Section Defaults**

Each §4.x / §5.x subsection may declare defaults that all its cases inherit. Case-level fields override section defaults.

```markdown
### 4.2 Work-request lifecycle

**Section defaults:**
- **Starting state:** S2
- **Cleanup:** return to S2 after the case (delete any created work request)
```

Rules:
- Section defaults are optional. If absent, each case declares its own.
- A case may override by setting its own `Starting state:` field.

### 4.3 Per-case strict template

Every case (both main-flow `§4.x.y` and independent `§5.x.y`) must follow this skeleton:

```markdown
#### 4.1.1 Service start / stop / address switch  (r1)

**Starting state:** S0
**Extra preconditions (case-specific):** config.yaml listen address = A

**Steps:**

1. **Action:** run `platform start`
   **Expected:**
   - exit code = 0
   - file `~/.platform5/platform.sock` exists within 3s
   - `platform status` exit code = 0

2. **Action:** run `platform ping` (from a CLI client) and open one TUI session
   **Expected:**
   - `platform ping` stdout matches regex `ok address=.*A`
   - TUI connects without error

3. **Action:** run `platform stop`
   **Expected:**
   - exit code = 0
   - socket file removed within 3s
   - next `platform ping` exits non-zero with stderr matching `connection refused`

4. **Action:** set config.yaml listen address = B, then run `platform start`
   **Expected:**
   - exit code = 0
   - `platform ping` stdout matches regex `ok address=.*B`
   - TUI reconnects at address B

**Pass checklist (all must be true):**
- [ ] Each step's "Expected" bullets all hold
- [ ] No unexpected error entries appear in `~/.platform5/logs/platform.log` during the run
- [ ] End state: service running at address B

**Tracked requirements:** `r1-REQ-1.1` `r1-REQ-1.2.7` `r1-REQ-1.3`
**Cleanup:** run `platform stop && rm ~/.platform5/platform.sock`
```

Fields (all required unless marked optional):

| Field | Required | Notes |
| --- | --- | --- |
| Starting state | yes (or via section default) | Must reference a State Catalog ID |
| Extra preconditions | optional | Only case-specific delta |
| Steps (numbered) | yes | Each step = one Action + its Expected bullets |
| Action | yes per step | Exact command or operation |
| Expected | yes per step | Tool-checkable observations only |
| Pass checklist | yes | Boolean items, including any end-state check not already in steps |
| Tracked requirements | yes | Requirement ID or `X` track ID |
| Cleanup | optional | Only when state change persists beyond Starting state |
| Release tag | yes | `(r1)` next to the heading |

### 4.4 Expected-observation vocabulary

To keep "Expected" uniformly checkable, the skill will list the allowed observation types. Anything outside these requires an explicit rewrite rationale:

- **Exit code** of a named command (`exit code = N`)
- **Stdout / stderr** equals / contains / matches regex
- **File exists / absent** at path
- **File field** equals / matches (for YAML/JSON files, path-addressed — e.g., `state.yaml -> projects.P1.status = "ready"`)
- **Log line** appears in named log file within time budget
- **Process** with name/pattern running / not running
- **Socket / port** listening / closed

This list is exhaustive. If a product capability cannot be expressed this way, the case is not tool-checkable and must be rewritten or removed.

### 4.5 Independence rule

Each case must begin from a State Catalog ID. Cases must not depend on the tail state of another case. Rationale:
- AI can run cases in any order or parallel.
- Failure of case N does not cascade into case N+1.
- Tokens for setup are paid once (in the State Catalog) regardless of case count.

If a test genuinely needs a sequence, express it as a single case with ordered steps, not as coupled neighboring cases.

## 5. File-Level Edits

### 5.1 `skills/acceptance-designer/SKILL.md`

- Rewrite `## Acceptance Content Rules` to require: State Catalog, per-step Action+Expected pairing, Pass checklist, Starting state per case, independence rule.
- Add new subsection `## Acceptance Item Structure` that inlines the strict template from §4.3.
- Extend `## Working Loop` step 2 to: "Write State Catalog first, then cases referencing states; never inline setup commands in a case."
- Keep all other rules (release tags, traceability, non-normal inclusion rule, upstream change handling, review gate, completion checklist).

### 5.2 `skills/acceptance-designer/references/output-artifacts.md`

- Add required body sections "State Catalog" and "Section Defaults (optional per section)".
- Replace the brief "Main-Flow Acceptance Stories" bullet list with the strict per-case template from §4.3, including the fields table and the expected-observation vocabulary.
- Keep frontmatter contract and review report contract unchanged.

### 5.3 `skills/acceptance-designer/references/boundary-examples.md`

- Add one edge-case row: "Case shares setup with many siblings → define once in State Catalog or Section Defaults; do not inline in each case."
- Otherwise unchanged.

### 5.4 No new files

Everything fits in the two existing references plus SKILL.md. No new support file added.

## 6. Before / After Example

Uses `§3.1.1` from the current platform5 acceptance doc.

### Before (current skill output)

```markdown
#### 3.1.1 服务启动、停止与统一 API 入口

- (r1) 验收动作：在 `~/.platform5/config.yaml` 中设置 Unix socket 地址 A，执行 `platform start` 启动服务；使用 CLI 和 TUI 分别连接平台；执行 `platform stop` 停止服务并确认连接中断；随后将监听地址改为 Unix socket 地址 B，重新启动服务后再次使用 CLI 和 TUI 访问
- (r1) 通过标准：服务能以常驻进程形式启动并保持运行；`platform stop` 能停止服务并释放当前监听地址；服务停止后 CLI / TUI 无法继续访问旧地址；监听地址以配置值为准且切换地址不需要改代码；CLI 与 TUI 在两个地址下都能访问同一平台能力
- 追踪需求：`r1-REQ-1.1` `r1-REQ-1.2.7` `r1-REQ-1.3`
```

Problems: P1 (action bundle of 4 operations), P2 ("能保持运行" not observable), P4 (no per-step pairing), P6 (no checklist).

### After (new skill output)

See §4.3. The rewrite splits into 4 numbered steps, each pairing an exact command with exit-code / file / regex observations, followed by a pass checklist.

Token impact: the per-case body grows ~40%, but adding a State Catalog (~20 lines, written once) removes ~3 lines of repeated setup text from every case in §3 and §4. Net token count for the platform5 document (~30 cases) is expected to decrease.

## 7. Migration Impact on Existing Documents

- `persona-agents-platform5/docs/acceptance/acceptance.md` is currently `active` (was frozen then reopened under CR-01). It will need to be revised under the new structure during the CR-01 continuation work. Not in scope for this skill change itself.
- No automatic migration. The skill change only governs future writes/reviews.
- Any document still using the old narrative shape should be treated as a review finding at the next review round.

## 8. Open Questions for Codex Review

1. **Granularity of State Catalog IDs**: S0 / S1 / S2 linear chain versus orthogonal dimensions (e.g., `platform=started, template=T1, project=none`). Linear is simpler; orthogonal composes better for large suites. Recommendation: start with linear named snapshots; allow orthogonal composition only when a suite actually needs it.

2. **Cleanup enforcement**: Should Cleanup be required or optional? Making it required guarantees independence but costs tokens on read-only cases. Recommendation: optional; omit when Starting state reflects a read-only observation.

3. **Time budgets**: "within 3s" in expected observations introduces a tunable. Should the skill fix a default (e.g., 5s) or require each case to declare? Recommendation: default 5s, override per step.

4. **Log-file assertions**: matching "no unexpected error entries" is itself narrative. Should the skill require a positive allowlist / explicit regex instead? Recommendation: yes — the pass checklist must name an exact regex or a specific absent-pattern.

5. **Non-CLI product commitments** (e.g., TUI rendering): the expected-observation vocabulary does not cover visual state. Should the skill accept a textual TUI-state dump as a first-class observation type, or force those commitments out of formal acceptance? Recommendation: accept textual TUI-state dumps if the product exposes one; otherwise treat as "not tool-checkable" and exclude per existing rule.

6. **Interaction with `delivery-qa` skill**: the new structure is closer to an executable test spec. Does that blur the boundary between acceptance design and test authoring? Recommendation: no — acceptance still declares *what* must be true; `test-engineer` still decides *how* to automate (shell, pytest harness, fixtures). But this warrants a boundary-examples row.

## 9. Completion Criteria

- `SKILL.md` Acceptance Content Rules require State Catalog, per-step Action+Expected, Pass checklist, Starting state, independence rule.
- `SKILL.md` contains an "Acceptance Item Structure" section with the strict template.
- `references/output-artifacts.md` specifies State Catalog, Section Defaults, per-case template, and observation vocabulary as required artifacts.
- `references/boundary-examples.md` has the "shared setup" edge-case row.
- Plan reviewed by codex; blockers resolved before implementation.
- After implementation, a spot re-write of one platform5 case using the new skill demonstrates clearer per-step verifiability.

## 10. Out of Scope

- Re-writing the platform5 acceptance document.
- Building any tooling to statically validate the new structure (future work; could live in `doc-guardian`).
- Changes to review report format.
