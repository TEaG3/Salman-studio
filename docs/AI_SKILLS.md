# AI skills for Frame Studio

This repository provides a shared video-editing skill for two agent environments.

## Claude Code
- Project skill: `.claude/skills/video-edit/SKILL.md`
- User install: `bash install.sh --claude`
- Claude Code can discover project skills from the repository's `.claude/skills/` directory.

## OpenAI Codex-compatible agents
- Project skill: `.agents/skills/video-edit/SKILL.md`
- User install: `bash install.sh --codex`
- Codex-compatible agent environments can discover skills from `.agents/skills/`.

## Install both
From the repository root:

```bash
bash install.sh
```

Install only into this checkout:

```bash
bash install.sh --project
```

## Important ChatGPT distinction
Adding skill files to GitHub does not automatically make them active in ordinary ChatGPT conversations. The `.agents/skills/` layout is intended for Codex-compatible agent environments that support Agent Skills. In ChatGPT, attach or provide the skill instructions in the environment/workflow that supports them.

The skill does not enable editing features that the app itself has not implemented. The current MVP stores trim points as metadata; actual rendering/export remains a later milestone.
