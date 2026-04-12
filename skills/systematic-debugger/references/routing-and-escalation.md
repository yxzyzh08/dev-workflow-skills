# Systematic Debugger Routing And Escalation

Use this file when the diagnosis starts to point outside direct code debugging.

## Route by confirmed layer

- architecture gap -> `system-architect`
- design or contract gap -> `tech-lead`
- implementation defect -> `developer`
- acceptance or product ambiguity -> escalate to the human or upstream doc owner

## Escalate when

- available evidence still cannot classify the failure
- the suspected fix requires changing frozen upstream baselines
- the failure is environmental and ownership is unclear
- the requested action skips the diagnosis gate entirely
