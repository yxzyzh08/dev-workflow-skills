# Parallel Dispatcher Prerequisites

Use this file before dispatching any parallel batch.

## Required preconditions

- `<from paths.releases_dir>/r{n}/design/plan.md` names task dependencies explicitly; if split format is used, each task file under `tasks/T{n}.md` exists and contains complete step decomposition
- each candidate task has a stable output location and owner boundary
- shared interfaces or data contracts are already frozen by `tech-lead`
- upstream requirement, acceptance, and architecture baselines are stable enough for implementation
- git worktree isolation is available through `git-manager`
- review resources are available: enough agents for cross-review between workers, or human has explicitly waived reviewer separation
- for multi-task plans with shared interfaces or data flow: a valid integration task exists in plan.md and is excluded from the parallel batch — it runs after all parallel merges complete. For multi-task plans with fully independent tasks: an integration task exists and is excluded, or plan.md contains an explicit exemption reason. Single-task plans do not require an integration task.

## Blockers that force serial work or escalation

- hidden dependency between tasks
- overlapping write ownership on the same files or modules
- unresolved interface contract between agents
- pending CR that can still reroute the task set
- missing human approval for a scope or contract change
