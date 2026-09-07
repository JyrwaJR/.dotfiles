---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# SOLID Principles & Clean Code (Common)

> Language-agnostic SOLID principles and clean code patterns.

## SOLID Principles

### Single Responsibility Principle (SRP)

Each module, class, or function should have one reason to change.

```text
BAD:  UserService handles auth, emails, and database
GOOD: AuthService, EmailService, UserRepository - each with one job
```

### Open/Closed Principle (OCP)

Open for extension, closed for modification.

```text
BAD:  Modify NotificationService to add SMS
GOOD: Add SMSNotification class implementing NotificationChannel
```

### Liskov Substitution Principle (LSP)

Subtypes must be substitutable for their base types.

```text
BAD:  Square extends Rectangle (breaks area calculation)
GOOD: Both Rectangle and Square implement Shape interface
```

### Interface Segregation Principle (ISP)

Clients shouldn't depend on interfaces they don't use.

```text
BAD:  Fat UserService with 10+ methods
GOOD: UserCreator, UserReader, UserUpdater - each focused
```

### Dependency Inversion Principle (DIP)

Depend on abstractions, not concretions.

```text
BAD:  UserService creates PrismaClient internally
GOOD: UserService receives UserRepository interface via constructor
```

## Clean Code Principles

### Meaningful Names

```text
BAD:  function d(a, b) { return a * b }
GOOD: function calculateArea(width, height) { return width * height }
```

### Small Functions

```text
BAD:  100+ line function doing everything
GOOD: Functions under 30 lines, each with one responsibility
```

### Pure Functions

```text
BAD:  function with side effects, modifies external state
GOOD: Same input always produces same output, no side effects
```

### Immutability

```text
BAD:  Modify objects in place
GOOD: Create new objects with changes applied
```

### Guard Clauses

```text
BAD:  Deep nesting (4+ levels)
GOOD: Early returns for error conditions
```

### Composition Over Inheritance

```text
BAD:  Deep inheritance hierarchy (Animal > Mammal > Dog > GuideDog)
GOOD: Compose behaviors via interfaces and dependency injection
```

## Code Smells to Avoid

| Smell | Fix |
|-------|-----|
| God Class | Split into focused classes |
| Long Method | Extract small functions |
| Feature Envy | Move logic to the data it uses |
| Primitive Obsession | Use value objects |
| Switch Statements | Use polymorphism |
| Parallel Inheritance | Use composition |
| Speculative Generality | Delete unused code |
| Dead Code | Remove immediately |

## Refactoring Checklist

Before refactoring:

- [ ] Existing tests pass
- [ ] Characterization tests added (if none exist)
- [ ] Changes are behavior-preserving
- [ ] Small, verifiable steps
- [ ] Tests run after each step

After refactoring:

- [ ] All tests still pass
- [ ] Code is more readable
- [ ] No new abstractions added
- [ ] No features changed
