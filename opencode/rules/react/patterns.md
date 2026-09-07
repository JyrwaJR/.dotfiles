---
paths:
  - "**/*.tsx"
  - "**/*.jsx"
---
# React Patterns

> This file extends [web/patterns.md](../web/patterns.md) with React-specific patterns.

## Component Composition Patterns

### Compound Components

Use compound components for complex widgets that share state:

```tsx
// Tabs compound component
interface TabsContextValue {
  activeTab: string
  setActiveTab: (value: string) => void
}

const TabsContext = createContext<TabsContextValue | null>(null)

function useTabsContext() {
  const context = useContext(TabsContext)
  if (!context) {
    throw new Error('Tabs compound components must be used within <Tabs>')
  }
  return context
}

interface TabsProps {
  defaultValue: string
  children: ReactNode
}

export function Tabs({ defaultValue, children }: TabsProps) {
  const [activeTab, setActiveTab] = useState(defaultValue)

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div data-testid="tabs">{children}</div>
    </TabsContext.Provider>
  )
}

interface TabListProps {
  children: ReactNode
}

Tabs.List = function TabList({ children }: TabListProps) {
  return (
    <div role="tablist" className="flex border-b">
      {children}
    </div>
  )
}

interface TabTriggerProps {
  value: string
  children: ReactNode
}

Tabs.Trigger = function TabTrigger({ value, children }: TabTriggerProps) {
  const { activeTab, setActiveTab } = useTabsContext()

  return (
    <button
      role="tab"
      aria-selected={activeTab === value}
      onClick={() => setActiveTab(value)}
      className={cn(
        'px-4 py-2 border-b-2',
        activeTab === value ? 'border-primary' : 'border-transparent'
      )}
    >
      {children}
    </button>
  )
}

interface TabContentProps {
  value: string
  children: ReactNode
}

Tabs.Content = function TabContent({ value, children }: TabContentProps) {
  const { activeTab } = useTabsContext()

  if (activeTab !== value) return null

  return (
    <div role="tabpanel" className="p-4">
      {children}
    </div>
  )
}

// Usage
<Tabs defaultValue="overview">
  <Tabs.List>
    <Tabs.Trigger value="overview">Overview</Tabs.Trigger>
    <Tabs.Trigger value="settings">Settings</Tabs.Trigger>
  </Tabs.List>
  <Tabs.Content value="overview">Overview content</Tabs.Content>
  <Tabs.Content value="settings">Settings content</Tabs.Content>
</Tabs>
```

### Render Props / Children as Functions

Use when behavior needs to be shared but markup varies:

```tsx
interface MouseTrackerProps {
  children: (position: { x: number; y: number }) => ReactNode
}

export function MouseTracker({ children }: MouseTrackerProps) {
  const [position, setPosition] = useState({ x: 0, y: 0 })

  const handleMouseMove = (e: React.MouseEvent) => {
    setPosition({ x: e.clientX, y: e.clientY })
  }

  return (
    <div onMouseMove={handleMouseMove}>
      {children(position)}
    </div>
  )
}

// Usage
<MouseTracker>
  {({ x, y }) => (
    <div>Mouse is at ({x}, {y})</div>
  )}
</MouseTracker>
```

### Higher-Order Components (HOC)

Use sparingly - prefer hooks for logic reuse:

```tsx
interface WithAuthProps {
  isAuthenticated: boolean
  user: User | null
}

export function withAuth<P extends WithAuthProps>(
  WrappedComponent: React.ComponentType<P>
) {
  return function WithAuthComponent(props: Omit<P, keyof WithAuthProps>) {
    const { isAuthenticated, user } = useAuth()

    if (!isAuthenticated) {
      return <Redirect to="/login" />
    }

    return <WrappedComponent {...(props as P)} isAuthenticated={isAuthenticated} user={user} />
  }
}

// Usage
const ProtectedDashboard = withAuth(Dashboard)
```

## Data Fetching Patterns

### Server State with React Query / TanStack Query

```tsx
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'

// Query hook
function useUser(userId: string) {
  return useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
    staleTime: 5 * 60 * 1000, // 5 minutes
  })
}

// Mutation hook
function useUpdateUser() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (data: UpdateUserDto) => updateUser(data),
    onSuccess: (updatedUser) => {
      queryClient.invalidateQueries({ queryKey: ['user', updatedUser.id] })
    },
  })
}

// Usage in component
function UserProfile({ userId }: UserProfileProps) {
  const { data: user, isLoading, error } = useUser(userId)
  const updateUser = useUpdateUser()

  if (isLoading) return <Spinner />
  if (error) return <ErrorMessage error={error} />
  if (!user) return null

  return (
    <div>
      <h1>{user.name}</h1>
      <button
        onClick={() => updateUser.mutate({ name: 'New Name' })}
        disabled={updateUser.isPending}
      >
        {updateUser.isPending ? 'Saving...' : 'Update Name'}
      </button>
    </div>
  )
}
```

### Optimistic Updates

```tsx
function useToggleTodo() {
  const queryClient = useQueryClient()

  return useMutation({
    mutationFn: (todo: Todo) => toggleTodo(todo.id),
    onMutate: async (todo) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries({ queryKey: ['todos'] })

      // Snapshot previous value
      const previousTodos = queryClient.getQueryData<Todo[]>(['todos'])

      // Optimistically update
      queryClient.setQueryData<Todo[]>(['todos'], (old) =>
        old?.map((t) =>
          t.id === todo.id ? { ...t, completed: !t.completed } : t
        )
      )

      return { previousTodos }
    },
    onError: (err, todo, context) => {
      // Rollback on error
      queryClient.setQueryData(['todos'], context?.previousTodos)
    },
    onSettled: () => {
      // Refetch after error or success
      queryClient.invalidateQueries({ queryKey: ['todos'] })
    },
  })
}
```

## Form Patterns

### React Hook Form + Zod

```tsx
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
})

type LoginInput = z.infer<typeof loginSchema>

export function LoginForm() {
  const {
    register,
    handleSubmit,
    formState: { errors, isSubmitting },
  } = useForm<LoginInput>({
    resolver: zodResolver(loginSchema),
  })

  const onSubmit = async (data: LoginInput) => {
    try {
      await login(data)
    } catch (error) {
      // Handle error
    }
  }

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          type="email"
          {...register('email')}
          aria-invalid={errors.email ? 'true' : 'false'}
        />
        {errors.email && (
          <span role="alert">{errors.email.message}</span>
        )}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input
          id="password"
          type="password"
          {...register('password')}
          aria-invalid={errors.password ? 'true' : 'false'}
        />
        {errors.password && (
          <span role="alert">{errors.password.message}</span>
        )}
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Logging in...' : 'Log in'}
      </button>
    </form>
  )
}
```

## State Machine Patterns

Use XState or finite state machines for complex state logic:

```tsx
import { useMachine } from '@xstate/react'
import { createMachine } from 'xstate'

const fetchMachine = createMachine({
  id: 'fetch',
  initial: 'idle',
  context: {
    data: null,
    error: null,
  },
  states: {
    idle: {
      on: { FETCH: 'loading' },
    },
    loading: {
      invoke: {
        src: 'fetchData',
        onDone: {
          target: 'success',
          actions: 'setData',
        },
        onError: {
          target: 'failure',
          actions: 'setError',
        },
      },
    },
    success: {
      on: { FETCH: 'loading' },
    },
    failure: {
      on: { RETRY: 'loading' },
    },
  },
})

export function DataFetcher() {
  const [state, send] = useMachine(fetchMachine, {
    services: {
      fetchData: async () => {
        const response = await fetch('/api/data')
        return response.json()
      },
    },
  })

  return (
    <div>
      {state.matches('idle') && (
        <button onClick={() => send('FETCH')}>Load Data</button>
      )}
      {state.matches('loading') && <Spinner />}
      {state.matches('success') && (
        <pre>{JSON.stringify(state.context.data, null, 2)}</pre>
      )}
      {state.matches('failure') && (
        <div>
          <p>Error: {state.context.error?.message}</p>
          <button onClick={() => send('RETRY')}>Retry</button>
        </div>
      )}
    </div>
  )
}
```

## Performance Patterns

### Virtualization for Long Lists

```tsx
import { useVirtualizer } from '@tanstack/react-virtual'

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 50,
  })

  return (
    <div ref={parentRef} style={{ height: '400px', overflow: 'auto' }}>
      <div
        style={{
          height: `${virtualizer.getTotalSize()}px`,
          width: '100%',
          position: 'relative',
        }}
      >
        {virtualizer.getVirtualItems().map((virtualRow) => (
          <div
            key={virtualRow.key}
            style={{
              position: 'absolute',
              top: 0,
              left: 0,
              width: '100%',
              height: `${virtualRow.size}px`,
              transform: `translateY(${virtualRow.start}px)`,
            }}
          >
            {items[virtualRow.index].name}
          </div>
        ))}
      </div>
    </div>
  )
}
```

### Debounced Search

```tsx
function SearchInput({ onSearch }: { onSearch: (query: string) => void }) {
  const [inputValue, setInputValue] = useState('')
  const debouncedSearch = useDebounce(onSearch, 300)

  const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const value = e.target.value
    setInputValue(value)
    debouncedSearch(value)
  }

  return (
    <input
      type="search"
      value={inputValue}
      onChange={handleChange}
      placeholder="Search..."
    />
  )
}
```
