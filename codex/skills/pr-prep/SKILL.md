---
name: pr-prep
description: Prepare repository work for a pull request. Use when Codex is asked to inspect git state, separate unrelated changes, create or verify a branch, stage only relevant files, run validation, commit with a conventional message, push to origin, create a draft PR when possible, or provide copy-ready PR title and description.
---

# PR Prep

## Principles

- Inspect before mutating. Start with branch, status, changed files, untracked files, and remotes.
- Never revert or overwrite unrelated user changes. If unrelated changes exist, leave them unstaged or ask before including them.
- Follow the repo’s own instructions first, especially `AGENTS.md`, PR templates, branch naming, commit message rules, and validation commands.
- Stage explicit paths. Avoid broad `git add .` unless the repo state is already proven clean and all changes are in scope.
- Prefer one focused commit unless the user asks for multiple commits or the changes are clearly independent.
- Do not amend, squash, force-push, or rewrite history unless the user explicitly asks.
- Do not include secrets, downloaded files, generated build outputs, vendored dependencies, or local runtime artifacts unless intentionally part of the PR.

## Workflow

1. Inspect state:
   - `git status --short --branch`
   - `git diff --name-status`
   - `git ls-files --others --exclude-standard`
   - `git remote -v`
   - read `AGENTS.md` or equivalent if present.
2. Choose or verify branch:
   - use repo convention when present.
   - otherwise use `<type>/<short-kebab-summary>`, with `feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `perf`, or `ci`.
3. Validate before commit:
   - run repo-specific checks first.
   - attempt requested license/copyright hooks if available.
   - run focused tests and `git diff --check`.
4. Stage only relevant paths and confirm:
   - `git diff --cached --name-status`
   - ensure `git diff --name-status` has no leftover in-scope changes.
5. Commit:
   - use Conventional Commit style, for example `feat: add fund metric calculation workflow`.
6. Push:
   - `git push -u origin <branch>`.
7. PR:
   - if `gh` is installed and authenticated, create a draft PR unless the user asks otherwise.
   - if PR creation is blocked, provide the GitHub compare/new PR link.
   - provide copy-ready PR title and description.

## Reporting Format

Report:

- Branch and commit hash.
- Files changed.
- Whether unrelated changes were found.
- Exact validation commands and pass/fail result.
- Push result.
- PR URL or compare/new PR link.
- Copy-ready PR title and body.

When the user asks for another language, include a localized PR title/body too.

## Script

Use `scripts/pr_state_summary.py` for a concise state snapshot:

```bash
python ~/.codex/skills/pr-prep/scripts/pr_state_summary.py .
```

The script is read-only and prints branch, status, remotes, tracked changes, untracked files, and the latest commit.
