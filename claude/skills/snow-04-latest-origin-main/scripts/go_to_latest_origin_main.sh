#!/usr/bin/env bash
set -euo pipefail

remote="origin"
branch="main"
remote_ref="refs/remotes/${remote}/${branch}"
stash_created=0
stash_ref=""
stash_message=""

fail() {
  printf 'ERROR: %s\n' "$*" >&2
  exit 1
}

print_stash_restore() {
  if [[ "$stash_created" -eq 1 ]]; then
    printf 'Stashed local changes: yes\n'
    printf 'Stash: %s\n' "$stash_ref"
    printf 'Stash message: %s\n' "$stash_message"
    printf 'Restore command: git stash pop %s\n' "$stash_ref"
  fi
}

on_error() {
  local status=$?
  local command=${BASH_COMMAND}

  printf 'ERROR: command failed with exit %s: %s\n' "$status" "$command" >&2
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'Current branch: %s\n' "$(current_branch)" >&2
    printf 'Status:\n' >&2
    git status --short --branch >&2 || true
  fi
  print_stash_restore >&2
  printf 'No destructive cleanup was performed. Resolve the issue, then rerun this script.\n' >&2
  exit "$status"
}

command_failed() {
  local status=$1
  shift

  printf 'ERROR: command failed with exit %s:' "$status" >&2
  printf ' %q' "$@" >&2
  printf '\n' >&2
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'Current branch: %s\n' "$(current_branch)" >&2
    printf 'Status:\n' >&2
    git status --short --branch >&2 || true
  fi
  print_stash_restore >&2
  printf 'No destructive cleanup was performed. Resolve the issue, then rerun this script.\n' >&2
  exit "$status"
}

run() {
  printf '+'
  printf ' %q' "$@"
  printf '\n'
  "$@" || command_failed "$?" "$@"
}

git_dir_file() {
  git rev-parse --git-path "$1"
}

stop_if_interrupted_operation() {
  local path

  path=$(git_dir_file MERGE_HEAD)
  if [[ -e "$path" ]]; then
    fail "unfinished merge detected at ${path}; resolve or abort it before syncing main."
  fi

  path=$(git_dir_file rebase-merge)
  if [[ -e "$path" ]]; then
    fail "unfinished rebase detected at ${path}; resolve or abort it before syncing main."
  fi

  path=$(git_dir_file rebase-apply)
  if [[ -e "$path" ]]; then
    fail "unfinished rebase or am detected at ${path}; resolve or abort it before syncing main."
  fi

  path=$(git_dir_file CHERRY_PICK_HEAD)
  if [[ -e "$path" ]]; then
    fail "unfinished cherry-pick detected at ${path}; resolve or abort it before syncing main."
  fi

  path=$(git_dir_file REVERT_HEAD)
  if [[ -e "$path" ]]; then
    fail "unfinished revert detected at ${path}; resolve or abort it before syncing main."
  fi
}

current_branch() {
  git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD
}

repo_root=$(git rev-parse --show-toplevel 2>/dev/null) || fail "current directory is not inside a Git worktree."
cd "$repo_root"
trap on_error ERR

original_branch=$(current_branch)
printf 'Repository: %s\n' "$repo_root"
printf 'Original branch: %s\n' "$original_branch"
printf 'Initial status:\n'
git status --short --branch

stop_if_interrupted_operation

if ! git remote get-url "$remote" >/dev/null 2>&1; then
  fail "remote '${remote}' is not configured."
fi

run git fetch "$remote" --prune

if ! git rev-parse --verify --quiet "$remote_ref" >/dev/null; then
  fail "${remote}/${branch} does not exist after fetching."
fi

if [[ -n "$(git status --porcelain)" ]]; then
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  stash_message="snow-04-latest-origin-main: ${original_branch} ${timestamp}"
  run git stash push -u -m "$stash_message"
  stash_created=1
  stash_ref=$(git stash list --format='%gd' -n 1)
  printf 'Created stash: %s (%s)\n' "$stash_ref" "$stash_message"
else
  printf 'No local changes to stash.\n'
fi

if git show-ref --verify --quiet "refs/heads/${branch}"; then
  run git switch "$branch"
else
  run git switch --track -c "$branch" "${remote}/${branch}"
fi

run git merge --ff-only "${remote}/${branch}"

head_sha=$(git rev-parse HEAD)
remote_sha=$(git rev-parse "$remote_ref")
final_status=$(git status --porcelain)

if [[ "$head_sha" != "$remote_sha" ]]; then
  fail "HEAD (${head_sha}) does not match ${remote}/${branch} (${remote_sha}) after fast-forward."
fi

if [[ -n "$final_status" ]]; then
  printf '%s\n' "$final_status" >&2
  fail "worktree is not clean after syncing ${remote}/${branch}."
fi

printf '\nDone.\n'
printf 'Final branch: %s\n' "$(current_branch)"
printf 'Final commit: %s\n' "$head_sha"
printf 'HEAD matches %s/%s: yes\n' "$remote" "$branch"

if [[ "$stash_created" -eq 1 ]]; then
  print_stash_restore
else
  printf 'Stashed local changes: no\n'
fi
