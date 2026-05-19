#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
repo_root=$(cd "$script_dir/.." && pwd -P)
python_bin="${PYTHON:-python3}"

cd "$repo_root"

"$python_bin" codex/skills/bilingual-repo-docs/scripts/check_bilingual_docs.py .
"$python_bin" codex/skills/pr-prep/scripts/pr_state_summary.py .
git diff --check
