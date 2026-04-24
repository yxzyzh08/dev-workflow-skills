# Acceptance Designer Boundary Examples

Use this file to decide whether a request belongs to `acceptance-designer` or to another skill, and to resolve common structural edge cases inside an acceptance document.

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
- "Layer a runtime environment-error annotation onto a run" → `delivery-qa` (case-level outcome stays inside the closed vocabulary)

## Scope Edge Cases

| Situation | Owner | Reason |
| --- | --- | --- |
| Acceptance work finds missing requirement detail | If only clarification (boundary unchanged): `acceptance-designer` updates requirements in place with `change_history`. If boundary expands: create CR, return to `requirements-analyst` | Freeze rules determine the path |
| Human wants to add exception path to acceptance | `acceptance-designer` — but only if it's a product commitment, governance gate, or recovery capability | Non-normal path inclusion rule |
| Acceptance item cannot be tool-checked by AI | Classify as `verifier: human` or `verifier: hybrid`; never silently omit the item | H1 human-verification rule |
| Test engineer finds acceptance ambiguity | Route to `acceptance-designer` for clarification; if frozen, assess small vs. large adjustment | Upstream change handling |
| Human questions acceptance scope | `acceptance-designer` for discussion; human decides | Human gate for alignment |

## Structural Edge Cases

| Situation | Decision |
| --- | --- |
| Case shares setup with many siblings | Define setup once in the State Catalog; cases reference the state ID and only list case-specific deltas |
| Section of subcases share a starting state | Declare Section Defaults at the subsection head; cases inherit and override when needed |
| Case has human-typed gate (e.g., typing a `freeze`/`approve`/`reject` command) but all expected bullets are AI-tier | `default-actor: ai` with step override `(actor=human)` for the gate step; `verifier: ai`. **Not** `hybrid` — tier is determined by observation modes, not by who typed a command |
| Case mixes mechanical checks with judgment-based observations | `verifier: hybrid` with an AI block (Flow + AI pass checklist) and a Human block (signals format). One case-level outcome rule; no `Overall pass:` line |
| Author claims `verifier: human` to avoid writing mechanical assertions | Reviewer challenges `Why human?`. Reclassifies if the observation could be expressed via an AI-tier mode with reasonable effort |
| Case depends on previous case's tail state | Rejected. Every case must start from a declared State Catalog state; the case resets to that state at its start |
| Product offers no workspace/home flag | Use State Catalog Variant A (serial + run-lock). Do not invent a flag |
| Flow needs a construct outside the 5 primitives or the Condition sub-grammar | Rewrite via primitive nesting; only if truly unavoidable, file a grammar-extension RFC before writing the case |
| "Across the case" assertion needed (e.g., "at least one stage used a non-default executor") | Use a Scope-2 aggregate Pass-checklist bullet (`at-least-once`, `for-all-iterations`, `count-matching`). **Not** inside a step-local `expected` |
| Need a numeric threshold (`max_retries`, `timeout_ms`, `default-executor`) in conditions or observations | Declare via case-level Placeholders. Do not use a bare unquoted token as a literal |
| Need "session unchanged" / "counter incremented" / "value decreased" assertions | Use `file-field-delta` with a named checkpoint (`case-start`, `step-start`, `iteration-start`, `loop-start`). Do not invent verbal forms like "unchanged" inside `file-field` |
| Step has no external action and just waits for state | `step (actor=<ai|system|human>, kind=wait)` with `within Ns` on every expected bullet. `actor=system` implies `kind=wait` |
| `file-field-delta` target is the outer iterator, not the inner | `iteration-start` binds to the innermost iterator. To reach an outer iteration use `loop-start` (if the outer is `loop-until`), `case-start`, or split the case |
| For-each needs to iterate over something that isn't a literal list | Declare a list Placeholder (case-level) whose RHS is a literal list. Use the placeholder name as the for-each source. Derived sources (e.g., `nodes-of(<yaml>)`) are not allowed |
| Case wants `partial-coverage` but has no obvious branch to declare | Not valid. Either declare at least one branch with a concrete exercised-condition, or drop rule 3 and the `partial-coverage` outcome from the rule list |
| `Declared branches` exercised-condition looks like `for-all-iterations in {scope}: <obs>` | Rejected. `for-all-iterations` belongs in Pass-checklist aggregates, not branch exercises — it collapses the branch concept |
| Human case author wants to declare a branch for `partial-coverage` | Allowed but rare. Exercised-condition must be a plain human-tier `<observation>` only; `at-least-once` and `count-matching` require a Flow `<scope>` that human cases don't have |
| Hybrid case wants a separate "AI passed but human failed" result | Not allowed as a distinct outcome. The case-level outcome rule's rule 2 combines AI-checklist-fail and Human-Fail-signal into one `fail` |
| Human case observer cannot complete (environment broke, ran out of effort budget) | Declare a matching `Inconclusive signals` bullet; the human outcome rule emits `inconclusive-human-needed` via rule 1 |
| Case has both a `set-outcome inconclusive-human-needed` branch and Pass-checklist items about completion | Outcome is `inconclusive-human-needed` when the branch fires (rule 1). Unreached completion-oriented checklist bullets are not evaluated. Authors should verify the branch actually reflects an authorial decision to classify the case as inconclusive rather than fail |
| Author wants to write `set-outcome fail` or `set-outcome partial-coverage` inside the Flow | Not allowed. `set-outcome` is only legal as `set-outcome inconclusive-human-needed`. `pass` / `fail` / `partial-coverage` are determined by the outcome rule |
| Environment/fixture failure caused a Pass-checklist item to fail | Outcome is `fail` unless the author had already fired an explicit `set-outcome inconclusive-human-needed` earlier in the Flow. To classify as inconclusive, the Flow must detect the environmental condition observably and fire `set-outcome` before the checklist item fails |同意
