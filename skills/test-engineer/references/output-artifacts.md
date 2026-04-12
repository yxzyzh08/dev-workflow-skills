# Test Engineer Output Artifacts

Use this file when producing or reviewing E2E assets.

## `<from paths.releases_dir>/r{n}/testing/e2e-plan.md`

Expected coverage:

- acceptance items covered by the suite
- preparation and environment setup
- case list with expected observations
- traceability from each case to requirement / acceptance IDs
- cleanup or reset steps for repeatable runs

## E2E suite

Expected properties:

- executable from automated setup
- black-box assertions
- no dependency on implementation internals

## `<from paths.releases_dir>/r{n}/testing/reviews/e2e-review-{nn}.md`

Expected coverage:

- review scope
- coverage gaps
- automation gaps
- execution readiness
- pass / not pass judgment
