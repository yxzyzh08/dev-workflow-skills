# Review Report Reference

Use this file when a workflow skill needs to create or validate a review-style artifact.

## Required Frontmatter

| Field | Required | Notes |
| --- | --- | --- |
| `title` | yes | Human-readable review title |
| `type: review` | yes | Fixed document type |
| `created` | yes | `YYYY-MM-DD HH:mm` |
| `target` | yes | Reviewed path or reviewed scope |
| `reviewer` | yes | Reviewing agent or human |
| `release` | only for release-scoped reviews | Example: `r1` |

### YAML Example

Logical mapping example (resolved via `workflow-project.yaml`):

- `requirements` -> `<from paths.requirements>`

> **Immutable reference rule:** In actual review artifacts, the `target` field must store the resolved concrete path at write time (e.g., the path resolved from `paths.requirements`), not the `<from paths.*>` placeholder. This ensures references remain valid across release switches.

```yaml
---
title: "Review Report: Requirements Document"
type: review
created: 2026-04-11 10:00
target: "<from paths.requirements>"            # actual artifact writes resolved path
reviewer: <agent-A>
release: r1
---
```

### Release-Scoped Review Example

Use `release` when the reviewed artifact belongs to a release-scoped document set.

```yaml
---
title: "Review Report: Detailed Design"
type: review
created: 2026-04-11 10:00
target: "<from paths.releases_dir>/r1/design/detail.md"
reviewer: <agent-B>
release: r1
---
```

### Implementation Spec Compliance Review Example

Use for the spec compliance stage of the two-stage implementation review.

```yaml
---
title: "Spec Compliance Review: Task T1"
type: review
created: 2026-04-12 14:00
target: "src/modules/auth/ (Task T1 implementation scope)"
reviewer: <agent-C>
release: r1
---
```

## Required Body Content

- review conclusion: pass / not pass
- review scope
- findings list
- severity per finding: `blocker` or `minor`
- overall judgment and next-step note when the review blocks progress

## Separation Rule

- If the reviewed target has an `author` field, default to `reviewer != author`.
- If the human waives creator/reviewer separation, state that waiver explicitly in the review context or report.

## Workflow Rules

- Review, recheck, acceptance, audit, and similar requests must create the review report before any chat summary.
- Code review reports must name the reviewed files, directories, or modules explicitly.
- Review conclusions stay in the body; they are not stored as a separate frontmatter status field.
- Findings use only `blocker` and `minor`; no extra severity scale should be invented ad hoc.
