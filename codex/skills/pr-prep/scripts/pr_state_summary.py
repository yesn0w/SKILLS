#!/usr/bin/env python3
"""Print a read-only PR preparation snapshot for a git repository."""

from __future__ import annotations

import argparse
from pathlib import Path
import subprocess
import sys


def run_git(root: Path, *args: str) -> tuple[int, str]:
    """Run a git command and return exit code plus combined output."""
    proc = subprocess.run(
        ["git", *args],
        cwd=root,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        check=False,
    )
    return proc.returncode, proc.stdout.strip()


def print_section(title: str, body: str) -> None:
    """Print a titled output section."""
    print(f"## {title}")
    print(body or "(none)")
    print()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", type=Path)
    args = parser.parse_args()

    root = args.root.resolve()
    code, inside = run_git(root, "rev-parse", "--is-inside-work-tree")
    if code != 0 or inside != "true":
        print(f"Not a git repository: {root}", file=sys.stderr)
        return 1

    commands = [
        ("Branch", ("branch", "--show-current")),
        ("Status", ("status", "--short", "--branch")),
        ("Tracked Changes", ("diff", "--name-status")),
        ("Untracked Files", ("ls-files", "--others", "--exclude-standard")),
        ("Remotes", ("remote", "-v")),
        ("Latest Commit", ("log", "--oneline", "--decorate", "--max-count=1")),
    ]

    for title, git_args in commands:
        code, output = run_git(root, *git_args)
        if code != 0:
            print_section(title, f"git {' '.join(git_args)} failed:\n{output}")
        else:
            print_section(title, output)

    return 0


if __name__ == "__main__":
    sys.exit(main())
