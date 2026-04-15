---
name: spec-driven-development
description: Spec-driven development skill for planning, designing, and implementing features with structured specs and task tracking.
disable-model-invocation: true
---

# Spec-Driven Development Skill

This skill guides you through structured feature development using a lightweight `.specs/` directory to maintain project context, avoid re-reading the entire codebase, and track work across sessions.

For detailed flows on special operations, see the reference files in `reference/`:
- **Initialize Project:** `reference/initialize-project.md`
- **Map Codebase:** `reference/map-codebase.md`
- **Quick Task:** `reference/quick-task.md`
- **Pause & Resume:** `reference/pause-resume.md`

---

## Quick Start: Key Commands

Invoke this skill with one of these triggers to enter the appropriate phase:

| Trigger | What it does |
|---------|-----------|
| **initialize project** | 5-question Q&A to set up a new project; creates `.specs/project/PROJECT.md` |
| **map codebase** | Scans an existing codebase; creates `.specs/codebase/` files (STACK.md, ARCHITECTURE.md, CONVENTIONS.md) |
| **specify feature [NAME]** | Gathers requirements and creates `.specs/features/[NAME]/spec.md` |
| **design [FEATURE]** | Reads spec, identifies patterns, creates `.specs/features/[FEATURE]/design.md` |
| **tasks [FEATURE]** | Breaks feature into atomic tasks; creates `.specs/features/[FEATURE]/tasks.md` |
| **implement [TASK_ID]** | Picks a task from tasks.md and executes it (read phase, plan, write code, verify, commit) |
| **pause work** | Saves current session state to `.specs/HANDOFF.md` |
| **resume work** | Reads HANDOFF.md and STATE.md, summarizes your position, proposes next action |
| **quick task [DESCRIPTION]** | For small tasks (≤3 files, one sentence); skips design; creates `.specs/quick/NNN-slug.md` |

---

## Phase 0: Context Load (Always First)

When you invoke the skill, immediately:

1. **Check if `.specs/` exists**
   - If NO → offer to run **Initialize Project** or ask what you're working on
   - If YES → continue to step 2

2. **If new project:** Run **Initialize Project** flow (see below)

3. **If existing project:** Load context in this order:
   - Read `.specs/project/PROJECT.md` (vision, stack, scope)
   - Read `.specs/project/STATE.md` if it exists (decisions, blockers, deferred)
   - Read `.specs/HANDOFF.md` if it exists (session state, pending steps)
   - Read relevant feature files (spec.md / design.md / tasks.md) based on what you're working on
   - **Skip full codebase re-read** — trust the local `.specs/codebase/` files
   - If codebase not yet mapped → offer to run **Map Codebase** flow

4. **Summarize position:** "I've read [files]. Here's where we are: [summary]. What's next?"

5. **Assess complexity and select workflow:**

| Scope | Criteria | Workflow |
|-------|----------|----------|
| Trivial | ≤3 files, one sentence | Quick Task (skip everything) |
| Small | Clear requirements, no architecture decisions | Specify → Execute (skip Design, Tasks) |
| Medium | Some design decisions, 3-8 files | Specify → Tasks → Execute (skip Design) |
| Large | New components, architectural decisions, 8+ files | Full: Specify → Design → Tasks → Execute |

State which workflow you're using and why. The developer can override.

---

## Phase 1: Specify

**Goal:** Clarify requirements without interrogation.

**Flow:**
1. Ask clarifying questions only if needed (e.g., "Who are the users?", "What's the success metric?")
2. Document findings in `.specs/features/[FEATURE]/spec.md`
3. **Surface gray areas:** If any user-facing behavior has multiple valid interpretations, list them explicitly and ask the developer to decide. Document decisions in the spec under a "Resolved Gray Areas" section. Don't guess — ambiguity in the spec becomes bugs in the code.

**Output Template:** `.specs/features/[FEATURE]/spec.md`

```markdown
---
feature: [feature-name]
status: drafted
last-updated: YYYY-MM-DD
---

# Spec: [Feature Name]

## Problem / Motivation
[Why are we building this?]

## Goals
- [P1 goal]
- [P2 goal]

## Out of Scope
- [Explicitly exclude this]
- [And this]

## User Stories
### P1 (Must-have)
- AS A [user type] I WANT TO [action] SO THAT [outcome]
- ...

### P2 (Nice-to-have)
- AS A [user type] I WANT TO [action] SO THAT [outcome]

### P3 (Future)
- [Optional ideas]

## Acceptance Criteria
| ID | Criterion | Status |
|----|-----------|--------|
| FEAT-01 | WHEN [condition] THEN [result] SHALL [action] | Pending |
| FEAT-02 | ... | Pending |

## Resolved Gray Areas
- **[Ambiguous behavior]:** Decided [X] because [reason]. (Date)

## Edge Cases & Error Handling
- [Invalid input X → should do Y]
- [Network failure → should do Z]

## Open Questions
- [Question 1 — TBD: person/date]
- [Question 2 — TBD: person/date]
```

---

## Phase 2: Design

**Goal:** Translate spec into architecture.

**Flow:**
1. Read `.specs/features/[FEATURE]/spec.md`
2. Scan existing codebase patterns (look at `.specs/codebase/ARCHITECTURE.md`, check examples in code)
3. Design components, data models, and tech decisions
4. Document in `.specs/features/[FEATURE]/design.md`

**Output Template:** `.specs/features/[FEATURE]/design.md`

```markdown
---
feature: [feature-name]
status: drafted
last-updated: YYYY-MM-DD
---

# Design: [Feature Name]

## Architecture Overview
[High-level diagram or description. What are the main components?]

## Components
### [Component 1]
- **Purpose:** [What it does]
- **Lives in:** `src/path/to/component`
- **Dependencies:** [other components / external libs]
- **Key methods/exports:** [list]

### [Component 2]
- ...

## Data Models
```
[Entity/Type]
├── field1: Type [cardinality, constraints]
├── field2: Type
└── ...
```

## Tech Decisions
- **[Decision 1]:** [Why this way and not the other?]
- **[Decision 2]:** ...

## Integration Points
- [API endpoint consumed by this feature]
- [Storage / database table]
- [Event bus / message queue]

## Error Handling
- [Failure mode A] → [recovery strategy]

## Testing Strategy
- Unit tests for: [components]
- Integration tests for: [endpoints/flows]
```

---

## Phase 3: Tasks

**Goal:** Break feature into atomic, self-contained work units.

**Flow:**
1. Read spec.md and design.md
2. Identify atomic tasks: one component, one file, one endpoint
3. Define dependencies and done-when criteria
4. Document in `.specs/features/[FEATURE]/tasks.md`
5. **Validate tasks before proceeding:**
   - Each task touches ≤5 files (if more, split it)
   - Each "done when" criterion is testable without human judgment
   - Every acceptance criterion from spec.md maps to at least one task
   - Dependencies form a DAG (no circular dependencies)

**Output Template:** `.specs/features/[FEATURE]/tasks.md`

```markdown
---
feature: [feature-name]
status: drafted
last-updated: YYYY-MM-DD
---

# Tasks: [Feature Name]

## Task 1: [Component / File / Endpoint Name]
- **What:** [One sentence summary]
- **Requirement:** FEAT-01, FEAT-03
- **Where:** `src/path/to/file.ts` (or create if new)
- **Depends on:** [Task N / external library]
- **Done when:**
  - [ ] Code written and reviewed
  - [ ] Tests passing (unit + integration)
  - [ ] Handles [specific edge case]
  - [ ] [If API] endpoint responds with [expected schema]
  - [ ] Committed with Conventional Commits

## Task 2: [Next component]
- ...

## Task N: Integration / Validation
- **What:** Verify feature end-to-end, write UAT script
- **Where:** `tests/features/[feature].test.ts`
- **Depends on:** [All previous tasks]
- **Done when:**
  - [ ] All sub-tasks completed
  - [ ] UAT script passes
  - [ ] Code review approved
```

---

## Phase 4: Execute

**Goal:** Implement one task at a time, verify, commit.

**Flow per task:**
1. **Read `reference/coding-principles.md`** before writing any code
2. Read task description from tasks.md
3. **State your plan:** "I'm going to [what], touching [files], then verify with [test]"
4. **Pre-check (optional):** "Does this approach look right?" (if task is complex)
5. **Write tests first (RED):** If the task's done-when criteria include testable behavior, write the test before the implementation. The test should fail.
6. **Implement (GREEN):** Write minimum code to make the test pass and satisfy done-when criteria
7. **Verify:** Run tests, check output, manual test if needed. Do NOT weaken assertions or delete tests to make them pass.
8. **Commit:** Conventional Commits message
9. **Update tasks.md:** Mark task done, add any findings to next task
10. **Track deviations:** If your implementation diverges from spec.md or design.md, add a comment `// SPEC_DEVIATION: [what changed] — Reason: [why]` and note it in tasks.md so the spec can be updated later.

---

## Phase 5: Verify (for Medium+ features)

**Goal:** Confirm the feature works end-to-end after all tasks are complete.

**Flow:**
1. Re-read spec.md acceptance criteria
2. Run all related tests
3. Manual verification of each acceptance criterion
4. Update requirement statuses: Pending → Verified
5. Note any deviations or issues discovered
6. If issues found: create new tasks in tasks.md, return to Phase 4

---

## Special Flow: Initialize Project

**Trigger:** "initialize project" or "set up project"

**Brief:** 5-question Q&A to gather vision, audience, stack, scope, and constraints. Creates `.specs/project/PROJECT.md` and optionally ROADMAP.md and STATE.md.

**Detailed flow and templates:** See `reference/initialize-project.md`

---

## Special Flow: Map Codebase

**Trigger:** "map codebase" or "scan codebase"

**Brief:** Use Explore sub-agent to scan directory structure, dependencies, and conventions. Creates `.specs/codebase/STACK.md`, `ARCHITECTURE.md`, `CONVENTIONS.md`, `TESTING.md`, and `CONCERNS.md`.

**Detailed flow and templates:** See `reference/map-codebase.md`

---

## Special Flow: Quick Task

**Trigger:** "quick task [DESCRIPTION]" or "quick fix [DESCRIPTION]"

**Brief:** For tasks touching ≤3 files and fitting in one sentence. Describe → pre-check → implement → verify → commit. Logs result to `.specs/quick/NNN-slug.md`.

**Detailed flow and template:** See `reference/quick-task.md`

---

## Special Flows: Pause & Resume Work

**Pause Trigger:** "pause work" or "exit session"
**Resume Trigger:** "resume work" or "pick up where I left off"

**Brief:** Pause saves current position, pending steps, blockers, and uncommitted files to `.specs/HANDOFF.md`. Resume reads HANDOFF.md + STATE.md and summarizes where you left off.

**Detailed flows and templates:** See `reference/pause-resume.md`

---

## Supporting Files

The `.specs/` directory is organized as follows:

```
.specs/
├── project/
│   ├── PROJECT.md          # Vision, goals, stack, v1 scope, constraints
│   ├── ROADMAP.md          # (optional) Milestones and feature list
│   └── STATE.md            # (optional) Decisions, blockers, deferred ideas
├── codebase/
│   ├── STACK.md            # Tech stack and key dependencies
│   ├── ARCHITECTURE.md     # Patterns, data flow, modules
│   ├── CONVENTIONS.md      # Naming, style, file structure
│   ├── TESTING.md          # Test framework, organization, conventions
│   └── CONCERNS.md         # Tech debt, fragile areas, security considerations
├── features/
│   ├── [feature-name]/
│   │   ├── spec.md         # Requirements and acceptance criteria
│   │   ├── design.md       # Architecture and components
│   │   └── tasks.md        # Atomic task breakdown
│   └── [feature-2]/
│       └── ...
├── quick/
│   ├── 001-fix-typo.md
│   ├── 002-add-logging.md
│   └── ...
└── HANDOFF.md              # (temporary) Session pause/resume state
```

---

## Tips for Success

1. **Read before writing:** Always load context first (Phase 0). This avoids re-reading the codebase.

2. **One task at a time:** Don't juggle multiple tasks. Finish one, commit, mark done, move to next.

3. **Templates are guides, not laws:** Adapt templates to your project. The goal is clarity, not compliance.

4. **Keep specs lightweight:** Aim for ~1,500 tokens per file. Long specs get stale. Link to code for details.

5. **Use Conventional Commits:** `feat(feature-name):`, `fix(component):`, `test(feature):`, etc.

6. **Pause before big changes:** If you're about to refactor core logic, pause and write a design doc first.

7. **Trust .specs/ files:** Once you've mapped the codebase and documented decisions, don't re-scan unnecessarily.

8. **Specs are living documents:** When implementation reveals that a requirement was wrong, incomplete, or needs changing — update spec.md first, then continue implementing. Don't let specs become stale. The spec is the source of truth.

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| "I don't know what to do next" | Read HANDOFF.md and STATE.md. Ask to "resume work". |
| "Specs are getting stale" | Update them as you learn new things. Use STATE.md for blockers/decisions. |
| "I keep re-reading the same code" | That's a sign to document it in `.specs/codebase/`. Run **Map Codebase**. |
| "Task list is too long" | Break it down further or defer to ROADMAP. Aim for 5–10 tasks per feature. |
| "I'm context-switching too much" | Use **Pause Work** to save state. Resume later with full context restored. |

