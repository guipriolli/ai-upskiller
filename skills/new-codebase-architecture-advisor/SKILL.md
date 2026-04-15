---
name: new-codebase-architecture-advisor
description: Explore a codebase to identify architectural improvements — from Gang of Four design patterns to module-deepening refactors. Use when the user wants to resolve structural friction, reduce coupling, improve extensibility or testability, consolidate tightly-coupled modules, or apply proven design patterns.
---

# Codebase Architecture Advisor

Explore a codebase, surface structural friction, and propose concrete architectural improvements
drawing from both the Gang of Four design pattern catalog and John Ousterhout's deep module
philosophy.

A **design pattern** is a typical solution to a commonly occurring problem in software design — a
blueprint you customize to fit the specific problem. A **deep module** has a small interface hiding a
large implementation, making the system more testable and navigable. These lenses are complementary:
patterns organize inter-class relationships, while module depth guides where boundaries should be.
See [REFERENCE.md](REFERENCE.md) for cross-pattern relationships, dependency categories, and testing
strategy.

## Process

### 1. Scope and explore the codebase

First, ask the user: **"Do you have a specific subsystem, module, or concern area in mind — or would
you like a broad exploration of the entire codebase?"** Wait for their answer before exploring. Use
their response to focus your exploration on the relevant area(s).

Use the Agent tool with `subagent_type=Explore` to navigate the codebase naturally. Do NOT follow
rigid heuristics — explore organically and note where you experience friction:

**Pattern-level signals:**

- Where does adding a new variant require touching many files or duplicating logic? *(may need a
  creational pattern: Factory Method, Abstract Factory, Builder, Prototype)*
- Where is object creation scattered with `new` calls tightly coupled to concrete classes?
- Where do classes grow bloated because multiple optional behaviors are composed via inheritance
  instead of composition? *(Decorator, Strategy)*
- Where do subsystem integrations force callers to understand too many internal details? *(Facade)*
- Where do objects with incompatible interfaces need to collaborate? *(Adapter)*
- Where are large conditional blocks selecting behavior based on type or state? *(State, Strategy,
  Chain of Responsibility)*
- Where do changes to one class cascade into unrelated classes? *(Mediator, Observer)*
- Where is traversal logic tangled with business logic? *(Iterator, Visitor)*
- Where do classes mix construction complexity with domain logic? *(Builder, Factory Method)*

**Module-depth signals:**

- Where does understanding one concept require bouncing between many small files?
- Where are modules so shallow that the interface is nearly as complex as the implementation?
- Where have pure functions been extracted just for testability, but the real bugs hide in how
  they're called?
- Where do tightly-coupled modules create integration risk in the seams between them?
- Which parts of the codebase are untested, or hard to test?

The friction you encounter IS the signal.

### 2. Present candidates

Present a numbered list of architectural improvement opportunities. For each candidate, show:

- **Location**: Which files, classes, or modules are involved
- **Smell**: The structural problem observed (e.g., "constructor with 12 optional parameters",
  "switch on type in 4 places", "5 shallow modules that all share the same types")
- **Approach**: Either a named GoF pattern (with category) OR a deepening strategy (merge modules,
  redefine boundary, hide implementation behind narrower interface)
- **Dependency category**: Classify involved dependencies — In-process / Local-substitutable /
  Remote-owned / True-external (see [REFERENCE.md](REFERENCE.md))
- **Impact**: What improves — extensibility, testability, readability, or decoupling
- **Test impact**: What existing tests would be replaced, what new boundary tests are needed

If no architectural change is warranted, say so. The analysis may conclude with "the current
structure is fine" or "a simple refactor (extract method, rename, inline) is more appropriate than a
design pattern or module restructuring." Do not force-fit patterns or restructuring where they add
complexity without clear benefit.

Do NOT propose implementations yet. Ask the user: "Which of these would you like to explore?"

### 3. User picks a candidate

### 4. Frame the problem space

Before spawning sub-agents, write a user-facing explanation of the chosen candidate:

- The structural problem in concrete terms (with file paths and code references)
- The pattern intent or module boundary constraints — why this particular approach fits
- For patterns: the participants/roles the pattern requires and which existing code maps to each role
- For module deepening: the constraints any new interface would need to satisfy and the dependencies
  it would need to manage
- A rough illustrative code sketch showing the improvement applied — this is not a proposal, just a
  way to ground the discussion

Show this to the user, then immediately proceed to Step 5. The user reads and thinks about the
problem while the sub-agents work in parallel.

### 5. Design multiple implementations

Spawn 3+ sub-agents in parallel using the Agent tool. Each must produce a **distinct
implementation** of the chosen improvement tailored to the codebase.

Prompt each sub-agent with a technical brief (file paths, current structure, pattern participants or
coupling details, dependency category, language/framework constraints). Give each agent a different
design constraint:

- Agent 1: "Minimal changes — apply the improvement with the smallest diff possible"
- Agent 2: "Full pattern / deep module — implement the textbook structure with all participants,
  optimizing for future extensibility"
- Agent 3: "Pragmatic hybrid — combine elements of related patterns, or use ports & adapters where
  it simplifies cross-boundary dependencies" (e.g., Strategy + Factory Method, or merge modules
  behind a port interface)
- Agent 4 (if applicable): "Language-idiomatic — use language features (lambdas, generics, traits,
  protocols) to achieve the intent with less boilerplate"

Each sub-agent outputs a **concise summary** (not a full implementation):

1. Interface/class signatures (types, methods, params)
2. A short usage example showing how callers interact with the new structure
3. Related patterns leveraged (see [REFERENCE.md](REFERENCE.md) for cross-pattern relationships)
4. Dependency strategy (how deps are handled — see [REFERENCE.md](REFERENCE.md) for categories)
5. Trade-offs (complexity added vs. problem solved)

Keep each design brief — detailed implementation code is deferred to Step 7 after the user picks a
design.

Present designs sequentially, then compare them in prose.

After comparing, give your own recommendation: which design you think is strongest and why. If
elements from different designs combine well, propose a hybrid. Be opinionated — the user wants a
strong read, not just a menu.

### 6. User picks an implementation (or accepts recommendation)

### 7. Implementation

- Implement the user's choice
- Testing philosophy: **replace, don't layer** — write boundary tests at the new module's public
  interface, delete obsolete shallow tests that tested internals now hidden behind the new boundary.
  Tests should assert on observable outcomes and survive internal refactors.
- Run tests with coverage and improve tests if necessary
- Run build to certify nothing has broken
