---
name: snow-04-latest-origin-main
description: Sync a Git repo to clean latest origin/main. Use when asked for latest origin main, a clean main, or to prepare for new work.
---

# Latest Origin Main

Use this skill when the user wants to prepare a repository for a new question or development task by moving to a clean, up-to-date `origin/main`.

## Safety Rules

- Inspect before changing state: branch, status, remotes, and interrupted Git operations.
- Automatically stash uncommitted tracked and untracked changes with `git stash push -u`; do not stash ignored files.
- Never discard work: do not use `git reset --hard`, `git clean`, force push, rebase, or history rewriting.
- Only update `main` with `git merge --ff-only origin/main`.
- Stop if `main` and `origin/main` have diverged, if Git has an unfinished merge/rebase/cherry-pick/revert, or if `origin/main` cannot be verified.
- Do not create a new development branch unless the user separately asks for it.

## Workflow

1. Confirm the current directory is inside a Git worktree:
   - `git rev-parse --show-toplevel`
   - `git status --short --branch`
2. Stop if there is an interrupted Git operation:
   - merge: `.git/MERGE_HEAD`
   - rebase: `.git/rebase-merge` or `.git/rebase-apply`
   - cherry-pick: `.git/CHERRY_PICK_HEAD`
   - revert: `.git/REVERT_HEAD`
3. Fetch `origin` and prune stale refs:
   - `git fetch origin --prune`
4. Verify `origin/main` exists:
   - `git rev-parse --verify refs/remotes/origin/main`
5. If the worktree has changes, stash them:
   - message format: `snow-04-latest-origin-main: <branch> <timestamp>`
   - include untracked files with `-u`
6. Switch to local `main`:
   - if `main` exists, `git switch main`
   - otherwise create it from `origin/main` with `git switch --track -c main origin/main`
7. Fast-forward local `main`:
   - `git merge --ff-only origin/main`
8. Verify completion:
   - `git rev-parse HEAD`
   - `git rev-parse refs/remotes/origin/main`
   - `git status --short`
   - stop if `HEAD` differs from `origin/main` or the worktree is not clean.

## Script

Prefer the bundled script for consistency:

```bash
bash ${CLAUDE_SKILL_DIR}/scripts/go_to_latest_origin_main.sh
```

The script operates on the current repository and prints the original branch, resulting branch, resulting commit, whether a stash was created, and recovery instructions.

## Reporting

Report:

- Original branch and final branch.
- Whether local changes were stashed.
- Stash reference and message, if created.
- Final `main` commit hash.
- Whether `HEAD` matches `origin/main`.
- Any failure reason and the safest next step.

If a stash was created, include the exact restore command, for example:

```bash
git stash pop stash@{0}
```
