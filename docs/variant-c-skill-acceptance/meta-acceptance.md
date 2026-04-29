---
title: Variant C Meta-Acceptance for acceptance-designer
type: acceptance
status: active
version: "0.1"
created: 2026-04-29 09:00
last_modified: 2026-04-29 11:00
author: human
upstream: docs/variant-c-skill-acceptance/requirements.md
downstream: (none — closing artifact for Variant C v1)
change_history:
  - { date: 2026-04-29, author: human, description: initial draft (paper-complete dogfood case) }
---

# Variant C Meta-Acceptance: `acceptance-designer`

> Dogfood acceptance document. Validates `acceptance-designer` itself using Variant C against a sample frozen-requirements fixture (Toy Counter Service).
>
> **Scope of this version (v0.1, paper-complete)**:
> - Document is fully written and conforms to Variant C grammar (per `references/variant-c-skill-projects.md`).
> - Helper scripts referenced in §4 case Flows are **named and specified but not implemented** (see §2.4). Implementing them is follow-up work.
> - Harness invocation is bound to one candidate form (Claude Code CLI), marked **"untested"**: the case has not been actually run against a live skill invocation.
> - Use this document to: (a) prove Variant C grammar can express a real acceptance case end-to-end, (b) anchor follow-up implementation tasks.

## 1. Document Instructions

- This is a Variant C acceptance baseline. Refer to `skills/acceptance-designer/references/variant-c-skill-projects.md` for variant-specific rules and `skills/acceptance-designer/references/output-artifacts.md` for the full grammar.
- Every case below uses `verifier: ai`. No human or hybrid cases in v1.
- All cases trace back to requirement IDs in `docs/variant-c-skill-acceptance/requirements.md` (R1-R9).
- Anti-patterns (per R5): no exact text equality, no line-number assertions, no order-sensitive assertions across cases.
- Helper scripts referenced below are pending implementation; see §2.4 for the inventory.
- Default coverage is main flow + variant-selection regression check. No independent formal acceptance items in v1.

## 2. Acceptance Preparation

### 2.1 Harness binding

- **Skill under test**: `acceptance-designer` (located at `skills/acceptance-designer/`)
- **Invocation harness**: `claude-code --skill acceptance-designer --input <fixture-root>/<scenario>/ --output <output-dir>/<case-id>/`
  - Inputs: a frozen-requirements file under `<fixture-root>/<scenario>/`
  - Outputs: an `acceptance.md` file under `<output-dir>/<case-id>/`
  - Determinism contract: same fixture should produce structurally isomorphic output (per R5 + LLM non-determinism recipes in references §6).
- **Status: UNTESTED** — paper-complete only. Whether `claude-code` supports this exact invocation form (skill selection + I/O redirection) is unverified. If incompatible at run time, switch to a custom runner or API form per references §3.1.

### 2.2 Fixture root binding

- **Fixture root**: `docs/variant-c-skill-acceptance/fixtures/`
- **Scenario subdirectory convention**: `<fixture-root>/<scenario-name>/<input-files>`
- **v0.1 simplification**: fixture is **not yet under a scenario subdirectory** — `sample-frozen-requirements.md` lives directly under `fixtures/`. Follow-up: move to `fixtures/toy-counter/sample-frozen-requirements.md` to match the convention. Until then, treat the whole `fixtures/` directory as the single scenario.
- **Read-only constraint**: cases must not modify fixtures. (No filesystem-level enforcement in v0.1; relies on convention.)

### 2.3 Output workspace binding

- **Output root**: `output/variant-c-meta/`
- **Per-case isolation**: `output/variant-c-meta/<case-id>/`
- **Cleanup**: `rm -rf output/variant-c-meta/<case-id>/` at case start and at cleanup. Fixture root never touched.

### 2.4 Pending implementation work (helper scripts)

Referenced in §4 case Flows; not yet implemented. Each is named, scoped, and should land before this meta-acceptance can actually run.

| Script | Location (proposed) | Purpose | Args | Output / exit |
| --- | --- | --- | --- | --- |
| `markdown-section-exists.sh` | `docs/variant-c-skill-acceptance/scripts/` | Check `## <heading>` exists in a markdown file | `<file> <heading>` | exit 0 if found, 1 otherwise |
| `markdown-trace-extractor.py` | same | Extract all `Tracked requirements: ...` values into a JSON list | `<file>` | JSON list on stdout |
| `markdown-headings-to-json.py` | same | Dump headings to hierarchical JSON | `<file>` | JSON on stdout |
| `per-case-fields-check.py` | same | Verify each `#### <case-id>` block has all §5.1 required fields | `<file>` | exit 0 if all pass, 1 + offending case-ids on stderr |
| `r5-antipattern-check.sh` | same | Detect line-number / exact-text / order-sensitive assertion patterns | `<file>` | exit 0 if clean, 1 + locations on stderr |

When these land, replace the Flow steps' "(pending: <script>)" markers with the actual invocation.

## 3. State Catalog (Variant C: fixture-based / artifact-only)

### 3.0 Suite-level rules

- **Workspace isolation**: per-case `output/variant-c-meta/<case-id>/`
- **Fixture root**: `docs/variant-c-skill-acceptance/fixtures/` (read-only by convention)
- **Output cleanup**: `rm -rf output/variant-c-meta/<case-id>/` at case start and cleanup
- **Run-lock**: not required (per-case workspace isolation)
- **Harness invocation**: see §2.1

### S0 — empty workspace

**Invariants:**
- `directory-absent output/variant-c-meta/<case-id>`

**How to reach:**
- step (actor=ai): `rm -rf output/variant-c-meta/<case-id>`
  expected:
  - `directory-absent output/variant-c-meta/<case-id>`

### S1 — fixture available + empty output

**Invariants:**
- `file-exists docs/variant-c-skill-acceptance/fixtures/sample-frozen-requirements.md`
- `directory-absent output/variant-c-meta/<case-id>`

**How to reach:** [from S0:]
- step (actor=ai): `rm -rf output/variant-c-meta/<case-id>` (fixture is pre-staged and read-only by convention)
  expected:
  - `file-exists docs/variant-c-skill-acceptance/fixtures/sample-frozen-requirements.md`
  - `directory-absent output/variant-c-meta/<case-id>`

## 4. Main-Flow Acceptance Stories

### Section defaults

- **Starting state:** S1
- **Cleanup:** `rm -rf output/variant-c-meta/<case-id>`
- **Verifier:** ai
- **default-actor:** ai

#### meta-001 acceptance-designer selects Variant A for runtime product (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S1
**Extra preconditions:** harness §2.1 reachable
**Cleanup:** `rm -rf output/variant-c-meta/meta-001`

**Flow:**
- step (actor=ai): `claude-code --skill acceptance-designer --input docs/variant-c-skill-acceptance/fixtures/ --output output/variant-c-meta/meta-001/`
  expected:
  - exit-code = 0 within 180s

- step (actor=ai): assert produced file exists with correct frontmatter
  expected:
  - file-exists output/variant-c-meta/meta-001/acceptance.md
  - file-field output/variant-c-meta/meta-001/acceptance.md -> frontmatter.type = "acceptance"
  - file-field output/variant-c-meta/meta-001/acceptance.md -> frontmatter.status ∈ {draft, active, frozen}

- step (actor=ai): assert State Catalog declares Variant A specifically (not B or C)
  expected:
  - exit-code = 0  (pending: `./docs/variant-c-skill-acceptance/scripts/markdown-section-exists.sh output/variant-c-meta/meta-001/acceptance.md "3. State Catalog"`)
  - exit-code = 0  (`grep -q "Variant A" output/variant-c-meta/meta-001/acceptance.md`)
  - exit-code = 1  (`grep -q "Variant C" output/variant-c-meta/meta-001/acceptance.md`)   # negative — must NOT pick Variant C for runtime product

**Pass checklist:**
- [ ] every expected bullet in the Flow held
- [ ] end state: produced doc has Variant A declaration

**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else: `pass`

**Tracked requirements:** R3 (AI-tier `file-field` for frontmatter; `exit-code` for body via grep / helper), R8 (harness binding), R7 (variant-selection logic preserved for runtime products)

---

#### meta-002 acceptance-designer traces every input requirement (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S1
**Cleanup:** `rm -rf output/variant-c-meta/meta-002`

**Flow:**
- step (actor=ai): `claude-code --skill acceptance-designer --input docs/variant-c-skill-acceptance/fixtures/ --output output/variant-c-meta/meta-002/`
  expected:
  - exit-code = 0 within 180s
  - file-exists output/variant-c-meta/meta-002/acceptance.md

- for-each {req} in [R1, R2, R3]:
  - step (actor=ai): probe produced doc for {req} in any Tracked requirements field
    expected:
    - exit-code = 0  (`grep -q "Tracked requirements:.*{req}" output/variant-c-meta/meta-002/acceptance.md`)

**Pass checklist:**
- [ ] every expected bullet in the Flow held    # Scope 1 — every {req} matched (the "every input traced" pattern from references §5.2)

**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else: `pass`

**Tracked requirements:** R5 (structural assertion via for-each + Scope 1), R7 (traceability rule §1.4 unchanged)

---

#### meta-003 acceptance-designer output respects R5 anti-patterns (r1)

**default-actor:** ai
**verifier:** ai
**Starting state:** S1
**Cleanup:** `rm -rf output/variant-c-meta/meta-003`

**Flow:**
- step (actor=ai): `claude-code --skill acceptance-designer --input docs/variant-c-skill-acceptance/fixtures/ --output output/variant-c-meta/meta-003/`
  expected:
  - exit-code = 0 within 180s
  - file-exists output/variant-c-meta/meta-003/acceptance.md

- step (actor=ai): scan produced doc for forbidden anti-patterns (line-number / exact-text / order-sensitive)
  expected:
  - exit-code = 0  (pending: `./docs/variant-c-skill-acceptance/scripts/r5-antipattern-check.sh output/variant-c-meta/meta-003/acceptance.md`)

**Pass checklist:**
- [ ] every expected bullet in the Flow held

**Outcome rule (priority order, first match wins):**
1. If `set-outcome inconclusive-human-needed` fired during the Flow: `inconclusive-human-needed`
2. Else if any Pass-checklist item failed: `fail`
3. Else: `pass`

**Tracked requirements:** R5 (anti-patterns enforced)

## 5. Next-Phase Constraints

- **Helper scripts must be implemented** (§2.4) before this acceptance can actually run.
- **Harness binding (§2.1) must be verified** — `claude-code` CLI form may not exist as specified. If incompatible, switch to a custom runner or API per references §3.1.
- **Fixture restructuring**: move `sample-frozen-requirements.md` into a `toy-counter/` subdirectory to match the §3.1 convention.
- **Behavioral discovery validation** is explicitly out of scope (per requirements.md "不在范围"). Static visibility (skill loaded into agent system prompt) is in scope via `check-skill-discovery.py` if added as a helper.

## Appendix A: Why this dogfood is recursive

We use Variant C to validate `acceptance-designer`. The fixture (Toy Counter Service) is a runtime product, so the produced acceptance document should be **Variant A**, not Variant C. The dogfood thus also verifies that `acceptance-designer` correctly chooses Variant A for runtime products — i.e., that adding Variant C did not regress the variant-selection logic. meta-001's negative assertion (`grep -q "Variant C" ... should fail`) catches this regression directly.

## Appendix B: Summary of remaining work

- [ ] Implement 5 helper scripts (§2.4)
- [ ] Verify or replace harness binding (§2.1)
- [ ] Restructure fixtures into per-scenario subdirectories (§2.2)
- [ ] First end-to-end run; capture failures and refine cases as needed
- [ ] Optionally promote helper scripts and meta-acceptance into `skills/acceptance-designer/` test infrastructure
