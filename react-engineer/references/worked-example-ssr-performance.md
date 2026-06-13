# Worked Example: Taking a Slow Page from 4s to <1s LCP

## Scenario

A product detail page has a measured LCP of 4.2 seconds. The business reports high bounce rates on mobile. We need to get LCP under 2 seconds while keeping the page functional and reducing server costs.

---

## Step 1: Measure and Diagnose

### Before Optimization

| Metric | Value | Target |
|:-------|:-------|:-------|
| TTFB | 1.8s | < 200ms |
| LCP | 4.2s | < 2.5s |
| FCP | 2.1s | < 1.8s |
| CLS | 0.12 | < 0.1 |
| INP | 320ms | < 200ms |
| First Load JS | 380 KB | < 150 KB |
| Serverless invocations/1K views | 1,000 | < 100 |

### Diagnosis: What's Wrong

```
1. TTFB 1.8s
   - Page is SSR (force-dynamic) even though product rarely changes
   - Sequential data fetches in Server Component
   - No caching anywhere

2. LCP 4.2s
   - Hero image is 2.4MB JPEG, loaded as <img> not next/image
   - Image is render-blocking (not lazy, not prioritized)
   - JavaScript blocks rendering (380KB needs parsing)

3. CLS 0.12
   - Hero image has no width/height -> layout shift when loaded
   - Font loading causes text reflow
   - Dynamic content loads cause shifts

4. INP 320ms
   - Variant selector triggers expensive re-render cascade
   - Price calculation runs on every keystroke in quantity input

5. Bundle 380KB
   - Full lodash imported
   - Chart library imported synchronously
   - Three.js loaded for a 3D product viewer used by 5% of users

6. Cost: 1,000 serverless invocations per 1K views
   - Every page view is SSR = 1 invocation
   - Product data changes 2-3 times per day, not per request
```

---

## Step 2: Fix Rendering Strategy (Biggest Impact)

### Before: SSR on Every Request

```tsx
// app/products/[id]/page.tsx (BEFORE)
export const dynamic = 'force-dynamic'; // SSR every time

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  // Sequential fetches
  const product = await db.product.findUnique({ where: { id } });
  const reviews = await db.review.findMany({ where: { productId: id } });
  const related = await db.product.findMany({ where: { category: product.category } });
  const stock = await getRealTimeStock(id);

  return (
    <div>
      <ProductHero product={product} />
      <StockIndicator stock={stock} />
      <ReviewList reviews={reviews} />
      <RelatedProducts products={related} />
    </div>
  );
}
```

### After: ISR + PPR + Streaming

```tsx
// app/products/[id]/page.tsx (AFTER)
import { Suspense } from 'react';

// ISR: revalidate every 10 minutes (product changes ~2x/day)
export const revalidate = 600;

// Static params for all published products
export async function generateStaticParams() {
  const products = await db.product.findMany({
    select: { id: true },
    where: { status: 'published' },
  });
  return products.map((p) => ({ id: p.id }));
}

export async function generateMetadata({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await getProductCached(id);
  return {
    title: `${product.name} | Store`,
    description: product.description.slice(0, 160),
    openGraph: { images: [product.image] },
  };
}

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;

  // Cached fetch (included in ISR cache)
  const product = await getProductCached(id);

  return (
    <div>
      {/* Static shell — served from CDN, instant */}
      <ProductHero product={product} />

      {/* Dynamic hole — streamed, small invocation */}
      <Suspense fallback={<StockSkeleton />}>
        <StockIndicator productId={id} />
      </Suspense>

      {/* Cached — included in ISR */}
      <Suspense fallback={<ReviewSkeleton />}>
        <ReviewSection productId={id} />
      </Suspense>

      {/* Cached — included in ISR */}
      <RelatedProducts category={product.category} excludeId={id} />
    </div>
  );
}

// Cached product data (deduped across generateMetadata and page)
import { cache } from 'react';

const getProductCached = cache(async (id: string) => {
  return db.product.findUnique({
    where: { id },
    select: {
      id: true,
      name: true,
      description: true,
      price: true,
      image: true,
      category: true,
      // Only select fields needed for the page
    },
  });
});
```

### Impact of This Change Alone

| Metric | Before | After |
|:-------|:-------|:------|
| TTFB | 1.8s | 50ms (CDN) |
| Serverless invocations/1K | 1,000 | ~7 (revalidations) |
| Cost per 10K views | ~$0.50 | ~$0.005 |

---

## Step 3: Fix Images (Second Biggest Impact)

### Before: Raw `<img>` Tag

```tsx
// BAD: 2.4MB JPEG, no optimization
<img src="/uploads/hero-product.jpg" alt="Product" />
// No responsive sizing, no format conversion, no lazy loading control
```

### After: Optimized `next/image`

```tsx
import Image from 'next/image';

<Image
  src={product.image}
  alt={product.name}
  width={1200}
  height={800}
  priority                    // Above fold: load immediately
  sizes="(max-width: 768px) 100vw, (max-width: 1200px) 60vw, 50vw"
  placeholder="blur"
  blurDataURL={product.blurHash} // Smooth loading placeholder
/>
```

```js
// next.config.js — Enable AVIF for maximum compression
module.exports = {
  images: {
    formats: ['image/avif', 'image/webp'],
    deviceSizes: [640, 750, 828, 1080, 1200, 1920],
    imageSizes: [16, 32, 48, 64, 96, 128, 256],
  },
};
```

### Impact

| Metric | Before | After |
|:-------|:-------|:------|
| Hero image size | 2.4MB | 80-150KB (AVIF) |
| Hero image CLS | Yes (no dimensions) | None (width/height set) |
| LCP contribution | ~3s (download + render) | ~0.3s |

---

## Step 4: Fix Bundle Size

### Remove Heavy Dependencies

```bash
# Replace lodash with lodash-es (tree-shakable)
npm uninstall lodash
npm install lodash-es

# Replace moment.js with date-fns
npm uninstall moment
npm install date-fns

# Dynamic import the chart library
# (already done in Step 2 via next/dynamic)
```

### Dynamic Import for Rare Features

```tsx
// BEFORE: Three.js loaded for every visitor (5% use it)
import { ProductViewer3D } from './product-viewer-3d';

// AFTER: Only loaded on demand
import dynamic from 'next/dynamic';

const ProductViewer3D = dynamic(
  () => import('./product-viewer-3d').then((mod) => mod.ProductViewer3D),
  {
    loading: () => <Viewer3DPlaceholder />,
    ssr: false, // Three.js needs browser APIs
  }
);

function ProductPage({ product }: { product: Product }) {
  const [show3D, setShow3D] = useState(false);

  return (
    <div>
      <Image src={product.image} alt={product.name} priority />
      <button onClick={() => setShow3D(true)}>View in 3D</button>
      {show3D && <ProductViewer3D modelUrl={product.model3dUrl} />}
    </div>
  );
}
```

### Impact

| Metric | Before | After |
|:-------|:-------|:------|
| First Load JS | 380 KB | 95 KB |
| Three.js chunk | Included | 0 KB (loaded on demand) |
| lodash | 70 KB | ~5 KB (only used functions) |

---

## Step 5: Fix CLS

### Font Loading

```tsx
// app/layout.tsx
import { Inter } from 'next/font/google';

const inter = Inter({
  subsets: ['latin'],
  display: 'swap',
  variable: '--font-inter',
});

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en" className={inter.variable}>
      <body className={inter.className}>{children}</body>
    </html>
  );
}
```

### Image Dimensions

Already fixed in Step 3 by adding `width` and `height` to `next/image`.

### Dynamic Content

```tsx
// Prevent layout shifts from dynamic content loading
// Give containers explicit minimum heights

<div className="min-h-[200px]"> {/* Prevents CLS when reviews load */}
  <Suspense fallback={<ReviewSkeleton />}>
    <ReviewSection productId={id} />
  </Suspense>
</div>
```

---

## Step 6: Fix INP (Interaction Latency)

### Before: Expensive Re-Renders on Variant Selection

```tsx
// BAD: Selecting a variant re-renders the entire page
function ProductPage({ product }) {
  const [selectedVariant, setSelectedVariant] = useState(product.variants[0]);

  // Expensive computation runs on every variant change
  const pricing = calculatePricing(product, selectedVariant);
  const availability = checkAvailability(product, selectedVariant);
  const shipping = calculateShipping(product, selectedVariant);

  return (
    <div>
      <ProductImage product={product} variant={selectedVariant} />
      <PriceDisplay pricing={pricing} />
      <AvailabilityBadge availability={availability} />
      <ShippingEstimate shipping={shipping} />
      <VariantSelector
        variants={product.variants}
        selected={selectedVariant}
        onChange={setSelectedVariant}
      />
    </div>
  );
}
```

### After: Colocate State, Minimize Re-Renders

```tsx
// GOOD: Only the parts that change re-render
function ProductPage({ product }: { product: Product }) {
  return (
    <div>
      {/* These don't change with variant selection */}
      <ProductImage product={product} />
      <ProductDescription product={product} />

      {/* Only this section re-renders on variant change */}
      <VariantSection product={product} />
    </div>
  );
}

// Isolate the interactive part
function VariantSection({ product }: { product: Product }) {
  const [selectedVariant, setSelectedVariant] = useState(product.variants[0]);

  // React Compiler memoizes these automatically
  const price = product.basePrice + selectedVariant.priceAdjustment;
  const inStock = selectedVariant.stock > 0;

  return (
    <div>
      <PriceDisplay price={price} />
      <AvailabilityBadge inStock={inStock} />
      <VariantSelector
        variants={product.variants}
        selected={selectedVariant}
        onChange={setSelectedVariant}
      />
    </div>
  );
}
```

---

## Step 7: Final Results

### After All Optimizations

| Metric | Before | After | Improvement |
|:-------|:-------|:------|:------------|
| TTFB | 1.8s | 50ms | 97% faster |
| LCP | 4.2s | 0.8s | 81% faster |
| FCP | 2.1s | 0.5s | 76% faster |
| CLS | 0.12 | 0.02 | 83% reduction |
| INP | 320ms | 80ms | 75% faster |
| First Load JS | 380 KB | 95 KB | 75% smaller |
| Serverless/1K views | 1,000 | 7 | 99.3% fewer |
| Cost per 10K views | ~$0.50 | ~$0.005 | 99% cheaper |

### Optimization Priority Recap

| Priority | Optimization | Impact on LCP |
|:---------|:-------------|:--------------|
| 1 | Switch SSR to ISR | -1.6s (TTFB) |
| 2 | Optimize hero image (next/image + AVIF) | -2.2s |
| 3 | Reduce JS bundle (remove lodash, dynamic import Three.js) | -0.5s |
| 4 | Fix CLS (fonts, image dimensions) | N/A (CLS fix) |
| 5 | Fix INP (state colocation) | N/A (INP fix) |

### Cost Savings Summary

| Item | Before | After |
|:-----|:-------|:------|
| Serverless function invocations (100K views/month) | 100,000 | 700 |
| Image optimization (unique images) | Every view | Cached |
| Bandwidth (hero image alone) | 240 GB/month | 8 GB/month |
| Estimated monthly cost (Vercel Pro) | ~$50-80 | ~$20-30 |
