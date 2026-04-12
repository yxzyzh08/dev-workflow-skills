#!/usr/bin/env bash
set -euo pipefail

if ! command -v git >/dev/null 2>&1; then
  echo "missing git" >&2
  exit 2
fi

if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "not inside a git repository" >&2
  exit 2
fi

repo_root=$(git rev-parse --show-toplevel)
current_branch=$(git rev-parse --abbrev-ref HEAD)
worktree_dir="$repo_root/.worktree"

printf 'repo_root: %s\n' "$repo_root"
printf 'current_branch: %s\n' "$current_branch"

if [ -d "$worktree_dir" ]; then
  printf '.worktree: present\n'
else
  printf '.worktree: missing (can be created when needed)\n'
fi

printf 'worktrees:\n'
git worktree list
