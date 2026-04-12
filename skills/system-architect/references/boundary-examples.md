# System Architect Boundary Examples

Use these examples when the request sits near another stage boundary.

- Use `system-architect`: requirements and acceptance are already stable, and the next need is a durable architecture baseline.
- Do not use `system-architect`: acceptance is still being defined or revised; use `requirements-analyst` or `acceptance-designer` first.
- Do not use `system-architect`: the problem is module slicing, interface shape, or field-level data modeling; use `tech-lead`.
- Do not use `system-architect`: Delivery QA has already classified the failure as a code bug; route to `developer`.
