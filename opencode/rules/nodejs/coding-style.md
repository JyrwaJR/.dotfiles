---
paths:
  - "**/*.ts"
  - "**/*.js"
  - "package.json"
  - "tsconfig.json"
---
# Node.js Coding Style

> This file extends [typescript/coding-style.md](../typescript/coding-style.md) with Node.js-specific content.

## Project Structure

### Feature-First Architecture

```text
src/
├── features/
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.repository.ts
│   │   ├── auth.routes.ts
│   │   ├── auth.types.ts
│   │   ├── auth.validation.ts
│   │   └── auth.test.ts
│   ├── users/
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.repository.ts
│   │   ├── users.routes.ts
│   │   ├── users.types.ts
│   │   ├── users.validation.ts
│   │   └── users.test.ts
│   └── posts/
│       ├── posts.controller.ts
│       ├── posts.service.ts
│       ├── posts.repository.ts
│       ├── posts.routes.ts
│       ├── posts.types.ts
│       ├── posts.validation.ts
│       └── posts.test.ts
├── shared/
│   ├── middleware/
│   │   ├── auth.middleware.ts
│   │   ├── error.middleware.ts
│   │   └── validation.middleware.ts
│   ├── utils/
│   │   ├── logger.ts
│   │   ├── config.ts
│   │   └── helpers.ts
│   └── types/
│       └── index.ts
├── config/
│   ├── database.ts
│   ├── redis.ts
│   └── env.ts
└── app.ts
```

### Controller Pattern

```typescript
// features/users/users.controller.ts
import { Request, Response, NextFunction } from 'express'
import { UsersService } from './users.service'
import { createUserSchema, updateUserSchema } from './users.validation'

export class UsersController {
  constructor(private usersService: UsersService) {}

  async getAll(req: Request, res: Response, next: NextFunction) {
    try {
      const { page = 1, limit = 10 } = req.query
      const users = await this.usersService.findAll({
        page: Number(page),
        limit: Number(limit),
      })

      res.json({
        success: true,
        data: users,
      })
    } catch (error) {
      next(error)
    }
  }

  async getById(req: Request, res: Response, next: NextFunction) {
    try {
      const user = await this.usersService.findById(req.params.id)

      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'User not found',
        })
      }

      res.json({
        success: true,
        data: user,
      })
    } catch (error) {
      next(error)
    }
  }

  async create(req: Request, res: Response, next: NextFunction) {
    try {
      const result = createUserSchema.safeParse(req.body)

      if (!result.success) {
        return res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: result.error.flatten(),
        })
      }

      const user = await this.usersService.create(result.data)

      res.status(201).json({
        success: true,
        data: user,
      })
    } catch (error) {
      next(error)
    }
  }

  async update(req: Request, res: Response, next: NextFunction) {
    try {
      const result = updateUserSchema.safeParse(req.body)

      if (!result.success) {
        return res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: result.error.flatten(),
        })
      }

      const user = await this.usersService.update(req.params.id, result.data)

      if (!user) {
        return res.status(404).json({
          success: false,
          error: 'User not found',
        })
      }

      res.json({
        success: true,
        data: user,
      })
    } catch (error) {
      next(error)
    }
  }

  async delete(req: Request, res: Response, next: NextFunction) {
    try {
      const deleted = await this.usersService.delete(req.params.id)

      if (!deleted) {
        return res.status(404).json({
          success: false,
          error: 'User not found',
        })
      }

      res.status(204).send()
    } catch (error) {
      next(error)
    }
  }
}
```

### Service Pattern

```typescript
// features/users/users.service.ts
import { UsersRepository } from './users.repository'
import { CreateUserDto, UpdateUserDto, User } from './users.types'

export class UsersService {
  constructor(private usersRepository: UsersRepository) {}

  async findAll(options: { page: number; limit: number }): Promise<User[]> {
    const skip = (options.page - 1) * options.limit
    return this.usersRepository.findMany({
      skip,
      take: options.limit,
    })
  }

  async findById(id: string): Promise<User | null> {
    return this.usersRepository.findById(id)
  }

  async create(data: CreateUserDto): Promise<User> {
    // Check for duplicate email
    const existing = await this.usersRepository.findByEmail(data.email)
    if (existing) {
      throw new Error('Email already exists')
    }

    return this.usersRepository.create(data)
  }

  async update(id: string, data: UpdateUserDto): Promise<User | null> {
    // Check if user exists
    const existing = await this.usersRepository.findById(id)
    if (!existing) {
      return null
    }

    // Check for duplicate email if updating
    if (data.email) {
      const emailTaken = await this.usersRepository.findByEmail(data.email)
      if (emailTaken && emailTaken.id !== id) {
        throw new Error('Email already exists')
      }
    }

    return this.usersRepository.update(id, data)
  }

  async delete(id: string): Promise<boolean> {
    const existing = await this.usersRepository.findById(id)
    if (!existing) {
      return false
    }

    await this.usersRepository.delete(id)
    return true
  }
}
```

### Repository Pattern

```typescript
// features/users/users.repository.ts
import { prisma } from '@/config/database'
import { CreateUserDto, UpdateUserDto, User } from './users.types'

export class UsersRepository {
  async findMany(options: { skip: number; take: number }): Promise<User[]> {
    return prisma.user.findMany({
      skip: options.skip,
      take: options.take,
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
      },
    })
  }

  async findById(id: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
      },
    })
  }

  async findByEmail(email: string): Promise<User | null> {
    return prisma.user.findUnique({
      where: { email },
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
      },
    })
  }

  async create(data: CreateUserDto): Promise<User> {
    return prisma.user.create({
      data,
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
      },
    })
  }

  async update(id: string, data: UpdateUserDto): Promise<User> {
    return prisma.user.update({
      where: { id },
      data,
      select: {
        id: true,
        name: true,
        email: true,
        createdAt: true,
        updatedAt: true,
      },
    })
  }

  async delete(id: string): Promise<void> {
    await prisma.user.delete({
      where: { id },
    })
  }
}
```

## Error Handling

### Custom Error Classes

```typescript
// shared/utils/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public statusCode: number,
    public code: string
  ) {
    super(message)
    this.name = 'AppError'
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string) {
    super(`${resource} not found`, 404, 'NOT_FOUND')
  }
}

export class ValidationError extends AppError {
  constructor(message: string, public details: Record<string, string[]>) {
    super(message, 400, 'VALIDATION_ERROR')
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 401, 'UNAUTHORIZED')
  }
}

export class ForbiddenError extends AppError {
  constructor(message = 'Forbidden') {
    super(message, 403, 'FORBIDDEN')
  }
}
```

### Error Middleware

```typescript
// shared/middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { AppError } from '@/shared/utils/errors'
import { logger } from '@/shared/utils/logger'

export function errorHandler(
  err: Error,
  req: Request,
  res: Response,
  next: NextFunction
) {
  // Log error
  logger.error({
    message: err.message,
    stack: err.stack,
    path: req.path,
    method: req.method,
  })

  // Handle known errors
  if (err instanceof AppError) {
    return res.status(err.statusCode).json({
      success: false,
      error: err.message,
      code: err.code,
      ...(err instanceof ValidationError && { details: err.details }),
    })
  }

  // Handle unknown errors
  res.status(500).json({
    success: false,
    error: 'Internal server error',
  })
}
```

## Async/Await Patterns

### Consistent Async Handling

```typescript
// WRONG: Unhandled promise rejections
app.get('/users', (req, res) => {
  usersService.findAll().then(users => {
    res.json(users)
  })
  // No error handling!
})

// CORRECT: Proper async/await with error handling
app.get('/users', async (req, res, next) => {
  try {
    const users = await usersService.findAll()
    res.json({
      success: true,
      data: users,
    })
  } catch (error) {
    next(error)
  }
})
```

### Async Middleware

```typescript
// shared/utils/async-handler.ts
import { Request, Response, NextFunction } from 'express'

type AsyncHandler = (
  req: Request,
  res: Response,
  next: NextFunction
) => Promise<any>

export const asyncHandler = (fn: AsyncHandler) => {
  return (req: Request, res: Response, next: NextFunction) => {
    Promise.resolve(fn(req, res, next)).catch(next)
  }
}

// Usage
app.get('/users', asyncHandler(async (req, res) => {
  const users = await usersService.findAll()
  res.json({ success: true, data: users })
}))
```

## Configuration Management

### Environment Variables

```typescript
// config/env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  PORT: z.coerce.number().default(3000),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  CORS_ORIGIN: z.string().url(),
})

export const env = envSchema.parse(process.env)
```

### Config Pattern

```typescript
// config/database.ts
import { PrismaClient } from '@prisma/client'
import { env } from './env'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

## Logging

### Structured Logging

```typescript
// shared/utils/logger.ts
import pino from 'pino'
import { env } from '@/config/env'

export const logger = pino({
  level: env.NODE_ENV === 'production' ? 'info' : 'debug',
  transport:
    env.NODE_ENV === 'development'
      ? { target: 'pino-pretty', options: { colorize: true } }
      : undefined,
  serializers: {
    err: pino.stdSerializers.err,
    req: pino.stdSerializers.req,
    res: pino.stdSerializers.res,
  },
})

// Usage
logger.info({ userId: '123', action: 'login' }, 'User logged in')
logger.error({ err: error, requestId: 'abc' }, 'Request failed')
```

## Database Patterns

### Transaction Handling

```typescript
// features/users/users.service.ts
async transferCredits(fromId: string, toId: string, amount: number) {
  return prisma.$transaction(async (tx) => {
    const fromUser = await tx.user.findUnique({ where: { id: fromId } })
    const toUser = await tx.user.findUnique({ where: { id: toId } })

    if (!fromUser || !toUser) {
      throw new NotFoundError('User not found')
    }

    if (fromUser.credits < amount) {
      throw new ValidationError('Insufficient credits', {
        credits: ['Not enough credits for transfer'],
      })
    }

    await tx.user.update({
      where: { id: fromId },
      data: { credits: { decrement: amount } },
    })

    await tx.user.update({
      where: { id: toId },
      data: { credits: { increment: amount } },
    })

    return { success: true }
  })
}
```

### Query Optimization

```typescript
// WRONG: N+1 query
const users = await prisma.user.findMany()
for (const user of users) {
  user.posts = await prisma.post.findMany({
    where: { authorId: user.id },
  })
}

// CORRECT: Eager loading with include
const users = await prisma.user.findMany({
  include: {
    posts: {
      select: {
        id: true,
        title: true,
      },
    },
  },
})
```

## Testing Patterns

### Unit Testing Services

```typescript
// features/users/users.service.test.ts
import { UsersService } from './users.service'
import { UsersRepository } from './users.repository'
import { NotFoundError, ValidationError } from '@/shared/utils/errors'

// Mock repository
const mockRepository = {
  findMany: jest.fn(),
  findById: jest.fn(),
  findByEmail: jest.fn(),
  create: jest.fn(),
  update: jest.fn(),
  delete: jest.fn(),
}

describe('UsersService', () => {
  let service: UsersService

  beforeEach(() => {
    service = new UsersService(mockRepository as any)
    jest.clearAllMocks()
  })

  describe('findById', () => {
    it('should return user when found', async () => {
      const mockUser = { id: '1', name: 'John', email: 'john@example.com' }
      mockRepository.findById.mockResolvedValue(mockUser)

      const result = await service.findById('1')

      expect(result).toEqual(mockUser)
      expect(mockRepository.findById).toHaveBeenCalledWith('1')
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
      mockRepository.findByEmail.mockResolvedValue({ id: '1', email: 'john@example.com' })

      await expect(service.create(createUserDto)).rejects.toThrow('Email already exists')
    })
  })
})
```

## Checklist

- [ ] Feature-first directory structure
- [ ] Controller → Service → Repository pattern
- [ ] All async operations have error handling
- [ ] Environment variables validated at startup
- [ ] Structured logging (no console.log)
- [ ] Database queries use parameterized queries
- [ ] Transactions for multi-step operations
- [ ] Unit tests for services
- [ ] Integration tests for controllers
- [ ] Error messages don't leak sensitive data
