#!/usr/bin/env bash
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"

structure_targets=()
hardcoded_targets=()
project_config="workflow-project.yaml"
discovery_prompt=""
discovery_skills=()

usage() {
  cat <<'EOF'
Usage: run-skill-library-regression.sh [options]

Options:
  --skills <path>          add <path> to the structure and language checks (repeatable; default: skills/)
  --hardcoded-scope <path> scope the hardcoded-path scan to <path> (repeatable; default: full skills/ tree)
  --project-config <path>  config file passed to check-project-config.py (default: workflow-project.yaml)
  --discovery-prompt <json> prompt json used for discoverability probing (requires --discovery-skill)
  --discovery-skill <name>  skill id to check inside the discovery prompt (repeatable)
  -h, --help               print this help text and exit
EOF
  exit 2
}

add_structure_target() {
  local target="$1"
  if [ -z "$target" ]; then
    echo "--skills requires a path" >&2
    usage
  fi
  structure_targets+=("$target")
}

add_hardcoded_target() {
  local target="$1"
  if [ -z "$target" ]; then
    echo "--hardcoded-scope requires a path" >&2
    usage
  fi
  hardcoded_targets+=("$target")
}

set_project_config() {
  local target="$1"
  if [ -z "$target" ]; then
    echo "--project-config requires a path" >&2
    usage
  fi
  project_config="$target"
}

parse_args() {
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --skills)
        shift
        add_structure_target "$1"
        ;;
      --hardcoded-scope)
        shift
        add_hardcoded_target "$1"
        ;;
      --project-config)
        shift
        set_project_config "$1"
        ;;
      --discovery-prompt)
        shift
        discovery_prompt="$1"
        ;;
      --discovery-skill)
        shift
        discovery_skills+=("$1")
        ;;
      -h|--help)
        usage
        ;;
      *)
        echo "Unknown option: $1" >&2
        usage
        ;;
    esac
    shift
  done
}

parse_args "$@"

if [ "${#structure_targets[@]}" -eq 0 ]; then
  structure_targets=("skills")
fi

resolved_structure_targets=()
for target in "${structure_targets[@]}"; do
  if [ -d "$target" ]; then
    if [ -f "$target/SKILL.md" ]; then
      resolved_structure_targets+=("$target")
    else
      while IFS= read -r -d '' skill_file; do
        resolved_structure_targets+=("$(dirname "$skill_file")")
      done < <(find "$target" -type f -name 'SKILL.md' -print0)
    fi
  else
    resolved_structure_targets+=("$target")
  fi
done

if [ "${#resolved_structure_targets[@]}" -eq 0 ]; then
  echo "No structure targets resolved from: ${structure_targets[*]}" >&2
  exit 1
fi

echo "Running structure check on: ${resolved_structure_targets[*]}"
skills/skill-writer/scripts/check-skill-structure.sh "${resolved_structure_targets[@]}"

echo "Running language policy check on: ${structure_targets[*]}"
skills/skill-writer/scripts/check-language-policy.sh "${structure_targets[@]}"

if [ -f "$project_config" ]; then
  echo "Running project-config check on: $project_config"
  skills/skill-writer/scripts/check-project-config.py "$project_config"
else
  echo "Skipping project-config check: $project_config not found (expected in target projects, not the skill library itself)"
fi

if [ "${#hardcoded_targets[@]}" -gt 0 ]; then
  echo "Running hardcoded-path scan on: ${hardcoded_targets[*]}"
  skills/skill-writer/scripts/check-hardcoded-paths.sh "${hardcoded_targets[@]}"
else
  echo "Running hardcoded-path scan on full skills tree"
  skills/skill-writer/scripts/check-hardcoded-paths.sh
fi

if [ "${#discovery_skills[@]}" -gt 0 ]; then
  if [ -z "$discovery_prompt" ]; then
    echo "--discovery-skill requires --discovery-prompt" >&2
    usage
  fi
  if [ ! -f "$discovery_prompt" ]; then
    echo "Discovery prompt JSON not found: $discovery_prompt" >&2
    exit 2
  fi
  echo "Running discovery check with $discovery_prompt for: ${discovery_skills[*]}"
  skills/skill-writer/scripts/check-skill-discovery.py "$discovery_prompt" "${discovery_skills[@]}"
fi
