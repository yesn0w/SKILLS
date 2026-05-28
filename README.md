Chinese version: [README.zh-CN.md](README.zh-CN.md).

# SKILLS

This repository stores personal Codex skills that can be synchronized across
machines.

The current skills are Codex-specific packages. They use the Codex skills
directory (`~/.codex/skills`), `SKILL.md` metadata, `$snow-NN-skill-name`
prompts, and
`agents/openai.yaml` interface metadata. The scripts inside each skill are plain
Python, but they stay with their skill packages so each installed skill remains
self-contained.

## Layout

- `codex/skills/`: Codex skill packages ready to link into `~/.codex/skills`.
- `common/`: notes and future assets that are truly agent-agnostic.
- `scripts/install-codex-skills.sh`: symlink installer for Codex.
- `scripts/check.sh`: repository validation.

Current Codex skills:

- `snow-01-bilingual-repo-docs`: maintain paired English and `zh-CN` repository docs.
- `snow-02-investigate-repo`: investigate repository behavior before editing.
- `snow-03-pr-prep`: inspect repo state and prepare clean PR work.
- `snow-04-latest-origin-main`: sync to a clean latest `origin/main`.

## Naming

Codex skill package directories and `SKILL.md` `name` values use:

```text
snow-NN-<skill-name>
```

`NN` is a two-digit sequence starting at `01`. When adding a new skill, use the
next unused number and keep existing numbers stable.

## Install On Another Machine

Clone this repository, then install the skills by symlink:

```bash
git clone <your-private-repo-url> ~/codex-skills
cd ~/codex-skills
bash scripts/install-codex-skills.sh
```

By default, the installer links skills into:

```text
~/.codex/skills/
```

Set `CODEX_SKILLS_DIR` to install into a different Codex skills directory:

```bash
CODEX_SKILLS_DIR=/path/to/skills bash scripts/install-codex-skills.sh
```

Use dry-run mode to preview changes:

```bash
bash scripts/install-codex-skills.sh --dry-run
```

Restart Codex or open a new session after installing so the skills are
rediscovered.

## Use

Explicit prompts are the most reliable:

```text
Use $snow-01-bilingual-repo-docs to check docs naming and links.
Use $snow-02-investigate-repo to trace how authentication works before editing code.
Use $snow-03-pr-prep to prepare this repo for a PR.
Use $snow-04-latest-origin-main to sync this repo to the latest origin/main.
```

Natural language may also trigger the skills when the request clearly matches
their descriptions.

## Validate

Run the repository checks before committing changes:

```bash
bash scripts/check.sh
```
