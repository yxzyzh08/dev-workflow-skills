# Acceptance Output Artifacts Reference

Use this file to verify the acceptance baseline meets the minimum artifact contract.

## Acceptance Baseline (`paths.acceptance`)

### Required Frontmatter

| Field | Required | Notes |
| --- | --- | --- |
| `title` | yes | Human-readable document title |
| `type` | yes | Must be `acceptance` |
| `status` | yes | `draft`, `active`, or `frozen` |
| `version` | yes | Document revision number, e.g., `"0.4"` |
| `created` | yes | `YYYY-MM-DD HH:mm` |
| `last_modified` | yes | `YYYY-MM-DD HH:mm` |
| `author` | yes | Agent identifier or `human` |
| `upstream` | recommended | e.g., `paths.requirements` |
| `downstream` | recommended | e.g., `paths.architecture` |
| `change_history` | yes | Each entry: `date`, `author`, `description` |

### Required Body Sections

1. **Document Instructions** — usage rules:
   - Default coverage is main flow + formal product commitments only
   - Exceptions only when they are product commitments, governance gates, or recovery capabilities
   - Each acceptance item must include: actionable verification action, determinable pass criteria, stable requirement tracking ID
   - Process descriptions in Markdown, not HTML/prototypes

2. **Acceptance Preparation** — test fixture setup:
   - Fixed acceptance fixtures (complete structure and workflow templates)
   - Repository and configuration assets (sample repos, config examples)
   - Observation and fault injection preparation (state file inspection, fault scenarios)

3. **Main-Flow Acceptance Stories** — organized by feature area, each item containing:
   - **Verification action**: explicit steps to execute
   - **Pass criteria**: determinable, tool-checkable conditions
   - **Tracked requirements**: requirement IDs or `X` track IDs being verified

4. **Independent Formal Acceptance Items** — non-main-flow items that meet the formal inclusion rule:
   - Workflow/DSL-specific validation
   - Retry, timeout, session continuity
   - Isolation and recovery capabilities
   - Governance gates and constraints

5. **Next-Phase Constraints** — constraints for downstream stages

### Release Tag Convention

- Cases carry release origin tags: `(r1)`
- When modified in a later release: `(r1→r3 modified)` — show origin and latest only
- Do NOT chain: NOT `(r1→r2→r3 modified)`
- Tags go on individual cases, not group headers

### Traceability Contract

- Every formal acceptance item must trace to at least one requirement ID or `X` track ID
- Unbranched requirements track to level 2
- Branched requirements track to level 3 `must-have` items

## Review Reports (`acc-review-{nn}.md`)

### Required Frontmatter

| Field | Required | Notes |
| --- | --- | --- |
| `title` | yes | e.g., "Acceptance Review Report 01" |
| `type` | yes | Must be `review` |
| `created` | yes | `YYYY-MM-DD HH:mm` |
| `target` | yes | Resolved path to acceptance document |
| `reviewer` | yes | Must differ from document `author` unless human waives |

### Required Body

1. **Conclusion** — `pass` or `not pass`
2. **Review Scope** — target, sources, focus areas
3. **Findings** — numbered with `[blocker]` or `[minor]`
4. **Overall Judgment** — summary and next steps

### Review Focus Areas

- Tool-checkability: can each acceptance item be verified by running a command or checking output?
- Requirement traceability: does every item trace to a requirement or `X` ID?
- Non-normal path inclusion: are non-normal paths included only when they meet the formal inclusion rule?
- Requirement boundary: does the acceptance document stay inside the frozen requirement scope?
- Preparation completeness: are fixtures, configs, and observation tools defined?
