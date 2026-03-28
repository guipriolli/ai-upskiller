# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is **ai-upskiller** — a personal toolkit for getting more out of AI assistants. It contains
Claude Code skills, agents, hooks, MCP servers, shell scripts, configuration files, and
documentation. Skills live under `skills/` and are installed by symlinking into `~/.claude/skills/`.

## Installation

```bash
bash scripts/install.sh
```

This symlinks each skill directory from `skills/` into `~/.claude/skills/`. Edits to skill files take effect immediately without re-running the script.

## Repository structure

Skills live in the `skills/` subdirectory. Each skill is a directory containing at least a `SKILL.md` with YAML frontmatter:

```markdown
---
name: skill-name
description: What this skill does
---

Prompt instructions...
```

The `name` field determines the slash command (`/skill-name`). The `description` field is shown in skill listings and used for trigger matching.

## Adding a new skill

1. Create a new directory: `skills/<skill-name>/SKILL.md`
2. Add the frontmatter (`name`, `description`) and the prompt body
3. Run `bash scripts/install.sh` to symlink it
4. Update `README.md` to add the skill to the table

## Skill authoring conventions

- **`disable-model-invocation: true`** in frontmatter prevents recursive skill invocation — use this for skills that invoke Claude directly (like `git-commit`)
- Use `$ARGUMENTS` in the prompt body to receive arguments passed by the user (e.g., `/test-review src/Foo.java`)
- Skills that run multi-step processes should define numbered steps and be explicit about when to stop vs. continue on error
- Prefer sequential processing with explicit "stop on build failure" guards rather than attempting auto-fixes for compilation errors

## Scripts

### `scripts/bubblewrap_claude.sh`

Wraps a command in a [bubblewrap](https://github.com/containers/bubblewrap) sandbox. Use it to run
Claude Code with restricted filesystem access — system paths are read-only and writes are limited to
an explicit allowlist (`$PWD`, `~/.claude`, `~/.claude.json`, `~/.npm`, `~/.m2`, `~/.agents`).
SSH agent, D-Bus, GNOME Keyring, GPG, and GitHub CLI auth are forwarded so normal workflows still
function. Network is shared; PID namespace is isolated.

```bash
bash scripts/bubblewrap_claude.sh -c claude
```

Requires `bwrap` (`apt install bubblewrap`).

## Current skills

| Skill | Key behaviour |
|-------|---------------|
| `git-commit` | Stages, commits, and pushes; never commits to `main` or `release/*` |
| `test-review` | TDD loop for Java/Maven and Angular/Vitest — fixes failures, adds tests to 100% coverage, strengthens assertions |
| `docs-writer` | Enforces UK English, active voice, 100-char wrap, serial comma, and specific Markdown formatting rules |
| `improve-codebase-architecture` | Module-deepening refactor workflow using John Ousterhout's "deep module" principle; spawns parallel design agents |
