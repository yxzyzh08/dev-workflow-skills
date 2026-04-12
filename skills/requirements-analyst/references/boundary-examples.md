# Requirements Analyst Boundary Examples

Use this file to decide whether a request belongs to `requirements-analyst` or to another skill.

## Belongs to requirements-analyst

- "Clarify what the platform should do" → requirement clarification (Step 1)
- "Structure the requirements into a tree" → requirement structuring (Step 2)
- "Review the requirements document" → requirement review (Step 3)
- "Add a new capability to the requirements" → requirement revision (check freeze rules)
- "The acceptance designer found an upstream gap" → small adjustment if boundary unchanged, CR if boundary expands
- "Reopen requirements after CR-01 was approved" → CR-driven re-entry

## Does NOT belong to requirements-analyst

- "Design the acceptance test cases" → `acceptance-designer`
- "How should we architect this?" → `system-architect`
- "What should the API look like?" → `tech-lead` (detailed design)
- "Fix the broken test" → `developer` or `systematic-debugger`
- "Is the requirements document frozen correctly?" → `doc-guardian` (compliance check)
- "Mark the requirements stage as complete" → `completion-verifier`

## Edge Cases

| Situation | Owner | Reason |
| --- | --- | --- |
| Acceptance designer discovers missing requirement detail | `requirements-analyst` if boundary/responsibility change; `acceptance-designer` in-place update if only clarification | Freeze rules determine the path |
| Human wants to add a 3rd-level item under frozen 2nd-level | `requirements-analyst` — but only a small adjustment if capability boundary and acceptance responsibility do not expand | Per workflow-protocol freeze rules |
| Human questions whether a requirement is in scope | `requirements-analyst` for clarification; human decides | Human gate for scope alignment |
| Product fact source (`sources.product_prd`) changed | `requirements-analyst` must assess impact; may need CR if frozen baseline affected | Change routing through protocol |
