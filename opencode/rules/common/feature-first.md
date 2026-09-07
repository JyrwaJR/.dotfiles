---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# Feature-First Architecture (Common)

> Language-agnostic feature-first architecture patterns.

## Core Principle

Organize code by **feature/domain**, not by technical layer.

```text
BAD:  src/controllers/, src/services/, src/models/
GOOD: src/features/auth/, src/features/users/, src/features/posts/
```

## Directory Structure

### Feature Directory

Each feature contains everything needed for that domain:

```text
features/
└── users/
    ├── components/       # UI components
    ├── hooks/            # React hooks / custom hooks
    ├── services/         # Business logic
    ├── store/            # State management
    ├── types/            # TypeScript types
    ├── utils/            # Feature-specific utilities
    ├── tests/            # Feature tests
    └── index.ts          # Public API
```

### Public API Pattern

Each feature exports through index.ts:

```typescript
// features/users/index.ts
export { UserCard, UserList } from './components'
export { useUsers } from './hooks'
export type { User, CreateUserDto } from './types'
```

### Import Rules

```text
BAD:  import from @/features/users/components/UserCard
GOOD: import { UserCard } from '@/features/users'

BAD:  Feature A imports from Feature B's internals
GOOD: Feature A imports from Feature B's public API
```

## Shared Code

### Shared Directory

Common code used across features:

```text
shared/
├── components/       # Reusable UI components
├── hooks/            # Shared hooks
├── lib/              # Utilities, API client
├── services/         # Shared services
└── types/            # Common types
```

### Import Priority

1. Feature's own code
2. Shared code
3. External libraries

## Cross-Feature Communication

### Event Bus Pattern

```typescript
// Shared event bus
eventBus.emit('user:created', { userId })
eventBus.on('user:created', handler)
```

### Props/Callbacks

Parent components pass data down:

```typescript
<UserCard user={user} onSelect={handleSelect} />
```

## Testing Strategy

### Feature Tests

Co-located with feature code:

```text
features/users/
├── components/
│   └── UserCard.test.tsx
├── hooks/
│   └── useUsers.test.ts
└── services/
    └── users.service.test.ts
```

### Integration Tests

Test feature boundaries:

```text
tests/integration/
└── user-registration.test.ts
```

## Benefits

1. **High Cohesion** - Related code lives together
2. **Low Coupling** - Features are independent
3. **Easy Navigation** - Find code by domain
4. **Scalable** - Add new features without touching existing ones
5. **Testable** - Features can be tested in isolation

## Checklist

- [ ] Code organized by feature/domain
- [ ] Each feature has a public API
- [ ] Features don't import from other features' internals
- [ ] Shared code in shared/ directory
- [ ] Tests co-located with feature code
- [ ] Cross-feature communication via events or props
