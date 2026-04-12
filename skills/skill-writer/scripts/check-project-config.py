#!/usr/bin/env python3
import sys
import re
from pathlib import Path

def _strip_comment(line: str) -> str:
    if "#" not in line:
        return line
    return line.split("#", 1)[0]

def _is_top_level(line: str) -> bool:
    return line and not line.startswith(" ") and not line.startswith("\t")

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: check-project-config.py <workflow-project.yaml>", file=sys.stderr)
        return 2

    path = Path(sys.argv[1])
    if not path.is_file():
        print(f"MISSING_FILE: {path}", file=sys.stderr)
        return 1

    required_top = {"project", "paths", "sources", "workflow"}
    required_paths = {
        "progress",
        "requirements",
        "acceptance",
        "architecture",
        "changes_dir",
        "change_template",
        "releases_dir",
    }
    required_project = {
        "current_release",
    }

    top_keys = set()
    path_keys = set()
    project_keys = set()
    path_values = {}
    project_values = {}
    in_paths = False
    in_project = False

    for raw in path.read_text(encoding="utf-8").splitlines():
        line = _strip_comment(raw).rstrip()
        if not line:
            continue

        if _is_top_level(line):
            key = line.split(":", 1)[0].strip()
            if key:
                top_keys.add(key)
            in_paths = key == "paths"
            in_project = key == "project"
            continue

        stripped = line.lstrip(" \t")
        if ":" in stripped:
            key = stripped.split(":", 1)[0].strip()
            val = stripped.split(":", 1)[1].strip()
            if in_paths and key:
                path_keys.add(key)
                path_values[key] = val
            if in_project and key:
                project_keys.add(key)
                project_values[key] = val

    missing_top = sorted(required_top - top_keys)
    missing_paths = sorted(required_paths - path_keys)
    missing_project = sorted(required_project - project_keys)

    if missing_top:
        print("MISSING_TOP_LEVEL_BLOCKS: " + ", ".join(missing_top), file=sys.stderr)
    if missing_paths:
        print("MISSING_PATH_KEYS: " + ", ".join(missing_paths), file=sys.stderr)
    if missing_project:
        print("MISSING_PROJECT_KEYS: " + ", ".join(missing_project), file=sys.stderr)

    if missing_top or missing_paths or missing_project:
        return 1

    # --- Consistency checks ---
    warnings = []
    current_release = project_values.get("current_release", "").strip().strip('"').strip("'")

    if current_release and "requirements" in path_values:
        req_path = path_values["requirements"].strip().strip('"').strip("'")
        if current_release not in req_path:
            warnings.append(
                f"CONSISTENCY_WARNING: paths.requirements ({req_path}) "
                f"does not contain current_release ID ({current_release})"
            )

    if current_release and "progress" in path_values:
        progress_file = Path(path.parent, "..", "..",
                             path_values["progress"].strip().strip('"').strip("'")).resolve()
        # Also try resolving relative to repo root (parent of workflow-project.yaml)
        if not progress_file.is_file():
            progress_file = path.parent / path_values["progress"].strip().strip('"').strip("'")
        if progress_file.is_file():
            content = progress_file.read_text(encoding="utf-8")
            # Parse YAML frontmatter between --- delimiters
            fm_match = re.match(r"^---\s*\n(.*?)\n---", content, re.DOTALL)
            if fm_match:
                for fm_line in fm_match.group(1).splitlines():
                    fm_stripped = fm_line.strip()
                    if fm_stripped.startswith("current_release"):
                        parts = fm_stripped.split(":", 1)
                        if len(parts) == 2:
                            progress_release = parts[1].strip().strip('"').strip("'")
                            if progress_release != current_release:
                                warnings.append(
                                    f"CONSISTENCY_WARNING: progress frontmatter current_release "
                                    f"({progress_release}) != project.current_release ({current_release})"
                                )

    for w in warnings:
        print(w, file=sys.stderr)

    print("project config: ok")
    return 0


if __name__ == "__main__":
    sys.exit(main())
