# Systematic Debugger Debug Loop And Evidence

Use this file while narrowing a failure.

## Loop

1. state the expected behavior and the actual behavior
2. form one testable hypothesis
3. run the smallest experiment that can confirm or exclude it
4. record what the evidence changed
5. repeat with a narrower scope until the root cause is defensible

## Evidence sources

- failing command output
- logs and stack traces
- reproduction steps
- design or architecture comparisons
- screenshots or captured observations when relevant

## Anti-patterns

- proposing a fix before the hypothesis is tested
- running many unrelated experiments at once
- skipping the evidence log because the cause "seems obvious"
