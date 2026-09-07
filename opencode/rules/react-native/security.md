---
paths:
  - "**/*.tsx"
  - "**/*.ts"
---
# React Native / Expo Security

> This file extends [react/security.md](../react/security.md) with React Native-specific security content.

## Secure Storage

### AsyncStorage vs SecureStore

```typescript
// WRONG: Sensitive data in AsyncStorage (unencrypted)
import AsyncStorage from '@react-native-async-storage/async-storage'

await AsyncStorage.setItem('token', jwt) // Insecure!

// CORRECT: Sensitive data in Expo SecureStore (encrypted)
import * as SecureStore from 'expo-secure-store'

// Store sensitive data
await SecureStore.setItemAsync('auth-token', jwt)

// Retrieve sensitive data
const token = await SecureStore.getItemAsync('auth-token')

// Delete sensitive data
await SecureStore.deleteItemAsync('auth-token')
```

### When to Use What

| Data Type | Storage | Reason |
|-----------|---------|--------|
| Auth tokens | SecureStore | Encrypted, hardware-backed |
| User preferences | AsyncStorage | Non-sensitive, needs persistence |
| Cache data | AsyncStorage | Temporary, non-sensitive |
| Biometric data | SecureStore | Highly sensitive |

## Authentication

### Secure Token Storage

```typescript
// services/auth.service.ts
import * as SecureStore from 'expo-secure-store'
import { Platform } from 'react-native'

const TOKEN_KEY = 'auth-token'
const REFRESH_KEY = 'refresh-token'

export class AuthService {
  async storeTokens(accessToken: string, refreshToken: string) {
    await SecureStore.setItemAsync(TOKEN_KEY, accessToken)
    await SecureStore.setItemAsync(REFRESH_KEY, refreshToken)
  }

  async getAccessToken(): Promise<string | null> {
    return SecureStore.getItemAsync(TOKEN_KEY)
  }

  async getRefreshToken(): Promise<string | null> {
    return SecureStore.getItemAsync(REFRESH_KEY)
  }

  async clearTokens() {
    await SecureStore.deleteItemAsync(TOKEN_KEY)
    await SecureStore.deleteItemAsync(REFRESH_KEY)
  }

  async refreshAccessToken(): Promise<string | null> {
    const refreshToken = await this.getRefreshToken()
    if (!refreshToken) return null

    try {
      const response = await fetch('/api/auth/refresh', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      })

      if (!response.ok) {
        await this.clearTokens()
        return null
      }

      const { accessToken, newRefreshToken } = await response.json()
      await this.storeTokens(accessToken, newRefreshToken)
      return accessToken
    } catch {
      await this.clearTokens()
      return null
    }
  }
}
```

### API Client with Auth

```typescript
// lib/api.ts
import * as SecureStore from 'expo-secure-store'

const API_BASE_URL = process.env.EXPO_PUBLIC_API_URL

class ApiClient {
  private async getHeaders(): Promise<HeadersInit> {
    const token = await SecureStore.getItemAsync('auth-token')
    return {
      'Content-Type': 'application/json',
      ...(token && { Authorization: `Bearer ${token}` }),
    }
  }

  async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const headers = await this.getHeaders()

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers: {
        ...headers,
        ...options.headers,
      },
    })

    if (response.status === 401) {
      // Token expired, try refresh
      const newToken = await this.refreshToken()
      if (newToken) {
        // Retry with new token
        return this.request(endpoint, options)
      }
      // Redirect to login
      throw new Error('Unauthorized')
    }

    if (!response.ok) {
      throw new Error(`API error: ${response.status}`)
    }

    return response.json()
  }

  private async refreshToken(): Promise<string | null> {
    const refreshToken = await SecureStore.getItemAsync('refresh-token')
    if (!refreshToken) return null

    try {
      const response = await fetch(`${API_BASE_URL}/auth/refresh`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ refreshToken }),
      })

      if (!response.ok) return null

      const { accessToken, newRefreshToken } = await response.json()
      await SecureStore.setItemAsync('auth-token', accessToken)
      await SecureStore.setItemAsync('refresh-token', newRefreshToken)
      return accessToken
    } catch {
      return null
    }
  }
}

export const api = new ApiClient()
```

## Input Validation

### Client-Side Validation (UX Only)

```typescript
// features/auth/validation.ts
import { z } from 'zod'

export const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
})

export const registerSchema = z.object({
  name: z.string().min(1, 'Name is required').max(100),
  email: z.string().email('Invalid email address'),
  password: z
    .string()
    .min(8, 'Password must be at least 8 characters')
    .regex(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/,
      'Password must contain uppercase, lowercase, and number'
    ),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: 'Passwords do not match',
  path: ['confirmPassword'],
})

export type LoginInput = z.infer<typeof loginSchema>
export type RegisterInput = z.infer<typeof registerSchema>
```

### Form Validation

```tsx
// features/auth/LoginForm.tsx
import { useState } from 'react'
import { View, TextInput, Button, Text, Alert } from 'react-native'
import { loginSchema, LoginInput } from './validation'

interface LoginFormProps {
  onSubmit: (data: LoginInput) => Promise<void>
}

export function LoginForm({ onSubmit }: LoginFormProps) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [loading, setLoading] = useState(false)

  const handleSubmit = async () => {
    const result = loginSchema.safeParse({ email, password })

    if (!result.success) {
      const fieldErrors: Record<string, string> = {}
      result.error.errors.forEach((err) => {
        if (err.path[0]) {
          fieldErrors[err.path[0] as string] = err.message
        }
      })
      setErrors(fieldErrors)
      return
    }

    setErrors({})
    setLoading(true)

    try {
      await onSubmit(result.data)
    } catch (error) {
      Alert.alert('Error', 'Login failed. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <View>
      <TextInput
        placeholder="Email"
        value={email}
        onChangeText={setEmail}
        autoCapitalize="none"
        keyboardType="email-address"
        autoComplete="email"
      />
      {errors.email && <Text>{errors.email}</Text>}

      <TextInput
        placeholder="Password"
        value={password}
        onChangeText={setPassword}
        secureTextEntry
        autoComplete="password"
      />
      {errors.password && <Text>{errors.password}</Text>}

      <Button
        title={loading ? 'Logging in...' : 'Log in'}
        onPress={handleSubmit}
        disabled={loading}
      />
    </View>
  )
}
```

## Deep Link Security

### Validate Deep Links

```typescript
// lib/deep-links.ts
import * as Linking from 'expo-linking'

const ALLOWED_HOSTS = ['myapp.com', 'www.myapp.com']

export function validateDeepLink(url: string): boolean {
  try {
    const parsed = Linking.parse(url)

    // Validate host
    if (!parsed.hostname || !ALLOWED_HOSTS.includes(parsed.hostname)) {
      return false
    }

    // Validate scheme
    if (parsed.scheme !== 'myapp' && parsed.scheme !== 'https') {
      return false
    }

    return true
  } catch {
    return false
  }
}

// Handle deep links
Linking.addEventListener('url', ({ url }) => {
  if (!validateDeepLink(url)) {
    console.warn('Invalid deep link:', url)
    return
  }

  // Process valid deep link
  handleDeepLink(url)
})
```

## Network Security

### Certificate Pinning

```typescript
// lib/network-security.ts
import * as FileSystem from 'expo-file-system'

// For critical API calls, implement certificate pinning
// Note: This requires native module support

export async function secureFetch(
  url: string,
  options: RequestInit = {}
): Promise<Response> {
  // Validate URL before fetching
  if (!isAllowedUrl(url)) {
    throw new Error('URL not allowed')
  }

  return fetch(url, {
    ...options,
    headers: {
      ...options.headers,
      'X-Request-ID': generateRequestId(),
    },
  })
}

function isAllowedUrl(url: string): boolean {
  try {
    const parsed = new URL(url)
    return (
      parsed.protocol === 'https:' &&
      ALLOWED_HOSTS.includes(parsed.hostname)
    )
  } catch {
    return false
  }
}

function generateRequestId(): string {
  return `${Date.now()}-${Math.random().toString(36).substr(2, 9)}`
}
```

## Screenshot Prevention

### Prevent Screenshots on Sensitive Screens

```tsx
import { WindowManager } from 'expo'

// Disable screenshots for sensitive screens
export function useScreenshotProtection(enabled: boolean) {
  useEffect(() => {
    WindowManager.setSecureScreenEntry(enabled)

    return () => {
      WindowManager.setSecureScreenEntry(false)
    }
  }, [enabled])
}

// Usage
function SensitiveScreen() {
  useScreenshotProtection(true)

  return (
    <View>
      <Text>Sensitive content</Text>
    </View>
  )
}
```

## Biometric Authentication

### Expo Local Authentication

```typescript
// lib/biometrics.ts
import * as LocalAuthentication from 'expo-local-authentication'

export async function isBiometricAvailable(): Promise<boolean> {
  const compatible = await LocalAuthentication.hasHardwareAsync()
  const enrolled = await LocalAuthentication.isEnrolledAsync()
  return compatible && enrolled
}

export async function authenticateWithBiometrics(): Promise<boolean> {
  const result = await LocalAuthentication.authenticateAsync({
    promptMessage: 'Authenticate to continue',
    cancelLabel: 'Cancel',
    disableDeviceFallback: false,
  })

  return result.success
}

// Usage in auth flow
async function loginWithBiometrics() {
  const biometricsAvailable = await isBiometricAvailable()

  if (biometricsAvailable) {
    const authenticated = await authenticateWithBiometrics()
    if (authenticated) {
      // Get stored credentials and login
      const credentials = await getStoredCredentials()
      if (credentials) {
        await login(credentials.email, credentials.password)
      }
    }
  }
}
```

## Checklist

- [ ] Sensitive data stored in SecureStore (not AsyncStorage)
- [ ] Auth tokens stored securely
- [ ] API client handles token refresh
- [ ] Input validation on client (UX) and server (security)
- [ ] Deep links validated
- [ ] Network requests use HTTPS
- [ ] Certificate pinning for critical APIs
- [ ] Screenshots prevented on sensitive screens
- [ ] Biometric authentication implemented
- [ ] No sensitive data in logs
- [ ] Dependencies audited
