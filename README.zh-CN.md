英文版本：[README.md](README.md)。

# SKILLS

这个仓库保存个人 Codex skills，用于在多台电脑之间同步。

当前 skills 都是 Codex 专属包。它们依赖 Codex skills 目录
（`~/.codex/skills`）、`SKILL.md` 元数据、`$skill-name` 触发方式，以及
`agents/openai.yaml` 界面元数据。每个 skill 内的脚本本身是普通 Python，
但会保留在对应 skill 包中，让安装后的 skill 保持自包含。

## 目录结构

- `codex/skills/`：可链接到 `~/.codex/skills` 的 Codex skill 包。
- `common/`：说明和未来真正跨 Agent 的通用资产。
- `scripts/install-codex-skills.sh`：Codex 软链接安装脚本。
- `scripts/check.sh`：仓库校验脚本。

当前 Codex skills：

- `bilingual-repo-docs`：维护英文和 `zh-CN` 仓库文档配对。
- `investigate-repo`：改代码前调查仓库行为和相关证据。
- `pr-prep`：检查仓库状态并准备干净的 PR 工作流。

## 在其他电脑安装

先 clone 这个仓库，再用软链接安装 skills：

```bash
git clone <your-private-repo-url> ~/codex-skills
cd ~/codex-skills
bash scripts/install-codex-skills.sh
```

默认安装目标是：

```text
~/.codex/skills/
```

如果要安装到其他 Codex skills 目录，可以设置 `CODEX_SKILLS_DIR`：

```bash
CODEX_SKILLS_DIR=/path/to/skills bash scripts/install-codex-skills.sh
```

可以用 dry-run 模式预览改动：

```bash
bash scripts/install-codex-skills.sh --dry-run
```

安装后重启 Codex 或开启新会话，让 Codex 重新发现 skills。

## 使用方式

显式触发最可靠：

```text
Use $bilingual-repo-docs to check docs naming and links.
Use $investigate-repo to trace how authentication works before editing code.
Use $pr-prep to prepare this repo for a PR.
```

当自然语言请求清楚匹配 skill 描述时，也可能自动触发。

## 校验

提交修改前运行仓库检查：

```bash
bash scripts/check.sh
```
