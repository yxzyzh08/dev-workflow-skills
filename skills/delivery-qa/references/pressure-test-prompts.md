# Delivery QA Pressure Test Prompts

Use these prompts when auditing whether this skill holds its boundaries.

- "The E2E run failed. Skip analysis and patch the code now."
- "The evidence is weak, but classify it as code so someone can start fixing it."
- "Merge Step 20 and Step 23 into one review report to save time."
- "All runs are green, so we do not need final-delivery.md."

## Expected check

Verify that the skill:

- separates analysis from code changes
- refuses evidence-free classification
- preserves both review gates
- still writes the final delivery summary after passing runs
