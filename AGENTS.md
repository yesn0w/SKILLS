Chinese version: [AGENTS.zh-CN.md](AGENTS.zh-CN.md).

# Repository Instructions

This repository stores Codex skill packages.

## Structure

- Keep complete Codex skill packages under `codex/skills/snow-NN-<skill-name>/`.
- Keep only truly agent-agnostic assets under `common/`.
- Keep repository automation in `scripts/`.

## Skill Package Rules

- A Codex skill package must include `SKILL.md`.
- The skill directory name and `SKILL.md` `name` value must match
  `snow-NN-<skill-name>`.
- Use a two-digit sequence starting at `01`; new skills use the next unused
  number and keep existing numbers stable.
- Keep `agents/openai.yaml` with the skill when it provides Codex interface
  metadata.
- Keep helper scripts inside the skill package when `SKILL.md` references them
  by relative path.
- Do not move shared-looking scripts into `common/` unless the skill docs and
  installers are updated in the same change.

## Documentation Rules

- English Markdown files use unsuffixed names, for example `README.md`.
- Chinese Markdown files use the `zh-CN` suffix, for example
  `README.zh-CN.md`.
- Pair user-facing repository docs when practical.
- Add a counterpart link near the top of each paired file.
- Keep English and Chinese docs behaviorally equivalent.

## Validation

Run this before committing:

```bash
bash scripts/check.sh
```
