# Git Manager Worktree And Branch Rules

Use this file before creating or cleaning up isolated git work.

## Naming contract

- branch: `r{n}/task-{nn}-{slug}`
- worktree: `.worktree/r{n}/task-{nn}-{slug}`

## Environment checks

- current directory is inside a git repository
- protected base branch is known
- target branch name does not collide with an existing worktree assignment
- `.worktree/` path is available for isolated checkouts

## Guardrails

- one worker per worktree
- no shared checkout for parallel workers
- no force-push to the protected branch
- integration stays serial even when implementation was parallel
