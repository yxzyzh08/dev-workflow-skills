---
title: "Review Report: Acceptance Designer AI-Readable Restructure Plan"
type: review
created: 2026-04-17 12:08
target: "docs/acceptance-designer-plan-2026-04-17.md"
reviewer: codex
---

# Review Report: Acceptance Designer AI-Readable Restructure Plan

## Conclusion

not pass

## Review Scope

- Target document: `docs/acceptance-designer-plan-2026-04-17.md`
- Comparison baseline:
  - `skills/acceptance-designer/SKILL.md`
  - `skills/acceptance-designer/references/output-artifacts.md`
  - `skills/acceptance-designer/references/boundary-examples.md`
  - `../persona-agents-platform5/docs/acceptance/acceptance.md`
- Focus areas:
  - internal consistency of the proposed acceptance structure
  - whether the structure is actually tool-checkable
  - whether the structure can express current core acceptance cases without regression

## Findings

1. [blocker] The proposed observation vocabulary is internally inconsistent with the strict template examples.

   The plan declares the `Expected` observation types to be exhaustive at `docs/acceptance-designer-plan-2026-04-17.md:166`, but the example template immediately uses assertions that do not fit that vocabulary:

   - `TUI connects without error` at `docs/acceptance-designer-plan-2026-04-17.md:126`
   - `TUI reconnects at address B` at `docs/acceptance-designer-plan-2026-04-17.md:141`
   - `No unexpected error entries appear` at `docs/acceptance-designer-plan-2026-04-17.md:145`

   None of those are currently defined as allowed exit-code, stdout/stderr, file, field, log-regex, process, or socket observations. The open-question note at `docs/acceptance-designer-plan-2026-04-17.md:249` also acknowledges that the log assertion remains narrative. As written, authors and reviewers will not be able to apply the rule consistently, and the template itself teaches non-compliant patterns.

2. [blocker] The independence goal conflicts with the State Catalog design, which still uses shared global state.

   The plan treats case independence and arbitrary execution order as core goals at `docs/acceptance-designer-plan-2026-04-17.md:43` and `docs/acceptance-designer-plan-2026-04-17.md:182`. However, the State Catalog examples are built around one shared environment:

   - `~/.platform5/` as a fixed global location at `docs/acceptance-designer-plan-2026-04-17.md:65`
   - `rm -rf ~/.platform5` and `pkill -f 'platform '` at `docs/acceptance-designer-plan-2026-04-17.md:68`
   - fixed template and project identifiers `T1` / `P1` at `docs/acceptance-designer-plan-2026-04-17.md:80`
   - `platform template register ... && platform project create ...` against that same shared state at `docs/acceptance-designer-plan-2026-04-17.md:84`

   Two cases running in parallel would race on the same home directory, socket, process set, template name, and project name. One case could erase or kill another case's environment. The current proposal therefore does not actually satisfy the stated independence rule unless it first defines per-case isolation or explicitly narrows execution to serialized runs.

3. [blocker] The strict case template cannot express a core existing acceptance scenario with branching and unbounded loops.

   The plan requires every case to use a linear numbered `Steps` structure at `docs/acceptance-designer-plan-2026-04-17.md:108`, while also rejecting a DSL or pseudocode layer at `docs/acceptance-designer-plan-2026-04-17.md:52`. It further says that genuine sequences should remain a single case at `docs/acceptance-designer-plan-2026-04-17.md:187`.

   That structure is not rich enough for the current platform5 closed-loop workflow acceptance case at `../persona-agents-platform5/docs/acceptance/acceptance.md:121`, which explicitly depends on:

   - pass / not_pass branching
   - review-driven return loops
   - loop counts that are not predetermined
   - human gates that advance only after the correct upstream artifacts exist

   Under the proposed template, that case cannot be represented faithfully without falling back to narrative prose or splitting it into interdependent cases. Either outcome would undercut the plan's goals of mechanical executability and case independence.

## Overall Judgment

The restructuring direction is promising and does address real problems in the current acceptance shape, especially bundled actions and weak per-step observability. However, the current plan is not yet implementation-ready because its core rules still conflict with each other and it cannot yet represent one of the acceptance suite's most important workflow cases.

Next step: revise the plan to (1) make the observation vocabulary fully self-consistent, (2) define an isolation model that makes case independence real, and (3) add a first-class way to express branching and bounded or unbounded review loops without falling back to narrative-only wording.
