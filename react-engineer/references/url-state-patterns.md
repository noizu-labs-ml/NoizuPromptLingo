# URL-as-State Patterns for React/Next.js

## Overview

Using the URL as the primary source of truth for application state enables deep linking, shareable states, browser back/forward support, and server-side rendering without client hydration mismatches. This guide covers every pattern you need.

---

## 1. URL Search Params as Primary State

The URL should drive any state that:
- Affects what data is displayed (filters, search queries, sort order)
- Determines the current view (tabs, pagination, modal open/close)
- Should survive a page refresh or be shareable

```tsx
// Bad: state lives only in React
const [page, setPage] = useState(1);
const [sort, setSort] = useState('newest');
const [filter, setFilter] = useState('all');

// Good: state lives in the URL
// /products?page=2&sort=newest&filter=electronics
```

---

## 2. Reading Search Params

### Next.js App Router: `useSearchParams()`

```tsx
'use client';

import { useSearchParams, useRouter, usePathname } from 'next/navigation';

function ProductFilters() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const pathname = usePathname();

  const category = searchParams.get('category') ?? 'all';
  const sort = searchParams.get('sort') ?? 'newest';
  const page = Number(searchParams.get('page') ?? '1');

  function updateParams(updates: Record<string, string | null>) {
    const params = new URLSearchParams(searchParams.toString());
    for (const [key, value] of Object.entries(updates)) {
      if (value === null || value === '') {
        params.delete(key);
      } else {
        params.set(key, value);
      }
    }
    router.push(`${pathname}?${params.toString()}`);
  }

  return (
    <div>
      <select
        value={category}
        onChange={(e) => updateParams({ category: e.target.value, page: '1' })}
      >
        <option value="all">All Categories</option>
        <option value="electronics">Electronics</option>
        <option value="clothing">Clothing</option>
      </select>

      <select
        value={sort}
        onChange={(e) => updateParams({ sort: e.target.value, page: '1' })}
      >
        <option value="newest">Newest</option>
        <option value="price-asc">Price: Low to High</option>
        <option value="price-desc">Price: High to Low</option>
      </select>
    </div>
  );
}
```

### React Router DOM: `useSearchParams`

```tsx
import { useSearchParams } from 'react-router-dom';

function ProductFilters() {
  const [searchParams, setSearchParams] = useSearchParams();

  const category = searchParams.get('category') ?? 'all';
  const sort = searchParams.get('sort') ?? 'newest';

  function updateParams(updates: Record<string, string | null>) {
    setSearchParams((prev) => {
      const next = new URLSearchParams(prev);
      for (const [key, value] of Object.entries(updates)) {
        if (value === null || value === '') {
          next.delete(key);
        } else {
          next.set(key, value);
        }
      }
      return next;
    });
  }

  return (
    <div>
      <select
        value={category}
        onChange={(e) => updateParams({ category: e.target.value, page: '1' })}
      >
        <option value="all">All</option>
        <option value="electronics">Electronics</option>
      </select>
    </div>
  );
}
```

---

## 3. Serialization Strategies

### Strategy A: Flat Key-Value (Recommended for most cases)

```
/products?category=electronics&sort=newest&page=2
```

Simple, readable, SEO-friendly, no parsing needed.

### Strategy B: Custom Parser for Complex Values

```tsx
// Encoding arrays in URL params
// ?tags=react,vue,svelte&price=100-500
function parseSearchParams(params: URLSearchParams) {
  const tags = params.get('tags')?.split(',').filter(Boolean) ?? [];
  const priceRange = params.get('price')?.split('-').map(Number) ?? [0, 10000];
  return { tags, priceRange };
}

function serializeToParams(state: FilterState): URLSearchParams {
  const params = new URLSearchParams();
  if (state.tags.length > 0) params.set('tags', state.tags.join(','));
  if (state.priceRange[0] > 0 || state.priceRange[1] < 10000) {
    params.set('price', `${state.priceRange[0]}-${state.priceRange[1]}`);
  }
  return params;
}
```

### Strategy C: JSON in Hash (For complex, non-SEO state)

```tsx
// Use the hash fragment for complex state that shouldn't be sent to the server
// /products#{"view":"grid","columns":["name","price","stock"]}
function useHashState<T>(defaultValue: T) {
  const [state, setState] = useState<T>(() => {
    try {
      const hash = window.location.hash.slice(1);
      return hash ? JSON.parse(decodeURIComponent(hash)) : defaultValue;
    } catch {
      return defaultValue;
    }
  });

  useEffect(() => {
    const serialized = encodeURIComponent(JSON.stringify(state));
    window.history.replaceState(null, '', `#${serialized}`);
  }, [state]);

  return [state, setState] as const;
}
```

### Strategy D: Compressed Base64 (For large state objects)

```tsx
import { compressToEncodedURIComponent, decompressFromEncodedURIComponent } from 'lz-string';

function useCompressedUrlState<T>(key: string, defaultValue: T) {
  const searchParams = useSearchParams()[0];
  const router = useRouter();
  const pathname = usePathname();

  const state = useMemo<T>(() => {
    const compressed = searchParams.get(key);
    if (!compressed) return defaultValue;
    try {
      const json = decompressFromEncodedURIComponent(compressed);
      return JSON.parse(json);
    } catch {
      return defaultValue;
    }
  }, [searchParams, key, defaultValue]);

  function setState(newState: T) {
    const json = JSON.stringify(newState);
    const compressed = compressToEncodedURIComponent(json);
    const params = new URLSearchParams(searchParams.toString());
    params.set(key, compressed);
    router.push(`${pathname}?${params.toString()}`);
  }

  return [state, setState] as const;
}
```

---

## 4. Shallow Routing: Update URL Without Full Re-Render

### Next.js: `window.history.replaceState`

```tsx
'use client';

import { usePathname, useRouter } from 'next/navigation';
import { useCallback } from 'react';

function useShallowSearchParams() {
  const pathname = usePathname();
  const router = useRouter();

  const shallowUpdate = useCallback(
    (updates: Record<string, string | null>) => {
      const params = new URLSearchParams(window.location.search);
      for (const [key, value] of Object.entries(updates)) {
        if (value === null || value === '') {
          params.delete(key);
        } else {
          params.set(key, value);
        }
      }
      // replaceState avoids a navigation/re-render
      window.history.replaceState(null, '', `${pathname}?${params.toString()}`);
    },
    [pathname]
  );

  return { shallowUpdate };
}
```

### Next.js: `router.replace` with `scroll: false`

```tsx
// Soft navigation without scrolling to top
router.replace(`${pathname}?${params.toString()}`, { scroll: false });
```

---

## 5. Synchronizing URL State with Server State

### Pattern: URL Params Drive TanStack Query Keys

```tsx
'use client';

import { useSearchParams } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';

function ProductList() {
  const searchParams = useSearchParams();

  const filters = {
    category: searchParams.get('category') ?? 'all',
    sort: searchParams.get('sort') ?? 'newest',
    page: Number(searchParams.get('page') ?? '1'),
    query: searchParams.get('q') ?? '',
  };

  // URL params are part of the query key — URL change = refetch
  const { data, isLoading } = useQuery({
    queryKey: ['products', filters],
    queryFn: () => fetchProducts(filters),
  });

  if (isLoading) return <ProductListSkeleton />;

  return (
    <div>
      {data.products.map((product) => (
        <ProductCard key={product.id} product={product} />
      ))}
      <Pagination
        currentPage={filters.page}
        totalPages={data.totalPages}
      />
    </div>
  );
}
```

### Pattern: URL Params Drive SWR

```tsx
import useSWR from 'swr';

function useProducts(filters: ProductFilters) {
  const params = new URLSearchParams();
  if (filters.category !== 'all') params.set('category', filters.category);
  if (filters.sort !== 'newest') params.set('sort', filters.sort);
  params.set('page', String(filters.page));

  const { data, error, isLoading } = useSWR(
    `/api/products?${params.toString()}`,
    fetcher,
    { keepPreviousData: true }
  );

  return { data, error, isLoading };
}
```

---

## 6. Debounced URL Updates for Search Inputs

Typing in a search box should not push a new history entry per keystroke.

```tsx
'use client';

import { useSearchParams, useRouter, usePathname } from 'next/navigation';
import { useCallback, useRef, useState } from 'react';

function SearchInput() {
  const searchParams = useSearchParams();
  const router = useRouter();
  const pathname = usePathname();

  const currentQuery = searchParams.get('q') ?? '';
  const [inputValue, setInputValue] = useState(currentQuery);
  const debounceRef = useRef<ReturnType<typeof setTimeout>>();

  const updateSearch = useCallback(
    (value: string) => {
      const params = new URLSearchParams(searchParams.toString());
      if (value) {
        params.set('q', value);
      } else {
        params.delete('q');
      }
      params.set('page', '1'); // reset page on new search
      router.push(`${pathname}?${params.toString()}`);
    },
    [searchParams, router, pathname]
  );

  function handleChange(e: React.ChangeEvent<HTMLInputElement>) {
    const value = e.target.value;
    setInputValue(value);

    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      updateSearch(value);
    }, 300);
  }

  return (
    <input
      type="search"
      value={inputValue}
      onChange={handleChange}
      placeholder="Search products..."
    />
  );
}
```

---

## 7. Deep Linking: Every State Change Reflected in URL

The principle: if a user copies the URL and opens it in a new tab, they see the exact same view.

```tsx
'use client';

import { useSearchParams, useRouter, usePathname } from 'next/navigation';
import { useCallback, useMemo } from 'react';

interface ListState {
  page: number;
  sort: string;
  filters: Record<string, string>;
  view: 'grid' | 'table';
}

function useListState(): [ListState, (updates: Partial<ListState>) => void] {
  const searchParams = useSearchParams();
  const router = useRouter();
  const pathname = usePathname();

  const state: ListState = useMemo(
    () => ({
      page: Number(searchParams.get('page') ?? '1'),
      sort: searchParams.get('sort') ?? 'newest',
      filters: Object.fromEntries(
        searchParams.getAll('filter').map((f) => f.split(':') as [string, string])
      ),
      view: (searchParams.get('view') as 'grid' | 'table') ?? 'grid',
    }),
    [searchParams]
  );

  const setState = useCallback(
    (updates: Partial<ListState>) => {
      const params = new URLSearchParams(searchParams.toString());
      const next = { ...state, ...updates };

      params.set('page', String(next.page));
      params.set('sort', next.sort);
      params.delete('filter');
      for (const [key, value] of Object.entries(next.filters)) {
        params.append('filter', `${key}:${value}`);
      }
      params.set('view', next.view);

      router.push(`${pathname}?${params.toString()}`);
    },
    [searchParams, router, pathname, state]
  );

  return [state, setState];
}
```

---

## 8. Sharing URLs That Preserve Exact State

```tsx
function ShareButton() {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const shareUrl = `${window.location.origin}${pathname}?${searchParams.toString()}`;

  async function handleShare() {
    if (navigator.share) {
      await navigator.share({ url: shareUrl });
    } else {
      await navigator.clipboard.writeText(shareUrl);
      toast.success('Link copied to clipboard');
    }
  }

  return <button onClick={handleShare}>Share Current View</button>;
}
```

---

## 9. Pattern: URL to Server Component to Client Hydration

```tsx
// app/products/page.tsx (Server Component)
interface PageProps {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}

export default async function ProductsPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const category = typeof params.category === 'string' ? params.category : 'all';
  const page = Number(params.page ?? '1');
  const sort = typeof params.sort === 'string' ? params.sort : 'newest';

  // Server-side data fetch using URL params
  const products = await db.product.findMany({
    where: category !== 'all' ? { category } : undefined,
    orderBy: getOrderBy(sort),
    skip: (page - 1) * 20,
    take: 20,
  });

  return (
    <div>
      <ProductFiltersServer category={category} sort={sort} />
      <ProductGrid products={products} />
      <PaginationServer currentPage={page} basePath="/products" />
    </div>
  );
}
```

---

## 10. Pattern: URL to Client State Sync to API Call

```tsx
'use client';

import { useSearchParams, useRouter, usePathname } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';

function useUrlDrivenQuery<T>(options: {
  queryKeyPrefix: string;
  buildUrl: (params: URLSearchParams) => string;
  select?: (data: unknown) => T;
}) {
  const searchParams = useSearchParams();

  return useQuery({
    queryKey: [options.queryKeyPrefix, searchParams.toString()],
    queryFn: async () => {
      const res = await fetch(options.buildUrl(searchParams));
      if (!res.ok) throw new Error('Fetch failed');
      return res.json();
    },
    select: options.select,
  });
}

// Usage
function OrderList() {
  const { data } = useUrlDrivenQuery({
    queryKeyPrefix: 'orders',
    buildUrl: (params) => `/api/orders?${params.toString()}`,
  });

  return <div>{/* render orders */}</div>;
}
```

---

## 11. Anti-Patterns

### Storing Too Much in URL

```tsx
// BAD: Entire form state in URL params
// /checkout?name=John&address=123+Main&card=4111...&cvv=123
// Problems: URL length limits, sensitive data exposed, bookmark pollution

// GOOD: Only store what defines the view
// /checkout?step=shipping
// Keep form data in local state or server session
```

### Sensitive Data in URL

```tsx
// BAD: Auth tokens or personal data in search params
// /dashboard?token=abc123&userId=456&email=user@example.com
// URLs appear in: browser history, server logs, analytics, referrer headers

// GOOD: Use cookies or session storage for sensitive data
// /dashboard (token in HttpOnly cookie)
```

### Storing Derived/Computed State in URL

```tsx
// BAD: Storing both page and offset (redundant)
// /list?page=3&offset=60

// GOOD: Store only the primary source and derive the rest
// /list?page=3
// const offset = (page - 1) * PAGE_SIZE; // derived
```

### Pushing History Entries for Trivial Changes

```tsx
// BAD: Every keystroke creates a new history entry
function SearchInput() {
  const router = useRouter();
  return (
    <input
      onChange={(e) => {
        router.push(`/search?q=${e.target.value}`); // 10 entries for "hello"
      }}
    />
  );
}

// GOOD: Debounce and use replace for search-as-you-type
// Use router.replace or debounce to collapse intermediate states
```

---

## 12. Testing URL State

```tsx
import { render, screen } from '@testing-library/react';
import { useRouter, useSearchParams, usePathname } from 'next/navigation';

// Mock Next.js navigation
jest.mock('next/navigation', () => ({
  useRouter: jest.fn(),
  useSearchParams: jest.fn(),
  usePathname: jest.fn(),
}));

test('filters update URL params', async () => {
  const push = jest.fn();
  (useRouter as jest.Mock).mockReturnValue({ push });
  (useSearchParams as jest.Mock).mockReturnValue(
    new URLSearchParams('category=all&sort=newest')
  );
  (usePathname as jest.Mock).mockReturnValue('/products');

  render(<ProductFilters />);

  const select = screen.getByRole('combobox', { name: /category/i });
  await userEvent.selectOptions(select, 'electronics');

  expect(push).toHaveBeenCalledWith('/products?category=electronics&page=1&sort=newest');
});
```
