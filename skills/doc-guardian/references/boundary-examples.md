# Doc Guardian Boundary Examples

Use this file to decide whether a request belongs to `doc-guardian` or to another skill.

## Belongs to doc-guardian

- "Check if the document frontmatter is valid" → metadata validation
- "Is this frozen document being edited legally?" → freeze compliance check
- "The progress dashboard doesn't match the actual document state" → progress correction
- "Does this CR have proper approval before unfreezing?" → CR state validation
- "Can this draft document be used as a downstream baseline?" → derivation legality check (answer: no, only frozen)
- "Verify document state transitions are legal" → state flow validation

## Does NOT belong to doc-guardian

- "Write the requirements document" → `requirements-analyst`
- "Review the acceptance document for content quality" → `acceptance-designer`
- "Is this stage complete?" → `completion-verifier` (evidence gate, not compliance gate)
- "Route me to the next skill" → `workflow-router`
- "Fix the code" → `developer`
- "Analyze this test failure" → `systematic-debugger` or `delivery-qa`

## Edge Cases

| Situation | Owner | Reason |
| --- | --- | --- |
| Progress dashboard says stage is frozen but document is still `active` | `doc-guardian` corrects dashboard to match document reality | Frontmatter reality wins |
| A skill wants to use a `draft` document as baseline | `doc-guardian` blocks — only `frozen` (or `stable` for architecture) documents may serve as baselines | Derivation legality |
| Small adjustment to frozen document without CR | `doc-guardian` allows if `change_history` is appended | Small adjustment rule |
| Large adjustment to frozen document without CR | `doc-guardian` blocks and escalates | CR required for large adjustments |
| Completion-verifier PASS updates dashboard | Not doc-guardian's concern — completion-verifier has dashboard write permission for stage advancement | Write permission layering |
| Router finds dashboard inconsistency | Router reports it, recommends doc-guardian; doc-guardian does the actual correction | Router is read-only |

## Permission Boundary

Doc-guardian may:
- Correct dashboard metadata inconsistencies
- Block illegal document modifications
- Append correction entries to `paths.progress_history`

Doc-guardian must NOT:
- Advance stage status (that's `completion-verifier`)
- Create or modify content documents
- Execute stage work
