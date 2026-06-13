# TypeScript Patterns for Production React

## Strict tsconfig.json for React Projects

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["dom", "dom.iterable", "esnext"],
    "module": "ESNext",
    "moduleResolution": "bundler",
    "jsx": "react-jsx",
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "forceConsistentCasingInFileNames": true,
    "exactOptionalPropertyTypes": true,
    "paths": {
      "@/*": ["./src/*"]
    },
    "plugins": [{ "name": "next" }],
    "incremental": true
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

Key strictness flags explained:
- `strict: true` enables all strict checks
- `noUncheckedIndexedAccess` requires null checks on array/object indexing
- `exactOptionalPropertyTypes` distinguishes between `undefined` and missing

---

## Typed Component Props

### Basic Props

```tsx
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  disabled?: boolean;
}

function Button({ variant, size = 'md', children, onClick, disabled }: ButtonProps) {
  return (
    <button
      className={`btn btn-${variant} btn-${size}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
}
```

### Discriminated Unions for Polymorphic Components

```tsx
// Component that renders differently based on a discriminated prop
interface TextProps {
  as?: 'span' | 'p' | 'h1' | 'h2' | 'h3';
  children: React.ReactNode;
  className?: string;
}

// For links: requires href
interface LinkProps {
  as: 'a';
  href: string;
  children: React.ReactNode;
  className?: string;
}

// For buttons: requires onClick
interface ButtonTextProps {
  as: 'button';
  onClick: (e: React.MouseEvent<HTMLButtonElement>) => void;
  children: React.ReactNode;
  className?: string;
}

type TypographyProps = TextProps | LinkProps | ButtonTextProps;

function Typography(props: TypographyProps) {
  const { as: Component = 'p', children, className } = props;

  if (Component === 'a') {
    const { href } = props as LinkProps;
    return <a href={href} className={className}>{children}</a>;
  }

  if (Component === 'button') {
    const { onClick } = props as ButtonTextProps;
    return <button onClick={onClick} className={className}>{children}</button>;
  }

  return <Component className={className}>{children}</Component>;
}
```

### Generic Components

```tsx
// Generic select component that knows about its option type
interface SelectProps<T extends string> {
  options: { value: T; label: string }[];
  value: T;
  onChange: (value: T) => void;
  placeholder?: string;
}

function Select<T extends string>({
  options,
  value,
  onChange,
  placeholder,
}: SelectProps<T>) {
  return (
    <select
      value={value}
      onChange={(e) => onChange(e.target.value as T)}
    >
      {placeholder && <option value="">{placeholder}</option>}
      {options.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  );
}

// Usage: TypeScript infers the value type from options
<Select
  options={[
    { value: 'electronics', label: 'Electronics' },
    { value: 'clothing', label: 'Clothing' },
  ]}
  value={category}
  onChange={setCategory}
/>
// onChange is typed as (value: 'electronics' | 'clothing') => void
```

### Props with `children` Patterns

```tsx
// Accept any children
interface ContainerProps {
  children: React.ReactNode;
}

// Accept only one child (e.g., cloneElement)
interface WrapperProps {
  children: React.ReactElement<Record<string, unknown>>;
}

// Function as children
interface RenderProps<T> {
  children: (data: T) => React.ReactNode;
  data: T;
}

function DataRenderer<T>({ children, data }: RenderProps<T>) {
  return <>{children(data)}</>;
}

// Usage
<DataRenderer data={{ name: 'Alice', age: 30 }}>
  {(user) => <div>{user.name} is {user.age}</div>}
</DataRenderer>
```

---

## Typed Hooks

### Custom Hooks with Proper Typing

```tsx
// Hook that returns a typed tuple
function useToggle(initialValue = false): [boolean, () => void, (value: boolean) => void] {
  const [value, setValue] = useState(initialValue);
  const toggle = useCallback(() => setValue((v) => !v), []);
  const set = useCallback((newValue: boolean) => setValue(newValue), []);
  return [value, toggle, set];
}

// Usage
const [isOpen, toggleOpen, setOpen] = useToggle();
```

### Typed Async Hook

```tsx
interface UseAsyncState<T> {
  data: T | null;
  error: Error | null;
  isLoading: boolean;
}

function useAsync<T>(asyncFn: () => Promise<T>, deps: unknown[]): UseAsyncState<T> {
  const [state, setState] = useState<UseAsyncState<T>>({
    data: null,
    error: null,
    isLoading: true,
  });

  useEffect(() => {
    let cancelled = false;
    setState({ data: null, error: null, isLoading: true });

    asyncFn()
      .then((data) => {
        if (!cancelled) setState({ data, error: null, isLoading: false });
      })
      .catch((error: Error) => {
        if (!cancelled) setState({ data: null, error, isLoading: false });
      });

    return () => {
      cancelled = true;
    };
  }, deps);

  return state;
}

// Usage
const { data: user, error, isLoading } = useAsync(
  () => fetchUser(userId),
  [userId]
);
```

### Typed Debounced Value Hook

```tsx
function useDebouncedValue<T>(value: T, delay: number): T {
  const [debouncedValue, setDebouncedValue] = useState(value);

  useEffect(() => {
    const timer = setTimeout(() => setDebouncedValue(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);

  return debouncedValue;
}
```

---

## Next.js Typed Routes (15.5+)

### Route Type

```tsx
// Next.js 15.5+ generates Route type from your file structure
import type { Route } from 'next';
import Link from 'next/link';

// Type-safe href - only valid routes are accepted
function Navigation() {
  return (
    <nav>
      <Link href="/products">Products</Link>
      <Link href="/products/123">Product Detail</Link>
      <Link href="/about">About</Link>
      {/* <Link href="/nonexistent">About</Link> // TypeScript error! */}
    </nav>
  );
}

// Type-safe programmatic navigation
import { useRouter } from 'next/navigation';

function useTypedNavigation() {
  const router = useRouter();

  return {
    goToProduct: (id: string) => router.push(`/products/${id}` as Route),
    goToHome: () => router.push('/' as Route),
    goToAbout: () => router.push('/about' as Route),
  };
}
```

### Typed Search Params

```tsx
// Define expected search params for each route
interface ProductSearchParms {
  category?: string;
  sort?: 'newest' | 'price-asc' | 'price-desc';
  page?: string;
  q?: string;
}

function useProductSearchParams(): ProductSearchParms {
  const searchParams = useSearchParams();
  return {
    category: searchParams.get('category') ?? undefined,
    sort: (searchParams.get('sort') as ProductSearchParms['sort']) ?? undefined,
    page: searchParams.get('page') ?? undefined,
    q: searchParams.get('q') ?? undefined,
  };
}
```

---

## Typed Server Actions

### Input Validation with Zod

```tsx
// actions/product-actions.ts
import { z } from 'zod';

// Define schema
const createProductSchema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().min(10).max(5000),
  price: z.number().positive().max(999999.99),
  category: z.enum(['electronics', 'clothing', 'home', 'books']),
  tags: z.array(z.string()).max(10).default([]),
  images: z.array(z.object({
    url: z.string().url(),
    alt: z.string().max(200).optional(),
  })).min(1).max(5),
});

// Infer types from schema
type CreateProductInput = z.infer<typeof createProductSchema>;

// Define action result type
interface ActionResult<T = void> {
  success: boolean;
  data?: T;
  error?: string;
  fieldErrors?: Record<string, string[]>;
}

// Server Action with full typing
'use server';
export async function createProduct(
  rawInput: unknown
): Promise<ActionResult<{ id: string }>> {
  // 1. Authenticate
  const session = await getServerSession();
  if (!session?.user?.id) {
    return { success: false, error: 'Unauthorized' };
  }

  // 2. Validate
  const result = createProductSchema.safeParse(rawInput);
  if (!result.success) {
    return {
      success: false,
      fieldErrors: result.error.flatten().fieldErrors,
    };
  }

  // 3. Execute (input is fully typed as CreateProductInput)
  const product = await db.product.create({
    data: {
      ...result.data,
      createdById: session.user.id,
    },
  });

  // 4. Return typed result
  return { success: true, data: { id: product.id } };
}
```

### Client-Side Action Hook

```tsx
// hooks/use-action.ts
'use client';

import { useTransition, useState } from 'react';

interface UseActionOptions<TInput, TOutput> {
  onSuccess?: (data: TOutput) => void;
  onError?: (error: string) => void;
}

function useAction<TInput, TOutput>(
  action: (input: TInput) => Promise<ActionResult<TOutput>>,
  options?: UseActionOptions<TInput, TOutput>
) {
  const [isPending, startTransition] = useTransition();
  const [result, setResult] = useState<ActionResult<TOutput> | null>(null);

  function execute(input: TInput) {
    startTransition(async () => {
      const response = await action(input);
      setResult(response);

      if (response.success && response.data) {
        options?.onSuccess?.(response.data);
      } else if (response.error) {
        options?.onError?.(response.error);
      }
    });
  }

  return { execute, result, isPending };
}

// Usage
function CreateProductForm() {
  const { execute, result, isPending } = useAction(createProduct, {
    onSuccess: (data) => {
      router.push(`/products/${data.id}`);
    },
    onError: (error) => {
      toast.error(error);
    },
  });

  function handleSubmit(formData: FormData) {
    execute({
      name: formData.get('name') as string,
      description: formData.get('description') as string,
      price: Number(formData.get('price')),
      category: formData.get('category') as CreateProductInput['category'],
      tags: JSON.parse(formData.get('tags') as string),
      images: JSON.parse(formData.get('images') as string),
    });
  }

  return (
    <form action={handleSubmit}>
      {/* ... form fields ... */}
      <button type="submit" disabled={isPending}>
        {isPending ? 'Creating...' : 'Create Product'}
      </button>
      {result?.fieldErrors && (
        <ValidationErrors errors={result.fieldErrors} />
      )}
    </form>
  );
}
```

---

## Typed API Routes

```tsx
// app/api/products/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';

// Request type
const getProductsSchema = z.object({
  category: z.enum(['electronics', 'clothing', 'home']).optional(),
  sort: z.enum(['newest', 'price-asc', 'price-desc']).default('newest'),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

// Response type
interface ProductsResponse {
  products: Product[];
  total: number;
  page: number;
  totalPages: number;
}

export async function GET(request: NextRequest): Promise<NextResponse<ProductsResponse | { error: string }>> {
  const parsed = getProductsSchema.safeParse(
    Object.fromEntries(request.nextUrl.searchParams)
  );

  if (!parsed.success) {
    return NextResponse.json(
      { error: parsed.error.flatten().fieldErrors },
      { status: 400 }
    );
  }

  const { category, sort, page, limit } = parsed.data;

  const [products, total] = await Promise.all([
    db.product.findMany({
      where: category ? { category } : undefined,
      orderBy: getOrderBy(sort),
      skip: (page - 1) * limit,
      take: limit,
    }),
    db.product.count({ where: category ? { category } : undefined }),
  ]);

  return NextResponse.json({
    products,
    total,
    page,
    totalPages: Math.ceil(total / limit),
  });
}
```

---

## Typed Redux

```tsx
// store/hooks.ts - Pre-typed hooks
import { useDispatch, useSelector, TypedUseSelectorHook } from 'react-redux';
import type { RootState, AppDispatch } from './index';

export const useAppDispatch = () => useDispatch<AppDispatch>();
export const useAppSelector: TypedUseSelectorHook<RootState> = useSelector;

// store/products-slice.ts
import { createSlice, PayloadAction } from '@reduxjs/toolkit';

interface ProductsState {
  items: Product[];
  filters: ProductFilters;
  status: 'idle' | 'loading' | 'succeeded' | 'failed';
  error: string | null;
}

const initialState: ProductsState = {
  items: [],
  filters: { category: 'all', sort: 'newest', page: 1 },
  status: 'idle',
  error: null,
};

const productsSlice = createSlice({
  name: 'products',
  initialState,
  reducers: {
    setFilters(state, action: PayloadAction<Partial<ProductFilters>>) {
      state.filters = { ...state.filters, ...action.payload };
    },
    resetFilters(state) {
      state.filters = initialState.filters;
    },
  },
});

// Typed selector usage
function ProductList() {
  const products = useAppSelector((state) => state.products.items);
  const filters = useAppSelector((state) => state.products.filters);
  const dispatch = useAppDispatch();

  return (
    <div>
      <FilterBar
        filters={filters}
        onChange={(f) => dispatch(setFilters(f))}
      />
      {products.map((p) => <ProductCard key={p.id} product={p} />)}
    </div>
  );
}
```

---

## Branded Types

Branded types prevent accidental mixing of values that share the same underlying type:

```tsx
// Brand utility
type Brand<T, B extends string> = T & { readonly __brand: B };

// Branded ID types
type UserId = Brand<string, 'UserId'>;
type ProductId = Brand<string, 'ProductId'>;
type OrderId = Brand<string, 'OrderId'>;

// Smart constructors
function UserId(id: string): UserId {
  if (!/^[a-f0-9-]{36}$/.test(id)) throw new Error('Invalid User ID');
  return id as UserId;
}

function ProductId(id: string): ProductId {
  if (!/^[a-f0-9-]{36}$/.test(id)) throw new Error('Invalid Product ID');
  return id as ProductId;
}

// Now TypeScript prevents mixing them
function getUser(id: UserId): Promise<User> { /* ... */ }
function getProduct(id: ProductId): Promise<Product> { /* ... */ }

const userId = UserId('abc-123');
const productId = ProductId('def-456');

getUser(userId); // OK
getUser(productId); // TypeScript error! ProductId is not assignable to UserId
```

---

## Utility Types

```tsx
// ComponentProps - extract props from a component
type ButtonProps = React.ComponentProps<typeof Button>;
// Equivalent to { variant: ...; size?: ...; children: ...; onClick?: ...; disabled?: boolean }

// ComponentPropsWithoutRef - exclude ref from props
type InputProps = React.ComponentPropsWithoutRef<'input'>;
// All standard input element props without ref

// Pick and Omit for prop subsets
type ButtonBaseProps = Pick<ButtonProps, 'variant' | 'size' | 'disabled'>;
type ButtonWithoutClick = Omit<ButtonProps, 'onClick'>;

// Pattern: extending HTML element types
interface CustomInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label: string;
  error?: string;
}

function CustomInput({ label, error, className, ...inputProps }: CustomInputProps) {
  return (
    <div>
      <label>{label}</label>
      <input className={cn('input', error && 'input-error', className)} {...inputProps} />
      {error && <span className="error">{error}</span>}
    </div>
  );
}
```

---

## Generic List/Table Components

```tsx
// Typed column definition
interface Column<T> {
  key: keyof T | string;
  header: string;
  render?: (value: T[keyof T], row: T) => React.ReactNode;
  sortable?: boolean;
  width?: string;
}

// Generic table component
interface TableProps<T> {
  data: T[];
  columns: Column<T>[];
  keyExtractor: (row: T) => string;
  onRowClick?: (row: T) => void;
  emptyMessage?: string;
  isLoading?: boolean;
}

function Table<T>({
  data,
  columns,
  keyExtractor,
  onRowClick,
  emptyMessage = 'No data',
  isLoading,
}: TableProps<T>) {
  if (isLoading) return <TableSkeleton columns={columns.length} rows={5} />;
  if (data.length === 0) return <EmptyState message={emptyMessage} />;

  return (
    <table>
      <thead>
        <tr>
          {columns.map((col) => (
            <th key={String(col.key)} style={{ width: col.width }}>
              {col.header}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {data.map((row) => (
          <tr
            key={keyExtractor(row)}
            onClick={() => onRowClick?.(row)}
            style={{ cursor: onRowClick ? 'pointer' : undefined }}
          >
            {columns.map((col) => (
              <td key={String(col.key)}>
                {col.render
                  ? col.render(row[col.key as keyof T], row)
                  : String(row[col.key as keyof T] ?? '')}
              </td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

// Usage with full type inference
interface User {
  id: string;
  name: string;
  email: string;
  role: 'admin' | 'user';
  createdAt: Date;
}

const columns: Column<User>[] = [
  { key: 'name', header: 'Name', sortable: true },
  { key: 'email', header: 'Email' },
  {
    key: 'role',
    header: 'Role',
    render: (role) => <Badge variant={role === 'admin' ? 'primary' : 'secondary'}>{role}</Badge>,
  },
  {
    key: 'createdAt',
    header: 'Joined',
    render: (_, row) => formatDate(row.createdAt),
  },
];

<Table data={users} columns={columns} keyExtractor={(u) => u.id} onRowClick={(u) => navigate(`/users/${u.id}`)} />
// TypeScript ensures column keys are valid User keys
// render function parameters are correctly typed
```
