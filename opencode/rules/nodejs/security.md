---
paths:
  - "**/*.ts"
  - "**/*.js"
---
# Node.js Security

> This file extends [typescript/security.md](../typescript/security.md) with Node.js-specific security content.

## OWASP Top 10 for Node.js

### A01: Broken Access Control

```typescript
// WRONG: Client-side only authorization
app.delete('/users/:id', (req, res) => {
  // Anyone can delete any user
  usersService.delete(req.params.id)
  res.status(204).send()
})

// CORRECT: Server-side authorization middleware
app.delete('/users/:id', authMiddleware, async (req, res, next) => {
  try {
    // Check if user owns the resource or is admin
    if (req.user.id !== req.params.id && req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        error: 'Forbidden',
      })
    }

    await usersService.delete(req.params.id)
    res.status(204).send()
  } catch (error) {
    next(error)
  }
})
```

### A02: Cryptographic Failures

```typescript
// WRONG: Weak password hashing
import bcrypt from 'bcrypt'
const hash = await bcrypt.hash(password, 8) // Too low

// CORRECT: Strong password hashing
import argon2 from 'argon2'

const hash = await argon2.hash(password, {
  type: argon2.argon2id,
  memoryCost: 65536,
  timeCost: 3,
  parallelism: 4,
})

// Verify password
const isValid = await argon2.verify(hash, password)
```

### A03: Injection

```typescript
// WRONG: SQL injection vulnerability
const query = `SELECT * FROM users WHERE id = '${userId}'`
await db.query(query)

// CORRECT: Parameterized queries with Prisma
const user = await prisma.user.findUnique({
  where: { id: userId },
})

// WRONG: Command injection
exec(`convert ${userInput} output.png`)

// CORRECT: Validate and sanitize input
import { sanitizeFilename } from '@/shared/utils/sanitize'
const safeInput = sanitizeFilename(userInput)
execFile('convert', [safeInput, 'output.png'])
```

### A04: Insecure Design

```typescript
// Rate limiting for sensitive operations
import rateLimit from 'express-rate-limit'

const loginLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts
  message: 'Too many login attempts',
  standardHeaders: true,
  legacyHeaders: false,
})

app.post('/auth/login', loginLimiter, authController.login)
```

### A05: Security Misconfiguration

```typescript
// middleware/security.ts
import helmet from 'helmet'

export function securityMiddleware(app: Express) {
  // Security headers
  app.use(helmet())

  // CORS configuration
  app.use(
    cors({
      origin: env.CORS_ORIGIN,
      credentials: true,
      methods: ['GET', 'POST', 'PUT', 'DELETE'],
      allowedHeaders: ['Content-Type', 'Authorization'],
    })
  )

  // Disable X-Powered-By
  app.disable('x-powered-by')

  // Trust proxy (for rate limiting behind reverse proxy)
  app.set('trust proxy', 1)
}
```

### A06: Vulnerable Components

```bash
# Regularly audit dependencies
npm audit
yarn audit
pnpm audit

# Fix vulnerabilities
npm audit fix

# Check for outdated packages
npm outdated
```

### A07: Authentication Failures

```typescript
// JWT with secure defaults
import jwt from 'jsonwebtoken'

const generateToken = (userId: string) => {
  return jwt.sign(
    { userId },
    env.JWT_SECRET,
    {
      expiresIn: '1h',
      algorithm: 'HS256',
    }
  )
}

// Refresh token with rotation
const generateRefreshToken = (userId: string, tokenId: string) => {
  return jwt.sign(
    { userId, tokenId },
    env.JWT_REFRESH_SECRET,
    {
      expiresIn: '7d',
      algorithm: 'HS256',
    }
  )
}
```

### A08: Data Integrity Failures

```typescript
// Webhook signature verification
import crypto from 'crypto'

function verifyWebhookSignature(
  payload: string,
  signature: string,
  secret: string
): boolean {
  const expectedSignature = crypto
    .createHmac('sha256', secret)
    .update(payload)
    .digest('hex')

  return crypto.timingSafeEqual(
    Buffer.from(signature),
    Buffer.from(expectedSignature)
  )
}

app.post('/webhooks/stripe', (req, res) => {
  const signature = req.headers['stripe-signature'] as string

  if (!verifyWebhookSignature(JSON.stringify(req.body), signature, env.STRIPE_WEBHOOK_SECRET)) {
    return res.status(400).json({ error: 'Invalid signature' })
  }

  // Process webhook
})
```

### A09: Logging and Monitoring

```typescript
// Structured security logging
import { logger } from '@/shared/utils/logger'

// Log authentication events
logger.info({
  event: 'auth_login',
  userId: user.id,
  ip: req.ip,
  userAgent: req.headers['user-agent'],
  timestamp: new Date().toISOString(),
})

// Log failed attempts
logger.warn({
  event: 'auth_failed',
  email: email,
  ip: req.ip,
  reason: 'Invalid password',
  timestamp: new Date().toISOString(),
})

// Log sensitive operations
logger.info({
  event: 'user_delete',
  deletedBy: req.user.id,
  deletedUser: userId,
  ip: req.ip,
  timestamp: new Date().toISOString(),
})
```

### A10: SSRF

```typescript
// Validate URLs before fetching
import { URL } from 'url'

const ALLOWED_HOSTS = ['api.example.com', 'cdn.example.com']

function isAllowedUrl(urlString: string): boolean {
  try {
    const url = new URL(urlString)

    // Only allow HTTPS
    if (url.protocol !== 'https:') {
      return false
    }

    // Check allowlist
    if (!ALLOWED_HOSTS.includes(url.hostname)) {
      return false
    }

    // Block internal IPs
    const internalRanges = [
      /^127\./,
      /^10\./,
      /^172\.(1[6-9]|2\d|3[01])\./,
      /^192\.168\./,
      /^localhost$/,
    ]

    for (const range of internalRanges) {
      if (range.test(url.hostname)) {
        return false
      }
    }

    return true
  } catch {
    return false
  }
}

// Safe fetch with validation
async function safeFetch(urlString: string): Promise<Response> {
  if (!isAllowedUrl(urlString)) {
    throw new Error('URL not allowed')
  }

  return fetch(urlString, {
    signal: AbortSignal.timeout(10000),
  })
}
```

## Input Validation

### Zod Schemas

```typescript
// shared/validation/schemas.ts
import { z } from 'zod'

export const createUserSchema = z.object({
  name: z
    .string()
    .min(1, 'Name is required')
    .max(100, 'Name must be less than 100 characters')
    .trim(),
  email: z
    .string()
    .email('Invalid email address')
    .max(255, 'Email must be less than 255 characters')
    .toLowerCase(),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .max(128, 'Password must be less than 128 characters')
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      'Password must contain at least one uppercase, one lowercase, and one number'
    ),
})

export const updateUserSchema = createUserSchema.partial()

export const querySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(10),
  search: z.string().max(100).optional(),
})
```

## Secret Management

```typescript
// config/env.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'production', 'test']),
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  REDIS_URL: z.string().url(),
  SMTP_HOST: z.string(),
  SMTP_PORT: z.coerce.number(),
  SMTP_USER: z.string().email(),
  SMTP_PASS: z.string(),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  STRIPE_WEBHOOK_SECRET: z.string().startsWith('whsec_'),
})

// Validate at startup
try {
  env = envSchema.parse(process.env)
} catch (error) {
  console.error('Invalid environment variables:', error)
  process.exit(1)
}
```

## Checklist

- [ ] All endpoints have authentication middleware
- [ ] Authorization checked server-side for every request
- [ ] Passwords hashed with Argon2id (not bcrypt)
- [ ] JWT secrets are at least 32 characters
- [ ] Rate limiting on auth endpoints
- [ ] Input validated with Zod
- [ ] SQL queries use Prisma (parameterized)
- [ ] No command injection vectors
- [ ] Webhook signatures verified
- [ ] Security headers configured (helmet)
- [ ] Sensitive operations logged
- [ ] Dependencies audited regularly
- [ ] SSRF prevention (URL validation)
- [ ] Secrets in environment variables (not code)
