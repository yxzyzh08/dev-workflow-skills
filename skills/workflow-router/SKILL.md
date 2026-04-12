---
name: workflow-router
description: Use when a session starts, the human asks 下一步/该用哪个 skill, or workflow ownership for the next step is unclear
---

# Workflow Router

## Overview

Workflow Router is a navigation-only skill. It reads the live workflow state, accounts for open CRs, shows the panorama of done / current / next, and recommends the next owning skill without executing the stage work itself.

## Support Files

Use these support assets when the route is not obvious:

- `references/stage-recommendation-table.md`
- `references/cr-and-warning-rules.md`
- `references/pressure-test-prompts.md` (for skill audits or revisions)

## First Step

Read `skills/workflow-protocol/SKILL.md`, then read repository-root `workflow-project.yaml`.

- If the config file is missing, treat the repository as not yet adapted to the workflow library. Route to configuration/bootstrap guidance before any stage work.
- If the config exists but the progress dashboard at `paths.progress` does not resolve to a real file, treat the repository as uninitialized. Use `references/stage-recommendation-table.md` for the startup route and recommend `requirements-analyst` plus progress bootstrap instead of assuming an active stage.

## When to Use

Use this skill when:

- a session starts and the human asks what to do next
- the human is unsure which workflow skill should own the current request
- CR state may override the normal mainline route
- the human appears to be jumping ahead and needs a workflow warning first

Do not use this skill to execute requirement, design, coding, testing, or QA work.

## Inputs

- human intent or blocker description
- repository-root `workflow-project.yaml` when it exists; its absence is an adaptation signal
- the progress dashboard from `paths.progress` when it exists; otherwise the absence is itself an initialization signal (do not read `paths.progress_history` for routing)
- CR documents under `<from paths.changes_dir>` when present
- shared workflow rules from `workflow-protocol`

## Outputs

- a short navigation summary with done / current / next
- the recommended next skill or skill combination
- adaptation guidance when `workflow-project.yaml` does not exist yet
- initialization guidance when the progress dashboard does not exist yet
- any CR override or out-of-order warning that affects the route
- a reminder that the router itself does not perform the stage work

## Working Loop

1. Read repository-root `workflow-project.yaml`. If missing, mark the repository as not yet adapted and route to configuration/bootstrap guidance.
2. If config exists, check whether the progress dashboard at `paths.progress` exists. If it does, build the workflow panorama from the dashboard and repository reality; if it does not, mark the repository as uninitialized and recommend `requirements-analyst` plus creation of the initial requirement and progress baselines.
3. Apply `references/stage-recommendation-table.md` to identify the default owning skill.
4. Apply `references/cr-and-warning-rules.md` to override that path when CR state or out-of-order intent matters.
5. Report the recommendation, warnings, adaptation or initialization guidance when needed, and the limits of router ownership clearly.

## Routing Rules

- Apply the CR precedence and return-path rules from `references/cr-and-warning-rules.md` instead of restating protocol details locally.
- Out-of-order requests trigger warnings, but the human still decides whether to proceed.
- If `workflow-project.yaml` is missing, say so explicitly and recommend configuration/bootstrap work before stage execution.
- If the progress dashboard is incomplete, inconsistent, or missing, say so explicitly and recommend invoking `doc-guardian` to repair or initialize it. Router must not modify the progress dashboard itself — its ownership is strictly navigation-only.

## Release Routing

- Read `project.current_release` from `workflow-project.yaml` to determine the active release.
- When the human wants to start a new release, prompt them to run the release switch procedure (update `project.current_release` in `workflow-project.yaml`, create the new release directory under `paths.releases_dir`, and reset the progress dashboard for the new release).
- If `project.current_release` in the config and the release shown in the progress dashboard disagree, warn the human about the mismatch before recommending a next step. Do not silently pick one side.

## Completion Checklist

- `workflow-protocol` was read.
- `workflow-project.yaml` was read when present, or its absence was handled as an adaptation case.
- The progress dashboard was read when present, or its absence was handled as an initialization case.
- The human sees done / current / next, not just a raw skill name.
- CR overrides and out-of-order warnings were surfaced when relevant.
- The next recommended skill is explicit.
- Router ownership stayed limited to navigation.
