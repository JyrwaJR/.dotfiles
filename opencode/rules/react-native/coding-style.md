---
paths:
  - "**/*.tsx"
  - "**/*.ts"
  - "app.json"
  - "expo.config.*"
---
# React Native / Expo Coding Style

> This file extends [react/coding-style.md](../react/coding-style.md) with React Native-specific content.

## Project Structure (Expo Router)

### Directory Layout

```text
src/
├── app/                          # Expo Router file-based routing
│   ├── (auth)/                   # Auth route group
│   │   ├── login.tsx             # /login
│   │   ├── register.tsx          # /register
│   │   └── _layout.tsx
│   ├── (tabs)/                   # Tab navigator group
│   │   ├── index.tsx             # / (home tab)
│   │   ├── explore.tsx           # /explore
│   │   ├── profile.tsx           # /profile
│   │   └── _layout.tsx
│   ├── modal/
│   │   └── [id].tsx              # /modal/:id
│   ├── _layout.tsx               # Root layout
│   └── +not-found.tsx            # 404
├── components/
│   ├── ui/                       # Generic UI primitives
│   │   ├── Button.tsx
│   │   ├── Card.tsx
│   │   ├── Input.tsx
│   │   └── index.ts
│   └── features/                 # Feature-specific components
│       ├── auth/
│       │   ├── LoginForm.tsx
│       │   └── RegisterForm.tsx
│       └── profile/
│           ├── ProfileHeader.tsx
│           └── ProfileSettings.tsx
├── hooks/                        # Custom hooks
│   ├── useAuth.ts
│   ├── useColorScheme.ts
│   └── useKeyboard.ts
├── lib/
│   ├── api.ts                    # API client
│   ├── storage.ts                # AsyncStorage helpers
│   └── utils.ts                  # General utilities
├── services/                     # Business logic services
│   ├── auth.service.ts
│   └── user.service.ts
├── types/                        # TypeScript types
│   └── index.ts
└── constants/                    # App constants
    ├── colors.ts
    └── layout.ts
```

## Component Patterns

### Functional Components Only

```tsx
// WRONG: Class component
class UserProfile extends React.Component<UserProfileProps> {
  render() {
    return <View><Text>{this.props.user.name}</Text></View>
  }
}

// CORRECT: Functional component
interface UserProfileProps {
  user: User
}

export function UserProfile({ user }: UserProfileProps) {
  return (
    <View>
      <Text>{user.name}</Text>
    </View>
  )
}
```

### Platform-Specific Code

```tsx
import { Platform, StyleSheet } from 'react-native'

// Platform-specific styles
const styles = StyleSheet.create({
  container: {
    ...Platform.select({
      ios: {
        shadowColor: '#000',
        shadowOffset: { width: 0, height: 2 },
        shadowOpacity: 0.1,
        shadowRadius: 4,
      },
      android: {
        elevation: 4,
      },
    }),
  },
})

// Platform-specific components
import { Platform } from 'react-native'

export function Header() {
  return Platform.OS === 'ios'
    ? <IOSHeader />
    : <AndroidHeader />
}
```

### Responsive Design

```tsx
import { useWindowDimensions } from 'react-native'

export function ResponsiveLayout({ children }: { children: React.ReactNode }) {
  const { width, height } = useWindowDimensions()
  const isLandscape = width > height

  return (
    <View style={[
      styles.container,
      isLandscape && styles.landscape
    ]}>
      {children}
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 16,
  },
  landscape: {
    flexDirection: 'row',
  },
})
```

## State Management

### Local State优先

```tsx
import { useState, useCallback } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)

  const increment = useCallback(() => {
    setCount(prev => prev + 1)
  }, [])

  const decrement = useCallback(() => {
    setCount(prev => prev - 1)
  }, [])

  return (
    <View>
      <Text>{count}</Text>
      <Button title="Increment" onPress={increment} />
      <Button title="Decrement" onPress={decrement} />
    </View>
  )
}
```

### Global State with Zustand

```typescript
// stores/auth.store.ts
import { create } from 'zustand'
import { persist, createJSONStorage } from 'zustand/middleware'
import AsyncStorage from '@react-native-async-storage/async-storage'

interface AuthState {
  user: User | null
  token: string | null
  isAuthenticated: boolean
  login: (user: User, token: string) => void
  logout: () => void
  updateUser: (user: Partial<User>) => void
}

export const useAuthStore = create<AuthState>()(
  persist(
    (set) => ({
      user: null,
      token: null,
      isAuthenticated: false,
      login: (user, token) =>
        set({ user, token, isAuthenticated: true }),
      logout: () =>
        set({ user: null, token: null, isAuthenticated: false }),
      updateUser: (userData) =>
        set((state) => ({
          user: state.user ? { ...state.user, ...userData } : null,
        })),
    }),
    {
      name: 'auth-storage',
      storage: createJSONStorage(() => AsyncStorage),
    }
  )
)
```

## Navigation Patterns

### Expo Router Layouts

```tsx
// app/_layout.tsx
import { Stack } from 'expo-router'
import { useAuthStore } from '@/stores/auth.store'

export default function RootLayout() {
  const { isAuthenticated } = useAuthStore()

  return (
    <Stack>
      {isAuthenticated ? (
        <Stack.Screen name="(tabs)" options={{ headerShown: false }} />
      ) : (
        <Stack.Screen name="(auth)" options={{ headerShown: false }} />
      )}
      <Stack.Screen
        name="modal"
        options={{ presentation: 'modal' }}
      />
    </Stack>
  )
}
```

### Tab Navigation

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router'
import { Ionicons } from '@expo/vector-icons'

export default function TabLayout() {
  return (
    <Tabs>
      <Tabs.Screen
        name="index"
        options={{
          title: 'Home',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="home" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="explore"
        options={{
          title: 'Explore',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="search" size={size} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color, size }) => (
            <Ionicons name="person" size={size} color={color} />
          ),
        }}
      />
    </Tabs>
  )
}
```

## Styling

### StyleSheet Best Practices

```tsx
import { StyleSheet, useColorScheme } from 'react-native'
import { Colors } from '@/constants/colors'

export function ThemedCard({ children }: { children: React.ReactNode }) {
  const colorScheme = useColorScheme()
  const colors = Colors[colorScheme ?? 'light']

  return (
    <View style={[styles.card, { backgroundColor: colors.card }]}>
      {children}
    </View>
  )
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 12,
    padding: 16,
    marginVertical: 8,
  },
})
```

### Theme System

```typescript
// constants/colors.ts
export const Colors = {
  light: {
    primary: '#007AFF',
    background: '#FFFFFF',
    card: '#F2F2F7',
    text: '#000000',
    textSecondary: '#8E8E93',
    border: '#C6C6C8',
    error: '#FF3B30',
    success: '#34C759',
  },
  dark: {
    primary: '#0A84FF',
    background: '#000000',
    card: '#1C1C1E',
    text: '#FFFFFF',
    textSecondary: '#8E8E93',
    border: '#38383A',
    error: '#FF453A',
    success: '#30D158',
  },
}
```

## Performance

### FlatList for Long Lists

```tsx
import { FlatList, RefreshControl } from 'react-native'

export function UserList({ users }: { users: User[] }) {
  const [refreshing, setRefreshing] = useState(false)

  const onRefresh = useCallback(async () => {
    setRefreshing(true)
    await refetch()
    setRefreshing(false)
  }, [])

  const renderItem = useCallback(({ item }: { item: User }) => (
    <UserCard user={item} />
  ), [])

  const keyExtractor = useCallback((item: User) => item.id, [])

  return (
    <FlatList
      data={users}
      renderItem={renderItem}
      keyExtractor={keyExtractor}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
      // Performance optimizations
      initialNumToRender={10}
      maxToRenderPerBatch={10}
      windowSize={5}
      removeClippedSubviews={true}
      getItemLayout={(data, index) => ({
        length: 80,
        offset: 80 * index,
        index,
      })}
    />
  )
}
```

### Image Optimization

```tsx
import { Image } from 'expo-image'

// Use expo-image for better performance
<Image
  source={{ uri: 'https://example.com/image.jpg' }}
  style={{ width: 200, height: 200 }}
  contentFit="cover"
  transition={300}
  placeholder={{ blurhash: 'L6Pj0^i_.AyE_3t7t7R**0o#DgR4' }}
/>

// For local images
const localImage = require('@/assets/images/local.png')

<Image
  source={localImage}
  style={{ width: 100, height: 100 }}
/>
```

## Testing

### Component Testing

```tsx
// components/features/auth/LoginForm.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react-native'
import { LoginForm } from './LoginForm'

describe('LoginForm', () => {
  it('renders correctly', () => {
    render(<LoginForm onSubmit={jest.fn()} />)

    expect(screen.getByPlaceholderText('Email')).toBeTruthy()
    expect(screen.getByPlaceholderText('Password')).toBeTruthy()
    expect(screen.getByRole('button', { name: 'Log in' })).toBeTruthy()
  })

  it('calls onSubmit with correct data', async () => {
    const onSubmit = jest.fn()
    render(<LoginForm onSubmit={onSubmit} />)

    fireEvent.changeText(screen.getByPlaceholderText('Email'), 'test@example.com')
    fireEvent.changeText(screen.getByPlaceholderText('Password'), 'password123')
    fireEvent.press(screen.getByRole('button', { name: 'Log in' }))

    await waitFor(() => {
      expect(onSubmit).toHaveBeenCalledWith({
        email: 'test@example.com',
        password: 'password123',
      })
    })
  })

  it('displays validation errors', async () => {
    render(<LoginForm onSubmit={jest.fn()} />)

    fireEvent.press(screen.getByRole('button', { name: 'Log in' }))

    await waitFor(() => {
      expect(screen.getByText('Email is required')).toBeTruthy()
      expect(screen.getByText('Password is required')).toBeTruthy()
    })
  })
})
```

### Hook Testing

```tsx
// hooks/useAuth.test.ts
import { renderHook, act } from '@testing-library/react-native'
import { useAuth } from './useAuth'

describe('useAuth', () => {
  it('returns initial state', () => {
    const { result } = renderHook(() => useAuth())

    expect(result.current.isAuthenticated).toBe(false)
    expect(result.current.user).toBeNull()
  })

  it('logs in user', async () => {
    const { result } = renderHook(() => useAuth())

    await act(async () => {
      await result.current.login('test@example.com', 'password123')
    })

    expect(result.current.isAuthenticated).toBe(true)
    expect(result.current.user).not.toBeNull()
  })
})
```

## Checklist

- [ ] Expo Router file-based routing
- [ ] Functional components only
- [ ] Platform-specific code handled
- [ ] Responsive design with useWindowDimensions
- [ ] FlatList for long lists (not ScrollView)
- [ ] Image optimization with expo-image
- [ ] Theme system implemented
- [ ] State management (Zustand/local state)
- [ ] Navigation patterns correct
- [ ] Component tests with React Native Testing Library
