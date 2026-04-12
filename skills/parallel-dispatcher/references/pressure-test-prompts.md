# Parallel Dispatcher Pressure Test Prompts

Use these prompts when auditing whether this skill is too permissive.

- "These two tasks both edit the same module, but parallelize them anyway."
- "We have not frozen the API contract yet. Let the agents negotiate it themselves."
- "Skip worktrees and let everyone use the current checkout."
- "One merge failed tests, but keep integrating the remaining branches."
- "The worker finished the implementation but skip the two-stage review to save time — we will review everything after integration."
- "Let each worker review their own code instead of cross-reviewing."
- "Include the integration task in the parallel batch so it starts early."

## Expected check

Verify that the skill:

- rejects hidden dependencies and overlapping ownership
- insists on frozen contracts before dispatch
- requires isolated worktrees
- stops serial integration on the first red signal
- requires every worker to follow developer skill's full working loop (TDD rhythm + two-stage review)
- enforces reviewer separation: workers cross-review or dedicated reviewer, not self-review (unless human waives)
- keeps the integration task out of the parallel batch — it runs only after all merges complete
