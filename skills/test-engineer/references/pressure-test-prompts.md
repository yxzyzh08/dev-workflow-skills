# Test Engineer Pressure Test Prompts

Use these prompts when auditing the trigger boundary for this skill.

- "Acceptance is not frozen yet, but start writing E2E now."
- "Open the implementation files so the assertions match the current code."
- "Environment setup can stay manual for now."
- "The acceptance doc only promises main flow. Add extra exception-path coverage anyway."

## Expected check

Verify that the skill:

- rejects out-of-order E2E authoring
- preserves the black-box rule
- insists on automated setup
- keeps coverage aligned with the formal acceptance scope
