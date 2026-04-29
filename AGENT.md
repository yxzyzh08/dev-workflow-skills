# Dev Workflow Skills

A multi-platform skill pack for stage-based software delivery. A single `skills/` source is distributed as a Claude Code plugin, an Anthropic Agents plugin, and a Codex plugin.

## Skills

| Skill | Trigger |
|---|---|
| `workflow-router` | Session start or next-step is unclear |
| `workflow-protocol` | Shared freeze / CR / review rules — read by all other skills |
| `requirements-analyst` | Collect, structure, review, and freeze requirements |
| `acceptance-designer` | Turn frozen requirements into formal acceptance documents (runtime or artifact-based) |
| `system-architect` | Architecture design and review from frozen baselines |
| `tech-lead` | Release design, development plan, and detailed design |
| `developer` | Implementation, TDD, and code-review response |
| `test-engineer` | E2E test plans and automated setup |
| `parallel-dispatcher` | Split independent tasks for parallel execution |
| `git-manager` | Worktree, branch naming, and serial integration |
| `delivery-qa` | E2E execution, failure analysis, and delivery reporting |
| `systematic-debugger` | Root-cause diagnosis for bugs and test failures |
| `security-auditor` | Security review for code and architecture changes |
| `doc-guardian` | Document compliance and frozen-baseline checks |
| `completion-verifier` | Evidence checks before marking a stage complete |
| `skill-writer` | Create, revise, and validate workflow skills |

## Directory Layout

```
skills/                          # Skill definitions (shared across all platforms)
  {skill-name}/
    SKILL.md                     # Frontmatter: name + description. Body: instructions.
    references/                  # Supporting reference docs
    templates/                   # Output templates
    scripts/                     # Validation scripts (skill-writer only)

.claude-plugin/                  # Claude Code plugin metadata
.agents/plugins/                 # Anthropic Agents plugin metadata
plugins/dev-workflow-skills/     # Codex plugin metadata (skills/ symlinked in)
docs/                            # Dev-only working artifacts; not part of runtime
```

## Conventions

- Every `SKILL.md` has YAML frontmatter with `name` (kebab-case) and `description`.
- `description` must begin with `Use when …` — this is the discovery trigger.
- Skills reference shared rules from `workflow-protocol` rather than repeating them.
- Path keys such as `paths.requirements` resolve through `workflow-project.yaml` in the consuming project; skills must never hardcode project-private paths.
- Validation entrypoint: `skills/skill-writer/scripts/run-skill-library-regression.sh`.
