# Git Manager Boundary Examples

Use these examples when the request is near another operational boundary.

- Use `git-manager`: isolated worktrees, branch naming, merge ordering, or cleanup are the main concern.
- Do not use `git-manager`: the task is to decide whether work should be parallel at all; use `parallel-dispatcher`.
- Do not use `git-manager`: the request is to verify stage completion evidence; use `completion-verifier`.
- Do not use `git-manager`: the request is to implement the feature inside the branch rather than manage the branch/worktree environment.
