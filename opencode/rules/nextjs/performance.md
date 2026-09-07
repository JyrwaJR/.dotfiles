---
paths:
  - "**/*.tsx"
  - "**/*.ts"
  - "next.config.*"
---
# Next.js Performance

> This file extends [web/performance.md](../web/performance.md) with Next.js-specific performance content.

## Core Web Vitals Targets

| Metric | Target |
|--------|--------|
| LCP | < 2.5s |
| INP | < 200ms |
| CLS | < 0.1 |
| FCP | < 1.5s |
| TTFB | < 800ms |

## Bundle Optimization

### Dynamic Imports

```tsx
// Heavy components - load only when needed
import dynamic from 'next/dynamic'

const HeavyChart = dynamic(() => import('@/components/HeavyChart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // Skip server-side rendering for client-only components
})

const MarkdownEditor = dynamic(() => import('@/components/MarkdownEditor'), {
  loading: () => <EditorSkeleton />,
})
```

### Tree Shaking

```tsx
// WRONG: Imports entire library
import _ from 'lodash'
const result = _.debounce(fn, 300)

// CORRECT: Import only what you need
import debounce from 'lodash/debounce'
const result = debounce(fn, 300)
```

### Package Analysis

```bash
# Analyze bundle size
npx @next/bundle-analyzer

# Check specific imports
npx cost-of-modules
```

## Image Optimization

### Next.js Image Component

```tsx
import Image from 'next/image'

// Static images
<Image
  src="/images/hero.png"
  alt="Hero image"
  width={1200}
  height={600}
  priority  // Above-the-fold images
  placeholder="blur"
  blurDataURL="data:image/jpeg;base64,..."
/>

// Remote images with lazy loading
<Image
  src="https://example.com/image.jpg"
  alt="Remote image"
  width={400}
  height={300}
  loading="lazy"  // Below-the-fold images
/>

// Responsive images
<Image
  src="/images/hero.png"
  alt="Hero image"
  fill
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>
```

### Image Formats

```js
// next.config.js
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920, 2048],
    imageSizes: [16, 32, 48, 64, 96, 128, 256, 384],
  },
}
```

## Font Optimization

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google'

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',  // Prevents FOIT
  preload: true,
  fallback: ['system-ui', 'arial'],
})

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

## Caching Strategies

### Static Generation (SSG)

```tsx
// app/blog/[slug]/page.tsx
export const revalidate = 3600 // Revalidate every hour

export async function generateStaticParams() {
  const posts = await getPosts()
  return posts.map(post => ({ slug: post.slug }))
}

export default async function BlogPost({ params }) {
  const post = await getPost(params.slug)
  return <Article post={post} />
}
```

### Incremental Static Regeneration (ISR)

```tsx
// app/products/[id]/page.tsx
export const revalidate = 60 // Revalidate every 60 seconds

export default async function ProductPage({ params }) {
  const product = await getProduct(params.id)
  return <ProductDetails product={product} />
}
```

### Server-Side Rendering (SSR)

```tsx
// app/dashboard/page.tsx
export const dynamic = 'force-dynamic' // Always render on server

export default async function DashboardPage() {
  const data = await getFreshData() // Always fresh
  return <Dashboard data={data} />
}
```

## Streaming and Suspense

### Progressive Rendering

```tsx
// app/dashboard/page.tsx
import { Suspense } from 'react'

export default function DashboardPage() {
  return (
    <div>
      <h1>Dashboard</h1>

      {/* Immediate: Shell renders */}
      <div className="grid grid-cols-2 gap-4">
        {/* Each Suspense boundary streams independently */}
        <Suspense fallback={<StatsSkeleton />}>
          <StatsPanel />
        </Suspense>

        <Suspense fallback={<ActivitySkeleton />}>
          <ActivityFeed />
        </Suspense>
      </div>
    </div>
  )
}
```

### Loading States

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

## Route prefetching

### Link Prefetching

```tsx
import Link from 'next/link'

// Prefetch on hover (default)
<Link href="/dashboard">Dashboard</Link>

// Disable prefetch for rarely-visited pages
<Link href="/settings" prefetch={false}>Settings</Link>

// Prefetch specific routes programmatically
import { useRouter } from 'next/navigation'

const router = useRouter()

// Prefetch on hover
<Link
  href="/dashboard"
  onMouseEnter={() => router.prefetch('/dashboard')}
>
  Dashboard
</Link>
```

## Client-Side Performance

### useMemo and useCallback

```tsx
'use client'

import { useMemo, useCallback } from 'react'

export function ProductList({ products }: { products: Product[] }) {
  // Memoize expensive computations
  const sortedProducts = useMemo(() => {
    return [...products].sort((a, b) => a.price - b.price)
  }, [products])

  // Memoize callbacks passed to child components
  const handleSelect = useCallback((id: string) => {
    console.log('Selected:', id)
  }, [])

  return (
    <ul>
      {sortedProducts.map(product => (
        <li key={product.id}>
          <ProductCard product={product} onSelect={handleSelect} />
        </li>
      ))}
    </ul>
  )
}
```

### Virtualization for Long Lists

```tsx
'use client'

import { useVirtualizer } from '@tanstack/react-virtual'
import { useRef } from 'react'

export function VirtualProductList({ products }: { products: Product[] }) {
  const parentRef = useRef<HTMLDivElement>(null)

  const virtualizer = useVirtualizer({
    count: products.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 80,
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
        {virtualizer.getVirtualItems().map(virtualRow => (
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
            <ProductCard product={products[virtualRow.index]} />
          </div>
        ))}
      </div>
    </div>
  )
}
```

## Performance Checklist

- [ ] Images use Next.js Image component
- [ ] Above-the-fold images use `priority`
- [ ] Heavy components use dynamic imports
- [ ] Fonts use `display: 'swap'`
- [ ] Static pages use ISR or SSG
- [ ] Streaming with Suspense boundaries
- [ ] No unnecessary client-side JavaScript
- [ ] Bundle size analyzed and optimized
- [ ] API routes have proper caching headers
- [ ] Lighthouse score > 90
