---
name: codebase-architecture-advisor
description: Explore a codebase to identify where Gang of Four design patterns can resolve structural problems. Use when the user wants to find pattern opportunities, reduce code duplication through proven abstractions, decouple tightly-bound components, or improve extensibility.
---

# Codebase Architecture Advisor

Explore a codebase, surface structural friction, and propose concrete design pattern applications
from the Gang of Four catalog (as described on refactoring.guru/design-patterns).

A **design pattern** is a typical solution to a commonly occurring problem in software design. It is
not copy-paste code — it is a blueprint you customize to fit the specific problem in the codebase.
Patterns are organized into three categories: **Creational** (object creation), **Structural**
(object composition), and **Behavioral** (object communication and responsibility assignment). See
[REFERENCE.md](REFERENCE.md) for cross-pattern relationships.

## Process

### 1. Scope and explore the codebase

First, ask the user: **"Do you have a specific subsystem, module, or concern area in mind — or would
you like a broad exploration of the entire codebase?"** Wait for their answer before exploring. Use
their response to focus your exploration on the relevant area(s).

Use the Agent tool with `subagent_type=Explore` to navigate the codebase naturally. Do NOT follow
rigid heuristics — explore organically and note where you experience friction:

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

The friction you encounter IS the signal.

### 2. Present candidates

Present a numbered list of design pattern opportunities. For each candidate, show:

- **Location**: Which files, classes, or modules are involved
- **Smell**: The structural problem observed (e.g., "constructor with 12 optional parameters",
  "switch on type in 4 places", "every new payment method requires editing 3 classes")
- **Pattern**: The recommended design pattern and its category
- **Why it fits**: How the pattern's intent maps to the observed problem
- **Impact**: What improves — extensibility, testability, readability, or decoupling

If no design pattern is warranted, say so. The analysis may conclude with "the current structure is
fine" or "a simple refactor (extract method, rename, inline) is more appropriate than a design
pattern." Do not force-fit patterns where they add complexity without clear benefit.

Do NOT propose implementations yet. Ask the user: "Which of these would you like to explore?"

### 3. User picks a candidate

### 4. Frame the problem space

Before spawning sub-agents, write a user-facing explanation of the chosen candidate:

- The structural problem in concrete terms (with file paths and code references)
- The design pattern's intent and how it maps to this problem
- The participants/roles the pattern requires (e.g., for Strategy: Context, Strategy interface,
  Concrete Strategies) and which existing code maps to each role
- A rough illustrative code sketch showing the pattern applied — this is not a proposal, just a way
  to ground the discussion

Show this to the user, then immediately proceed to Step 5. The user reads and thinks about the
problem while the sub-agents work in parallel.

### 5. Design multiple implementations

Spawn 3+ sub-agents in parallel using the Agent tool. Each must produce a **distinct
implementation** of the chosen pattern tailored to the codebase.

Prompt each sub-agent with a technical brief (file paths, current structure, pattern participants,
language/framework constraints). Give each agent a different design constraint:

- Agent 1: "Minimal changes — apply the pattern with the smallest diff possible"
- Agent 2: "Full pattern — implement the textbook structure with all participants, optimizing for
  future extensibility"
- Agent 3: "Pragmatic hybrid — combine elements of the chosen pattern with related patterns where
  it simplifies the result" (e.g., Strategy + Factory Method, Decorator + Composite)
- Agent 4 (if applicable): "Language-idiomatic — use language features (lambdas, generics, traits,
  protocols) to achieve the pattern's intent with less boilerplate"

Each sub-agent outputs a **concise summary** (not a full implementation):

1. Interface/class signatures (types, methods, params)
2. A short usage example showing how callers interact with the new structure
3. Which related patterns it leverages (see [REFERENCE.md](REFERENCE.md) for cross-pattern
   relationships)
4. Trade-offs (complexity added vs. problem solved)

Keep each design brief — detailed implementation code is deferred to Step 7 after the user picks a
design.

Present designs sequentially, then compare them in prose.

After comparing, give your own recommendation: which design you think is strongest and why. If
elements from different designs combine well, propose a hybrid. Be opinionated — the user wants a
strong read, not just a menu.

### 6. User picks an implementation (or accepts recommendation)

### 7. Implementation

- Implement the user's choice
- Write unit tests that match or exceed the project's existing test coverage style
- Run tests with coverage and improve tests if necessary
- Run build to certify nothing has broken
