# Delivery QA Output Artifacts

Use this file when producing delivery-stage records.

## `run-{date}.md`

Record at least:

- execution command or trigger context
- environment notes that matter for interpretation
- pass / fail summary
- notable observations and evidence links

## `bug-{nn}.md`

Record at least:

- failing case
- reproduction steps
- evidence-backed root cause
- affected doc / code scope
- suggested fix direction

## Review reports

- `result-review-{nn}.md` checks whether the failure analysis is reasonable
- `fix-review-{nn}.md` checks whether the fix plan is actionable

## `final-delivery.md`

Summarize the overall delivery state across all runs; do not replace the per-run records.
