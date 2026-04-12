#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <skill-dir-or-skill-file> [...]" >&2
  exit 2
fi

status=0

for target in "$@"; do
  if [ -d "$target" ]; then
    file="$target/SKILL.md"
  else
    file="$target"
  fi

  echo "== $file =="

  if [ ! -f "$file" ]; then
    echo "MISSING_FILE"
    status=1
    continue
  fi

  if rg -n "TODO|TBD|待补|待定" "$file" >/dev/null; then
    echo "PLACEHOLDER_FAIL"
    rg -n "TODO|TBD|待补|待定" "$file"
    status=1
  else
    echo "placeholder: ok"
  fi

  for pattern in '^---$' '^name: ' '^description: Use when' '^# '; do
    if rg -n "$pattern" "$file" >/dev/null; then
      echo "pattern ok: $pattern"
    else
      echo "pattern missing: $pattern"
      status=1
    fi
  done

  echo
done

exit "$status"
