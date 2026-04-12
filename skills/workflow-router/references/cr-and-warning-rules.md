# Workflow Router CR And Warning Rules

Use this file when CR state or out-of-order intent changes the route.

## CR overrides

- `decision: pending` -> tell the human the affected path is waiting on human decision
- `decision: approved` but not closed -> route to the earliest skill implied by `minimum_return_steps`
- downstream docs reopened to `active` by CR -> do not steer toward the old downstream mainline until they are re-frozen

## Out-of-order warning rules

- warn when the human is jumping ahead of frozen upstream baselines
- do not block the human; make the risk explicit and route to the likely owner
- remind the human that the router only recommends and does not execute the work
