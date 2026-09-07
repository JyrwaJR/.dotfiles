---
paths:
  - "**/*.tsx"
  - "**/*.ts"
  - "next.config.*"
  - "app/**"
  - "pages/**"
---
# Next.js Coding Style

> This file extends [react/coding-style.md](../react/coding-style.md) with Next.js-specific content.

## App Router Structure (Next.js 13+)

### Directory Layout

```text
src/
├── app/
│   ├── (auth)/                    # Route group (no URL segment)
│   │   ├── login/
│   │   │   ├── page.tsx           # /login
│   │   │   └── layout.tsx
│   │   └── signup/
│   │       ├── page.tsx           # /signup
│   │       └── layout.tsx
│   ├── (dashboard)/               # Route group
│   │   ├── layout.tsx             # Shared dashboard layout
│   │   ├── page.tsx               # /dashboard
│   │   └── settings/
│   │       └── page.tsx           # /dashboard/settings
│   ├── api/                       # API routes
│   │   └── users/
│   │       └── route.ts           # /api/users
│   ├── layout.tsx                 # Root layout
│   ├── page.tsx                   # /
│   ├── loading.tsx                # Loading UI
│   ├── error.tsx                  # Error boundary
│   └── not-found.tsx              # 404 page
├── components/
│   ├── ui/                        # Shared UI components
│   └── features/                  # Feature-specific components
├── lib/
│   ├── prisma.ts                  # Prisma client
│   ├── auth.ts                    # Auth utilities
│   └── utils.ts                   # General utilities
├── hooks/
├── types/
└── middleware.ts                   # Route middleware
```

### Page Components

#### Server Components (Default)

```tsx
// app/dashboard/page.tsx
// Server component by default - no 'use client'
import { prisma } from '@/lib/prisma'
import { DashboardContent } from '@/components/features/dashboard/DashboardContent'

export default async function DashboardPage() {
  // Direct database access - no API layer needed
  const users = await prisma.user.findMany({
    select: {
      id: true,
      name: true,
      email: true,
    },
  })

  return <DashboardContent users={users} />
}
```

#### Client Components

```tsx
// components/features/dashboard/DashboardContent.tsx
'use client'

import { useState } from 'react'
import { UserCard } from '@/components/ui/UserCard'

interface User {
  id: string
  name: string
  email: string
}

interface DashboardContentProps {
  users: User[]
}

export function DashboardContent({ users }: DashboardContentProps) {
  const [selectedUser, setSelectedUser] = useState<User | null>(null)

  return (
    <div>
      <h1>Dashboard</h1>
      <ul>
        {users.map(user => (
          <li key={user.id}>
            <UserCard
              user={user}
              onSelect={() => setSelectedUser(user)}
            />
          </li>
        ))}
      </ul>
      {selectedUser && (
        <div>Selected: {selectedUser.name}</div>
      )}
    </div>
  )
}
```

### Layout Patterns

#### Root Layout

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'
import { Providers } from './providers'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata = {
  title: 'My App',
  description: 'Built with Next.js',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Providers>{children}</Providers>
      </body>
    </html>
  )
}
```

#### Nested Layout

```tsx
// app/(dashboard)/layout.tsx
import { Sidebar } from '@/components/features/dashboard/Sidebar'
import { Header } from '@/components/features/dashboard/Header'

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex h-screen">
      <Sidebar />
      <div className="flex-1 flex flex-col">
        <Header />
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  )
}
```

## API Routes

### Route Handlers

```tsx
// app/api/users/route.ts
import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'
import { getUserSchema } from '@/lib/validations'

export async function GET(request: Request) {
  try {
    const { searchParams } = new URL(request.url)
    const result = getUserSchema.safeParse({
      page: searchParams.get('page'),
      limit: searchParams.get('limit'),
    })

    if (!result.success) {
      return NextResponse.json(
        { error: 'Invalid parameters' },
        { status: 400 }
      )
    }

    const { page, limit } = result.data
    const skip = (page - 1) * limit

    const [users, total] = await Promise.all([
      prisma.user.findMany({
        skip,
        take: limit,
        select: {
          id: true,
          name: true,
          email: true,
        },
      }),
      prisma.user.count(),
    ])

    return NextResponse.json({
      data: users,
      meta: {
        total,
        page,
        limit,
        totalPages: Math.ceil(total / limit),
      },
    })
  } catch (error) {
    console.error('Failed to fetch users:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function POST(request: Request) {
  try {
    const body = await request.json()
    const result = createUserSchema.safeParse(body)

    if (!result.success) {
      return NextResponse.json(
        { error: 'Validation failed', details: result.error.flatten() },
        { status: 400 }
      )
    }

    const user = await prisma.user.create({
      data: result.data,
    })

    return NextResponse.json(user, { status: 201 })
  } catch (error) {
    console.error('Failed to create user:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

### Route Handlers with Params

```tsx
// app/api/users/[id]/route.ts
import { NextResponse } from 'next/server'
import { prisma } from '@/lib/prisma'

interface RouteContext {
  params: {
    id: string
  }
}

export async function GET(request: Request, { params }: RouteContext) {
  try {
    const user = await prisma.user.findUnique({
      where: { id: params.id },
      select: {
        id: true,
        name: true,
        email: true,
        posts: {
          select: {
            id: true,
            title: true,
          },
        },
      },
    })

    if (!user) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      )
    }

    return NextResponse.json(user)
  } catch (error) {
    console.error('Failed to fetch user:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function PUT(request: Request, { params }: RouteContext) {
  try {
    const body = await request.json()
    const result = updateUserSchema.safeParse(body)

    if (!result.success) {
      return NextResponse.json(
        { error: 'Validation failed', details: result.error.flatten() },
        { status: 400 }
      )
    }

    const user = await prisma.user.update({
      where: { id: params.id },
      data: result.data,
    })

    return NextResponse.json(user)
  } catch (error) {
    console.error('Failed to update user:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function DELETE(request: Request, { params }: RouteContext) {
  try {
    await prisma.user.delete({
      where: { id: params.id },
    })

    return new NextResponse(null, { status: 204 })
  } catch (error) {
    console.error('Failed to delete user:', error)
    return NextResponse.json(
      { error: 'Internal server error' },
      { status: 500 }
    )
  }
}
```

## Data Fetching

### Server-Side Data Fetching

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { prisma } from '@/lib/prisma'
import { StatsCards } from '@/components/features/dashboard/StatsCards'
import { RecentActivity } from '@/components/features/dashboard/RecentActivity'

// Parallel data fetching
async function getStats() {
  const [userCount, postCount, commentCount] = await Promise.all([
    prisma.user.count(),
    prisma.post.count(),
    prisma.comment.count(),
  ])

  return { userCount, postCount, commentCount }
}

async function getRecentActivity() {
  return prisma.activity.findMany({
    take: 10,
    orderBy: { createdAt: 'desc' },
    include: { user: { select: { name: true } } },
  })
}

export default async function DashboardPage() {
  // Parallel fetching
  const [stats, activity] = await Promise.all([
    getStats(),
    getRecentActivity(),
  ])

  return (
    <div>
      <h1>Dashboard</h1>
      <Suspense fallback={<StatsCardsSkeleton />}>
        <StatsCards stats={stats} />
      </Suspense>
      <Suspense fallback={<ActivitySkeleton />}>
        <RecentActivity activity={activity} />
      </Suspense>
    </div>
  )
}
```

### Client-Side Data Fetching

```tsx
'use client'

import useSWR from 'swr'

const fetcher = (url: string) => fetch(url).then(res => res.json())

export function UserList() {
  const { data, error, isLoading } = useSWR('/api/users', fetcher)

  if (isLoading) return <div>Loading...</div>
  if (error) return <div>Error loading users</div>

  return (
    <ul>
      {data.users.map((user: User) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
}
```

## Middleware

```tsx
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Check authentication
  const token = request.cookies.get('session')?.value

  if (!token && request.nextUrl.pathname.startsWith('/dashboard')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Check authorization
  if (request.nextUrl.pathname.startsWith('/admin')) {
    const userRole = request.headers.get('x-user-role')
    if (userRole !== 'admin') {
      return NextResponse.redirect(new URL('/unauthorized', request.url))
    }
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/admin/:path*'],
}
```

## File Conventions

### loading.tsx

```tsx
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/4 mb-4" />
      <div className="grid grid-cols-3 gap-4">
        {[...Array(6)].map((_, i) => (
          <div key={i} className="h-32 bg-gray-200 rounded" />
        ))}
      </div>
    </div>
  )
}
```

### error.tsx

```tsx
// app/dashboard/error.tsx
'use client'

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <div className="text-center py-10">
      <h2 className="text-2xl font-bold mb-4">Something went wrong</h2>
      <p className="text-gray-600 mb-4">{error.message}</p>
      <button
        onClick={reset}
        className="px-4 py-2 bg-blue-500 text-white rounded"
      >
        Try again
      </button>
    </div>
  )
}
```

### not-found.tsx

```tsx
// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="text-center py-10">
      <h2 className="text-2xl font-bold mb-4">Page Not Found</h2>
      <p className="text-gray-600 mb-4">
        The page you are looking for does not exist.
      </p>
      <Link href="/" className="text-blue-500 hover:underline">
        Go home
      </Link>
    </div>
  )
}
```
