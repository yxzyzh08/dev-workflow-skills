# Acceptance Designer Boundary Examples

Use this file to decide whether a request belongs to `acceptance-designer` or to another skill.

## Belongs to acceptance-designer

- "Design acceptance test cases from frozen requirements" → acceptance design (Step 4)
- "Review the acceptance document" → acceptance review (Step 5-6)
- "Add a governance gate to acceptance" → only if it's a product commitment, governance gate, or recovery capability
- "Reopen acceptance after CR-01 was approved" → CR-driven re-entry
- "The requirement was clarified — update acceptance" → small upstream adjustment, update in place with `change_history`

## Does NOT belong to acceptance-designer

- "Collect and clarify requirements" → `requirements-analyst`
- "Design the system architecture" → `system-architect`
- "Write the E2E test code" → `test-engineer`
- "Run the E2E suite" → `delivery-qa`
- "Check if the acceptance document metadata is valid" → `doc-guardian`
- "Mark acceptance stage complete" → `completion-verifier`

## Edge Cases

| Situation | Owner | Reason |
| --- | --- | --- |
| Acceptance work finds missing requirement detail | If only clarification (boundary unchanged): `acceptance-designer` updates requirements in place with `change_history`. If boundary expands: create CR, return to `requirements-analyst` | Freeze rules determine the path |
| Human wants to add exception path to acceptance | `acceptance-designer` — but only if it's a product commitment, governance gate, or recovery capability | Non-normal path inclusion rule |
| Acceptance item cannot be tool-checked | `acceptance-designer` must rewrite until tool-checkable | Tool-checkability is mandatory |
| Test engineer finds acceptance ambiguity | Route to `acceptance-designer` for clarification; if frozen, assess small vs. large adjustment | Upstream change handling |
| Human questions acceptance scope | `acceptance-designer` for discussion; human decides | Human gate for alignment |
