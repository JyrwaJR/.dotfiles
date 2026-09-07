---
paths:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
---
# Feature-First Architecture

> This file extends [common/patterns.md](../common/patterns.md) with feature-first architecture patterns.

## Directory Structure

### Feature-First Organization

```text
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── RegisterForm.tsx
│   │   │   └── index.ts
│   │   ├── hooks/
│   │   │   ├── useAuth.ts
│   │   │   └── useLogin.ts
│   │   ├── services/
│   │   │   ├── auth.service.ts
│   │   │   └── auth.api.ts
│   │   ├── store/
│   │   │   └── auth.store.ts
│   │   ├── types/
│   │   │   └── index.ts
│   │   ├── utils/
│   │   │   └── auth.utils.ts
│   │   └── index.ts              # Public API
│   ├── users/
│   │   ├── components/
│   │   │   ├── UserCard.tsx
│   │   │   ├── UserList.tsx
│   │   │   └── index.ts
│   │   ├── hooks/
│   │   │   └── useUsers.ts
│   │   ├── services/
│   │   │   ├── users.service.ts
│   │   │   └── users.api.ts
│   │   ├── types/
│   │   │   └── index.ts
│   │   └── index.ts
│   └── posts/
│       ├── components/
│       │   ├── PostCard.tsx
│       │   ├── PostList.tsx
│       │   └── index.ts
│       ├── hooks/
│       │   └── usePosts.ts
│       ├── services/
│       │   ├── posts.service.ts
│       │   └── posts.api.ts
│       ├── types/
│       │   └── index.ts
│       └── index.ts
├── shared/
│   ├── components/
│   │   ├── ui/
│   │   │   ├── Button.tsx
│   │   │   ├── Input.tsx
│   │   │   └── index.ts
│   │   └── layout/
│   │       ├── Header.tsx
│   │       ├── Sidebar.tsx
│   │       └── index.ts
│   ├── hooks/
│   │   ├── useDebounce.ts
│   │   ├── useLocalStorage.ts
│   │   └── index.ts
│   ├── lib/
│   │   ├── api.ts
│   │   ├── logger.ts
│   │   └── utils.ts
│   ├── services/
│   │   ├── email.service.ts
│   │   └── storage.service.ts
│   └── types/
│       └── index.ts
├── app/                          # App shell (pages/routes)
│   ├── (auth)/
│   │   ├── login/
│   │   │   └── page.tsx
│   │   └── register/
│   │       └── page.tsx
│   ├── (dashboard)/
│   │   ├── page.tsx
│   │   └── settings/
│   │       └── page.tsx
│   ├── layout.tsx
│   └── page.tsx
├── config/
│   ├── database.ts
│   └── env.ts
└── index.ts
```

## Feature Boundaries

### Public API (index.ts)

Each feature exposes a public API through its index.ts:

```typescript
// features/auth/index.ts
export { LoginForm } from './components/LoginForm'
export { RegisterForm } from './components/RegisterForm'
export { useAuth } from './hooks/useAuth'
export { useLogin } from './hooks/useLogin'
export type { User, AuthState, LoginCredentials } from './types'
```

### Import Rules

```typescript
// WRONG: Importing from internal paths
import { LoginForm } from '@/features/auth/components/LoginForm'
import { useAuth } from '@/features/auth/hooks/useAuth'

// CORRECT: Import from public API
import { LoginForm, useAuth } from '@/features/auth'

// WRONG: Feature importing from another feature's internals
import { UserCard } from '@/features/users/components/UserCard'

// CORRECT: Feature importing from shared
import { Button } from '@/shared/components/ui'
```

## Feature Types

### TypeScript Types

```typescript
// features/users/types/index.ts
export interface User {
  id: string
  name: string
  email: string
  avatar?: string
  role: UserRole
  createdAt: Date
  updatedAt: Date
}

export type UserRole = 'admin' | 'member' | 'viewer'

export interface CreateUserDto {
  name: string
  email: string
  password: string
  role?: UserRole
}

export interface UpdateUserDto {
  name?: string
  email?: string
  avatar?: string
  role?: UserRole
}

export interface UserFilters {
  role?: UserRole
  search?: string
  page?: number
  limit?: number
}
```

## Feature Services

### Service Layer

```typescript
// features/users/services/users.service.ts
import { prisma } from '@/config/database'
import { UserRepository } from './users.repository'
import {
  User,
  CreateUserDto,
  UpdateUserDto,
  UserFilters,
} from '../types'

export class UsersService {
  constructor(private repository: UserRepository) {}

  async findAll(filters: UserFilters): Promise<User[]> {
    return this.repository.findMany(filters)
  }

  async findById(id: string): Promise<User | null> {
    return this.repository.findById(id)
  }

  async create(data: CreateUserDto): Promise<User> {
    // Check for duplicate email
    const existing = await this.repository.findByEmail(data.email)
    if (existing) {
      throw new Error('Email already exists')
    }

    return this.repository.create(data)
  }

  async update(id: string, data: UpdateUserDto): Promise<User | null> {
    const existing = await this.repository.findById(id)
    if (!existing) {
      return null
    }

    return this.repository.update(id, data)
  }

  async delete(id: string): Promise<boolean> {
    const existing = await this.repository.findById(id)
    if (!existing) {
      return false
    }

    await this.repository.delete(id)
    return true
  }
}
```

### API Layer

```typescript
// features/users/services/users.api.ts
import { api } from '@/shared/lib/api'
import {
  User,
  CreateUserDto,
  UpdateUserDto,
  UserFilters,
} from '../types'

export const usersApi = {
  async findAll(filters: UserFilters): Promise<User[]> {
    const params = new URLSearchParams()
    if (filters.role) params.append('role', filters.role)
    if (filters.search) params.append('search', filters.search)
    if (filters.page) params.append('page', String(filters.page))
    if (filters.limit) params.append('limit', String(filters.limit))

    return api.get(`/users?${params.toString()}`)
  },

  async findById(id: string): Promise<User> {
    return api.get(`/users/${id}`)
  },

  async create(data: CreateUserDto): Promise<User> {
    return api.post('/users', data)
  },

  async update(id: string, data: UpdateUserDto): Promise<User> {
    return api.put(`/users/${id}`, data)
  },

  async delete(id: string): Promise<void> {
    return api.delete(`/users/${id}`)
  },
}
```

## Feature Hooks

### Custom Hooks

```typescript
// features/users/hooks/useUsers.ts
import { useState, useEffect } from 'react'
import { usersApi } from '../services/users.api'
import { User, UserFilters } from '../types'

export function useUsers(filters: UserFilters = {}) {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let cancelled = false

    async function fetchUsers() {
      try {
        setLoading(true)
        const data = await usersApi.findAll(filters)
        if (!cancelled) {
          setUsers(data)
          setError(null)
        }
      } catch (err) {
        if (!cancelled) {
          setError(err instanceof Error ? err.message : 'Failed to fetch users')
        }
      } finally {
        if (!cancelled) {
          setLoading(false)
        }
      }
    }

    fetchUsers()

    return () => {
      cancelled = true
    }
  }, [JSON.stringify(filters)])

  return { users, loading, error }
}
```

### React Query Pattern

```typescript
// features/users/hooks/useUsers.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { usersApi } from '../services/users.api'
import { UserFilters, CreateUserDto } from '../types'

export function useUsers(filters: UserFilters = {}) {
  return useQuery({
    queryKey: ['users', filters],
    queryFn: () => usersApi.findAll(filters),
  })
}

export function useUser(id: string) {
  return useQuery({
    queryKey: ['users', id],
    queryFn: () => usersApi.findById(id),
    enabled: !!id,
  })
}

export function useCreateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: CreateUserDto) => usersApi.create(data),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['users'] })
    },
  })
}
```

## Feature Components

### Component Organization

```tsx
// features/users/components/UserCard.tsx
import { User } from '../types'
import { format } from 'date-fns'

interface UserCardProps {
  user: User
  onSelect: (user: User) => void
}

export function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <div
      className="p-4 border rounded-lg hover:shadow-md cursor-pointer"
      onClick={() => onSelect(user)}
    >
      <div className="flex items-center gap-3">
        {user.avatar && (
          <img
            src={user.avatar}
            alt={user.name}
            className="w-10 h-10 rounded-full"
          />
        )}
        <div>
          <h3 className="font-medium">{user.name}</h3>
          <p className="text-sm text-gray-500">{user.email}</p>
        </div>
      </div>
      <div className="mt-2 text-xs text-gray-400">
        Joined {format(user.createdAt, 'MMM d, yyyy')}
      </div>
    </div>
  )
}
```

### Feature Page

```tsx
// app/(dashboard)/users/page.tsx
import { useUsers, UserCard } from '@/features/users'
import { useState } from 'react'

export default function UsersPage() {
  const [filters, setFilters] = useState({ page: 1, limit: 10 })
  const { users, loading, error } = useUsers(filters)

  if (loading) return <div>Loading...</div>
  if (error) return <div>Error: {error}</div>

  return (
    <div>
      <h1>Users</h1>
      <div className="grid gap-4">
        {users.map(user => (
          <UserCard
            key={user.id}
            user={user}
            onSelect={(u) => console.log('Selected:', u)}
          />
        ))}
      </div>
    </div>
  )
}
```

## Cross-Feature Communication

### Events Pattern

```typescript
// shared/lib/events.ts
type EventHandler<T = any> = (data: T) => void

class EventBus {
  private handlers = new Map<string, Set<EventHandler>>()

  on<T>(event: string, handler: EventHandler<T>) {
    if (!this.handlers.has(event)) {
      this.handlers.set(event, new Set())
    }
    this.handlers.get(event)!.add(handler)

    return () => {
      this.handlers.get(event)?.delete(handler)
    }
  }

  emit<T>(event: string, data: T) {
    this.handlers.get(event)?.forEach(handler => handler(data))
  }
}

export const eventBus = new EventBus()

// Usage
// features/auth/services/auth.service.ts
import { eventBus } from '@/shared/lib/events'

export class AuthService {
  async login(credentials: LoginCredentials) {
    const user = await this.authenticate(credentials)
    eventBus.emit('auth:login', { user })
    return user
  }
}

// features/notifications/hooks/useNotifications.ts
import { useEffect } from 'react'
import { eventBus } from '@/shared/lib/events'

export function useNotifications() {
  useEffect(() => {
    const unsubscribe = eventBus.on('auth:login', ({ user }) => {
      // Show welcome notification
    })

    return unsubscribe
  }, [])
}
```

## Testing Features

### Feature Unit Tests

```typescript
// features/users/services/users.service.test.ts
import { describe, it, expect, beforeEach, jest } from 'vitest'
import { UsersService } from './users.service'
import { UserRepository } from './users.repository'

describe('UsersService', () => {
  let service: UsersService
  let mockRepository: jest.Mocked<UserRepository>

  beforeEach(() => {
    mockRepository = {
      findMany: jest.fn(),
      findById: jest.fn(),
      findByEmail: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    }
    service = new UsersService(mockRepository)
  })

  describe('create', () => {
    it('should create user when email is unique', async () => {
      const dto = { name: 'John', email: 'john@example.com', password: 'pass' }
      mockRepository.findByEmail.mockResolvedValue(null)
      mockRepository.create.mockResolvedValue({ id: '1', ...dto })

      const result = await service.create(dto)

      expect(result).toHaveProperty('id')
      expect(mockRepository.create).toHaveBeenCalledWith(dto)
    })

    it('should throw when email exists', async () => {
      mockRepository.findByEmail.mockResolvedValue({
        id: '1',
        email: 'john@example.com',
      })

      await expect(
        service.create({
          name: 'John',
          email: 'john@example.com',
          password: 'pass',
        })
      ).rejects.toThrow('Email already exists')
    })
  })
})
```

### Feature Integration Tests

```typescript
// features/users/users.integration.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import request from 'supertest'
import { app } from '@/app'
import { prisma } from '@/config/database'

describe('Users Feature', () => {
  beforeAll(async () => {
    await prisma.$connect()
  })

  afterAll(async () => {
    await prisma.$disconnect()
  })

  it('should create and retrieve user', async () => {
    // Create
    const createResponse = await request(app)
      .post('/api/users')
      .send({
        name: 'John',
        email: 'john@example.com',
        password: 'Password123',
      })
      .expect(201)

    const userId = createResponse.body.data.id

    // Retrieve
    const getResponse = await request(app)
      .get(`/api/users/${userId}`)
      .expect(200)

    expect(getResponse.body.data.name).toBe('John')
  })
})
```

## Checklist

- [ ] Features organized by domain, not by type
- [ ] Each feature has a public API (index.ts)
- [ ] Features don't import from other features' internals
- [ ] Shared code lives in shared/ directory
- [ ] Types defined per feature
- [ ] Services handle business logic
- [ ] API layer handles HTTP requests
- [ ] Custom hooks encapsulate state logic
- [ ] Components are focused and reusable
- [ ] Cross-feature communication via events
- [ ] Features are independently testable
- [ ] Tests co-located with feature code
