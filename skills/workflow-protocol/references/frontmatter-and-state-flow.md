# Frontmatter And State Flow Reference

Use this file when a workflow skill needs the concrete metadata schema, legal state transitions, or code-artifact tracking rules.

## Placeholder Convention

The examples in this file use placeholder markers to show config-resolved values without hardcoding one repository layout as the universal truth.

- `<from paths.*>` means "resolve this path from the matching key in repository-root `workflow-project.yaml`"
- `<from sources.*>` means "resolve this fact source from the matching key in repository-root `workflow-project.yaml`"
- `logical` labels in examples exist so traceability and validation can point back to the config key, not only the resolved path

## Common Required Fields

These fields apply to all workflow documents unless explicitly exempted.

| Field | Type | Required | Legal Values / Notes |
| --- | --- | --- | --- |
| `title` | string | yes | Human-readable document title |
| `type` | enum | yes | `requirements`, `acceptance`, `architecture`, `design`, `plan`, `e2e-plan`, `e2e-result`, `bug-analysis`, `change-request`, `review` |
| `created` | datetime | yes | `YYYY-MM-DD HH:mm` |

## Content Document Extension Fields

Applies to `requirements`, `acceptance`, `architecture`, `design`, `plan`, `e2e-plan`, `e2e-result`, and `bug-analysis`.

| Field | Type | Required | Legal Values / Notes |
| --- | --- | --- | --- |
| `status` | enum | yes | `draft`, `active`, `frozen`, `stable`; `stable` is architecture-only — means current and authoritative but open to evolution |
| `last_modified` | datetime | yes | `YYYY-MM-DD HH:mm` |
| `author` | enum | yes | agent identifier or `human` (e.g., `agent-A`, `agent-B`, `human`) |
| `version` | string | only cumulative docs | Document revision number. Use for acceptance, architecture. Example: `"1.0"` |
| `release` | string | only release-scoped docs | Which release cycle this artifact belongs to. Example: `r1` |
| `upstream` | list[object] | recommended | Each item uses `logical` + `path` resolved from `workflow-project.yaml` |
| `downstream` | list[object] | recommended | Each item uses `logical` + `path` resolved from `workflow-project.yaml` |
| `change_history` | list[object] | yes | Each entry uses `date`, `author`, `description` |

## Progress Dashboard Schema (`paths.progress`)

The progress dashboard is a slim, current-state-only navigation document. It does not follow the content/review/change-request schema and must not be validated or classified as one of those document types. Historical entries belong in `paths.progress_history`, not here.

Expected frontmatter (lighter schema):

| Field | Type | Required | Notes |
| --- | --- | --- | --- |
| `title` | string | yes | Human-readable title |
| `current_stage` | string | yes | Current owning skill ID, e.g. `acceptance-designer` |
| `current_release` | string | yes | Must match `project.current_release` in config. Example: `r1` |
| `status` | string | yes | Example: `initializing`, `active`, `paused` |
| `last_updated` | datetime | yes | `YYYY-MM-DD HH:mm` |

Expected body structure — keep under 30 lines:

1. **Current Status** table: one row per stage (`not-started` / `active` / `frozen`), key artifact path
2. **Blockers / Pending Decisions** section: current blockers or empty
3. **Next Step** section: next action

## Progress History Schema (`paths.progress_history`)

Append-only log, newest entries first. Each entry is one line with timestamp, actor, and action. Skills append here whenever their work advances, confirms, or corrects the workflow state — not on every invocation, only on actual state changes. Skills never read this file during normal routing.

```markdown
## 2026-04-12

- 15:30 agent-A: revised acceptance doc per acc-review-02
- 14:00 agent-B: produced acc-review-02, not-pass
- 11:00 agent-B: produced acc-review-01, not-pass
```

### Content YAML Example

Logical mapping example (resolved via `workflow-project.yaml`):

- `product_prd` -> `<from sources.product_prd>`
- `acceptance` -> `<from paths.acceptance>`

> **Immutable reference rule:** The `<from paths.*>` placeholders below are for illustration only. In actual artifacts, `upstream`, `downstream`, and `target` fields must store the **resolved concrete path** at write time (the value obtained by resolving the logical key through `workflow-project.yaml`), not the placeholder. This ensures references remain valid across release switches.

```yaml
---
title: "Requirements Document"
type: requirements
created: 2026-04-11 09:00
status: frozen
last_modified: 2026-04-11 14:30
author: agent-A
release: r1
upstream:
  - logical: product_prd
    path: <from sources.product_prd>          # actual artifact writes resolved path
downstream:
  - logical: acceptance
    path: <from paths.acceptance>             # actual artifact writes resolved path
change_history:
  - date: 2026-04-11 09:00
    author: agent-A
    description: "Initial creation"
---
```

## Change Request Extension Fields

Applies to `type: change-request`.

| Field | Type | Required | Legal Values / Notes |
| --- | --- | --- | --- |
| `status` | enum | yes | `draft`, `active`, `closed` |
| `last_modified` | datetime | yes | `YYYY-MM-DD HH:mm` |
| `author` | enum | yes | agent identifier or `human` (e.g., `agent-A`, `agent-B`, `human`) |
| `targets` | list[path] | yes | Frozen baselines affected by the CR |
| `change_category` | enum | yes | `scope`, `acceptance`, `constraint`, `flow` |
| `decision` | enum | yes | `pending`, `approved`, `rejected` |
| `decided_by` | string | when decided | Human identity or `human` |
| `decided_at` | datetime | when decided | `YYYY-MM-DD HH:mm` |
| `minimum_return_steps` | list[string] | yes | Human-readable step ranges |
| `downstream_impact` | list[object] | yes | Each item uses `path` + `action` where action is `reopen-to-active` |
| `change_history` | list[object] | yes | Each entry uses `date`, `author`, `description` |

### Change Request YAML Example

Logical mapping example (resolved via `workflow-project.yaml`):

- `requirements` -> `<from paths.requirements>`
- `acceptance` -> `<from paths.acceptance>`

> **Immutable reference rule:** In actual CR artifacts, `targets` and `downstream_impact` paths must store resolved concrete paths at write time.

```yaml
---
title: "Change Request 01"
type: change-request
created: 2026-04-11 16:00
status: active
last_modified: 2026-04-11 16:00
author: agent-B
targets:
  - <from paths.requirements>               # actual artifact writes resolved path
change_category: scope
decision: pending
minimum_return_steps:
  - "Steps 1-3: requirement clarification and review"
downstream_impact:
  - path: <from paths.acceptance>            # actual artifact writes resolved path
    action: reopen-to-active
change_history:
  - date: 2026-04-11 16:00
    author: agent-B
    description: "Create CR"
---
```

## Review Document Extension Fields

Applies to `type: review`.

| Field | Type | Required | Legal Values / Notes |
| --- | --- | --- | --- |
| `target` | string | yes | Reviewed path or scope summary |
| `reviewer` | enum | yes | agent identifier or `human` (e.g., `agent-A`, `agent-B`, `human`); must differ from `author` unless human waives |
| `release` | string | only release-scoped reviews | Example: `r1` |

### Review YAML Example
Logical mapping example (resolved via `workflow-project.yaml`):

- `requirements` -> `<from paths.requirements>`

> **Immutable reference rule:** In actual review artifacts, the `target` field must store the resolved concrete path at write time.

```yaml
---
title: "Review Report: Requirements Document"
type: review
created: 2026-04-11 10:00
target: "<from paths.requirements>"            # actual artifact writes resolved path
reviewer: agent-B
release: r1
---
```

## Reviewer Separation Rule

- If the reviewed target exposes an `author`, default to `reviewer != author`.
- Only the human may waive reviewer separation, and the waiver should be stated explicitly in the review context or report.

## Legal State Flow

- `draft -> active`
- `active -> frozen`
- `active -> stable` (architecture only — baseline is current and authoritative but open to evolution through review or approved change flow)
- `frozen -> active` only after human-approved CR

## Frozen Update Rule

- small adjustment: update in place + append `change_history`
- large adjustment: CR first, then reopen the upstream loop
- requirements special case: adding a third-level item under a frozen second-level item is still a small adjustment only when it stays inside the current capability boundary and does not expand acceptance responsibility

## Code Artifact Tracking Rules

Code artifacts do not use frontmatter. Use this table instead.

| Dimension | Document Artifact | Code Artifact |
| --- | --- | --- |
| version control | `version` / `change_history` | git commit / branch |
| state judgment | frontmatter `status` | lint + type check + tests pass |
| traceability | `upstream` / `downstream` | `plan.md` task ID -> code file or directory |
| compliance check | `doc-guardian` checks frontmatter | `completion-verifier` runs commands |
| review record | review report cites document path | two-stage: `spec-review-{nn}.md` (spec compliance, stage 1) then `code-review-{nn}.md` (code quality, stage 2); spec compliance must pass before code quality review |

## Code Artifact Constraints

- `plan.md` must map each task to its code output location.
- Code review reports must cite modules, directories, or files explicitly.
- Verification claims for code must cite command output, not only narrative assertion.
