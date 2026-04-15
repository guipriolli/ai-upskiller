# Reference: Code Smells & Refactoring Techniques

Based on Martin Fowler's refactoring catalog as documented on refactoring.guru.

---

## Numeric Thresholds for Code Smells

- **Long Method**: >20 lines of logic
- **Large Class**: >300 lines; >7 public methods; >3 distinct responsibilities
- **Primitive Obsession / Long Parameter List**: >3 primitives or parameters passed together
- **Data Clumps**: 3+ identical fields or parameters in multiple locations
- **Switch Statements**: >3 cases explicitly dispatching on type
- **Refused Bequest**: subclass ignores >50% of inherited interface
- **Divergent Change**: class modified in >2 unrelated features
- **Shotgun Surgery**: single change requires updating >3 files
- **Duplicate Code**: >5 lines of identical logic in 2+ locations
- **Lazy Class**: <3 methods or <30 lines total
- **Feature Envy**: method calls getters on another object >3 times
- **Message Chains**: >3 chained accessor calls (e.g., `a.getB().getC().getD()`)
- **Middle Man**: >50% of methods are one-line delegations

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
