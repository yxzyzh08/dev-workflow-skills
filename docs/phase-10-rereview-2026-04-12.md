# Re-Review: Phase 10 Git Commit Rules

- Date: 2026-04-12
- Target: `docs/enhancement-plan-2026-04-12.md`
- Scope: Phase 10 only
- Baseline: revised plan after `docs/phase-10-review-2026-04-12.md`
- Verdict: Improved, but still needs revision before implementation

## Findings

### 1. Blocker - artifact-to-commit verification rule still cannot prove milestone commits

The revised plan introduces a stronger mapping concept at `path + artifact ID + stage action`, but the actual verification method still falls back to checking whether the file was ever added to git:

- `docs/enhancement-plan-2026-04-12.md:91`
- `docs/enhancement-plan-2026-04-12.md:96`
- `docs/enhancement-plan-2026-04-12.md:142`

`git log --diff-filter=A -- {path}` only proves that a path was first introduced. It does not prove that later milestone commits happened for actions such as:

- `publish`
- `freeze`
- `verify`
- `review`

That gap is especially serious for artifacts that are intentionally revised multiple times in place, such as:

- `paths.requirements`
- `paths.architecture`
- `detail.md`
- `plan.md`
- `paths.progress`

As written, completion-verifier would still be unable to distinguish "file exists in history" from "required milestone commit happened".

### 2. High - commit trigger taxonomy and action taxonomy are still misaligned

The trigger definition now correctly narrows commits to release-relevant moments, but the allowed actions in the message format do not cover all mandatory trigger types:

- trigger definitions: `docs/enhancement-plan-2026-04-12.md:44`
- all-skills rules: `docs/enhancement-plan-2026-04-12.md:66`
- action schema: `docs/enhancement-plan-2026-04-12.md:75`

Examples of required triggers that do not map cleanly onto the declared action set `publish / freeze / verify / review`:

- `draft -> active`
- `frozen -> active (CR)`
- CR creation
- progress dashboard state change

If those actions remain unnamed or informal, the verifier, pressure tests, and future commit examples cannot consistently audit them.

### 3. High - file change scope still does not cover all stages named in the timing table

The revised timing table now defines commit behavior for most workflow stages:

- `docs/enhancement-plan-2026-04-12.md:57`

But the "Files to change" section still updates only a subset of the owning stage skills:

- `docs/enhancement-plan-2026-04-12.md:106`

The plan does not currently schedule direct updates for:

- `skills/requirements-analyst/SKILL.md`
- `skills/acceptance-designer/SKILL.md`
- `skills/system-architect/SKILL.md`
- `skills/test-engineer/SKILL.md`
- `skills/delivery-qa/SKILL.md`

That leaves a mismatch between the normative timing table and the executable working loops that agents will actually follow. Existing loops for those stages still do not contain phase-10-specific commit instructions:

- `skills/requirements-analyst/SKILL.md:51`
- `skills/acceptance-designer/SKILL.md:50`
- `skills/system-architect/SKILL.md:55`
- `skills/test-engineer/SKILL.md:51`
- `skills/delivery-qa/SKILL.md:57`

## Accepted Improvements

The revised phase 10 does successfully address two major problems from the prior review:

- It no longer requires commits for every write-to-disk event; it now limits commits to publish / handoff / state-change style milestones.
- It moves the developer commit point from immediate GREEN to after the complete RED-GREEN-REFACTOR cycle plus verification.

## Recommended Revisions

1. Replace `git log --diff-filter=A -- {path}` with a rule that can verify milestone commits, not just first introduction of a file.
2. Expand the action vocabulary so every mandatory trigger has a canonical action label.
3. Add the missing stage skill files to the implementation scope so the timing table is reflected in each owning working loop.
