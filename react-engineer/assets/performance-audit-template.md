# React Performance Audit Template

Use this template when conducting a performance audit of a React/Next.js application. Fill in each section with findings and action items.

---

## Audit Metadata

| Field | Value |
|:------|:------|
| **Application** | _[name]_ |
| **URL** | _[production or staging URL]_ |
| **Date** | _[YYYY-MM-DD]_ |
| **Auditor** | _[name]_ |
| **Next.js Version** | _[version]_ |
| **React Version** | _[version]_ |
| **Node.js Version** | _[version]_ |

---

## 1. Bundle Analysis

### Size Metrics

| Metric | Current | Target | Status |
|:-------|:--------|:-------|:-------|
| First Load JS (homepage) | _KB_ | < 100 KB | Pass/Fail |
| First Load JS (average page) | _KB_ | < 150 KB | Pass/Fail |
| Total JS (full app) | _KB_ | < 500 KB | Pass/Fail |
| CSS bundle size | _KB_ | < 50 KB | Pass/Fail |
| Largest single chunk | _KB_ | < 100 KB | Pass/Fail |

### How to Measure

```bash
# Next.js bundle analysis
ANALYZE=true npm run build

# Or install bundle analyzer
npm install @next/bundle-analyzer
```

```js
// next.config.js
const withBundleAnalyzer = require('@next/bundle-analyzer')({
  enabled: process.env.ANALYZE === 'true',
});

module.exports = withBundleAnalyzer({
  // ... config
});
```

### Duplicate Dependencies

```bash
# Check for duplicate packages in bundle
npx duplicate-package-checker-webpack-plugin

# Or check with npm
npx npm-dedupe
```

### Tree-Shaking Verification

- [ ] No named imports from barrel files that pull in everything
- [ ] lodash replaced with lodash-es or individual packages
- [ ] date-fns uses individual function imports
- [ ] icon libraries import only used icons

```tsx
// Bad: imports entire library
import { debounce } from 'lodash';
import { format, parseISO } from 'date-fns';

// Good: imports only what's needed
import debounce from 'lodash/debounce';
import format from 'date-fns/format';
import parseISO from 'date-fns/parseISO';
```

### Findings

| Finding | Severity | Action Item |
|:-------|:---------|:------------|
| _e.g., moment.js adds 70KB_ | High | Replace with date-fns |
| _e.g., three instances of lodash_ | Medium | Dedupe in package.json resolutions |

---

## 2. Render Profiling

### Methodology

Use React DevTools Profiler to record typical user interactions.

### Metrics to Track

| Metric | Description | Target |
|:-------|:------------|:-------|
| Render count (initial load) | Number of component renders on page load | < 3 per component |
| Render duration (initial) | Time to complete initial render tree | < 16ms |
| Wasted renders | Components that render with same output | 0 |
| Long commits | React commits > 50ms | 0 |

### Unnecessary Re-Render Candidates

Check for these patterns:

```tsx
// Pattern 1: Inline object/function in JSX
<Child style={{ margin: 10 }} onClick={() => doSomething()} />
// Fix: hoist or memoize

// Pattern 2: Parent state causing child re-renders
function Parent() {
  const [count, setCount] = useState(0); // changes frequently
  return (
    <div>
      <ExpensiveChild /> {/* re-renders on every count change */}
    </div>
  );
}
// Fix: split into separate components

// Pattern 3: Context value creating new object
<ThemeContext.Provider value={{ theme, setTheme }}>
  {/* All consumers re-render on any value change */}
</ThemeContext.Provider>
// Fix: useMemo on value, or split into separate contexts
```

### React Compiler Status

- [ ] React Compiler is enabled in build config
- [ ] No components opted out with `'use no memo'` without documented reason
- [ ] Compiler errors are addressed (check build output)
- [ ] Components with complex patterns (HOCs, render props) are reviewed

### Findings

| Component | Issue | Render Count | Fix |
|:----------|:------|:-------------|:----|
| _e.g., ProductGrid_ | Re-renders on parent state change | 12 | Push state down |
| _e.g., SearchInput_ | Inline onChange creates new fn each render | 8 | useCallback or compiler |

---

## 3. Network Performance

### Request Waterfalls

Identify sequential request chains:

```
Page Load
  ├── /api/user (200ms)
  │     └── /api/permissions (150ms)  ← Sequential! Should be parallel
  ├── /api/products (300ms)
  │     ├── /api/products/images (200ms)  ← Sequential!
  │     └── /api/products/reviews (180ms)
```

### Targets

| Metric | Target |
|:-------|:-------|
| Time to First Byte (TTFB) | < 200ms |
| API response time (p95) | < 300ms |
| Sequential request chains | 0 (all parallelizable) |
| Duplicate API calls (same data) | 0 |

### Caching Headers

Verify API responses have appropriate cache headers:

```tsx
// Route handler caching
export async function GET() {
  const data = await getData();
  return Response.json(data, {
    headers: {
      'Cache-Control': 'public, s-maxage=60, stale-while-revalidate=300',
    },
  });
}
```

- [ ] Static assets have long-lived cache (`Cache-Control: max-age=31536000, immutable`)
- [ ] API responses have `stale-while-revalidate` where appropriate
- [ ] No cacheable responses missing cache headers
- [ ] Next.js `fetch` cache options are explicit (not relying on defaults)

### Findings

| URL | Issue | Current | Target | Fix |
|:----|:------|:--------|:-------|:----|
| _e.g., /api/products_ | No cache header | Uncached | 60s s-w-r | Add Cache-Control |
| _e.g., /api/user + /api/permissions_ | Sequential fetch | 350ms total | Parallel: 200ms | Promise.all |

---

## 4. Lighthouse Scores and Core Web Vitals

### Lighthouse Scores

| Category | Score | Target |
|:---------|:------|:-------|
| Performance | _score_ | > 90 |
| Accessibility | _score_ | > 95 |
| Best Practices | _score_ | > 95 |
| SEO | _score_ | > 90 |

### Core Web Vitals

| Metric | Current | Target | Status |
|:-------|:--------|:-------|:-------|
| Largest Contentful Paint (LCP) | _ms_ | < 2500ms | Pass/Fail |
| First Input Delay (FID) | _ms_ | < 100ms | Pass/Fail |
| Cumulative Layout Shift (CLS) | _score_ | < 0.1 | Pass/Fail |
| Interaction to Next Paint (INP) | _ms_ | < 200ms | Pass/Fail |
| Time to First Byte (TTFB) | _ms_ | < 800ms | Pass/Fail |

### How to Measure

```bash
# Using Lighthouse CLI
npx lighthouse https://your-app.com --output=json --output-path=./lighthouse-report.json

# Using web-vitals library
npm install web-vitals
```

```tsx
// app/layout.tsx - Report web vitals
export function reportWebVitals(metric: NextWebVitalsMetric) {
  // Send to analytics
  if (metric.label === 'web-vital') {
    console.log(`${metric.name}: ${metric.value}`);
  }
}
```

### Findings

| Metric | Issue | Cause | Fix |
|:-------|:------|:------|:----|
| _e.g., LCP 4.2s_ | Hero image loads late | Unoptimized image | next/image with priority |
| _e.g., CLS 0.25_ | Layout shift on font load | FOUT without size-adjust | font-display: swap + fallback |

---

## 5. Server Components Ratio

### Analysis

| Component Type | Count | Percentage |
|:---------------|:------|:-----------|
| Server Components | _count_ | _%_ |
| Client Components | _count_ | _%_ |
| Target: > 70% Server Components | | |

### How to Check

```bash
# Find all client components
grep -r "'use client'" --include="*.tsx" --include="*.jsx" src/ app/ | wc -l

# Find all server components (files without 'use client')
find app/ -name "*.tsx" | wc -l
```

### Common Mistakes

```tsx
// Mistake: Entire page is a client component
'use client';
export default function ProductsPage() {
  const { data } = useProducts();
  return <ProductGrid products={data} />;
}

// Better: Split into server + client
export default async function ProductsPage() {
  const products = await db.product.findMany();
  return <ProductGrid products={products} />;
}
// ProductGrid can be server too if it doesn't need interactivity
```

### Findings

| Page/Route | Server Components | Client Components | Opportunity |
|:-----------|:------------------|:------------------|:------------|
| _e.g., /products_ | 2 | 5 | Convert 3 to server |

---

## 6. Image Optimization

### Checklist

- [ ] All images use `next/image`
- [ ] Above-fold images have `priority` prop
- [ ] `sizes` prop is set for responsive images
- [ ] `width` and `height` are set to prevent layout shift
- [ ] `placeholder="blur"` for local images
- [ ] AVIF/WebP formats enabled (automatic in Next.js 16)
- [ ] No oversized images (displayed size vs. file size)
- [ ] Background images use CSS, not `<img>` tags

### Image Audit

| Image | Current Size | Display Size | Format | Issue |
|:------|:------------|:-------------|:-------|:------|
| _e.g., hero.jpg_ | 2.4MB | 1200x600 | JPEG | Resize, convert to WebP |
| _e.g., product.png_ | 800KB | 300x300 | PNG | Convert to WebP, compress |

### Code Pattern

```tsx
// Good: optimized image
import Image from 'next/image';

<Image
  src="/hero.jpg"
  alt="Hero image"
  width={1200}
  height={600}
  priority // Above fold
  sizes="100vw"
  placeholder="blur"
  blurDataURL={blurDataUrl}
/>

// Bad: unoptimized image
<img src="/hero.jpg" alt="Hero" />
```

---

## 7. Code Splitting

### Route-Based Splitting

Next.js App Router automatically splits code per route. Verify:

- [ ] Each route loads only its own JavaScript
- [ ] Shared components are in a common chunk
- [ ] No route loads > 100KB of unique JS

### Dynamic Imports for Heavy Components

```tsx
import dynamic from 'next/dynamic';

// Heavy chart component only loads when needed
const Chart = dynamic(() => import('./chart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // If it uses browser APIs
});

// Dialog only loads when opened
const HeavyDialog = dynamic(() => import('./heavy-dialog'));
```

### Split Points Audit

| Component | Size | Lazy Loaded | Should Be |
|:----------|:-----|:------------|:----------|
| _e.g., Chart_ | 200KB | No | Yes (dynamic import) |
| _e.g., RichTextEditor_ | 150KB | No | Yes (dynamic import) |

---

## 8. React Compiler Adoption

### Status

- [ ] Compiler is enabled in build config
- [ ] Build succeeds with compiler enabled
- [ ] No `babel-plugin-react-compiler` errors in build output

### Opt-Out Areas

Document any components that have `'use no memo'` and why:

| File | Reason | Revisit Date |
|:-----|:-------|:-------------|
| _e.g., components/legacy-grid.tsx_ | Complex HOC pattern | 2026-06-01 |

### Manual Memoization Review

Components that still use manual `useMemo`/`useCallback`/`React.memo` with the compiler active should be cleaned up:

| File | Manual Memo | Can Remove? |
|:-----|:------------|:------------|
| _e.g., ProductCard.tsx_ | `React.memo` | Yes (compiler handles it) |
| _e.g., SearchInput.tsx_ | `useCallback` | Yes |

---

## Summary Scorecard

| Category | Score (1-5) | Top Finding |
|:---------|:------------|:------------|
| Bundle Size | _score_ | _finding_ |
| Render Performance | _score_ | _finding_ |
| Network | _score_ | _finding_ |
| Core Web Vitals | _score_ | _finding_ |
| Server Components | _score_ | _finding_ |
| Image Optimization | _score_ | _finding_ |
| Code Splitting | _score_ | _finding_ |
| React Compiler | _score_ | _finding_ |

### Priority Action Items

| Priority | Finding | Effort | Impact |
|:--------|:--------|:-------|:-------|
| 1 | _highest impact fix_ | Low/Med/High | _estimated improvement_ |
| 2 | _next fix_ | Low/Med/High | _estimated improvement_ |
| 3 | _next fix_ | Low/Med/High | _estimated improvement_ |
| 4 | _next fix_ | Low/Med/High | _estimated improvement_ |
| 5 | _next fix_ | Low/Med/High | _estimated improvement_ |
