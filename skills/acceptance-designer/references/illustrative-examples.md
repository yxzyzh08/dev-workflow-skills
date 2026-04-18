# Illustrative Examples (Non-Normative)

**This file is non-normative.** The examples below use a hypothetical toy product `wfd` ("workflow daemon") invented only to illustrate the skill's grammar. The skill itself prescribes no commands, paths, or field names. Each project instantiates the placeholders in its own acceptance document.

Copying these examples wholesale will not produce a valid project acceptance document. Use them to understand the **shape** of each case tier, then bind the placeholders to your actual product.

## Toy Product `wfd`

Assumed CLI surface:

- Service: `wfd service start [--daemon]`, `wfd service stop`, `wfd service status`
- Templates: `wfd tmpl register <fixture-path>`, `wfd tmpl list`, `wfd tmpl show <name>`
- Projects: `wfd proj create <name> --tmpl <template>`, `wfd proj list`, `wfd proj switch <name>`
- Runs: `wfd run start "<description>"` (creates a run in the current project)
- Gates: `wfd gate freeze`, `wfd gate approve`, `wfd gate reject`
- TUI: `wfd display`

Assumed filesystem layout:

- Home: `~/.wfd/`
- PID file: `~/.wfd/wfd.pid`
- Socket: `~/.wfd/wfd.sock`
- State file: `~/.wfd/state.yaml`
- Project directory: `~/.wfd/proj/<proj>/`
- Run log: `~/.wfd/proj/<proj>/runs/<wr>/log.yaml`
- Run result files: `~/.wfd/proj/<proj>/runs/<wr>/results/<stage>.yaml` with field `outcome` ∈ `{pass, not_pass}`
- Project config: `~/.wfd/proj/<proj>/config.yaml`
- Daemon process: matches regex `/wfd-server/`
- Platform log: `~/.wfd/logs/wfd.log`

## State Catalog (Variant A — serial-only, singleton home)

### Suite-level rules

- Run-lock: flock on `<acceptance-parent>/.acceptance-run.lock` at case start; release at cleanup.
- Serialization: one case at a time.
- Shared state location: `~/.wfd/`.
- Fixture root: `<acceptance-parent>/fixtures/`.

### S0 — Clean

**Invariants:**
- file-absent `~/.wfd`
- process-absent matching /wfd-server/

**How to reach (always):**
- step (actor=ai): `wfd service stop` (no-op if not running)
  expected:
  - exit-code ∈ {0, 1}
- step (actor=ai): `pkill -f "wfd-server" || true`
  expected:
  - exit-code ∈ {0, 1}
- step (actor=ai): `rm -rf ~/.wfd`
  expected:
  - exit-code = 0
  - file-absent `~/.wfd`
  - process-absent matching /wfd-server/ within 5s

### S1 — Service started (extends S0)

**Invariants:**
- file-exists `~/.wfd/wfd.pid`
- file-exists `~/.wfd/state.yaml`
- socket-listening `~/.wfd/wfd.sock`
- exit-code = 0 from `wfd service status`

**How to reach:** from S0:
- step (actor=ai): `wfd service start --daemon`
  expected:
  - exit-code = 0
  - stdout contains "Service started in background."
- step (actor=ai, kind=wait): daemon becomes ready
  expected:
  - file-exists `~/.wfd/wfd.pid` within 5s
  - file-exists `~/.wfd/state.yaml` within 5s
  - socket-listening `~/.wfd/wfd.sock` within 5s
  - exit-code = 0 from `wfd service status` within 5s

### S2 — Template registered, project created (extends S1; parameters: {tpl}, {proj})

**Invariants:**
- stdout of `wfd tmpl list` contains `{tpl}`
- directory-exists `~/.wfd/proj/{proj}`
- file-field `~/.wfd/state.yaml -> projects.{proj}.status = "ready"`

**How to reach:** from S1:
- step (actor=ai): `wfd tmpl register <fixture-root>/{tpl}`
  expected:
  - exit-code = 0
  - stdout of `wfd tmpl list` contains `{tpl}` within 5s
- step (actor=ai): `wfd proj create {proj} --tmpl {tpl}`
  expected:
  - exit-code = 0
  - directory-exists `~/.wfd/proj/{proj}` within 5s
  - file-field `~/.wfd/state.yaml -> projects.{proj}.status = "ready"` within 5s

## Example 1 — Linear AI Case

```markdown
#### W.1.1 Service start / stop  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S0
**Cleanup:** reset to S0

**Flow:**
- step: `wfd service start --daemon`
  expected:
  - exit-code = 0
  - stdout contains "Service started in background."
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

**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else: `pass`

**Tracked requirements:** `r1-REQ-demo-1.1`
```

Notes:

- No `Declared branches`; rule 3 `partial-coverage` correctly omitted.
- No `set-outcome` in practice — rule 1 still present per the standard template (it stays reachable only if authored into the Flow).

## Example 2 — Branch + Loop AI Case (with Declared Branches)

```markdown
#### W.2.3 Closed-loop workflow on toy wfd  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S2 (parameters {tpl}=T1, {proj}=P1)
**Extra preconditions:** a run has been created via `wfd run start "toy closed-loop run"`; its id is bound as `{wr}` at case start.

**Placeholders:**
- `max_retries` = file-field ~/.wfd/proj/{proj}/config.yaml -> `workflow.max_retries`
- `default-executor` = "claude-code"
- `stage-list` = ["req", "design", "impl", "final"]

**Declared branches:**
- `B1`: at-least-once in for-each {stage}: file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}-review.loop_count` ≥ 1

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
        - file-field-delta ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.sessionId` unchanged since iteration-start within 60s
        - file-field-delta ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.loop_count` increased by at-least 1 since iteration-start within 60s
  - if `file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> nodes.{stage}-review.loop_count ≥ max_retries`:
    - set-outcome inconclusive-human-needed
  - else:
    - if `{stage} in ["req"]`:
      - step (actor=human): human runs "wfd gate freeze"
        expected:
        - exit-code = 0
        - file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.status` = "completed" within 5s
        - log-line in ~/.wfd/proj/{proj}/runs/{wr}/log.yaml matching /gate\.freeze.*by=human/ within 5s
    - else:
      - step (actor=human): human runs "wfd gate approve"
        expected:
        - exit-code = 0
        - file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.status` = "completed" within 5s
        - log-line in ~/.wfd/proj/{proj}/runs/{wr}/log.yaml matching /gate\.approve.*by=human/ within 5s

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) at-least-once in for-each {stage}: file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.executor` != file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}-review.executor`
- [ ] (aggregate) count-matching(file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `nodes.{stage}.executor` != default-executor) in for-each {stage} ≥ 2
- [ ] (aggregate) log-absent in ~/.wfd/logs/wfd.log matching /level=error/ during the case window
- [ ] end state: file-field ~/.wfd/proj/{proj}/runs/{wr}/log.yaml -> `status` = "completed"

**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else if any declared branch's exercised-condition did not hold: `partial-coverage`
4. Else: `pass`

**Tracked requirements:** `r1-REQ-demo-4.2` `r1-REQ-demo-4.6`
```

Behavior notes:

- When a `{stage}-review` loop reaches `max_retries`, the Flow fires `set-outcome inconclusive-human-needed` and short-circuits. Pass-checklist bullets like `end state: status = completed` never evaluate. Rule 1 fires → `inconclusive-human-needed`.
- If no loop hits `max_retries` and every stage completes, `set-outcome` never fires, the Pass-checklist evaluates, and the outcome is `pass` or `partial-coverage` depending on whether branch `B1` was exercised (any `loop-until` iterated at least once).

Construct audit against the grammar:

- `for-each {stage} in \`stage-list\`` — P4 with `<list-placeholder>`
- `step (actor=system, kind=wait)` with `within Ns` on every bullet — P1 normalized
- `step (actor=human)` with deterministic command instruction — P1
- `loop-until <compound-condition with or>` — P2 + Condition sub-grammar
- `file-field X -> k ≥ max_retries` — extended `file-field`; `max_retries` via Placeholders
- `file-field-delta ... unchanged since iteration-start within 60s` — `file-field-delta` mode; `iteration-start` = innermost iterator = the enclosing `loop-until` iteration
- `file-field-delta ... increased by at-least 1 since iteration-start within 60s` — same mode
- `{stage} in ["req"]` — variable-condition
- `set-outcome inconclusive-human-needed` — P5 (only legal form)
- Scope-2 aggregates `at-least-once` and `count-matching(...) ≥ 2` — §9 Pass-checklist
- Field-to-field comparison `file-field ... != file-field ...` — extended `file-field`
- Priority-ordered outcome rule with exclusive values — §10.2

## Example 3 — Human Case

```markdown
#### W.5.1 TUI render quality on wfd observer  (r1)

**default-actor:** human
**verifier:** human
**Why human?** Render smoothness and visual integrity are perceptual product commitments; the product exposes no stable textual surface that captures rendering artifacts.
**Starting state:** S2 (parameters {tpl}=T1, {proj}=P1)
**Estimated effort:** 10 minutes
**Observer qualification:** any engineer familiar with the wfd TUI.

**Setup for the observer:**
1. Open two wfd TUI instances side-by-side.
2. Start a run whose workflow will execute at least 3 nodes.

**What to observe (human-tier modes only):**
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
1. If any Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any Fail signal was observed: `fail`
3. Else: `pass`

**Recording:** notes at `<acceptance-parent>/human-runs/W-5-1-<YYYYMMDD>.md`; attach screenshot or recording for any fail or inconclusive signal.

**Tracked requirements:** `r1-REQ-demo-7.1.1`
```

Notes:

- No Flow, no Pass checklist — human cases use the signals format.
- No `Declared branches` and no rule 3; rule 3 omitted from the outcome rule.

## Example 4 — Hybrid Case

```markdown
#### W.4.5 Reject routing + CLI feedback quality  (r1)

**default-actor:** ai
**verifier:** hybrid
**Why human?** Routing outcome is structurally checkable; the reject-feedback message quality (does the CLI clearly convey what was rejected and where routing goes next) is a perceptual commitment.
**Starting state:** S2 (parameters {tpl}=T1, {proj}=P1)
**Extra preconditions:** a run has been created via `wfd run start "hybrid reject run"` against {proj}; its id is bound as `{wr}` at case start. The workflow has advanced far enough that a human-gate node named `<gate>` exists and can be reached.
**Cleanup:** reset to S0

**AI block (Flow):**
- step (actor=ai): advance workflow until node `<gate>` enters `paused_at_gate`
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
1. If `set-outcome inconclusive-human-needed` fired in the AI Flow OR any Human Inconclusive signal was observed: `inconclusive-human-needed`
2. Else if any AI-pass-checklist item failed OR any Human Fail signal was observed: `fail`
3. Else: `pass`

**Tracked requirements:** `r1-REQ-demo-1.2.4` `r1-REQ-demo-4.6` `r1-REQ-demo-4.7` `r1-REQ-demo-6.2`
```

Notes:

- `{wr}` is bound in `Extra preconditions`.
- The AI block uses `actor=ai` by default with one `actor=human` step for the gate command — `verifier` stays `hybrid` because the Human block's observations are judgment-based (`quality`, `visual`).
- No `Overall pass:` line; the single case-level outcome rule consumes both channels.
- No `Declared branches`, no rule 3.

## Anti-Patterns (do not copy)

- **Bundled actions:** "Execute start; use CLI and TUI to connect; execute stop; change address; restart." → split into one `step` per action with its own `expected`.
- **Narrative pass criteria:** "Service remains running as a daemon." → translate into AI-tier observations (`process-running matching /...`, `socket-listening ...`, `exit-code = 0 from 'status'`).
- **Hidden aggregates in a step:** expected bullet saying "across all stages, at least one used a different executor" → move to a Pass-checklist Scope-2 `at-least-once` aggregate.
- **Bare undeclared literal:** condition like `loop_count ≥ max_retries` without `max_retries` appearing in a Placeholders block → declare `max_retries` via Placeholders first.
- **`set-outcome pass` / `set-outcome fail`:** not allowed. Only `set-outcome inconclusive-human-needed` is legal.
- **`Overall pass:` line in hybrid cases:** remove; the case-level outcome rule already combines blocks.
- **`for-all-iterations` in a `Declared branches` exercised-condition:** not allowed — collapses the branch concept. Use `at-least-once` or `count-matching` instead.
- **Human case with `at-least-once in <scope>`** in its exercised-condition: not allowed (no Flow `<scope>`). Use a plain human-tier observation.
