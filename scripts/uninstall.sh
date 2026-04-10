#!/usr/bin/env bash
set -euo pipefail

# uninstall.sh — remove ai-upskiller skills or bubblewrap launchers.
#
# Usage:
#   bash scripts/uninstall.sh <name>
#
# Examples:
#   bash scripts/uninstall.sh code-reviewer
#   bash scripts/uninstall.sh bwclaude
#   bash scripts/uninstall.sh bwgemini

if [ $# -eq 0 ]; then
  echo "Usage: $0 <skill-name|bwclaude|bwgemini>"
  exit 1
fi

TARGET_NAME="$1"
BIN_DIR="$HOME/.local/bin"
CLAUDE_SKILLS="$HOME/.claude/skills"
GEMINI_SKILLS="$HOME/.gemini/skills"

# remove_item <path> <label>
remove_item() {
  local target_path="$1"
  local label="$2"

  if [ -L "$target_path" ] || [ -e "$target_path" ]; then
    rm "$target_path"
    echo "Removed $label: $target_path"
  else
    echo "Not found: $target_path"
  fi
}

case "$TARGET_NAME" in
  bwclaude|bwgemini)
    remove_item "$BIN_DIR/$TARGET_NAME" "launcher"
    ;;
  *)
    # Assume it's a skill name
    echo "Attempting to remove skill: $TARGET_NAME"
    remove_item "$CLAUDE_SKILLS/$TARGET_NAME" "Claude skill"
    remove_item "$GEMINI_SKILLS/$TARGET_NAME" "Gemini skill"
    ;;
esac
