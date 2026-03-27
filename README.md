# Claude Code skills

A personal collection of skills for [Claude Code](https://github.com/anthropics/claude-code).

## What are skills?

Skills are prompt files that extend Claude Code with reusable slash commands. When you invoke a
skill (for example, `/my-skill`), Claude Code expands the skill's prompt into the conversation,
giving Claude specific instructions for the task.

## Structure

Each skill is a Markdown file stored in `~/.claude/skills/` (or a configured skills directory).
Skills use frontmatter to define metadata:

```markdown
---
name: my-skill
description: What this skill does
---

The prompt instructions go here...
```

## Skills in this repo

The table below lists all available skills and their purpose.

| Skill | Description |
|-------|-------------|
| [docs-writer](./docs-writer/SKILL.md) | Specialised technical writer for creating, reviewing, or editing `.md` documentation files. |
| [git-commit](./git-commit/SKILL.md) | Reviews code changes, prepares a commit message, and pushes to GitHub. |
| [improve-codebase-architecture](./improve-codebase-architecture/SKILL.md) | Explores a codebase to find architectural improvement opportunities, focusing on deepening shallow modules for better testability and AI-navigability. |

## Installation

To install skills, run the install script from the repo root:

```bash
bash install.sh
```

This symlinks each skill directory into `~/.claude/skills/`. Because they're symlinks, any edits to
skill files take effect immediately — you don't need to re-run the script.

To install skills from a published GitHub repo, use:

```bash
npx skills install <github-repo>
```

## Usage

To use a skill in Claude Code, type `/skill-name` in the conversation.

## Resources

- [Claude Code documentation](https://github.com/anthropics/claude-code)
- [Claude Code issues](https://github.com/anthropics/claude-code/issues)
