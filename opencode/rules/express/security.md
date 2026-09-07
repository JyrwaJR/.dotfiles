---
paths:
  - "**/*.ts"
  - "**/*.js"
---
# Express.js Security

> This file extends [nodejs/security.md](../nodejs/security.md) with Express-specific security content.

## Security Middleware

### Helmet Configuration

```typescript
import helmet from 'helmet'

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'", 'https://fonts.googleapis.com'],
      imgSrc: ["'self'", 'data:', 'https:'],
      fontSrc: ["'self'", 'https://fonts.gstatic.com'],
      connectSrc: ["'self'", 'https://api.example.com'],
      frameSrc: ["'none'"],
      objectSrc: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
      upgradeInsecureRequests: [],
    },
  },
  hsts: {
    maxAge: 63072000,
    includeSubDomains: true,
    preload: true,
  },
}))
```

### CORS Configuration

```typescript
import cors from 'cors'

app.use(cors({
  origin: (origin, callback) => {
    const allowedOrigins = [env.CORS_ORIGIN]

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-CSRF-Token'],
  exposedHeaders: ['X-Total-Count'],
  maxAge: 600, // 10 minutes preflight cache
}))
```

## CSRF Protection

### CSRF Token Middleware

```typescript
// shared/middleware/csrf.middleware.ts
import { Request, Response, NextFunction } from 'express'
import crypto from 'crypto'
import { redis } from '@/config/redis'

export function csrfProtection(
  req: Request,
  res: Response,
  next: NextFunction
) {
  // Skip for GET, HEAD, OPTIONS
  if (['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    return next()
  }

  const token = req.headers['x-csrf-token'] as string
  const sessionId = req.cookies['session-id']

  if (!token || !sessionId) {
    return res.status(403).json({
      success: false,
      error: 'CSRF token missing',
    })
  }

  // Validate token against stored value
  const storedToken = await redis.get(`csrf:${sessionId}`)

  if (!storedToken || !crypto.timingSafeEqual(
    Buffer.from(token),
    Buffer.from(storedToken)
  )) {
    return res.status(403).json({
      success: false,
      error: 'Invalid CSRF token',
    })
  }

  next()
}

// Generate CSRF token
export async function generateCsrfToken(sessionId: string): Promise<string> {
  const token = crypto.randomBytes(32).toString('hex')
  await redis.set(`csrf:${sessionId}`, token, 'EX', 3600) // 1 hour
  return token
}
```

## Input Validation

### Express-Validator + Zod

```typescript
// shared/middleware/validate.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { ZodSchema, ZodError } from 'zod'

export function validate(schema: ZodSchema) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      const result = schema.parse({
        body: req.body,
        query: req.query,
        params: req.params,
      })

      req.body = result.body
      req.query = result.query
      req.params = result.params

      next()
    } catch (error) {
      if (error instanceof ZodError) {
        return res.status(400).json({
          success: false,
          error: 'Validation failed',
          details: error.flatten(),
        })
      }
      next(error)
    }
  }
}
```

## Authentication

### JWT with Refresh Token

```typescript
// features/auth/auth.service.ts
import jwt from 'jsonwebtoken'
import { env } from '@/config/env'
import { UnauthorizedError } from '@/shared/utils/errors'
import { redis } from '@/config/redis'

export class AuthService {
  async generateTokens(userId: string) {
    const accessToken = jwt.sign(
      { userId },
      env.JWT_SECRET,
      { expiresIn: '15m' }
    )

    const refreshToken = jwt.sign(
      { userId },
      env.JWT_REFRESH_SECRET,
      { expiresIn: '7d' }
    )

    // Store refresh token in Redis
    await redis.set(
      `refresh:${userId}`,
      refreshToken,
      'EX',
      7 * 24 * 60 * 60 // 7 days
    )

    return { accessToken, refreshToken }
  }

  async refreshAccessToken(refreshToken: string) {
    try {
      const decoded = jwt.verify(
        refreshToken,
        env.JWT_REFRESH_SECRET
      ) as { userId: string }

      // Verify refresh token exists in Redis
      const storedToken = await redis.get(`refresh:${decoded.userId}`)
      if (storedToken !== refreshToken) {
        throw new UnauthorizedError('Invalid refresh token')
      }

      // Generate new tokens
      return this.generateTokens(decoded.userId)
    } catch (error) {
      throw new UnauthorizedError('Invalid refresh token')
    }
  }

  async logout(userId: string) {
    await redis.del(`refresh:${userId}`)
  }
}
```

## Rate Limiting

### Redis-Based Rate Limiting

```typescript
// shared/middleware/rate-limit.middleware.ts
import { Request, Response, NextFunction } from 'express'
import { redis } from '@/config/redis'

interface RateLimitOptions {
  windowMs: number
  max: number
  keyGenerator?: (req: Request) => string
}

export function rateLimit(options: RateLimitOptions) {
  return async (req: Request, res: Response, next: NextFunction) => {
    const key = options.keyGenerator
      ? options.keyGenerator(req)
      : req.ip

    const windowStart = Math.floor(Date.now() / options.windowMs)
    const redisKey = `ratelimit:${key}:${windowStart}`

    const current = await redis.incr(redisKey)

    if (current === 1) {
      await redis.expire(redisKey, Math.ceil(options.windowMs / 1000))
    }

    if (current > options.max) {
      return res.status(429).json({
        success: false,
        error: 'Too many requests',
      })
    }

    res.setHeader('X-RateLimit-Limit', options.max)
    res.setHeader('X-RateLimit-Remaining', Math.max(0, options.max - current))
    res.setHeader('X-RateLimit-Reset', windowStart * options.windowMs)

    next()
  }
}

// Usage
app.post(
  '/auth/login',
  rateLimit({ windowMs: 15 * 60 * 1000, max: 5 }),
  authController.login
)
```

## Session Security

### Secure Session Configuration

```typescript
import session from 'express-session'
import RedisStore from 'connect-redis'
import { redis } from '@/config/redis'
import { env } from '@/config/env'

app.use(
  session({
    store: new RedisStore({ client: redis }),
    secret: env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: {
      secure: env.NODE_ENV === 'production',
      httpOnly: true,
      maxAge: 24 * 60 * 60 * 1000, // 1 day
      sameSite: 'lax',
      domain: env.COOKIE_DOMAIN,
    },
  })
)
```

## File Upload Security

```typescript
// shared/middleware/upload.middleware.ts
import multer from 'multer'
import { sanitizeFilename } from '@/shared/utils/sanitize'

const ALLOWED_MIME_TYPES = [
  'image/jpeg',
  'image/png',
  'image/webp',
  'application/pdf',
]

const MAX_FILE_SIZE = 5 * 1024 * 1024 // 5MB

const storage = multer.memoryStorage()

const fileFilter = (
  req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) => {
  if (ALLOWED_MIME_TYPES.includes(file.mimetype)) {
    cb(null, true)
  } else {
    cb(new Error('Invalid file type'))
  }
}

export const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: MAX_FILE_SIZE,
  },
})

// Usage
app.post(
  '/upload',
  authMiddleware,
  upload.single('file'),
  async (req, res) => {
    const file = req.file

    // Sanitize filename
    const safeFilename = sanitizeFilename(file.originalname)

    // Process file...
  }
)
```

## Security Headers

```typescript
// Additional security headers
app.use((req, res, next) => {
  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff')

  // Prevent clickjacking
  res.setHeader('X-Frame-Options', 'DENY')

  // Enable XSS protection
  res.setHeader('X-XSS-Protection', '1; mode=block')

  // Referrer policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin')

  // Permissions policy
  res.setHeader(
    'Permissions-Policy',
    'camera=(), microphone=(), geolocation=()'
  )

  // HSTS (if not using helmet)
  if (env.NODE_ENV === 'production') {
    res.setHeader(
      'Strict-Transport-Security',
      'max-age=63072000; includeSubDomains; preload'
    )
  }

  next()
})
```

## Checklist

- [ ] Helmet configured with CSP
- [ ] CORS restricted to allowed origins
- [ ] CSRF protection on state-changing requests
- [ ] Input validation with Zod
- [ ] Rate limiting on auth endpoints
- [ ] JWT with short expiry + refresh tokens
- [ ] Sessions stored in Redis
- [ ] Secure cookie settings (httpOnly, secure, sameSite)
- [ ] File uploads validated (size, type)
- [ ] Security headers configured
- [ ] SQL injection prevented (Prisma)
- [ ] XSS prevention (output encoding)
- [ ] No sensitive data in logs
- [ ] Dependencies audited
