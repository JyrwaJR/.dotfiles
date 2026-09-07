---
paths:
  - "**/*.ts"
  - "**/*.js"
---
# Express.js Patterns

> This file extends [nodejs/coding-style.md](../nodejs/coding-style.md) with Express-specific patterns.

## Application Structure

### Entry Point

```typescript
// src/app.ts
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import compression from 'compression'
import { env } from '@/config/env'
import { errorHandler } from '@/shared/middleware/error.middleware'
import { routes } from '@/routes'

const app = express()

// Security middleware
app.use(helmet())
app.use(cors({
  origin: env.CORS_ORIGIN,
  credentials: true,
}))

// Body parsing
app.use(express.json({ limit: '10mb' }))
app.use(express.urlencoded({ extended: true }))

// Compression
app.use(compression())

// Request logging
app.use(requestLogger)

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() })
})

// API routes
app.use('/api', routes)

// Error handling
app.use(errorHandler)

export { app }
```

```typescript
// src/server.ts
import { app } from './app'
import { env } from '@/config/env'
import { logger } from '@/shared/utils/logger'
import { prisma } from '@/config/database'

async function bootstrap() {
  try {
    // Connect to database
    await prisma.$connect()
    logger.info('Database connected')

    // Start server
    app.listen(env.PORT, () => {
      logger.info(`Server running on port ${env.PORT}`)
    })
  } catch (error) {
    logger.error('Failed to start server:', error)
    process.exit(1)
  }
}

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received, shutting down...')
  await prisma.$disconnect()
  process.exit(0)
})

process.on('SIGINT', async () => {
  logger.info('SIGINT received, shutting down...')
  await prisma.$disconnect()
  process.exit(0)
})

bootstrap()
```

## Router Organization

### Feature-Based Routes

```typescript
// src/routes/index.ts
import { Router } from 'express'
import { authRoutes } from '@/features/auth/auth.routes'
import { userRoutes } from '@/features/users/users.routes'
import { postRoutes } from '@/features/posts/posts.routes'

const router = Router()

router.use('/auth', authRoutes)
router.use('/users', userRoutes)
router.use('/posts', postRoutes)

export { router as routes }
```

### Route Definitions

```typescript
// features/users/users.routes.ts
import { Router } from 'express'
import { UsersController } from './users.controller'
import { UsersService } from './users.service'
import { UsersRepository } from './users.repository'
import { authMiddleware } from '@/shared/middleware/auth.middleware'
import { asyncHandler } from '@/shared/utils/async-handler'

const router = Router()
const repository = new UsersRepository()
const service = new UsersService(repository)
const controller = new UsersController(service)

// Public routes
router.get('/', asyncHandler(controller.getAll.bind(controller)))
router.get('/:id', asyncHandler(controller.getById.bind(controller)))

// Protected routes
router.post(
  '/',
  authMiddleware,
  asyncHandler(controller.create.bind(controller))
)

router.put(
  '/:id',
  authMiddleware,
  asyncHandler(controller.update.bind(controller))
)

router.delete(
  '/:id',
  authMiddleware,
  asyncHandler(controller.delete.bind(controller))
)

export { router as userRoutes }
```

## Middleware Patterns

### Authentication Middleware

```typescript
// shared/middleware/auth.middleware.ts
import { Request, Response, NextFunction } from 'express'
import jwt from 'jsonwebtoken'
import { env } from '@/config/env'
import { UnauthorizedError } from '@/shared/utils/errors'

interface JwtPayload {
  userId: string
}

declare global {
  namespace Express {
    interface Request {
      user?: JwtPayload
    }
  }
}

export function authMiddleware(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const authHeader = req.headers.authorization

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new UnauthorizedError('No token provided')
  }

  const token = authHeader.split(' ')[1]

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET) as JwtPayload
    req.user = decoded
    next()
  } catch (error) {
    throw new UnauthorizedError('Invalid token')
  }
}
```

### Validation Middleware

```typescript
// shared/middleware/validation.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { ZodSchema } from 'zod'

export function validate(schema: ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    const result = schema.safeParse({
      body: req.body,
      query: req.query,
      params: req.params,
    })

    if (!result.success) {
      return res.status(400).json({
        success: false,
        error: 'Validation failed',
        details: result.error.flatten(),
      })
    }

    req.body = result.data.body
    req.query = result.data.query
    req.params = result.data.params

    next()
  }
}

// Usage
import { createUserSchema } from './users.validation'

router.post(
  '/',
  authMiddleware,
  validate(createUserSchema),
  asyncHandler(controller.create.bind(controller))
)
```

### Rate Limiting

```typescript
// shared/middleware/rate-limit.middleware.ts
import rateLimit from 'express-rate-limit'
import RedisStore from 'rate-limit-redis'
import { redis } from '@/config/redis'

export const apiLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args: string[]) => redis.call(...args),
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: 'Too many requests',
  },
})

export const authLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args: string[]) => redis.call(...args),
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    success: false,
    error: 'Too many login attempts',
  },
})
```

### Request Logging

```typescript
// shared/middleware/logger.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { logger } from '@/shared/utils/logger'

export function requestLogger(
  req: Request,
  res: Response,
  next: NextFunction
) {
  const start = Date.now()

  res.on('finish', () => {
    const duration = Date.now() - start
    logger.info({
      method: req.method,
      url: req.originalUrl,
      status: res.statusCode,
      duration: `${duration}ms`,
      ip: req.ip,
      userAgent: req.headers['user-agent'],
    })
  })

  next()
}
```

## Error Handling

### Global Error Handler

```typescript
// shared/middleware/error.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { AppError, ValidationError } from '@/shared/utils/errors'
import { logger } from '@/shared/utils/logger'
import { env } from '@/config/env'

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
    requestId: req.headers['x-request-id'],
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

  // Handle JWT errors
  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      success: false,
      error: 'Invalid token',
    })
  }

  if (err.name === 'TokenExpiredError') {
    return res.status(401).json({
      success: false,
      error: 'Token expired',
    })
  }

  // Handle unknown errors
  res.status(500).json({
    success: false,
    error: env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message,
  })
}
```

## API Response Format

### Consistent Envelope

```typescript
// shared/types/api.ts
export interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
  code?: string
  details?: Record<string, string[]>
  meta?: {
    total: number
    page: number
    limit: number
    totalPages: number
  }
}

// Usage in controller
res.status(200).json({
  success: true,
  data: users,
  meta: {
    total: 100,
    page: 1,
    limit: 10,
    totalPages: 10,
  },
})
```

## Testing

### Supertest for API Testing

```typescript
// features/users/users.api.test.ts
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
    it('should return 200 with empty array', async () => {
      const response = await request(app)
        .get('/api/users')
        .expect(200)

      expect(response.body.success).toBe(true)
      expect(response.body.data).toEqual([])
    })

    it('should return 200 with users', async () => {
      await prisma.user.createMany({
        data: [
          { name: 'John', email: 'john@example.com' },
          { name: 'Jane', email: 'jane@example.com' },
        ],
      })

      const response = await request(app)
        .get('/api/users')
        .expect(200)

      expect(response.body.data).toHaveLength(2)
    })
  })

  describe('POST /api/users', () => {
    it('should return 201 with created user', async () => {
      const response = await request(app)
        .post('/api/users')
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
      const response = await request(app)
        .post('/api/users')
        .send({
          name: '',
          email: 'invalid',
        })
        .expect(400)

      expect(response.body.success).toBe(false)
    })
  })
})
```

## Checklist

- [ ] Express app properly configured with security middleware
- [ ] Routes organized by feature
- [ ] Controllers handle request/response
- [ ] Services contain business logic
- [ ] Repositories handle data access
- [ ] Middleware for auth, validation, rate limiting
- [ ] Consistent API response format
- [ ] Global error handling
- [ ] Request logging
- [ ] Graceful shutdown
- [ ] API tests with supertest
