# Java / Maven — test-review reference

## Test file location

Mirror the source path from `src/main/java/` to `src/test/java/`, and look for
`<ClassName>Test.java` or `<ClassName>Tests.java`.

## Test runner commands

Run a single test class:
```
mvn test -Dtest=<TestClassName>
```

If no test class exists yet, run `mvn test` to compile and confirm there are no build errors.

**Multi-module projects:** run from the module root, or add `-pl <module-path>` to target the
correct module (e.g., `mvn test -pl services/order -Dtest=OrderServiceTest`). When using `-pl`,
also adjust the JaCoCo report path accordingly
(e.g., `services/order/target/site/jacoco/jacoco.xml`).

## Output parsing patterns

- `BUILD FAILURE` → compilation or runtime error
- `Tests run: N, Failures: F, Errors: E` → identify failing tests by name

## Coverage commands

Generate coverage report:
```
mvn test jacoco:report
```

Parse coverage for a specific class:
```
python3 ~/.claude/skills/test-review/scripts/jacoco-coverage-by-class.py <ClassName>
```
Substitute `<ClassName>` with the simple class name (e.g., `OrderService`).

For multi-module projects, ensure you read the report from the correct module directory
(e.g., `services/order/target/site/jacoco/jacoco.xml`). If needed, run the script from the
module root or adjust the path.

## Final verification commands

```
mvn test jacoco:report
```
Then read coverage numbers:
```
python3 ~/.claude/skills/test-review/scripts/jacoco-coverage-summary.py
```
Use `INSTRUCTION` as "statements %" and `BRANCH` as "branches %" in the report.

## Naming convention

```
given_<context>_when_<action>_then_<result>
```
Example: `given_emptyCart_when_checkout_then_throwsException`

## Assertion quality table

| Weak pattern | Replacement |
|---|---|
| `assertNotNull(result)` with no further checks | Assert the actual value or specific fields |
| `assertTrue(result != null)` | `assertNotNull(result)` + value check |
| `assertEquals(true, someCondition)` | `assertTrue(someCondition)` |
| `assertEquals(false, someCondition)` | `assertFalse(someCondition)` |
| Mock verified with `verify()` but return value never checked | Also assert the return value |
| `assertThat(list).isNotEmpty()` with no content check | Assert size or specific elements |
| Exception test only checks type (`assertThrows(FooException.class, ...)`) | Also assert the exception message or cause |

**JUnit 5 bonus:** prefer `assertAll(...)` for grouping multiple field checks on the same object
so all failures are shown at once.

## Test isolation rules

- Static mutable fields mutated in one test and read in another → move initialisation to
  `@BeforeEach`
- Tests that rely on execution order → make each test self-contained
- Missing `@AfterEach` cleanup for resources opened in tests → add teardown

## Coverage suppression syntax

- Inline: `// jacoco:ignore`
- Build-level: configure exclusions in `pom.xml`
