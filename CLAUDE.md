# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Overview

This is **ai-upskiller** — a personal toolkit of Claude Code skills, hooks, MCP servers, and
scripts. Skills live under `skills/` and are installed by running `bash scripts/install.sh`.

## Repository structure

- `skills/<name>/SKILL.md` — each skill is a directory with a SKILL.md containing YAML frontmatter
  (`name`, `description`) followed by the prompt body
- `scripts/` — shell scripts for setup and sandboxing
- See README.md for full documentation

## Adding a new skill

1. Create a new directory: `skills/<skill-name>/SKILL.md`
2. Add the frontmatter (`name`, `description`) and the prompt body
3. Run `bash scripts/install.sh` to symlink it
4. Update `README.md` to add the skill to the table

## Skill authoring conventions

- **`disable-model-invocation: true`** in frontmatter prevents recursive skill invocation — use
  this for skills that invoke Claude directly (like `git-commit`)
- Use `$ARGUMENTS` in the prompt body to receive arguments passed by the user
  (e.g., `/test-review src/Foo.java`)
- Skills that run multi-step processes should define numbered steps and be explicit about when to
  stop vs. continue on error
- Prefer sequential processing with explicit "stop on build failure" guards rather than attempting
  auto-fixes for compilation errors
