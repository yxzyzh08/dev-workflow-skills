# TDD Rhythm

Use this file to enforce the RED-GREEN-REFACTOR cycle during implementation.

## The Iron Law

No production code is written except to make a failing test pass. No refactoring changes behavior. Every cycle completes all three phases.

## The Cycle

### RED: Write a failing test

- Write exactly one test that expresses the next intended behavior
- Run the test and confirm it fails
- The failure message must relate to the behavior under test, not a syntax error or import problem
- Record the failing test name and output as evidence

### GREEN: Make it pass with minimum code

- Write the smallest amount of production code that makes the failing test pass
- Do not add behavior beyond what the test requires
- Do not refactor during this phase
- Run the full relevant test suite to confirm nothing else broke

### REFACTOR: Clean up without changing behavior

- Remove duplication, improve naming, simplify structure
- Run the full relevant test suite after refactoring — all tests must still pass
- If any test fails during refactor, revert the refactor change and try again
- This phase is optional only when the code is already clean; it is never skipped by default

## Cycle verification checklist

After each RED-GREEN-REFACTOR cycle, confirm:

- [ ] A test was written before the production code
- [ ] The test was observed failing with a behavior-relevant failure message
- [ ] The production code is the minimum needed to pass
- [ ] All tests pass after GREEN
- [ ] Refactoring (if done) did not change test outcomes
- [ ] All tests pass after REFACTOR

## Rejected rationalizations

These are not valid reasons to skip or reorder the cycle:

- "The implementation is obvious, so I will write it first" — write the test first anyway
- "I need to set up the module structure first" — structure changes are refactoring; write a failing test for the first behavior, then refactor after GREEN
- "This is just a config change" — if the config affects behavior, write a test that verifies the behavior first
- "The test framework is not set up yet" — setting up the test framework is the first task; do it before writing production code
- "I will write all tests after the implementation" — this is test-after, not TDD; it violates the iron law

## Integration with working loop

- Working loop step 2 is RED
- Working loop step 3 covers GREEN and REFACTOR
- Working loop step 4 adds regression coverage (which may trigger additional RED-GREEN-REFACTOR cycles)
- Multiple cycles per task are expected; each cycle addresses one behavior increment
