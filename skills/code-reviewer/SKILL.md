---
name: code-reviewer
description: Automates local code review of uncommitted changes. Analyzes diffs, identifies issues, proposes categorized fixes, gathers user approval, delegates fixes to subagents, and verifies the final state through compilation and testing.
disable-model-invocation: true
---

# Code reviewer

Act as a code-reviewer expert. Guide the user through a comprehensive local code review of their uncommitted changes. Follow these steps strictly. **Stop on any build or test failure — do not attempt auto-fixes.**

## 1. Gather changes

1. Run `git diff HEAD`, `git diff --staged`, and `git ls-files --others --exclude-standard` 
to collect all modified and untracked files.
2. **Large diffs:** If diff >500 lines, process by file or module. Do not load the full diff into 
one prompt.
3. **Context:** If a hunk is ambiguous, read the full file before forming an opinion.

## 2. Review

Scan the changes against the criteria below, in priority order:

1. **Secrets and credentials** — Hardcoded API keys, passwords, `.env` values, or tokens. Flag immediately.
2. **Correctness** — Bugs, logic flaws, or behavior that contradicts stated intent.
3. **Security** — Injection vectors, insecure defaults, OWASP Top 10 violations.
4. **Architecture** — Tight coupling, broken patterns, or cross-module impact. If a core interface changed, use an Explore subagent to verify that all dependent modules still compile.
5. **Edge cases and error handling** — Missing guards, swallowed exceptions, inadequate logging.
6. **Testability** — Insufficient test coverage for new or modified paths. Suggest specific test cases.
7. **Efficiency** — Performance bottlenecks or unnecessary complexity.
8. **Maintainability** — Code smells, poor modularity, or design-pattern violations.
9. **Readability** — Formatting inconsistencies or missing/inaccurate inline documentation.
10. **Documentation sync** — Changes that render `README.md`, API docs, or other reference material obsolete.
11. **Conventions** — Deviations from project conventions or CLAUDE.md instructions.

Output a **numbered list** of findings.

## 3. Propose fixes

For each finding, provide:

| Field | Content |
|---|---|
| **Fix** | The specific code change or refactoring required |
| **Rationale** | Why the fix matters |
| **Severity** | `Critical` or `Nitpick` |
| **Trade-offs** | Any relevant trade-offs (e.g., performance vs. readability) |

## 4. User authorization

Present the proposed fixes and ask the user which to apply. Accept:
- "Fix all critical"
- Specific numbers (e.g., "1, 3, 4")
- Explicit rejections (e.g., "Ignore 2")

**Wait for explicit authorization before proceeding.**

## 5. Delegate fixes to subagents

Delegate each approved fix to a subagent:

1. **Prepare context:** For each approved fix, extract the affected file path, issue description, and proposed change.
2. **Same-file rule:** If two or more approved fixes touch the same file, combine them into a single subagent call to prevent race conditions.
3. **Spawn subagents:** Launch one `general-purpose` subagent per independent fix. Run them in parallel, up to a maximum of **5 concurrent** subagents. Queue remaining fixes in subsequent batches.

## 6. Verify

After all subagents complete:

1. **Detect build tool:** Identify the project's build system (e.g., `mvn`, `npm`, `gradle`, `cargo`) from config files in the repository root.
2. **Compile:** If the project requires compilation, run the build command. **Stop on failure** — report the error to the user and do not proceed.
3. **Run tests:** Execute test suite. Verify if modified lines have coverage. **Stop on failure.**
4. **Check git status:** Run `git status` to confirm only the intended files were modified. Flag any unexpected changes.
