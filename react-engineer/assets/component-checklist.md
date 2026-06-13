# Pre-Merge Checklist for React Components

Use this checklist before merging any React component or feature. Each item should be verified.

---

## Props

- [ ] All props are typed with TypeScript interfaces (no `any`)
- [ ] Optional props have sensible defaults (via default parameters, not `defaultProps`)
- [ ] No unnecessary props that duplicate state already available elsewhere
- [ ] Props use discriminated unions for mutually exclusive variants
- [ ] Callback props have proper event types (e.g., `React.MouseEvent<HTMLButtonElement>`)
- [ ] Complex prop objects use `readonly` for invariant fields
- [ ] Props are documented with JSDoc if purpose is not obvious from name

```tsx
// Good prop typing
interface CardProps {
  /** Product to display in the card */
  product: Product;
  /** Called when the user clicks the card */
  onClick?: (product: Product) => void;
  /** Visual variant of the card */
  variant?: 'default' | 'compact' | 'featured';
}

// Bad: untyped or overly broad
interface CardProps {
  product: any;
  onClick?: Function;
  variant?: string;
}
```

---

## State

- [ ] State is minimal: no derived state in `useState` (compute during render instead)
- [ ] State lives in the right place (URL, server cache, global store, or local)
- [ ] No state duplication (same data in multiple places)
- [ ] Boolean state uses descriptive names (`isOpen`, not `flag`)
- [ ] Complex state transitions use `useReducer` instead of multiple `useState`
- [ ] State updates use functional form when depending on previous state

```tsx
// Bad: derived state in useState
const [total, setTotal] = useState(0);
useEffect(() => {
  setTotal(items.reduce((sum, i) => sum + i.price, 0));
}, [items]);

// Good: compute during render
const total = items.reduce((sum, i) => sum + i.price, 0);

// Bad: multiple related booleans
const [isLoading, setIsLoading] = useState(false);
const [hasError, setHasError] = useState(false);
const [isSuccess, setIsSuccess] = useState(false);

// Good: single state variable with union type
const [status, setStatus] = useState<'idle' | 'loading' | 'success' | 'error'>('idle');
```

---

## Effects

- [ ] All dependencies are listed in the dependency array
- [ ] No unnecessary dependencies that cause extra runs
- [ ] Cleanup functions are present for subscriptions, timers, and observers
- [ ] No race conditions (use `AbortController` or cancellation flags)
- [ ] Effects that should run once have stable dependencies (or explicit comment explaining why)

```tsx
// Good: proper cleanup and dependency
useEffect(() => {
  const controller = new AbortController();

  async function fetchData() {
    try {
      const res = await fetch(`/api/data/${id}`, { signal: controller.signal });
      setData(await res.json());
    } catch (err) {
      if (!controller.signal.aborted) setError(err);
    }
  }

  fetchData();
  return () => controller.abort();
}, [id]); // Only re-run when id changes

// Bad: missing cleanup, missing dependency
useEffect(() => {
  const interval = setInterval(() => {
    setCount(count + 1); // Stale closure!
  }, 1000);
  // No cleanup!
}, []); // count not in deps
```

---

## Accessibility

- [ ] Semantic HTML elements used (`<button>`, `<nav>`, `<main>`, `<article>`)
- [ ] All interactive elements are keyboard accessible (tab navigation, Enter/Space activation)
- [ ] ARIA labels on icon-only buttons and non-text content
- [ ] Form inputs have associated `<label>` elements
- [ ] Error messages linked to inputs via `aria-describedby`
- [ ] `aria-invalid` on inputs with validation errors
- [ ] Focus management for modals, drawers, and dialogs
- [ ] Skip navigation links where appropriate
- [ ] Color is not the only indicator of state (use icons or text too)
- [ ] Tab order is logical
- [ ] `aria-live` regions for dynamic content updates

```tsx
// Good: accessible button
<button
  onClick={handleDelete}
  aria-label={`Delete ${product.name}`}
  className="text-red-600 hover:text-red-800"
>
  <TrashIcon aria-hidden="true" />
</button>

// Good: accessible form input
<div>
  <label htmlFor="email">Email address</label>
  <input
    id="email"
    type="email"
    value={email}
    onChange={(e) => setEmail(e.target.value)}
    aria-invalid={!!errors.email}
    aria-describedby={errors.email ? 'email-error' : undefined}
  />
  {errors.email && (
    <p id="email-error" role="alert">{errors.email}</p>
  )}
</div>
```

---

## Performance

- [ ] No unnecessary re-renders (state pushed down to leaf components)
- [ ] Heavy computations memoized (or handled by React Compiler)
- [ ] Large lists use virtualization (`@tanstack/react-virtual` or similar)
- [ ] Images use `next/image` with proper `width`, `height`, and `sizes`
- [ ] Dynamic imports for code splitting heavy components
- [ ] No inline object/function creation in render that causes child re-renders
- [ ] React Compiler is active (or manual memoization applied)

```tsx
// Good: push state down
function Parent() {
  return (
    <div>
      <StaticHeader /> {/* Won't re-render when sibling state changes */}
      <InteractiveContent /> {/* Owns its own state */}
    </div>
  );
}

// Good: dynamic import for heavy component
const HeavyChart = dynamic(() => import('./heavy-chart'), {
  loading: () => <ChartSkeleton />,
  ssr: false, // If chart depends on browser APIs
});
```

---

## Testing

- [ ] Unit tests for business logic and state transformations
- [ ] Integration tests for user interactions (click, type, submit)
- [ ] Edge cases tested (empty state, error state, loading state)
- [ ] Accessibility tested (axe-core or similar)
- [ ] No testing implementation details (test behavior, not state)

```tsx
// Good: test behavior
test('submitting valid shipping form advances to payment', async () => {
  render(<ShippingStep />);

  await userEvent.type(screen.getByLabelText(/first name/i), 'John');
  await userEvent.type(screen.getByLabelText(/last name/i), 'Doe');
  // ... fill other required fields

  await userEvent.click(screen.getByRole('button', { name: /continue/i }));

  await waitFor(() => {
    expect(mockPush).toHaveBeenCalledWith('/checkout/payment');
  });
});

// Bad: testing implementation details
test('sets shipping state on submit', () => {
  const { result } = renderHook(() => useCheckoutStore());
  act(() => result.current.setShipping({ firstName: 'John' }));
  expect(result.current.shipping.firstName).toBe('John'); // Tests store, not UI
});
```

---

## Server/Client Boundary

- [ ] `'use client'` only on components that need it (event handlers, hooks, browser APIs)
- [ ] Server Components for data fetching, static content, SEO-critical content
- [ ] No server-only code in client components (no `fs`, `db`, env vars without `NEXT_PUBLIC_`)
- [ ] Client boundary pushed as far down the tree as possible
- [ ] Props passed from server to client are serializable (no functions, no class instances)

```tsx
// Good: server component fetches data, passes to client leaf
// app/products/page.tsx (Server Component)
async function ProductsPage() {
  const products = await db.product.findMany(); // Server-only
  return <ProductGrid products={products} />;    // Pass serializable data
}

// components/product-grid.tsx (Server Component)
function ProductGrid({ products }: { products: Product[] }) {
  return (
    <div className="grid grid-cols-4 gap-4">
      {products.map((p) => <ProductCard key={p.id} product={p} />)}
    </div>
  );
}

// components/product-card.tsx (Client Component)
'use client';
function ProductCard({ product }: { product: Product }) {
  const [isHovered, setIsHovered] = useState(false); // Needs client
  return <div onMouseEnter={() => setIsHovered(true)}>...</div>;
}
```

---

## Error Handling

- [ ] Loading states for async operations (Skeleton UI, not spinners)
- [ ] Error states with user-friendly messages and retry options
- [ ] Error boundaries wrapping risky components
- [ ] Server Actions return typed error objects (not thrown exceptions for validation)
- [ ] Network errors handled gracefully (retry, offline message)
- [ ] No uncaught promise rejections

```tsx
// Good: proper error and loading states
function ProductList() {
  const { data, isLoading, error, refetch } = useProducts(filters);

  if (isLoading) return <ProductListSkeleton />;
  if (error) {
    return (
      <div role="alert" className="text-center py-8">
        <p className="text-red-600">Failed to load products</p>
        <button onClick={() => refetch()} className="mt-2 text-blue-600">
          Try again
        </button>
      </div>
    );
  }

  return <div>{data.products.map((p) => <ProductCard key={p.id} product={p} />)}</div>;
}
```

---

## Responsive Design

- [ ] Works at 320px, 768px, 1024px, and 1440px widths
- [ ] Touch targets are at least 44x44px on mobile
- [ ] Content doesn't overflow or clip at any breakpoint
- [ ] Images are responsive with proper `sizes` attribute
- [ ] Navigation collapses to mobile menu on small screens
- [ ] Forms are usable on mobile (appropriate input types, no horizontal scroll)

---

## Security

- [ ] No XSS vectors (`dangerouslySetInnerHTML` only with sanitized content)
- [ ] No sensitive data in client-side code (API keys, secrets in `NEXT_PUBLIC_` vars)
- [ ] Server Actions validate all inputs with Zod or equivalent
- [ ] User authentication checked before any mutation
- [ ] No user-controlled data in redirect URLs without validation
- [ ] Form submissions have CSRF protection (built into Next.js Server Actions)
