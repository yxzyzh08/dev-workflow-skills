# Variant C: Fixture-Based / Artifact-Only Acceptance

> Companion reference for `acceptance-designer`. Read alongside:
> - `output-artifacts.md` — full grammar and observation vocabulary
> - `boundary-examples.md` — scope decisions vs other skills
> - `illustrative-examples.md` — worked examples for runtime products
>
> This file covers projects whose deliverable is a **static artifact** (skill, document, article, configuration template, or other text-based product) rather than a runtime service or daemon.

## 1. When to Use Variant C

Pick Variant C only when **all** of the following hold:

1. **The deliverable is one or more files**, not a process. There is nothing to start, listen on a port, or report a PID.
2. **Acceptance reduces to "the produced files have certain structural properties"**, not "the running system behaves a certain way."
3. **The producer is invocable from a reproducible harness** (see §3.1) — typically an LLM-driven agent, templating engine, or script.

If any of the following apply, prefer Variant A or B instead:

- The product runs as a service, daemon, or long-lived process → Variant A (singleton state) or Variant B (workspace-parameterized).
- Acceptance involves observing process state, sockets, or runtime logs → Variant A/B.
- The deliverable is a CLI tool whose acceptance is measured by runtime side effects on shared state → Variant A/B.

### 1.1 Decision tree

```
Is the deliverable a runnable process or service?
├── Yes → Variant A (default) or Variant B (per-workspace isolation)
└── No, the deliverable is one or more static files
    ├── Files are produced by a deterministic templating engine?
    │   └── Variant C with low LLM-non-determinism tolerance
    │       (mostly exact file-field assertions; §6 mostly unused)
    └── Files are produced by an LLM-driven agent?
        └── Variant C with full LLM-non-determinism recipes (§6)
```

### 1.2 Examples that fit Variant C

- A workflow skill (`SKILL.md` + `references/` + `scripts/`) — the deliverable is the skill file set
- A documentation generator that produces markdown / HTML files
- A config-as-code generator
- An article-writing assistant whose output is markdown / text

### 1.3 Examples that do NOT fit Variant C

- A web service exposing an API → Variant A
- A CLI that reads input and modifies a database → Variant A
- A database migration tool → Variant A (its effect is on a running database)
- A skill whose acceptance also includes "is this skill discovered/selected by the agent under context X?" → discovery validation is out of scope for Variant C; static visibility (skill loaded into available-skills) is in scope via §4.3 helper-script pattern.

## 2. State Catalog Template

### 2.1 Variant declaration

The `## 3. State Catalog` heading must declare:

```markdown
## 3. State Catalog (Variant C: fixture-based / artifact-only)
```

Mixing variants in a single document is not permitted.

### 2.2 Required suite-level rules block

```markdown
### 3.0 Suite-level rules
- Workspace isolation: per-case `<output-dir>/<case-id>/` (recommended) or shared `<output-dir>/` (requires run-lock).
- Fixture root: `<fixture-root>` (read-only; cleanup never resets fixtures).
- Output cleanup: remove `<output-dir>/<case-id>/` at case start and at cleanup.
- Run-lock: not required by default; required only when cases share `<output-dir>`.
- Harness invocation: `<harness-cmd>` (specifics in §2.1 Acceptance Preparation).
```

### 2.3 State schema

```markdown
### S<n> — <short semantic name>

**Invariants:**
- <AI-tier file-state observation>
- <AI-tier file-state observation>

**How to reach:** [from S<m>:]
- step (actor=ai): <fs-only command>
  expected:
  - <observation>
```

Rules:

- **Invariants use only file-state modes**: `file-exists`, `file-absent`, `directory-exists`, `directory-absent`, `file-field`, `file-field-delta`. Runtime modes (`process-running`, `socket-listening`, `log-line`) must not appear in Variant C states.
- **How to reach** uses only file-system commands (`rm`, `cp`, `ln`, `mkdir`, `chmod`). No service start/stop.
- **S0 ≡ empty workspace** (`<output-dir>/<case-id>` absent; fixture loading is a separate state).
- **Each fixture set gets its own S<n>**. Number of states tracks the number of distinct input scenarios.

### 2.4 State invariant granularity

Recommended granularity:

| Component | Recommended invariant | Rationale |
| --- | --- | --- |
| Fixture entry directory | `directory-exists <fixture-root>/<scenario>` | Confirms the fixture set is present |
| Each top-level input file | `file-exists <fixture-root>/<scenario>/<file>` | Confirms inputs are accessible |
| Output workspace | `directory-absent <output-dir>/<case-id>` | Confirms no leftover artifacts |

Avoid `file-field` checks on fixture content as state invariants — fixture content is owned by the fixture, not the state. Move content checks to case-level Pass-checklist bullets.

### 2.5 Example State Catalog

```markdown
## 3. State Catalog (Variant C: fixture-based / artifact-only)

### 3.0 Suite-level rules
- Workspace isolation: per-case `output/<case-id>/`
- Fixture root: `fixtures/` (read-only)
- Output cleanup: `rm -rf output/<case-id>/` at case start and cleanup
- Run-lock: not required
- Harness invocation: `./scripts/run-skill.sh acceptance-designer <fixture-root>/<scenario> output/<case-id>`

### S0 — empty workspace
**Invariants:**
- `directory-absent output/<case-id>`

**How to reach:**
- step (actor=ai): `rm -rf output/<case-id>`
  expected:
  - `directory-absent output/<case-id>`

### S1 — fixture "toy-counter" available + empty output
**Invariants:**
- `directory-exists fixtures/toy-counter`
- `file-exists fixtures/toy-counter/sample-frozen-requirements.md`
- `directory-absent output/<case-id>`

**How to reach:** [from S0:]
- step (actor=ai): `rm -rf output/<case-id>`
  expected:
  - `file-exists fixtures/toy-counter/sample-frozen-requirements.md`
  - `directory-absent output/<case-id>`
```

## 3. Acceptance Preparation Bindings

`output-artifacts.md` §1.2 #2 Acceptance Preparation under Variant C must bind three groups.

### 3.1 Harness binding

```markdown
### 2.1 Harness binding
- Skill under test: `<skill-name>`
- Invocation harness: `<harness-cmd>`
  - Inputs: fixture set name + workspace paths
  - Outputs: produced markdown file(s) under `<output-dir>/<case-id>/`
  - Determinism contract: harness is reproducibly invocable; same fixture produces *structurally isomorphic* output (wording variation handled per §6).
- Example harness forms (pick one per project):
  - **CLI**: `claude-code --skill <skill-name> --input <fixture-root>/<scenario>/ --output <output-dir>/<case-id>/` (where supported)
  - **Custom runner**: `./scripts/run-skill.sh <skill-name> <fixture-root>/<scenario> <output-dir>/<case-id>`
  - **API**: Anthropic Agents SDK invoking the skill harness directly, output redirected to `<output-dir>/<case-id>/`
```

The harness is the only mechanism by which AI-tier cases trigger skill invocations. Without a stable harness, AI cases cannot run.

### 3.2 Fixture root binding

```markdown
### 2.2 Fixture root binding
- Fixture root: `<fixture-root>`
- Subdirectory convention: `<fixture-root>/<scenario-name>/<input-files>`
- **Read-only constraint**: cases must not modify fixtures. Recommended enforcement: `chmod -w` on fixture files, or a read-only mount.
```

### 3.3 Output workspace binding

```markdown
### 2.3 Output workspace binding
- Output root: `<output-dir>`
- Per-case isolation: `<output-dir>/<case-id>/` (recommended; matches §3.0 Workspace isolation)
- Cleanup semantics: delete `<output-dir>/<case-id>/`; `<fixture-root>` is never touched
```

## 4. AI-Tier Observation Patterns for Static Artifacts

### 4.1 Applicability matrix

| Mode | Applicable in Variant C? | Use case |
| --- | --- | --- |
| `exit-code` | yes | Helper scripts asserting structural properties of produced markdown |
| `stdout` / `stderr` | yes | Helper script output for inspection |
| `file-exists` / `file-absent` | yes | Output file presence/absence |
| `directory-exists` / `directory-absent` | yes | Output workspace state |
| `file-field` | yes (with caveat — see §4.2) | Frontmatter / YAML / JSON field assertions |
| `file-field-delta` | yes (rarely needed for one-shot generation) | Tracking field changes across steps |
| `log-line` / `log-absent` | context-dependent | Only if the harness emits logs |
| `process-running` / `process-absent` | NOT applicable | No processes in Variant C |
| `socket-listening` / `socket-closed` | NOT applicable | No sockets in Variant C |

### 4.2 `file-field` semantics for markdown outputs

`file-field <path> -> <dotted-key>` works directly on YAML frontmatter:

```
file-field <output> -> frontmatter.type = "acceptance"
file-field <output> -> frontmatter.status ∈ {draft, active, frozen}
```

For markdown **body** content (non-frontmatter), `file-field` does not have native semantics. Use the **helper-script + exit-code** pattern in §4.3.

### 4.3 Helper-script pattern for markdown body assertions

To assert "produced document contains a `## 3. State Catalog` section":

```
expected:
- exit-code = 0  (./scripts/markdown-section-exists.sh "<output>" "3. State Catalog")
```

Recommended helper scripts (each project may add its own):

| Script | Purpose | Output |
| --- | --- | --- |
| `markdown-section-exists.sh` | Check whether a `## <heading>` exists | exit 0 if found, 1 otherwise |
| `markdown-section-extract.sh` | Extract a section's content for further checks | section text on stdout |
| `markdown-trace-extractor.py` | Pull all `Tracked requirements: ...` lines into a list | JSON list on stdout |
| `markdown-headings-to-json.py` | Dump all headings into a hierarchical JSON | JSON on stdout, then queryable via `file-field` |

Existing scripts under `skills/skill-writer/scripts/` can be reused as `exit-code` observations:

| Script | Use as |
| --- | --- |
| `check-skill-structure.sh` | Verify a produced skill output has correct directory structure |
| `check-hardcoded-paths.sh` | Verify a produced skill output doesn't hardcode project paths |
| `check-skill-discovery.py` | Verify a produced skill is loaded into the agent's available-skills (static visibility) |
| `check-language-policy.sh` | Verify a produced skill follows the language policy |

### 4.4 Multi-file output observation

When the harness produces multiple output files:

```
expected:
- file-exists <output-dir>/<case-id>/SKILL.md
- file-exists <output-dir>/<case-id>/references/usage.md
- exit-code = 0  (./scripts/check-skill-structure.sh <output-dir>/<case-id>)
```

## 5. Pass Checklist Recipes

### 5.1 Recommended structural property forms

Use these forms:

```
- [ ] file-field <output> -> frontmatter.type = "acceptance"
- [ ] file-exists <output-dir>/<case-id>/acceptance.md
- [ ] (aggregate) count-matching(file-field <output> -> body matches /#### \w+/) in scope ≥ 3
- [ ] end state: S0
```

Do not use these forms:

```
- [ ] produced file equals fixture/expected.md verbatim    # LLM output varies
- [ ] line 12 of produced file is "S1: ..."                # fragile to formatting
- [ ] cases appear in the same order as input requirements # LLM ordering may shuffle
```

### 5.2 "Every input X is traced" pattern

To assert that every input requirement (or every member of a known set) is referenced in the output:

```markdown
**Flow:**
- for-each {req} in [R1, R2, R3]:
  - step: probe doc for {req} in Tracked requirements
    expected:
    - exit-code = 0  (grep -q "Tracked requirements:.*{req}" <output>)

**Pass checklist:**
- [ ] every expected bullet in the Flow held    # Scope 1 — every {req} matched
```

This uses Scope 1 ("every expected held") to assert universal quantification across the iteration. Do not use Scope 2 `at-least-once` for this — that asserts existence (some iteration matched), not universality.

### 5.3 "M of N" soft-assertion pattern

For tolerance when "any M of these N keywords should appear":

```markdown
**Flow:**
- for-each {kw} in [k1, k2, k3, k4, k5]:
  - step: <no-op probe>
    expected:
    - file-exists <output>

**Pass checklist:**
- [ ] (aggregate) count-matching(file-field <output> -> body matches /{kw}/i) in {kw} ≥ M
```

The Flow's per-step expected is intentionally trivial; the discriminator is the Scope 2 `count-matching` aggregate.

### 5.4 Frontmatter-first checklist pattern

When asserting many frontmatter fields, prefer frontmatter assertions over body assertions — they are mechanically clean:

```markdown
**Pass checklist:**
- [ ] file-field <output> -> frontmatter.type = "acceptance"
- [ ] file-field <output> -> frontmatter.status ∈ {draft, active, frozen}
- [ ] file-field <output> -> frontmatter.version matches /^\d+\.\d+$/
- [ ] file-field <output> -> frontmatter.upstream != null
```

## 6. LLM Non-Determinism Recipes

When the producer is an LLM-driven agent, output wording varies across runs. Authoring patterns must accommodate this.

### 6.1 Wording variation

Use case-insensitive regex with stems:

```
file-field <output> -> body matches /state catalog/i
file-field <output> -> body matches /tracked requirements?/i
```

### 6.2 "M of N" soft assertions

See §5.3.

### 6.3 Enumerated valid values

```
file-field <output> -> frontmatter.status ∈ {draft, active, frozen}
file-field <output> -> body matches /Variant [ABC]/
```

### 6.4 Anti-patterns (forbidden)

| Anti-pattern | Why forbidden | Use instead |
| --- | --- | --- |
| Exact text equality on body content | LLM rephrases freely | Regex / contains |
| Line-number-based assertions | LLM may reformat | Helper script / structural |
| Order-sensitive assertions across cases | LLM may reorder | Set membership / count-matching |
| Asserting exact whitespace / punctuation | Trivial variation | Match with `\s+` / pre-normalize |

## 7. Section Defaults (Recommended)

Variant C inherits the §3 Section Defaults mechanism unchanged. Recommended defaults for a Variant C section:

```markdown
**Section defaults:**
- **Starting state:** S<n> (per-section choice)
- **Cleanup:** rm -rf <output-dir>/<case-id>
- **Verifier:** ai
- **default-actor:** ai
```

These are non-normative — projects may override per case.

## 8. Dogfood Case: `acceptance-designer` Itself

A reference dogfood case lives in `docs/variant-c-skill-acceptance/fixtures/`:

- **Input fixture**: `sample-frozen-requirements.md` — frozen requirements for a "Toy Counter Service".
- **Expected output properties**: `expected-output-properties.md` — structural properties the produced acceptance document must satisfy.

### 8.1 Why the dogfood is recursive

We use Variant C to validate `acceptance-designer`. The fixture (Toy Counter) is a runtime product, so the produced acceptance document should be **Variant A**, not Variant C. This makes the test recursive: Variant C is verifying that the producer correctly chooses Variant A for runtime products.

If `acceptance-designer` regresses and incorrectly chose Variant C for a runtime product, the dogfood case would fail, catching the behavior change.

### 8.2 Walkthrough sketch

```markdown
#### dogfood-001 acceptance-designer produces Variant A acceptance for Toy Counter  (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S1 (fixture "toy-counter" loaded)
**Cleanup:** rm -rf output/dogfood-001

**Flow:**
- step (actor=ai): claude-code --skill acceptance-designer --input fixtures/toy-counter/ --output output/variant-c-meta/dogfood-001/
  expected:
  - file-exists output/variant-c-meta/dogfood-001/acceptance.md within 120s

- step: assert frontmatter
  expected:
  - file-field output/variant-c-meta/dogfood-001/acceptance.md -> frontmatter.type = "acceptance"
  - file-field output/variant-c-meta/dogfood-001/acceptance.md -> frontmatter.status ∈ {draft, active, frozen}

- step: assert State Catalog declares Variant A
  expected:
  - exit-code = 0  (./scripts/markdown-section-exists.sh output/variant-c-meta/dogfood-001/acceptance.md "3. State Catalog")
  - exit-code = 0  (grep -q "Variant A" output/variant-c-meta/dogfood-001/acceptance.md)

- for-each {req} in [R1, R2, R3]:
  - step: assert {req} is traced
    expected:
    - exit-code = 0  (grep -q "Tracked requirements:.*{req}" output/variant-c-meta/dogfood-001/acceptance.md)

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] (aggregate) count-matching of `^#### ` headings in main-flow section ≥ 3   # informal pseudo-syntax for brevity in this sketch; canonical form per §9 Scope 2 is `count-matching(<observation>) in <scope> <op> N` and lives in the meta-acceptance document
- [ ] end state: S0

**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else: `pass`

**Tracked requirements:** R8 (harness binding), R5 (Pass checklist style), R3 (AI-tier modes)
```

This is a sketch; the canonical full case lives in the meta-acceptance document at `docs/variant-c-skill-acceptance/`.

## 9. Quick Reference Card

| Question | Answer |
| --- | --- |
| Variant declaration heading | `## 3. State Catalog (Variant C: fixture-based / artifact-only)` |
| State invariants use | `file-exists`, `file-absent`, `directory-exists`, `directory-absent`, `file-field`, `file-field-delta` |
| State invariants do NOT use | `process-running`, `socket-listening`, `log-line` |
| How to assert markdown body content | Helper script + `exit-code` (§4.3) |
| How to assert frontmatter | `file-field <doc> -> frontmatter.<key>` (§4.2) |
| "Every input X traced" pattern | `for-each` + Scope 1 (§5.2) |
| "M of N" soft pattern | `count-matching` (§5.3) |
| Wording variation | `matches /regex/i` (§6.1) |
| Cleanup default | `rm -rf <output-dir>/<case-id>` |
| Fixture mutability | Read-only (§3.2) |
| Run-lock | Optional; required only with shared output-dir |
| Discovery (behavioral) | Out of scope; static visibility via §4.3 helper scripts |
