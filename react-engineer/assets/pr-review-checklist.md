# PR Review Checklist for React/Next.js

Use this checklist when reviewing React/Next.js pull requests. Check each item before approving.

---

## Server/Client Boundary

- [ ] `'use client'` only on components that need it (hooks, event handlers, browser APIs)
- [ ] Server Components used for data fetching and static content
- [ ] Client boundary pushed down to the smallest possible component
- [ ] No server-only code leaking into client bundles (`fs`, `db`, non-`NEXT_PUBLIC_` env vars)
- [ ] Props passed from server to client are serializable (no functions, no class instances)

```tsx
// Red flag: entire page is a client component unnecessarily
'use client'; // Does this whole page need to be a client component?
export default function ProductPage() { ... }

// Better: only the interactive part is a client component
export default async function ProductPage() {
  const product = await getProduct(); // Server-side fetch
  return <InteractiveProductView product={product} />; // Client component
}
```

---

## Hydration

- [ ] No `Date.now()`, `Math.random()`, or `new Date()` in Server Component render
- [ ] No `window` or `document` access outside of `useEffect` or event handlers
- [ ] Client state initializes with safe defaults (not browser-dependent values)
- [ ] `suppressHydrationWarning` only used intentionally and documented

```tsx
// Red flag: hydration mismatch
function Clock() {
  const [time, setTime] = useState(new Date().toLocaleTimeString());
  // Server and client times differ -> hydration mismatch

  // Fix: initialize in useEffect
  const [time, setTime] = useState('');
  useEffect(() => {
    setTime(new Date().toLocaleTimeString());
    const interval = setInterval(() => setTime(new Date().toLocaleTimeString()), 1000);
    return () => clearInterval(interval);
  }, []);
}
```

---

## Bundle Impact

- [ ] No new heavy dependencies added without justification
- [ ] Dynamic imports used for large components used conditionally
- [ ] Check bundle size delta: `ANALYZE=true npm run build` before and after
- [ ] No full library imports where individual imports suffice

```bash
# Quick bundle size check
npm run build 2>&1 | grep "First Load JS"

# If First Load JS increased by > 10KB, investigate
```

---

## Performance

- [ ] No unnecessary re-renders (new object/function refs in JSX for memoized children)
- [ ] Heavy computations are memoized or handled by React Compiler
- [ ] Images use `next/image` with `width`, `height`, and `sizes`
- [ ] Above-fold images have `priority` prop
- [ ] No `useEffect` for data fetching when Server Components suffice
- [ ] Suspense boundaries for slow data loading

---

## SEO (for public-facing pages)

- [ ] Unique `<title>` and `meta description` via `generateMetadata` or `metadata` export
- [ ] Open Graph and Twitter card metadata set
- [ ] Canonical URL specified for pages with multiple URL paths
- [ ] Structured data (JSON-LD) for products, articles, or other schema types
- [ ] `robots.txt` and `sitemap.xml` updated if new public routes added
- [ ] Semantic HTML used (`<article>`, `<nav>`, `<main>`, `<h1>`-`<h6>`)
- [ ] Server Components used for SEO-critical content (not client-only rendering)

---

## State Management

- [ ] Navigation-affecting state is in URL params (filters, pagination, tabs, sort)
- [ ] Server data managed by TanStack Query or React cache (not useState + useEffect)
- [ ] Global UI state in Zustand/Redux (not scattered Context providers)
- [ ] Local form state in useState (not in global store)
- [ ] No state duplication (same data in multiple stores)

---

## Security

- [ ] Server Actions validate all inputs with Zod
- [ ] Server Actions check authentication before mutations
- [ ] No sensitive data in client-visible code (API keys, secrets in `NEXT_PUBLIC_`)
- [ ] No `dangerouslySetInnerHTML` without sanitization
- [ ] No user-controlled data in redirect URLs without validation
- [ ] SQL/ORM queries use parameterized inputs (no string interpolation)

---

## Accessibility

- [ ] Interactive elements are `<button>` or `<a>` (not `<div onClick>`)
- [ ] Form inputs have associated `<label>` elements
- [ ] Icon-only buttons have `aria-label`
- [ ] Error messages linked to inputs via `aria-describedby`
- [ ] Modal/dialog has focus trap and proper ARIA roles
- [ ] Color is not the only indicator of state
- [ ] Keyboard navigation works (tab order, Enter/Space activation)

---

## Testing

- [ ] New components have unit tests
- [ ] Server Actions have validation tests
- [ ] Critical user flows have E2E tests (if applicable)
- [ ] Tests cover error states and edge cases, not just happy path

---

## Error Handling

- [ ] `error.tsx` boundary exists for route segments with Server Components
- [ ] `loading.tsx` exists for routes with async data
- [ ] `not-found.tsx` for dynamic routes
- [ ] API routes return proper status codes (400, 401, 404, 500)
- [ ] Server Actions return typed error objects
- [ ] No uncaught promise rejections

---

## Migration-Specific (if applicable)

- [ ] `params` and `searchParams` are awaited (Next.js 15+/16)
- [ ] No `getServerSideProps` or `getStaticProps` (Pages Router APIs in App Router)
- [ ] No `router.query` (App Router uses `useSearchParams`)
- [ ] No `next/router` imports (use `next/navigation` for App Router)
- [ ] `fetch` calls have explicit `cache` or `next.revalidate` options

---

## Quick Red Flags

These always warrant a closer look:

| Pattern | Issue |
|:--------|:------|
| `'use client'` at top of page.tsx | Probably should be a Server Component |
| `useEffect` for data fetching | Use Server Component or TanStack Query |
| `useContext` with large objects | Consider Zustand or narrower context |
| `any` in TypeScript | Replace with proper types |
| `@ts-ignore` or `@ts-expect-error` | Fix the type error, don't suppress it |
| Inline `new Date()` in render | Hydration mismatch risk |
| `fetch` without cache option | Implicit behavior differs between Next.js versions |
| Dynamic `import()` without `next/dynamic` | Missing loading state |
