# SSR, SSG, ISR, and SEO for React/Next.js

## Rendering Strategy Decision Matrix

| Strategy | When | TTFB | Cache | Complexity | SEO |
|:---------|:-----|:-----|:------|:-----------|:----|
| **SSG** (Static Site Generation) | Content rarely changes, known at build time | Fastest (CDN) | Build-time | Low | Excellent |
| **ISR** (Incremental Static Regeneration) | Content changes periodically, not per-request | Fast (CDN, stale-while-revalidate) | Time-based or on-demand | Low | Excellent |
| **SSR** (Server-Side Rendering) | Content changes per-request, personalized | Slowest (compute per request) | None (or manual) | Medium | Excellent |
| **CSR** (Client-Side Rendering) | Private dashboards, no SEO need | Fast HTML, slow FCP | N/A | Low | Poor |
| **PPR** (Partial Prerendering) | Mix of static shell + dynamic holes | Fast (static shell from CDN) | Shell cached, holes streamed | Medium | Excellent |
| **Streaming SSR** | Dynamic pages with multiple data sources | Fast TTFB (shell), progressive | None | Medium-High | Good |

### Decision Flowchart

```
Does the page need to be indexed by search engines?
  NO -> CSR (Client Component with 'use client')
  YES -> Is the content the same for every visitor?
    YES -> Does it change more than once per hour?
      NO -> SSG (static at build time)
      YES -> ISR (revalidate every N seconds)
    NO -> Does it need per-request personalization?
      YES -> PPR or Streaming SSR
      NO -> SSR with cache headers
```

---

## Static Site Generation (SSG)

### When to Use

- Marketing pages, blog posts, documentation
- Product pages for catalogs that don't change per-user
- Landing pages, legal pages, about pages

```tsx
// app/products/[id]/page.tsx
// Static generation with generateStaticParams

export const revalidate = false; // Pure static, never revalidates

export async function generateStaticParams() {
  const products = await db.product.findMany({ select: { id: true } });
  return products.map((p) => ({ id: p.id }));
}

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await db.product.findUnique({ where: { id } });

  if (!product) notFound();

  return (
    <article>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
    </article>
  );
}
```

### Build-Time Data Fetching

```tsx
// For truly static data that won't change between deployments
async function getCategories(): Promise<Category[]> {
  // This runs at build time only
  const res = await fetch(`${process.env.API_URL}/categories`, {
    cache: 'force-cache', // Explicit: cache at build time
  });
  return res.json();
}

export default async function CategoryPage() {
  const categories = await getCategories();
  return (
    <nav>
      {categories.map((cat) => (
        <a key={cat.id} href={`/categories/${cat.slug}`}>{cat.name}</a>
      ))}
    </nav>
  );
}
```

---

## Incremental Static Regeneration (ISR)

### Time-Based Revalidation

```tsx
// Revalidate every hour
export const revalidate = 3600;

export default async function BlogIndex() {
  const posts = await db.post.findMany({
    orderBy: { publishedAt: 'desc' },
    take: 20,
  });

  return (
    <div>
      {posts.map((post) => (
        <article key={post.id}>
          <h2><a href={`/blog/${post.slug}`}>{post.title}</a></h2>
          <time>{post.publishedAt}</time>
        </article>
      ))}
    </div>
  );
}
```

### On-Demand Revalidation

```tsx
// app/api/revalidate/route.ts
import { revalidatePath, revalidateTag } from 'next/cache';
import { NextRequest } from 'next/server';

export async function POST(request: NextRequest) {
  const body = await request.json();
  const secret = request.headers.get('x-revalidate-secret');

  // Verify the request is authorized
  if (secret !== process.env.REVALIDATE_SECRET) {
    return Response.json({ error: 'Invalid secret' }, { status: 401 });
  }

  if (body.tag) {
    // Revalidate all pages with this cache tag
    revalidateTag(body.tag);
    return Response.json({ revalidated: true, tag: body.tag });
  }

  if (body.path) {
    // Revalidate a specific path
    revalidatePath(body.path);
    return Response.json({ revalidated: true, path: body.path });
  }

  return Response.json({ error: 'Missing tag or path' }, { status: 400 });
}
```

### Cache Tags for Granular Invalidation

```tsx
// Fetch with cache tags
async function getProduct(id: string) {
  const res = await fetch(`${process.env.API_URL}/products/${id}`, {
    next: {
      tags: [`product-${id}`, 'products'],
      revalidate: 3600,
    },
  });
  return res.json();
}

// When a product is updated, invalidate its specific cache
// POST /api/revalidate { "tag": "product-123" }
```

### ISR Cost Optimization

```tsx
// Careful revalidation intervals affect compute cost
// Shorter interval = more revalidation = higher serverless function invocations

// Product catalog: changes a few times per day
export const revalidate = 3600; // 1 hour is usually enough

// Blog content: changes rarely
export const revalidate = 86400; // 24 hours

// Stock/price data: needs freshness but not real-time
export const revalidate = 60; // 1 minute

// NEVER do this unless truly needed:
// export const revalidate = 1; // Every second = extremely expensive
```

---

## Server-Side Rendering (SSR)

### Dynamic Rendering

```tsx
// app/dashboard/page.tsx
// Per-request rendering because content is user-specific

import { cookies } from 'next/headers';

export const dynamic = 'force-dynamic'; // Explicit: always SSR

export default async function Dashboard() {
  const cookieStore = await cookies();
  const session = cookieStore.get('session');

  if (!session) redirect('/login');

  const user = await getSessionUser(session.value);
  const data = await getUserDashboard(user.id);

  return (
    <main>
      <h1>Welcome, {user.name}</h1>
      <DashboardWidgets data={data} />
    </main>
  );
}
```

### SSR with Cache Headers

Even SSR pages can use HTTP caching for shared content:

```tsx
export async function GET(request: NextRequest) {
  const data = await fetchPublicData();

  return Response.json(data, {
    headers: {
      'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300',
      'CDN-Cache-Control': 'public, s-maxage=60',
    },
  });
}
```

---

## Partial Prerendering (PPR)

PPR delivers a static HTML shell instantly, then streams dynamic content into Suspense holes.

```tsx
// app/products/[id]/page.tsx
// The layout and product info are static (fast TTFB)
// The reviews and stock status are dynamic (streamed in)

export const experimental_ppr = true; // Next.js 15.x experimental
// PPR is stable in Next.js 16

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  // This fetch is static (cached at build time)
  const product = await getProduct(id);

  return (
    <div className="product-page">
      {/* Static shell — instant */}
      <h1>{product.name}</h1>
      <p className="price">${product.price}</p>
      <img src={product.image} alt={product.name} />

      {/* Dynamic hole — streamed */}
      <Suspense fallback={<StockSkeleton />}>
        <StockStatus productId={id} />
      </Suspense>

      {/* Dynamic hole — streamed */}
      <Suspense fallback={<ReviewsSkeleton />}>
        <ProductReviews productId={id} />
      </Suspense>

      {/* Static — included in shell */}
      <RelatedProducts category={product.category} />
    </div>
  );
}

// Dynamic components (not cached)
async function StockStatus({ productId }: { productId: string }) {
  const stock = await getRealTimeStock(productId);
  return <span className={stock > 0 ? 'text-green' : 'text-red'}>
    {stock > 0 ? `${stock} in stock` : 'Out of stock'}
  </span>;
}

async function ProductReviews({ productId }: { productId: string }) {
  const reviews = await getProductReviews(productId);
  return <ReviewList reviews={reviews} />;
}
```

---

## Streaming SSR

### Basic Streaming with Suspense

```tsx
// app/feed/page.tsx
export default async function FeedPage() {
  return (
    <div>
      {/* This renders immediately */}
      <h1>Your Feed</h1>

      {/* Each section loads independently */}
      <section>
        <h2>Recommended</h2>
        <Suspense fallback={<CardGridSkeleton count={6} />}>
          <RecommendedProducts />
        </Suspense>
      </section>

      <section>
        <h2>Trending</h2>
        <Suspense fallback={<CardGridSkeleton count={6} />}>
          <TrendingProducts />
        </Suspense>
      </section>

      <section>
        <h2>Based on Your History</h2>
        <Suspense fallback={<CardGridSkeleton count={6} />}>
          <PersonalizedProducts />
        </Suspense>
      </section>
    </div>
  );
}
```

### Streaming with Loading UI

```
app/
  feed/
    page.tsx          # Has Suspense boundaries
    loading.tsx       # Shows while page.tsx data loads
    recommended/
      page.tsx        # Recommended section
      loading.tsx     # Recommended skeleton
```

---

## SEO: Metadata and Open Graph

### Page-Level Metadata

```tsx
// app/products/[id]/page.tsx
import type { Metadata, ResolvingMetadata } from 'next';

interface Props {
  params: Promise<{ id: string }>;
}

export async function generateMetadata(
  { params }: Props,
  parent: ResolvingMetadata
): Promise<Metadata> {
  const { id } = await params;
  const product = await getProduct(id);

  if (!product) return { title: 'Product Not Found' };

  const previousImages = (await parent).openGraph?.images || [];

  return {
    title: `${product.name} | My Store`,
    description: product.description.slice(0, 160),
    keywords: [product.category, product.brand, product.name],
    openGraph: {
      title: product.name,
      description: product.description.slice(0, 160),
      images: [product.image, ...previousImages],
      type: 'website',
      siteName: 'My Store',
    },
    twitter: {
      card: 'summary_large_image',
      title: product.name,
      description: product.description.slice(0, 160),
      images: [product.image],
    },
    alternates: {
      canonical: `/products/${product.slug}`,
    },
    robots: product.inStock
      ? { index: true, follow: true }
      : { index: false, follow: true }, // Don't index out-of-stock
  };
}
```

### Layout-Level Metadata

```tsx
// app/layout.tsx
import type { Metadata } from 'next';

export const metadata: Metadata = {
  metadataBase: new URL('https://mystore.com'),
  title: {
    default: 'My Store - Quality Products',
    template: '%s | My Store',
  },
  description: 'Shop quality products at great prices.',
  openGraph: {
    type: 'website',
    locale: 'en_US',
    siteName: 'My Store',
  },
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  verification: {
    google: 'your-google-verification-code',
  },
};
```

### Structured Data (JSON-LD)

```tsx
// components/json-ld.tsx
export function ProductJsonLd({ product }: { product: Product }) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Product',
    name: product.name,
    description: product.description,
    image: product.images.map((img) => img.url),
    brand: {
      '@type': 'Brand',
      name: product.brand,
    },
    offers: {
      '@type': 'Offer',
      url: `https://mystore.com/products/${product.slug}`,
      priceCurrency: 'USD',
      price: product.price.toFixed(2),
      availability: product.inStock
        ? 'https://schema.org/InStock'
        : 'https://schema.org/OutOfStock',
      seller: {
        '@type': 'Organization',
        name: 'My Store',
      },
    },
    aggregateRating: product.reviewCount > 0
      ? {
          '@type': 'AggregateRating',
          ratingValue: product.averageRating.toFixed(1),
          reviewCount: product.reviewCount,
        }
      : undefined,
  };

  return (
    <script
      type="application/ld+json"
      dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
    />
  );
}
```

### Sitemap Generation

```tsx
// app/sitemap.ts
import type { MetadataRoute } from 'next';

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const products = await db.product.findMany({
    select: { slug: true, updatedAt: true },
    where: { inStock: true },
  });

  const productUrls: MetadataRoute.Sitemap = products.map((product) => ({
    url: `https://mystore.com/products/${product.slug}`,
    lastModified: product.updatedAt,
    changeFrequency: 'daily',
    priority: 0.8,
  }));

  return [
    {
      url: 'https://mystore.com',
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 1,
    },
    {
      url: 'https://mystore.com/products',
      lastModified: new Date(),
      changeFrequency: 'daily',
      priority: 0.9,
    },
    ...productUrls,
  ];
}
```

### Robots.txt

```tsx
// app/robots.ts
import type { MetadataRoute } from 'next';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      {
        userAgent: '*',
        allow: '/',
        disallow: ['/api/', '/account/', '/checkout/', '/admin/'],
      },
    ],
    sitemap: 'https://mystore.com/sitemap.xml',
  };
}
```

---

## SEO Checklist for Every Page

- [ ] Unique `<title>` per page (max 60 chars)
- [ ] Unique `meta description` per page (max 160 chars)
- [ ] Open Graph image (1200x630 minimum)
- [ ] Canonical URL set
- [ ] Structured data (JSON-LD) where applicable
- [ ] Semantic HTML (`<article>`, `<nav>`, `<main>`, `<h1>`-`<h6>`)
- [ ] Images have descriptive `alt` text
- [ ] Internal links use descriptive anchor text (not "click here")
- [ ] Page loads with valid HTTP 200 status
- [ ] No duplicate content across routes
- [ ] Mobile-responsive layout
- [ ] Core Web Vitals passing (LCP < 2.5s, CLS < 0.1, INP < 200ms)

---

## Common SEO Anti-Patterns in Next.js

### Anti-Pattern: Client-Only Rendering for SEO Pages

```tsx
// BAD: SEO-critical page rendered client-side
'use client';
export default function ProductsPage() {
  const [products, setProducts] = useState([]);
  useEffect(() => { fetch('/api/products').then(r => r.json()).then(setProducts); }, []);
  // Search engines see an empty page!
}

// GOOD: Server Component fetches data, renders full HTML
export default async function ProductsPage() {
  const products = await db.product.findMany();
  return <ProductGrid products={products} />;
}
```

### Anti-Pattern: Missing Loading States

```tsx
// BAD: No loading.tsx, page blocks until all data is ready
// Search engine crawler may time out

// GOOD: Provide loading.tsx for progressive enhancement
// app/products/loading.tsx
export default function ProductsLoading() {
  return <ProductGridSkeleton />;
}
```

### Anti-Pattern: Dynamic Routes Without generateStaticParams

```tsx
// BAD: Dynamic route without static generation
// Every request is SSR = slow TTFB, higher compute cost
export default async function ProductPage({ params }: Props) {
  const { id } = await params;
  const product = await getProduct(id);
  return <ProductDetail product={product} />;
}

// GOOD: Provide generateStaticParams + ISR for known products
export async function generateStaticParams() {
  const products = await db.product.findMany({
    select: { id: true },
    where: { status: 'published' },
  });
  return products.map((p) => ({ id: p.id }));
}

export const revalidate = 3600; // ISR: revalidate every hour
```
