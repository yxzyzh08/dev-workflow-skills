# Skill Validation Checklist

Use this checklist after creating or revising a workflow skill.

## Structure

- file path is `skills/{skill-name}/SKILL.md`
- `name` uses the frozen `kebab-case` skill ID
- `description` starts with `Use when ...`
- top-level title exists
- no unresolved placeholders

## Language policy

- `check-language-policy.sh` passes on the revised scope whenever `SKILL.md`, `references/`, or `templates/` changed
- Chinese in `SKILL.md` is limited to approved `description:` trigger wording
- Chinese in `references/` is limited to prompt bullets inside `references/pressure-test-prompts.md`
- library-facing narrative, checklist text, and template skeletons remain English-first

## Protocol linkage

- first operational step references `skills/workflow-protocol/SKILL.md`
- skill also references repository-root `workflow-project.yaml`
- skill references the progress dashboard at `paths.progress` and uses the shared progress update rules from `workflow-protocol`
- shared protocol rules are referenced instead of copied in full

## Discoverability

- cold-start prompt rendered
- only `### Available skills` inspected
- target skill is `FOUND`
- high-frequency skills were checked against at least one Chinese smoke prompt for repo-default collaboration

## Behavior readiness

- at least one pressure-test prompt reviewed
- obvious overlap with neighboring skills checked
- Chinese trigger wording or equivalent keyword coverage was reviewed where the skill is likely to be triggered in Chinese
- validation report written to `docs/dev-workflow-skills/reviews/`

## Decoupling

- repository-root `workflow-project.yaml` exists
- skill reads config before project docs
- `check-project-config.py workflow-project.yaml` passes, or the alternate configured adapter file passes when testing a non-default setup
- incremental decoupling checks may scope `check-hardcoded-paths.sh` to the revised skill files or directories
- final regression runs `check-hardcoded-paths.sh` with no args across the full `skills/` tree
- no hardcoded project-private paths remain in the scoped revised targets during incremental work, and none remain under `skills/` during final regression
- no hardcoded project identity or raw-workflow filename remains unless explicitly routed via `sources.*`
- use `scripts/run-skill-library-regression.sh` for the final regression to verify structure, language policy, project-config, hardcoded paths, and optional discovery coverage in one step
