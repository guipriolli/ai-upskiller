#!/usr/bin/env bash
set -euo pipefail

# install.sh — set up ai-upskiller skills and the bubblewrap launchers.
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

# install_skills <target_dir>
install_skills() {
  local target_dir="$1"
  mkdir -p "$target_dir"

  for skill_dir in "$REPO_DIR"/skills/*/; do
    local skill_name="$(basename "$skill_dir")"
    local target="$target_dir/$skill_name"

    if [ -e "$target" ] || [ -L "$target" ]; then
      echo "Skipping $skill_name (already exists at $target)"
    else
      ln -s "$skill_dir" "$target"
      echo "Installed $skill_name → $target"
    fi
  done
}

# install_launcher <src_path> <dst_path> <name>
install_launcher() {
  local src="$1"
  local dst="$2"
  local name="$3"

  chmod +x "$src"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "Skipping $name (already exists at $dst)"
  else
    ln -s "$src" "$dst"
    echo "Installed $name → $dst"
  fi
}

# Install skills to both Claude and Gemini
install_skills "$HOME/.claude/skills"
install_skills "$HOME/.gemini/skills"

# Install launchers to ~/.local/bin
BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

install_launcher "$REPO_DIR/scripts/bubblewrap_claude.sh" "$BIN_DIR/bwclaude" "bwclaude"
install_launcher "$REPO_DIR/scripts/bubblewrap_gemini.sh" "$BIN_DIR/bwgemini" "bwgemini"
