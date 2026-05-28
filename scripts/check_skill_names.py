#!/usr/bin/env python3
"""Validate Codex skill package names."""

from __future__ import annotations

import re
import sys
from pathlib import Path


NAME_RE = re.compile(r"^snow-(\d{2})-[a-z0-9]+(?:-[a-z0-9]+)*$")


def read_skill_name(skill_file: Path) -> str | None:
    in_frontmatter = False
    for line in skill_file.read_text(encoding="utf-8").splitlines():
        if line == "---":
            if not in_frontmatter:
                in_frontmatter = True
                continue
            break
        if in_frontmatter and line.startswith("name:"):
            return line.removeprefix("name:").strip()
    return None


def main() -> int:
    repo_root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path.cwd()
    skills_dir = repo_root / "codex" / "skills"

    if not skills_dir.is_dir():
        print(f"Missing skills directory: {skills_dir}", file=sys.stderr)
        return 1

    failures: list[str] = []
    numbers: list[int] = []

    for skill_dir in sorted(path for path in skills_dir.iterdir() if path.is_dir()):
        match = NAME_RE.fullmatch(skill_dir.name)
        if not match:
            failures.append(
                f"{skill_dir.relative_to(repo_root)} must match snow-NN-<skill-name>"
            )
            continue

        number = int(match.group(1))
        numbers.append(number)

        skill_file = skill_dir / "SKILL.md"
        if not skill_file.is_file():
            failures.append(f"{skill_dir.relative_to(repo_root)} is missing SKILL.md")
            continue

        skill_name = read_skill_name(skill_file)
        if skill_name != skill_dir.name:
            failures.append(
                f"{skill_file.relative_to(repo_root)} name must be {skill_dir.name}"
            )

    expected = list(range(1, len(numbers) + 1))
    if sorted(numbers) != expected:
        expected_text = ", ".join(f"{number:02d}" for number in expected)
        actual_text = ", ".join(f"{number:02d}" for number in sorted(numbers))
        failures.append(
            f"Skill numbers must be contiguous: expected {expected_text}; got {actual_text}"
        )

    if failures:
        print("Skill name check failed:", file=sys.stderr)
        for failure in failures:
            print(f"- {failure}", file=sys.stderr)
        return 1

    print("Skill name check passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
