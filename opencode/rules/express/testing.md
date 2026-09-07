---
paths:
  - "**/*.ts"
  - "**/*.js"
  - "**/*.test.ts"
  - "**/*.spec.ts"
---
# Express.js Testing

> This file extends [nodejs/testing.md](../nodejs/testing.md) with Express-specific testing content.

## Testing Strategy

### Test Pyramid

1. **Unit Tests** (70%) - Services, utilities, pure functions
2. **Integration Tests** (20%) - Controllers, middleware, database operations
3. **E2E Tests** (10%) - Full API flows with supertest

## Unit Testing Services

```typescript
// features/auth/auth.service.test.ts
import { describe, it, expect, beforeEach, jest } from 'vitest'
import { AuthService } from './auth.service'
import { UnauthorizedError } from '@/shared/utils/errors'

// Mock dependencies
jest.mock('@/config/redis', () => ({
  redis: {
    get: jest.fn(),
    set: jest.fn(),
    del: jest.fn(),
  },
}))

jest.mock('jsonwebtoken', () => ({
  sign: jest.fn().mockReturnValue('mock-token'),
  verify: jest.fn().mockReturnValue({ userId: 'user-123' }),
}))

describe('AuthService', () => {
  let service: AuthService

  beforeEach(() => {
    service = new AuthService()
    jest.clearAllMocks()
  })

  describe('generateTokens', () => {
    it('should generate access and refresh tokens', async () => {
      const result = await service.generateTokens('user-123')

      expect(result).toHaveProperty('accessToken')
      expect(result).toHaveProperty('refreshToken')
    })
  })

  describe('refreshAccessToken', () => {
    it('should return new tokens when refresh token is valid', async () => {
      const { redis } = await import('@/config/redis')
      redis.get.mockResolvedValue('valid-refresh-token')

      const result = await service.refreshAccessToken('valid-refresh-token')

      expect(result).toHaveProperty('accessToken')
      expect(result).toHaveProperty('refreshToken')
    })

    it('should throw when refresh token is invalid', async () => {
      const { redis } = await import('@/config/redis')
      redis.get.mockResolvedValue(null)

      await expect(
        service.refreshAccessToken('invalid-token')
      ).rejects.toThrow(UnauthorizedError)
    })
  })

  describe('logout', () => {
    it('should remove refresh token from Redis', async () => {
      const { redis } = await import('@/config/redis')

      await service.logout('user-123')

      expect(redis.del).toHaveBeenCalledWith('refresh:user-123')
    })
  })
})
```

## Integration Testing Controllers

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
    it('should return 200 with users', async () => {
      const mockUsers = [
        { id: '1', name: 'John', email: 'john@example.com' },
      ]
      mockService.findAll.mockResolvedValue(mockUsers)

      const req = mockRequest({ query: { page: '1', limit: '10' } })
      const res = mockResponse()
      const next = mockNext()

      await controller.getAll(req, res, next)

      expect(res.status).not.toHaveBeenCalled()
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
    it('should return 201 with created user', async () => {
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

## API Integration Testing

```typescript
// features/users/users.api.test.ts
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import request from 'supertest'
import { app } from '@/app'
import { prisma } from '@/config/database'

describe('Users API', () => {
  let authToken: string

  beforeAll(async () => {
    await prisma.$connect()

    // Create test user and get auth token
    const response = await request(app)
      .post('/api/auth/register')
      .send({
        name: 'Test User',
        email: 'test@example.com',
        password: 'Password123',
      })

    authToken = response.body.data.accessToken
  })

  afterAll(async () => {
    await prisma.user.deleteMany()
    await prisma.$disconnect()
  })

  beforeEach(async () => {
    await prisma.post.deleteMany()
  })

  describe('GET /api/users', () => {
    it('should return 200 with empty array', async () => {
      const response = await request(app)
        .get('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .expect(200)

      expect(response.body.success).toBe(true)
      expect(response.body.data).toEqual([])
    })

    it('should return 401 without auth token', async () => {
      await request(app)
        .get('/api/users')
        .expect(401)
    })
  })

  describe('POST /api/users', () => {
    it('should return 201 with created user', async () => {
      const response = await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'John',
          email: 'john@example.com',
          password: 'Password123',
        })
        .expect(201)

      expect(response.body.data).toMatchObject({
        name: 'John',
        email: 'john@example.com',
      })
    })

    it('should return 400 for invalid data', async () => {
      await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: '',
          email: 'invalid',
        })
        .expect(400)
    })

    it('should return 409 for duplicate email', async () => {
      // Create first user
      await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'John',
          email: 'john@example.com',
          password: 'Password123',
        })

      // Try to create duplicate
      await request(app)
        .post('/api/users')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          name: 'Jane',
          email: 'john@example.com',
          password: 'Password123',
        })
        .expect(409)
    })
  })
})
```

## Middleware Testing

```typescript
// shared/middleware/auth.middleware.test.ts
import { describe, it, expect, beforeEach, jest } from 'vitest'
import { authMiddleware } from './auth.middleware'
import { mockRequest, mockResponse, mockNext } from '@/shared/utils/test-utils'
import jwt from 'jsonwebtoken'

jest.mock('jsonwebtoken')

describe('AuthMiddleware', () => {
  beforeEach(() => {
    jest.clearAllMocks()
  })

  it('should call next with user when token is valid', async () => {
    const mockUser = { userId: 'user-123' }
    ;(jwt.verify as jest.Mock).mockReturnValue(mockUser)

    const req = mockRequest({
      headers: { authorization: 'Bearer valid-token' },
    })
    const res = mockResponse()
    const next = mockNext()

    authMiddleware(req, res, next)

    expect(req.user).toEqual(mockUser)
    expect(next).toHaveBeenCalled()
  })

  it('should return 401 when no token', async () => {
    const req = mockRequest({ headers: {} })
    const res = mockResponse()
    const next = mockNext()

    authMiddleware(req, res, next)

    expect(res.status).toHaveBeenCalledWith(401)
  })

  it('should return 401 when token is invalid', async () => {
    ;(jwt.verify as jest.Mock).mockImplementation(() => {
      throw new Error('Invalid token')
    })

    const req = mockRequest({
      headers: { authorization: 'Bearer invalid-token' },
    })
    const res = mockResponse()
    const next = mockNext()

    authMiddleware(req, res, next)

    expect(res.status).toHaveBeenCalledWith(401)
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
    cookies: {},
    ...overrides,
  } as Request
}

export function mockResponse(): Response {
  const res = {
    status: jest.fn().mockReturnThis(),
    json: jest.fn().mockReturnThis(),
    send: jest.fn().mockReturnThis(),
    header: jest.fn().mockReturnThis(),
    cookie: jest.fn().mockReturnThis(),
    clearCookie: jest.fn().mockReturnThis(),
  } as unknown as Response

  return res
}

export function mockNext(): NextFunction {
  return jest.fn() as NextFunction
}
```

## Test Configuration

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config'
import path from 'path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./src/shared/utils/test-setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      include: ['src/**/*.ts'],
      exclude: [
        'node_modules/',
        'src/**/*.test.ts',
        'src/**/*.spec.ts',
        'src/config/',
        'src/shared/utils/test-*.ts',
      ],
    },
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
})
```

```typescript
// src/shared/utils/test-setup.ts
import { prisma } from '@/config/database'
import { redis } from '@/config/redis'

beforeAll(async () => {
  await prisma.$connect()
})

afterAll(async () => {
  await prisma.$disconnect()
  await redis.quit()
})

beforeEach(async () => {
  // Clean database before each test
  await prisma.post.deleteMany()
  await prisma.user.deleteMany()
})
```

## Checklist

- [ ] Unit tests for all services
- [ ] Integration tests for controllers
- [ ] API tests with supertest
- [ ] Middleware tests
- [ ] Test coverage >= 80%
- [ ] Tests are isolated (clean database)
- [ ] Mocks properly cleaned up
- [ ] Async operations properly awaited
- [ ] Error cases tested
- [ ] Auth flows tested
