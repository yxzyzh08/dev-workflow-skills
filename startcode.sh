#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
USER_HOME="${HOME:-}"

mkdir -p "$ROOT_DIR/.codex" "$ROOT_DIR/.agents/skills"

if [ -n "$USER_HOME" ] && [ "$USER_HOME" != "$ROOT_DIR" ]; then
  if [ ! -e "$ROOT_DIR/.codex/auth.json" ] && [ -e "$USER_HOME/.codex/auth.json" ]; then
    ln -s "$USER_HOME/.codex/auth.json" "$ROOT_DIR/.codex/auth.json"
  fi

  if [ ! -e "$ROOT_DIR/.codex/config.toml" ] && [ -e "$USER_HOME/.codex/config.toml" ]; then
    ln -s "$USER_HOME/.codex/config.toml" "$ROOT_DIR/.codex/config.toml"
  fi
fi

export HOME="$ROOT_DIR"
export CODEX_HOME="$ROOT_DIR/.codex"

exec codex \
  --enable multi_agent \
  --dangerously-bypass-approvals-and-sandbox \
  "$@"
