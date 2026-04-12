# Tech Lead Impact Analysis Checklist

Use this file when review findings or E2E evidence force design changes.

## Re-check these artifacts

- `<from paths.releases_dir>/r{n}/design/detail.md` (single contract authority — check first)
- `<from paths.releases_dir>/r{n}/design/plan.md` (index or single-file with steps)
- `<from paths.releases_dir>/r{n}/design/tasks/T{n}.md` (if split format — check each affected task file)
- downstream E2E plans or existing code that rely on the changed contract

## Document the ripple

- what requirement / acceptance / architecture assumption changed
- which interfaces or data models in detail.md are invalidated
- which plan.md tasks or steps have detail.md references that are now stale and need updating
- whether dependencies or parallel groups must be re-sequenced
- whether step-level expected outputs are still valid after the contract change
- which owner should take each repair task
