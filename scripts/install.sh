#!/usr/bin/env bash
set -euo pipefail

# install.sh — set up ai-upskiller skills and the bwclaude launcher.
#
# Usage:
#   bash scripts/install.sh
#
# What it does:
#   1. Symlinks each directory under skills/ into ~/.claude/skills/ and ~/.gemini/skills/
#   2. Symlinks bubblewrap launchers to ~/.local/bin/
#
# Existing symlinks are skipped (re-running is safe).

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Install skills to both Claude and Gemini
for SKILLS_DIR in "$HOME/.claude/skills" "$HOME/.gemini/skills"; do
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
done

# Install launchers to ~/.local/bin
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# Install bwclaude
WRAPPER_SRC="$REPO_DIR/scripts/bubblewrap_claude.sh"
WRAPPER_DST="$BIN_DIR/bwclaude"
chmod +x "$WRAPPER_SRC"

if [ -e "$WRAPPER_DST" ] || [ -L "$WRAPPER_DST" ]; then
  echo "Skipping bwclaude (already exists at $WRAPPER_DST)"
else
  ln -s "$WRAPPER_SRC" "$WRAPPER_DST"
  echo "Installed bwclaude → $WRAPPER_DST"
fi

# Install bwgemini
GEMINI_WRAPPER_SRC="$REPO_DIR/scripts/bubblewrap_gemini.sh"
GEMINI_WRAPPER_DST="$BIN_DIR/bwgemini"
chmod +x "$GEMINI_WRAPPER_SRC"

if [ -e "$GEMINI_WRAPPER_DST" ] || [ -L "$GEMINI_WRAPPER_DST" ]; then
  echo "Skipping bwgemini (already exists at $GEMINI_WRAPPER_DST)"
else
  ln -s "$GEMINI_WRAPPER_SRC" "$GEMINI_WRAPPER_DST"
  echo "Installed bwgemini → $GEMINI_WRAPPER_DST"
fi
