# Test Engineer Boundary Examples

Use these examples before taking ownership of a borderline request.

- Use `test-engineer`: acceptance is frozen, detailed design is stable, and the next step is black-box E2E planning or automation.
- Do not use `test-engineer`: acceptance is still changing; return upstream before authoring E2E assets.
- Do not use `test-engineer`: the request depends on reading production implementation internals; keep the suite black-box.
- Do not use `test-engineer`: the task is to classify a failed E2E run after execution; use `delivery-qa`.
