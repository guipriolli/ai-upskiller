---
name: refactoring-advisor
description: Analyzes codebases for code smells and proposes refactoring techniques based on Martin Fowler's refactoring catalog. Identifies method/class-level structural issues, maps them to named refactorings, and applies selected fixes with verification.
---

# Refactoring Advisor

Analyze code for structural problems (code smells), map each smell to a named refactoring
technique, present findings for user approval, and apply selected refactorings with verification.

**Arguments:** `$ARGUMENTS`

Parse `$ARGUMENTS` as: `[--focus <category>] <paths...>`

- `<paths...>`: space-separated file paths, directory paths, or `.` for the whole project.
  Defaults to `.`.
- `--focus <category>` (optional): restrict analysis to one smell category. Valid values:
  `bloaters`, `oo-abusers`, `change-preventers`, `dispensables`, `couplers`.

## 1. Parse scope

Resolve `<paths...>` to source files (exclude test files, generated files, `node_modules`,
`target`, `dist`, `.git`, etc.)

- **Small (1–10 files):** Proceed directly to step 2.
- **Medium (11–50 files):** Use Explore subagents grouped by directory. Each subagent reports:
  file path, language, line count, class/function count, max nesting depth, max parameter count.
- **Large (>50 files):** Use Explore subagents for a triage pass — identify the top 20
  highest-risk files by size, complexity, and nesting. Deep-read only those files.

Report scope: `Scope: N source files across M directories. Largest: path/to/file (X lines).`

## 2. Safety check

Run `git status`. If there are uncommitted changes, **stop and warn the user** — suggest they
commit or stash first to ensure a safe rollback point. Proceed only after the user confirms.

## 3. Identify smells

Evaluate each file against [REFERENCE.md](REFERENCE.md), noting:

- Language and framework
- Line count, class/function names and sizes
- Max nesting depth and parameter counts
- Structural patterns (inheritance hierarchies, long switch/match blocks, data-only classes)

Use the detection heuristics and thresholds in [REFERENCE.md](REFERENCE.md). If `--focus` was
specified, only evaluate smells from that category. For each smell, select the most appropriate
refactoring technique from the smell-to-technique mapping, considering:

- **Language idioms** (e.g., pattern matching over polymorphism in Kotlin/Scala)
- **Architectural feasibility** (don't propose Extract Class if it creates a circular dependency)
- **Effort** (prefer lower-effort techniques for Minor severity)
- **Risk** (prefer safer techniques unless the simpler approach is insufficient)

## 4. Present and select

Present findings in a table:

| # | File | Lines | Smell | Category | Technique | Severity | Effort |
|---|------|-------|-------|----------|-----------|----------|--------|
| Number | `path/to/file` | start–end | smell name | category | proposed technique | Critical / Moderate / Minor | Low / Medium / High |

For each **Critical** finding, write a 2–3 sentence narrative explaining: what the problem is and
why it matters, what the refactoring would change, and the expected improvement.

Then ask:

> Which refactorings would you like to apply?
> - `all` — apply everything
> - `all critical` — apply all critical-severity items
> - Specific numbers: `1, 3, 5`
> - `none` — scan only, no changes

## 5. Apply refactorings

For each approved refactoring:

1. **Single file, single refactoring:** Apply directly using the Edit tool.
2. **Multiple independent refactorings across different files:** Delegate to `general-purpose`
   subagents in parallel (one per refactoring). Send all agent calls in a single message.
3. **Multiple refactorings in the same file:** Combine into one subagent call and apply
   bottom-to-top to preserve line numbers.

Each subagent receives: the file path and current contents, the smell description and line range,
the named technique, and the instruction to preserve the public API, update all internal callers,
and not modify test files.

**Constraints:**
- Preserve public API and existing tests unless the refactoring explicitly requires a signature change
- Update all callers of renamed/moved methods within the project scope
- Apply one technique per smell — do not combine multiple refactorings into one edit

## 6. Verification

### Build

Run the project build command (`mvn compile`, `npx tsc --noEmit`, `python -m py_compile`, etc.).
**If build fails — stop.** Report the full error and say:
> "Build failed after applying refactorings. Review and fix manually, or revert with `git checkout .`"

### Tests

Run the test suite (`mvn test`, `npx vitest run`, `pytest`, etc.). If tests fail, report which
tests failed and the likely cause (e.g., renamed method not updated in caller). Do NOT auto-fix.

### Diff and summary

Run `git diff` and scan for unintended modifications, accidentally deleted code, or missing
imports. Then output:

| Check | Status | Notes |
|-------|--------|-------|
| Build | Pass/Fail | error message if failed |
| Tests | Pass/Fail (N passed, M failed) | list failures |
| Scope | Clean / Drift | list unexpected file changes |

## Notes

- Heuristics are tuned for OO languages (Java, TypeScript, C#, Python, Kotlin). For functional
  codebases, focus on Bloaters and Dispensables — OO Abusers and some Couplers may not apply.
- Threshold values (20 lines, 300 lines, 7 methods) are guidelines — adjust per documented
  project conventions.
- Test files are not modified unless explicitly passed as arguments.
