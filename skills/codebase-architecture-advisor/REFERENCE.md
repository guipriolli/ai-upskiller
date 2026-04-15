# Reference — Cross-Pattern Relationships

Quick-reference for how GoF patterns relate, combine, and evolve into each other. Individual pattern
definitions are not repeated here — the model already knows them.

## Evolution paths

- Factory Method → Abstract Factory → Builder (increasing creation complexity)
- Factory Method → Prototype (clone-based alternative)

## Composition-based family (similar structure, different intent)

- Bridge, State, Strategy, Adapter — all use composition to delegate

## Recursive composition family

- Composite, Decorator, Chain of Responsibility — recursive wrapping structures

## Request handling alternatives

- Chain of Responsibility, Command, Mediator, Observer — different sender/receiver connections

## Undo support

- Command + Memento (commands for operations, mementos for state snapshots)

## Traversal + operations

- Iterator + Visitor (iterate + execute heterogeneous operations)
- Iterator + Composite (traverse tree structures)

## Commonly paired

- Abstract Factory + Bridge (encapsulate implementation relations)
- Builder + Composite (construct tree structures)
- Factory Method + Template Method (factory step within algorithm skeleton)
- Strategy + Factory Method (create strategies dynamically)
- Decorator + Strategy (external wrapping vs. internal algorithm swap)
