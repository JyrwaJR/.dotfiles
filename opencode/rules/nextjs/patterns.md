---
paths:
  - "**/*.tsx"
  - "**/*.ts"
  - "next.config.*"
  - "app/**"
  - "pages/**"
---
# Next.js Patterns

> This file extends [react/patterns.md](../react/patterns.md) with Next.js-specific patterns.

## Server Actions

### Form Actions

```tsx
// app/actions.ts
'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { prisma } from '@/lib/prisma'
import { createUserSchema } from '@/lib/validations'

export async function createUser(formData: FormData) {
  const rawData = {
    name: formData.get('name'),
    email: formData.get('email'),
  }

  const result = createUserSchema.safeParse(rawData)

  if (!result.success) {
    return {
      error: 'Validation failed',
      details: result.error.flatten(),
    }
  }

  try {
    await prisma.user.create({
      data: result.data,
    })
  } catch (error) {
    return {
      error: 'Failed to create user',
    }
  }

  revalidatePath('/users')
  redirect('/users')
}
```

### Using Server Actions in Forms

```tsx
// app/users/new/page.tsx
import { createUser } from '../actions'

export default function NewUserPage() {
  return (
    <form action={createUser}>
      <div>
        <label htmlFor="name">Name</label>
        <input
          id="name"
          name="name"
          type="text"
          required
        />
      </div>
      <div>
        <label htmlFor="email">Email</label>
        <input
          id="email"
          name="email"
          type="email"
          required
        />
      </div>
      <button type="submit">Create User</button>
    </form>
  )
}
```

### Server Actions with useActionState

```tsx
'use client'

import { useActionState } from 'react'
import { createUser } from '../actions'

export function CreateUserForm() {
  const [state, formAction, isPending] = useActionState(createUser, null)

  return (
    <form action={formAction}>
      {state?.error && (
        <div className="text-red-500">{state.error}</div>
      )}
      <input name="name" required />
      <input name="email" type="email" required />
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create User'}
      </button>
    </form>
  )
}
```

## Parallel Routes

### Route Groups with Parallel Routes

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
  analytics,
  notifications,
}: {
  children: React.ReactNode
  analytics: React.ReactNode
  notifications: React.ReactNode
}) {
  return (
    <div className="flex">
      <div className="flex-1">{children}</div>
      <aside className="w-64">
        {analytics}
        {notifications}
      </aside>
    </div>
  )
}

// app/dashboard/@analytics/page.tsx
export default function AnalyticsPanel() {
  return <div>Analytics content</div>
}

// app/dashboard/@notifications/page.tsx
export default function NotificationsPanel() {
  return <div>Notifications content</div>
}
```

## Intercepting Routes

### Modal Interception

```tsx
// app/@modal/(.)photo/[id]/page.tsx
'use client'

import { useRouter } from 'next/navigation'
import { PhotoModal } from '@/components/features/photos/PhotoModal'

export default function InterceptedPhotoPage({
  params,
}: {
  params: { id: string }
}) {
  const router = useRouter()

  return (
    <PhotoModal
      photoId={params.id}
      onClose={() => router.back()}
    />
  )
}
```

## Streaming and Suspense

### Progressive Rendering

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'
import { RecentSales } from '@/components/features/dashboard/RecentSales'
import { Overview } from '@/components/features/dashboard/Overview'

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Immediate: Shell renders */}
      <div className="grid grid-cols-2 gap-4">
        {/* Streaming: Each Suspense boundary streams independently */}
        <Suspense fallback={<CardSkeleton />}>
          <Overview />
        </Suspense>

        <Suspense fallback={<CardSkeleton />}>
          <RecentSales />
        </Suspense>
      </div>
    </div>
  )
}
```

### Streaming with Loading UI

```tsx
// app/dashboard/overview/loading.tsx
export default function OverviewLoading() {
  return (
    <Card>
      <CardHeader>
        <Skeleton className="h-4 w-[250px]" />
      </CardHeader>
      <CardContent>
        <Skeleton className="h-[200px] w-full" />
      </CardContent>
    </Card>
  )
}
```

## Caching Patterns

### Static Generation

```tsx
// app/blog/[slug]/page.tsx
import { prisma } from '@/lib/prisma'

// Generate static paths at build time
export async function generateStaticParams() {
  const posts = await prisma.post.findMany({
    select: { slug: true },
  })

  return posts.map(post => ({
    slug: post.slug,
  }))
}

// Revalidate every 60 seconds
export const revalidate = 60

export default async function BlogPost({
  params,
}: {
  params: { slug: string }
}) {
  const post = await prisma.post.findUnique({
    where: { slug: params.slug },
  })

  if (!post) {
    return notFound()
  }

  return (
    <article>
      <h1>{post.title}</h1>
      <p>{post.content}</p>
    </article>
  )
}
```

### Cache Tags

```tsx
// lib/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log: process.env.NODE_ENV === 'development' ? ['query'] : [],
  })

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma

// app/api/users/route.ts
import { prisma } from '@/lib/prisma'
import { NextResponse } from 'next/server'

export async function GET() {
  const users = await prisma.user.findMany()

  return NextResponse.json(users, {
    headers: {
      'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300',
    },
  })
}
```

## Image Optimization

```tsx
import Image from 'next/image'

// Static images
<Image
  src="/images/hero.png"
  alt="Hero image"
  width={1200}
  height={600}
  priority  // For above-the-fold images
/>

// Remote images
<Image
  src="https://example.com/image.jpg"
  alt="Remote image"
  width={400}
  height={300}
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
/>

// Responsive images
<Image
  src="/images/hero.png"
  alt="Hero image"
  fill
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>
```

## Font Optimization

```tsx
// app/layout.tsx
import { Inter, Playfair_Display } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
})

const playfair = Playfair_Display({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-playfair',
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={`${inter.variable} ${playfair.variable}`}>
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

## Metadata API

### Static Metadata

```tsx
// app/page.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: 'My App',
  description: 'Built with Next.js',
  openGraph: {
    title: 'My App',
    description: 'Built with Next.js',
    images: ['https://example.com/og.png'],
  },
}
```

### Dynamic Metadata

```tsx
// app/blog/[slug]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata({
  params,
}: {
  params: { slug: string }
}): Promise<Metadata> {
  const post = await getPost(params.slug)

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [post.coverImage],
    },
  }
}
```

## Route Handlers

### Webhooks

```tsx
// app/api/webhooks/stripe/route.ts
import { NextResponse } from 'next/server'
import { headers } from 'next/headers'
import Stripe from 'stripe'

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!)

export async function POST(request: Request) {
  const body = await request.text()
  const signature = (await headers()).get('stripe-signature')!

  let event: Stripe.Event

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      process.env.STRIPE_WEBHOOK_SECRET!
    )
  } catch (err) {
    console.error('Webhook signature verification failed:', err)
    return NextResponse.json(
      { error: 'Invalid signature' },
      { status: 400 }
    )
  }

  switch (event.type) {
    case 'checkout.session.completed':
      await handleCheckoutComplete(event.data.object)
      break
    case 'invoice.paid':
      await handleInvoicePaid(event.data.object)
      break
    default:
      console.log(`Unhandled event type: ${event.type}`)
  }

  return NextResponse.json({ received: true })
}
```

### Streaming Responses

```tsx
// app/api/chat/route.ts
export async function POST(request: Request) {
  const { message } = await request.json()

  const encoder = new TextEncoder()
  const stream = new ReadableStream({
    async start(controller) {
      // Stream AI response chunk by chunk
      for await (const chunk of streamAIResponse(message)) {
        controller.enqueue(encoder.encode(chunk))
      }
      controller.close()
    },
  })

  return new Response(stream, {
    headers: {
      'Content-Type': 'text/plain; charset=utf-8',
      'Transfer-Encoding': 'chunked',
    },
  })
}
```
