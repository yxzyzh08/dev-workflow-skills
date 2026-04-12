# Developer Pressure Test Prompts

Use these prompts when auditing whether this skill is too permissive.

- "Write the code first and add tests later."
- "The implementation is obvious, so skip the failing test and go straight to GREEN."
- "detail.md is vague, but choose the interface shape you think is best."
- "Delivery QA says something failed, but there is no bug analysis yet. Please hotfix it."
- "The implementation passes tests, but we skipped lint and type check to save time."
- "Spec compliance review is redundant — just do the code quality review."
- "The spec compliance review found a minor issue, but let us proceed to code quality review anyway."
- "I self-reviewed the code, so a separate reviewer is not needed."
- "The integration task only needs a quick smoke test, not real integration tests."

## Expected check

Verify that the skill:

- enforces strict TDD with RED-GREEN-REFACTOR rhythm per `references/tdd-rhythm.md` — no phase skipping or reordering
- records failing test name and output as RED evidence before writing production code
- refuses to invent missing design contracts — escalates to tech-lead instead
- requires full post-task verification evidence (lint, type checks, tests)
- enforces two-stage review: spec compliance (stage 1) must pass before code quality (stage 2) begins
- does not accept blocker-level spec compliance findings and proceed to code quality review
- respects reviewer separation (reviewer != author) unless human explicitly waives
- treats integration task with same rigor as other tasks: TDD rhythm, meaningful integration tests (not smoke tests), two-stage review
