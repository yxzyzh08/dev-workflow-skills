# Tech Lead Output Artifacts

Use this file when producing or reviewing release design artifacts.

## `<from paths.releases_dir>/r{n}/design/plan.md`

Expected coverage:

- release goal
- included requirement / acceptance IDs
- excluded or deferred items
- upstream assumptions that shape the release
- task list
- dependency notes per task
- parallel or serialized execution notes
- output locations for each task
- key risks, blockers, or handoff points

### Step-level decomposition per task

Each task must have an ordered list of steps. Each step provides:

- action: one-sentence description of what the step accomplishes
- code or content: complete code, commands, file content, or configuration (copy-paste ready, no placeholders)
- expected output: observable result after the step completes (test output, file on disk, command stdout, state change)

Step count target per task: 2-10. Target 2-5 minutes per step. In single-file format, no task may exceed 10 steps. If a coherent task needs more than 10 steps, switch to split format and place that task's decomposition in `tasks/T{n}.md`; split the task itself only when the work is actually multiple independent objectives.

### Single-file vs split format

Choose the format based on plan size:

- **Single-file** (tasks ≤ 3 and no task exceeds 10 steps): steps are inline in plan.md under each task entry.
- **Split format** (tasks > 3 or any coherent task needs more than 10 steps): plan.md stays as a lightweight index (task list, dependencies, parallel groups, output locations, risks). Each task's step decomposition moves to `<from paths.releases_dir>/r{n}/design/tasks/T{n}.md`. plan.md must list every task file path in its task entries so readers can navigate.

In split format, the `tasks/` directory is part of the design artifact set. Each `T{n}.md` file contains only the step decomposition for that task and a header citing the parent task ID and the detail.md sections it references. A task file may exceed 10 steps when the task remains one coherent objective.

### Integration task

When plan.md contains more than one task and tasks share interfaces or data flow, the last task must be an integration task. Its purpose is to wire all prior task outputs together at the development level before handing off to test-engineer for black-box E2E.

Integration task expected coverage:

- objective: verify cross-module wiring, data flow, and interface contracts from detail.md work end to end
- steps: connect modules, write integration tests (developer-perspective cross-module verification, not black-box E2E), run integration tests, produce integration verification evidence
- output: integration test code + passing command output as evidence

Exemption: single-task plans do not need an integration task. Multi-task plans with fully independent tasks (no shared interfaces or data flow) may omit it if plan.md states the reason explicitly.

## `<from paths.releases_dir>/r{n}/design/detail.md`

detail.md is the single authority for contract definitions. Task steps in plan.md or `tasks/T{n}.md` reference detail.md sections for interface and data-model specifications instead of duplicating them.

Expected coverage:

- module responsibility notes
- interface definitions (the authoritative source — task steps in plan.md or `tasks/T{n}.md` cite these, not redefine them)
- data models field by field (the authoritative source — task steps in plan.md or `tasks/T{n}.md` cite these, not redefine them)
- validation and error-contract notes where needed
- no unresolved placeholders

## `<from paths.releases_dir>/r{n}/design/reviews/design-review-{nn}.md`

Expected coverage:

- reviewed artifacts
- findings with severity
- decision and required follow-up
