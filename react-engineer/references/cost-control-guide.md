# React/Next.js Cost Control Guide

## Overview

Serverless and edge-hosted React applications can accumulate costs rapidly if caching, rendering strategies, and data fetching patterns are not carefully managed. This guide covers cost optimization for Vercel, AWS (via SST/Amplify/CDK), and self-hosted deployments.

---

## Cost Drivers in Next.js Applications

| Cost Driver | Platform Impact | Typical % of Bill |
|:------------|:----------------|:------------------|
| Serverless function invocations | Vercel Serverless, AWS Lambda | 20-40% |
| Edge function invocations | Vercel Edge, Cloudflare Workers | 5-15% |
| Data transfer / bandwidth | All platforms | 10-20% |
| Image optimization | Vercel (`next/image`) | 5-15% |
| Build minutes | Vercel, CI/CD | 5-10% |
| Database queries (connection time) | PlanetScale, Neon, RDS | 15-30% |
| CDN cache miss ratio | CloudFront, Vercel CDN | 10-20% |

---

## 1. Rendering Strategy Cost Impact

### Cost per 10,000 Page Views

| Strategy | Serverless Invocations | Edge Invocations | Relative Cost |
|:---------|:----------------------|:-----------------|:-------------|
| SSG (static) | 0 | 0 | Lowest (CDN only) |
| ISR (revalidate 1hr) | ~7 (revalidations) | 0 | Very Low |
| ISR (revalidate 1min) | ~167 | 0 | Low-Medium |
| SSR (no cache) | 10,000 | 0 | High |
| SSR + CDN cache (5min) | ~33 | 0 | Medium |
| Edge SSR | 0 | 10,000 | Medium (cheaper per-inv) |

### Strategy: Maximize SSG and ISR

```tsx
// app/products/[id]/page.tsx

// ISR: revalidate every hour
// Cost: ~1 serverless invocation per hour, regardless of traffic
// Benefit: 99.9% of requests served from CDN (free)
export const revalidate = 3600;

export async function generateStaticParams() {
  const products = await db.product.findMany({
    select: { id: true },
    where: { status: 'published' },
  });
  return products.map((p) => ({ id: p.id }));
}

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await getProduct(id);
  return <ProductDetail product={product} />;
}
```

### Strategy: Use PPR for Mixed Static/Dynamic

```tsx
// Partial Prerendering: static shell + dynamic holes
// Cost: Shell served from CDN (free), only dynamic holes invoke serverless
// Benefit: 80-90% of page is static, only personalized sections are dynamic

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await getProduct(id); // Cached (ISR)

  return (
    <div>
      {/* Static shell: cached, zero compute */}
      <h1>{product.name}</h1>
      <p>${product.price}</p>

      {/* Dynamic hole: small serverless invocation */}
      <Suspense fallback={<StockSkeleton />}>
        <StockStatus productId={id} />
      </Suspense>

      {/* Static: cached */}
      <RelatedProducts category={product.category} />
    </div>
  );
}
```

---

## 2. Serverless Function Optimization

### Reduce Function Execution Time

Longer execution = higher cost. Target < 200ms per invocation.

```tsx
// BAD: Multiple sequential DB queries
export async function GET() {
  const user = await db.user.findUnique({ where: { id: userId } });       // 50ms
  const orders = await db.order.findMany({ where: { userId } });          // 80ms
  const preferences = await db.preferences.findUnique({ where: { userId } }); // 30ms
  // Total: 160ms of DB time alone
}

// GOOD: Parallel queries
export async function GET() {
  const [user, orders, preferences] = await Promise.all([
    db.user.findUnique({ where: { id: userId } }),
    db.order.findMany({ where: { userId } }),
    db.preferences.findUnique({ where: { userId } }),
  ]);
  // Total: ~80ms (bound by slowest query)
}

// BEST: Use React cache() to deduplicate across components
import { cache } from 'react';

const getUser = cache(async (id: string) => {
  return db.user.findUnique({ where: { id } });
});
```

### Reduce Cold Starts

```tsx
// Use edge runtime for frequently-hit routes
export const runtime = 'edge'; // Near-zero cold start

// Keep Node.js runtime for routes that need DB/file access
export const runtime = 'nodejs'; // Default, but has cold start cost

// Minimize imported modules in serverless functions
// BAD: Heavy import
import { generatePDF } from 'pdf-lib'; // Adds to bundle size, increases cold start

// GOOD: Dynamic import only when needed
async function handlePDFGeneration() {
  const { generatePDF } = await import('pdf-lib');
  return generatePDF(data);
}
```

### Route-Level Runtime Selection

```tsx
// app/api/health/route.ts - Edge (fast, cheap)
export const runtime = 'edge';
export async function GET() {
  return Response.json({ status: 'ok', timestamp: Date.now() });
}

// app/api/products/route.ts - Node.js (needs DB)
export const runtime = 'nodejs';
export async function GET() {
  const products = await db.product.findMany();
  return Response.json(products);
}

// app/api/products/[id]/route.ts - Edge with HTTP DB client
export const runtime = 'edge';
export async function GET(request: NextRequest) {
  // Use HTTP-based DB client (Neon HTTP, PlanetScale Edge)
  const product = await fetchFromEdgeDB(request);
  return Response.json(product);
}
```

---

## 3. Database Cost Optimization

### Connection Pooling

```tsx
// BAD: Each serverless invocation opens a new connection
// With Prisma: use connection pooling
import { PrismaClient } from '@prisma/client';

// Global singleton prevents connection exhaustion
const globalForPrisma = globalThis as unknown as { prisma: PrismaClient };
export const prisma = globalForPrisma.prisma ?? new PrismaClient();

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma;

// GOOD: Use external connection pooler (PgBouncer, Supavisor, Neon pooler)
// DATABASE_URL="postgresql://user:pass@pooler.host:6543/db?pgbouncer=true"
```

### Query Reduction Patterns

```tsx
// BAD: N+1 query pattern
const products = await db.product.findMany();
for (const product of products) {
  product.reviews = await db.review.findMany({
    where: { productId: product.id },
  });
}
// 1 + N queries!

// GOOD: Include related data
const products = await db.product.findMany({
  include: {
    reviews: {
      take: 5,
      orderBy: { createdAt: 'desc' },
    },
  },
});
// 1 query with JOIN

// GOOD: Batch with DataLoader pattern
import { DataLoader } from 'dataloader';

const reviewLoader = new DataLoader(async (productIds: string[]) => {
  const reviews = await db.review.findMany({
    where: { productId: { in: productIds } },
  });
  return productIds.map((id) => reviews.filter((r) => r.productId === id));
});
```

### Select Only What You Need

```tsx
// BAD: Fetch entire row when you only need name and price
const products = await db.product.findMany();
// Returns: id, name, description, price, images, specs, reviews, ... (large)

// GOOD: Select only needed fields
const products = await db.product.findMany({
  select: {
    id: true,
    name: true,
    price: true,
    image: true,
  },
});
// Returns: only 4 fields (smaller payload, faster query)
```

---

## 4. Image Optimization Cost Control

### Vercel Image Optimization Costs

Vercel charges per optimized image. On Pro plan: included quota, then per-image pricing.

```tsx
// BAD: Optimizing the same image multiple times
// Each unique width/quality combo = separate optimization invocation
<Image src="/hero.jpg" width={1200} height={600} />
<Image src="/hero.jpg" width={600} height={300} />
<Image src="/hero.jpg" width={300} height={150} />
// 3 optimization invocations for the same image!

// GOOD: Use sizes to let Next.js pick the right size
<Image
  src="/hero.jpg"
  alt="Hero"
  width={1200}
  height={600}
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 33vw"
/>
// Next.js generates appropriate srcSet, but uses cached optimizations
```

### Self-Hosted Image Optimization

```js
// next.config.js - Custom loader for self-hosted (avoid Vercel costs)
module.exports = {
  images: {
    loader: 'custom',
    loaderFile: './lib/image-loader.ts',
  },
};

// lib/image-loader.ts
export default function customImageLoader({ src, width, quality }: {
  src: string; width: number; quality?: number;
}) {
  // Use your own image CDN (Cloudflare Images, imgproxy, Thumbor)
  return `https://img.mystore.com/${src}?w=${width}&q=${quality || 75}`;
}
```

---

## 5. CDN and Caching Cost Optimization

### Cache Hit Ratio Targets

| Asset Type | Target Cache Hit Ratio | TTL |
|:-----------|:----------------------|:----|
| Static assets (`_next/static/`) | 99%+ | 1 year (immutable) |
| ISR pages | 90%+ | Until revalidation |
| SSR pages with CDN cache | 70-90% | 60s-5min |
| API responses | 50-80% | Depends on data |

### Reducing Cache Misses

```tsx
// 1. Use stale-while-revalidate for API routes
export async function GET() {
  const data = await fetchData();
  return Response.json(data, {
    headers: {
      'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300',
      // CDN serves stale for up to 300s while revalidating in background
      // Prevents cache stampede (thundering herd)
    },
  });
}

// 2. Use Vary header carefully
export async function GET(request: NextRequest) {
  const locale = request.headers.get('accept-language')?.split(',')[0] ?? 'en';
  const data = await getLocalizedData(locale);

  return Response.json(data, {
    headers: {
      'Cache-Control': 'public, s-maxage=300',
      'Vary': 'Accept-Language', // Separate cache per language
    },
  });
}

// 3. Use stale-if-error for resilience
'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300, stale-if-error=600'
// If origin is down, serve stale cache for up to 600s
```

---

## 6. Build Cost Optimization

### Reduce Build Time

```bash
# Turbopack for faster builds (Next.js 16 default)
# Already default, but verify:
next build --turbopack  # Explicit if needed

# Reduce number of static pages generated at build
# Only pre-render top products, let ISR handle the rest
```

```tsx
// app/products/[id]/page.tsx

// BAD: Generate ALL products at build time
export async function generateStaticParams() {
  const products = await db.product.findMany(); // 100,000 products!
  return products.map((p) => ({ id: p.id }));
}
// Build time: 30+ minutes, may hit timeouts

// GOOD: Generate top products, let ISR handle the rest
export async function generateStaticParams() {
  const products = await db.product.findMany({
    where: { views: { gt: 1000 } }, // Only popular products
    select: { id: true },
    take: 1000, // Limit build time
  });
  return products.map((p) => ({ id: p.id }));
}
// Build time: < 5 minutes
// Less popular products get ISR on first request
```

### Incremental Builds

```js
// next.config.js
module.exports = {
  experimental: {
    incrementalCacheHandlerPath: './cache-handler.ts',
  },
};
```

---

## 7. Bandwidth Optimization

### Reduce Payload Sizes

```tsx
// 1. API response compression (automatic on Vercel/CDN)
// Ensure your hosting platform enables gzip/brotli

// 2. Selective field fetching
// app/api/products/route.ts
export async function GET(request: NextRequest) {
  const fields = request.nextUrl.searchParams.get('fields')?.split(',');

  const products = await db.product.findMany({
    select: fields
      ? Object.fromEntries(fields.map((f) => [f, true]))
      : undefined,
  });

  return Response.json(products);
}
// GET /api/products?fields=id,name,price
// Returns only requested fields = smaller payload

// 3. Pagination with cursor (not offset)
export async function GET(request: NextRequest) {
  const cursor = request.nextUrl.searchParams.get('cursor');
  const limit = Math.min(
    Number(request.nextUrl.searchParams.get('limit') ?? '20'),
    100 // Hard cap
  );

  const products = await db.product.findMany({
    take: limit,
    skip: cursor ? 1 : 0,
    cursor: cursor ? { id: cursor } : undefined,
    orderBy: { createdAt: 'desc' },
  });

  return Response.json({
    products,
    nextCursor: products.length === limit ? products[products.length - 1].id : null,
  });
}
```

---

## 8. Self-Hosting Cost Optimization

### Running Next.js on Kubernetes / Docker

```dockerfile
# Dockerfile - Multi-stage build for minimal image
FROM node:20-slim AS base
RUN npm install -g corepack && corepack enable

FROM base AS deps
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile --prod

FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
RUN pnpm build

FROM base AS runner
WORKDIR /app
ENV NODE_ENV=production

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs
EXPOSE 3000
ENV PORT=3000

CMD ["node", "server.js"]
```

```js
// next.config.js - Enable standalone output for Docker
module.exports = {
  output: 'standalone', // Minimal server bundle for containers
};
```

### Resource Sizing for Self-Hosted

| Component | CPU | Memory | Replicas | Notes |
|:----------|:----|:--------|:---------|:------|
| Next.js SSR | 0.5-1 core | 512MB-1GB | 2-4 (HPA) | Scale on CPU/request rate |
| Next.js ISR | 0.25 core | 256-512MB | 1-2 | Mostly static |
| Redis (cache) | 0.25 core | 256MB | 1 | ISR cache backend |
| CDN (CloudFront/Nginx) | N/A | N/A | N/A | Handle 90%+ of traffic |

---

## 9. Cost Monitoring Checklist

- [ ] Track serverless function invocations per route
- [ ] Monitor ISR revalidation frequency
- [ ] Alert on cache hit ratio below 70%
- [ ] Alert on p95 serverless duration above 500ms
- [ ] Track image optimization count
- [ ] Monitor bandwidth usage per route
- [ ] Review build minutes per week
- [ ] Track database query count per API route
- [ ] Monthly cost review: compare against traffic growth

---

## 10. Quick Wins (Biggest Cost Savings, Least Effort)

| Priority | Action | Typical Savings |
|:---------|:-------|:----------------|
| 1 | Convert SSR pages to ISR where possible | 60-80% function invocations |
| 2 | Add `s-maxage` cache headers to API routes | 30-50% API invocations |
| 3 | Use `select` in database queries (don't fetch all fields) | 20-40% DB costs |
| 4 | Enable connection pooling | 15-30% DB costs |
| 5 | Replace `revalidate: 1` with `revalidate: 60` minimum | 90-98% revalidation invocations |
| 6 | Use edge runtime for health checks and simple APIs | 50-70% function cost per invocation |
| 7 | Dynamic import heavy client-side libraries | 10-20% bandwidth |
| 8 | Set proper `sizes` on images | 10-30% image optimization costs |
