# Step Decomposition Rules

Use this file when breaking plan.md tasks into implementation-ready steps.

## Granularity target

Each step should take 2-5 minutes to execute. If a step takes longer, split it. If shorter, merge with an adjacent step.

## Required fields per step

1. **action**: one sentence stating what the step accomplishes
2. **code or content**: complete, copy-paste ready material — source code, shell commands, file content, or configuration. Must not contain unresolved or deferred content.
3. **expected output**: the observable result — test output, command stdout, file existence, state change. Must be verifiable without subjective judgment.

## Step count bounds

- minimum: 2 steps per task (if a task is truly atomic, it may be too small to be a separate task)
- inline ceiling: in single-file format, no task may exceed 10 steps; if a coherent task needs more than 10 steps, switch to split format and move that task's decomposition to `tasks/T{n}.md`

## Single-file vs split format

After writing all task steps, check the plan size:

- **Single-file**: tasks ≤ 3 and no task exceeds 10 steps → keep steps inline in plan.md.
- **Split format**: tasks > 3 or any coherent task needs more than 10 steps → move each task's steps to `<from paths.releases_dir>/r{n}/design/tasks/T{n}.md`. plan.md becomes a lightweight index that lists task IDs, dependencies, parallel groups, output locations, risks, and the file path to each task file.

In split format, each `T{n}.md` must include:
- a header with the task ID and a one-line objective
- which detail.md sections it references
- the ordered step list (same fields as single-file steps; it may exceed 10 steps when the task remains one coherent objective)

## Contract reference rule

When a step implements an interface, data model, or validation contract defined in detail.md, the step must cite the corresponding detail.md section (e.g., "implement interface per detail.md section 3.2") rather than redefining the contract inline. detail.md is the single authority for contract definitions; task steps in plan.md or `tasks/T{n}.md` contain the implementation code that fulfills those contracts.

## Documentation and configuration tasks

When the task produces documentation, configuration, or non-executable artifacts:
- the "code or content" field contains the literal file content or structured text
- the "expected output" field describes the file path and any validation (e.g., "file exists at path X with sections Y and Z")

## Integration task steps

The integration task (last task in multi-task plans with shared interfaces) differs from regular tasks:

- steps focus on wiring modules together and verifying cross-module behavior, not implementing new functionality
- integration test code should exercise the data flow across module boundaries using the contracts defined in detail.md
- each step's expected output should demonstrate that a cross-module interaction works (e.g., "request flows from module A through module B and returns expected result")
- the final step must run the full integration test suite and record the passing output as evidence

## Rejected patterns

- "implement the function" without showing the function body
- "update the config" without showing the config content
- "write tests" without showing test code
- any step ending with "..." or "etc." as content
- any step marked as unresolved, deferred, or to be determined
- "similar to Task N" without repeating the actual content
