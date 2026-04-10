# GEMINI.md

This file provides foundational context and instructions for Gemini CLI when working in the `ai-upskiller` repository.

## Project Overview

**ai-upskiller** is a personal toolkit designed to extend the capabilities of AI assistants (primarily Claude Code and Gemini CLI). It contains:
- **Skills:** Specialized, structured prompt templates (located in `skills/`) that define complex workflows for tasks like technical writing, code review, and TDD.
- **Scripts:** Bash scripts for installation, sandboxing (using Bubblewrap), and automation.
- **Configurations:** Guardrails and environment setups for AI-driven development.

## Core Mandates

1.  **Skill-Based Workflow:** When asked to perform a task that matches an existing skill (e.g., "write documentation", "review tests", "commit changes"), refer to the corresponding `SKILL.md` file for detailed instructions and follow its execution directives strictly.
2.  **Technical Writing Standards:** All documentation must adhere to the standards defined in `skills/docs-writer/SKILL.md`. This includes using active voice, sentence case for headings, and wrapping text at 100 characters.
3.  **Sandboxing Awareness:** The `scripts/bubblewrap_claude.sh` script (installed as `bwclaude`) provides a restricted environment. Be aware of these restrictions when suggesting or executing shell commands.
4.  **No Recursive Invocation:** Skills with `disable-model-invocation: true` in their frontmatter should not be invoked by the assistant recursively.

## Repository Structure

- `skills/`: Directories containing `SKILL.md` files. Each skill is a standalone instruction set.
- `scripts/`:
    - `install.sh`: Sets up the environment by symlinking skills and the `bwclaude` launcher.
    - `bubblewrap_claude.sh`: The sandboxed execution wrapper.
- `CLAUDE.md`: Assistant-specific guidance (original source for these mandates).

## Common Workflows

### Installing or Removing Skills
To install or refresh the skill symlinks in your local environment:
```bash
bash scripts/install.sh
```

To remove a specific skill or launcher:
```bash
bash scripts/uninstall.sh <name>
```

### Adding a New Skill
1.  Create a new directory: `skills/<skill-name>/`.
2.  Create `skills/<skill-name>/SKILL.md` with YAML frontmatter (`name`, `description`).
3.  Run `bash scripts/install.sh` to register the new skill.
4.  Update the `README.md` skills table.

### Using the Sandbox
To run commands (including assistant sessions) inside the Bubblewrap sandbox:
```bash
bwclaude <command>  # For Claude Code
bwgemini <command>  # For Gemini CLI
```

## Development Conventions

- **Commit Messages:** Follow the directives in `skills/git-commit/SKILL.md`. Review changes, update README if necessary, and use objective, concise messages.
- **Testing (TDD):** Use the `test-review` skill logic for any test-related tasks. It supports Java/Maven and Angular/Vitest 4, focusing on 100% coverage and strong assertions.
- **Documentation:** Always use the `docs-writer` standards. Every file must have exactly one H1, use sentence case, and provide introductory paragraphs for all headings.
