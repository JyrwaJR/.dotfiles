---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.test.tsx"
  - "**/*.test.jsx"
  - "**/*.spec.tsx"
  - "**/*.spec.jsx"
---
# React Testing

> This file extends [web/testing.md](../web/testing.md) with React-specific testing content.

## Testing Library Principles

### Use React Testing Library

Prefer React Testing Library over Enzyme. Test behavior, not implementation details.

```tsx
// WRONG: Testing implementation details
expect(wrapper.state('isLoading')).toBe(true)
expect(wrapper.find('.loading-spinner').length).toBe(1)

// CORRECT: Testing behavior
expect(screen.getByText('Loading...')).toBeInTheDocument()
```

### Query Priority

Use queries in this priority order:

1. `getByRole` - Most accessible, reflects user experience
2. `getByLabelText` - Best for form elements
3. `getByPlaceholderText` - When no label is available
4. `getByText` - For non-interactive elements
5. `getByTestId` - Last resort, add `data-testid` to component

```tsx
// GOOD: Accessible queries
screen.getByRole('button', { name: 'Submit' })
screen.getByLabelText('Email')
screen.getByText('Welcome back')

// BAD: Brittle queries
screen.getByClassName('btn-primary')
screen.getByCssSelector('div > form > button')
```

## Component Testing

### User Events Over Fire Events

```tsx
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'

describe('Counter', () => {
  it('increments when button is clicked', async () => {
    const user = userEvent.setup()
    render(<Counter />)

    expect(screen.getByText('Count: 0')).toBeInTheDocument()

    await user.click(screen.getByRole('button', { name: 'Increment' }))

    expect(screen.getByText('Count: 1')).toBeInTheDocument()
  })
})
```

### Async Operations

```tsx
import { render, screen, waitFor } from '@testing-library/react'

describe('UserProfile', () => {
  it('loads and displays user data', async () => {
    // Mock API
    server.use(
      rest.get('/api/user/:id', (req, res, ctx) => {
        return res(
          ctx.json({ id: '1', name: 'John Doe', email: 'john@example.com' })
        )
      })
    )

    render(<UserProfile userId="1" />)

    // Wait for loading to complete
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })

    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })
})
```

## Hook Testing

### renderHook

```tsx
import { renderHook, act } from '@testing-library/react'
import { useCounter } from './useCounter'

describe('useCounter', () => {
  it('increments count', () => {
    const { result } = renderHook(() => useCounter(0))

    act(() => {
      result.current.increment()
    })

    expect(result.current.count).toBe(1)
  })

  it('respects max value', () => {
    const { result } = renderHook(() => useCounter(0, { max: 5 }))

    act(() => {
      for (let i = 0; i < 10; i++) {
        result.current.increment()
      }
    })

    expect(result.current.count).toBe(5)
  })
})
```

### Custom Hook with Context

```tsx
import { renderHook } from '@testing-library/react'
import { AuthProvider } from './AuthContext'
import { useAuth } from './useAuth'

describe('useAuth', () => {
  it('provides authentication state', () => {
    const wrapper = ({ children }: { children: React.ReactNode }) => (
      <AuthProvider>{children}</AuthProvider>
    )

    const { result } = renderHook(() => useAuth(), { wrapper })

    expect(result.current.isAuthenticated).toBe(false)
    expect(result.current.user).toBeNull()
  })
})
```

## Integration Testing

### Full Flow Testing

```tsx
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { server } from '../mocks/server'
import { App } from './App'

describe('Login Flow', () => {
  it('completes login successfully', async () => {
    const user = userEvent.setup()

    // Setup mock
    server.use(
      rest.post('/api/login', (req, res, ctx) => {
        return res(
          ctx.json({ user: { id: '1', name: 'John' }, token: 'fake-token' })
        )
      })
    )

    render(<App />)

    // Navigate to login
    await user.click(screen.getByRole('link', { name: 'Login' }))

    // Fill form
    await user.type(screen.getByLabelText('Email'), 'john@example.com')
    await user.type(screen.getByLabelText('Password'), 'password123')

    // Submit
    await user.click(screen.getByRole('button', { name: 'Log in' }))

    // Verify success
    await waitFor(() => {
      expect(screen.getByText('Welcome, John!')).toBeInTheDocument()
    })
  })
})
```

## Mocking

### Mocking Modules

```tsx
import { render, screen } from '@testing-library/react'
import { useRouter } from 'next/router'
import { Dashboard } from './Dashboard'

// Mock the router
jest.mock('next/router', () => ({
  useRouter: jest.fn(),
}))

describe('Dashboard', () => {
  it('redirects to login when not authenticated', () => {
    const push = jest.fn()
    ;(useRouter as jest.Mock).mockReturnValue({ push })

    render(<Dashboard />)

    expect(push).toHaveBeenCalledWith('/login')
  })
})
```

### Mocking API Calls

```tsx
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { render, screen, waitFor } from '@testing-library/react'
import { UserList } from './UserList'

const server = setupServer(
  rest.get('/api/users', (req, res, ctx) => {
    return res(
      ctx.json([
        { id: '1', name: 'John' },
        { id: '2', name: 'Jane' },
      ])
    )
  })
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

describe('UserList', () => {
  it('displays users', async () => {
    render(<UserList />)

    await waitFor(() => {
      expect(screen.getByText('John')).toBeInTheDocument()
      expect(screen.getByText('Jane')).toBeInTheDocument()
    })
  })
})
```

## Snapshot Testing

### When to Use

Use snapshots sparingly and only for stable, low-churn components:

```tsx
// Good: Simple UI component
it('renders correctly', () => {
  const { container } = render(<Button>Click me</Button>)
  expect(container).toMatchSnapshot()
})

// Bad: Dynamic content
it('renders user profile', () => {
  // Don't snapshot - too many variations
  expect(screen.getByText(user.name)).toBeInTheDocument()
})
```

## Accessibility Testing

### Automated Checks

```tsx
import { render, screen } from '@testing-library/react'
import { axe, toHaveNoViolations } from 'jest-axe'

expect.extend(toHaveNoViolations)

describe('LoginForm', () => {
  it('has no accessibility violations', async () => {
    const { container } = render(<LoginForm />)
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })
})
```

### Manual Accessibility Checks

```tsx
it('is keyboard navigable', async () => {
  const user = userEvent.setup()
  render(<LoginForm />)

  // Tab to first input
  await user.tab()
  expect(screen.getByLabelText('Email')).toHaveFocus()

  // Tab to next input
  await user.tab()
  expect(screen.getByLabelText('Password')).toHaveFocus()

  // Tab to submit button
  await user.tab()
  expect(screen.getByRole('button', { name: 'Log in' })).toHaveFocus()
})
```

## Test Organization

### File Structure

```text
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx
│   │   └── Button.stories.tsx
│   └── index.ts
├── hooks/
│   ├── useAuth.ts
│   └── useAuth.test.ts
└── __tests__/
    └── integration/
        └── login-flow.test.tsx
```

### Test Categories

1. **Unit Tests** - Individual functions, hooks, utilities
2. **Component Tests** - Component rendering and interaction
3. **Integration Tests** - Multiple components working together
4. **E2E Tests** - Full user flows (Playwright)
