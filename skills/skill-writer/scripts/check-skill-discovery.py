#!/usr/bin/env python3
import json
import sys
from pathlib import Path


def collect_strings(node, parts):
    if isinstance(node, dict):
        for value in node.values():
            collect_strings(value, parts)
    elif isinstance(node, list):
        for value in node:
            collect_strings(value, parts)
    elif isinstance(node, str):
        parts.append(node)


def main():
    if len(sys.argv) < 3:
        print(
            "Usage: check-skill-discovery.py <prompt-input.json> <skill-name> [...]",
            file=sys.stderr,
        )
        return 2

    prompt_json = Path(sys.argv[1])
    skill_names = sys.argv[2:]

    if not prompt_json.is_file():
      print(f"Missing prompt json: {prompt_json}", file=sys.stderr)
      return 2

    obj = json.loads(prompt_json.read_text())
    parts = []
    collect_strings(obj, parts)
    text = "\n".join(parts)

    start = text.find("### Available skills")
    end = text.find("### How to use skills", start if start != -1 else 0)
    section = text[start:end] if start != -1 and end != -1 else text

    missing = []
    for skill_name in skill_names:
        found = skill_name in section
        print(f"{skill_name}: {'FOUND' if found else 'MISSING'}")
        if not found:
            missing.append(skill_name)

    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main())
