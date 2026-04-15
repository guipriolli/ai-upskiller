# Reference: Code Smells & Refactoring Techniques

Based on Martin Fowler's refactoring catalog as documented on refactoring.guru.

---

## Code Smells

### Bloaters

Code that has grown too large to be easily understood or maintained.

#### Long Method
A method with too many lines of logic, making it hard to understand and test.
- **Heuristics**: >20 lines of logic; multiple levels of nesting; inline comments explaining
  sections; multiple return points
- **Techniques**: Extract Method, Replace Temp with Query, Introduce Parameter Object,
  Decompose Conditional

#### Large Class
A class that does too many things, accumulating too many fields and methods.
- **Heuristics**: >300 lines; >7 public methods; >3 distinct responsibilities; name includes
  "Manager", "Handler", "Processor", "Utils"
- **Techniques**: Extract Class, Extract Subclass, Extract Interface

#### Primitive Obsession
Using primitive types instead of small objects for simple tasks (money, ranges, phone numbers).
- **Heuristics**: >3 related primitives passed together; string parsing/formatting scattered
  across code; type codes used instead of classes
- **Techniques**: Replace Data Value with Object, Replace Type Code with Class, Replace Type Code
  with Subclasses, Introduce Parameter Object, Replace Array with Object

#### Long Parameter List
More than three parameters in a method signature.
- **Heuristics**: >3 parameters; several parameters always passed together; boolean flag
  parameters that switch behavior
- **Techniques**: Introduce Parameter Object, Preserve Whole Object, Replace Parameter with
  Method Call

#### Data Clumps
Groups of data that appear together repeatedly across the codebase.
- **Heuristics**: same 3+ fields in multiple classes; same 3+ parameters in multiple method
  signatures; removing one field from the group would make the rest meaningless
- **Techniques**: Extract Class, Introduce Parameter Object, Preserve Whole Object

---

### Object-Orientation Abusers

Incomplete or incorrect application of object-oriented principles.

#### Switch Statements
Complex switch/match operators or sequences of if-else that dispatch on type.
- **Heuristics**: switch/match on type with >3 cases; duplicated switch across multiple
  locations; adding a new type requires updating multiple switches
- **Techniques**: Replace Conditional with Polymorphism, Replace Type Code with Subclasses,
  Replace Type Code with State/Strategy, Introduce Null Object

#### Temporary Field
A field that is set only under certain circumstances and is null/unused otherwise.
- **Heuristics**: field initialized in some methods but not the constructor; null checks on
  the field scattered through the class; field only meaningful during a specific operation
- **Techniques**: Extract Class, Introduce Null Object, Replace Temp with Query

#### Refused Bequest
A subclass uses only some of the methods and properties inherited from its parent.
- **Heuristics**: subclass overrides parent methods to no-op or throw; subclass ignores
  >50% of inherited interface; subclass only uses parent for code reuse, not substitutability
- **Techniques**: Replace Inheritance with Delegation, Extract Superclass, Push Down Method,
  Push Down Field

#### Alternative Classes with Different Interfaces
Two classes that perform similar functions but have different method names.
- **Heuristics**: two classes with similar fields and logic but different method signatures;
  callers choose between them based on context; they could be used interchangeably with
  renaming
- **Techniques**: Rename Method, Extract Superclass, Extract Interface, Move Method

---

### Change Preventers

Patterns that make code changes disproportionately expensive.

#### Divergent Change
One class is commonly changed for multiple different reasons.
- **Heuristics**: recent git history shows the class modified in >2 unrelated features; class
  has methods belonging to different domains; different developers modify different sections
- **Techniques**: Extract Class, Extract Superclass, Extract Subclass

#### Shotgun Surgery
A single logical change requires many small edits across multiple classes.
- **Heuristics**: adding a field requires updating >3 files; a feature flag must be checked in
  many places; changing a business rule touches unrelated modules
- **Techniques**: Move Method, Move Field, Inline Class, Extract Class

#### Parallel Inheritance Hierarchies
Creating a subclass in one hierarchy requires creating a corresponding subclass in another.
- **Heuristics**: class name prefixes mirror across two hierarchies; adding a type in one
  package always requires adding one in another; hierarchies have 1:1 correspondence
- **Techniques**: Move Method, Move Field (collapse one hierarchy into the other)

---

### Dispensables

Code that is unnecessary and whose removal makes the codebase cleaner.

#### Comments
Excessive comments that explain *what* the code does rather than *why*.
- **Heuristics**: comments restating the code in English; commented-out code blocks; TODOs
  older than 6 months; comments compensating for bad naming
- **Techniques**: Extract Method (make code self-documenting), Rename Method, Introduce
  Assertion

#### Duplicate Code
Identical or near-identical code fragments in multiple places.
- **Heuristics**: >5 lines of identical logic in 2+ locations; copy-paste with minor parameter
  changes; same bug fixed in multiple places
- **Techniques**: Extract Method, Extract Class, Pull Up Method, Form Template Method,
  Substitute Algorithm

#### Lazy Class
A class that doesn't do enough to justify its existence.
- **Heuristics**: <3 methods; <30 lines; delegates everything to another class; was created for
  a future need that never materialized
- **Techniques**: Inline Class, Collapse Hierarchy

#### Data Class
A class with only fields, getters, and setters but no meaningful behavior.
- **Heuristics**: no methods beyond accessors; all logic that uses this class lives elsewhere;
  class is passed around but never asked to do anything
- **Techniques**: Move Method (move behavior into the data class), Encapsulate Field,
  Encapsulate Collection, Remove Setting Method

#### Dead Code
Code that is never executed or referenced.
- **Heuristics**: methods with no callers; parameters never read; variables assigned but never
  used; unreachable branches after early returns
- **Techniques**: Remove (delete the dead code), Inline Method (if partially dead),
  Remove Parameter

#### Speculative Generality
Abstractions created for hypothetical future needs that have not materialized.
- **Heuristics**: interface with exactly one implementation; abstract class with one subclass;
  method parameters used by no caller; delegation class that adds no value
- **Techniques**: Collapse Hierarchy, Inline Class, Remove Parameter, Rename Method

---

### Couplers

Patterns that create excessive coupling between classes.

#### Feature Envy
A method that accesses the data of another object more than its own.
- **Heuristics**: method calls getters on another object >3 times; method's logic is primarily
  about another object's state; method would make more sense in the other class
- **Techniques**: Move Method, Extract Method (then Move Method)

#### Inappropriate Intimacy
Two classes that access each other's internal fields or private methods.
- **Heuristics**: classes reference each other's private/protected members; bidirectional
  dependencies; one class reaches into another's internal data structure
- **Techniques**: Move Method, Move Field, Extract Class, Hide Delegate,
  Replace Inheritance with Delegation

#### Message Chains
A client asks one object for another, then asks that object for yet another, and so on.
- **Heuristics**: >3 chained accessor calls (`a.getB().getC().getD()`); navigating a deep
  object graph to reach data; changes to intermediate objects break distant callers
- **Techniques**: Hide Delegate, Extract Method, Move Method

#### Middle Man
A class where the majority of methods simply delegate to another object.
- **Heuristics**: >50% of methods are one-line delegations; class adds no logic or state of
  its own; removing the class would simplify callers
- **Techniques**: Remove Middle Man, Inline Method, Replace Delegation with Inheritance

---

---

## Smell-to-Technique Quick Reference

| # | Smell | Category | Primary Techniques | Secondary Techniques |
|---|-------|----------|--------------------|----------------------|
| 1 | Long Method | Bloaters | Extract Method | Replace Temp with Query, Decompose Conditional, Replace Method with Method Object |
| 2 | Large Class | Bloaters | Extract Class, Extract Subclass | Extract Interface, Duplicate Observed Data |
| 3 | Primitive Obsession | Bloaters | Replace Data Value with Object, Replace Type Code with Class | Introduce Parameter Object, Replace Array with Object, Replace Type Code with Subclasses |
| 4 | Long Parameter List | Bloaters | Introduce Parameter Object, Preserve Whole Object | Replace Parameter with Method Call |
| 5 | Data Clumps | Bloaters | Extract Class, Introduce Parameter Object | Preserve Whole Object |
| 6 | Switch Statements | OO Abusers | Replace Conditional with Polymorphism | Replace Type Code with Subclasses, Replace Type Code with State/Strategy, Introduce Null Object |
| 7 | Temporary Field | OO Abusers | Extract Class | Introduce Null Object, Replace Temp with Query |
| 8 | Refused Bequest | OO Abusers | Replace Inheritance with Delegation | Push Down Method, Push Down Field, Extract Superclass |
| 9 | Alternative Classes with Different Interfaces | OO Abusers | Rename Method, Extract Superclass | Extract Interface, Move Method |
| 10 | Divergent Change | Change Preventers | Extract Class | Extract Superclass, Extract Subclass |
| 11 | Shotgun Surgery | Change Preventers | Move Method, Move Field | Inline Class, Extract Class |
| 12 | Parallel Inheritance Hierarchies | Change Preventers | Move Method, Move Field | Collapse Hierarchy |
| 13 | Comments | Dispensables | Extract Method, Rename Method | Introduce Assertion |
| 14 | Duplicate Code | Dispensables | Extract Method, Pull Up Method | Extract Class, Form Template Method, Substitute Algorithm |
| 15 | Lazy Class | Dispensables | Inline Class | Collapse Hierarchy |
| 16 | Data Class | Dispensables | Move Method, Encapsulate Field | Encapsulate Collection, Remove Setting Method |
| 17 | Dead Code | Dispensables | Remove (delete) | Inline Method, Remove Parameter |
| 18 | Speculative Generality | Dispensables | Collapse Hierarchy, Inline Class | Remove Parameter, Rename Method |
| 19 | Feature Envy | Couplers | Move Method | Extract Method (then Move Method) |
| 20 | Inappropriate Intimacy | Couplers | Move Method, Move Field | Extract Class, Hide Delegate, Replace Inheritance with Delegation |
| 21 | Message Chains | Couplers | Hide Delegate | Extract Method, Move Method |
| 22 | Middle Man | Couplers | Remove Middle Man | Inline Method, Replace Delegation with Inheritance |
