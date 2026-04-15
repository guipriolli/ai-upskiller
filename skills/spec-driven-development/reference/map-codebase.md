# Special Flow: Map Codebase

**Trigger:** "map codebase" or "scan codebase"

**Flow:**
1. Use Explore sub-agent (brief, medium, or thorough based on codebase size):
   - Scan directory structure (focus on `src/`, `lib/`, `api/`, etc.)
   - List key files and their purpose
   - Identify tech stack, frameworks, key dependencies
   - Note naming conventions and patterns

2. Create `.specs/codebase/STACK.md`:
   ```markdown
   ---
   created: YYYY-MM-DD
   last-updated: YYYY-MM-DD
   ---

   # Tech Stack

   - **Runtime:** [Node.js 18, Python 3.11, etc.]
   - **Framework:** [Express, Django, Next.js, etc.]
   - **Database:** [PostgreSQL 14, MongoDB, etc.]
   - **Package Manager:** [npm, pip, cargo, etc.]
   - **Test Framework:** [Jest, pytest, Vitest, etc.]

   ## Key Dependencies
   - [lib1]: [version] — [why used]
   - [lib2]: [version]
   ```

3. Create `.specs/codebase/ARCHITECTURE.md`:
   ```markdown
   ---
   created: YYYY-MM-DD
   last-updated: YYYY-MM-DD
   ---

   # Architecture

   ## Directory Structure
   ```
   src/
   ├── models/      → [What lives here]
   ├── services/    → [What lives here]
   ├── routes/      → [What lives here]
   └── ...
   ```

   ## Design Patterns
   - [Pattern 1]: [Used here, for this reason]
   - [Pattern 2]: ...

   ## Data Flow
   [Request → Handler → Service → Model → Response]

   ## Key Modules
   - [Module A]: [Responsibility]
   ```

4. Create `.specs/codebase/CONVENTIONS.md`:
   ```markdown
   ---
   created: YYYY-MM-DD
   last-updated: YYYY-MM-DD
   ---

   # Conventions

   ## Naming
   - Files: `camelCase.ts` or `snake_case.py`?
   - Functions: verb-noun pattern? (e.g., `fetchUser()`, `validateEmail()`)
   - Variables: single-letter loop vars OK? Constants ALL_CAPS?

   ## File Structure
   - One export per file or multiple?
   - Folder structure for features: flat or nested?

   ## Code Style
   - Indentation: 2 or 4 spaces?
   - Semicolons: yes or no?
   - Type annotations: always or optional?

   ## Testing
   - Where test files live: `__tests__/` or `.test.ts` in src/?
   - Naming: `describe('X', () => { it('...') })` or other?
   ```

5. Create `.specs/codebase/TESTING.md`:
   ```markdown
   ---
   created: YYYY-MM-DD
   last-updated: YYYY-MM-DD
   ---

   # Testing

   ## Test Framework
   - Framework: [jest / pytest / etc.]
   - Runner: [npm test / etc.]
   - Coverage tool: [istanbul / etc.]

   ## Test Organization
   - Unit tests: `[path pattern]`
   - Integration tests: `[path pattern]`
   - E2E tests: `[path pattern]`

   ## Conventions
   - Naming: [describe/it / test_ / etc.]
   - Mocking approach: [jest.mock / dependency injection / etc.]
   - Fixtures: [factory pattern / fixtures directory / inline]
   ```

6. Create `.specs/codebase/CONCERNS.md`:
   ```markdown
   ---
   created: YYYY-MM-DD
   last-updated: YYYY-MM-DD
   ---

   # Known Concerns

   ## Tech Debt
   - [Area]: [What's wrong and why it matters]

   ## Fragile Areas
   - [File/module]: [Why it's fragile — e.g., no tests, tight coupling]

   ## Security Considerations
   - [Area]: [What to watch for]
   ```
