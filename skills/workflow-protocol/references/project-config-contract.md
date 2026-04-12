# Project Config Contract

Every workflow skill must read repository-root `workflow-project.yaml` before entering stage-specific work. The config file is the only adapter layer that defines project identity, logical paths, and fact sources.

## Required keys

The following keys must be present and non-empty because workflow skills depend on them for routing and validation:

- `project.name`: display name only; do not use it for control flow.
- `paths.progress`: progress dashboard — slim, current-state-only navigation document.
- `paths.progress_history`: append-only progress log for audit trail.
- `paths.requirements`: current release requirements baseline (updated on release switch; must match `project.current_release`).
- `paths.acceptance`: cumulative acceptance baseline.
- `paths.architecture`: cumulative architecture baseline.
- `paths.changes_dir`: Change Request directory.
- `paths.change_template`: Change Request body template.
- `paths.releases_dir`: root directory for release-scoped outputs.
- `project.current_release`: active release identifier (e.g., `r1`). Single source of truth — `paths.requirements` and `progress.md` `current_release` must be consistent with this value.

## Recommended keys

- `project.default_language`: default collaboration language such as `zh-CN`.
- `sources.product_prd`: product-level fact source.
- `sources.raw_workflow`: project-level raw workflow description.
- `sources.skill_design_spec`: workflow-skill design source.
- `workflow.use_change_request`: whether CR handling is enabled.
- `workflow.use_progress_tracking`: whether the project maintains a progress tracker.
- `workflow.default_doc_language`: default language for generated project documents.

## Path reference rules

1. Skills may reference only logical keys such as `paths.progress`; do not hardcode fixed repository paths in rules or checks.
2. Release-scoped outputs must be rooted in `paths.releases_dir`, for example `<from paths.releases_dir>/r{n}/design/plan.md`.
3. Change Request operations must read both `paths.changes_dir` and `paths.change_template`. If work needs a child path outside the obvious default, derive it from config rather than inventing a literal path.
4. Fact sources must be referenced through `sources.*`. Concrete repository paths may appear only as examples and must not be hardcoded into skill text or scripts.

## Missing config or path behavior

- If repository-root `workflow-project.yaml` is missing, no workflow skill should proceed into stage work. `workflow-router` should treat the repository as not yet adapted and tell the human to create the config first.
- All required `paths.*` keys must exist, but the referenced files or directories may still be absent because creation depends on project progress. A declared logical key is valid even before the artifact exists.
- If the file referenced by `paths.progress` is missing or unreadable, treat the repository as being in initialization. `workflow-router` should tell the human to initialize that document or provide a replacement navigation artifact before continuing the mainline flow.
- If `paths.progress_history` is missing, the first skill that changes workflow state should create it. Its absence does not block routing or stage work.
- For stage baselines such as `paths.requirements`, `paths.acceptance`, and `paths.architecture`, missing files block only when the current skill truly depends on them. If the current stage has not created that baseline yet, the skill may mark it as not yet prepared and route the human to produce it first.
- If a `sources.*` entry is missing, the skill should judge whether it is a weak dependency or a hard dependency. Weak dependencies may be skipped temporarily; hard dependencies must be restored before execution.
- If `paths.releases_dir` exists only in config but the directory tree has not been created yet, the responsible skill may initialize it when needed and must not assume it already exists.
- If `project.current_release`, `paths.requirements`, and `progress.md` `current_release` are inconsistent, the skill must stop and warn the human. `project.current_release` is the single source of truth; the other two must be corrected to match.

## Uniqueness of the adapter layer

- Each project has exactly one `workflow-project.yaml`; it is the single adapter layer between the skill library and the project.
- Do not add extra project-coupled path or naming declarations under `skills/`.
- When a skill references a logical path, name the matching config key so later validation and review can trace the rule back to config.

This contract applies both to the current repository and to future projects that adopt the skill library. Project documentation or onboarding material should repeat this expectation so the library remains config-driven over time.
