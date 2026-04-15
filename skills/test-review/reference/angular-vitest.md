# Angular / Vitest — test-review reference

## Test file location

Look for `<filename>.spec.ts` adjacent to the source file.

## Test runner commands

Run a single spec file:
```
npx vitest run --reporter=verbose <path/to/spec-file.spec.ts>
```

If no spec file exists yet, run `npx vitest run` to confirm the project builds.

## Output parsing patterns

- `FAIL` lines → failing test names and assertion errors
- `PASS` lines → already passing tests

## Coverage commands

**Prerequisite:** `@vitest/coverage-v8` (or `@vitest/coverage-istanbul`) must be installed.
If coverage fails with a missing provider error, tell the user:
> "Run: `npm install --save-dev @vitest/coverage-v8`" — then stop and wait.

```
npx vitest run --coverage <path/to/spec-file.spec.ts>
```
Read the coverage summary printed to stdout (statements, branches, functions, lines %).

## Final verification commands

```
npx vitest run --coverage
```

## Naming convention

```
should_<behavior>_when_<condition>
```
Example: `should_showError_when_formIsInvalid`

## Assertion quality table

| Weak pattern | Replacement |
|---|---|
| `expect(component).toBeTruthy()` as the only assertion | Assert specific properties or output values |
| `expect(result).toBeDefined()` with no further checks | Assert the actual value |
| `expect(spy).toHaveBeenCalled()` with no argument check | Use `toHaveBeenCalledWith(...)` |
| `expect(result).toEqual({})` (empty object) | Assert the specific fields expected |
| Exception test only checks type | Also assert the exception message or cause |

## Test isolation rules

- Static mutable fields mutated in one test and read in another → move initialisation to
  `beforeEach`
- Tests that rely on execution order → make each test self-contained
- Missing `afterEach` cleanup for resources opened in tests → add teardown
- `TestBed` not reset between tests when component has side-effectful `ngOnInit` →
  add `TestBed.resetTestingModule()` or restructure

## Coverage suppression syntax

- `/* v8 ignore next */`
- `/* istanbul ignore next */`
