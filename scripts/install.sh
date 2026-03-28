#!/usr/bin/env bash
set -euo pipefail

# install.sh — set up ai-upskiller skills and the bwclaude launcher.
#
# Usage:
#   bash scripts/install.sh
#
# What it does:
#   1. Symlinks each directory under skills/ into ~/.claude/skills/
#   2. Symlinks scripts/bubblewrap_claude.sh to ~/.local/bin/bwclaude
#
# Existing symlinks are skipped (re-running is safe).

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

mkdir -p "$SKILLS_DIR"

for skill_dir in "$REPO_DIR"/skills/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"

  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Skipping $skill_name (already exists at $target)"
  else
    ln -s "$skill_dir" "$target"
    echo "Installed $skill_name → $target"
  fi
done

# Install bwclaude launcher to ~/.local/bin
BIN_DIR="$HOME/.local/bin"
WRAPPER_SRC="$REPO_DIR/scripts/bubblewrap_claude.sh"
WRAPPER_DST="$BIN_DIR/bwclaude"

mkdir -p "$BIN_DIR"
chmod +x "$WRAPPER_SRC"

if [ -e "$WRAPPER_DST" ] || [ -L "$WRAPPER_DST" ]; then
  echo "Skipping bwclaude (already exists at $WRAPPER_DST)"
else
  ln -s "$WRAPPER_SRC" "$WRAPPER_DST"
  echo "Installed bwclaude → $WRAPPER_DST"
fi
