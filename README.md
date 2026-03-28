# ai-upskiller

A personal toolkit for getting more out of AI assistants — skills, agents, hooks, MCP servers,
shell scripts, and configuration files for guardrails and workflows.

Primarily built around [Claude Code](https://github.com/anthropics/claude-code), but designed to be
useful across AI assistants.

## What's in here?

| Category | Description |
|----------|-------------|
| [Skills](./skills) | Reusable slash commands that extend Claude Code |
| Agents | Custom agents for multi-step autonomous tasks |
| Hooks | Shell hooks that trigger on Claude Code events |
| MCP servers | Model Context Protocol servers for extending AI capabilities |
| Scripts | Shell scripts for setup, automation, and guardrails |
| Configs | Configuration files and guardrail definitions |
| Docs | Notes and documentation from hands-on learning |

## Skills

Skills are prompt files that extend Claude Code with reusable slash commands. When you invoke a
skill (for example, `/my-skill`), Claude Code expands the skill's prompt into the conversation,
giving Claude specific instructions for the task.

Each skill is a Markdown file with frontmatter:

```markdown
---
name: my-skill
description: What this skill does
---

The prompt instructions go here...
```

### Available skills

| Skill | Description |
|-------|-------------|
| [docs-writer](./skills/docs-writer/SKILL.md) | Specialised technical writer for creating, reviewing, or editing `.md` documentation files. |
| [git-commit](./skills/git-commit/SKILL.md) | Reviews code changes, prepares a commit message, and pushes to GitHub. |
| [improve-codebase-architecture](./skills/improve-codebase-architecture/SKILL.md) | Explores a codebase to find architectural improvement opportunities, focusing on deepening shallow modules for better testability and AI-navigability. |
| [test-review](./skills/test-review/SKILL.md) | Full TDD review loop: reads source files, runs existing tests, fixes failures, writes missing tests to reach 100% coverage, and strengthens weak assertions. Supports Java/Maven and Angular/Vitest 4. |

### Installation

```bash
bash scripts/install.sh
```

This symlinks each skill directory from `skills/` into `~/.claude/skills/`. Because they're symlinks, any edits to
skill files take effect immediately — you don't need to re-run the script.

To install skills from a published GitHub repo, use:

```bash
npx skills install <github-repo>
```

## Usage

To use a skill in Claude Code, type `/skill-name` in the conversation.

## Scripts

### `scripts/bubblewrap_claude.sh`

Runs Claude Code (or any command) inside a [bubblewrap](https://github.com/containers/bubblewrap) sandbox.
The sandbox restricts filesystem access so that Claude can only write to an explicit allowlist of directories,
reducing the blast radius of unintended or runaway file operations.

**What it does:**

- Mounts system paths (`/usr`, `/lib`, `/bin`, `/etc/...`) as **read-only**
- Grants **write access** only to: `$PWD`, `~/.claude`, `~/.claude.json`, `~/.npm`, `~/.m2`, `~/.agents`
- Forwards SSH agent, D-Bus, GNOME Keyring, GPG, and GitHub CLI config so normal auth flows still work
- Shares the network but isolates the PID namespace (`--unshare-pid`)
- Dies with the parent process (`--die-with-parent`)

**Usage:**

```bash
bash scripts/bubblewrap_claude.sh -c claude
```

Any arguments after the script name are passed to `bash`, so you can also wrap other commands:

```bash
bash scripts/bubblewrap_claude.sh -c "npm install && npm test"
```

**Requirements:** `bwrap` must be installed (`apt install bubblewrap` on Debian/Ubuntu).

## Resources

- [Claude Code documentation](https://code.claude.com/docs/en/overview)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
