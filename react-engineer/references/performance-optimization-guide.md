# React/Next.js Performance Optimization Guide

## Performance Budget

Start every optimization effort with a budget. Without targets, you don't know when to stop.

| Metric | Budget | Red Line |
|:-------|:-------|:---------|
| First Load JS (homepage) | < 80 KB | 120 KB |
| First Load JS (avg page) | < 120 KB | 180 KB |
| LCP | < 2.0s | 2.5s |
| INP | < 150ms | 200ms |
| CLS | < 0.05 | 0.1 |
| TTFB | < 200ms | 800ms |
| Time to Interactive | < 3.5s | 5.0s |

---

## 1. Bundle Optimization

### Analyze Your Bundle

```bash
# Next.js built-in analysis
ANALYZE=true npm run build

# Check specific package sizes
npx cost-of-modules
```

### Common Bundle Bloat Sources

| Source | Typical Size | Fix |
|:-------|:------------|:----|
| `moment.js` + locales | 70-230 KB | Replace with `date-fns` or `dayjs` |
| `lodash` (full import) | 70 KB | Use `lodash-es` or individual imports |
| `@fortawesome/fontawesome` | 100+ KB | Use tree-shaken imports or SVG icons |
| `core-js` polyfills | 30-100 KB | Target modern browsers, use `browserslist` |
| `@prisma/client` (client) | N/A | Never import in client components |
| Heavy chart libs (d3, chart.js) | 100-300 KB | Dynamic import, load on demand |

### Tree-Shaking Fixes

```tsx
// BAD: Barrel import pulls in everything
import { debounce, throttle, groupBy } from 'lodash';

// GOOD: Individual imports
import debounce from 'lodash/debounce';
import throttle from 'lodash/throttle';
import groupBy from 'lodash/groupBy';

// BEST: Use lodash-es with proper tree-shaking
import { debounce, throttle, groupBy } from 'lodash-es';
```

### Code Splitting Strategies

```tsx
import dynamic from 'next/dynamic';

// 1. Route-level: Automatic in Next.js App Router
// Each app/ route gets its own chunk

// 2. Component-level: Dynamic import heavy components
const Chart = dynamic(() => import('./chart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // Skip SSR for browser-only components
});

// 3. Conditional loading: Only load when needed
function ProductPage({ product }: { product: Product }) {
  const [showReviews, setShowReviews] = useState(false);

  return (
    <div>
      <ProductInfo product={product} />
      <button onClick={() => setShowReviews(true)}>Show Reviews</button>
      {showReviews && <ReviewsSection productId={product.id} />}
    </div>
  );
}

// 4. Route prefetching control
import Link from 'next/link';

// Only prefetch on hover (saves bandwidth)
<Link href="/products/123" prefetch={false}>Product</Link>

// Never prefetch (rarely visited pages)
<Link href="/terms" prefetch={false}>Terms</Link>
```

---

## 2. Server Rendering Performance

### Parallel Data Fetching

```tsx
// BAD: Sequential waterfalls
async function DashboardPage() {
  const user = await getUser();          // 200ms
  const orders = await getOrders(user.id); // 300ms (depends on user)
  const notifications = await getNotifications(user.id); // 200ms (depends on user)
  // Total: 700ms
}

// GOOD: Parallel where possible
async function DashboardPage() {
  const user = await getUser(); // Must be first
  const [orders, notifications] = await Promise.all([
    getOrders(user.id),
    getNotifications(user.id),
  ]);
  // Total: 400ms
}

// BEST: Colocate fetches, use React cache
import { cache } from 'react';

const getUser = cache(async (id: string) => {
  const res = await fetch(`/api/users/${id}`);
  return res.json();
});

async function DashboardPage() {
  // If multiple components call getUser(id), React deduplicates
  const user = await getUser(userId);
  return (
    <div>
      <UserHeader userId={userId} />     {/* Calls getUser -> deduplicated */}
      <OrderList userId={userId} />       {/* Calls getUser -> deduplicated */}
      <NotificationBadge userId={userId} /> {/* Calls getUser -> deduplicated */}
    </div>
  );
}
```

### Suspense Boundaries for Progressive Loading

```tsx
// BAD: Single Suspense boundary blocks entire page
export default async function Page() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <SlowDataComponent />       {/* 3s */}
      <AlsoSlowComponent />       {/* 2s */}
      <FastComponent />           {/* 200ms -- blocked by slow siblings! */}
    </Suspense>
  );
}

// GOOD: Granular Suspense boundaries
export default async function Page() {
  return (
    <div>
      <FastComponent />           {/* Instant */}
      <Suspense fallback={<SlowSkeleton />}>
        <SlowDataComponent />     {/* Streams in after 3s */}
      </Suspense>
      <Suspense fallback={<AlsoSlowSkeleton />}>
        <AlsoSlowComponent />     {/* Streams in after 2s */}
      </Suspense>
    </div>
  );
}
```

### Streaming with Loading States

```
app/
  dashboard/
    page.tsx            # Server Component, immediate shell
    loading.tsx         # Fallback while navigating
    components/
      metrics.tsx       # Server Component, uses Suspense
      metrics-skeleton.tsx
```

---

## 3. Caching Strategy

### Multi-Layer Cache Architecture

```
Request → CDN Cache → Next.js Data Cache → Full Route Cache → React Cache → DB
           (edge)       (fetch cache)       (ISR/SSG)         (request)     (source)
```

### Cache Configuration Matrix

| Data Type | Cache Layer | Duration | Invalidation |
|:----------|:-----------|:----------|:-------------|
| Product catalog | ISR | 1 hour | On-demand via revalidateTag |
| User profile | No cache (SSR) | N/A | Always fresh |
| Search results | URL-keyed TanStack Query | 30s stale | On navigation |
| Navigation menu | Full Route Cache | Build-time | On deploy |
| Stock status | Short ISR | 10s | On-demand via webhook |
| Blog posts | ISR | 24 hours | On content update |

### Next.js Cache Configuration

```tsx
// Static data (cached forever until redeploy)
const staticData = await fetch('/api/config', { cache: 'force-cache' });

// ISR data (revalidate every N seconds)
const isrData = await fetch('/api/products', { next: { revalidate: 3600 } });

// Tagged cache (granular invalidation)
const taggedData = await fetch('/api/products', {
  next: { tags: ['products'], revalidate: 3600 },
});

// No cache (always fresh)
const freshData = await fetch('/api/user', { cache: 'no-store' });
```

### Client-Side Caching with TanStack Query

```tsx
const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30 * 1000,    // Data is fresh for 30s
      gcTime: 5 * 60 * 1000,   // Cache kept for 5min after last use
      refetchOnWindowFocus: false, // Don't refetch on tab switch
    },
  },
});

// Per-query overrides
useQuery({
  queryKey: ['products'],
  queryFn: fetchProducts,
  staleTime: 60 * 1000,  // Products fresh for 1 minute
  gcTime: 10 * 60 * 1000, // Keep cache for 10 minutes
  placeholderData: keepPreviousData, // Show old data while loading new
});
```

---

## 4. Image Performance

### Next.js Image Component

```tsx
import Image from 'next/image';

// Above-fold hero: priority loading
<Image
  src={product.image}
  alt={product.name}
  width={1200}
  height={600}
  priority
  sizes="100vw"
  placeholder="blur"
  blurDataURL={product.blurHash}
/>

// Below-fold gallery: lazy loading (default)
<Image
  src={image.url}
  alt={image.alt}
  width={400}
  height={400}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
  loading="lazy"
/>

// Responsive images with art direction
<picture>
  <source media="(max-width: 768px)" srcSet="/hero-mobile.webp" />
  <source media="(min-width: 769px)" srcSet="/hero-desktop.webp" />
  <Image src="/hero-desktop.webp" alt="Hero" width={1200} height={600} />
</picture>
```

### Image Optimization Checklist

- [ ] All images use `next/image` (automatic WebP/AVIF, responsive sizes)
- [ ] Above-fold images have `priority` prop
- [ ] `sizes` prop is set for every image (prevents downloading oversized images)
- [ ] `width` and `height` set to prevent CLS
- [ ] `placeholder="blur"` for smooth loading (or `placeholder="empty"` with fixed dimensions)
- [ ] External image domains configured in `next.config.js`

```js
// next.config.js
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    remotePatterns: [
      { protocol: 'https', hostname: 'cdn.mystore.com' },
    ],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920],
    imageSizes: [16, 32, 48, 64, 96, 128, 256],
  },
};
```

---

## 5. Prefetching and Navigation

### Link Prefetching

```tsx
import Link from 'next/link';

// Default: prefetches when visible in viewport
<Link href="/products/123">Product</Link>

// Disable prefetch for rarely-visited pages (saves bandwidth)
<Link href="/legal/terms" prefetch={false}>Terms</Link>

// Prefetch on hover only
<Link href="/heavy-page" prefetch={false}>Heavy Page</Link>
```

### Router Prefetching

```tsx
'use client';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';

function usePrefetchOnHover(href: string) {
  const router = useRouter();

  function handleMouseEnter() {
    router.prefetch(href);
  }

  return { onMouseEnter: handleMouseEnter };
}

// Usage
function ProductLink({ product }: { product: Product }) {
  const href = `/products/${product.id}`;
  const { onMouseEnter } = usePrefetchOnHover(href);

  return (
    <Link href={href} onMouseEnter={onMouseEnter}>
      {product.name}
    </Link>
  );
}
```

---

## 6. Edge Runtime

### When to Use Edge vs Node.js Runtime

| Factor | Edge | Node.js |
|:-------|:-----|:--------|
| Cold start | < 5ms | 250ms-1s |
| Max execution time | 30s (Vercel) | No limit |
| Bundle size limit | 4MB | No limit |
| Node.js APIs | Limited | Full |
| Database access | HTTP only | Direct |
| Cost per invocation | Lower | Higher |
| Best for | Middleware, redirects, simple APIs | Complex API routes, SSR with DB |

```tsx
// Edge runtime for fast middleware
export const runtime = 'edge';

export async function GET(request: NextRequest) {
  // Fast: runs at the CDN edge
  const country = request.geo?.country ?? 'US';
  return Response.json({ country });
}
```

```tsx
// Node.js runtime for complex operations
export const runtime = 'nodejs'; // default

export async function POST(request: NextRequest) {
  // Full Node.js: database, file system, heavy compute
  const data = await request.json();
  const result = await db.order.create({ data });
  await sendConfirmationEmail(result);
  return Response.json(result);
}
```

---

## 7. Third-Party Script Loading

```tsx
import Script from 'next/script';

export function Analytics() {
  return (
    <>
      {/* Load after page becomes interactive */}
      <Script
        src="https://analytics.example.com/script.js"
        strategy="afterInteractive"
      />

      {/* Load only after page is fully loaded */}
      <Script
        src="https://feedback.example.com/widget.js"
        strategy="lazyOnload"
      />

      {/* Load immediately for critical scripts */}
      <Script
        src="https://cdn.auth0.com/js/auth0.js"
        strategy="beforeInteractive"
      />

      {/* Inline script with worker (off main thread) */}
      <Script strategy="worker">
        {`console.log('Runs in a web worker, not blocking main thread');`}
      </Script>
    </>
  );
}
```

---

## 8. React Compiler Performance

The React Compiler eliminates manual memoization but has its own considerations:

```tsx
// The compiler handles these automatically:
// - useMemo for expensive computations
// - useCallback for function stability
// - React.memo for component memoization

// BUT: you still need to write efficient code
function ProductGrid({ products }: { products: Product[] }) {
  // GOOD: Compiler memoizes the filtered array
  const inStock = products.filter((p) => p.inStock);

  // BAD: Creating expensive objects in render that the compiler
  // can't optimize away because they're used in effects
  const analyticsData = products.map((p) => ({
    id: p.id,
    revenue: p.price * p.soldCount,
    margin: (p.price - p.cost) / p.price,
  }));

  useEffect(() => {
    trackAnalytics(analyticsData); // Re-creates every render
  }, [analyticsData]); // deps change every render!

  // FIX: Compute inside the effect or use useMemo explicitly
  useEffect(() => {
    const data = products.map((p) => ({
      id: p.id,
      revenue: p.price * p.soldCount,
      margin: (p.price - p.cost) / p.price,
    }));
    trackAnalytics(data);
  }, [products]);
}
```

---

## 9. Monitoring and Measurement

### Web Vitals Collection

```tsx
// app/layout.tsx or instrumentation
export function reportWebVitals(metric: NextWebVitalsMetric) {
  const body = {
    name: metric.name,
    value: metric.value,
    rating: metric.rating,
    delta: metric.delta,
    id: metric.id,
    pathname: window.location.pathname,
  };

  // Send to your analytics endpoint
  fetch('/api/analytics/web-vitals', {
    method: 'POST',
    body: JSON.stringify(body),
    headers: { 'Content-Type': 'application/json' },
  }).catch(() => {}); // Fire and forget
}
```

### Performance Monitoring Dashboard Metrics

Track these over time:

| Metric | Warning Threshold | Critical Threshold |
|:-------|:-----------------|:-------------------|
| p50 LCP | > 2.0s | > 2.5s |
| p75 LCP | > 2.5s | > 4.0s |
| p50 INP | > 150ms | > 200ms |
| p75 INP | > 200ms | > 500ms |
| p50 CLS | > 0.05 | > 0.1 |
| p75 CLS | > 0.1 | > 0.25 |
| TTFB p50 | > 200ms | > 800ms |
| JS bundle delta | +10% from baseline | +25% from baseline |

### Performance Regression Testing

```bash
# Run Lighthouse in CI
npx lhci autorun --config=lighthouserc.json
```

```json
// lighthouserc.json
{
  "ci": {
    "assert": {
      "assertions": {
        "categories:performance": ["error", { "minScore": 0.9 }],
        "categories:accessibility": ["error", { "minScore": 0.95 }],
        "first-contentful-paint": ["error", { "maxNumericValue": 2000 }],
        "largest-contentful-paint": ["error", { "maxNumericValue": 2500 }],
        "cumulative-layout-shift": ["error", { "maxNumericValue": 0.1 }],
        "total-blocking-time": ["error", { "maxNumericValue": 300 }]
      }
    }
  }
}
```

---

## 10. Optimization Priority Order

When time is limited, optimize in this order (biggest impact first):

1. **Rendering strategy**: Switch SSR pages to ISR/SSG where possible
2. **Image optimization**: `next/image` with `sizes`, `priority`, formats
3. **Bundle size**: Remove/replace heavy dependencies, dynamic imports
4. **Data fetching**: Parallel fetches, Suspense boundaries, React `cache()`
5. **Caching headers**: CDN and browser cache for static assets and API responses
6. **Third-party scripts**: Defer non-critical scripts
7. **Client re-renders**: React Compiler, memoization, state colocation
8. **Prefetching**: Strategic prefetch for likely navigation targets
