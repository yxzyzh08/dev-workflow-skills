# Requirements Output Artifacts Reference

Use this file to verify the requirements baseline meets the minimum artifact contract.

## Requirements Baseline (`paths.requirements`)

### Required Frontmatter

| Field | Required | Notes |
| --- | --- | --- |
| `title` | yes | Human-readable document title |
| `type` | yes | Must be `requirements` |
| `status` | yes | `draft`, `active`, or `frozen` |
| `created` | yes | `YYYY-MM-DD HH:mm` |
| `last_modified` | yes | `YYYY-MM-DD HH:mm` |
| `author` | yes | Agent identifier or `human` |
| `release` | yes | e.g., `r1` |
| `upstream` | recommended | Sources such as `sources.product_prd` |
| `downstream` | recommended | e.g., `paths.acceptance` |
| `change_history` | yes | Each entry: `date`, `author`, `description` |

### Required Body Sections

1. **Document Instructions** — usage rules for the requirement hierarchy (level structure, numbering, cross-cutting track rules)
2. **Version Scope** — version goals, current scope, explicit no-goals
3. **Main Requirement Tree** — hierarchical capability structure:
   - Level 1: capability domain (e.g., "Platform Services")
   - Level 2: capability unit — each must declare: goal, boundary, acceptance responsibility, cross-cutting references
   - Level 3 (optional): scoped deliverable with priority tag (`must-have`, `later`, `deferred`)
4. **Cross-Cutting Requirements** (`X` track) — items like logging, observability, permissions, isolation, security, governance. Each declares: goal, applicable scope, constraints, acceptance focus
5. **Freeze and Version Notes** — freeze rules, small vs. large adjustment criteria
6. **Traceability** — upstream sources, downstream consumers

### Numbering Contract

- Release-qualified stable IDs: `r1-REQ-1`, `r1-REQ-1.2`, `r1-REQ-1.2.3`
- Cross-cutting: `X1`, `X2`, etc.
- IDs are stable once assigned; never renumber frozen items

## Review Reports (`req-review-{nn}.md`)

### Required Frontmatter

| Field | Required | Notes |
| --- | --- | --- |
| `title` | yes | e.g., "Requirements Review Report 01" |
| `type` | yes | Must be `review` |
| `created` | yes | `YYYY-MM-DD HH:mm` |
| `target` | yes | Resolved path to requirements document |
| `reviewer` | yes | Must differ from document `author` unless human waives |
| `release` | yes | e.g., `r1` |

### Required Body

1. **Conclusion** — single line: `pass` or `not pass`
2. **Review Scope** — target document, source documents checked, review focus areas
3. **Findings** — numbered findings with severity: `[blocker]` or `[minor]`
4. **Overall Judgment** — summary and next steps

### Review Focus Areas

- Scope clarity: are goals, no-goals, and boundaries explicit?
- Numbering stability: are IDs release-qualified and consistent?
- Freeze boundaries: are level-2 capability boundaries and acceptance responsibilities clearly defined?
- Cross-cutting separation: are `X` track items correctly separated from the main tree?
- Traceability: does each requirement trace to upstream sources?
