# Reference

## Cross-Pattern Relationships

Quick-reference for how GoF patterns relate, combine, and evolve into each other. Individual pattern
definitions are not repeated here — the model already knows them.

### Evolution paths

- Factory Method → Abstract Factory → Builder (increasing creation complexity)
- Factory Method → Prototype (clone-based alternative)

### Composition-based family (similar structure, different intent)

- Bridge, State, Strategy, Adapter — all use composition to delegate

### Recursive composition family

- Composite, Decorator, Chain of Responsibility — recursive wrapping structures

### Request handling alternatives

- Chain of Responsibility, Command, Mediator, Observer — different sender/receiver connections

### Undo support

- Command + Memento (commands for operations, mementos for state snapshots)

### Traversal + operations

- Iterator + Visitor (iterate + execute heterogeneous operations)
- Iterator + Composite (traverse tree structures)

### Commonly paired

- Abstract Factory + Bridge (encapsulate implementation relations)
- Builder + Composite (construct tree structures)
- Factory Method + Template Method (factory step within algorithm skeleton)
- Strategy + Factory Method (create strategies dynamically)
- Decorator + Strategy (external wrapping vs. internal algorithm swap)

## Dependency Categories

When assessing a candidate, classify its dependencies:

### 1. In-process

Pure computation, in-memory state, no I/O. Always deepenable — just merge the modules and test
directly.

### 2. Local-substitutable

Dependencies that have local test stand-ins (e.g., PGLite for Postgres, in-memory filesystem).
Deepenable if the test substitute exists. The deepened module is tested with the local stand-in
running in the test suite.

### 3. Remote but owned (Ports & Adapters)

Your own services across a network boundary (microservices, internal APIs). Define a port (interface)
at the module boundary. The deep module owns the logic; the transport is injected. Tests use an
in-memory adapter. Production uses the real HTTP/gRPC/queue adapter.

Recommendation shape: "Define a shared interface (port), implement an HTTP adapter for production and
an in-memory adapter for testing, so the logic can be tested as one deep module even though it's
deployed across a network boundary."

### 4. True external (Mock)

Third-party services (Stripe, Twilio, etc.) you don't control. Mock at the boundary. The deepened
module takes the external dependency as an injected port, and tests provide a mock implementation.

## Testing Strategy

The core principle: **replace, don't layer.**

- Old unit tests on shallow modules are waste once boundary tests exist — delete them
- Write new tests at the deepened module's interface boundary
- Tests assert on observable outcomes through the public interface, not internal state
- Tests should survive internal refactors — they describe behavior, not implementation
