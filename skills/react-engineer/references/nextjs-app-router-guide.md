# Next.js 15-16 App Router -- Comprehensive Reference Guide

> Last updated: 2026-05-28
> Covers Next.js 15.0 through 16.2 (latest stable)

---

## Table of Contents

1. [Version History at a Glance](#version-history-at-a-glance)
2. [Project Structure](#project-structure)
3. [Layout System](#1-layout-system)
4. [Loading and Error States](#2-loading-and-error-states)
5. [Parallel Routes](#3-parallel-routes)
6. [Intercepting Routes](#4-intercepting-routes)
7. [Route Groups](#5-route-groups)
8. [Server Components by Default](#6-server-components-by-default)
9. [Server Actions](#7-server-actions)
10. [Data Fetching](#8-data-fetching)
11. [Middleware and Proxy](#9-middleware-and-proxy)
12. [Streaming and Suspense](#10-streaming-and-suspense)
13. [Cache Components (`use cache`)](#11-cache-components-use-cache)
14. [Navigation Hooks](#12-navigation-hooks)
15. [Image Optimization](#13-image-optimization)
16. [Metadata API](#14-metadata-api)
17. [Migration Notes](#migration-notes)

---

## Version History at a Glance

| Version | Date | Highlights |
|---------|------|------------|
| **15.0** | Oct 2024 | App Router stable, React 19, async request APIs (breaking), caching semantics changes (breaking), `next/form`, `instrumentation.js` stable, Turbopack dev stable |
| **15.5** | 2025 | Node.js middleware runtime stable, TypeScript typed routes, route export validation |
| **16.0** | Oct 2025 | Cache Components with `use cache`, Turbopack default bundler (stable), React Compiler (stable), `proxy.ts` replaces `middleware.ts`, React 19.2, async params (breaking), image defaults changes (breaking) |
| **16.1** | Dec 2025 | Turbopack FS caching stable for `next dev`, Bundle Analyzer (experimental), `next dev --inspect`, `next upgrade` command |
| **16.2** | Mar 2026 | ~400% faster `next dev` startup, ~50% faster rendering, redesigned 500 page, `unstable_catchError()`, `unstable_retry()`, Adapters API stable, `transitionTypes` on `Link` |

### Minimum Requirements (Next.js 16)

- Node.js 20.9+ (18 no longer supported)
- TypeScript 5.1+
- Chrome 111+, Edge 111+, Firefox 111+, Safari 16.4+

---

## Project Structure

```
app/
  layout.tsx            # Root layout (required)
  page.tsx              # Home page (/)
  loading.tsx           # Loading UI for /
  error.tsx             # Error boundary for /
  not-found.tsx         # 404 UI for /
  global-error.tsx      # Global error boundary
  template.tsx          # Re-rendered layout wrapper
  default.tsx           # Fallback for parallel routes
  proxy.ts              # Request interception (was middleware.ts)
  instrumentation.ts    # Server lifecycle hooks

  (marketing)/          # Route group -- no URL impact
    layout.tsx
    about/
      page.tsx          # /about
    contact/
      page.tsx          # /contact

  (dashboard)/
    layout.tsx
    dashboard/
      page.tsx          # /dashboard

  blog/
    [slug]/
      page.tsx          # /blog/:slug (dynamic)
    [...slug]/
      page.tsx          # /blog/a/b/c (catch-all)

  @modal/               # Parallel route slot
    (.)login/
      page.tsx          # Intercept /login at same level
    default.tsx
    page.tsx

  api/
    health/
      route.ts          # /api/health (Route Handler)

  sitemap.ts            # /sitemap.xml
  robots.ts             # /robots.txt
  opengraph-image.tsx   # OG image for /
  icon.png              # Favicon
```

---

## 1. Layout System

Layouts wrap pages and persist across navigations. They do not re-render when you move between child routes.

### Root Layout (Required)

Every App Router project must have a root `app/layout.tsx`. It must render `<html>` and `<body>`.

```tsx
// app/layout.tsx
import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: { default: 'My App', template: '%s | My App' },
  description: 'A Next.js application',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
```

### Nested Layouts

Layouts nest automatically. Each folder can have its own `layout.tsx`.

```tsx
// app/dashboard/layout.tsx
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="flex">
      <nav className="w-64">Sidebar</nav>
      <main className="flex-1">{children}</main>
    </div>
  )
}
```

The layout hierarchy for `/dashboard/settings` is:
```
RootLayout > DashboardLayout > settings/page.tsx
```

### Template vs Layout

`template.tsx` has the same wrapping behavior as `layout.tsx`, but **re-creates on every navigation** instead of persisting. Use templates when you need fresh state per visit (e.g., analytics tracking, entrance animations).

```tsx
// app/template.tsx
'use client'

import { useEffect } from 'react'

export default function Template({ children }: { children: React.ReactNode }) {
  useEffect(() => {
    // Runs on every navigation -- unlike layout which persists
    console.log('Page view tracked')
  }, [])

  return <div className="animate-fadeIn">{children}</div>
}
```

| Feature | `layout.tsx` | `template.tsx` |
|---------|-------------|----------------|
| Persists across navigations | Yes | No (re-mounts) |
| State preserved | Yes | No |
| Shares instance across siblings | Yes | No |
| Use case | Shared nav, providers | Page transitions, analytics |

---

## 2. Loading and Error States

### `loading.tsx` -- Streaming Loading UI

Creates an instant loading state backed by Suspense. The rest of the page streams in.

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="animate-pulse">
      <div className="h-8 bg-gray-200 rounded w-1/3 mb-4" />
      <div className="h-64 bg-gray-200 rounded" />
    </div>
  )
}
```

### `error.tsx` -- Error Boundary

Must be a Client Component. Receives the error and a `reset` function (and `unstable_retry` in 16.2+).

```tsx
// app/error.tsx
'use client'

import type { ErrorInfo } from 'next/error'

export default function Error({
  error,
  reset,
  unstable_retry,
}: {
  error: Error & { digest?: string }
  reset: () => void
  unstable_retry?: () => void
}) {
  return (
    <div className="p-8">
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      {/* unstable_retry re-fetches from server; reset only re-renders */}
      <button onClick={() => unstable_retry?.() ?? reset()}>
        Try again
      </button>
    </div>
  )
}
```

> **Next.js 16.2**: `unstable_retry()` calls `router.refresh()` + `reset()` within a `startTransition()`, re-fetching data and re-rendering the segment. Prefer it over `reset()` for data-fetching errors.

### `global-error.tsx` -- Catch Root Layout Errors

`error.tsx` boundaries do not catch errors in the root layout. Use `global-error.tsx` for that. It must define its own `<html>` and `<body>` tags.

```tsx
// app/global-error.tsx
'use client'

export default function GlobalError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  return (
    <html>
      <body>
        <h2>Something went wrong!</h2>
        <button onClick={reset}>Try again</button>
      </body>
    </html>
  )
}
```

### `not-found.tsx` -- 404 Page

```tsx
// app/not-found.tsx
import Link from 'next/link'

export default function NotFound() {
  return (
    <div className="text-center py-20">
      <h1 className="text-4xl font-bold">404</h1>
      <p>Page not found</p>
      <Link href="/">Go home</Link>
    </div>
  )
}
```

### `unstable_catchError()` -- Component-Level Error Boundaries (16.2 experimental)

Place error boundaries anywhere in the component tree, not just at route segment boundaries.

```tsx
// app/custom-error-boundary.tsx
'use client'

import { unstable_catchError, type ErrorInfo } from 'next/error'

function CustomErrorBoundary(
  props: { title: string },
  { error, unstable_retry }: ErrorInfo,
) {
  return (
    <div>
      <h2>{props.title}</h2>
      <p>{error.message}</p>
      <button onClick={() => unstable_retry()}>Try again</button>
    </div>
  )
}

export default unstable_catchError(CustomErrorBoundary)
```

```tsx
// app/page.tsx
import CustomErrorBoundary from './custom-error-boundary'

export default function Page() {
  return (
    <CustomErrorBoundary title="Oops!">
      <RiskyComponent />
    </CustomErrorBoundary>
  )
}
```

---

## 3. Parallel Routes

Render multiple pages simultaneously in the same layout using named slots (`@folder`).

### Basic Setup

```
app/
  layout.tsx
  @team/
    page.tsx
    settings/
      page.tsx
    default.tsx
  @analytics/
    page.tsx
    visitors/
      page.tsx
    default.tsx
```

```tsx
// app/layout.tsx
export default function Layout({
  children,
  team,
  analytics,
}: {
  children: React.ReactNode
  team: React.ReactNode
  analytics: React.ReactNode
}) {
  return (
    <>
      {children}
      <div className="grid grid-cols-2">
        {team}
        {analytics}
      </div>
    </>
  )
}
```

### `default.tsx` for Unmatched Slots

During hard navigation (full page load), Next.js cannot determine the active state for slots that do not match the current URL. It renders `default.tsx` (or 404 if missing).

> **Next.js 16 breaking change**: All parallel route slots now require explicit `default.tsx` files. Builds fail without them.

```tsx
// app/@analytics/default.tsx
export default function Default() {
  return null // or call notFound()
}
```

### Conditional Routes

```tsx
// app/dashboard/layout.tsx
import { checkUserRole } from '@/lib/auth'

export default function Layout({
  user,
  admin,
}: {
  user: React.ReactNode
  admin: React.ReactNode
}) {
  const role = checkUserRole()
  return role === 'admin' ? admin : user
}
```

### Reading Active Slot

```tsx
// app/layout.tsx
'use client'

import { useSelectedLayoutSegment } from 'next/navigation'

export default function Layout({ auth }: { auth: React.ReactNode }) {
  const loginSegment = useSelectedLayoutSegment('auth')
  // Returns "login" when @auth/login is active
}
```

---

## 4. Intercepting Routes

Load a route within the current layout (e.g., a modal) while masking the browser URL. On hard navigation (refresh, shareable URL), the full page renders instead.

### Convention

| Convention | Matches |
|-----------|---------|
| `(.)folder` | Same level |
| `(..)folder` | One level up |
| `(..)(..)folder` | Two levels up |
| `(...)`folder` | From root `app/` |

> The `(..)` convention is based on **route segments**, not the file system. Slots like `@modal` do not count as segments.

### Modal Pattern with Parallel Routes

```
app/
  layout.tsx
  page.tsx                    # Feed page
  @modal/
    (.)photo/[id]/
      page.tsx                # Intercepted: shows modal
    default.tsx               # Hidden when modal inactive
    [...catchAll]/
      page.tsx                # Returns null for non-modal routes
  photo/[id]/
    page.tsx                  # Full photo page (hard nav)
```

```tsx
// app/layout.tsx
export default function Layout({
  children,
  modal,
}: {
  children: React.ReactNode
  modal: React.ReactNode
}) {
  return (
    <>
      {children}
      {modal}
    </>
  )
}
```

```tsx
// app/@modal/(.)photo/[id]/page.tsx
import { Modal } from '@/components/modal'

export default function InterceptedPhotoPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  // This runs when clicking a photo from the feed
  return <Modal>Photo modal content</Modal>
}
```

```tsx
// app/photo/[id]/page.tsx
export default function FullPhotoPage({
  params,
}: {
  params: Promise<{ id: string }>
}) {
  // This runs on direct URL or refresh
  return <div>Full photo page</div>
}
```

```tsx
// app/@modal/default.tsx
export default function Default() {
  return null // No modal when not active
}
```

### Closing the Modal

```tsx
// components/modal.tsx
'use client'

import { useRouter } from 'next/navigation'

export function Modal({ children }: { children: React.ReactNode }) {
  const router = useRouter()

  return (
    <div className="fixed inset-0 bg-black/50" onClick={() => router.back()}>
      <div className="..." onClick={(e) => e.stopPropagation()}>
        <button onClick={() => router.back()}>Close</button>
        {children}
      </div>
    </div>
  )
}
```

---

## 5. Route Groups

`(folder)` creates a group for organization without affecting the URL.

```
app/
  (marketing)/
    layout.tsx        # Marketing-specific layout
    about/page.tsx    # /about  (not /(marketing)/about)
    contact/page.tsx  # /contact
  (dashboard)/
    layout.tsx        # Dashboard-specific layout
    analytics/page.tsx # /analytics
    settings/page.tsx  # /settings
```

Use cases:
- Share a layout across routes without nesting in the URL
- Organize routes by team/feature
- Apply different layouts to different route groups

---

## 6. Server Components by Default

All components in the App Router are **Server Components** by default. They render on the server and send HTML to the client with zero JavaScript overhead.

### When to Use `'use client'`

Only add `'use client'` when you need:
- Event listeners (`onClick`, `onChange`)
- State and lifecycle hooks (`useState`, `useEffect`)
- Browser-only APIs (`localStorage`, `window`)
- Custom hooks that depend on state

```tsx
// app/components/counter.tsx
'use client'

import { useState } from 'react'

export function Counter() {
  const [count, setCount] = useState(0)
  return <button onClick={() => setCount(count + 1)}>Count: {count}</button>
}
```

### Composition Pattern

Keep pages as Server Components and push interactivity down.

```tsx
// app/page.tsx (Server Component)
import { fetchPosts } from '@/lib/data'
import { LikeButton } from '@/components/like-button'

export default async function Page() {
  const posts = await fetchPosts() // Runs on the server

  return (
    <ul>
      {posts.map((post) => (
        <li key={post.id}>
          <h2>{post.title}</h2>
          <LikeButton postId={post.id} /> {/* Client Component */}
        </li>
      ))}
    </ul>
  )
}
```

### Boundary Rules

- `'use client'` at the top of a file marks it (and everything it imports) as a Client Component boundary
- Server Components can import Client Components
- Client Components **cannot** import Server Components directly
- To nest Server Components inside Client Components, pass them as `children` props

```tsx
// Client Component that accepts Server Component children
'use client'

export function ClientWrapper({ children }: { children: React.ReactNode }) {
  const [isOpen, setIsOpen] = useState(false)
  return (
    <div>
      <button onClick={() => setIsOpen(!isOpen)}>Toggle</button>
      {isOpen && children}
    </div>
  )
}
```

---

## 7. Server Actions

Server Actions are server-side functions callable from the client using the `'use server'` directive.

### Form Actions (Progressive Enhancement)

Works even without JavaScript enabled.

```tsx
// app/actions.ts
'use server'

import { revalidateTag, updateTag } from 'next/cache'
import { redirect } from 'next/navigation'

export async function createPost(formData: FormData) {
  const title = formData.get('title') as string
  const content = formData.get('content') as string

  await db.post.create({ data: { title, content } })

  // Next.js 16: updateTag for read-your-writes semantics
  await updateTag('posts')
  redirect('/posts')
}
```

```tsx
// app/posts/new/page.tsx
import { createPost } from '@/app/actions'

export default function NewPostPage() {
  return (
    <form action={createPost}>
      <input name="title" type="text" required />
      <textarea name="content" required />
      <button type="submit">Create Post</button>
    </form>
  )
}
```

### Programmatic Invocation

```tsx
// app/components/delete-button.tsx
'use client'

import { useTransition } from 'react'

export function DeleteButton({ id }: { id: string }) {
  const [isPending, startTransition] = useTransition()

  async function handleDelete() {
    startTransition(async () => {
      await deletePost(id) // Server Action imported from actions.ts
    })
  }

  return (
    <button onClick={handleDelete} disabled={isPending}>
      {isPending ? 'Deleting...' : 'Delete'}
    </button>
  )
}
```

### Server Action with `updateTag` (Next.js 16)

```tsx
// app/actions.ts
'use server'

import { updateTag, refresh } from 'next/cache'

export async function updateProfile(formData: FormData) {
  await db.user.update({ where: { id: userId }, data: { name: formData.get('name') } })

  // updateTag: read-your-writes -- expires and immediately reads fresh data
  await updateTag('user-profile')

  // refresh: re-reads uncached data without touching cache
  await refresh()
}
```

### `revalidateTag` with cacheLife Profile (Next.js 16)

```tsx
// app/actions.ts
'use server'

import { revalidateTag } from 'next/cache'

export async function publishPost(id: string) {
  await db.post.update({ where: { id }, data: { published: true } })

  // Next.js 16: second argument is required cacheLife profile for SWR behavior
  revalidateTag('posts', 'max') // 'max' = long-lived with background revalidation
}
```

### Security Considerations

- Server Actions are publicly accessible HTTP endpoints -- always validate inputs
- Next.js 15+ creates unguessable, non-deterministic action IDs
- Unused Server Actions are eliminated from the client bundle
- Never trust `formData` values without validation (use Zod, Valibot, etc.)

```tsx
// app/actions.ts
'use server'

import { z } from 'zod'

const schema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
})

export async function login(formData: FormData) {
  const result = schema.safeParse({
    email: formData.get('email'),
    password: formData.get('password'),
  })

  if (!result.success) {
    return { error: 'Invalid credentials' }
  }

  // Proceed with authenticated logic
}
```

---

## 8. Data Fetching

Server Components can `fetch` directly. No `getServerSideProps` or `getStaticProps`.

### Basic Fetch (Uncached by Default Since 15.0)

```tsx
// app/posts/page.tsx
export default async function PostsPage() {
  // In Next.js 15+, fetch is NOT cached by default
  const res = await fetch('https://api.example.com/posts')
  const posts = await res.json()

  return (
    <ul>
      {posts.map((post: any) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

### Opt Into Caching

```tsx
// Cache for 1 hour
const res = await fetch('https://api.example.com/posts', {
  next: { revalidate: 3600 },
})

// Or force full static
const res = await fetch('https://api.example.com/posts', {
  next: { revalidate: false },
  cache: 'force-cache',
})
```

### Parallel Data Fetching

```tsx
// app/dashboard/page.tsx
export default async function DashboardPage() {
  // Fetches run in parallel -- no waterfall
  const [users, analytics, notifications] = await Promise.all([
    fetch('/api/users').then(r => r.json()),
    fetch('/api/analytics').then(r => r.json()),
    fetch('/api/notifications').then(r => r.json()),
  ])

  return <Dashboard users={users} analytics={analytics} notifications={notifications} />
}
```

### Sequential Data Fetching (When Dependencies Exist)

```tsx
// app/blog/[slug]/page.tsx
export default async function BlogPostPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params

  const post = await fetch(`/api/posts/${slug}`).then(r => r.json())
  // Second fetch depends on data from the first
  const comments = await fetch(`/api/posts/${post.id}/comments`).then(r => r.json())

  return <Article post={post} comments={comments} />
}
```

### `generateStaticParams` for Static Generation

```tsx
// app/blog/[slug]/page.tsx
export async function generateStaticParams() {
  const posts = await fetch('https://api.example.com/posts').then(r => r.json())

  return posts.map((post: any) => ({
    slug: post.slug,
  }))
}

// Opt into ISR
export const revalidate = 3600 // Revalidate every hour

export default async function BlogPostPage({
  params,
}: {
  params: Promise<{ slug: string }>
}) {
  const { slug } = await params
  const post = await fetch(`/api/posts/${slug}`).then(r => r.json())
  return <Article post={post} />
}
```

---

## 9. Middleware and Proxy

### `proxy.ts` (Next.js 16+, replaces `middleware.ts`)

Next.js 16 introduced `proxy.ts` as the replacement for `middleware.ts`. It runs on the **Node.js** runtime and clarifies the network boundary.

```ts
// app/proxy.ts (or proxy.ts at project root)
import { NextRequest, NextResponse } from 'next/server'

export function proxy(request: NextRequest) {
  // Auth guard
  const token = request.cookies.get('session-token')
  if (!token && !request.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Add custom headers
  const response = NextResponse.next()
  response.headers.set('x-request-id', crypto.randomUUID())
  return response
}

// Limit which routes run through the proxy
export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
}
```

### Legacy `middleware.ts` (Pre-16)

```ts
// middleware.ts (still works in 16, but deprecated)
import { NextRequest, NextResponse } from 'next/server'

export async function middleware(request: NextRequest) {
  const token = request.cookies.get('session-token')

  if (!token && !request.nextUrl.pathname.startsWith('/login')) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*', '/settings/:path*'],
}
```

### Key Differences

| Feature | `middleware.ts` (legacy) | `proxy.ts` (Next.js 16) |
|---------|------------------------|------------------------|
| Runtime | Edge | Node.js |
| Status | Deprecated | Recommended |
| Full Node API access | No | Yes |
| Cold start | Fast (Edge) | Standard (Node) |

---

## 10. Streaming and Suspense

The App Router streams HTML by default using React Suspense boundaries.

### Basic Streaming

```tsx
// app/page.tsx
import { Suspense } from 'react'

async function SlowComponent() {
  const data = await fetch('/api/slow').then(r => r.json())
  return <div>{data.message}</div>
}

async function FastComponent() {
  const data = await fetch('/api/fast').then(r => r.json())
  return <div>{data.message}</div>
}

export default function Page() {
  return (
    <div>
      <h1>Streaming Demo</h1>
      {/* FastComponent starts immediately */}
      <Suspense fallback={<div>Loading fast...</div>}>
        <FastComponent />
      </Suspense>
      {/* SlowComponent streams in when ready */}
      <Suspense fallback={<div>Loading slow data...</div>}>
        <SlowComponent />
      </Suspense>
    </div>
  )
}
```

### `loading.tsx` is a Suspense Boundary

Each `loading.tsx` file automatically wraps the corresponding page segment in a Suspense boundary.

```
app/
  layout.tsx
  loading.tsx         # Wraps page.tsx in Suspense
  page.tsx
  dashboard/
    loading.tsx       # Wraps dashboard/page.tsx
    page.tsx
```

### Streaming with `loading.tsx`

```tsx
// app/dashboard/loading.tsx
export default function DashboardLoading() {
  return (
    <div role="status" aria-label="Loading dashboard">
      <div className="grid grid-cols-3 gap-4">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="h-32 bg-gray-200 animate-pulse rounded-lg" />
        ))}
      </div>
    </div>
  )
}
```

---

## 11. Cache Components (`use cache`)

Cache Components (Next.js 16+) combine the `'use cache'` directive with Partial Pre-Rendering (PPR) for instant navigation with dynamic content.

### Enabling Cache Components

```ts
// next.config.ts
import type { NextConfig } from 'next'

const config: NextConfig = {
  cacheComponents: true,
}

export default config
```

### Caching an Entire Route

Add `'use cache'` to **both** the layout and page files. Each segment is cached independently.

```tsx
// app/blog/layout.tsx
'use cache'

export default function BlogLayout({ children }: { children: React.ReactNode }) {
  return (
    <div>
      <h1>Blog</h1>
      {children}
    </div>
  )
}
```

```tsx
// app/blog/page.tsx
'use cache'

import { cacheLife } from 'next/cache'

export default async function BlogPage() {
  const posts = await fetch('https://api.example.com/posts').then(r => r.json())

  return (
    <ul>
      {posts.map((post: any) => (
        <li key={post.id}>{post.title}</li>
      ))}
    </ul>
  )
}
```

### Caching a Component

```tsx
// app/components/product-card.tsx
'use cache'

import { cacheLife, cacheTag } from 'next/cache'

export async function ProductCard({ id }: { id: string }) {
  cacheTag(`product-${id}`)
  cacheLife('hours')

  const product = await fetch(`/api/products/${id}`).then(r => r.json())

  return (
    <div className="border rounded p-4">
      <h3>{product.name}</h3>
      <p>${product.price}</p>
    </div>
  )
}
```

### Caching a Function

```tsx
// app/lib/data.ts
'use cache'

import { cacheLife, cacheTag } from 'next/cache'

export async function getProducts(category: string) {
  cacheTag('products')
  cacheLife('hours')

  const res = await fetch(`https://api.example.com/products?category=${category}`)
  return res.json()
}
```

### `cacheLife` Profiles

```ts
// Built-in profiles
cacheLife('seconds')  // stale: 0s, revalidate: 5s, expire: 15s
cacheLife('minutes')  // stale: 5m, revalidate: 15m, expire: 1h
cacheLife('hours')    // stale: 5m, revalidate: 1h, expire: 1d
cacheLife('days')     // stale: 5m, revalidate: 1d, expire: 30d
cacheLife('weeks')    // stale: 5m, revalidate: 1w, expire: 30d
cacheLife('max')      // stale: 5m, revalidate: ∞, expire: ∞
cacheLife('default')  // stale: 5m, revalidate: 15m, expire: never
```

Custom profiles in `next.config.ts`:

```ts
const config: NextConfig = {
  cacheComponents: true,
  cacheLife: {
    myProfile: {
      stale: 60,        // 1 minute (client-side)
      revalidate: 900,  // 15 minutes (server-side)
      expire: 86400,    // 24 hours
    },
  },
}
```

### On-Demand Revalidation

```tsx
// app/actions.ts
'use server'

import { updateTag, revalidateTag } from 'next/cache'

export async function updateProduct(id: string, data: FormData) {
  await db.product.update({ where: { id }, data: { name: data.get('name') } })

  // Read-your-writes: user sees update immediately
  await updateTag(`product-${id}`)

  // SWR: cached data served immediately, background refresh
  revalidateTag('products', 'hours')
}
```

### Interleaving: Children Pass Through Cache

```tsx
// app/components/cached-wrapper.tsx
'use cache'

export async function CachedWrapper({ children }: { children: React.ReactNode }) {
  // `children` are passed through without affecting cache entry
  // They can be dynamic even though this wrapper is cached
  return (
    <div className="cached-shell">
      <h2>Cached Header</h2>
      {children}
    </div>
  )
}
```

### Constraints

- Cannot use `cookies()`, `headers()`, or `searchParams` inside cached scopes -- pass values as arguments instead
- Outer-scope variables are automatically captured as part of the cache key
- Arguments and return values must be serializable
- `React.cache` operates in isolated scope inside `use cache` boundaries

### Passing Runtime Values to Cached Functions

```tsx
// app/page.tsx
import { cookies } from 'next/headers'

// Read cookies OUTSIDE the cached scope
async function Page() {
  const token = (await cookies()).get('session-token')?.value

  return <CachedDashboard token={token} />
}

// app/components/cached-dashboard.tsx
'use cache'

export async function CachedDashboard({ token }: { token: string | undefined }) {
  // `token` is now part of the cache key
  const data = await fetch('/api/dashboard', {
    headers: { Authorization: `Bearer ${token}` },
  }).then(r => r.json())

  return <Dashboard data={data} />
}
```

---

## 12. Navigation Hooks

All navigation hooks require `'use client'`.

### `useRouter()`

```tsx
// app/components/navigation.tsx
'use client'

import { useRouter } from 'next/navigation'

export function Navigation() {
  const router = useRouter()

  return (
    <nav>
      <button onClick={() => router.push('/dashboard')}>Dashboard</button>
      <button onClick={() => router.replace('/login')}>Login</button>
      <button onClick={() => router.back()}>Back</button>
      <button onClick={() => router.refresh()}>Refresh</button>
      <button onClick={() => router.prefetch('/settings')}>Prefetch Settings</button>
    </nav>
  )
}
```

### `usePathname()`

```tsx
'use client'

import { usePathname } from 'next/navigation'

export function ActiveLink({ href, children }: { href: string; children: React.ReactNode }) {
  const pathname = usePathname()
  const isActive = pathname === href || pathname.startsWith(href + '/')

  return (
    <a
      href={href}
      className={isActive ? 'text-blue-600 font-bold' : 'text-gray-600'}
    >
      {children}
    </a>
  )
}
```

### `useSearchParams()`

```tsx
'use client'

import { useSearchParams } from 'next/navigation'

export function SearchFilters() {
  const searchParams = useSearchParams()
  const category = searchParams.get('category') ?? 'all'
  const page = searchParams.get('page') ?? '1'

  return (
    <div>
      <p>Category: {category}</p>
      <p>Page: {page}</p>
    </div>
  )
}
```

> **Important**: `useSearchParams()` causes the closest Suspense boundary to fall back to its loading state during static rendering. Wrap components that use it in Suspense for best streaming behavior.

### `useParams()`

```tsx
'use client'

import { useParams } from 'next/navigation'

export function PostBreadcrumb() {
  const params = useParams()
  // For /blog/[slug]/[id], params = { slug: '...', id: '...' }
  return <span>{params.slug as string}</span>
}
```

### `<Link>` Component (Next.js 16.2)

```tsx
import Link from 'next/link'

// Basic
<Link href="/about">About</Link>

// With View Transitions (16.2+)
<Link href="/about" transitionTypes={['slide']}>
  About
</Link>

// Dynamic route
<Link href={`/blog/${post.slug}`}>{post.title}</Link>

// With search params
<Link href={{ pathname: '/search', query: { q: 'next.js' } }}>
  Search
</Link>

// Scroll control
<Link href="/about" scroll={false}>About (no scroll)</Link>

// Prefetch control
<Link href="/about" prefetch={false}>About (no prefetch)</Link>
```

---

## 13. Image Optimization

### Basic Usage

```tsx
import Image from 'next/image'

export function Hero() {
  return (
    <Image
      src="/hero.jpg"
      alt="Hero image"
      width={1200}
      height={600}
      priority          // Preload above-the-fold images
      placeholder="blur" // Show blur placeholder while loading
    />
  )
}
```

### Remote Images

```ts
// next.config.ts
const config: NextConfig = {
  images: {
    remotePatterns: [
      {
        protocol: 'https',
        hostname: 'cdn.example.com',
        pathname: '/images/**',
      },
    ],
  },
}
```

```tsx
<Image
  src="https://cdn.example.com/images/photo.jpg"
  alt="Remote image"
  width={800}
  height={600}
  sizes="(max-width: 768px) 100vw, 50vw"
/>
```

### Next.js 16 Image Defaults Changes

| Setting | Before 16 | Next.js 16 |
|---------|-----------|------------|
| `minimumCacheTTL` | 60s | 4 hours (14400s) |
| `imageSizes` default | `[16, 32, 48, 64, 96, 128, 256, 384]` | `[32, 48, 64, 96, 128, 256, 384]` (16 removed) |
| `qualities` default | `[1..100]` | `[75]` only |
| `dangerouslyAllowLocalIP` | true | false |
| `maximumRedirects` | unlimited | 3 |

### Responsive Images

```tsx
<Image
  src="/product.jpg"
  alt="Product"
  width={800}
  height={600}
  sizes="(max-width: 640px) 100vw, (max-width: 1024px) 50vw, 33vw"
  quality={90}
/>
```

### Fill Mode (No Dimensions Needed)

```tsx
<div className="relative w-full h-96">
  <Image
    src="/cover.jpg"
    alt="Cover"
    fill
    className="object-cover"
    sizes="100vw"
  />
</div>
```

---

## 14. Metadata API

### Static Metadata

```tsx
// app/layout.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  title: {
    default: 'My App',
    template: '%s | My App',
  },
  description: 'The best app',
  metadataBase: new URL('https://myapp.com'),
  openGraph: {
    type: 'website',
    locale: 'en_US',
    url: 'https://myapp.com',
    siteName: 'My App',
    images: [{ url: '/og-image.png', width: 1200, height: 630 }],
  },
  twitter: {
    card: 'summary_large_image',
    creator: '@myapp',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-image-preview': 'large',
    },
  },
}
```

### Dynamic Metadata with `generateMetadata`

```tsx
// app/blog/[slug]/page.tsx
import type { Metadata, ResolvingMetadata } from 'next'

type Props = {
  params: Promise<{ slug: string }>
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>
}

export async function generateMetadata(
  { params }: Props,
  parent: ResolvingMetadata,
): Promise<Metadata> {
  const { slug } = await params
  const post = await fetch(`https://api.example.com/posts/${slug}`).then(r => r.json())

  // Extend parent images rather than replacing
  const previousImages = (await parent).openGraph?.images || []

  return {
    title: post.title,
    description: post.excerpt,
    openGraph: {
      title: post.title,
      description: post.excerpt,
      images: [`/og/${slug}.png`, ...previousImages],
    },
  }
}

export default async function BlogPostPage({ params }: Props) {
  const { slug } = await params
  // ...
}
```

### Streaming Metadata

`generateMetadata` streams by default -- the page UI renders immediately and metadata is appended when resolved. This is handled automatically.

For bots that cannot execute JavaScript, Next.js blocks rendering to ensure metadata is in `<head>`. Customize with:

```ts
// next.config.ts
const config: NextConfig = {
  htmlLimitedBots: /facebookexternalhit|twitterbot/i,
}
```

### Cached Metadata (with Cache Components)

```tsx
// app/page.tsx
export async function generateMetadata() {
  'use cache'
  const { title, description } = await db.query('site-metadata')
  return { title, description }
}
```

### Title Behavior

```tsx
// Layout: template + default
export const metadata: Metadata = {
  title: {
    template: '%s | Acme',
    default: 'Acme',
  },
}

// Child page: simple string
export const metadata: Metadata = {
  title: 'About',
}
// Result: <title>About | Acme</title>

// Child page: absolute (bypasses template)
export const metadata: Metadata = {
  title: { absolute: 'Contact Us' },
}
// Result: <title>Contact Us</title>
```

### File-Based Metadata

Place these files in route segments for automatic metadata generation:

| File | Purpose |
|------|---------|
| `icon.png` / `icon.svg` | Favicon (16.2 supports multiple formats) |
| `apple-icon.png` | Apple touch icon |
| `opengraph-image.tsx` | Dynamic OG image |
| `twitter-image.tsx` | Dynamic Twitter card image |
| `sitemap.ts` | Dynamic sitemap |
| `robots.ts` | Dynamic robots.txt |
| `manifest.ts` | Web app manifest |

```tsx
// app/opengraph-image.tsx
import { ImageResponse } from 'next/og'

export const alt = 'About Acme'
export const size = { width: 1200, height: 630 }
export const contentType = 'image/png'

export default async function Image() {
  return new ImageResponse(
    (
      <div
        style={{
          fontSize: 128,
          background: 'white',
          width: '100%',
          height: '100%',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        Acme
      </div>
    ),
    { ...size },
  )
}
```

---

## Migration Notes

### Migrating from 15 to 16

1. **Async params**: `params` and `searchParams` are now `Promise<T>` -- must `await` them
   ```tsx
   // Before (15.x with warnings)
   export default function Page({ params }: { params: { id: string } }) {
     return <div>{params.id}</div>
   }

   // After (16.x)
   export default async function Page({ params }: { params: Promise<{ id: string }> }) {
     const { id } = await params
     return <div>{id}</div>
   }
   ```

2. **Async request APIs**: `cookies()`, `headers()`, `draftMode()` must be awaited
   ```tsx
   // Before
   const token = cookies().get('token')

   // After
   const token = (await cookies()).get('token')
   ```

3. **Rename `middleware.ts` to `proxy.ts`** (recommended, old name deprecated)

4. **`revalidateTag` now requires second argument**:
   ```tsx
   // Before
   revalidateTag('posts')

   // After
   revalidateTag('posts', 'max')
   ```

5. **Turbopack is now the default bundler**. Opt out with `next build --webpack`

6. **Parallel routes require `default.tsx`** in all slots (build fails without them)

7. **AMP support removed**, `next lint` removed (use ESLint directly)

### Migrating from 14 to 15

1. **Caching semantics**: `fetch` requests and `GET` Route Handlers are no longer cached by default
2. **React 19**: New concurrent features, backward-compatible for most App Router code
3. **`next/image`**: `squoosh` removed in favor of `sharp`
4. **`next/dynamic`**: `suspense` prop removed, no longer inserts empty Suspense boundaries
5. **`getServerSideProps`/`getStaticProps`**: Not available in App Router -- use `fetch` in Server Components

### Migrating from Pages Router to App Router

| Pages Router | App Router Equivalent |
|-------------|----------------------|
| `pages/index.tsx` | `app/page.tsx` |
| `pages/about.tsx` | `app/about/page.tsx` |
| `pages/blog/[slug].tsx` | `app/blog/[slug]/page.tsx` |
| `pages/_app.tsx` | `app/layout.tsx` |
| `pages/_document.tsx` | `app/layout.tsx` (html/body) |
| `pages/api/health.ts` | `app/api/health/route.ts` |
| `getServerSideProps` | `fetch` in Server Components |
| `getStaticProps` | `fetch` + `generateStaticParams` |
| `getStaticPaths` | `generateStaticParams` |
| `_error.tsx` | `error.tsx` |
| `404.tsx` | `not-found.tsx` |

---

## Next.js 16.2 Experimental Features

### `experimental.prefetchInlining`

Reduces prefetch request volume by bundling all segment data for a route into a single response.

```ts
const config: NextConfig = {
  experimental: {
    prefetchInlining: true,
  },
}
```

### `experimental.cachedNavigations`

Caches static and dynamic Server Components data from navigations for instant repeat visits. Requires `cacheComponents`.

### `experimental.appNewScrollHandler`

Improved scroll and focus management using React Fragment refs.

### `next-browser` (Experimental)

Forward browser console logs to the dev server terminal.

---

## Configuration Quick Reference

```ts
// next.config.ts (Next.js 16.2)
import type { NextConfig } from 'next'

const config: NextConfig = {
  // Cache Components (PPR + use cache)
  cacheComponents: true,

  // Custom cache life profiles
  cacheLife: {
    myProfile: { stale: 60, revalidate: 900, expire: 86400 },
  },

  // Custom cache handlers (Redis, KV, etc.)
  cacheHandlers: {
    remote: './my-cache-handler.ts',
  },

  // React Compiler (automatic memoization)
  reactCompiler: true,

  // Turbopack FS caching
  turbopackFileSystemCache: true,

  // View Transitions
  viewTransition: true,

  // Typed routes
  typedRoutes: true,

  // Images
  images: {
    remotePatterns: [
      { protocol: 'https', hostname: 'cdn.example.com' },
    ],
  },

  // Adapters (stable in 16.2)
  adapterPath: './my-adapter.ts',
}

export default config
```

---

## Turbopack Performance (16.0-16.2)

| Metric | Improvement |
|--------|------------|
| `next dev` startup (16.2 vs 16.1) | ~400% faster (87% reduction) |
| Server rendering | ~25-60% faster (RSC payload deserialization) |
| Production builds | 2-5x faster vs webpack |
| Fast Refresh | Up to 10x faster |
| Dev startup (vercel.com) | 76.7% faster |

---

## Sources

- [Next.js 16 Blog Post](https://nextjs.org/blog/next-16)
- [Next.js 16.1 Blog Post](https://nextjs.org/blog/next-16-1)
- [Next.js 16.2 Blog Post](https://nextjs.org/blog/next-16-2)
- [Next.js 15 Blog Post](https://nextjs.org/blog/next-15)
- [`use cache` Directive Docs](https://nextjs.org/docs/app/api-reference/directives/use-cache)
- [Parallel Routes Docs](https://nextjs.org/docs/app/building-your-application/routing/parallel-routes)
- [Intercepting Routes Docs](https://nextjs.org/docs/app/building-your-application/routing/intercepting-routes)
- [generateMetadata Docs](https://nextjs.org/docs/app/api-reference/functions/generate-metadata)
