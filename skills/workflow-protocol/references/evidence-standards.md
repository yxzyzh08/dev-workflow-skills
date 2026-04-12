# Evidence Standards Reference

Use this file when a skill needs to determine what constitutes sufficient evidence for verification, review, or diagnosis.

## Principle

Evidence must be **current, concrete, and reproducible**. Narrative assertions ("I checked and it works") are never sufficient. Every claim must point to an artifact, command output, or document state that another reviewer can independently verify.

## Evidence by Stage

### Requirements Stage (Steps 1-3)

| Claim | Minimum Evidence |
| --- | --- |
| Requirements baseline complete | Document exists at `paths.requirements` with valid frontmatter, all required sections present |
| Review passed | `req-review-{nn}.md` exists with `pass` conclusion |
| Human alignment confirmed | Review report records human confirmation |

### Acceptance Stage (Steps 4-6)

| Claim | Minimum Evidence |
| --- | --- |
| Acceptance baseline complete | Document exists at `paths.acceptance` with valid frontmatter, traceability to requirement IDs |
| Tool-checkability met | Each acceptance item has executable verification action and determinable pass criteria |
| Review passed | `acc-review-{nn}.md` exists with `pass` conclusion |

### Architecture Stage (Steps 7-9)

| Claim | Minimum Evidence |
| --- | --- |
| Architecture baseline complete | Document exists at `paths.architecture` with `stable` status, covers all 5 dimensions |
| Review passed | `arch-review-{nn}.md` exists with `pass` conclusion |
| Impact analysis done | Impact analysis document exists when architecture changed from review or Delivery QA |

### Design Stage (Steps 10-12)

| Claim | Minimum Evidence |
| --- | --- |
| Plan complete | `plan.md` exists with task IDs, dependencies, output locations |
| Plan tasks decomposed | Every task has step-level decomposition with action, code/content, and expected output per step; steps are inline in `plan.md` (single-file) or in `tasks/T{n}.md` (split format); no step contains unresolved or deferred content |
| Detail complete | `detail.md` exists with field-level interface and data model definitions, no unresolved placeholders |
| Review passed | `design-review-{nn}.md` exists with `pass` conclusion |

### Implementation Stage (Steps 13-15)

| Claim | Minimum Evidence |
| --- | --- |
| Task implemented | Code exists at output location declared in `plan.md` |
| TDD cycle followed | Each code change has a recorded RED (failing test) → GREEN (minimal pass) → REFACTOR sequence; failing test name/output recorded before implementation |
| Tests pass | Command output from test run showing zero failures (not a narrative claim) |
| Lint and type checks pass | Command output from lint and type-check runs showing zero errors |
| Design conformance | Implementation matches `detail.md` contracts |
| Spec compliance review passed | `spec-review-{nn}.md` exists with `pass` verdict confirming implementation matches plan.md task scope and detail.md contracts |
| Code quality review passed | `code-review-{nn}.md` exists with `pass` verdict citing reviewed modules/files |
| Integration verified | For multi-task plans with shared interfaces: integration task exists with passing integration test command output verifying cross-module data flow. For multi-task plans with fully independent tasks: integration task exists or plan.md contains explicit exemption reason. Single-task plans: not required. |
| Parallel worker reviews | When tasks ran in parallel: each worker has independent `spec-review-{nn}.md` and `code-review-{nn}.md` with pass verdict; parallel execution does not waive review gates |

### Testing Stage (Steps 16-18)

| Claim | Minimum Evidence |
| --- | --- |
| E2E plan complete | `e2e-plan.md` exists with coverage mapping to acceptance items |
| E2E suite runnable | Command output showing suite executes (pass or fail) |
| Review passed | `e2e-review-{nn}.md` exists with `pass` conclusion |

### Delivery Stage (Steps 19-26)

| Claim | Minimum Evidence |
| --- | --- |
| E2E execution recorded | `run-{date}.md` exists with execution evidence |
| Bug classified | `bug-{nn}.md` exists with evidence-backed root cause and routing |
| Fix plan reviewed | `fix-review-{nn}.md` exists with `pass` conclusion |
| All E2E pass | Final `run-{date}.md` shows all acceptance items passing |
| Delivery complete | `final-delivery.md` exists summarizing cross-run outcome |

## Evidence for Diagnosis (systematic-debugger)

| Claim | Minimum Evidence |
| --- | --- |
| Root cause identified | Written bug analysis with: failing case, reproduction steps, hypothesis, experiment results, confirmed root cause |
| Evidence trail | Each hypothesis round records what was confirmed or excluded |
| Routing justified | Root cause maps to specific layer (architecture/design/code) with cited evidence |

## What Does NOT Count as Evidence

- "I reviewed the code and it looks fine" — must cite specific files/modules
- "Tests pass" without command output — must show actual command and result
- "The document is complete" without checking required sections — must verify each section exists
- Progress dashboard showing `frozen` — dashboard is bookkeeping, not proof; verify actual document `status`
- Prior conversation claims — evidence must be current and re-verifiable
