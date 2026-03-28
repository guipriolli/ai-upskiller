# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal collection of Claude Code skills — Markdown prompt files that extend Claude Code with reusable slash commands. Each skill lives in its own directory and is installed by symlinking into `~/.claude/skills/`.

## Installation

```bash
bash install.sh
```

This symlinks each skill directory into `~/.claude/skills/`. Edits to skill files take effect immediately without re-running the script.

## Repository structure

Each skill is a directory containing at least a `SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name
description: What this skill does
---

Prompt instructions...
```

The `name` field determines the slash command (`/skill-name`). The `description` field is shown in skill listings and used for trigger matching.

## Adding a new skill

1. Create a new directory: `<skill-name>/SKILL.md`
2. Add the frontmatter (`name`, `description`) and the prompt body
3. Run `bash install.sh` to symlink it (or it auto-symlinks if already linked)
4. Update `README.md` to add the skill to the table

## Skill authoring conventions

- **`disable-model-invocation: true`** in frontmatter prevents recursive skill invocation — use this for skills that invoke Claude directly (like `git-commit`)
- Use `$ARGUMENTS` in the prompt body to receive arguments passed by the user (e.g., `/test-review src/Foo.java`)
- Skills that run multi-step processes should define numbered steps and be explicit about when to stop vs. continue on error
- Prefer sequential processing with explicit "stop on build failure" guards rather than attempting auto-fixes for compilation errors

## Current skills

| Skill | Key behaviour |
|-------|---------------|
| `git-commit` | Stages, commits, and pushes; never commits to `main` or `release/*` |
| `test-review` | TDD loop for Java/Maven and Angular/Vitest — fixes failures, adds tests to 100% coverage, strengthens assertions |
| `docs-writer` | Enforces UK English, active voice, 100-char wrap, serial comma, and specific Markdown formatting rules |
| `improve-codebase-architecture` | Module-deepening refactor workflow using John Ousterhout's "deep module" principle; spawns parallel design agents |
