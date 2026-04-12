# System Architect Impact Analysis Checklist

Use this file when architecture changes because of review findings or E2E root-cause analysis.

## Record the change

- which architecture sections changed
- why the previous architecture was insufficient
- whether the change is a small adjustment or needs a CR

## Downstream impact

Check at least these paths:

- `<from paths.releases_dir>/r{n}/design/plan.md`
- `<from paths.releases_dir>/r{n}/design/detail.md`
- `<from paths.releases_dir>/r{n}/testing/e2e-plan.md`
- code areas or integration points already implemented

## Fix-task list

Publish concrete follow-up tasks with:

- owner skill
- touched artifact or module
- sequence or dependency notes
