#!/usr/bin/env bash
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"
skill_root="skills"
script_path="skills/skill-writer/scripts/check-hardcoded-paths.sh"

if [ ! -d "$skill_root" ]; then
  echo "MISSING_SKILLS_DIR: $skill_root" >&2
  exit 1
fi

# Allowed references: workflow-project.yaml and placeholders like <from paths.*>.
# This scan only flags known project-private names/paths.
patterns=(
  "Persona Agents Platform 5"
  "docs/workflow/progress.md"
  "docs/requirements/requirements.md"
  "docs/acceptance/acceptance.md"
  "docs/architecture/architecture.md"
  "docs/changes/cr-template.md"
  "docs/changes"
  "docs/releases/"
  "docs/requirements/product-prd.md"
  "human_report_v1.md"
  "human_report.md"
  "docs/superpowers/specs/2026-04-11-workflow-skills-design.md"
)

status=0
scan_targets=()

if [ "$#" -eq 0 ]; then
  scan_targets=("$skill_root")
else
  for target in "$@"; do
    rel_target="$target"
    case "$target" in
      "$root"/*)
        rel_target="${target#"$root"/}"
        ;;
    esac

    if [ ! -e "$rel_target" ]; then
      echo "MISSING_TARGET: $target" >&2
      status=1
      continue
    fi

    if [ "$rel_target" = "$script_path" ]; then
      continue
    fi

    scan_targets+=("$rel_target")
  done
fi

if [ "${#scan_targets[@]}" -eq 0 ]; then
  if [ "$status" -eq 0 ]; then
    echo "hardcoded paths: ok"
  fi
  exit "$status"
fi

for pattern in "${patterns[@]}"; do
  matches=$(rg -n --fixed-strings --glob "!$script_path" "$pattern" "${scan_targets[@]}" || true)
  if [ -n "$matches" ]; then
    echo "HARD_CODED_MATCH: $pattern"
    echo "$matches"
    status=1
  fi
done

if [ "$status" -eq 0 ]; then
  echo "hardcoded paths: ok"
fi

exit "$status"
