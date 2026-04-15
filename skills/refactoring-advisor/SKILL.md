---
name: refactoring-advisor
description: Analyzes codebases for code smells and proposes concrete refactoring techniques based on Martin Fowler's refactoring catalog. Identifies method/class-level structural issues, maps them to named refactorings, and applies selected fixes with verification.
disable-model-invocation: true
---

# Refactoring Advisor

You are running the `refactoring-advisor` skill. Your job is to analyze code for structural
problems (code smells), map each smell to a named refactoring technique, present findings for user
approval, and apply selected refactorings with verification.

**Arguments:** `$ARGUMENTS`

Parse `$ARGUMENTS` as: `[--focus <category>] <paths...>`

- `<paths...>`: space-separated file paths, directory paths, or `.` for the whole project. If no
  paths are provided, default to `.`.
- `--focus <category>` (optional): restrict analysis to a single smell category. Valid values:
  `bloaters`, `oo-abusers`, `change-preventers`, `dispensables`, `couplers`. If omitted, analyze
  all categories.

---

## 1. Parse scope

Resolve `$ARGUMENTS` into a concrete list of source files (exclude test files, generated files,
`node_modules`, `target`, `dist`, `.git`, and similar build artifacts).

- **Small scope** (1-10 files): proceed directly to step 2.
- **Medium scope** (11-50 files): use Explore subagents grouped by directory to read and triage
  files. Each subagent reports: file path, language, line count, number of classes/functions, max
  nesting depth, max parameter count.
- **Large scope** (>50 files): use Explore subagents to perform a triage pass first — identify
  the top 20 highest-risk files by size, complexity, and nesting depth. Then deep-read only those
  files.

Report the resolved scope to the user:
> Scope: N source files across M directories. Largest: `path/to/file` (X lines).

---

## 2. Read code and identify smells

Read each in-scope file and concurrently evaluate it against the smell catalog in [REFERENCE.md](REFERENCE.md). Note the following context for each file:

- Language and framework
- Line count
- Classes, functions, and methods (names and line counts)
- Max nesting depth
- Parameter counts for each method/function
- Any obvious structural patterns (inheritance hierarchies, long switch/match blocks, data-only
  classes)

For medium/large scopes, delegate reading to Explore subagents grouped by directory. Each subagent returns a structured summary — do not dump raw file contents into the main context.

Use the detection heuristics and thresholds defined in [REFERENCE.md](REFERENCE.md) to identify
smells. If `--focus` was specified, only evaluate smells from that category.

For each detected smell, record:

| Field | Value |
|-------|-------|
| File | path/to/file |
| Lines | start-end |
| Smell | name from catalog |
| Category | Bloaters / OO Abusers / Change Preventers / Dispensables / Couplers |
| Severity | Critical / Moderate / Minor |
| Confidence | High / Medium / Low |

**Severity guidelines:**
- **Critical**: actively causes bugs, blocks testability, or forces shotgun surgery on every change
- **Moderate**: measurably hurts readability or maintainability but is contained
- **Minor**: style-level issue or marginal improvement opportunity

---

## 3. Map to refactoring techniques

For each smell, consult the smell-to-technique mapping in [REFERENCE.md](REFERENCE.md) to select
the most appropriate refactoring technique(s).

When choosing between alternatives, consider:
- **Language idioms**: prefer idiomatic solutions (e.g., pattern matching over polymorphism in
  Kotlin/Scala, composition over inheritance in Go)
- **Architectural feasibility**: don't propose Extract Class if it would create a circular
  dependency
- **Effort**: prefer lower-effort techniques when the smell is Minor severity
- **Risk**: prefer safer techniques (e.g., Extract Method over Replace Method with Method Object)
  unless the simpler approach is insufficient

---

## 4. Present findings

Output findings in this format:

### Summary

> Found **N** code smells across **M** files: **X** critical, **Y** moderate, **Z** minor.

### Findings by category

For each category that has findings, output a table:

#### Category Name

| # | Severity | Smell | File | Lines | Technique | Effort |
|---|----------|-------|------|-------|-----------|--------|
| 1 | Critical | Long Method | `src/OrderService.java` | 45-120 | Extract Method | Low |
| 2 | Moderate | Feature Envy | `src/OrderService.java` | 78-95 | Move Method | Medium |

**Effort levels:**
- **Low**: single-file, few lines affected, no caller updates needed
- **Medium**: single-file but many lines, or few cross-file caller updates
- **High**: multi-file changes, many callers to update, or architectural impact

### Critical findings (narrative)

For each Critical-severity finding, write a 2-3 sentence narrative explaining:
- What the problem is and why it matters
- What the proposed refactoring would change
- What the expected improvement is

### User prompt

After presenting all findings, ask:

> Which refactorings would you like to apply? Options:
> - `all` — apply everything
> - `all critical` — apply all critical-severity items
> - Specific numbers: `1, 3, 5`
> - `none` — scan-only, no changes

---

## 5. User selects refactorings

Wait for the user's response. Parse their selection:
- `all` — apply all findings
- `all critical` — apply all Critical-severity findings
- `all moderate` — apply all Moderate-severity findings
- Comma-separated numbers — apply specific findings by their `#` from the tables
- `none` — end the skill here with no code changes

---

## 6. Apply refactorings

**Safety Check:** Before applying any changes, check if the git working directory is clean using `git status` (if in a git repository). If there are uncommitted changes, stop execution and **warn the user and suggest they commit or stash first** before proceeding. Ensure they have a safe point to fall back to in case refactoring breaks things. Proceed only after user confirms it is safe.

For each approved refactoring:

1. **Single file, single refactoring**: apply directly using Edit tool.
2. **Multiple independent refactorings across different files**: delegate to subagents in parallel
   (one `general-purpose` subagent per independent refactoring). Send all agent calls in a single
   message.
3. **Multiple refactorings in the same file**: combine into a single subagent call to prevent
   race conditions. Apply them in order from bottom-of-file to top-of-file to preserve line
   numbers.

Each subagent receives:
- The file path and current file contents
- The specific smell description and line range
- The named refactoring technique to apply
- The instruction: "Apply this refactoring. Preserve the public API — do not rename public
  methods, change return types, or modify method signatures unless the refactoring specifically
  requires it. Update all callers within the file. Do not modify test files."

**Constraints:**
- Preserve existing tests and public API unless the refactoring explicitly requires a signature
  change
- Update all callers of renamed/moved methods within the project scope
- Apply one technique at a time per smell — do not combine multiple refactorings into one edit
- Do not modify test files unless they were explicitly included in `$ARGUMENTS`

---

## 7. Verification

After all refactorings are applied:

### 7a. Build check

If the project has a build system, run the build command:
- Java/Maven: `mvn compile`
- TypeScript/Node: `npx tsc --noEmit` or the project's build script
- Python: `python -m py_compile` on changed files
- Other: check for a `build` script in `package.json` or `Makefile`

**If the build fails — STOP.** Report the full error output to the user. Do NOT attempt to
auto-fix build errors. Say:
> "Build failed after applying refactorings. Here's the error — please review and fix manually,
> or ask me to revert with `git checkout .`"

### 7b. Test check

Run the project's test suite:
- Java/Maven: `mvn test`
- TypeScript/Node: `npx vitest run` or `npm test`
- Python: `pytest`

If tests fail, report:
- Which tests failed
- The likely cause (e.g., "renamed method not updated in caller" or "extracted class not imported")
- Do NOT auto-fix — let the user decide

### 7c. Diff review

Run `git diff` and scan the changes for:
- Unintended modifications outside the target scope
- Accidentally deleted code
- Import statements that need updating

### 7d. Regression summary

Output a summary table:

| Check | Status | Notes |
|-------|--------|-------|
| Build | Pass/Fail | error message if failed |
| Tests | Pass/Fail (N passed, M failed) | list failures |
| Scope | Clean / Drift | list unexpected file changes |

---

## Notes

- Works with any language but detection heuristics are tuned for OO languages (Java, TypeScript,
  C#, Python, Kotlin)
- Threshold values (20 lines, 300 lines, 7 methods, etc.) are guidelines — adjust per project
  conventions if the codebase has documented standards
- Does not modify test files unless they are explicitly passed as arguments
- For functional codebases, focus on Bloaters and Dispensables categories — OO Abusers and some
  Couplers may not apply
