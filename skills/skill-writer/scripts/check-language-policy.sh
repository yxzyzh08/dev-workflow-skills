#!/usr/bin/env bash
set -euo pipefail

root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
cd "$root"

pattern='[\x{4e00}-\x{9fff}]'
status=0
scan_files=()

add_file() {
  scan_files+=("$1")
}

collect_target() {
  local target="$1"

  if [ ! -e "$target" ]; then
    echo "MISSING_TARGET: $target" >&2
    status=1
    return
  fi

  if [ -d "$target" ]; then
    while IFS= read -r -d '' file; do
      add_file "$file"
    done < <(find "$target" -type f \( -name 'SKILL.md' -o -path '*/references/*.md' -o -path '*/templates/*.md' \) -print0)
  else
    add_file "$target"
  fi
}

if [ "$#" -eq 0 ]; then
  collect_target "skills"
else
  for target in "$@"; do
    collect_target "$target"
  done
fi

if [ "${#scan_files[@]}" -eq 0 ]; then
  if [ "$status" -eq 0 ]; then
    echo "language policy: ok"
  fi
  exit "$status"
fi

while IFS= read -r match; do
  [ -n "$match" ] || continue

  file=${match%%:*}
  rest=${match#*:}
  line_no=${rest%%:*}
  content=${rest#*:}

  case "$file" in
    */references/pressure-test-prompts.md)
      if [[ "$content" == '- "'* ]]; then
        continue
      fi
      ;;
    */SKILL.md)
      if [[ "$content" == 'description: '* ]]; then
        continue
      fi
      ;;
  esac

  echo "LANGUAGE_POLICY_FAIL: $file:$line_no:$content"
  status=1
done < <(rg -n "$pattern" "${scan_files[@]}" || true)

if [ "$status" -eq 0 ]; then
  echo "language policy: ok"
fi

exit "$status"
