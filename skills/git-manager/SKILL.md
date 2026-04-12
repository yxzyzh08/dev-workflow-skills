---
name: git-manager
description: Use when isolated worktrees, workflow branch naming, or serial integration control are needed for implementation work
---

# Git Manager

## Overview

Git Manager owns worktree isolation, branch naming discipline, merge ordering, and cleanup for implementation work. It keeps parallel development from colliding in one checkout and keeps protected-branch integration explicit and serial.

## Support Files

Use these support assets before manipulating branches or worktrees:

- `references/worktree-and-branch-rules.md`
- `references/integration-checklist.md`
- `references/boundary-examples.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)
- `scripts/check-worktree-env.sh`

## First Step

Read `skills/workflow-protocol/SKILL.md`, then repository-root `workflow-project.yaml`. Resolve `paths.progress`, then read the progress dashboard at `paths.progress`. Before creating or cleaning up worktrees, run `scripts/check-worktree-env.sh` and scan `references/boundary-examples.md` if the request overlaps with dispatch or verification ownership.

## When to Use

Use this skill when:

- isolated worktrees are needed for implementation work
- branch naming and task-to-branch mapping need to stay consistent
- multiple branches must be merged in a controlled serial order
- merged or abandoned worktrees need cleanup

Do not use this skill to decide task decomposition, verify stage completion, or implement the feature work itself.

## Inputs

- task or release plan with IDs (for example, plans under `<from paths.releases_dir>/r{n}/`)
- current protected-base branch context
- signals from workers about readiness, conflicts, or cleanup needs
- merge-order requirements coming from dependency or integration risk

## Outputs

- branches named `r{n}/task-{nn}-{slug}`
- `.worktree/r{n}/task-{nn}-{slug}` directories
- integration notes covering merge order, conflicts, and verification status
- cleaned-up worktrees and branch references after landing or abandonment

## Working Loop

1. Run `scripts/check-worktree-env.sh` and confirm the environment is ready.
2. Apply `references/worktree-and-branch-rules.md` to derive the branch and worktree name.
3. Create one worktree per worker and keep ownership isolated.
4. Use `references/integration-checklist.md` to merge branches back in serial order with verification in front of each merge.
5. Clean up worktrees and branch references after the integration outcome is recorded.

## Worktree Rules

- One worker per worktree, always under `.worktree/`.
- Naming follows `r{n}/task-{nn}-{slug}` for both traceability and cleanup.
- No force-push to the protected branch.
- If merge conflicts or verification failures occur, resolve and re-verify before the next merge starts.

## Completion Checklist

- The environment check ran before worktree operations.
- Each worktree and branch follows the naming contract.
- Merge order, conflict notes, and verification outcomes are recorded.
- Merged or abandoned worktrees are cleaned up.
- Protected-branch history stayed non-destructive.
