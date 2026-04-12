# Delivery QA Root Cause And Routing

Use this file before classifying a failed E2E run.

## Classification lens

- `architecture`: system structure or shared foundation cannot support the required scenario
- `design`: interface, data-model, or behavior contract is missing or incorrect
- `code`: implementation diverges from the approved design or contains logic defects

## Evidence chain

Compare at least:

- acceptance baseline from `paths.acceptance`
- architecture baseline from `paths.architecture`
- `<from paths.releases_dir>/r{n}/design/detail.md`
- `<from paths.releases_dir>/r{n}/design/plan.md` and `tasks/T{n}.md` if split format (including step-level decomposition and expected outputs)
- `<from paths.releases_dir>/r{n}/design/reviews/spec-review-{nn}.md` and `code-review-{nn}.md` from the implementation stage — check whether the two-stage review caught the issue or missed it
- observed E2E behavior and execution evidence

## Routing rule

If the evidence still does not support a confident category after another pass, escalate to the human instead of forcing a label.
