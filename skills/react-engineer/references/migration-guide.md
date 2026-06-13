# React/Next.js Migration Guide

## React 18 to React 19

### Pre-Migration Checklist

- [ ] Audit all `ref` usage for string refs (`"myRef"`) and callback refs expecting cleanup
- [ ] Search for `defaultProps` on function components
- [ ] Check for `propTypes` usage
- [ ] Identify all `forwardRef` usage (simplified in React 19)
- [ ] Run `npx react-codemod@latest` for automated fixes
- [ ] Ensure test environment supports React 19 (`@testing-library/react` 16+)
- [ ] Check third-party library compatibility

### Breaking Changes

#### 1. Ref as a Prop (No More `forwardRef`)

```tsx
// React 18: forwardRef required
const MyInput = forwardRef(function MyInput(props, ref) {
  return <input ref={ref} {...props} />;
});

// React 19: ref is just a prop
function MyInput({ ref, ...props }: { ref?: React.Ref<HTMLInputElement> }) {
  return <input ref={ref} {...props} />;
}
```

#### 2. Ref Cleanup Functions

```tsx
// React 18: no cleanup for callback refs
<div ref={(node) => { /* setup */ }} />

// React 19: callback refs can return a cleanup function
<div ref={(node) => {
  if (!node) return;
  // Setup
  const observer = new IntersectionObserver(/* ... */);
  observer.observe(node);
  // Cleanup (returned function)
  return () => observer.disconnect();
}} />
```

#### 3. `useContext` Render Path Change

```tsx
// React 18: context change triggers re-render of the component that called useContext
// React 19: context change can be accessed synchronously without re-render

import { useContext } from 'react';

// If provider value changes, React 19 may skip re-render if the consumed
// value hasn't actually changed (more efficient)
```

#### 4. String Refs Removed

```tsx
// React 18: string refs deprecated but still worked
class MyComponent extends React.Component {
  render() {
    return <input ref="myInput" />; // Error in React 19!
  }
}

// React 19: use createRef or callback refs
class MyComponent extends React.Component {
  myInput = React.createRef<HTMLInputElement>();
  render() {
    return <input ref={this.myInput} />;
  }
}
```

#### 5. `defaultProps` Removed for Function Components

```tsx
// React 18
function Greeting({ name = 'World' }) {
  return <h1>Hello, {name}</h1>;
}
Greeting.defaultProps = { name: 'World' }; // Error in React 19!

// React 19: use default parameters only
function Greeting({ name = 'World' }: { name?: string }) {
  return <h1>Hello, {name}</h1>;
}
```

#### 6. Removed APIs

- `react-test-renderer` (use `@testing-library/react` instead)
- `ReactDOM.render` (use `createRoot` from `react-dom/client`)
- `ReactDOM.hydrate` (use `hydrateRoot` from `react-dom/client`)

### New Features to Adopt

```tsx
// use() hook - read promises and context in render
import { use } from 'react';

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  const user = use(userPromise);
  return <h1>{user.name}</h1>;
}

// useActionState - form state management
import { useActionState } from 'react';

function Form() {
  const [state, submitAction, isPending] = useActionState(
    async (prevState, formData) => {
      const result = await submitForm(formData);
      return result;
    },
    { status: 'idle' }
  );

  return (
    <form action={submitAction}>
      <input name="email" />
      <button type="submit" disabled={isPending}>Submit</button>
    </form>
  );
}

// useOptimistic - optimistic UI updates
import { useOptimistic } from 'react';

function MessageList({ messages }: { messages: Message[] }) {
  const [optimisticMessages, addOptimisticMessage] = useOptimistic(
    messages,
    (state, newMessage: string) => [
      ...state,
      { id: 'temp', text: newMessage, sending: true },
    ]
  );

  async function handleSubmit(formData: FormData) {
    const text = formData.get('message') as string;
    addOptimisticMessage(text);
    await sendMessage(text);
  }

  return (
    <div>
      {optimisticMessages.map((msg) => (
        <p key={msg.id} style={{ opacity: msg.sending ? 0.5 : 1 }}>
          {msg.text}
        </p>
      ))}
      <form action={handleSubmit}>
        <input name="message" />
        <button type="submit">Send</button>
      </form>
    </div>
  );
}
```

### Post-Migration Verification

1. Run full test suite: `npm test`
2. Check console for deprecation warnings
3. Verify all refs work correctly
4. Test form submissions with `useActionState`
5. Verify SSR/hydration works without mismatch errors
6. Run Lighthouse audit for performance regression

---

## Next.js 14 to 15

### Pre-Migration Checklist

- [ ] Update `next` to version 15
- [ ] Update `react` and `react-dom` to version 19
- [ ] Check all `searchParams` and `params` usage (now async)
- [ ] Review caching behavior changes
- [ ] Test Turbopack compatibility if using it

### Breaking Changes

#### 1. Async Request APIs

```tsx
// Next.js 14: synchronous params and searchParams
export default function Page({ params, searchParams }: {
  params: { id: string };
  searchParams: { [key: string]: string | string[] | undefined };
}) {
  const product = await getProduct(params.id);
  return <div>{product.name}</div>;
}

// Next.js 15: async params and searchParams
export default async function Page({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}) {
  const { id } = await params;
  const search = await searchParams;
  const product = await getProduct(id);
  return <div>{product.name}</div>;
}
```

#### 2. Caching Defaults Changed

```tsx
// Next.js 14: fetch was cached by default
const res = await fetch('/api/data'); // cached

// Next.js 15: fetch is NOT cached by default
const res = await fetch('/api/data'); // no cache (like standard fetch)

// To opt into caching:
const res = await fetch('/api/data', { cache: 'force-cache' });

// To cache with revalidation:
const res = await fetch('/api/data', { next: { revalidate: 3600 } });
```

```tsx
// Next.js 14: GET route handlers cached by default
export async function GET() {
  const data = await getData();
  return Response.json(data); // cached
}

// Next.js 15: not cached by default
export async function GET() {
  const data = await getData();
  return Response.json(data); // not cached

  // To cache:
  // export const dynamic = 'force-static';
}
```

#### 3. Layout `cookies()`, `headers()`, and `uncached()` in Layouts

```tsx
// Next.js 15: calling cookies() or headers() in a layout opts the entire
// layout tree into dynamic rendering
import { cookies } from 'next/headers';

export default async function Layout({ children }) {
  const cookieStore = await cookies(); // makes this layout dynamic
  const theme = cookieStore.get('theme')?.value ?? 'light';
  return <div data-theme={theme}>{children}</div>;
}
```

#### 4. `unstable_noStore` Removed

```tsx
// Next.js 14
import { unstable_noStore as noStore } from 'next/cache';

export async function GET() {
  noStore(); // opt out of caching
}

// Next.js 15: use `connection` from next/server or just rely on new defaults
import { connection } from 'next/server';

export async function GET() {
  await connection(); // marks as dynamic
}
```

### Post-Migration Verification

1. Test all dynamic routes: `app/[slug]/page.tsx`
2. Verify search params work in server components
3. Check caching behavior (may need to add explicit `cache` options)
4. Test API routes for correct caching
5. Verify ISR pages revalidate correctly
6. Run `next build` and check for warnings

---

## Next.js 15 to 16

### Pre-Migration Checklist

- [ ] Update `next` to version 16
- [ ] Verify Turbopack compatibility with all loaders/plugins
- [ ] Review image optimization configuration
- [ ] Check `params` handling (now stricter async requirement)
- [ ] Audit `next/image` usage for new defaults

### Breaking Changes

#### 1. Turbopack Is the Default Bundler

```js
// next.config.js
// Next.js 15: Turbopack was opt-in for dev
// const nextConfig = { experimental: { turbo: true } };

// Next.js 16: Turbopack is the default for dev and build
// To opt out (Webpack):
const nextConfig = {
  bundler: 'webpack', // only if needed for compatibility
};
```

#### 2. Cache Components (Stable)

```tsx
// Next.js 16: Cache (formerly unstable) is stable for Server Components
import { cache } from 'react';

const getUser = cache(async (id: string) => {
  const user = await db.user.findUnique({ where: { id } });
  return user;
});

// Multiple calls with same args return cached result within a render pass
async function UserProfile({ id }: { id: string }) {
  const user = await getUser(id);
  return <h1>{user.name}</h1>;
}

async function UserEmail({ id }: { id: string }) {
  const user = await getUser(id); // returns cached result, no extra DB call
  return <p>{user.email}</p>;
}
```

#### 3. Async Params Strictness

```tsx
// Next.js 15: params could sometimes be accessed synchronously
// (worked but warned)
export default async function Page({ params }: { params: { id: string } }) {
  // This might have worked in some cases in 15 but is an error in 16
  const id = params.id;
}

// Next.js 16: params must always be awaited
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return <div>Product: {id}</div>;
}
```

#### 4. Image Defaults Changed

```tsx
// Next.js 15
<Image src="/photo.jpg" alt="Photo" width={800} height={600} />
// Default: quality=75, unoptimized=false

// Next.js 16
<Image src="/photo.jpg" alt="Photo" width={800} height={600} />
// Default: quality=80, AVIF enabled automatically where supported
// `fill` prop prefers `sizes` being set explicitly
```

### Post-Migration Verification

1. Run `next build` with Turbopack (default) and check for errors
2. Verify image optimization (check `<picture>` sources for AVIF)
3. Test all dynamic routes with async params
4. Verify cache deduplication works in Server Components
5. Check bundle size (Turbopack may produce different output)
6. Test production build locally: `next start`

---

## Pages Router to App Router (Incremental)

### Migration Strategy

The App Router coexists with the Pages Router. Migrate incrementally, one route at a time.

### Step 1: Install App Router Alongside Pages Router

```
app/
  layout.tsx        # Root layout (required)
  page.tsx          # Home page (replaces pages/index.tsx)
pages/
  _app.tsx          # Still active for non-migrated routes
  about.tsx         # Still active
  products/
    index.tsx       # Still active
```

### Step 2: Create the Root Layout

```tsx
// app/layout.tsx
export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  );
}
```

### Step 3: Migrate One Route at a Time

```tsx
// pages/about.tsx (Pages Router - before)
import Head from 'next/head';
import Header from '../components/Header';

export default function About() {
  return (
    <>
      <Head>
        <title>About Us</title>
      </Head>
      <Header />
      <main>
        <h1>About Us</h1>
        <p>Our story...</p>
      </main>
    </>
  );
}

// app/about/page.tsx (App Router - after)
import { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'About Us',
};

// Server Component by default (no 'use client')
export default function AboutPage() {
  return (
    <main>
      <h1>About Us</h1>
      <p>Our story...</p>
    </main>
  );
}
```

### Step 4: Migrate Data Fetching

```tsx
// Pages Router: getServerSideProps
export async function getServerSideProps() {
  const products = await getProducts();
  return { props: { products } };
}

export default function Products({ products }) {
  return <ProductList products={products} />;
}

// App Router: direct async in Server Component
export default async function ProductsPage() {
  const products = await getProducts();
  return <ProductList products={products} />;
}
```

```tsx
// Pages Router: getStaticProps + getStaticPaths
export async function getStaticPaths() {
  const products = await getProducts();
  return {
    paths: products.map((p) => ({ params: { id: p.id } })),
    fallback: 'blocking',
  };
}

export async function getStaticProps({ params }) {
  const product = await getProduct(params.id);
  return { props: { product }, revalidate: 3600 };
}

// App Router: generateStaticParams + async component
export async function generateStaticParams() {
  const products = await getProducts();
  return products.map((p) => ({ id: p.id }));
}

export const revalidate = 3600;

export default async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await getProduct(id);
  return <ProductDetail product={product} />;
}
```

### Step 5: Migrate Client-Side Logic

```tsx
// Pages Router: everything is a client component
import { useState, useEffect } from 'react';

export default function Search() {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState([]);

  useEffect(() => {
    fetchResults(query).then(setResults);
  }, [query]);

  return <div>{/* ... */}</div>;
}

// App Router: split into server + client
// app/search/page.tsx (Server Component)
export default async function SearchPage({ searchParams }: { searchParams: Promise<{ q?: string }> }) {
  const { q } = await searchParams;
  const results = q ? await fetchResults(q) : [];
  return (
    <div>
      <SearchInput defaultValue={q} />
      <ResultsList results={results} />
    </div>
  );
}

// app/search/search-input.tsx (Client Component)
'use client';
import { useRouter } from 'next/navigation';

export function SearchInput({ defaultValue }: { defaultValue?: string }) {
  const router = useRouter();
  const [value, setValue] = useState(defaultValue ?? '');

  function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    router.push(`/search?q=${encodeURIComponent(value)}`);
  }

  return (
    <form onSubmit={handleSubmit}>
      <input value={value} onChange={(e) => setValue(e.target.value)} />
      <button type="submit">Search</button>
    </form>
  );
}
```

### Common Gotchas

1. **`_app.tsx` wrappers don't apply to App Router routes** - Migrate providers to `app/layout.tsx`
2. **Custom `Document` doesn't apply to App Router** - Use `app/layout.tsx` for `<html>` and `<body>` tags
3. **Middleware works for both routers** - No changes needed
4. **Static imports of CSS modules work differently** - Use `import styles from './styles.module.css'` in both
5. **API routes remain in `pages/api/`** until migrated to Route Handlers (`app/api/`)

---

## CRA (Create React App) to Next.js or Vite

### CRA to Next.js

```bash
# Install Next.js
npm install next
```

```json
// package.json scripts
{
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  }
}
```

1. Move `public/` contents to Next.js `public/` (compatible)
2. Create `app/layout.tsx` as root layout
3. Create `app/page.tsx` for home route
4. Add `'use client'` to components that use hooks
5. Replace `react-router-dom` with Next.js file-based routing
6. Replace `REACT_APP_*` env vars with `NEXT_PUBLIC_*`

### CRA to Vite

```bash
# Install Vite
npm install vite @vitejs/plugin-react
```

```json
// package.json scripts
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview"
  }
}
```

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
});
```

```html
<!-- Move public/index.html to index.html (root) -->
<!-- Remove %PUBLIC_URL% references -->
```

1. Move `index.html` from `public/` to project root
2. Replace `REACT_APP_*` env vars with `VITE_*`
3. Remove `react-scripts` from dependencies
4. Update TypeScript config to reference Vite types

---

## Class Components to Hooks (Gradual)

### Strategy

1. Start with leaf components (simple, no lifecycle complexity)
2. Move to container components
3. Handle error boundaries last (they require classes in React 19)

### Common Conversions

#### State

```tsx
// Class component
class Counter extends React.Component {
  state = { count: 0 };
  increment = () => this.setState({ count: this.state.count + 1 });
  render() {
    return <button onClick={this.increment}>{this.state.count}</button>;
  }
}

// Hooks
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount((c) => c + 1)}>{count}</button>;
}
```

#### Lifecycle Methods

```tsx
// componentDidMount + componentWillUnmount
class DataFetcher extends React.Component {
  state = { data: null };
  componentDidMount() {
    this.fetchData();
  }
  componentWillUnmount() {
    this.abortController?.abort();
  }
  async fetchData() {
    this.abortController = new AbortController();
    const res = await fetch('/api/data', { signal: this.abortController.signal });
    this.setState({ data: await res.json() });
  }
  render() {
    return <div>{JSON.stringify(this.state.data)}</div>;
  }
}

// Hooks equivalent
function DataFetcher() {
  const { data } = useQuery({
    queryKey: ['data'],
    queryFn: async () => {
      const res = await fetch('/api/data');
      return res.json();
    },
  });
  return <div>{JSON.stringify(data)}</div>;
}
```

#### componentDidUpdate

```tsx
// Class: componentDidUpdate for responding to prop changes
class UserProfile extends React.Component {
  componentDidUpdate(prevProps) {
    if (prevProps.userId !== this.props.userId) {
      this.fetchUser(this.props.userId);
    }
  }
  // ...
}

// Hooks: TanStack Query handles this automatically
function UserProfile({ userId }: { userId: string }) {
  const { data: user } = useQuery({
    queryKey: ['user', userId],
    queryFn: () => fetchUser(userId),
  });
  // Query re-fetches when userId changes
  return <div>{user?.name}</div>;
}
```

#### shouldComponentUpdate / React.memo

```tsx
// Class: shouldComponentUpdate
class ExpensiveList extends React.Component {
  shouldComponentUpdate(nextProps) {
    return nextProps.items !== this.props.items;
  }
  render() {
    return <ul>{this.props.items.map(i => <li key={i.id}>{i.name}</li>)}</ul>;
  }
}

// Hooks: React.memo (or React Compiler)
const ExpensiveList = React.memo(function ExpensiveList({ items }: { items: Item[] }) {
  return <ul>{items.map((i) => <li key={i.id}>{i.name}</li>)}</ul>;
});
```

### What Stays as a Class

Error boundaries still require class components in React 19:

```tsx
class ErrorBoundary extends React.Component<
  { children: React.ReactNode; fallback: React.ReactNode },
  { hasError: boolean }
> {
  state = { hasError: false };

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error: Error, info: React.ErrorInfo) {
    console.error('Error caught:', error, info);
  }

  render() {
    if (this.state.hasError) return this.props.fallback;
    return this.props.children;
  }
}
```

---

## Common Errors and Fixes

### Error: `params` must be awaited

```tsx
// Error in Next.js 16
export default function Page({ params }: { params: { id: string } }) {
  return <div>{params.id}</div>; // TypeError: params.id is undefined
}

// Fix
export default async function Page({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  return <div>{id}</div>;
}
```

### Error: Hydration Mismatch After Migration

```tsx
// Common cause: client-only state initialized differently than server
'use client';
function ClientComponent() {
  const [value, setValue] = useState(window.innerWidth > 768 ? 'desktop' : 'mobile');
  // Server doesn't have window -> hydration mismatch

  // Fix: use useEffect for client-only initialization
  const [value, setValue] = useState('desktop'); // safe default
  useEffect(() => {
    setValue(window.innerWidth > 768 ? 'desktop' : 'mobile');
  }, []);
}
```

### Error: Missing `use client` Directive

```tsx
// Error: useState can only be used in client components
// If a component uses hooks but is in the app/ directory without 'use client':

// Fix: add 'use client' at the top of the file
'use client';
import { useState } from 'react';

export function InteractiveWidget() {
  const [isOpen, setIsOpen] = useState(false);
  // ...
}
```
