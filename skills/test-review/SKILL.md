---
name: test-review
description: Full TDD review loop — reads source files, runs tests, fixes failures, writes missing tests to reach 100% coverage, and strengthens weak assertions. Extensible via per-language reference files.
---

You are running the `test-review` skill. Your job is to execute a full TDD review loop for each
source file provided as an argument.

**Arguments:** `$ARGUMENTS`

Parse `$ARGUMENTS` as a space-separated list of file paths.

If `$ARGUMENTS` is empty or blank, stop immediately and print:
> "Usage: `/test-review <file1> [file2 ...]` — provide one or more source files."

- **Single file:** execute steps 1–6 directly in this conversation, then produce the report
  (step 7).
- **Multiple files:** spawn one subagent per file **in parallel** using the Agent tool
  (`subagent_type=general-purpose`). Send all agent calls in a single message. Each agent
  receives a copy of these instructions and a single file path; it executes steps 1–6
  independently. Wait for all agents to finish, collect their outputs, then produce the combined
  report (step 7) in this conversation.

---

## Spawn subagents (multi-file mode only)

Before spawning agents, resolve `$ARGUMENTS` into a concrete list of file paths. Each subagent
receives a **literal file path string**, never the `$ARGUMENTS` token.

Prompt each subagent with:

1. The full text of this skill (steps 1–6).
2. The resolved file path for that agent, hardcoded as a string (e.g., `src/main/java/Foo.java`).
3. The working directory to use (the module root for multi-module Maven projects).
4. The instruction: "Your argument is `<resolved-path>`. Execute steps 1–6 for this file only.
   Return your results as a structured block using the step 7 report format.
   Do not produce a combined report — only report on your assigned file."

Do NOT pass `$ARGUMENTS` to subagents — it will not be substituted inside the subagent prompt.
Do NOT ask subagents to run step 7 or produce a combined report; the orchestrating conversation
does that after all agents return.

---

## Step 1 — Read and understand the source file

Read the source file using the Read tool. Identify: class/component name, all public
methods/inputs/outputs, every business logic branch, and expected edge cases.

---

## Step 2 — Detect project type and load reference file

Determine mode from the file extension:

- `.java` → **Java/Maven** mode
- `.ts` (including `.component.ts`, `.service.ts`) → **Angular/Vitest** mode

If the extension is unrecognised, stop immediately (skip steps 3–7) and report:
> "Unsupported file type: `<extension>`. This skill supports `.java` and `.ts` files only."

After detecting the project type, read the corresponding reference file:
- Java/Maven → `reference/java-maven.md`
- Angular/Vitest → `reference/angular-vitest.md`

All subsequent steps use commands, conventions, and rules from this reference file.
Locate the test file using the conventions in the reference file.

If the reference file cannot be read, stop immediately and report:
> "Could not load reference file for `<project-type>`. Ensure the reference files exist under
> `skills/test-review/reference/`."

Read the test file if it exists. Record how many tests are already present (this is the "tests
before" count for step 7).

---

## Step 3 — Run existing tests

Run the existing tests using the test runner commands from the reference file.

**If a build/compilation error is detected → stop immediately.** Print the full error output and
tell the user:
> "Build failed — please fix the compilation error before proceeding. Here's the output: `<error>`"

Do NOT attempt to auto-fix build or compilation errors. Skip steps 4–7.

---

## Step 4 — Fix failing tests

For each failing test identified in step 3:

1. Read the failure message carefully.
2. Read the test code at the failing location.
3. Trace the failure: is it a stale assertion, wrong mock setup, outdated expected value, or a
   real regression in the source?
4. Apply the minimal fix to make the test correct and green.
5. Re-run only the affected test to confirm it passes before moving on.

**Iteration cap:** attempt at most **3 fix cycles per test**. If a test still fails after 3
attempts, leave it failing and report it in step 7 as requiring manual intervention.

Do NOT delete failing tests. Fix them.

---

## Step 5 — Write new tests to reach 100% coverage

### Measure current coverage

Run the coverage commands from the reference file and parse the results.

### Write tests for uncovered code

If no test file exists yet, create it at the path identified in step 2 with appropriate
boilerplate (imports, test class/describe block).

For every uncovered branch, method, statement, or line:

- Write a focused test case with a descriptive name using the naming convention from the
  reference file.
- Cover all of: happy path (if missing), null/undefined/empty inputs, boundary values,
  exception/error paths.
- Prefer one assertion per concept.
- Use `given/when/then` or `arrange/act/assert` structure inside the test body.

### Iterate toward 100%

After writing each batch of tests, re-run coverage. **Repeat for at most 3 rounds.** If coverage
has not reached 100% after 3 rounds, suppress the remaining uncoverable lines using the
suppression syntax from the reference file and proceed to step 6.

### Suppress genuinely unreachable lines

If a line is genuinely unreachable (e.g., a defensive null check the framework guarantees will
never fire), add a suppression comment using the syntax from the reference file and record the
reason for step 7.

---

## Step 6 — Review and improve existing tests

Go through every test in the file — both old and newly written — and apply the three checks
below.

### 6a — Test naming and structure

| Problem | Fix |
|---|---|
| Generic name (`test1`, `testMethod`, `shouldWork`) | Rename using the convention from the reference file |
| Name describes implementation (`callsRepositorySave`) | Rename to describe observable behaviour (`persistsOrderWhenValid`) |
| No AAA separation (Arrange/Act/Assert not identifiable) | Add blank-line separation or `// Arrange / // Act / // Assert` comments |
| Multiple unrelated behaviours in one test | Split into focused tests, one behaviour each |
| Magic literals with no explanation (`assertEquals(42, result)`) | Extract to a named constant or add an inline comment |

### 6b — Assertion quality

Check every assertion against the quality table in the reference file. Replace weak patterns with
the stronger alternatives specified there.

### 6c — Test isolation

Apply the test isolation rules from the reference file.

Rules:
- Do NOT reduce the number of tests or remove test coverage. Splitting a test into multiple
  focused tests is permitted.
- Each assertion must be specific enough that if the business logic changed subtly, the test
  would fail.

---

## Step 7 — Run final verification and report

Run the final verification commands from the reference file.

Report to the user using this format (output as rendered Markdown, not inside a code block):

---

## Test review summary

### \<FileName\>
- Tests before: \<N\>
- Tests after:  \<N\> (+\<added\>)
- Coverage:     \<X\>% (statements) / \<Y\>% (branches)
- Suppressed lines: \<list with reasons, or "none"\>

### Overall
- Total tests before: \<N\>
- Total tests after:  \<N\>
- All tests passing:  ✓ / ✗

---

If any test is still failing after all fixes, list it explicitly and explain what manual
intervention is needed.
