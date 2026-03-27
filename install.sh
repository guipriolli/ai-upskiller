#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$HOME/.claude/skills"
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$SKILLS_DIR"

for skill_dir in "$REPO_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  target="$SKILLS_DIR/$skill_name"

  if [ -e "$target" ] || [ -L "$target" ]; then
    echo "Skipping $skill_name (already exists at $target)"
  else
    ln -s "$skill_dir" "$target"
    echo "Installed $skill_name → $target"
  fi
done
