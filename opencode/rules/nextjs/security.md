---
paths:
  - "**/*.tsx"
  - "**/*.ts"
  - "next.config.*"
  - "app/**"
  - "pages/**"
  - "middleware.ts"
---
# Next.js Security

> This file extends [react/security.md](../react/security.md) with Next.js-specific security content.

## Server-Side Security

### Never Expose Secrets

```tsx
// WRONG: Secret bundled into client
const API_KEY = process.env.API_KEY // Visible in browser

// CORRECT: Server-only env vars
// Only process.env.NEXT_PUBLIC_* is exposed to client
const API_KEY = process.env.API_SECRET // Server-only
```

### Validate Server Inputs

```tsx
// app/api/users/route.ts
import { z } from 'zod'

const createUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
  age: z.number().int().min(0).max(150),
})

export async function POST(request: Request) {
  const body = await request.json()

  // ALWAYS validate on server
  const result = createUserSchema.safeParse(body)
  if (!result.success) {
    return NextResponse.json(
      { error: 'Validation failed' },
      { status: 400 }
    )
  }

  // Use validated data
  const user = await prisma.user.create({
    data: result.data,
  })

  return NextResponse.json(user)
}
```

## Authentication

### Secure Session Management

```tsx
// lib/auth.ts
import { cookies } from 'next/headers'
import { SignJWT, jwtVerify } from 'jose'

const secretKey = process.env.SESSION_SECRET
const encodedKey = new TextEncoder().encode(secretKey)

interface SessionPayload {
  userId: string
  expiresAt: Date
}

export async function encrypt(payload: SessionPayload) {
  return new SignJWT({ userId: payload.userId })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('7d')
    .sign(encodedKey)
}

export async function decrypt(session: string | undefined) {
  if (!session) return null

  try {
    const { payload } = await jwtVerify(session, encodedKey, {
      algorithms: ['HS256'],
    })
    return payload as unknown as SessionPayload
  } catch {
    return null
  }
}

export async function createSession(userId: string) {
  const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
  const session = await encrypt({ userId, expiresAt })

  const cookieStore = await cookies()
  cookieStore.set('session', session, {
    httpOnly: true,
    secure: true,
    expires: expiresAt,
    sameSite: 'lax',
    path: '/',
  })
}

export async function getSession() {
  const cookieStore = await cookies()
  const session = cookieStore.get('session')?.value
  return decrypt(session)
}
```

### Middleware Authentication

```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { decrypt } from '@/lib/auth'

export async function middleware(request: NextRequest) {
  const session = request.cookies.get('session')?.value

  if (!session) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  const payload = await decrypt(session)

  if (!payload) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Add user ID to headers for downstream use
  const response = NextResponse.next()
  response.headers.set('x-user-id', payload.userId)

  return response
}

export const config = {
  matcher: ['/dashboard/:path*', '/api/:path*'],
}
```

## CSRF Protection

### Server Actions CSRF

```tsx
// Server Actions are protected by Next.js automatically
// The origin header is validated

// For custom API routes, implement CSRF protection
// lib/csrf.ts
import { cookies } from 'next/headers'
import { SignJWT, jwtVerify } from 'jose'

const secretKey = process.env.CSRF_SECRET
const encodedKey = new TextEncoder().encode(secretKey)

export async function generateCsrfToken() {
  const token = await new SignJWT({})
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('1h')
    .sign(encodedKey)

  const cookieStore = await cookies()
  cookieStore.set('csrf-token', token, {
    httpOnly: true,
    secure: true,
    sameSite: 'strict',
  })

  return token
}

export async function validateCsrfToken(token: string) {
  try {
    await jwtVerify(token, encodedKey, { algorithms: ['HS256'] })
    return true
  } catch {
    return false
  }
}
```

## API Route Security

### Rate Limiting

```tsx
// lib/rate-limit.ts
import { RateLimiterMemory } from 'rate-limiter-flexible'

const limiter = new RateLimiterMemory({
  points: 10, // 10 requests
  duration: 1, // per second
})

export async function rateLimit(ip: string) {
  try {
    await limiter.consume(ip)
    return true
  } catch {
    return false
  }
}

// app/api/users/route.ts
import { NextResponse } from 'next/server'
import { rateLimit } from '@/lib/rate-limit'
import { headers } from 'next/headers'

export async function POST(request: Request) {
  const headersList = await headers()
  const ip = headersList.get('x-forwarded-for') || 'unknown'

  if (!(await rateLimit(ip))) {
    return NextResponse.json(
      { error: 'Too many requests' },
      { status: 429 }
    )
  }

  // Process request
}
```

### Input Sanitization

```tsx
// lib/sanitize.ts
import DOMPurify from 'dompurify'

export function sanitizeHtml(input: string): string {
  return DOMPurify.sanitize(input)
}

export function sanitizeFilename(filename: string): string {
  return filename
    .replace(/[^a-zA-Z0-9.-]/g, '_')
    .replace(/_{2,}/g, '_')
    .substring(0, 255)
}
```

## Headers Security

### Security Headers

```tsx
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()',
          },
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=63072000; includeSubDomains; preload',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
        ],
      },
    ]
  },
}

module.exports = nextConfig
```

## File Upload Security

```tsx
// app/api/upload/route.ts
import { NextResponse } from 'next/server'
import { put } from '@vercel/blob'
import { sanitizeFilename } from '@/lib/sanitize'

const MAX_FILE_SIZE = 5 * 1024 * 1024 // 5MB
const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp']

export async function POST(request: Request) {
  const formData = await request.formData()
  const file = formData.get('file') as File | null

  if (!file) {
    return NextResponse.json(
      { error: 'No file provided' },
      { status: 400 }
    )
  }

  // Validate file size
  if (file.size > MAX_FILE_SIZE) {
    return NextResponse.json(
      { error: 'File too large' },
      { status: 400 }
    )
  }

  // Validate file type
  if (!ALLOWED_TYPES.includes(file.type)) {
    return NextResponse.json(
      { error: 'Invalid file type' },
      { status: 400 }
    )
  }

  // Sanitize filename
  const filename = sanitizeFilename(file.name)

  // Upload to secure storage
  const blob = await put(filename, file, {
    access: 'public',
    contentType: file.type,
  })

  return NextResponse.json({ url: blob.url })
}
```

## Checklist

Before deploying Next.js apps:

- [ ] No secrets in client bundle (check `NEXT_PUBLIC_` prefix)
- [ ] All API routes validate input with Zod
- [ ] Authentication middleware protects private routes
- [ ] CSRF protection on state-changing operations
- [ ] Rate limiting on API endpoints
- [ ] Security headers configured in `next.config.js`
- [ ] File uploads validated (size, type)
- [ ] Session tokens stored in httpOnly cookies
- [ ] SQL queries use Prisma (parameterized)
- [ ] Error messages don't leak sensitive data
- [ ] `npm audit` passes with no HIGH+ vulnerabilities
