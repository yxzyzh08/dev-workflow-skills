# Delivery QA Boundary Examples

Use these examples when the request sits on a delivery boundary.

- Use `delivery-qa`: E2E assets exist, and the next need is execution, evidence capture, failure analysis, review-gate judgment, or final delivery reporting.
- Do not use `delivery-qa`: the request is to change production code directly; route to `developer` after classification.
- Do not use `delivery-qa`: the E2E suite itself still needs to be authored or revised; use `test-engineer`.
- Do not use `delivery-qa`: acceptance behavior must be redefined; route upstream instead of rewriting the promise here.
