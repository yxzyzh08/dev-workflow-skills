# Developer Output And Evidence

Use this file when implementing, fixing, or reviewing code tasks.

## Minimum delivery evidence per task

- plan task ID (and task file path if split format is used)
- relevant `detail.md` section or interface name (detail.md is the contract authority)
- TDD RED evidence: failing test name, the command used to run it, and its failure output — recorded before writing production code
- TDD GREEN evidence: passing verification commands after minimal implementation
- touched code and test paths
- spec compliance review artifact path (`spec-review-{nn}.md`, mandatory stage 1)
- code quality review artifact path (`code-review-{nn}.md`, mandatory stage 2)

## Integration task evidence

When the task is the integration task (last task in multi-task plans with shared interfaces), also record:

- integration test names and the cross-module interactions they verify
- integration test run command and passing output
- which detail.md interface contracts were exercised across module boundaries

## Bug-fix evidence

When the work comes from Delivery QA, also record:

- bug analysis ID or path
- reproduced failing scenario
- regression test that now covers the reported case
