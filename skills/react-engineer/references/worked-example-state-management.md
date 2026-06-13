# Worked Example: E-commerce State Management

## Scenario

An e-commerce product listing page with:
- Category and price filters
- Sort order (newest, price, popularity)
- Pagination
- Search query
- Shopping cart (add, remove, update quantity)
- User preferences (view mode, items per page, currency)

---

## Step 1: Classify Each Piece of State

| State | Type | Location | Rationale |
|:------|:-----|:---------|:----------|
| Category filter | URL | `?category=electronics` | Deep linkable, affects data fetch |
| Price range filter | URL | `?min=50&max=200` | Deep linkable, affects data fetch |
| Sort order | URL | `?sort=price-asc` | Deep linkable, affects data fetch |
| Current page | URL | `?page=2` | Deep linkable, affects data fetch |
| Search query | URL (debounced) | `?q=wireless+headphones` | Shareable search results |
| Product data | Server cache | TanStack Query | API response, cached, auto-refetched |
| Cart items | Client persistent | Zustand (persisted) | Survives navigation, client-only |
| View mode (grid/list) | Client persistent | Zustand (persisted) | User preference, persists across sessions |
| Items per page | Client persistent | Zustand (persisted) | User preference |
| Currency | Client persistent | Zustand (persisted) | User preference |
| Search input value | Local | `useState` | Ephemeral, debounced before URL update |
| Mobile filter panel open | Local | `useState` | Ephemeral UI state |

---

## Step 2: URL State Layer

```tsx
// hooks/use-product-filters.ts
'use client';

import { useSearchParams, useRouter, usePathname } from 'next/navigation';
import { useCallback, useMemo } from 'react';

export interface ProductFilters {
  category: string;
  minPrice: number;
  maxPrice: number;
  sort: 'newest' | 'price-asc' | 'price-desc' | 'popular';
  page: number;
  query: string;
}

const DEFAULT_FILTERS: ProductFilters = {
  category: 'all',
  minPrice: 0,
  maxPrice: 10000,
  sort: 'newest',
  page: 1,
  query: '',
};

export function useProductFilters(): [
  ProductFilters,
  (updates: Partial<ProductFilters>) => void,
] {
  const searchParams = useSearchParams();
  const router = useRouter();
  const pathname = usePathname();

  const filters: ProductFilters = useMemo(
    () => ({
      category: searchParams.get('category') ?? DEFAULT_FILTERS.category,
      minPrice: Number(searchParams.get('min') ?? DEFAULT_FILTERS.minPrice),
      maxPrice: Number(searchParams.get('max') ?? DEFAULT_FILTERS.maxPrice),
      sort: (searchParams.get('sort') as ProductFilters['sort']) ?? DEFAULT_FILTERS.sort,
      page: Number(searchParams.get('page') ?? DEFAULT_FILTERS.page),
      query: searchParams.get('q') ?? DEFAULT_FILTERS.query,
    }),
    [searchParams]
  );

  const updateFilters = useCallback(
    (updates: Partial<ProductFilters>) => {
      const params = new URLSearchParams(searchParams.toString());

      if (updates.category !== undefined) {
        if (updates.category === 'all') params.delete('category');
        else params.set('category', updates.category);
      }
      if (updates.minPrice !== undefined) {
        if (updates.minPrice === DEFAULT_FILTERS.minPrice) params.delete('min');
        else params.set('min', String(updates.minPrice));
      }
      if (updates.maxPrice !== undefined) {
        if (updates.maxPrice === DEFAULT_FILTERS.maxPrice) params.delete('max');
        else params.set('max', String(updates.maxPrice));
      }
      if (updates.sort !== undefined) {
        if (updates.sort === DEFAULT_FILTERS.sort) params.delete('sort');
        else params.set('sort', updates.sort);
      }
      if (updates.page !== undefined) {
        if (updates.page === DEFAULT_FILTERS.page) params.delete('page');
        else params.set('page', String(updates.page));
      }
      if (updates.query !== undefined) {
        if (updates.query === '') params.delete('q');
        else params.set('q', updates.query);
      }

      // Reset page when filters change (but not when page itself changes)
      if (updates.category !== undefined || updates.sort !== undefined ||
          updates.minPrice !== undefined || updates.maxPrice !== undefined ||
          updates.query !== undefined) {
        if (updates.page === undefined) {
          params.delete('page');
        }
      }

      router.push(`${pathname}?${params.toString()}`, { scroll: false });
    },
    [searchParams, router, pathname]
  );

  return [filters, updateFilters];
}
```

---

## Step 3: TanStack Query for Server Data

```tsx
// queries/use-products-query.ts
import { useQuery } from '@tanstack/react-query';
import type { ProductFilters } from '@/hooks/use-product-filters';

export interface Product {
  id: string;
  name: string;
  slug: string;
  price: number;
  originalPrice?: number;
  category: string;
  image: string;
  rating: number;
  reviewCount: number;
  inStock: boolean;
}

export interface ProductsResponse {
  products: Product[];
  total: number;
  page: number;
  totalPages: number;
  aggregations: {
    categories: { name: string; count: number }[];
    priceRange: { min: number; max: number };
  };
}

async function fetchProducts(filters: ProductFilters): Promise<ProductsResponse> {
  const params = new URLSearchParams();
  if (filters.category !== 'all') params.set('category', filters.category);
  if (filters.minPrice > 0) params.set('minPrice', String(filters.minPrice));
  if (filters.maxPrice < 10000) params.set('maxPrice', String(filters.maxPrice));
  params.set('sort', filters.sort);
  params.set('page', String(filters.page));
  if (filters.query) params.set('q', filters.query);

  const res = await fetch(`/api/products?${params.toString()}`);
  if (!res.ok) {
    const error = await res.json();
    throw new Error(error.message || 'Failed to fetch products');
  }
  return res.json();
}

export function useProductsQuery(filters: ProductFilters) {
  return useQuery({
    queryKey: ['products', filters],
    queryFn: () => fetchProducts(filters),
    placeholderData: (previousData) => previousData, // keep old data while loading new
    staleTime: 30 * 1000, // 30 seconds
  });
}
```

---

## Step 4: Zustand for Cart and Preferences

```tsx
// stores/cart-store.ts
import { create } from 'zustand';
import { persist, devtools } from 'zustand/middleware';
import { immer } from 'zustand/middleware/immer';

export interface CartItem {
  id: string;
  name: string;
  price: number;
  image: string;
  quantity: number;
  maxQuantity: number;
}

interface CartState {
  items: CartItem[];
  addItem: (item: Omit<CartItem, 'quantity'>) => void;
  removeItem: (id: string) => void;
  updateQuantity: (id: string, quantity: number) => void;
  clearCart: () => void;
  itemCount: () => number;
  subtotal: () => number;
}

export const useCartStore = create<CartState>()(
  devtools(
    persist(
      immer((set, get) => ({
        items: [],

        addItem: (item) =>
          set((state) => {
            const existing = state.items.find((i) => i.id === item.id);
            if (existing) {
              existing.quantity = Math.min(existing.quantity + 1, item.maxQuantity);
            } else {
              state.items.push({ ...item, quantity: 1 });
            }
          }),

        removeItem: (id) =>
          set((state) => {
            state.items = state.items.filter((i) => i.id !== id);
          }),

        updateQuantity: (id, quantity) =>
          set((state) => {
            const item = state.items.find((i) => i.id === id);
            if (item) {
              item.quantity = Math.max(0, Math.min(quantity, item.maxQuantity));
              if (item.quantity === 0) {
                state.items = state.items.filter((i) => i.id !== id);
              }
            }
          }),

        clearCart: () => set({ items: [] }),

        itemCount: () => get().items.reduce((sum, i) => sum + i.quantity, 0),

        subtotal: () =>
          get().items.reduce((sum, i) => sum + i.price * i.quantity, 0),
      })),
      {
        name: 'gnp-cart',
        partialize: (state) => ({ items: state.items }),
      }
    ),
    { name: 'CartStore' }
  )
);
```

```tsx
// stores/preferences-store.ts
import { create } from 'zustand';
import { persist } from 'zustand/middleware';

interface PreferencesState {
  viewMode: 'grid' | 'list';
  itemsPerPage: 12 | 24 | 48;
  currency: 'USD' | 'EUR' | 'GBP';
  setViewMode: (mode: 'grid' | 'list') => void;
  setItemsPerPage: (count: 12 | 24 | 48) => void;
  setCurrency: (currency: 'USD' | 'EUR' | 'GBP') => void;
}

export const usePreferencesStore = create<PreferencesState>()(
  persist(
    (set) => ({
      viewMode: 'grid',
      itemsPerPage: 12,
      currency: 'USD',
      setViewMode: (viewMode) => set({ viewMode }),
      setItemsPerPage: (itemsPerPage) => set({ itemsPerPage }),
      setCurrency: (currency) => set({ currency }),
    }),
    { name: 'gnp-preferences' }
  )
);
```

---

## Step 5: Integration - The Product Listing Page

```tsx
// app/products/page.tsx (Server Component)
import { Suspense } from 'react';
import { ProductsPageContent } from './products-page-content';
import { ProductsPageSkeleton } from './products-page-skeleton';

interface PageProps {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}

export default async function ProductsPage({ searchParams }: PageProps) {
  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Products</h1>
      <Suspense fallback={<ProductsPageSkeleton />}>
        <ProductsPageContent searchParams={searchParams} />
      </Suspense>
    </div>
  );
}
```

```tsx
// app/products/products-page-content.tsx
'use client';

import { useProductFilters } from '@/hooks/use-product-filters';
import { useProductsQuery } from '@/queries/use-products-query';
import { usePreferencesStore } from '@/stores/preferences-store';
import { ProductFilters } from './product-filters';
import { ProductGrid } from './product-grid';
import { ProductList } from './product-list';
import { Pagination } from './pagination';
import { SearchInput } from './search-input';
import { CartSummary } from './cart-summary';
import { ViewToggle } from './view-toggle';

interface Props {
  searchParams: Promise<{ [key: string]: string | string[] | undefined }>;
}

export function ProductsPageContent({ searchParams }: Props) {
  const [filters, updateFilters] = useProductFilters();
  const { data, isLoading, error } = useProductsQuery(filters);
  const viewMode = usePreferencesStore((s) => s.viewMode);

  if (error) {
    return (
      <div className="text-center py-12">
        <h2 className="text-xl text-red-600">Failed to load products</h2>
        <p className="text-gray-500 mt-2">{error.message}</p>
        <button
          onClick={() => window.location.reload()}
          className="mt-4 px-4 py-2 bg-blue-600 text-white rounded"
        >
          Try Again
        </button>
      </div>
    );
  }

  return (
    <div className="flex gap-8">
      {/* Sidebar Filters */}
      <aside className="w-64 shrink-0">
        <ProductFilters
          filters={filters}
          onUpdate={updateFilters}
          aggregations={data?.aggregations}
        />
      </aside>

      {/* Main Content */}
      <main className="flex-1">
        {/* Toolbar */}
        <div className="flex items-center justify-between mb-4">
          <SearchInput
            value={filters.query}
            onChange={(q) => updateFilters({ query: q })}
          />
          <div className="flex items-center gap-4">
            <CartSummary />
            <ViewToggle />
          </div>
        </div>

        {/* Product Display */}
        {isLoading ? (
          <div className="grid grid-cols-3 gap-4">
            {Array.from({ length: 12 }).map((_, i) => (
              <ProductCardSkeleton key={i} />
            ))}
          </div>
        ) : (
          <>
            {viewMode === 'grid' ? (
              <ProductGrid products={data?.products ?? []} />
            ) : (
              <ProductList products={data?.products ?? []} />
            )}

            <Pagination
              currentPage={filters.page}
              totalPages={data?.totalPages ?? 1}
              onPageChange={(page) => updateFilters({ page })}
            />
          </>
        )}
      </main>
    </div>
  );
}
```

---

## Step 6: Search Input with Debounce

```tsx
// app/products/search-input.tsx
'use client';

import { useState, useRef, useCallback } from 'react';

interface SearchInputProps {
  value: string;
  onChange: (query: string) => void;
}

export function SearchInput({ value, onChange }: SearchInputProps) {
  const [inputValue, setInputValue] = useState(value);
  const debounceRef = useRef<ReturnType<typeof setTimeout>>();

  const handleChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const newValue = e.target.value;
      setInputValue(newValue);

      if (debounceRef.current) clearTimeout(debounceRef.current);
      debounceRef.current = setTimeout(() => {
        onChange(newValue);
      }, 300);
    },
    [onChange]
  );

  return (
    <div className="relative w-72">
      <input
        type="search"
        value={inputValue}
        onChange={handleChange}
        placeholder="Search products..."
        className="w-full rounded-lg border border-gray-300 px-4 py-2 pl-10"
        aria-label="Search products"
      />
      <svg
        className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={2}
          d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
        />
      </svg>
    </div>
  );
}
```

---

## Step 7: Cart Summary with Optimistic Add

```tsx
// app/products/cart-summary.tsx
'use client';

import { useCartStore } from '@/stores/cart-store';
import { useMutation, useQueryClient } from '@tanstack/react-query';

export function CartSummary() {
  const items = useCartStore((s) => s.items);
  const subtotal = useCartStore((s) => s.subtotal());
  const itemCount = useCartStore((s) => s.itemCount());

  return (
    <button className="relative flex items-center gap-2 px-3 py-2 rounded-lg border">
      <svg className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth={2}
          d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 100 4 2 2 0 000-4z"
        />
      </svg>
      <span>{itemCount}</span>
      {itemCount > 0 && (
        <span className="text-sm text-gray-500">
          ${subtotal.toFixed(2)}
        </span>
      )}
    </button>
  );
}

// Add to cart button with optimistic update
export function AddToCartButton({ product }: { product: Product }) {
  const addItem = useCartStore((s) => s.addItem);

  const mutation = useMutation({
    mutationFn: async (productId: string) => {
      const res = await fetch('/api/cart/items', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ productId, quantity: 1 }),
      });
      if (!res.ok) throw new Error('Failed to add to cart');
      return res.json();
    },
    onMutate: async (productId) => {
      // Optimistic: add to local store immediately
      addItem({
        id: product.id,
        name: product.name,
        price: product.price,
        image: product.image,
        maxQuantity: 99,
      });
    },
    onError: () => {
      // Rollback: remove the item from local store
      useCartStore.getState().removeItem(product.id);
    },
  });

  return (
    <button
      onClick={() => mutation.mutate(product.id)}
      disabled={mutation.isPending}
      className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 disabled:opacity-50"
    >
      {mutation.isPending ? 'Adding...' : 'Add to Cart'}
    </button>
  );
}
```

---

## Common Edge Cases

### 1. URL Params Out of Sync with Local State

When the user navigates back, the search input may not match the URL query.

```tsx
// Solution: Sync local state when URL changes
useEffect(() => {
  setInputValue(filters.query);
}, [filters.query]);
```

### 2. Cart Persistence Across Sessions

Zustand `persist` middleware handles this, but you need a hydration guard:

```tsx
// components/cart-hydration-guard.tsx
'use client';

import { useState, useEffect } from 'react';

export function CartHydrationGuard({ children }: { children: React.ReactNode }) {
  const [isHydrated, setIsHydrated] = useState(false);

  useEffect(() => {
    setIsHydrated(true);
  }, []);

  if (!isHydrated) {
    return <CartSkeleton />;
  }

  return <>{children}</>;
}
```

### 3. Server-Rendered Page with Client Filters

The server renders the initial page, then the client takes over filtering.

```tsx
// Server Component passes initial data as fallback
async function ProductsPage({ searchParams }: PageProps) {
  const params = await searchParams;
  const initialData = await fetchProducts(params);

  return (
    <ProductsPageContent
      searchParams={searchParams}
      initialData={initialData}
    />
  );
}

// Client Component uses initialData with TanStack Query
function ProductsPageContent({ searchParams, initialData }: Props) {
  const [filters, updateFilters] = useProductFilters();
  const { data } = useProductsQuery(filters);
  // Use initialData for first render, then TanStack Query takes over
  const products = data ?? initialData;
}
```

### 4. Price Filter Slider

Two-thumb range sliders need careful URL sync:

```tsx
function PriceRangeFilter({ min, max, onUpdate }: PriceFilterProps) {
  const [localRange, setLocalRange] = useState<[number, number]>([min, max]);
  const debounceRef = useRef<ReturnType<typeof setTimeout>>();

  function handleChange(range: [number, number]) {
    setLocalRange(range);
    if (debounceRef.current) clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      onUpdate({ minPrice: range[0], maxPrice: range[1] });
    }, 500);
  }

  return (
    <RangeSlider
      min={0}
      max={10000}
      value={localRange}
      onChange={handleChange}
    />
  );
}
```

### 5. Multiple Filter Changes at Once

When clearing all filters, batch the URL update:

```tsx
function clearAllFilters() {
  // Single update call, not multiple
  updateFilters({
    category: 'all',
    minPrice: 0,
    maxPrice: 10000,
    sort: 'newest',
    page: 1,
    query: '',
  });
}
```
