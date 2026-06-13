# Testing Guide for React 19 / Next.js 16

## Testing Stack

| Layer | Tool | Purpose |
|:------|:-----|:--------|
| Unit tests | Vitest | Functions, hooks, utils |
| Component tests | React Testing Library | Component rendering and interaction |
| Server Component tests | Vitest + custom render | Server Component output |
| API route tests | Vitest + fetch mocks | Route Handler behavior |
| Server Action tests | Vitest + module mocks | Action validation and auth |
| E2E tests | Playwright | Full user flows |
| Visual regression | Playwright screenshots | UI consistency |

---

## Setup

### Vitest Configuration

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [react(), tsconfigPaths()],
  test: {
    environment: 'jsdom',
    setupFiles: ['./vitest.setup.ts'],
    include: ['**/*.test.{ts,tsx}'],
    globals: true,
    css: true,
  },
});
```

```ts
// vitest.setup.ts
import '@testing-library/jest-dom/vitest';
```

### Install Dependencies

```bash
npm install -D vitest @vitejs/plugin-react vite-tsconfig-paths jsdom
npm install -D @testing-library/react @testing-library/jest-dom @testing-library/user-event
npm install -D msw
npm install -D @playwright/test
```

---

## Unit Tests

### Testing Utility Functions

```ts
// lib/format-currency.test.ts
import { describe, it, expect } from 'vitest';
import { formatCurrency } from './format-currency';

describe('formatCurrency', () => {
  it('formats USD correctly', () => {
    expect(formatCurrency(1234.56, 'USD')).toBe('$1,234.56');
  });

  it('formats EUR correctly', () => {
    expect(formatCurrency(1234.56, 'EUR')).toBe('1.234,56 €');
  });

  it('handles zero', () => {
    expect(formatCurrency(0, 'USD')).toBe('$0.00');
  });

  it('handles negative values', () => {
    expect(formatCurrency(-50, 'USD')).toBe('-$50.00');
  });
});
```

### Testing Custom Hooks

```tsx
// hooks/use-toggle.test.ts
import { renderHook, act } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { useToggle } from './use-toggle';

describe('useToggle', () => {
  it('starts with default value', () => {
    const { result } = renderHook(() => useToggle(false));
    expect(result.current[0]).toBe(false);
  });

  it('toggles value', () => {
    const { result } = renderHook(() => useToggle(false));

    act(() => result.current[1]());
    expect(result.current[0]).toBe(true);

    act(() => result.current[1]());
    expect(result.current[0]).toBe(false);
  });

  it('sets specific value', () => {
    const { result } = renderHook(() => useToggle(false));

    act(() => result.current[2](true));
    expect(result.current[0]).toBe(true);
  });
});
```

---

## Component Tests

### Basic Component Test

```tsx
// components/button.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { Button } from './button';

describe('Button', () => {
  it('renders with text', () => {
    render(<Button variant="primary">Click me</Button>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('calls onClick when clicked', async () => {
    const onClick = vi.fn();
    render(<Button variant="primary" onClick={onClick}>Click me</Button>);

    await userEvent.click(screen.getByRole('button'));
    expect(onClick).toHaveBeenCalledTimes(1);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button variant="primary" disabled>Click me</Button>);
    expect(screen.getByRole('button')).toBeDisabled();
  });

  it('does not call onClick when disabled', async () => {
    const onClick = vi.fn();
    render(<Button variant="primary" onClick={onClick} disabled>Click me</Button>);

    await userEvent.click(screen.getByRole('button'));
    expect(onClick).not.toHaveBeenCalled();
  });
});
```

### Testing Forms

```tsx
// components/search-input.test.tsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';
import { SearchInput } from './search-input';

describe('SearchInput', () => {
  it('renders with default value', () => {
    render(<SearchInput value="hello" onChange={vi.fn()} />);
    expect(screen.getByRole('searchbox')).toHaveValue('hello');
  });

  it('calls onChange when typing', async () => {
    const onChange = vi.fn();
    render(<SearchInput value="" onChange={onChange} />);

    await userEvent.type(screen.getByRole('searchbox'), 'test');
    expect(onChange).toHaveBeenCalledTimes(4); // t, e, s, t
  });

  it('has correct placeholder', () => {
    render(<SearchInput value="" onChange={vi.fn()} />);
    expect(screen.getByPlaceholderText('Search products...')).toBeInTheDocument();
  });
});
```

### Testing with Loading and Error States

```tsx
// components/product-list.test.tsx
import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import { ProductList } from './product-list';

describe('ProductList', () => {
  it('shows loading skeleton', () => {
    render(<ProductList products={[]} isLoading={true} />);
    expect(screen.getByTestId('product-skeleton')).toBeInTheDocument();
  });

  it('shows empty state when no products', () => {
    render(<ProductList products={[]} isLoading={false} />);
    expect(screen.getByText('No products found')).toBeInTheDocument();
  });

  it('renders product cards', () => {
    const products = [
      { id: '1', name: 'Widget', price: 9.99, image: '/widget.jpg' },
      { id: '2', name: 'Gadget', price: 19.99, image: '/gadget.jpg' },
    ];
    render(<ProductList products={products} isLoading={false} />);
    expect(screen.getByText('Widget')).toBeInTheDocument();
    expect(screen.getByText('Gadget')).toBeInTheDocument();
  });
});
```

---

## Testing Server Components

Server Components can't use `@testing-library/react` directly since they're async functions, not React components in the traditional sense.

```tsx
// app/products/page.test.tsx
import { describe, it, expect, vi } from 'vitest';

// Mock the database
vi.mock('@/lib/db', () => ({
  db: {
    product: {
      findMany: vi.fn().mockResolvedValue([
        { id: '1', name: 'Widget', price: 9.99 },
        { id: '2', name: 'Gadget', price: 19.99 },
      ]),
    },
  },
}));

// Import the Server Component (it's an async function)
import ProductsPage from './page';

describe('ProductsPage (Server Component)', () => {
  it('renders product list', async () => {
    // Server Components are async functions that return JSX
    const result = await ProductsPage({
      searchParams: Promise.resolve({}),
    });

    // The result is a React element - render it for testing
    // Option 1: Use react-server-dom for server rendering
    // Option 2: Test the data fetching logic separately

    // For simple cases, verify the component doesn't throw
    expect(result).toBeDefined();
  });

  it('passes correct filters to database', async () => {
    const { db } = await import('@/lib/db');

    await ProductsPage({
      searchParams: Promise.resolve({ category: 'electronics' }),
    });

    expect(db.product.findMany).toHaveBeenCalledWith(
      expect.objectContaining({
        where: expect.objectContaining({ category: 'electronics' }),
      })
    );
  });
});
```

---

## Testing Server Actions

```tsx
// actions/create-product.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';

// Mock auth
vi.mock('@/lib/auth', () => ({
  getServerSession: vi.fn(),
}));

// Mock database
vi.mock('@/lib/db', () => ({
  db: {
    product: {
      create: vi.fn(),
    },
  },
}));

import { createProduct } from './create-product';
import { getServerSession } from '@/lib/auth';
import { db } from '@/lib/db';

describe('createProduct', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns error when not authenticated', async () => {
    vi.mocked(getServerSession).mockResolvedValue(null);

    const result = await createProduct({ name: 'Widget', price: 9.99 });

    expect(result).toEqual({ success: false, error: 'Unauthorized' });
    expect(db.product.create).not.toHaveBeenCalled();
  });

  it('validates input with Zod', async () => {
    vi.mocked(getServerSession).mockResolvedValue({ user: { id: 'user1' } });

    const result = await createProduct({ name: '', price: -5 });

    expect(result).toEqual({
      success: false,
      fieldErrors: expect.objectContaining({
        name: expect.any(Array),
        price: expect.any(Array),
      }),
    });
  });

  it('creates product with valid input', async () => {
    vi.mocked(getServerSession).mockResolvedValue({ user: { id: 'user1' } });
    vi.mocked(db.product.create).mockResolvedValue({ id: 'prod1' });

    const result = await createProduct({
      name: 'Widget',
      price: 9.99,
      category: 'electronics',
    });

    expect(result).toEqual({ success: true, data: { id: 'prod1' } });
    expect(db.product.create).toHaveBeenCalledWith(
      expect.objectContaining({
        data: expect.objectContaining({
          name: 'Widget',
          price: 9.99,
          createdById: 'user1',
        }),
      })
    );
  });
});
```

---

## Testing API Routes

```tsx
// app/api/products/route.test.ts
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { NextRequest } from 'next/server';
import { GET } from './route';

vi.mock('@/lib/db', () => ({
  db: {
    product: {
      findMany: vi.fn(),
      count: vi.fn(),
    },
  },
}));

import { db } from '@/lib/db';

describe('GET /api/products', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('returns products with pagination', async () => {
    vi.mocked(db.product.findMany).mockResolvedValue([
      { id: '1', name: 'Widget', price: 9.99 },
    ]);
    vi.mocked(db.product.count).mockResolvedValue(1);

    const request = new NextRequest(
      new URL('http://localhost:3000/api/products?page=1&limit=20')
    );

    const response = await GET(request);
    const data = await response.json();

    expect(response.status).toBe(200);
    expect(data.products).toHaveLength(1);
    expect(data.total).toBe(1);
    expect(data.page).toBe(1);
  });

  it('validates query parameters', async () => {
    const request = new NextRequest(
      new URL('http://localhost:3000/api/products?page=invalid')
    );

    const response = await GET(request);
    expect(response.status).toBe(400);
  });
});
```

---

## Mocking with MSW (Mock Service Worker)

```tsx
// mocks/handlers.ts
import { http, HttpResponse } from 'msw';

export const handlers = [
  http.get('/api/products', ({ request }) => {
    const url = new URL(request.url);
    const page = Number(url.searchParams.get('page') ?? '1');

    return HttpResponse.json({
      products: [
        { id: '1', name: 'Widget', price: 9.99 },
        { id: '2', name: 'Gadget', price: 19.99 },
      ],
      total: 2,
      page,
      totalPages: 1,
    });
  }),

  http.post('/api/cart/items', async ({ request }) => {
    const body = await request.json();
    return HttpResponse.json({ success: true, id: 'cart-item-1' });
  }),
];
```

```tsx
// mocks/server.ts
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

export const server = setupServer(...handlers);
```

```tsx
// vitest.setup.ts - Add MSW server lifecycle
import '@testing-library/jest-dom/vitest';
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'warn' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

---

## E2E Tests with Playwright

### Configuration

```ts
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'Mobile Chrome', use: { ...devices['Pixel 5'] } },
  ],
  webServer: {
    command: 'npm run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

### E2E Test Examples

```tsx
// e2e/products.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Product listing', () => {
  test('shows products on the listing page', async ({ page }) => {
    await page.goto('/products');
    await expect(page.getByRole('heading', { name: 'Products' })).toBeVisible();
    await expect(page.getByTestId('product-card')).toHaveCount(20);
  });

  test('filters products by category', async ({ page }) => {
    await page.goto('/products');
    await page.getByLabel('Category').selectOption('electronics');
    await expect(page).toHaveURL(/category=electronics/);
  });

  test('navigates to product detail', async ({ page }) => {
    await page.goto('/products');
    await page.getByTestId('product-card').first().click();
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
    await expect(page).toHaveURL(/\/products\/[\w-]+/);
  });
});

test.describe('Shopping cart', () => {
  test('adds product to cart', async ({ page }) => {
    await page.goto('/products/product-1');
    await page.getByRole('button', { name: /add to cart/i }).click();
    await expect(page.getByTestId('cart-badge')).toHaveText('1');
  });
});

test.describe('Search', () => {
  test('search debounces and updates URL', async ({ page }) => {
    await page.goto('/products');
    await page.getByPlaceholder(/search/i).fill('wireless headphones');

    // Wait for debounce (300ms) + navigation
    await expect(page).toHaveURL(/q=wireless\+headphones/, { timeout: 2000 });
  });
});
```

---

## Testing Checklist

### Per Component
- [ ] Renders correctly with required props
- [ ] Handles loading state
- [ ] Handles error state
- [ ] Handles empty state
- [ ] User interactions work (click, type, submit)
- [ ] Accessible (correct ARIA, keyboard nav)

### Per Server Action
- [ ] Returns error when not authenticated
- [ ] Validates input with Zod
- [ ] Returns success with valid input
- [ ] Handles database errors gracefully

### Per API Route
- [ ] Returns correct status codes (200, 400, 401, 404, 500)
- [ ] Validates query parameters
- [ ] Validates request body
- [ ] Returns correct response shape

### E2E Critical Path
- [ ] User can browse products
- [ ] User can search and filter
- [ ] User can add to cart
- [ ] User can complete checkout
- [ ] User can log in and view orders
