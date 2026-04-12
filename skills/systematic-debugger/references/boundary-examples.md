# Systematic Debugger Boundary Examples

Use these examples when the request is close to another ownership boundary.

- Use `systematic-debugger`: a bug, failing test, or anomalous behavior needs evidence-first diagnosis before anyone chooses a fix.
- Do not use `systematic-debugger`: Delivery QA has already completed the root-cause classification and the next step is implementation.
- Do not use `systematic-debugger`: the request is to review whether a finished architecture or design artifact is complete; use the owning stage or `completion-verifier`.
- Do not use `systematic-debugger`: the human is asking to change requirements rather than diagnose a failure.
