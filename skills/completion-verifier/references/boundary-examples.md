# Completion Verifier Boundary Examples

Use these examples before taking ownership of a completion claim.

- Use `completion-verifier`: someone is about to claim a stage, document transition, or integration batch is complete and needs evidence first.
- Do not use `completion-verifier`: the missing work itself still needs to be done; route back to the owning stage skill.
- Do not use `completion-verifier`: the request is to change progress optimistically before verification finishes.
- Do not use `completion-verifier`: a failing command or missing artifact is being treated as a minor note instead of a blocker.
