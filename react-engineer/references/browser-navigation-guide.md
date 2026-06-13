# Browser Navigation, Deep Linking, History Management & Back-Button Handling

The definitive reference for React/Next.js applications. Covers the modern Navigation API, legacy History API, framework-specific patterns, and every pitfall you will encounter.

---

## Table of Contents

1. [Navigation API (Modern)](#1-navigation-api-modern-replacement-for-history-api)
2. [History API (Legacy)](#2-history-api-legacy-but-still-needed)
3. [Deep Linking Patterns](#3-deep-linking-patterns)
4. [Back-Button Handling](#4-back-button-handling)
5. [Scroll Restoration](#5-scroll-restoration)
6. [Next.js App Router Navigation](#6-nextjs-app-router-navigation)
7. [Programmatic Navigation Patterns](#7-programmatic-navigation-patterns)
8. [Common Pitfalls and Solutions](#8-common-pitfalls-and-solutions)
9. [Testing Checklist](#9-testing-checklist)

---

## 1. Navigation API (Modern Replacement for History API)

The Navigation API is a ground-up replacement for the History API, designed specifically for single-page applications. It provides a centralized event model, proper async handling, abort signals, and scroll/focus management.

### Browser Support

| Browser | Minimum Version |
|---------|----------------|
| Chrome | 102+ |
| Edge | 102+ |
| Firefox | 147+ |
| Safari | 26.2+ |

For frameworks like Next.js and React Router, you typically do NOT use the Navigation API directly -- the router abstracts it. But understanding it is essential for debugging, custom routing, and building your own router.

### The Centralized "navigate" Event

The core insight: ALL navigations flow through a single `"navigate"` event on the global `navigation` object. This includes link clicks, form submissions, back/forward, `location.assign()`, `history.pushState()`, and programmatic calls.

```typescript
// Basic SPA router using the Navigation API
navigation.addEventListener('navigate', (navigateEvent) => {
  // Decide whether to intercept this navigation
  if (!navigateEvent.canIntercept) return;
  if (navigateEvent.hashChange) return;       // let browser handle anchor scrolling
  if (navigateEvent.downloadRequest) return;   // let browser handle downloads
  if (navigateEvent.formData) return;          // let server handle POST (or intercept below)

  const url = new URL(navigateEvent.destination.url);

  navigateEvent.intercept({
    async handler() {
      // Your SPA routing logic here
      await renderRoute(url.pathname);
    },
  });
});
```

### navigateEvent Properties Reference

```typescript
interface NavigateEvent extends Event {
  // Can you call intercept() on this? False for cross-origin navigations.
  canIntercept: boolean;

  // The destination of this navigation
  destination: {
    url: string;
    key: string | null;
    index: number;
    sameDocument: boolean;
    getState(): unknown;
  };

  // True if only the hash fragment changed (same document)
  hashChange: boolean;

  // True if initiated by a link with download attribute
  downloadRequest: string | null;

  // Present if this is a form submission (FormData object)
  formData: FormData | null;

  // "push" | "replace" | "reload" | "traverse"
  navigationType: NavigationNavigationType;

  // AbortSignal -- fires when navigation is superseded or user hits Stop
  signal: AbortSignal;

  // Can you call preventDefault()? False for back/forward (traverse).
  canTransition: boolean;

  // User-provided info from navigate() call (undefined for back/forward)
  info: unknown;
}
```

### intercept() vs preventDefault()

```typescript
navigation.addEventListener('navigate', (navigateEvent) => {
  // intercept() -- handle the navigation yourself (SPA-style)
  // The browser changes the URL, then calls your handler.
  navigateEvent.intercept({
    handler: async () => {
      await loadPage(navigateEvent.destination.url);
    },
    scroll: 'auto',     // 'auto' (default) or 'manual'
    focusReset: 'auto',  // 'auto' (default) or 'manual'
  });

  // preventDefault() -- cancel the navigation entirely
  // WARNING: Cannot cancel "traverse" (back/forward) navigations!
  // navigateEvent.preventDefault();
});
```

**Critical rule:** `preventDefault()` does NOT work for back/forward (traverse) navigations. You cannot trap users on your page.

### Abort Signals for In-Flight Work

The `navigateEvent.signal` is an `AbortSignal` that fires when:
1. The user clicks another link (old navigation is cancelled)
2. The user clicks the browser's Stop button
3. Another programmatic navigation occurs

```typescript
navigation.addEventListener('navigate', (navigateEvent) => {
  if (shouldNotIntercept(navigateEvent)) return;

  const url = new URL(navigateEvent.destination.url);

  navigateEvent.intercept({
    async handler() {
      try {
        // Pass the signal to fetch -- request is cancelled if navigation is preempted
        const response = await fetch(`/api/page-data${url.pathname}`, {
          signal: navigateEvent.signal,
        });
        const data = await response.json();
        renderPage(data);
      } catch (err) {
        if (err instanceof DOMException && err.name === 'AbortError') {
          // Navigation was superseded -- clean up, do not update DOM
          return;
        }
        throw err; // re-throw real errors
      }
    },
  });
});
```

### Navigation Entries and the `key` Property

```typescript
// Current entry (where the user is right now)
const current = navigation.currentEntry;
console.log(current.url);       // full URL
console.log(current.key);       // unique key for this slot in history
console.log(current.index);     // position in history entries
console.log(current.getState()); // developer-provided state

// All entries the user has visited
const entries = navigation.entries();
entries.forEach((entry, i) => {
  console.log(`[${i}] ${entry.url} key=${entry.key}`);
});

// The key persists even if the URL changes via replaceState.
// If the user goes back then forward to the same URL, key changes (new slot).
// Use key to jump to specific entries:
const homeKey = navigation.entries()[0].key;
homeButton.onclick = () => navigation.traverseTo(homeKey);
```

### State Management

```typescript
// Navigate WITH state (like pushState but better)
navigation.navigate('/dashboard', {
  state: { from: 'sidebar', expandedSection: 'analytics' },
  history: 'push',  // 'push' (default) or 'replace'
  info: { animation: 'slide-left' },  // passed to navigate event, NOT persisted
});

// Read state from the current entry
const state = navigation.currentEntry.getState() as DashboardState | undefined;

// Update state on the current entry without navigating
navigation.updateCurrentEntry({
  state: { ...navigation.currentEntry.getState(), scrollY: 500 },
});

// Replace current entry state (triggers navigate event)
navigation.navigate(location.href, {
  state: newState,
  history: 'replace',
});
```

**State vs URL params rule of thumb:**
- If the user would share the URL and expect state to be preserved, put it in the URL.
- If it's ephemeral (scroll position, UI toggles, animation direction), use state.
- `info` is fire-and-forget: it reaches the `navigate` event handler but is NOT replayed on back/forward (always `undefined` for traverse).

### Events: navigatesuccess, navigateerror, currententrychange

```typescript
// Fires when intercept handler resolves successfully
navigation.addEventListener('navigatesuccess', () => {
  loadingSpinner.hidden = true;
});

// Fires when intercept handler rejects or navigation fails
navigation.addEventListener('navigateerror', (event: ErrorEvent) => {
  loadingSpinner.hidden = true;
  showErrorToast(`Navigation failed: ${event.message}`);
  // This catches ALL errors from your intercept handlers --
  // network failures, rendering errors, etc.
});

// Fires when currentEntry changes (after navigate, back, forward, traverseTo)
navigation.addEventListener('currententrychange', () => {
  analytics.track('page_view', {
    url: navigation.currentEntry.url,
    state: navigation.currentEntry.getState(),
  });
});
```

### Programmatic Navigation Methods

```typescript
// All return { committed: Promise<void>, finished: Promise<void> }

// Navigate to a new URL (pushes onto history stack)
const { committed, finished } = navigation.navigate('/products/42');
await committed;  // URL has changed, new entry exists
await finished;   // intercept handler has completed

// Replace current entry
navigation.navigate('/login', { history: 'replace' });

// Go back one entry
navigation.back();

// Go forward one entry
navigation.forward();

// Jump to a specific entry by key
const targetEntry = navigation.entries().find(e => e.url.includes('/settings'));
if (targetEntry) {
  navigation.traverseTo(targetEntry.key);
}

// Reload current page
navigation.reload({ state: { refreshedAt: Date.now() } });
```

### The `committed` and `finished` Promises

```typescript
async function safeNavigate(url: string) {
  try {
    const { committed, finished } = navigation.navigate(url);

    // committed resolves when the URL bar has updated
    await committed;
    console.log('URL updated, new history entry created');

    // finished resolves when all intercept handlers complete
    await finished;
    console.log('Page fully loaded and rendered');
  } catch (err) {
    if (err instanceof Error) {
      // Navigation was cancelled or handler threw
      console.error('Navigation failed:', err.message);
    }
  }
}
```

### Form Submission Handling

```typescript
navigation.addEventListener('navigate', (navigateEvent) => {
  if (!navigateEvent.formData || !navigateEvent.canIntercept) return;

  // Intercept POST form submissions for SPA-style handling
  navigateEvent.intercept({
    focusReset: 'manual',  // don't steal focus
    scroll: 'manual',      // don't reset scroll
    async handler() {
      const response = await fetch(navigateEvent.destination.url, {
        method: 'POST',
        body: navigateEvent.formData,
        signal: navigateEvent.signal,
      });

      if (response.ok) {
        const result = await response.json();
        // Navigate to success page, replacing the form entry
        navigation.navigate(`/success/${result.id}`, {
          history: 'replace',
        });
      } else {
        showFormError(await response.text());
      }
    },
  });
});
```

### Full SPA Router Example

```typescript
// A complete (but minimal) SPA router using the Navigation API
type RouteHandler = (params: Record<string, string>) => Promise<void>;

interface Route {
  pattern: RegExp;
  handler: RouteHandler;
  paramNameList: string[];
}

function createRouter(routes: Map<string, RouteHandler>) {
  const compiledRoutes: Route[] = [];

  for (const [pattern, handler] of routes) {
    const paramNames: string[] = [];
    const regexStr = pattern.replace(
      /:([^/]+)/g,
      (_, name) => {
        paramNames.push(name);
        return '([^/]+)';
      }
    );
    compiledRoutes.push({
      pattern: new RegExp(`^${regexStr}$`),
      handler,
      paramNameList: paramNames,
    });
  }

  function matchRoute(pathname: string): { handler: RouteHandler; params: Record<string, string> } | null {
    for (const route of compiledRoutes) {
      const match = pathname.match(route.pattern);
      if (match) {
        const params: Record<string, string> = {};
        route.paramNameList.forEach((name, i) => {
          params[name] = match[i + 1];
        });
        return { handler: route.handler, params };
      }
    }
    return null;
  }

  // Centralized navigate listener
  navigation.addEventListener('navigate', (navigateEvent) => {
    if (!navigateEvent.canIntercept || navigateEvent.hashChange) return;

    const url = new URL(navigateEvent.destination.url);
    const result = matchRoute(url.pathname);

    if (!result) return; // let browser handle 404 or external

    navigateEvent.intercept({
      async handler() {
        await result.handler(result.params);
      },
    });
  });

  // Handle initial page load (navigate event does NOT fire for first load)
  const initialUrl = new URL(location.href);
  const initialMatch = matchRoute(initialUrl.pathname);
  if (initialMatch) {
    initialMatch.handler(initialMatch.params);
  }
}

// Usage
createRouter(new Map([
  ['/', async () => renderHome()],
  ['/products', async () => renderProductList()],
  ['/products/:id', async (params) => renderProduct(params.id)],
  ['/categories/:category/products/:productId', async (params) => {
    renderProductInCategory(params.category, params.productId);
  }],
]));
```

---

## 2. History API (Legacy but Still Needed)

The History API has been the backbone of SPA routing since the mid-2010s. Every framework still uses it under the hood. You need to understand it even if you use the Navigation API or a framework router.

### Core Methods

```typescript
// Push a new entry onto the history stack
// URL changes but page does not reload
window.history.pushState(state, unused, url);

// Replace the current entry (no new history entry created)
window.history.replaceState(state, unused, url);

// Go back/forward by a delta
window.history.go(-1);  // back
window.history.go(1);   // forward
window.history.go(0);   // reload
window.history.back();   // shorthand for go(-1)
window.history.forward(); // shorthand for go(1)

// Properties
window.history.length;  // total entries in history stack
window.history.state;   // state of current entry (what you passed to pushState)
window.history.scrollRestoration; // 'auto' | 'manual'
```

### The popstate Event

```typescript
// This is the ONLY event the History API fires, and it ONLY fires for:
// - Back/forward navigation (user clicks browser buttons)
// - history.go(), history.back(), history.forward()
//
// It does NOT fire for pushState or replaceState!
window.addEventListener('popstate', (event) => {
  console.log(event.state); // the state object you passed to pushState
  const url = location.href;
  renderRoute(url);
});
```

### Why the History API is Problematic

```typescript
// PROBLEM 1: No centralized event for pushState/replaceState
// If any code calls pushState, you won't know about it unless you
// monkey-patch it:
const originalPushState = history.pushState.bind(history);
history.pushState = function (state, unused, url) {
  originalPushState(state, unused, url);
  window.dispatchEvent(new CustomEvent('pushstate', { detail: { state, url } }));
};

// PROBLEM 2: popstate fires AFTER the URL has already changed
// By the time you handle it, the browser may have already scrolled
window.addEventListener('popstate', (event) => {
  // Too late to preventDefault -- URL already changed
  // Must handle state restoration reactively
});

// PROBLEM 3: state must be serializable (structuredClone-compatible)
// Cannot store functions, DOM nodes, Symbols, etc.
history.pushState(
  { selectedIds: new Set([1, 2, 3]) },  // THROWS in some browsers!
  '',
  '/products'
);

// PROBLEM 4: No way to enumerate history entries
// history.length tells you the count but not the URLs or states
// Navigation API fixes this with navigation.entries()

// PROBLEM 5: Scroll restoration is unreliable
// Browsers handle this inconsistently
```

### When to Use History API vs Navigation API

| Scenario | Use History API | Use Navigation API |
|----------|----------------|-------------------|
| Framework handles routing (Next.js, React Router) | Never (framework abstracts it) | Never (framework abstracts it) |
| Custom SPA router | Only if you need IE11 support | Preferred |
| Shallow URL update without re-render | Yes (pushState/replaceState) | Yes (navigate with intercept skipping) |
| Listening for back/forward | popstate event | "navigate" event |
| Enumerating history entries | Impossible | navigation.entries() |
| Shared code with older browsers | Yes | Feature-detect and fall back |

### Feature Detection

```typescript
// Use Navigation API where available, fall back to History API
function navigate(url: string, state?: unknown) {
  if ('navigation' in window) {
    navigation.navigate(url, { state });
  } else {
    history.pushState(state, '', url);
    // Must manually trigger route change since pushState fires no events
    handleRouteChange(url, state);
  }
}

function goBack() {
  if ('navigation' in window) {
    navigation.back();
  } else {
    history.back();
  }
}
```

---

## 3. Deep Linking Patterns

Deep linking means a URL encodes the full application state needed to recreate a view. When a user shares or bookmarks a URL, it should "just work."

### URL Search Params as Application State

```typescript
// BAD: State lives only in React state, lost on refresh
function ProductFilter() {
  const [category, setCategory] = useState('');
  const [sort, setSort] = useState('name');
  const [page, setPage] = useState(1);

  // User filters to "Electronics", sorts by price, goes to page 3
  // They copy the URL and share it -- the recipient sees the DEFAULT view
}

// GOOD: State lives in the URL, synchronized with React state
import { useSearchParams, useRouter } from 'next/navigation';

function ProductFilter() {
  const router = useRouter();
  const searchParams = useSearchParams();

  // Derive state from URL
  const category = searchParams.get('category') ?? '';
  const sort = searchParams.get('sort') ?? 'name';
  const page = Number(searchParams.get('page') ?? '1');

  function updateFilters(updates: Record<string, string>) {
    const params = new URLSearchParams(searchParams.toString());
    for (const [key, value] of Object.entries(updates)) {
      if (value === '' || value === undefined) {
        params.delete(key);
      } else {
        params.set(key, value);
      }
    }
    // Using pushState for shallow update (no full re-render of layout)
    window.history.pushState(null, '', `?${params.toString()}`);
  }

  return (
    <div>
      <select
        value={category}
        onChange={(e) => updateFilters({ category: e.target.value })}
      >
        <option value="">All Categories</option>
        <option value="electronics">Electronics</option>
        <option value="clothing">Clothing</option>
      </select>

      <select
        value={sort}
        onChange={(e) => updateFilters({ sort: e.target.value, page: '1' })}
      >
        <option value="name">Name</option>
        <option value="price">Price</option>
      </select>

      <ProductList category={category} sort={sort} page={page} />
    </div>
  );
}
```

### Complex State Encoding Patterns

```typescript
// Pattern 1: JSON-encoded state in a single query param
function useFilterState<T>(key: string, defaultValue: T) {
  const searchParams = useSearchParams();
  const encoded = searchParams.get(key);
  const value = encoded ? JSON.parse(decodeURIComponent(encoded)) : defaultValue;

  const setValue = (newValue: T) => {
    const params = new URLSearchParams(searchParams.toString());
    params.set(key, encodeURIComponent(JSON.stringify(newValue)));
    window.history.pushState(null, '', `?${params.toString()}`);
  };

  return [value, setValue] as const;
}

// Usage: deeply nested filter state in a single param
const [filters, setFilters] = useFilterState('f', {
  priceRange: [0, 500],
  brands: ['nike', 'adidas'],
  inStock: true,
});
// Produces: ?f=%7B%22priceRange%22%3A%5B0%2C500%5D%2C...

// Pattern 2: Individual params for flat state
function buildUrl(params: Record<string, string | number | boolean | undefined>) {
  const sp = new URLSearchParams();
  for (const [key, val] of Object.entries(params)) {
    if (val !== undefined && val !== '') {
      sp.set(key, String(val));
    }
  }
  return sp.toString();
}
// Produces: ?category=electronics&sort=price&page=2&inStock=true

// Pattern 3: Encoded path segments for hierarchical state
// /products/electronics/laptops/apple -> category=electronics, sub=laptops, brand=apple
// Use Next.js dynamic routes: /products/[...slug]
```

### Hash-Based Routing (Legacy)

```typescript
// Hash routing: everything after # never hits the server
// URL looks like: example.com/#/products/42?sort=price

// When to use: static hosting with no server-side routing (GitHub Pages, S3)
// When NOT to use: any server that can handle URL rewriting

// Simple hash router
function hashRouter() {
  function getHashPath() {
    return location.hash.slice(1) || '/';  // remove the #
  }

  window.addEventListener('hashchange', () => {
    renderRoute(getHashPath());
  });

  // Initial render
  renderRoute(getHashPath());
}

// Navigate by changing the hash
function navigateHash(path: string) {
  location.hash = path;  // fires hashchange event
}
```

### Path-Based Routing (Modern, Preferred)

```typescript
// With server-side support, use clean URLs:
// example.com/products/42?sort=price

// Server must be configured to serve index.html for all routes:
// Nginx: try_files $uri $uri/ /index.html;
// Express: app.get('*', (req, res) => res.sendFile('index.html'));
// Next.js: handled automatically by the framework

// React Router v6+ with path-based routing
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

const router = createBrowserRouter([
  {
    path: '/',
    element: <Layout />,
    children: [
      { index: true, element: <Home /> },
      { path: 'products', element: <ProductList /> },
      { path: 'products/:id', element: <ProductDetail /> },
      { path: 'categories/:categoryId/products/:productId', element: <ProductInCategory /> },
    ],
  },
]);

function App() {
  return <RouterProvider router={router} />;
}
```

### Sharing URLs That Preserve Exact Application State

```typescript
// useShareableUrl hook: generates a URL that recreates the current view
function useShareableUrl() {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const getShareUrl = () => {
    // The current URL already IS the shareable state if you've been
    // syncing everything to the URL. Just return it.
    return `${window.location.origin}${pathname}?${searchParams.toString()}`;
  };

  const copyShareUrl = async () => {
    await navigator.clipboard.writeText(getShareUrl());
  };

  return { getShareUrl, copyShareUrl };
}

// For deeply nested state that shouldn't pollute the URL,
// consider compressing state into a short token:
function encodeState<T>(state: T): string {
  const json = JSON.stringify(state);
  // Compress with LZ-string or similar
  return btoa(encodeURIComponent(json));
}

function decodeState<T>(encoded: string): T {
  return JSON.parse(decodeURIComponent(atob(encoded)));
}

// URL becomes: /products?state=eW91cl9jb21wcmVzc2VkX3N0YXRl
```

### Handling External Deep Links Into SPA Routes

```typescript
// Problem: someone shares /products/42, but the server returns 404
// because there's no physical /products/42.html file.

// Solution 1: Server-side catch-all (Express)
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Solution 2: Nginx rewrite
// location / {
//   try_files $uri $uri/ /index.html;
// }

// Solution 3: Next.js handles this automatically via its file-based routing
// but you need to ensure your route structure matches the expected URLs

// Solution 4: If you can't control the server, use hash routing as fallback
```

### Server-Side Rendering of Deep-Linked Content

```typescript
// Next.js App Router: SSR is the default for Server Components
// app/products/[id]/page.tsx
export default async function ProductPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;

  // This runs on the server, so the shared URL returns real HTML
  const product = await fetchProduct(id);

  if (!product) {
    notFound();
  }

  return (
    <div>
      <h1>{product.name}</h1>
      <p>{product.description}</p>
    </div>
  );
}

// Generate metadata for social sharing (Open Graph, Twitter Cards)
export async function generateMetadata({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await fetchProduct(id);

  return {
    title: product.name,
    openGraph: {
      title: product.name,
      description: product.description,
      images: [product.imageUrl],
    },
  };
}
```

---

## 4. Back-Button Handling

The back button is the single most problematic UX element in SPAs. Here is why and how to handle every scenario.

### Why Back-Button is Hard in SPAs

```typescript
// In a traditional MPA:
//   Back = load previous HTML page from server (or bfcache)
//   Everything is naturally restored: DOM, scroll, form values
//
// In an SPA:
//   Back = the URL changes via popstate / navigate(traverse)
//   Your code must manually restore:
//     - Which components to render
//     - Data fetched for the previous route
//     - Scroll position
//     - Form input values
//     - UI state (expanded/collapsed sections, open modals, etc.)
//     - Focus position
```

### Common Back-Button Bugs

```typescript
// Bug 1: Stale data displayed
// User navigates: List -> Detail (data loads) -> Edit (data changes) -> Back to Detail
// The Detail page shows the OLD data because it was cached from the first visit
// Fix: Invalidate cache on back navigation or refetch

// Bug 2: Lost scroll position
// User scrolls down a long list, clicks an item, hits back
// They're back at the top instead of where they were
// Fix: Scroll restoration (see Section 5)

// Bug 3: Lost form state
// User fills out a 20-field form, clicks a link to check something, hits back
// All form inputs are empty
// Fix: Form state preservation (see below)

// Bug 4: Wrong route rendered
// Race condition: fast back-then-forward navigations
// cause the wrong route's data to render
// Fix: AbortController / Navigation API signal

// Bug 5: Modal/overlay traps
// User opens modal, presses back, expects modal to close
// Instead they navigate away from the page entirely
// Fix: Modal as a route or intercept back navigation
```

### Navigation API Approach: Traverse Events Are Non-Cancellable

```typescript
// With the Navigation API, back/forward is a "traverse" navigationType.
// You CANNOT call preventDefault() on traverse events.
// You CAN call intercept() to handle it in your SPA.

navigation.addEventListener('navigate', (navigateEvent) => {
  if (!navigateEvent.canIntercept) return;

  // navigationType is "traverse" for back/forward
  if (navigateEvent.navigationType === 'traverse') {
    navigateEvent.intercept({
      async handler() {
        // Restore the previous view
        const url = new URL(navigateEvent.destination.url);
        await renderRoute(url.pathname);
        // Browser automatically restores scroll position for traversals
      },
    });
  }
});
```

### React Router Back-Button Behavior

```typescript
// React Router v6+ uses the History API under the hood.
// Back navigation triggers a popstate event, which React Router handles.

// React Router preserves the RouterProvider state tree, but individual
// component state (useState) is destroyed when the component unmounts.

// Pattern: Use location state for cross-route data
import { useNavigate, useLocation } from 'react-router-dom';

function ProductList() {
  const navigate = useNavigate();

  return products.map((product) => (
    <button
      key={product.id}
      onClick={() =>
        navigate(`/products/${product.id}`, {
          state: { scrollPosition: window.scrollY, fromList: true },
        })
      }
    >
      {product.name}
    </button>
  ));
}

function ProductDetail() {
  const location = useLocation();
  const scrollPosition = location.state?.scrollPosition ?? 0;

  useEffect(() => {
    // Restore scroll when coming back
    window.scrollTo(0, scrollPosition);
  }, []);
}
```

### Next.js App Router Back-Button Behavior

```typescript
// Next.js App Router maintains scroll position for back/forward by default.
// The Router Cache retains previously visited route segments.
// Back navigation reuses cached segments without refetching from the server.

// To force refetch on back navigation:
'use client';
import { useRouter } from 'next/navigation';

function useRefreshOnBack() {
  const router = useRouter();

  useEffect(() => {
    // Listen for pageshow to detect bfcache restoration
    const handlePageShow = (event: PageTransitionEvent) => {
      if (event.persisted) {
        // Page was restored from bfcache
        router.refresh();
      }
    };

    window.addEventListener('pageshow', handlePageShow);
    return () => window.removeEventListener('pageshow', handlePageShow);
  }, [router]);
}
```

### Preserving Form State Across Back Navigations

```typescript
// Pattern 1: Store form state in URL search params
function SearchForm() {
  const searchParams = useSearchParams();
  const router = useRouter();

  const query = searchParams.get('q') ?? '';
  const filters = searchParams.get('filters') ?? '';

  return (
    <form>
      <input
        name="q"
        value={query}
        onChange={(e) => {
          const params = new URLSearchParams(searchParams.toString());
          params.set('q', e.target.value);
          window.history.replaceState(null, '', `?${params.toString()}`);
        }}
      />
    </form>
  );
}

// Pattern 2: Store form state in sessionStorage
function useFormPersistence<T>(key: string, initialState: T) {
  const [state, setState] = useState<T>(() => {
    try {
      const saved = sessionStorage.getItem(key);
      return saved ? JSON.parse(saved) : initialState;
    } catch {
      return initialState;
    }
  });

  useEffect(() => {
    sessionStorage.setItem(key, JSON.stringify(state));
  }, [key, state]);

  // Clear on successful submission
  const clearSavedState = () => sessionStorage.removeItem(key);

  return [state, setState, clearSavedState] as const;
}

// Pattern 3: Use Navigation API state
if ('navigation' in window) {
  // Save form state before navigating away
  function saveFormState(formState: Record<string, string>) {
    navigation.updateCurrentEntry({
      state: { formData: formState },
    });
  }

  // Restore on navigate back
  navigation.addEventListener('navigate', (navigateEvent) => {
    if (navigateEvent.navigationType === 'traverse') {
      const savedState = navigateEvent.destination.getState() as
        | { formData: Record<string, string> }
        | undefined;
      if (savedState?.formData) {
        populateForm(savedState.formData);
      }
    }
  });
}
```

### BFCache (Back/Forward Cache) Implications

```typescript
// BFCache stores the entire page (DOM, JS heap, network stack) in memory.
// When user hits back, the page is restored INSTANTLY -- no reload.
// This can cause stale data and stale event listeners.

// Detecting BFCache restoration
window.addEventListener('pageshow', (event) => {
  if (event.persisted) {
    // Page was restored from BFCache.
    // Your JS state is from when the user left, which might be stale.
    console.log('Restored from BFCache -- check for stale data');

    // Refetch critical data
    refetchUserData();
  }
});

// Opting out of BFCache (use sparingly -- it hurts performance)
// Set this header: Cache-Control: no-store
// Or listen for beforeunload (but this is being deprecated)
// Next.js: BFCache works well with the App Router since router.refresh()
// can be called on pageshow to update stale data.

// The freeze/resume lifecycle
window.addEventListener('freeze', () => {
  // Page is being frozen for BFCache
  // Release any resources (WebSockets, IndexedDB locks, etc.)
});

window.addEventListener('resume', () => {
  // Page has been restored from BFCache
  // Re-establish connections, check for data staleness
});
```

### Modal Back-Button Pattern

```typescript
// Problem: User opens a modal, presses back, expects modal to close.
// Instead, they leave the page entirely.

// Solution: Each modal is a route segment, navigated to with history.push
// When the user presses back, the modal route unmounts (closing the modal).

// Next.js App Router with Intercepting Routes:
// app/products/[id]/page.tsx        -- full product page
// app/products/[id]/@modal/(.)[id]/page.tsx  -- modal overlay (intercepts)

// React Router v6 approach:
function ProductList() {
  const navigate = useNavigate();

  const openProductModal = (productId: string) => {
    // Push modal state onto history
    navigate(`/products/${productId}`, {
      state: { backgroundLocation: location },
    });
  };

  return (
    <div>
      {products.map((p) => (
        <button key={p.id} onClick={() => openProductModal(p.id)}>
          {p.name}
        </button>
      ))}

      {/* Render modal if there's background state */}
      <Outlet />
    </div>
  );
}
```

---

## 5. Scroll Restoration

### Browser Default Scroll Behavior

```typescript
// For "hard" navigations (full page loads):
//   Browser scrolls to top, or to #hash if present
//
// For back/forward:
//   Browser attempts to restore the scroll position from the previous visit
//   This works via BFCache or session history scroll position storage
//
// For SPA navigations (pushState/replaceState):
//   Browser does NOTHING. No scroll. You must handle it yourself.
```

### history.scrollRestoration

```typescript
// Tell the browser not to handle scroll restoration
// You'll do it yourself
if ('scrollRestoration' in window.history) {
  window.history.scrollRestoration = 'manual';
}

// Reset to browser default
window.history.scrollRestoration = 'auto';

// When to use 'manual':
// - SPA with virtualized lists (browser scroll restoration conflicts)
// - Custom scroll animations on route change
// - Fixed headers that offset scroll targets
// - Tabs/accordion where "scroll restoration" would be wrong

// When to use 'auto':
// - Simple page-based navigation
// - Back/forward where you want browser scroll restoration
// - Most MPA sites
```

### Navigation API Automatic Scroll Handling

```typescript
// The Navigation API handles scroll automatically in intercept():
//
// push/replace: scrolls to #hash or top of page
// reload: restores previous scroll
// traverse (back/forward): restores previous scroll
//
// All of this happens AFTER your handler resolves.

// Trigger scroll earlier than handler completion:
navigation.addEventListener('navigate', (navigateEvent) => {
  if (shouldNotIntercept(navigateEvent)) return;

  navigateEvent.intercept({
    async handler() {
      const data = await fetchData(navigateEvent.destination.url);
      renderContent(data);

      // Trigger scroll NOW instead of waiting for rest of handler
      navigateEvent.scroll();

      // Continue loading secondary content
      const secondary = await fetchSecondaryContent();
      renderSecondaryContent(secondary);
    },
  });
});

// Disable automatic scroll entirely:
navigateEvent.intercept({
  scroll: 'manual',
  async handler() {
    // Handle scroll yourself
    const savedScroll = getSavedScrollPosition(navigateEvent.destination.url);
    window.scrollTo(savedScroll.x, savedScroll.y);
  },
});
```

### Custom Scroll Position Tracking

```typescript
// Scroll position tracker that works with History API
class ScrollTracker {
  private positions = new Map<string, { x: number; y: number }>();

  private getKey(): string {
    return location.pathname + location.search;
  }

  save() {
    this.positions.set(this.getKey(), {
      x: window.scrollX,
      y: window.scrollY,
    });
  }

  restore(): boolean {
    const pos = this.positions.get(this.getKey());
    if (pos) {
      window.scrollTo(pos.x, pos.y);
      return true;
    }
    return false;
  }

  clear() {
    this.positions.clear();
  }
}

const scrollTracker = new ScrollTracker();

// Save scroll position before navigating away
window.addEventListener('beforeunload', () => scrollTracker.save());

// For SPA navigations, save before pushState
const originalPushState = history.pushState.bind(history);
history.pushState = function (...args) {
  scrollTracker.save();
  return originalPushState(...args);
};

// Restore on popstate (back/forward)
window.addEventListener('popstate', () => {
  // Wait for the next frame so the DOM has updated
  requestAnimationFrame(() => {
    if (!scrollTracker.restore()) {
      window.scrollTo(0, 0);  // default: scroll to top
    }
  });
});
```

### Scroll Restoration in Virtualized Lists

```typescript
// Virtualized lists (react-window, react-virtuoso) don't use native scrolling
// for content measurement, making scroll restoration tricky.

import { Virtuoso, VirtuosoHandle } from 'react-virtuoso';
import { useRef, useCallback } from 'react';

function VirtualProductList() {
  const virtuosoRef = useRef<VirtuosoHandle>(null);

  // Save the first visible item index (not pixel offset)
  const saveScrollState = useCallback(() => {
    virtuosoRef.current?.getState((state) => {
      if (state.scrollTop > 0) {
        sessionStorage.setItem(
          `scroll:${location.pathname}`,
          JSON.stringify({
            firstVisibleIndex: state.visibleRange.startIndex,
            offset: state.scrollTop,
          })
        );
      }
    });
  }, []);

  // Restore scroll to the saved index
  const restoreScroll = useCallback(() => {
    const saved = sessionStorage.getItem(`scroll:${location.pathname}`);
    if (saved) {
      const { firstVisibleIndex } = JSON.parse(saved);
      virtuosoRef.current?.scrollToIndex({
        index: firstVisibleIndex,
        align: 'start',
      });
    }
  }, []);

  return (
    <Virtuoso
      ref={virtuosoRef}
      data={products}
      initialDataReadyCallback={restoreScroll}
      itemContent={(index, product) => (
        <ProductItem product={product} />
      )}
    />
  );
}
```

### Intersection Observer for Scroll Anchors

```typescript
// For content that loads asynchronously and causes layout shifts,
// use IntersectionObserver to find and restore the user's viewport anchor.

function useScrollAnchor() {
  const anchorRef = useRef<HTMLDivElement>(null);
  const anchorTopRef = useRef<number>(0);

  // Before navigation, record which element is at the top of the viewport
  const saveAnchor = useCallback(() => {
    if (!anchorRef.current) return;
    const rect = anchorRef.current.getBoundingClientRect();
    anchorTopRef.current = rect.top;
  }, []);

  // After navigation + DOM update, scroll to restore the anchor
  const restoreAnchor = useCallback(() => {
    if (!anchorRef.current || anchorTopRef.current === 0) return;
    const rect = anchorRef.current.getBoundingClientRect();
    const diff = rect.top - anchorTopRef.current;
    if (Math.abs(diff) > 5) {
      window.scrollBy(0, diff);
    }
  }, []);

  return { anchorRef, saveAnchor, restoreAnchor };
}
```

---

## 6. Next.js App Router Navigation

Next.js App Router provides its own navigation layer on top of the browser's History API. Understanding both layers is essential.

### useRouter() Hook (Next.js Router)

```typescript
'use client';

import { useRouter } from 'next/navigation';

export default function NavigationExample() {
  const router = useRouter();

  return (
    <div>
      {/* Push: add new entry to history */}
      <button onClick={() => router.push('/dashboard')}>
        Go to Dashboard
      </button>

      {/* Replace: overwrite current history entry */}
      <button onClick={() => router.replace('/login')}>
        Go to Login (replace)
      </button>

      {/* Back: go to previous entry */}
      <button onClick={() => router.back()}>
        Go Back
      </button>

      {/* Forward: go to next entry */}
      <button onClick={() => router.forward()}>
        Go Forward
      </button>

      {/* Refresh: re-fetch server components without losing client state */}
      <button onClick={() => router.refresh()}>
        Refresh Data
      </button>

      {/* Prefetch: preload a route */}
      <button onClick={() => router.prefetch('/heavy-page')}>
        Prefetch Heavy Page
      </button>

      {/* Push with scroll disabled */}
      <button onClick={() => router.push('/dashboard', { scroll: false })}>
        Navigate without scrolling
      </button>
    </div>
  );
}
```

### useRouter Methods Reference

```typescript
interface NextRouter {
  // Navigate to a new route (push onto history stack)
  push(href: string, options?: { scroll?: boolean; transitionTypes?: string[] }): void;

  // Navigate to a new route (replace current history entry)
  replace(href: string, options?: { scroll?: boolean; transitionTypes?: string[] }): void;

  // Refresh the current route (re-fetch RSC payload, preserve client state)
  refresh(): void;

  // Navigate back in history
  back(): void;

  // Navigate forward in history
  forward(): void;

  // Prefetch a route for faster subsequent navigation
  prefetch(href: string, options?: { onInvalidate?: () => void }): void;
}
```

### usePathname() and useSearchParams()

```typescript
'use client';

import { usePathname, useSearchParams } from 'next/navigation';

export function RouteInfo() {
  const pathname = usePathname();     // "/products/42"
  const searchParams = useSearchParams();  // URLSearchParams object

  const id = pathname.split('/').pop();
  const sort = searchParams.get('sort');
  const page = searchParams.get('page');

  return (
    <div>
      <p>Product ID: {id}</p>
      <p>Sort: {sort}</p>
      <p>Page: {page}</p>
    </div>
  );
}
```

### Shallow Routing with window.history

```typescript
// Next.js integrates pushState/replaceState into its router.
// Calling window.history.pushState updates the URL visible to
// usePathname and useSearchParams WITHOUT triggering a server request.

'use client';

import { useSearchParams, usePathname } from 'next/navigation';

export function SortControls() {
  const searchParams = useSearchParams();
  const pathname = usePathname();

  function updateSort(sort: string) {
    const params = new URLSearchParams(searchParams.toString());
    params.set('sort', sort);

    // Shallow update: URL changes, no server round-trip
    window.history.pushState(null, '', `${pathname}?${params.toString()}`);

    // For replace (no new history entry):
    // window.history.replaceState(null, '', `${pathname}?${params.toString()}`);
  }

  return (
    <div>
      <button onClick={() => updateSort('price')}>Sort by Price</button>
      <button onClick={() => updateSort('name')}>Sort by Name</button>
    </div>
  );
}
```

### Navigation Within Layouts (Partial Rendering)

```typescript
// App Router structure:
// app/layout.tsx          -> root layout (always preserved)
// app/dashboard/layout.tsx -> dashboard layout (preserved within /dashboard/*)
// app/dashboard/analytics/page.tsx
// app/dashboard/settings/page.tsx

// When navigating from /dashboard/analytics to /dashboard/settings:
// - Root layout: PRESERVED
// - Dashboard layout: PRESERVED
// - Analytics page: UNMOUNTED
// - Settings page: MOUNTED with fresh state
// - Only the settings page's RSC payload is fetched

// This means dashboard layout state (sidebar, user menu) survives navigation.
// But analytics page state (filters, scroll) is DESTROYED.

// To preserve page-level state across same-layout navigation:
// Option 1: Lift state to the shared layout
// Option 2: Store in URL params
// Option 3: Use a state management library (zustand, jotai)
```

### Prefetching Behavior

```typescript
// Next.js prefetches routes in these cases:
//
// 1. <Link> component: prefetches when link enters viewport (production only)
//    Default behavior: prefetches the RSC payload down to the first loading.js
//    This gives instant loading states without downloading the full page.
//
//    <Link href="/products">Products</Link>
//    <Link href="/products" prefetch={false}>Products (no prefetch)</Link>
//    <Link href="/products" prefetch={true}>Products (full prefetch)</Link>
//
// 2. router.prefetch(): manual prefetch
//    Useful for prefetching on hover or when you know the user will navigate.

'use client';
import { useRouter } from 'next/navigation';

export function ProductCard({ id }: { id: string }) {
  const router = useRouter();

  return (
    <div
      onMouseEnter={() => router.prefetch(`/products/${id}`)}
      onClick={() => router.push(`/products/${id}`)}
    >
      Hover to prefetch, click to navigate
    </div>
  );
}
```

### next/link Component

```typescript
import Link from 'next/link';

export function Navigation() {
  return (
    <nav>
      {/* Basic link */}
      <Link href="/about">About</Link>

      {/* Link with query params */}
      <Link href="/products?sort=price&page=1">Products</Link>

      {/* Link to dynamic route */}
      <Link href={`/products/${productId}`}>View Product</Link>

      {/* Disable prefetch */}
      <Link href="/heavy-page" prefetch={false}>Heavy Page</Link>

      {/* Full page prefetch */}
      <Link href="/products" prefetch={true}>Products (full)</Link>

      {/* Replace instead of push */}
      <Link href="/login" replace>Login</Link>

      {/* Disable scroll to top */}
      <Link href="/products" scroll={false}>Products (no scroll)</Link>

      {/* Active link styling */}
      <Link
        href="/dashboard"
        className={({ isActive }) => isActive ? 'active' : ''}
      >
        Dashboard
      </Link>
    </nav>
  );
}
```

### Navigation Events (Replacing router.events)

```typescript
// App Router does NOT have router.events (unlike Pages Router).
// Instead, compose usePathname + useSearchParams in a client component.

'use client';

import { useEffect } from 'react';
import { usePathname, useSearchParams } from 'next/navigation';

export function NavigationEvents() {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  useEffect(() => {
    const url = `${pathname}?${searchParams.toString()}`;

    // Track page views
    analytics.page({ url, pathname });

    // Track performance
    performance.mark('navigation-complete');
  }, [pathname, searchParams]);

  return null; // invisible component
}

// Mount in root layout:
// app/layout.tsx
import { Suspense } from 'react';
import { NavigationEvents } from './navigation-events';

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Suspense fallback={null}>
          <NavigationEvents />
        </Suspense>
      </body>
    </html>
  );
}

// MUST wrap in Suspense because useSearchParams causes client-side rendering
// up to the nearest Suspense boundary during static generation.
```

---

## 7. Programmatic Navigation Patterns

### Imperative Navigation (from Event Handlers)

```typescript
'use client';

import { useRouter } from 'next/navigation';

export function LoginButton() {
  const router = useRouter();

  async function handleLogin() {
    const success = await login(formData);
    if (success) {
      // Imperative navigation after async work
      router.push('/dashboard');
    }
  }

  return <button onClick={handleLogin}>Login</button>;
}
```

### Declarative Navigation (Link and Form)

```typescript
// Declarative: the navigation is declared in JSX, not triggered by code

// Pattern 1: <Link> component (preferred for navigation)
import Link from 'next/link';

<nav>
  <Link href="/about">About</Link>
  <Link href="/contact">Contact</Link>
</nav>;

// Pattern 2: <form action> (Next.js Server Actions)
import { redirect } from 'next/navigation';

// Server Action
async function createUser(formData: FormData) {
  'use server';
  const id = await db.users.create({
    name: formData.get('name'),
    email: formData.get('email'),
  });
  redirect(`/users/${id}`);  // redirect after mutation
}

// Client form
export function CreateUserForm() {
  return (
    <form action={createUser}>
      <input name="name" />
      <input name="email" type="email" />
      <button type="submit">Create User</button>
    </form>
  );
}
```

### Navigation with State: Passing Data Between Routes

```typescript
// Pattern 1: URL search params (shareable, bookmarkable)
router.push('/products?category=electronics&sort=price');

// Pattern 2: Dynamic route segments
router.push(`/products/${productId}`);

// Pattern 3: window.history state (not visible in URL, not shared)
window.history.pushState(
  { from: 'product-list', scrollY: 500 },
  '',
  `/products/${productId}`
);

// Reading it on the destination:
useEffect(() => {
  const state = window.history.state;
  if (state?.from === 'product-list') {
    // Came from product list, show "back to list" button
  }
}, []);

// Pattern 4: Navigation API state + info
if ('navigation' in window) {
  // state is persisted in history entry
  navigation.navigate('/checkout', {
    state: { cartId: 'abc123', itemCount: 3 },
  });

  // info is ephemeral (not replayed on back/forward)
  navigation.navigate('/checkout', {
    info: { animation: 'slide-up' },
  });
}

// Pattern 5: Shared state via context/store (not tied to navigation)
// zustand, jotai, redux, etc.
const useStore = create((set) => ({
  navigationContext: null,
  setNavigationContext: (ctx) => set({ navigationContext: ctx }),
}));

// Before navigating:
useStore.getState().setNavigationContext({ source: 'product-card' });
router.push('/checkout');
```

### Optimistic Navigation: Update UI Before Server Confirms

```typescript
'use client';

import { useRouter } from 'next/navigation';
import { useState, useTransition } from 'react';

export function AddToCartButton({ productId }: { productId: string }) {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();
  const [optimisticCount, setOptimisticCount] = useState(0);

  function handleAdd() {
    // Optimistically update UI
    setOptimisticCount((c) => c + 1);

    startTransition(async () => {
      await addToCart(productId);
      // Refresh server data (merges RSC payload, preserves client state)
      router.refresh();
    });
  }

  return (
    <button onClick={handleAdd} disabled={isPending}>
      {isPending ? 'Adding...' : `Add to Cart (${optimisticCount})`}
    </button>
  );
}
```

### Redirect Patterns in Server Components and Server Actions

```typescript
// Server Component: redirect during render
import { redirect, permanentRedirect } from 'next/navigation';

export default async function OldProductPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  const product = await getProduct(id);

  if (!product) {
    redirect('/products');  // 307 Temporary Redirect
  }

  if (product.slug !== id) {
    // SEO: redirect to canonical slug URL
    permanentRedirect(`/products/${product.slug}`);  // 308 Permanent Redirect
  }

  return <ProductDetail product={product} />;
}

// Server Action: redirect after mutation
async function deleteProduct(formData: FormData) {
  'use server';
  const id = formData.get('id') as string;
  await db.products.delete(id);
  redirect('/products');  // 303 See Other (Post/Redirect/Get pattern)
}

// important: redirect throws a special error internally.
// Do NOT wrap it in try/catch.
// WRONG:
async function bad() {
  try {
    redirect('/elsewhere');  // this throw is caught, redirect doesn't happen
  } catch (e) {
    // redirect's internal error is caught here
  }
}
```

---

## 8. Common Pitfalls and Solutions

### Pitfall 1: Hydration Mismatch from URL-Dependent Rendering

```typescript
// PROBLEM: Server renders with one URL, client hydrates with another,
// or server can't access browser APIs during SSR.

// WRONG: Using window.location during SSR
export default function Page() {
  const path = window.location.pathname; // ReferenceError on server!
  return <div>Current path: {path}</div>;
}

// WRONG: Different content on server vs client
'use client';
export default function Page() {
  const [path, setPath] = useState('');
  useEffect(() => {
    setPath(window.location.pathname);  // client-only
  }, []);
  // Server renders with '', client renders with '/products' -> HYDRATION MISMATCH
  return <div>Current path: {path}</div>;
}

// CORRECT: Use Next.js hooks (work on both server and client)
import { usePathname } from 'next/navigation';

export default function Page() {
  const pathname = usePathname();  // works during SSR
  return <div>Current path: {pathname}</div>;
}

// CORRECT: For browser-only state, use suppressHydrationWarning
'use client';
export default function Page() {
  const [hash, setHash] = useState('');
  useEffect(() => {
    setHash(window.location.hash);
  }, []);

  return (
    <div suppressHydrationWarning>
      {/* suppressHydrationWarning tells React the mismatch is expected */}
      Hash: {hash || 'none'}
    </div>
  );
}
```

### Pitfall 2: Race Conditions in Concurrent Navigations

```typescript
// PROBLEM: User clicks rapidly, multiple navigations fire concurrently.
// The last-resolved navigation's data overwrites the correct one.

// WRONG: No abort handling
async function navigateTo(url: string) {
  const data = await fetch(url);  // slow
  renderPage(data);               // might render stale data if user navigated again
}

// CORRECT: AbortController pattern
let currentController: AbortController | null = null;

async function navigateTo(url: string) {
  // Cancel previous navigation
  currentController?.abort();
  currentController = new AbortController();

  try {
    const data = await fetch(url, { signal: currentController.signal });
    renderPage(data);
  } catch (err) {
    if (err instanceof DOMException && err.name === 'AbortError') {
      return; // superseded by newer navigation, silently discard
    }
    throw err;
  }
}

// CORRECT: Navigation API (signal built in)
navigation.addEventListener('navigate', (navigateEvent) => {
  if (shouldNotIntercept(navigateEvent)) return;

  navigateEvent.intercept({
    async handler() {
      // signal is automatically aborted if navigation is superseded
      const data = await fetch(navigateEvent.destination.url, {
        signal: navigateEvent.signal,
      });
      renderPage(data);
    },
  });
});

// CORRECT: Next.js (useTransition handles this)
'use client';
import { useRouter } from 'next/navigation';
import { useTransition } from 'react';

export function SearchResults() {
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  function search(query: string) {
    // startTransition batches the navigation, React discards stale renders
    startTransition(() => {
      router.push(`/search?q=${encodeURIComponent(query)}`);
    });
  }

  return (
    <div>
      <SearchInput onSearch={search} />
      {isPending && <LoadingSpinner />}
    </div>
  );
}
```

### Pitfall 3: Memory Leaks from Uncancelled Fetch on Navigation

```typescript
// PROBLEM: Component starts a fetch, user navigates away, component unmounts,
// fetch completes and tries to update unmounted component state.

// WRONG: No cleanup
function UserProfile({ id }: { id: string }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetch(`/api/users/${id}`)
      .then((r) => r.json())
      .then((data) => setUser(data));  // Warning: Can't perform a React state
                                        // update on an unmounted component
  }, [id]);

  return <div>{user?.name}</div>;
}

// CORRECT: AbortController in useEffect cleanup
function UserProfile({ id }: { id: string }) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    const controller = new AbortController();

    fetch(`/api/users/${id}`, { signal: controller.signal })
      .then((r) => r.json())
      .then((data) => {
        if (!controller.signal.aborted) {
          setUser(data);
        }
      })
      .catch((err) => {
        if (err.name !== 'AbortError') throw err;
      });

    return () => controller.abort();
  }, [id]);

  return <div>{user?.name}</div>;
}

// CORRECT: React Query / SWR (handles this automatically)
import useSWR from 'swr';

function UserProfile({ id }: { id: string }) {
  const { data: user } = useSWR(`/api/users/${id}`, fetcher);
  return <div>{user?.name}</div>;
  // SWR automatically cancels requests on unmount / key change
}
```

### Pitfall 4: Double Navigation Bugs

```typescript
// PROBLEM: Both the link click AND the event handler trigger navigation,
// resulting in duplicate history entries or unexpected behavior.

// WRONG: Link with onClick that also navigates
<Link href="/dashboard" onClick={() => router.push('/dashboard')}>
  Dashboard
</Link>
// This navigates TWICE: once from router.push, once from <Link>

// CORRECT: Use Link OR router.push, not both
<Link href="/dashboard">Dashboard</Link>
// OR
<button onClick={() => router.push('/dashboard')}>Dashboard</button>

// PROBLEM: Form submission followed by redirect
// Server Action calls redirect(), but client also calls router.push()
async function handleSubmit(formData: FormData) {
  'use server';
  await saveData(formData);
  redirect('/success');  // This already navigates the client
}

// Client should NOT also navigate:
// WRONG: onClick={() => { handleSubmit(formData); router.push('/success'); }}
// CORRECT: Let the Server Action's redirect handle it
<form action={handleSubmit}>...</form>
```

### Pitfall 5: Browser Refresh vs SPA Navigation State Loss

```typescript
// PROBLEM: Data stored in React state (useState, useRef, context)
// survives SPA navigation but is LOST on browser refresh (F5).

// Solutions by data type:

// 1. Ephemeral UI state (open/closed, hover) -> Accept the loss, it's fine
// 2. Form data -> sessionStorage
// 3. User preferences -> localStorage + React state (hydrate from storage)
// 4. Route-specific data -> URL params (survives refresh)
// 5. Auth tokens -> httpOnly cookies (survive everything)
// 6. API data -> React Query / SWR cache (persisted to storage)

// Pattern: Zustand with persist middleware
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

const useAppStore = create(
  persist(
    (set) => ({
      recentSearches: [] as string[],
      addSearch: (query: string) =>
        set((state) => ({
          recentSearches: [query, ...state.recentSearches].slice(0, 10),
        })),
    }),
    { name: 'app-store' }  // localStorage key
  )
);
// State survives refresh, back/forward, and even closing the tab.
```

### Pitfall 6: iOS Safari Bounce-Back Gesture Issues

```typescript
// PROBLEM: iOS Safari's swipe-from-edge gesture for back navigation
// fires popstate but the animation can be cancelled mid-way, causing
// desync between browser URL and app state.

// Solution 1: Listen for visualViewport changes (iOS Safari specific)
useEffect(() => {
  const handleViewportResize = () => {
    // During the iOS swipe-back gesture, visualViewport shrinks
    // If the gesture is cancelled, it returns to full size
    if (window.visualViewport?.width !== window.innerWidth) {
      // Gesture in progress, don't update app state
      return;
    }
  };

  window.visualViewport?.addEventListener('resize', handleViewportResize);
  return () => window.visualViewport?.removeEventListener('resize', handleViewportResize);
}, []);

// Solution 2: Debounce popstate handling on iOS
function isIOS() {
  return /iPad|iPhone|iPod/.test(navigator.userAgent);
}

let popstateTimer: ReturnType<typeof setTimeout>;
window.addEventListener('popstate', () => {
  if (isIOS()) {
    clearTimeout(popstateTimer);
    popstateTimer = setTimeout(() => {
      handleRouteChange();
    }, 100);
  } else {
    handleRouteChange();
  }
});

// Solution 3: Disable the edge gesture entirely (aggressive)
// CSS: overscroll-behavior-x: none;
// This prevents the bounce-back gesture on iOS Safari
// But also prevents pull-to-refresh, which some apps use

// Solution 4: Use Next.js or React Router which handle this internally
// Next.js App Router accounts for iOS Safari quirks in its router
```

### Pitfall 7: useSearchParams Suspense Boundary Requirement

```typescript
// PROBLEM: useSearchParams causes the entire page to client-render
// during static generation unless wrapped in Suspense.

// WRONG: useSearchParams at page level without Suspense
export default function SearchPage() {
  const searchParams = useSearchParams();  // blocks static generation!
  return <div>Results for: {searchParams.get('q')}</div>;
}

// CORRECT: Wrap in Suspense
import { Suspense } from 'react';

export default function SearchPage() {
  return (
    <Suspense fallback={<SearchSkeleton />}>
      <SearchResults />
    </Suspense>
  );
}

function SearchResults() {
  const searchParams = useSearchParams();
  return <div>Results for: {searchParams.get('q')}</div>;
}
```

---

## 9. Testing Checklist

### Manual Test Cases for Navigation Features

Every route change should be verified against these cases:

#### Basic Navigation

- [ ] Clicking a `<Link>` navigates to the correct URL
- [ ] `router.push()` navigates to the correct URL
- [ ] `router.replace()` navigates without adding a history entry
- [ ] `router.back()` returns to the previous page
- [ ] `router.forward()` advances to the next page
- [ ] Direct URL entry in browser address bar loads the correct page
- [ ] Refresh (F5 / Cmd+R) preserves the current page state where expected

#### Back-Button Test Matrix

| Starting State | Action | Expected Result |
|---------------|--------|----------------|
| Home page | Click link to /products, press Back | Returns to Home with correct state |
| Product list (scrolled to item 50) | Click product, press Back | Returns to list at scroll position of item 50 |
| Product detail | Click edit, make changes, save, press Back | Returns to detail with UPDATED data |
| Form (partially filled) | Click external link, press Back | Form values preserved |
| Modal open | Press Back | Modal closes (or navigates away if modal is not a route) |
| Page 3 of search results | Press Back, press Forward | Returns to page 3 with same results and scroll |
| After POST redirect | Press Back | Does not re-submit the form |
| Multiple tabs open | Navigate in tab A, switch to tab B | Tab B is unaffected |
| SPA navigation A -> B -> C | Hold Back button, select A | Jumps directly to A |

#### Deep Link Sharing Verification

- [ ] Copy URL from address bar, open in incognito window -> page loads correctly
- [ ] Copy URL from address bar, send to another device -> page loads correctly
- [ ] URL with search params (`?q=test&sort=price`) -> filters are applied
- [ ] URL with hash fragment (`#section-3`) -> page scrolls to section
- [ ] URL with dynamic segments (`/products/42`) -> correct product loads
- [ ] URL with encoded characters (`/search?q=hello%20world`) -> decoded correctly
- [ ] Open Graph / Twitter Card meta tags render correctly when shared on social

#### Scroll Restoration Verification

- [ ] Scroll down long list, click item, press Back -> scroll position restored
- [ ] Navigate to page with hash (`#section-3`) -> scrolls to section
- [ ] Navigate to page without hash -> scrolls to top (or correct position)
- [ ] Scroll in virtualized list, navigate away, navigate back -> correct item visible
- [ ] Multiple back/forward cycles -> scroll position correct at each step
- [ ] Navigate to shorter page, back to longer page -> scroll position correct

#### Edge Cases

- [ ] Rapid clicking multiple links -> last-clicked link wins, no crashes
- [ ] Navigate during ongoing fetch -> previous fetch is cancelled, no stale data
- [ ] Browser's Stop button during navigation -> app remains in consistent state
- [ ] Offline navigation (service worker cached routes) -> works or fails gracefully
- [ ] Opening link in new tab (Ctrl/Cmd+Click) -> new tab opens correctly
- [ ] Same-page hash navigation (`#section`) -> scrolls without page re-render
- [ ] External link navigation -> leaves the app (not intercepted by SPA router)

### Automated Testing Patterns

```typescript
// Playwright: test back-button behavior
import { test, expect } from '@playwright/test';

test('back button restores scroll position on product list', async ({ page }) => {
  // Navigate to product list
  await page.goto('/products');

  // Scroll down
  await page.evaluate(() => window.scrollTo(0, 2000));
  const scrollBefore = await page.evaluate(() => window.scrollY);
  expect(scrollBefore).toBe(2000);

  // Click a product
  await page.click('[data-testid="product-42"]');

  // Wait for product page to load
  await expect(page).toHaveURL(/\/products\/42/);

  // Go back
  await page.goBack();

  // Verify scroll position is restored
  const scrollAfter = await page.evaluate(() => window.scrollY);
  expect(Math.abs(scrollAfter - scrollBefore)).toBeLessThan(50);
});

test('back button from form preserves input values', async ({ page }) => {
  await page.goto('/contact');
  await page.fill('#name', 'John Doe');
  await page.fill('#email', 'john@example.com');

  // Click a link that navigates away
  await page.click('a[href="/privacy"]');

  // Go back
  await page.goBack();

  // Verify form values are preserved
  await expect(page.locator('#name')).toHaveValue('John Doe');
  await expect(page.locator('#email')).toHaveValue('john@example.com');
});

test('deep link with search params renders correctly', async ({ page }) => {
  await page.goto('/products?category=electronics&sort=price&page=2');

  // Verify filters are applied
  await expect(page.locator('[data-testid="category-select"]')).toHaveValue('electronics');
  await expect(page.locator('[data-testid="sort-select"]')).toHaveValue('price');

  // Verify correct page is shown
  await expect(page.locator('[data-testid="pagination-active"]')).toHaveText('2');
});

// React Testing Library: test navigation hooks
import { renderHook, act } from '@testing-library/react';
import { useRouter, usePathname, useSearchParams } from 'next/navigation';

// Mock Next.js navigation
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
  usePathname: jest.fn(),
  useSearchParams: jest.fn(),
}));

test('useRouter.push is called with correct arguments', () => {
  const mockPush = jest.fn();
  (useRouter as jest.Mock).mockReturnValue({ push: mockPush });
  (usePathname as jest.Mock).mockReturnValue('/products');
  (useSearchParams as jest.Mock).mockReturnValue(new URLSearchParams());

  const { result } = renderHook(() => useRouter());
  act(() => result.current.push('/dashboard'));

  expect(mockPush).toHaveBeenCalledWith('/dashboard');
});
```

---

## Quick Reference Card

### Navigation API Cheat Sheet

```typescript
// Feature detect
'navigation' in window

// Listen for ALL navigations
navigation.addEventListener('navigate', (e) => { /* ... */ });

// Intercept (SPA-style)
e.intercept({ handler: async () => { /* ... */ } });

// Cancel (NOT for back/forward)
e.preventDefault();

// Abort in-flight work
fetch(url, { signal: e.signal });

// Programmatic navigation
navigation.navigate(url, { state, history: 'push'|'replace', info });
navigation.back();
navigation.forward();
navigation.traverseTo(key);
navigation.reload({ state });

// State
navigation.currentEntry.getState();
navigation.updateCurrentEntry({ state });

// Events
"navigate" | "navigatesuccess" | "navigateerror" | "currententrychange"

// Scroll
e.intercept({ scroll: 'manual' | 'auto' });
e.scroll();  // trigger early

// Focus
e.intercept({ focusReset: 'manual' | 'auto' });
```

### Next.js App Router Cheat Sheet

```typescript
// Import from 'next/navigation' (NOT 'next/router')
import { useRouter, usePathname, useSearchParams } from 'next/navigation';

// Navigate
router.push(href, { scroll: boolean });
router.replace(href, { scroll: boolean });
router.back();
router.forward();
router.refresh();
router.prefetch(href);

// Read current route
const pathname = usePathname();
const searchParams = useSearchParams();

// Declarative
<Link href="/path" prefetch={true|false|null} scroll={false} replace />

// Server-side redirect
import { redirect } from 'next/navigation';  // throws internally

// Shallow routing (no server round-trip)
window.history.pushState(null, '', newUrl);
window.history.replaceState(null, '', newUrl);

// Navigation events (no router.events in App Router)
// Use usePathname + useSearchParams in a client component wrapped in <Suspense>
```

### Decision Tree: Which Navigation Method to Use

```text
Need to navigate?
|
+-- User clicking a link?
|   +-- YES: Use <Link href="...">
|   +-- After form submission? Use Server Action + redirect()
|
+-- Need to navigate from code?
|   +-- In event handler (client): router.push() / router.replace()
|   +-- In Server Component: redirect()
|   +-- In Server Action: redirect()
|   +-- In useEffect: router.push() (but prefer <Link> if possible)
|
+-- Need to update URL without navigation?
|   +-- Filters/sort/pagination: window.history.pushState()
|   +-- Replace current entry: window.history.replaceState()
|   +-- With state: history API state parameter
|
+-- Need to handle back/forward?
    +-- Framework router handles it (Next.js, React Router)
    +-- Custom: Listen for popstate or Navigation API "navigate" with traverse
    +-- Need scroll restoration: See Section 5
```

---

*Last updated: 2026-05-28. Navigation API browser support reflects current Baseline status. Next.js examples target App Router (v13+).*
