---
paths:
  - "**/*.ts"
  - "**/*.js"
  - "**/*.test.ts"
  - "**/*.test.js"
  - "**/*.spec.ts"
  - "**/*.spec.js"
---
# Node.js Testing

> This file extends [typescript/testing.md](../typescript/testing.md) with Node.js-specific testing content.

## Testing Framework

Use **Vitest** as the primary testing framework for Node.js projects.

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/config/',
        'src/**/*.d.ts',
      ],
    },
  },
})
```

## Unit Testing

### Service Testing

```typescript
// features/users/users.service.test.ts
import { describe, it, expect, beforeEach, jest } from 'vitest'
import { UsersService } from './users.service'
import { NotFoundError, ValidationError } from '@/shared/utils/errors'

describe('UsersService', () => {
  let service: UsersService
  let mockRepository: any

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

  describe('findAll', () => {
    it('should return paginated users', async () => {
      const mockUsers = [
        { id: '1', name: 'John', email: 'john@example.com' },
        { id: '2', name: 'Jane', email: 'jane@example.com' },
      ]
      mockRepository.findMany.mockResolvedValue(mockUsers)

      const result = await service.findAll({ page: 1, limit: 10 })

      expect(result).toEqual(mockUsers)
      expect(mockRepository.findMany).toHaveBeenCalledWith({
        skip: 0,
        take: 10,
      })
    })
  })

  describe('findById', () => {
    it('should return user when found', async () => {
      const mockUser = { id: '1', name: 'John', email: 'john@example.com' }
      mockRepository.findById.mockResolvedValue(mockUser)

      const result = await service.findById('1')

      expect(result).toEqual(mockUser)
    })

    it('should return null when not found', async () => {
      mockRepository.findById.mockResolvedValue(null)

      const result = await service.findById('999')

      expect(result).toBeNull()
    })
  })

  describe('create', () => {
    it('should create user when email is unique', async () => {
      const createUserDto = { name: 'John', email: 'john@example.com' }
      const mockUser = { id: '1', ...createUserDto }

      mockRepository.findByEmail.mockResolvedValue(null)
      mockRepository.create.mockResolvedValue(mockUser)

      const result = await service.create(createUserDto)

      expect(result).toEqual(mockUser)
      expect(mockRepository.create).toHaveBeenCalledWith(createUserDto)
    })

    it('should throw when email already exists', async () => {
      const createUserDto = { name: 'John', email: 'john@example.com' }
      mockRepository.findByEmail.mockResolvedValue({
        id: '1',
        email: 'john@example.com',
      })

      await expect(service.create(createUserDto)).rejects.toThrow(
        'Email already exists'
      )
    })
  })
})
```

### Repository Testing

```typescript
// features/users/users.repository.test.ts
import { describe, it, expect, beforeEach, afterAll } from 'vitest'
import { UsersRepository } from './users.repository'
import { prisma } from '@/config/database'

describe('UsersRepository', () => {
  let repository: UsersRepository

  beforeEach(async () => {
    repository = new UsersRepository()
    // Clean database
    await prisma.user.deleteMany()
  })

  afterAll(async () => {
    await prisma.$disconnect()
  })

  describe('create', () => {
    it('should create a user', async () => {
      const createUserDto = { name: 'John', email: 'john@example.com' }

      const user = await repository.create(createUserDto)

      expect(user).toMatchObject({
        id: expect.any(String),
        name: 'John',
        email: 'john@example.com',
      })
    })
  })

  describe('findById', () => {
    it('should return user by id', async () => {
      const created = await repository.create({
        name: 'John',
        email: 'john@example.com',
      })

      const found = await repository.findById(created.id)

      expect(found).toEqual(created)
    })

    it('should return null for non-existent id', async () => {
      const found = await repository.findById('non-existent-id')

      expect(found).toBeNull()
    })
  })
})
```

## Integration Testing

### Controller Testing

```typescript
// features/users/users.controller.test.ts
import { describe, it, expect, beforeEach, jest } from 'vitest'
import { UsersController } from './users.controller'
import { mockRequest, mockResponse, mockNext } from '@/shared/utils/test-utils'

describe('UsersController', () => {
  let controller: UsersController
  let mockService: any

  beforeEach(() => {
    mockService = {
      findAll: jest.fn(),
      findById: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    }
    controller = new UsersController(mockService)
  })

  describe('getAll', () => {
    it('should return paginated users', async () => {
      const mockUsers = [
        { id: '1', name: 'John', email: 'john@example.com' },
      ]
      mockService.findAll.mockResolvedValue(mockUsers)

      const req = mockRequest({ query: { page: '1', limit: '10' } })
      const res = mockResponse()
      const next = mockNext()

      await controller.getAll(req, res, next)

      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: mockUsers,
      })
    })

    it('should call next on error', async () => {
      const error = new Error('Database error')
      mockService.findAll.mockRejectedValue(error)

      const req = mockRequest()
      const res = mockResponse()
      const next = mockNext()

      await controller.getAll(req, res, next)

      expect(next).toHaveBeenCalledWith(error)
    })
  })

  describe('create', () => {
    it('should create user with valid data', async () => {
      const createUserDto = { name: 'John', email: 'john@example.com' }
      const mockUser = { id: '1', ...createUserDto }
      mockService.create.mockResolvedValue(mockUser)

      const req = mockRequest({ body: createUserDto })
      const res = mockResponse()
      const next = mockNext()

      await controller.create(req, res, next)

      expect(res.status).toHaveBeenCalledWith(201)
      expect(res.json).toHaveBeenCalledWith({
        success: true,
        data: mockUser,
      })
    })

    it('should return 400 for invalid data', async () => {
      const req = mockRequest({ body: { name: '' } })
      const res = mockResponse()
      const next = mockNext()

      await controller.create(req, res, next)

      expect(res.status).toHaveBeenCalledWith(400)
    })
  })
})
```

### API Integration Testing

```typescript
// features/users/users.integration.test.ts
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import request from 'supertest'
import { app } from '@/app'
import { prisma } from '@/config/database'

describe('Users API', () => {
  beforeAll(async () => {
    await prisma.$connect()
  })

  afterAll(async () => {
    await prisma.$disconnect()
  })

  beforeEach(async () => {
    await prisma.user.deleteMany()
  })

  describe('GET /api/users', () => {
    it('should return empty array when no users', async () => {
      const response = await request(app).get('/api/users')

      expect(response.status).toBe(200)
      expect(response.body.data).toEqual([])
    })

    it('should return paginated users', async () => {
      // Create test users
      await prisma.user.createMany({
        data: [
          { name: 'John', email: 'john@example.com' },
          { name: 'Jane', email: 'jane@example.com' },
        ],
      })

      const response = await request(app)
        .get('/api/users')
        .query({ page: 1, limit: 10 })

      expect(response.status).toBe(200)
      expect(response.body.data).toHaveLength(2)
    })
  })

  describe('POST /api/users', () => {
    it('should create user with valid data', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          name: 'John',
          email: 'john@example.com',
          password: 'Password123',
        })

      expect(response.status).toBe(201)
      expect(response.body.data).toMatchObject({
        name: 'John',
        email: 'john@example.com',
      })
    })

    it('should return 400 for invalid data', async () => {
      const response = await request(app)
        .post('/api/users')
        .send({
          name: '',
          email: 'invalid-email',
        })

      expect(response.status).toBe(400)
    })
  })
})
```

## Test Utilities

```typescript
// shared/utils/test-utils.ts
import { Request, Response, NextFunction } from 'express'

export function mockRequest(overrides: Partial<Request> = {}): Request {
  return {
    params: {},
    query: {},
    body: {},
    headers: {},
    ip: '127.0.0.1',
    ...overrides,
  } as Request
}

export function mockResponse(): Response {
  const res = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
    header: jest.fn().mockReturnThis(),
  } as unknown as Response

  return res
}

export function mockNext(): NextFunction {
  return jest.fn() as NextFunction
}
```

## Test Coverage

### Minimum Coverage Requirements

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    coverage: {
      provider: 'v8',
      thresholds: {
        statements: 80,
        branches: 80,
        functions: 80,
        lines: 80,
      },
    },
  },
})
```

### Coverage Reports

```bash
# Run tests with coverage
vitest run --coverage

# Generate HTML report
vitest run --coverage --reporter=html
```

## Mocking Patterns

### Database Mocking

```typescript
// Mock Prisma client
jest.mock('@/config/database', () => ({
  prisma: {
    user: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
  },
}))
```

### External Service Mocking

```typescript
// Mock email service
jest.mock('@/shared/services/email', () => ({
  sendEmail: jest.fn().mockResolvedValue({ success: true }),
}))

// Mock payment service
jest.mock('@/shared/services/payment', () => ({
  createPaymentIntent: jest.fn().mockResolvedValue({
    id: 'pi_123',
    client_secret: 'secret',
  }),
}))
```

## CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:coverage
      - run: npm run lint
      - run: npm run type-check
```

## Checklist

- [ ] Unit tests for all services
- [ ] Integration tests for controllers
- [ ] API integration tests for routes
- [ ] Test coverage >= 80%
- [ ] No console.log in tests
- [ ] Tests are isolated (no shared state)
- [ ] Mocks are properly cleaned up
- [ ] Async operations properly awaited
- [ ] Error cases tested
- [ ] CI/CD pipeline runs tests
