# Next.js 15 App Router — i18n Reference

> **Purpose:** Implementation-decision reference. Not a tutorial. Last updated: May 2026.

---

## 1. Built-in i18n Support: App Router vs Pages Router

### Pages Router (legacy)
`next.config.js` accepted an `i18n` block with `locales`, `defaultLocale`, and `domains`. Next.js handled routing, redirects, and the `useRouter().locale` value automatically.

```js
// next.config.js (Pages Router only)
module.exports = {
  i18n: {
    locales: ['en-US', 'fr', 'de'],
    defaultLocale: 'en-US',
  },
}
```

### App Router (current)
**The `i18n` config block is not supported in App Router.** Vercel deliberately removed it to give developers full control via middleware and dynamic segments. There is no built-in locale detection, routing, or `useRouter().locale`.

You implement i18n manually using:
1. A `[locale]` dynamic segment: `app/[locale]/layout.tsx`
2. Middleware to detect and redirect based on locale
3. A translation loading strategy (roll your own or use a library)

This is more work upfront but offers more flexibility and better compatibility with Server Components.

---

## 2. Recommended Approaches for App Router

### Option A: Manual (No Library)
Vercel's own recommendation in the docs:

1. Middleware detects locale from `Accept-Language` header
2. Redirect/rewrite to `/[locale]/path`
3. `getDictionary(locale)` loads JSON translation files server-side
4. Pass dict to Server Components as props

**When to use:** Simple apps, few locales, no pluralization or date formatting needs.

```ts
// app/[lang]/dictionaries.ts
import 'server-only'

const dictionaries = {
  en: () => import('./dictionaries/en.json').then(m => m.default),
  fr: () => import('./dictionaries/fr.json').then(m => m.default),
}

export const getDictionary = async (locale: keyof typeof dictionaries) =>
  dictionaries[locale]()
```

### Option B: next-intl (Recommended for Most Projects)
Purpose-built for Next.js App Router. Best balance of DX, SSR support, and ecosystem maturity.

- Server Components work without `use client`
- Middleware handles locale detection out of the box
- Handles translations, pluralization, date/number formatting
- ~4KB gzipped (~457B server-only path)
- TypeScript-first

```ts
// Server Component (no 'use client' needed)
import { getTranslations } from 'next-intl/server'

export default async function Page() {
  const t = await getTranslations('HomePage')
  return <h1>{t('title')}</h1>
}
```

### Option C: Paraglide-JS (Best Performance)
Compile-time code generation. Messages become typed functions, not runtime lookups.

```ts
import * as m from '@/paraglide/messages'
// m.someKey() — compiler-verified, no runtime cost
```

- ~1KB per locale (tree-shaken)
- No hooks required, works anywhere including RSC
- Part of the inlang ecosystem (translation management tooling)
- Tradeoff: code generation step in CI/CD, younger ecosystem

### Option D: react-i18next / i18next
Framework-agnostic, largest ecosystem, most community knowledge.

- **Problem:** `useTranslation` hook requires `use client`
- Workaround: `createInstance` pattern for Server Components, but verbose
- Best for: migrating existing i18next codebases, React Native parity, or teams with deep i18next familiarity

### Option E: LinguiJS
Compile-time translation extraction via JSX macros.

```tsx
import { Trans } from '@lingui/react/macro'
<Trans>Add to Cart</Trans>
```

- ~3KB gzipped, build-time validation catches missing translations
- Tradeoff: Babel/SWC plugin required, extraction → translation → compile CI cycle

---

## 3. URL Strategies

### Path Prefix (Most Common)
```
/en/products
/fr/products
/de/products
```
- Easiest to implement
- SEO-friendly (distinct URLs per locale)
- Default locale can be unprefixed (e.g., `/products` = English) — requires careful middleware logic to avoid redirect loops
- next-intl supports both `always` (always prefix) and `as-needed` (omit for default) modes

### Domain-Based
```
example.com      → en
example.fr       → fr
example.de       → de
```
- Strongest geo/locale signal, best for brand reasons
- Requires DNS + TLS per domain
- next-intl supports this via `domains` config in `routing.ts`

### Subdomain
```
en.example.com
fr.example.com
```
- Simpler DNS than full domains
- Same CORS/cookie considerations as domain-based

### Cookie/Header Only (No URL Change)
- Not recommended for SEO (no distinct URLs per locale)
- Acceptable for apps behind authentication where indexability doesn't matter
- Avoids redirect overhead

---

## 4. Locale Detection from Browser

Detection priority order (next-intl default, generally applicable):

1. **URL pathname** — `/fr/about` → `fr`
2. **Cookie** — previously stored preference from locale switch
3. **`Accept-Language` header** — browser preference
4. **Default locale** — fallback

### Accept-Language Matching
Use `@formatjs/intl-localematcher` + `negotiator` for best-fit matching:

```ts
import { match } from '@formatjs/intl-localematcher'
import Negotiator from 'negotiator'

function getLocale(request: Request): string {
  const headers = { 'accept-language': request.headers.get('accept-language') ?? '' }
  const languages = new Negotiator({ headers }).languages()
  const locales = ['en-US', 'fr', 'de']
  return match(languages, locales, 'en-US') // 'best fit' algorithm
}
```

**`best fit` vs `lookup`:** `best fit` handles regional variants (e.g., `en-GB` → `en-US` if only `en-US` available). `lookup` is exact-match only. Use `best fit` unless you explicitly need strict matching.

### Middleware Example (Manual)

```ts
// middleware.ts
import { NextResponse } from 'next/server'
import { match } from '@formatjs/intl-localematcher'
import Negotiator from 'negotiator'

const locales = ['en', 'fr', 'de']
const defaultLocale = 'en'

function getLocale(req: Request) {
  const headers = { 'accept-language': req.headers.get('accept-language') ?? '' }
  const languages = new Negotiator({ headers }).languages()
  return match(languages, locales, defaultLocale)
}

export function middleware(request: Request) {
  const { pathname } = new URL(request.url)
  const hasLocale = locales.some(l => pathname.startsWith(`/${l}/`) || pathname === `/${l}`)
  if (hasLocale) return

  const locale = getLocale(request)
  return NextResponse.redirect(new URL(`/${locale}${pathname}`, request.url))
}

export const config = {
  matcher: ['/((?!_next|api|favicon.ico).*)'],
}
```

---

## 5. SSR + Client Hydration with Locale

### The Hydration Problem
Hydration mismatches occur when server-rendered HTML differs from what the client renders. Common i18n triggers:

| Cause | Solution |
|-------|----------|
| **Timezone mismatch** — server renders UTC, client uses local TZ | Pin timezone in config; use ISO strings; defer formatting to `useEffect` |
| **Date/number formatting** — `Intl.DateTimeFormat` output differs per environment | Use `timeZone: 'UTC'` on server; reformat on client |
| **RTL/LTR layout** — dynamic `dir` attribute | Set `dir` in root layout from server-known locale |
| **Stale locale in client** — client reads different cookie than server used | Ensure middleware and client read same source of truth |

### next-intl Hydration Strategy
next-intl uses `setRequestLocale()` (backed by React `cache()`) to propagate locale through the Server Component tree without header access, enabling static rendering.

```ts
// app/[locale]/layout.tsx
import { setRequestLocale } from 'next-intl/server'

export default async function Layout({ children, params }) {
  const { locale } = await params
  setRequestLocale(locale) // enables static rendering
  return <html lang={locale}>{children}</html>
}
```

Without `setRequestLocale`, every route becomes dynamically rendered (opts out of static caching).

### Static Generation with Locales
Use `generateStaticParams` to pre-render all locale variants:

```ts
export async function generateStaticParams() {
  return ['en', 'fr', 'de'].map(locale => ({ locale }))
}
```

This creates `/en/about`, `/fr/about`, `/de/about` at build time.

### Timezone Fix
Always configure timezone explicitly to avoid server/client divergence:

```ts
// i18n/request.ts (next-intl)
export default getRequestConfig(async ({ locale }) => ({
  messages: (await import(`../messages/${locale}.json`)).default,
  timeZone: 'UTC', // or derive from user profile/geolocation
}))
```

---

## 6. Library Comparison

| Library | RSC Support | Bundle (gzip) | App Router DX | Lock-in | Notes |
|---------|-------------|---------------|---------------|---------|-------|
| **next-intl** | Native | ~4KB (~457B server) | Excellent | Next.js only | Best default choice for App Router |
| **Paraglide-JS** | Native | ~1KB/locale | Excellent | inlang ecosystem | Best perf; typed functions; younger ecosystem |
| **LinguiJS** | Native | ~3KB | Good | None | Build-time extraction; CI complexity |
| **react-i18next** | Workaround | ~6KB | Fair | None | Largest ecosystem; verbose RSC setup |
| **react-intl (FormatJS)** | Partial | ~20KB+ | Fair | None | Full ICU; hooks require `use client` |
| **next-i18next** | No (Pages Router) | ~658B | N/A | Next.js | Pages Router only; do not use with App Router |
| **Intlayer** | Native | ~5KB | Good | None | AI-assisted translation; newer |

### Decision Matrix

```
New Next.js App Router project?
├── Yes → next-intl (default) or Paraglide (if perf-critical)
└── No / cross-framework?
    ├── React + React Native parity → react-i18next
    ├── Type-safety priority → Paraglide or typesafe-i18n
    └── Full ICU formatting needs → FormatJS / react-intl
```

---

## 7. Project Structure (next-intl Reference)

```
src/
├── app/
│   └── [locale]/
│       ├── layout.tsx        # setRequestLocale(); html lang attr
│       ├── page.tsx
│       └── ...
├── i18n/
│   ├── routing.ts            # locales, defaultLocale config
│   ├── navigation.ts         # locale-aware Link, useRouter wrappers
│   └── request.ts            # getRequestConfig — loads messages
├── messages/
│   ├── en.json
│   ├── fr.json
│   └── de.json
└── middleware.ts             # locale detection + redirect
```

---

## 8. SEO Considerations

- Set `<html lang={locale}>` in root layout
- Add `hreflang` alternate links in `<head>` for all locale variants
- Use path-prefix or domain URLs (not cookie-only) for crawlability
- `generateStaticParams` ensures all locale routes are pre-rendered and indexable

```tsx
// Hreflang in metadata (next-intl)
export async function generateMetadata({ params }) {
  const { locale } = await params
  return {
    alternates: {
      canonical: `/${locale}`,
      languages: { 'en': '/en', 'fr': '/fr', 'de': '/de' },
    },
  }
}
```

---

## 9. Performance at Scale (10+ Locales)

- **Lazy-load by namespace**: Don't import all locale JSONs statically; use dynamic imports per route
- **Namespace segmentation**: Split `messages/en.json` into `en/common.json`, `en/checkout.json`, etc.
- **Avoid layout-level loading**: Load translations in leaf Server Components, not root layout (prevents cache invalidation cascade)
- **Edge middleware**: Run locale detection at the edge (Vercel Edge Runtime) to minimize redirect latency

Real-world gains from namespace segmentation + lazy loading (100+ locales):
- SSR time: 450–800ms → 80–150ms
- Server bundle: 30–50MB → 5–8MB

---

## Sources

- [Next.js App Router i18n Guide](https://nextjs.org/docs/app/guides/internationalization)
- [next-intl Docs](https://next-intl.dev/docs)
- [next-intl Routing Setup](https://next-intl.dev/docs/routing/setup)
- [next-intl Middleware](https://next-intl.dev/docs/routing/middleware)
- [Best i18n Libraries for Next.js 2026 — DEV Community](https://dev.to/erayg/best-i18n-libraries-for-nextjs-react-react-native-in-2026-honest-comparison-3m8f)
- [next-intl vs i18next vs Lingui 2026 — BuildPilot](https://trybuildpilot.com/910-next-intl-vs-i18next-vs-lingui-2026)
- [Most Popular React Localization Libraries — SimpleLocalize](https://simplelocalize.io/blog/posts/the-most-popular-react-localization-libraries/)
- [App Router i18n at Scale — GeekyAnts](https://geekyants.com/blog/architecture-for-nextjs-app-router-i18n-at-scale-fixing-100-locale-ssr-bottlenecks)
- [Hydration Timezone Fix — The Code Forge](https://thecodeforge.io/javascript/fix-next-js-hydration-errors/)
- [Complete Guide to i18n with next-intl — DEV Community](https://dev.to/mukitaro/a-complete-guide-to-i18n-in-nextjs-15-app-router-with-next-intl-supporting-8-languages-1lgj)
