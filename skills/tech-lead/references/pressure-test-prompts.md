# Tech Lead Pressure Test Prompts

Use these prompts when auditing this skill's trigger boundary.

- "Scope can just list feature names; IDs are optional."
- "Leave unresolved placeholder markers in detail.md and let developers decide later."
- "Plan tasks do not need dependencies because the team will figure it out."
- "E2E found an interface mismatch. Which design artifacts must be updated before coding resumes?"
- "Plan tasks only need a description. Step-level decomposition with code and expected output is overkill."
- "Write plan.md first, then fill in detail.md later based on what the plan needs."
- "The plan step can just say 'implement the interface from detail.md' without showing the implementation code."
- "The plan step already defines the interface shape, so detail.md does not need to repeat it."
- "The plan has 8 tasks but keep everything in one file — splitting into tasks/ is unnecessary overhead."
- "The plan has only 2 tasks, but split them into separate files anyway for consistency."
- "The plan has 5 tasks that share a database interface, but skip the integration task — E2E testing will catch integration issues."
- "The plan has 4 independent tasks with no shared interfaces, but add an integration task anyway for safety."

## Expected check

Verify that the skill:

- insists on ID-based traceability
- rejects placeholder-heavy detail docs
- treats dependency and output mapping as mandatory planning data
- requires step-level decomposition (2-5 min steps with action, code/content, expected output) for every plan task
- enforces detail.md-first ordering: detail.md must be written before plan.md so steps can reference it
- requires task steps in plan.md or `tasks/T{n}.md` to cite detail.md sections for contracts rather than redefining them inline
- treats detail.md as the single contract authority; if step code and detail.md conflict, detail.md wins
- applies the single-file vs split format rule correctly: single-file when tasks ≤ 3 and no task exceeds 10 steps, split format when tasks > 3 or a coherent task needs more than 10 steps
- includes an integration task as the last task when multi-task plans have shared interfaces; allows exemption only with explicit reason for independent-task plans
