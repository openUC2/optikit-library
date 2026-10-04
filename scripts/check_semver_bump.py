"""CI gate: a changed library record must bump its version.

Compares every ``library/**/{component,template,module}.yml`` against a git
ref (default ``origin/main``): if a record's content changed but its ``version``
did not, fail. New files and deletions are fine.

Run:  uv run python scripts/check_semver_bump.py [--base origin/main]
"""

from __future__ import annotations

import argparse
import io
import subprocess
import sys
from pathlib import Path

from ruamel.yaml import YAML

from optikit_core.library.build import RECORD_FILES

# Operate on the current working directory's repo (so the check runs in any
# checkout, and is testable against a throwaway repo).
REPO = Path.cwd()
_YAML = YAML(typ="safe")


def _load_yaml(text: str) -> dict:
    try:
        return _YAML.load(io.StringIO(text)) or {}
    except Exception:  # noqa: BLE001 — malformed record is not our concern here
        return {}


def _git(*args: str) -> str | None:
    result = subprocess.run(
        ["git", *args], cwd=REPO, capture_output=True, text=True, check=False
    )
    return result.stdout if result.returncode == 0 else None


def _version_at(ref: str, rel: str) -> str | None:
    content = _git("show", f"{ref}:{rel}")
    if content is None:
        return None
    return _load_yaml(content).get("version")


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--base", default="origin/main")
    args = parser.parse_args(argv)

    if _git("rev-parse", args.base) is None:
        print(f"base ref {args.base} not available — skipping semver-bump check")
        return 0

    library = REPO / "library"
    violations: list[str] = []
    for file in library.rglob("*.yml"):
        if file.name not in RECORD_FILES or "dist" in file.parts:
            continue
        rel = str(file.relative_to(REPO))
        old_version = _version_at(args.base, rel)
        if old_version is None:
            continue  # new record
        diff = _git("diff", "--quiet", args.base, "--", rel)
        changed = diff is None  # `git diff --quiet` exits non-zero on change
        new_version = _load_yaml(file.read_text()).get("version")
        if changed and new_version == old_version:
            violations.append(f"{rel}: changed but version stayed {old_version}")

    for v in violations:
        print(f"ERR {v}", file=sys.stderr)
    if violations:
        print(
            f"\n{len(violations)} record(s) changed without a version bump.",
            file=sys.stderr,
        )
        return 1
    print("semver-bump check passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
