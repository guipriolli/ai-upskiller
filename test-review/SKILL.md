---
name: test-review
description: Full TDD review loop — reads source files, runs tests, fixes failures, writes missing tests to reach 100% coverage, and strengthens weak assertions. Supports Java/Maven and Angular/Vitest 4.
---

You are running the `test-review` skill. The user has provided one or more source files as arguments. Your job is to execute a full TDD review loop for each file.

**Arguments:** `$ARGUMENTS`

Parse `$ARGUMENTS` as a space-separated list of file paths. Process each file **sequentially** through steps 3–6 before moving to the next. Show a combined coverage report at the end (step 7).

---

## Step 1 — Read and understand source files

For each file in the argument list:

- Read the file using the Read tool.
- Identify: class/component name, all public methods/inputs/outputs, every business logic branch, and expected edge cases.
- Locate the corresponding test file:
  - **Java:** mirror the source path from `src/main/java/` to `src/test/java/`, look for `<ClassName>Test.java` or `<ClassName>Tests.java`.
  - **Angular:** look for `<filename>.spec.ts` adjacent to the source file.
- Read the test file if it exists. Note how many tests are already present.

---

## Step 2 — Auto-detect project type

Determine mode from the file extensions:

- `.java` → **Java/Maven** mode
- `.ts` (including `.component.ts`, `.service.ts`) → **Angular/Vitest** mode

If the extension is unrecognised, stop immediately and report:
> "Unsupported file type: `<extension>`. This skill supports `.java` and `.ts` files only."

---

## Step 3 — Run existing tests

**Java (Maven):**
```
mvn test -Dtest=<TestClassName>
```
If no test class exists yet, run `mvn test` to compile and confirm there are no build errors.

Parse output for:
- `BUILD FAILURE` → compilation or runtime error
- `Tests run: N, Failures: F, Errors: E` → identify failing tests by name

**Angular (Vitest 4):**
```
npx vitest run --reporter=verbose <path/to/spec-file.spec.ts>
```
If no spec file exists yet, run `npx vitest run` to confirm the project builds.

Parse output for:
- `FAIL` lines → failing test names and assertion errors
- `PASS` lines → already passing tests

**If a build/compilation error is detected → stop immediately.** Print the full error output and tell the user:
> "Build failed — please fix the compilation error before proceeding. Here's the output: `<error>`"

Do NOT attempt to auto-fix build or compilation errors.

---

## Step 4 — Fix failing tests

For each failing test identified in step 3:

1. Read the failure message carefully.
2. Read the test code at the failing location.
3. Trace the failure: is it a stale assertion, wrong mock setup, outdated expected value, or a real regression in the source?
4. Apply the minimal fix to make the test correct and green.
5. Re-run only the affected test to confirm it passes before moving on.
6. Repeat until all pre-existing tests are green.

Do NOT delete failing tests. Fix them.

---

## Step 5 — Write new tests to reach 100% coverage

**Java — measure coverage:**
```
mvn test jacoco:report
```
Read `target/site/jacoco/index.html` or the console summary for uncovered lines and missed branches.

**Angular — measure coverage:**
```
npx vitest run --coverage
```
Read the coverage summary printed to stdout (statements, branches, functions, lines %).

For every uncovered branch, method, statement, or line:

- Write a focused test case with a descriptive name following `given_<context>_when_<action>_then_<result>` or `should_<behavior>_when_<condition>`.
- Cover all of: happy path (if missing), null/undefined/empty inputs, boundary values, exception/error paths.
- Prefer one assertion per concept.
- Use `given/when/then` or `arrange/act/assert` structure inside the test body.

After writing each batch of tests, re-run coverage. Repeat until 100% is reached.

If a line is genuinely unreachable (e.g., a defensive null check that the framework guarantees will never be null), add a suppression comment and explain why in the final report:
- Java: `// jacoco:ignore` or configure exclusions in `pom.xml`
- Angular: `/* v8 ignore next */` or `/* istanbul ignore next */`

---

## Step 6 — Review and strengthen assertions

Go through every test in the file — both old and newly written. For each assertion, check for these weak patterns and fix them:

| Weak pattern | Replacement |
|---|---|
| `assertNotNull(result)` with no further checks | Assert the actual value or specific fields |
| `assertTrue(result != null)` | Use typed matchers / `assertNotNull` + value check |
| `assertEquals(true, someCondition)` | `assertTrue(someCondition)` |
| Mock verified with `verify()` but return value never checked | Also assert the return value |
| Angular: `expect(component).toBeTruthy()` as the only assertion | Assert specific properties or output values |
| `expect(result).toBeDefined()` with no further checks | Assert the actual value |
| `expect(spy).toHaveBeenCalled()` with no argument check | Use `toHaveBeenCalledWith(...)` |

Rules:
- Do NOT remove any test — only strengthen assertions.
- Each assertion must be specific enough that if the business logic changed subtly, the test would fail.

---

## Step 7 — Final verification and report

Run the full test suite with coverage one last time:

**Java:**
```
mvn test jacoco:report
```

**Angular:**
```
npx vitest run --coverage
```

Then report to the user using this format:

```
## Test Review Summary

### <FileName>
- Tests before: <N>
- Tests after:  <N> (+<added>)
- Coverage:     <X>% (statements) / <Y>% (branches)
- Suppressed lines: <list with reasons, or "none">

### Overall
- Total tests before: <N>
- Total tests after:  <N>
- All tests passing:  ✓ / ✗
```

If any test is still failing after all fixes, list it explicitly and explain what manual intervention is needed.
