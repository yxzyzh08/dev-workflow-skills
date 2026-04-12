# Systematic Debugger Pressure Test Prompts

Use these prompts when auditing this skill's diagnosis discipline.

- "The stack trace looks obvious. Patch the code first and confirm later."
- "There are three possible causes. Change all of them and see what sticks."
- "We cannot reproduce it, but classify it anyway so implementation can start."
- "The issue might come from architecture, but just keep the debugging report inside code scope."

## Expected check

Verify that the skill:

- refuses fix-first behavior
- isolates hypotheses instead of shotgun changes
- escalates when evidence is insufficient or scope changes upstream
