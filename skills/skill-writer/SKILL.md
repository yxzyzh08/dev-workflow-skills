---
name: skill-writer
description: Use when creating a new workflow skill, revising an existing skill, or validating whether a skill can be discovered and followed correctly
---

# Skill Writer

## Overview
This skill owns creation, revision, and validation of repository workflow skills. It turns the frozen workflow-skill design into `skills/{skill-name}/SKILL.md`, keeps each skill slim and protocol-linked, validates cold-start discoverability, and pressure-tests ambiguous boundaries before the skill is treated as ready.

## Support Files

Use these support assets instead of repeating the same validation steps by hand:

- `references/validation-checklist.md`
- `references/pressure-test-prompts.md`
- `scripts/check-skill-structure.sh`
- `scripts/check-language-policy.sh`
- `scripts/check-skill-discovery.py`
- `scripts/check-project-config.py`
- `scripts/check-hardcoded-paths.sh`
- `scripts/run-skill-library-regression.sh`

For discovery checks, run a fresh-session cold-start probe in the target CLI tool (e.g., start a new session and ask a simple question), then use `scripts/check-skill-discovery.py` to verify the skill appears in the available skills list.

## First Step
Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`, then read the progress dashboard at `paths.progress` before creating, revising, or validating any workflow skill.

## When to Use
Use this skill when the human wants to:

- create a new workflow skill under `skills/`
- revise an existing workflow skill to match updated design rules
- verify that a new or changed skill can be discovered in a fresh session
- review a skill for ambiguity, trigger quality, protocol duplication, or boundary leaks

Do not use this skill to execute the workflow stage itself. Use the owning stage or cross-cutting skill for real requirement, design, coding, testing, or delivery work.

## Inputs

- relevant sections from the configured skill design spec in `sources.skill_design_spec`
- `skills/workflow-protocol/SKILL.md`
- target skill path(s) under `skills/`
- existing skill files, validation reports, and progress state when revising
- human decisions about naming, scope, and trigger boundaries

## Outputs

- `skills/{skill-name}/SKILL.md`
- skill validation or review reports under `docs/dev-workflow-skills/reviews/`
- synchronized updates to progress artifacts (dashboard + history per `workflow-protocol`) once validation passes

## Working Loop

1. Read the frozen design spec for the target skill and extract the trigger, responsibilities, inputs/outputs, and non-negotiable rules.
2. Draft or revise `skills/{skill-name}/SKILL.md` with a discovery-oriented frontmatter description and a slim body that starts by routing the reader through `workflow-protocol`, `workflow-project.yaml`, and the progress dashboard at `paths.progress`.
3. Check that the skill contains only stage-specific or skill-specific behavior. Shared workflow rules stay in `workflow-protocol` and should be referenced rather than repeated.
4. Run structure validation on the skill file with `scripts/check-skill-structure.sh` and the checklist in `references/validation-checklist.md`.
5. Run `scripts/check-language-policy.sh` whenever the revised scope touches `SKILL.md`, `references/`, or `templates/`. The default allowlist permits Chinese only on `description:` trigger lines and in `references/pressure-test-prompts.md`.
6. Run a fresh-session discovery check in the target CLI tool, then use `scripts/check-skill-discovery.py` to inspect the available skills list and confirm the skill is discoverable.
7. Pressure-test the skill wording against the prompts in `references/pressure-test-prompts.md`; for this repository, include Chinese smoke prompts for high-frequency skills so repo-default collaboration language is covered.
8. Run decoupling validations (`scripts/check-project-config.py` and `scripts/check-hardcoded-paths.sh`) when skill changes could reintroduce project coupling. During incremental implementation, scope the hardcoded-path scan to the revised skill file or directory. During final regression, run the no-argument full-library scan across `skills/`.

   Use `scripts/run-skill-library-regression.sh` as the single entrypoint for structure, language policy, project-config, hardcoded-path, and optional discovery checks; pass `--skills` to narrow scope, `--hardcoded-scope` to limit decoupling scans, `--project-config` to validate a non-default adapter file, or `--discovery-prompt/--discovery-skill` to run discovery probes when you have a prompt template.
9. Write the validation report, then update progress artifacts per `workflow-protocol` (dashboard + history) only after the discovery and ambiguity checks are complete.

## Skill Authoring Rules

- Store every workflow skill at `skills/{skill-name}/SKILL.md`; do not place workflow skills outside the `skills/` tree.
- The skill ID in frontmatter must use the frozen `kebab-case` name from the design spec.
- The `description` field must start with `Use when ...` and describe only triggering conditions, not the workflow steps the skill will execute.
- In this repository, high-frequency skills should include enough Chinese trigger wording or nearby keyword coverage to remain discoverable in default Chinese collaboration.
- Keep library-facing narrative, reference prose, checklist text, and template skeletons English-first. Chinese is allowed only for discoverability trigger coverage and Chinese smoke prompts unless a future language policy expands the allowlist.
- The first operational instruction inside the skill must send the reader to `skills/workflow-protocol/SKILL.md`, then to `workflow-project.yaml`, then to the progress dashboard at `paths.progress`.
- Inputs and outputs must use logical keys (for example, `paths.progress`, `paths.requirements`) or explicitly state that they resolve through `workflow-project.yaml`; do not hardcode project-private paths.
- Each skill should explicitly state its own inputs, outputs, working loop, and stage-specific rules, but should not restate protocol-wide freeze, CR, or review conventions in full.
- If a skill changes because of a reopened frozen baseline, route the document change through the approved CR path before treating the updated skill as valid.

## Validation Rules

- New or revised skills are not complete until a fresh-session discovery check confirms they appear in `### Available skills`.
- Discovery validation must inspect the `Available skills` section only; do not count matching strings that appear elsewhere in prompts, `AGENTS.md`, or repository text.
- Structure validation must at least check frontmatter presence, `Use when ...` description quality, top-level title, and absence of unresolved placeholders.
- Language policy validation is required whenever the revised scope touches `SKILL.md`, `references/`, or `templates/`. Default allowlisted Chinese is limited to `description:` trigger wording in `SKILL.md` and Chinese prompt bullets in `references/pressure-test-prompts.md`.
- Pressure tests should probe ambiguous edges such as overlapping skill ownership, overly broad triggers, or protocol duplication. Use `references/pressure-test-prompts.md` as the default baseline and tighten the wording if the skill could be mis-invoked or skipped.
- For this repository, behavior validation should include Chinese smoke prompts whenever the skill is likely to be triggered by Chinese task wording.
- Decoupling validation must confirm `workflow-project.yaml` structure, and a hardcoded-path scan must pass before declaring skill work complete. Use a scoped scan for the revised skill paths during incremental decoupling tasks, then run the no-argument full-library scan during final regression.
- `scripts/run-skill-library-regression.sh` is the preferred final-regression entrypoint because it chains structure, language policy, project-config, hardcoded-path, and optional discovery validation in one command.
- Validation results belong in a written review report under `docs/dev-workflow-skills/reviews/`; completion is not claimed only in chat.

## Completion Checklist

- `skills/{skill-name}/SKILL.md` exists at the correct path and uses the frozen skill ID.
- The skill starts by referencing `workflow-protocol`, `workflow-project.yaml`, and the progress dashboard at `paths.progress`.
- Inputs and outputs use logical keys or explicit config resolution; no hardcoded project-private paths remain.
- Incremental decoupling work used a scoped hardcoded-path scan for the revised skill paths, and final regression uses the no-argument full-library scan across `skills/`.
- Shared protocol rules are referenced rather than duplicated unnecessarily.
- Structure checks pass through `scripts/check-skill-structure.sh`: no unresolved placeholders, valid frontmatter, and clear stage-specific sections.
- `scripts/check-language-policy.sh` passes on the revised scope whenever `SKILL.md`, `references/`, or `templates/` changed.
- Fresh-session discovery validation confirms the skill is present in `Available skills`.
- Chinese smoke prompts were reviewed when the skill is expected to serve default Chinese collaboration.
- A written validation report exists under `docs/dev-workflow-skills/reviews/`.
- Progress artifacts reflect the validated state of the skill per `workflow-protocol` (dashboard + history).
