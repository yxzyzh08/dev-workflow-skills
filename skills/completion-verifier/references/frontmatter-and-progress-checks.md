# Completion Verifier Frontmatter And Progress Checks

Use this file when document outputs or progress rows are in scope.

## Document metadata checks

Review as needed:

- `status`
- `upstream`
- `downstream`
- `change_history`

## Progress artifact checks

- the stage row in `paths.progress` (dashboard) matches the actual artifact state
- dashboard does not claim more than the evidence supports
- blocked work remains blocked after a NOT PASS verdict
- on PASS, both `paths.progress` and `paths.progress_history` must be updated per `workflow-protocol`

## Escalate instead of passing when

- frontmatter state conflicts with actual workflow state
- progress claims completion that the artifacts do not prove
- a pending CR still blocks the claimed completion
