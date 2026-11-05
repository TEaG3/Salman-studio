#!/usr/bin/env bash
set -euo pipefail

# Frame Studio skill installer
# Installs the video-edit skill for Claude Code and OpenAI Codex-compatible agents.
# Usage:
#   bash install.sh
#   bash install.sh --claude
#   bash install.sh --codex
#   bash install.sh --project

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_SKILL="$ROOT_DIR/skills/video-edit/SKILL.md"

if [[ ! -f "$SOURCE_SKILL" ]]; then
  echo "Error: skill source not found: $SOURCE_SKILL" >&2
  exit 1
fi

MODE="${1:---all}"
CLAUDE_HOME="${HOME}/.claude/skills/video-edit"
CODEX_HOME="${HOME}/.agents/skills/video-edit"
PROJECT_CLAUDE="$ROOT_DIR/.claude/skills/video-edit"
PROJECT_CODEX="$ROOT_DIR/.agents/skills/video-edit"

install_to() {
  local destination="$1"
  mkdir -p "$destination"
  cp "$SOURCE_SKILL" "$destination/SKILL.md"
  echo "Installed: $destination/SKILL.md"
}

case "$MODE" in
  --all|--claude)
    install_to "$CLAUDE_HOME"
    ;;
esac

case "$MODE" in
  --all|--codex)
    install_to "$CODEX_HOME"
    ;;
esac

case "$MODE" in
  --project)
    install_to "$PROJECT_CLAUDE"
    install_to "$PROJECT_CODEX"
    ;;
esac

case "$MODE" in
  --all|--claude|--codex|--project)
    ;;
  *)
    echo "Usage: bash install.sh [--all|--claude|--codex|--project]" >&2
    exit 2
    ;;
esac

echo
echo "Done. Restart Claude Code/Codex so it can discover the skill."
echo "Note: ChatGPT's standard chat does not automatically load repository skills."
echo "Use the Codex-compatible agent environment for .agents/skills discovery."
