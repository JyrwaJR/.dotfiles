---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---
# React Security

> This file extends [web/security.md](../web/security.md) with React-specific security content.

## XSS Prevention

### Never Use dangerouslySetInnerHTML

```tsx
// WRONG: XSS vulnerability
<div dangerouslySetInnerHTML={{ __html: userContent }} />

// CORRECT: Sanitize with DOMPurify
import DOMPurify from 'dompurify'

const sanitizedContent = DOMPurify.sanitize(userContent)
<div dangerouslySetInnerHTML={{ __html: sanitizedContent }} />

// BETTER: Avoid HTML injection entirely
<div>{userContent}</div>
```

### Avoid Dynamic Script Execution

```tsx
// WRONG: Script injection
const script = document.createElement('script')
script.src = userInput
document.head.appendChild(script)

// CORRECT: Never execute dynamic scripts
// If you need dynamic URLs, validate against an allowlist
const ALLOWED_SCRIPTS = ['https://trusted-cdn.com/script.js']

if (ALLOWED_SCRIPTS.includes(userInput)) {
  const script = document.createElement('script')
  script.src = userInput
  document.head.appendChild(script)
}
```

## URL Security

### Validate URLs Before Navigation

```tsx
// WRONG: Open redirect vulnerability
function ExternalLink({ url, children }: ExternalLinkProps) {
  return <a href={url} target="_blank" rel="noopener noreferrer">{children}</a>
}

// CORRECT: Validate URL scheme and domain
const ALLOWED_DOMAINS = ['example.com', 'docs.example.com']

function ExternalLink({ url, children }: ExternalLinkProps) {
  const isValid = useMemo(() => {
    try {
      const parsed = new URL(url)
      return (
        parsed.protocol === 'https:' &&
        ALLOWED_DOMAINS.some(domain => parsed.hostname === domain)
      )
    } catch {
      return false
    }
  }, [url])

  if (!isValid) {
    console.warn(`Blocked navigation to invalid URL: ${url}`)
    return <span>{children}</span>
  }

  return <a href={url} target="_blank" rel="noopener noreferrer">{children}</a>
}
```

### Prevent Open Redirects

```tsx
// WRONG: Direct redirect from user input
function LoginSuccess() {
  const params = new URLSearchParams(window.location.search)
  const redirectTo = params.get('redirect') || '/'

  useEffect(() => {
    window.location.href = redirectTo // Open redirect!
  }, [])

  return <div>Logging in...</div>
}

// CORRECT: Validate redirect destination
const ALLOWED_REDIRECTS = ['/dashboard', '/settings', '/profile']

function LoginSuccess() {
  const params = new URLSearchParams(window.location.search)
  const redirectTo = params.get('redirect') || '/'

  const safeRedirect = ALLOWED_REDIRECTS.includes(redirectTo)
    ? redirectTo
    : '/dashboard'

  useEffect(() => {
    router.push(safeRedirect)
  }, [])

  return <div>Logging in...</div>
}
```

## State Security

### Don't Store Sensitive Data in Client State

```tsx
// WRONG: Storing tokens in React state (accessible via DevTools)
const [token, setToken] = useState<string | null>(null)

// CORRECT: Use httpOnly cookies (set by server)
// Client never sees the token
const { user, isAuthenticated } = useAuth() // Cookie-based auth
```

### Don't Trust Client-Side Data

```tsx
// WRONG: Trusting client-computed values for authorization
function AdminPanel() {
  const { user } = useAuth()

  // BAD: User could manipulate isAdmin in client state
  if (!user.isAdmin) {
    return <div>Access Denied</div>
  }

  return <AdminContent />
}

// CORRECT: Server-side authorization
// API routes must verify admin status independently
async function adminHandler(req: Request) {
  const session = await getSession(req)

  if (!session?.user?.isAdmin) {
    return new Response('Forbidden', { status: 403 })
  }

  // Process admin request
}
```

## Input Validation

### Client-Side Validation (UX Only)

```tsx
// Client-side validation is for UX, not security
function ContactForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ContactInput>({
    resolver: zodResolver(contactSchema),
  })

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('email')}
        aria-invalid={errors.email ? 'true' : 'false'}
      />
      {errors.email && <span role="alert">{errors.email.message}</span>}

      <button type="submit">Send</button>
    </form>
  )
}

// Server-side validation is for security
async function contactHandler(req: Request) {
  const body = await req.json()

  // ALWAYS validate on server
  const result = contactSchema.safeParse(body)
  if (!result.success) {
    return new Response(
      JSON.stringify({ errors: result.error.flatten() }),
      { status: 400 }
    )
  }

  // Process validated data
}
```

## Authentication Patterns

### Secure Token Handling

```tsx
// WRONG: Storing JWT in localStorage (XSS vulnerable)
localStorage.setItem('token', jwt)

// CORRECT: Use httpOnly cookies (set by server response)
// Server sets: Set-Cookie: session=xxx; HttpOnly; Secure; SameSite=Strict
// Client never accesses the cookie directly
```

### CSRF Protection

```tsx
// Include CSRF token in state-changing requests
async function updateUser(data: UpdateUserDto) {
  const csrfToken = getCsrfToken() // From meta tag or cookie

  const response = await fetch('/api/user', {
    method: 'PUT',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': csrfToken,
    },
    body: JSON.stringify(data),
  })

  return response.json()
}
```

## Secure Context Usage

### Environment Variables

```tsx
// WRONG: Exposing secrets to client
const API_KEY = process.env.API_SECRET // Bundled into client code

// CORRECT: Only NEXT_PUBLIC_ prefix is exposed
const PUBLIC_API_URL = process.env.NEXT_PUBLIC_API_URL // Safe for client
// process.env.API_SECRET only available server-side
```

### Content Security Policy

```tsx
// In _document.tsx or layout.tsx
<Head>
  <meta
    httpEquiv="Content-Security-Policy"
    content="default-src 'self'; script-src 'self' 'nonce-{RANDOM}'; style-src 'self' 'unsafe-inline'"
  />
</Head>
```

## Secure Dependencies

### Audit Dependencies

```bash
# Check for known vulnerabilities
npm audit
yarn audit
pnpm audit

# Fix automatically when possible
npm audit fix
```

### Avoid Dangerous Packages

- Never use `eval()` or `Function()` constructor
- Avoid packages that haven't been updated in 2+ years
- Check for known CVEs before adding new dependencies
- Use `npm audit` regularly

## Checklist

Before deploying React apps:

- [ ] No `dangerouslySetInnerHTML` with unsanitized input
- [ ] All URLs validated before navigation
- [ ] No secrets in client bundle (check `NEXT_PUBLIC_` prefix)
- [ ] Auth tokens stored in httpOnly cookies, not localStorage
- [ ] CSRF protection on state-changing operations
- [ ] Input validation on both client and server
- [ ] CSP headers configured
- [ ] Dependencies audited (`npm audit`)
- [ ] No `eval()` or `Function()` usage
- [ ] Open redirects prevented
