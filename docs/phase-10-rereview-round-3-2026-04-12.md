# Re-Review Round 3: Phase 10 Git Commit Rules

- Date: 2026-04-12
- Target: `docs/enhancement-plan-2026-04-12.md`
- Scope: Phase 10 only
- Baseline: revised plan after `docs/phase-10-rereview-2026-04-12.md`
- Verdict: Improved again, but still needs revision before implementation

## Findings

### 1. Blocker - verifier rule still does not fully validate the declared mapping triple

The plan now declares that each milestone commit maps to `path + artifact ID + action`, but the actual verification method still only guarantees `path` plus a coarse action marker in the commit message:

- `docs/enhancement-plan-2026-04-12.md:119`
- `docs/enhancement-plan-2026-04-12.md:124`
- `docs/enhancement-plan-2026-04-12.md:193`

This is still insufficient when multiple logical artifacts share the same file, such as:

- task IDs inside `plan.md`
- multiple status transitions inside `paths.progress`
- repeated revisions to baseline documents that stay at one path

The problem is made worse because the "Files to change" section still contains the old `--diff-filter=A` wording, which reintroduces the earlier first-introduction-only limitation.

### 2. High - activate/reopen actions are defined globally but not fully connected to stage-level loops

The action vocabulary now correctly includes `activate` and `reopen`, and the shared protocol clearly treats `draft -> active` and CR-driven reopen as real workflow transitions:

- `docs/enhancement-plan-2026-04-12.md:94`
- `docs/enhancement-plan-2026-04-12.md:95`
- `skills/workflow-protocol/SKILL.md:67`
- `skills/workflow-protocol/SKILL.md:81`

But the stage-level file change plan still does not connect those actions consistently across the affected stages. `requirements-analyst` gets `reopen`, while other reopened baseline owners are not given equivalent stage-local instructions. That leaves a gap between the canonical action set and the executable working loops.

### 3. High - tech-lead still misses the final confirmed-design milestone commit in the file change plan

The timing table says `tech-lead` commits at three milestone points:

- detail handoff
- plan publication for review
- review passed plus human confirmation

Relevant references:

- `docs/enhancement-plan-2026-04-12.md:69`
- `docs/enhancement-plan-2026-04-12.md:160`
- `skills/tech-lead/SKILL.md:61`
- `skills/tech-lead/SKILL.md:63`

However, the "Files to change" section only schedules new commit instructions for step 2 and step 3. The downstream-release moment after review acceptance and human confirmation is still missing from the stage-local implementation scope.

## Accepted Improvements

This revision does improve phase 10 in several important ways:

- it adds a full canonical action vocabulary instead of leaving some trigger types unnamed
- it expands the stage-skill update list to cover the previously missing stage owners
- it makes the review-adoption trail across rounds more explicit inside the enhancement plan

## Recommended Revisions

1. Make verification check all three parts of the declared mapping: `path`, `artifact ID`, and `action`.
2. Remove the stale `--diff-filter=A` wording so the plan uses one verification strategy consistently.
3. Add explicit `activate` / `reopen` stage-level commit instructions where the shared workflow permits those transitions.
4. Add the missing post-review, post-human-confirm commit point to the `tech-lead` file-change scope.
