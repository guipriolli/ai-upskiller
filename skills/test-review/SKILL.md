---
name: test-review
description: Full TDD review loop — reads source files, runs tests, fixes failures, writes missing tests to reach 100% coverage, and strengthens weak assertions. Extensible via per-language reference files.
model: claude-sonnet-4-6
---

# Test review

Execute a TDD review loop for provided source files.

**Arguments:** `$ARGUMENTS`

Parse `$ARGUMENTS` as a space-separated list of file paths.

If `$ARGUMENTS` is empty or blank, stop immediately and print:
> "Usage: `/test-review <file1> [file2 ...]` — provide one or more source files."

- **Single file:** Execute steps 1–6 directly, then produce the step 7 report.
- **Multiple files:** Spawn one `general-purpose` subagent per file in parallel. Provide each
  subagent with the full text of this skill and the resolved file path. Subagents execute steps
  1–6. Wait for all agents to finish, then produce the combined step 7 report in this
  conversation. Do NOT ask subagents to produce the combined report.

## Step 1 — Read and understand the source file

Read the source file. Identify: class/component name, all public methods/inputs/outputs, every
business logic branch, and expected edge cases.

## Step 2 — Detect project type and load reference file

Determine mode from the file extension and read the corresponding reference file:

- **.java:** Java/Maven mode → `reference/java-maven.md`
- **.ts:** Angular/Vitest mode → `reference/angular-vitest.md`

If the extension is unrecognised, stop immediately (skip steps 3–7) and report:
> "Unsupported file type: `<extension>`. This skill supports `.java` and `.ts` files only."

All subsequent steps use commands, conventions, and rules from the reference file. Locate and
read the test file using conventions from the reference file. Record the initial test count.

## Step 3 — Run existing tests

Run tests using the test runner commands from the reference file.

**On build/compilation error — stop immediately.** Print the full error and say:
> "Build failed — please fix the compilation error before proceeding."

Do NOT attempt to auto-fix build errors. Skip steps 4–7.

## Step 4 — Fix failing tests

For each failing test:

1. Trace the failure: stale assertion, wrong mock setup, outdated expected value, or real
   regression in the source?
2. Apply the minimal fix to make the test correct and green.
3. Re-run only the affected test to confirm it passes before moving on.

**Limit:** At most 3 fix cycles per test. If still failing, leave it and report in step 7.

Do NOT delete failing tests. Fix them.

## Step 5 — Write new tests to reach 100% coverage

1. **Measure:** Run coverage commands from the reference file.
2. **Write:** If no test file exists, create it with appropriate boilerplate. For every uncovered
   branch, method, statement, or line: write a focused test covering the happy path, null/empty
   inputs, boundary values, and error paths. Use one assertion per concept and
   `given/when/then` or `arrange/act/assert` structure.
3. **Iterate:** Re-run coverage after each batch. Repeat for at most 3 rounds.
4. **Suppress:** If coverage hasn't reached 100% after 3 rounds, suppress genuinely unreachable
   lines using the syntax from the reference file and record the reason for step 7.

## Step 6 — Review and improve existing tests

Apply to every test — both old and newly written.

### 6a — Naming, structure, and isolation

| Problem | Fix |
|---|---|
| Generic name (`test1`, `shouldWork`) | Rename using the convention from the reference file |
| Name describes implementation (`callsRepositorySave`) | Rename to describe behaviour (`persistsOrderWhenValid`) |
| No AAA separation | Add blank-line separation or `// Arrange / // Act / // Assert` comments |
| Multiple unrelated behaviours in one test | Split into focused tests, one behaviour each |
| Magic literals (`assertEquals(42, result)`) | Extract to a named constant or add an inline comment |
| Shared mutable state between tests | Isolate per test using the reference file's isolation rules |

Do NOT reduce the number of tests or remove coverage. Splitting a test into focused tests is
permitted. Each assertion must be specific enough that a subtle business logic change would fail it.

### 6b — Assertion quality

Verify assertions against the quality table in the reference file. Replace weak patterns with
the stronger alternatives specified there.

## Step 7 — Final verification and report

Run final verification and produce the report:

## Test review summary

### \<FileName\>
- Tests before: \<N\>
- Tests after: \<N\> (+\<added\>)
- Coverage: \<X\>% (statements) / \<Y\>% (branches)
- Suppressed lines: \<list with reasons, or "none"\>

### Overall
- Total tests before: \<N\>
- Total tests after: \<N\>
- All tests passing: ✓ / ✗

If any test is still failing, list it and explain what manual intervention is needed.
