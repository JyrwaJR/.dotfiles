---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---
# React Coding Style

> This file extends [typescript/coding-style.md](../typescript/coding-style.md) with React-specific content.

## Component Organization

### File Structure

```text
src/
├── components/
│   ├── ui/                    # Generic, reusable UI primitives
│   │   ├── Button.tsx
│   │   ├── Input.tsx
│   │   └── index.ts
│   ├── features/              # Feature-specific components
│   │   ├── auth/
│   │   │   ├── LoginForm.tsx
│   │   │   ├── SignupForm.tsx
│   │   │   └── index.ts
│   │   └── dashboard/
│   │       ├── DashboardLayout.tsx
│   │       ├── StatsCard.tsx
│   │       └── index.ts
│   └── layouts/               # Page layouts
│       ├── AuthLayout.tsx
│       └── DashboardLayout.tsx
├── hooks/                     # Custom hooks
│   ├── useAuth.ts
│   └── useDebounce.ts
├── lib/                       # Utilities and helpers
│   ├── api.ts
│   └── utils.ts
├── types/                     # Shared TypeScript types
│   └── index.ts
└── App.tsx
```

### Component Patterns

#### Functional Components Only

Never use class components. Always use functional components with hooks.

```tsx
// WRONG: Class component
class UserCard extends React.Component<UserCardProps> {
  render() {
    return <div>{this.props.user.name}</div>
  }
}

// CORRECT: Functional component
interface UserCardProps {
  user: User
  onSelect: (id: string) => void
}

export function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <button onClick={() => onSelect(user.id)}>
      {user.name}
    </button>
  )
}
```

#### Props Destructuring

Destructure props in the function signature for clarity:

```tsx
// WRONG: Accessing props object
function UserCard(props: UserCardProps) {
  return <div>{props.user.name}</div>
}

// CORRECT: Destructured props
function UserCard({ user, onSelect }: UserCardProps) {
  return (
    <button onClick={() => onSelect(user.id)}>
      {user.name}
    </button>
  )
}
```

#### Default Exports for Pages, Named for Components

```tsx
// Pages and route components: default export
export default function DashboardPage() {
  return <DashboardLayout>...</DashboardLayout>
}

// Reusable components: named export
export function UserCard({ user }: UserCardProps) {
  return <div>{user.name}</div>
}
```

## Hooks Rules

### Custom Hook Naming

Always prefix custom hooks with `use`:

```tsx
// WRONG
function getUserData() { ... }
function fetchProducts() { ... }

// CORRECT
function useUserData() { ... }
function useProducts() { ... }
```

### Hook Placement

- Custom hooks go in `src/hooks/` or co-located with the feature
- Keep hooks focused on a single concern
- Extract complex logic into custom hooks

```tsx
// WRONG: Complex component with inline logic
function UserProfile({ userId }: UserProfileProps) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [userId])

  // ... 50 more lines of logic
}

// CORRECT: Extracted into custom hook
function useUser(userId: string) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false))
  }, [userId])

  return { user, loading, error }
}

function UserProfile({ userId }: UserProfileProps) {
  const { user, loading, error } = useUser(userId)

  if (loading) return <Spinner />
  if (error) return <ErrorMessage message={error} />
  if (!user) return null

  return <UserDetails user={user} />
}
```

### Hook Rules (React Strict Mode)

1. Call hooks at the top level - never inside loops, conditions, or nested functions
2. Only call hooks from React functions (components or custom hooks)
3. Use the Dependency Array correctly - include all values used inside the effect

```tsx
// WRONG: Hook inside condition
if (isLoggedIn) {
  const { data } = useUserData() // Violation!
}

// CORRECT: Hook at top level
const { data } = useUserData()
const userData = isLoggedIn ? data : null
```

## State Management

### Local State优先

Use `useState` or `useReducer` for component-level state. Don't reach for global state managers until you actually need shared state.

```tsx
// Simple state: useState
const [count, setCount] = useState(0)

// Complex state: useReducer
interface State {
  items: Item[]
  loading: boolean
  error: string | null
}

type Action =
  | { type: 'FETCH_START' }
  | { type: 'FETCH_SUCCESS'; payload: Item[] }
  | { type: 'FETCH_ERROR'; payload: string }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case 'FETCH_START':
      return { ...state, loading: true, error: null }
    case 'FETCH_SUCCESS':
      return { ...state, loading: false, items: action.payload }
    case 'FETCH_ERROR':
      return { ...state, loading: false, error: action.payload }
  }
}
```

### Prop Drilling Prevention

- Use context for truly global state (auth, theme, locale)
- Use composition to avoid deep prop drilling
- Consider state management libraries only when context is insufficient

```tsx
// WRONG: Prop drilling through 3+ levels
<Layout theme={theme}>
  <Sidebar theme={theme}>
    <NavItem theme={theme} active={active}>
      <Icon theme={theme} />
    </NavItem>
  </Sidebar>
</Layout>

// CORRECT: Context for global state
<ThemeProvider theme={theme}>
  <Layout>
    <Sidebar>
      <NavItem active={active}>
        <Icon />
      </NavItem>
    </Sidebar>
  </Layout>
</ThemeProvider>
```

## Performance

### Memoization

Use `React.memo` for components that receive the same props frequently:

```tsx
// Memoize expensive computations
const sortedItems = useMemo(() => {
  return items.sort((a, b) => a.name.localeCompare(b.name))
}, [items])

// Memoize callbacks passed to child components
const handleSelect = useCallback((id: string) => {
  setSelectedId(id)
}, [])

// Memoize components that receive complex objects
const MemoizedUserCard = React.memo(UserCard)
```

### Avoid Inline Objects and Functions in JSX

```tsx
// WRONG: New object/function on every render
<UserCard
  style={{ padding: '10px' }}
  onClick={() => handleClick(id)}
/>

// CORRECT: Stable references
const cardStyle = useMemo(() => ({ padding: '10px' }), [])
const handleClick = useCallback(() => handleClick(id), [id])

<UserCard style={cardStyle} onClick={handleClick} />
```

### Lazy Loading

Use `React.lazy` for code splitting:

```tsx
import { lazy, Suspense } from 'react'

const Dashboard = lazy(() => import('./pages/Dashboard'))
const Settings = lazy(() => import('./pages/Settings'))

function App() {
  return (
    <Suspense fallback={<Spinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  )
}
```

## Error Handling

### Error Boundaries

Wrap critical UI sections with error boundaries:

```tsx
import { Component, ErrorInfo, ReactNode } from 'react'

interface ErrorBoundaryProps {
  children: ReactNode
  fallback?: ReactNode
}

interface ErrorBoundaryState {
  hasError: boolean
  error: Error | null
}

export class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props)
    this.state = { hasError: false, error: null }
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    console.error('ErrorBoundary caught:', error, errorInfo)
  }

  render() {
    if (this.state.hasError) {
      return this.props.fallback || <ErrorMessage error={this.state.error} />
    }
    return this.props.children
  }
}
```

### Async Error Handling

Use error boundaries or try-catch for async operations:

```tsx
function useAsyncData<T>(fetcher: () => Promise<T>) {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<Error | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false

    fetcher()
      .then(result => {
        if (!cancelled) {
          setData(result)
          setLoading(false)
        }
      })
      .catch(err => {
        if (!cancelled) {
          setError(err instanceof Error ? err : new Error(String(err)))
          setLoading(false)
        }
      })

    return () => {
      cancelled = true
    }
  }, [fetcher])

  return { data, error, loading }
}
```

## Accessibility

### Semantic HTML

Use semantic elements before reaching for generic divs:

```tsx
// WRONG: Non-semantic
<div onClick={handleClick}>Click me</div>
<div class="nav">...</div>

// CORRECT: Semantic
<button onClick={handleClick}>Click me</button>
<nav aria-label="Main navigation">...</nav>
```

### ARIA Attributes

Add ARIA attributes when semantic HTML isn't sufficient:

```tsx
<div
  role="tablist"
  aria-label="Settings tabs"
>
  <button
    role="tab"
    aria-selected={activeTab === 'general'}
    aria-controls="general-panel"
  >
    General
  </button>
</div>
```

### Keyboard Navigation

Ensure all interactive elements are keyboard accessible:

```tsx
function Dropdown({ items, onSelect }: DropdownProps) {
  const [isOpen, setIsOpen] = useState(false)

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') {
      setIsOpen(false)
    }
  }

  return (
    <div onKeyDown={handleKeyDown}>
      <button
        onClick={() => setIsOpen(!isOpen)}
        aria-expanded={isOpen}
        aria-haspopup="listbox"
      >
        Select option
      </button>
      {isOpen && (
        <ul role="listbox">
          {items.map(item => (
            <li
              key={item.id}
              role="option"
              tabIndex={0}
              onClick={() => onSelect(item.id)}
              onKeyDown={e => {
                if (e.key === 'Enter') onSelect(item.id)
              }}
            >
              {item.label}
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
```

## Testing

### Component Testing

Test components in isolation with React Testing Library:

```tsx
import { render, screen, fireEvent } from '@testing-library/react'
import { UserCard } from './UserCard'

describe('UserCard', () => {
  const mockUser = { id: '1', name: 'John Doe', email: 'john@example.com' }
  const mockOnSelect = jest.fn()

  it('renders user name and email', () => {
    render(<UserCard user={mockUser} onSelect={mockOnSelect} />)

    expect(screen.getByText('John Doe')).toBeInTheDocument()
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
  })

  it('calls onSelect with user id when clicked', () => {
    render(<UserCard user={mockUser} onSelect={mockOnSelect} />)

    fireEvent.click(screen.getByRole('button'))
    expect(mockOnSelect).toHaveBeenCalledWith('1')
  })
})
```

### Hook Testing

Test custom hooks with `renderHook`:

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
})
```
