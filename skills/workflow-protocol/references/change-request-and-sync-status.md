# Change Request Quick Reference

Use this file when a workflow skill needs to judge whether a frozen baseline may change or whether downstream documents need reopening.

## Required CR fields to inspect

At minimum, check these fields before treating a CR as actionable:

- `targets`
- `change_category`
- `decision`
- `minimum_return_steps`
- `downstream_impact`

The resolved target paths should come from `workflow-project.yaml` rather than from literal repository paths.

## CR lifecycle

- `decision: pending` → no unfreeze, wait for human
- `decision: approved` → reopen only the listed targets and start from the minimum return path
- `decision: rejected` → keep the frozen baseline unchanged

## Downstream impact on approval

When a CR is approved, affected downstream documents must have their `status` set back to `active` with a `change_history` entry referencing the CR. Documents in `active` status cannot serve as frozen baselines for further downstream work until they pass review and are re-frozen.

## Minimum return path

- requirement CR → at least requirement + acceptance loop
- acceptance CR → at least acceptance loop

`minimum_return_steps` is the smallest allowed upstream re-entry path after approval. Downstream stages may need to reopen further, but they may not reopen less than this declared minimum.

## YAML example

> **Immutable reference rule:** In actual CR artifacts, `targets` and `downstream_impact` paths must store the resolved concrete path at write time, not the `<from paths.*>` placeholder.

```yaml
---
title: "Change Request 01"
type: change-request
created: 2026-04-11 16:00
status: active
last_modified: 2026-04-11 16:00
author: <agent>
targets:
  - <from paths.requirements>               # actual artifact writes resolved path
change_category: scope
decision: pending
minimum_return_steps:
  - "Steps 1-3: requirement clarification and review"
downstream_impact:
  - path: <from paths.acceptance>            # actual artifact writes resolved path
    action: reopen-to-active
change_history:
  - date: 2026-04-11 16:00
    author: <agent>
    description: "Create CR"
---
```

## Cascade depth limit

- Every CR must declare its expected cascade scope in `downstream_impact`.
- If the cascade spans more than 2 stages, the CR must be flagged as a **major change** and escalated to the human for a dedicated scope decision before approval.
- If cascading reopenings threaten to exceed 2 stages deep, stop and escalate with a full impact summary.

## Protocol rule

- A CR closes only after reopened documents pass review, are re-frozen, and all affected downstream documents have been re-reviewed, unless the human explicitly waives that requirement.
