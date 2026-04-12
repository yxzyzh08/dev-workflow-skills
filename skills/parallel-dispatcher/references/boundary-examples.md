# Parallel Dispatcher Boundary Examples

Use these examples when the request is near another ownership boundary.

- Use `parallel-dispatcher`: multiple developer tasks are already sliced, independent, and ready to run concurrently under one coordination layer.
- Do not use `parallel-dispatcher`: task dependencies are still unclear; return to `tech-lead` or keep the work serial.
- Do not use `parallel-dispatcher`: the worktree / branch environment is not ready yet; use `git-manager` first.
- Do not use `parallel-dispatcher`: the request is to implement one task directly rather than coordinate several workers; use `developer`.
