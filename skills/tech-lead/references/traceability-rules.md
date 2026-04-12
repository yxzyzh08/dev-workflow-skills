# Tech Lead Traceability Rules

Use this file to keep plan and detail aligned.

## Requirements to plan

- every plan entry cites the release-qualified requirement / acceptance ID it implements
- every plan task maps back to a requirement or explicit cross-cutting work item

## Plan to outputs

- each task names the doc, code area, or test area it will create or change
- dependency notes explain who must finish first and what artifact unlocks the next task

## Plan tasks to steps

- every step within a task traces to the parent task ID (steps live inline in plan.md or in `tasks/T{n}.md` depending on format)
- in split format, plan.md must list the file path to each task file so the step location is navigable
- step expected-output must be verifiable: a command that can be run, a file that can be checked, or a state that can be observed
- if a step produces an artifact that another task depends on, the dependency note in plan.md must reference the specific step, not just the task

## Detail as contract authority

- detail.md is the single authority for interface and data-model contracts; task steps in plan.md or `tasks/T{n}.md` reference detail.md sections instead of duplicating definitions
- every interface or data model section in detail.md points back to the plan task that owns it
- every task step that implements a contract — whether inline in plan.md or stored in `tasks/T{n}.md` — cites the corresponding detail.md section
- field-level definitions in detail.md are stable enough that developers should not invent missing contract details
- if task-step code in plan.md or `tasks/T{n}.md` conflicts with detail.md, detail.md wins — update the step, not the contract
