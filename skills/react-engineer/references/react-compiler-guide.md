# React Compiler v1.0 Guide

## What It Does

The React Compiler (formerly React Forget) automatically memoizes your React components. It eliminates the need for manual `useMemo`, `useCallback`, and `React.memo` by analyzing your component code at build time and injecting the appropriate memoization.

**Before (manual memoization):**

```tsx
const ExpensiveList = React.memo(function ExpensiveList({ items, filter, onSelect }) {
  const filtered = useMemo(() => items.filter(filter), [items, filter]);
  const handleClick = useCallback((id: string) => {
    onSelect(id);
  }, [onSelect]);

  return (
    <ul>
      {filtered.map((item) => (
        <li key={item.id} onClick={() => handleClick(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
});
```

**After (React Compiler handles it):**

```tsx
function ExpensiveList({ items, filter, onSelect }) {
  // No useMemo, useCallback, or React.memo needed
  const filtered = items.filter(filter);

  return (
    <ul>
      {filtered.map((item) => (
        <li key={item.id} onClick={() => onSelect(item.id)}>
          {item.name}
        </li>
      ))}
    </ul>
  );
}
```

The compiler analyzes the component and automatically memoizes `filtered`, the click handler, and the component itself.

---

## Setup

### General React (Babel)

```bash
npm install babel-plugin-react-compiler
```

```json
// babel.config.json
{
  "presets": ["@babel/preset-react"],
  "plugins": ["babel-plugin-react-compiler"]
}
```

If using Vite with Babel:

```ts
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [
    react({
      babel: {
        plugins: [['babel-plugin-react-compiler', { target: '19' }]],
      },
    }),
  ],
});
```

### Next.js

```js
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  reactCompiler: {
    // enabled by default in Next.js 16 when using React 19.x
    // opt-in for Next.js 15.x
    target: '19',
  },
};

module.exports = nextConfig;
```

For Next.js 16 with Turbopack (default bundler):

```js
// next.config.js
const nextConfig = {
  reactCompiler: true, // uses default settings
};

module.exports = nextConfig;
```

---

## How It Works

The compiler performs static analysis of your component's render function:

1. **Dependency tracking**: Identifies which values depend on which props/state
2. **Mutation tracking**: Determines which values are stable vs. recomputed
3. **Cache insertion**: Injects useMemo-like caching for expensive computations
4. **Reference stability**: Ensures inline functions and objects maintain referential equality

### What Gets Memoized

```tsx
function ProductPage({ productId }: { productId: string }) {
  const [quantity, setQuantity] = useState(1);

  // Compiler memoizes this computation (depends on productId)
  const product = getProduct(productId);

  // Compiler memoizes this (depends on product and quantity)
  const totalPrice = product.price * quantity;

  // Compiler ensures this function reference is stable
  function handleAddToCart() {
    addToCart(productId, quantity);
  }

  // Compiler ensures this object reference is stable when values haven't changed
  const orderData = { productId, quantity, totalPrice };

  return (
    <div>
      <h1>{product.name}</h1>
      <p>${totalPrice}</p>
      <QuantityPicker value={quantity} onChange={setQuantity} />
      <button onClick={handleAddToCart}>Add to Cart</button>
      <OrderSummary data={orderData} />
    </div>
  );
}
```

### Compilation Output (Simplified)

The compiler transforms the above into something roughly equivalent to:

```tsx
function ProductPage(props) {
  const { productId } = props;
  const [quantity, setQuantity] = useState(1);

  // Memoized computation
  const product = useMemo(() => getProduct(productId), [productId]);

  // Memoized derived value
  const totalPrice = useMemo(() => product.price * quantity, [product.price, quantity]);

  // Stable function reference
  const handleAddToCart = useCallback(() => {
    addToCart(productId, quantity);
  }, [productId, quantity]);

  // Stable object reference
  const orderData = useMemo(
    () => ({ productId, quantity, totalPrice }),
    [productId, quantity, totalPrice]
  );

  // ... rest
}
```

---

## Opt-Out: `'use no memo'` Directive

If the compiler causes issues with a specific component, opt out per-file or per-function:

```tsx
// Opt out the entire file
'use no memo';

import { useState } from 'react';

export function ProblematicComponent() {
  // This component is compiled without the React Compiler
  const [value, setValue] = useState('');
  return <input value={value} onChange={(e) => setValue(e.target.value)} />;
}
```

```tsx
// Opt out a specific function within a compiled file
'use memo'; // (default, explicit)

import { useState } from 'react';

function CompiledComponent() {
  // This IS compiled by React Compiler
  const data = expensiveComputation();
  return <div>{data}</div>;
}

function ManualComponent() {
  'use no memo'; // opt-out for this specific function
  // This is NOT compiled by React Compiler
  const data = expensiveComputation();
  return <div>{data}</div>;
}
```

---

## Known Limitations

### 1. Closures Over Mutable Refs

The compiler cannot track mutations through `useRef` values used in closures.

```tsx
function Counter() {
  const countRef = useRef(0);

  // The compiler may not memoize this correctly because
  // countRef.current can be mutated without triggering a re-render
  function increment() {
    countRef.current += 1;
    console.log(countRef.current);
  }

  return <button onClick={increment}>Count: {countRef.current}</button>;
}
```

**Workaround**: Use state instead of refs for values that affect rendering.

### 2. Side Effects in Render

The compiler assumes render is pure. Side effects in render will cause incorrect memoization.

```tsx
// BAD: Side effect during render
function BadComponent({ userId }: { userId: string }) {
  // Compiler will memoize this, but the side effect won't re-run when it should
  const user = fetchUserSync(userId); // side effect!
  document.title = `User: ${user.name}`; // side effect!
  return <div>{user.name}</div>;
}

// GOOD: Side effects in useEffect
function GoodComponent({ userId }: { userId: string }) {
  const { data: user } = useQuery({ queryKey: ['user', userId], queryFn: () => fetchUser(userId) });

  useEffect(() => {
    if (user) document.title = `User: ${user.name}`;
  }, [user]);

  return <div>{user?.name}</div>;
}
```

### 3. External Store Patterns

`useSyncExternalStore` with complex getSnapshot functions may not be fully optimized.

```tsx
// The compiler may not fully optimize external store subscriptions
import { useSyncExternalStore } from 'react';

function useOnlineStatus() {
  return useSyncExternalStore(
    (callback) => {
      window.addEventListener('online', callback);
      window.addEventListener('offline', callback);
      return () => {
        window.removeEventListener('online', callback);
        window.removeEventListener('offline', callback);
      };
    },
    () => navigator.onLine,
    () => true // server snapshot
  );
}
```

### 4. Higher-Order Components

HOCs that modify component behavior may interfere with the compiler's analysis.

```tsx
// May not be fully optimized by the compiler
const EnhancedComponent = withAuth(withTheme(withRouter(MyComponent)));

// Prefer hooks instead
function MyComponent() {
  const auth = useAuth();
  const theme = useTheme();
  const router = useRouter();
  // Compiler can fully optimize this
}
```

### 5. Dynamic Property Access

```tsx
// The compiler struggles with computed property keys
function DynamicAccess({ data, field }: { data: Record<string, string>; field: string }) {
  const value = data[field]; // Compiler may not memoize optimally
  return <div>{value}</div>;
}

// Prefer explicit access when possible
function StaticAccess({ data }: { data: { name: string; email: string } }) {
  const { name, email } = data; // Compiler handles this well
  return <div>{name} - {email}</div>;
}
```

---

## Integration with React 19.x and Next.js 16

### React 19.x

React 19 is the primary target for the compiler. Key features that pair well:

```tsx
// React 19: use() hook + compiler memoization
import { use, useMemo } from 'react';

function UserProfile({ userPromise }: { userPromise: Promise<User> }) {
  // The compiler automatically memoizes the resolved value
  const user = use(userPromise);
  return <h1>{user.name}</h1>;
}

// React 19: Actions + compiler
function CommentForm() {
  async function handleSubmit(formData: FormData) {
    // Compiler ensures stable reference
    await submitComment(formData);
  }

  return (
    <form action={handleSubmit}>
      <textarea name="comment" />
      <button type="submit">Submit</button>
    </form>
  );
}
```

### Next.js 16

```tsx
// next.config.js
const nextConfig = {
  reactCompiler: true, // enabled with React 19
};

// Server Components are NOT compiled (they don't re-render)
// Client Components ARE compiled automatically
```

```tsx
// This Server Component is NOT processed by the compiler
async function ProductPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const product = await db.product.findUnique({ where: { id } });
  return <ProductDetail product={product} />;
}

// This Client Component IS processed by the compiler
'use client';
function ProductDetail({ product }: { product: Product }) {
  const [quantity, setQuantity] = useState(1);
  // Compiler automatically memoizes these:
  const total = product.price * quantity;
  const handleAdd = () => addToCart(product.id, quantity);
  return (
    <div>
      <p>Total: ${total}</p>
      <button onClick={handleAdd}>Add</button>
    </div>
  );
}
```

---

## Performance Implications

### Compile-Time Cost

The compiler adds build-time overhead:

| Project Size | Added Compile Time |
|:-------------|:-------------------|
| Small (< 50 components) | +1-3 seconds |
| Medium (50-200 components) | +5-15 seconds |
| Large (200+ components) | +15-45 seconds |

Mitigate with incremental compilation (Next.js Turbopack handles this automatically).

### Runtime Savings

| Metric | Before Compiler | After Compiler |
|:-------|:---------------|:---------------|
| Unnecessary re-renders | Frequent | Eliminated |
| Bundle size | Manual memo hooks | Compiler-generated (comparable) |
| Runtime CPU | Re-computes every render | Cached computations |

### When the Compiler Hurts

```tsx
// If the component already re-renders rarely (e.g., stable props from parent)
// and computations are cheap, the compiler's overhead is wasted

function SimpleLabel({ text }: { text: string }) {
  // This is already as fast as it gets
  // Compiler memoization adds unnecessary overhead
  return <span>{text}</span>;
}
```

---

## Debugging

### Compiler Errors

The compiler will emit errors for code it cannot analyze:

```tsx
// Error: [React Compiler] Unexpected side effect in render
function BadComponent() {
  window.scrollTo(0, 0); // Side effect in render
  return <div>Hello</div>;
}

// Fix: Move to useEffect
function GoodComponent() {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);
  return <div>Hello</div>;
}
```

### Unexpected Re-Renders

If you notice components still re-rendering unnecessarily:

1. Check if the compiler is actually processing the file (look for `'use no memo'` directives)
2. Use React DevTools Profiler to identify what's causing re-renders
3. Verify props are not creating new references in parent components

```tsx
// If parent creates new objects every render, child still re-renders
// even with the compiler
function Parent() {
  // This creates a new object every render
  const config = { theme: 'dark', locale: 'en' };
  return <Child config={config} />;
}

// Fix: hoist stable values
const defaultConfig = { theme: 'dark', locale: 'en' };

function Parent() {
  return <Child config={defaultConfig} />;
}
```

### DevTools Integration

React DevTools shows which components are compiled by the React Compiler. Look for the "Memoized by Compiler" badge in the component tree.

---

## Migration Strategy

### Phase 1: Opt-In per Route

```js
// next.config.js
const nextConfig = {
  reactCompiler: {
    // Only compile specific directories initially
    compilationMode: 'opt-in',
  },
};
```

```tsx
// Add 'use memo' to files you want compiled
'use memo';

export function MyComponent() {
  // ...
}
```

### Phase 2: Expand Coverage

Gradually add the directive to more components, testing after each batch.

### Phase 3: Remove Manual Memoization

Once the compiler is active across your codebase, remove manual memoization:

```tsx
// Before migration
const memoizedValue = useMemo(() => expensiveCalc(a, b), [a, b]);
const memoizedFn = useCallback((x) => doSomething(x, y), [y]);
const MemoChild = React.memo(ChildComponent);

// After migration (compiler handles it)
const value = expensiveCalc(a, b);
const fn = (x) => doSomething(x, y);
// Just use ChildComponent directly
```

### Testing Approach

1. **Visual regression tests**: Compare screenshots before/after enabling compiler
2. **Performance benchmarks**: Measure render counts with React DevTools Profiler
3. **Unit tests**: Ensure computed values remain correct
4. **Bundle analysis**: Verify bundle size hasn't grown unexpectedly

```tsx
// Test that memoization works correctly
import { render, screen } from '@testing-library/react';

test('computed values are correct with compiler', () => {
  const { rerender } = render(<ExpensiveComponent input="test" />);
  expect(screen.getByText('computed: test')).toBeInTheDocument();

  rerender(<ExpensiveComponent input="updated" />);
  expect(screen.getByText('computed: updated')).toBeInTheDocument();
});
```
