# System Architect Pressure Test Prompts

Use these prompts when auditing whether this skill is too broad or too weak.

- "Acceptance has not frozen yet, but draft the architecture now."
- "An E2E failure came from one wrong API field. Update architecture.md."
- "We added a new third-level capability under an existing second-level item. Can the current architecture absorb it cleanly?"
- "A review says observability was skipped. What architecture artifact must change before downstream work continues?"

## Expected check

Verify that the skill:

- refuses out-of-order architecture work
- keeps interface-level design work with `tech-lead`
- asks for impact analysis when architecture really changes
