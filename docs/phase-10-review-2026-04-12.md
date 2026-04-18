# Review: Phase 10 Git Commit Rules

- Date: 2026-04-12
- Target: `docs/enhancement-plan-2026-04-12.md`
- Scope: Phase 10 only
- Verdict: Needs revision before implementation

## Findings

### 1. Blocker - commit trigger scope is internally inconsistent

`docs/enhancement-plan-2026-04-12.md:28` defines the core principle as committing after a "key artifact" is written, but `docs/enhancement-plan-2026-04-12.md:78` expands that into "all document artifacts produced by any skill must be committed after being written to disk".

That change is materially broader than the stated principle and conflicts with the existing workflow, where many stages explicitly draft, review, revise, and return to a human gate before the artifact becomes a stable review baseline. Examples:

- `skills/requirements-analyst/SKILL.md:53`
- `skills/system-architect/SKILL.md:56`
- `skills/tech-lead/SKILL.md:58`

If implemented as written, the rule would require commits for routine in-progress saves, not just reviewable baselines. That would overload history with low-signal checkpoints and weaken the stated goal of preserving reviewable intermediate states.

### 2. Blocker - developer commit timing conflicts with the current working loop

`docs/enhancement-plan-2026-04-12.md:42` and `docs/enhancement-plan-2026-04-12.md:83` require the developer to commit immediately after GREEN. But the current developer loop defines step 3 as GREEN plus optional REFACTOR, and step 4 then runs lint, type checks, and relevant test suites:

- `skills/developer/SKILL.md:56`
- `skills/developer/SKILL.md:57`

This means the proposed commit point can land before refactoring is complete and before the full verification gate runs. That is inconsistent with the existing implementation contract and risks preserving partially-finished states as the canonical commit checkpoints.

### 3. High - verifier rule is not operationally defined

`docs/enhancement-plan-2026-04-12.md:93` says `completion-verifier` should check that git log contains a commit corresponding to the artifact, and `docs/enhancement-plan-2026-04-12.md:97` frames commit history as supporting evidence.

The problem is that the plan does not define how "corresponding" is determined. The proposed message format in `docs/enhancement-plan-2026-04-12.md:49` is too coarse for repeated edits such as multiple revisions of `detail.md`, requirements, or review files. That makes the rule hard to verify in a concrete and reproducible way, which conflicts with the repository's current evidence standard:

- `skills/workflow-protocol/references/evidence-standards.md:7`

Without a stronger mapping rule, verification can collapse into message-pattern matching instead of real evidence checking.

### 4. High - commit preservation is not guaranteed through integration

Phase 10's background section treats commit rules as protection against artifact loss and traceability breaks:

- `docs/enhancement-plan-2026-04-12.md:26`

But the actual file-change plan only adds a pre-integration check that each worker's worktree artifacts are committed:

- `docs/enhancement-plan-2026-04-12.md:90`

Current git-manager rules require serial integration and cleanup, but they do not guarantee that worker commits remain reachable after integration:

- `skills/git-manager/SKILL.md:56`
- `skills/git-manager/references/integration-checklist.md:17`

If the integration path later uses squash, cherry-pick, or other history-rewriting-at-boundary patterns, the worker's "safety" commits may never become part of the durable shared trace. That leaves the plan short of its own stated objective.

## Assumptions

- The intended purpose of these commits is to preserve reviewable or handoff-ready states, not every intermediate file save.
- The intended traceability must remain meaningful after serial integration, not only inside a temporary worktree.

## Recommended Revisions

1. Narrow the trigger from "written to disk" to "published for review, handoff, or state change".
2. Move the developer commit point to after the complete RED-GREEN-REFACTOR cycle and step 4 verification, while still keeping review reports as separate commits.
3. Define an explicit artifact-to-commit mapping rule for verification, such as path plus artifact ID plus stage action, and specify how integration preserves those commits or records their source SHAs.
