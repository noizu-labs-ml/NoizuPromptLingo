# NPL-FIM Prototyping Guide

## Table of Contents
1. [Required Dependencies](#required-dependencies)
2. [React Component Patterns](#react-component-patterns)
3. [TypeScript Integration](#typescript-integration)
4. [State Management](#state-management)
5. [NPL-FIM Templates](#npl-fim-templates)
6. [Testing Patterns](#testing-patterns)
7. [Documentation Links](#documentation-links)

## Required Dependencies

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "axios": "^1.6.0",
    "zustand": "^4.4.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@types/react-dom": "^18.2.0",
    "typescript": "^5.3.0",
    "@vitejs/plugin-react": "^4.2.0",
    "vite": "^5.0.0",
    "vitest": "^1.0.0",
    "@testing-library/react": "^14.1.0"
  }
}
```

## React Component Patterns

### Functional Component with TypeScript
```tsx
import React, { useState, useCallback } from 'react';

interface ProductCardProps {
  id: string;
  name: string;
  price: number;
  image: string;
  onAddToCart: (productId: string) => Promise<void>;
}

export const ProductCard: React.FC<ProductCardProps> = ({
  id,
  name,
  price,
  image,
  onAddToCart
}) => {
  const [loading, setLoading] = useState(false);

  const handleAddToCart = useCallback(async () => {
    setLoading(true);
    try {
      await onAddToCart(id);
    } finally {
      setLoading(false);
    }
  }, [id, onAddToCart]);

  return (
    <article className="product-card">
      <img src={image} alt={name} loading="lazy" />
      <h3>{name}</h3>
      <p>${price.toFixed(2)}</p>
      <button onClick={handleAddToCart} disabled={loading}>
        {loading ? 'Adding...' : 'Add to Cart'}
      </button>
    </article>
  );
};
```

## TypeScript Integration

### Type Definitions
```typescript
// types/product.ts
export interface Product {
  id: string;
  name: string;
  price: number;
  description: string;
  image: string;
  category: string;
  stock: number;
}

export interface CartItem extends Product {
  quantity: number;
}

export type CartState = {
  items: CartItem[];
  total: number;
};
```

### API Service Pattern
```typescript
import axios from 'axios';
import type { Product } from './types/product';

const API_BASE = process.env.VITE_API_URL || 'http://localhost:3000';

export const productService = {
  async getAll(): Promise<Product[]> {
    const { data } = await axios.get(`${API_BASE}/products`);
    return data;
  },

  async getById(id: string): Promise<Product> {
    const { data } = await axios.get(`${API_BASE}/products/${id}`);
    return data;
  },

  async search(query: string): Promise<Product[]> {
    const { data } = await axios.get(`${API_BASE}/products/search`, {
      params: { q: query }
    });
    return data;
  }
};
```

## State Management

### Zustand Store Pattern
```typescript
import { create } from 'zustand';
import { devtools } from 'zustand/middleware';
import type { CartState, Product } from './types';

interface CartStore extends CartState {
  addItem: (product: Product) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
}

export const useCartStore = create<CartStore>()(
  devtools((set) => ({
    items: [],
    total: 0,

    addItem: (product) => set((state) => {
      const existingItem = state.items.find(item => item.id === product.id);

      if (existingItem) {
        return {
          items: state.items.map(item =>
            item.id === product.id
              ? { ...item, quantity: item.quantity + 1 }
              : item
          ),
          total: state.total + product.price
        };
      }

      return {
        items: [...state.items, { ...product, quantity: 1 }],
        total: state.total + product.price
      };
    }),

    removeItem: (productId) => set((state) => {
      const item = state.items.find(i => i.id === productId);
      return {
        items: state.items.filter(i => i.id !== productId),
        total: item ? state.total - (item.price * item.quantity) : state.total
      };
    }),

    updateQuantity: (productId, quantity) => set((state) => {
      if (quantity <= 0) {
        return state;
      }

      const item = state.items.find(i => i.id === productId);
      if (!item) return state;

      const priceDiff = (quantity - item.quantity) * item.price;

      return {
        items: state.items.map(i =>
          i.id === productId ? { ...i, quantity } : i
        ),
        total: state.total + priceDiff
      };
    }),

    clearCart: () => set({ items: [], total: 0 })
  }))
);
```

## NPL-FIM Templates

### Component Generation Template
```npl-fim
Generate React component:
Context: E-commerce product display
Requirements:
- TypeScript interfaces for all props
- Error boundary implementation
- Loading and error states
- Accessibility ARIA labels
- Mobile-responsive design

Include:
- Component file with full imports
- CSS module with responsive breakpoints
- Unit test file with RTL
- Storybook story configuration
```

### Dashboard Prototype Template
```npl-fim
Build dashboard layout:
Stack: React 18 + TypeScript + Recharts
Features:
- Grid layout with drag-and-drop widgets
- Real-time data updates via WebSocket
- Dark/light theme toggle with CSS variables
- Export to PDF/CSV functionality

Provide:
- Component hierarchy with type definitions
- WebSocket service implementation
- Theme context provider
- Export utility functions
```

### Form System Template
```npl-fim
Create form validation system:
Library: React Hook Form + Zod
Components:
- Text input with error display
- Select dropdown with search
- File upload with preview
- Date picker with range selection
- Multi-step form wizard

Output:
- Form components with TypeScript generics
- Validation schema examples
- Custom hook for form state
- Accessibility compliance checks
```

## Testing Patterns

### Component Testing
```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { ProductCard } from './ProductCard';

describe('ProductCard', () => {
  const mockProduct = {
    id: '1',
    name: 'Test Product',
    price: 99.99,
    image: '/test.jpg'
  };

  const mockAddToCart = jest.fn();

  beforeEach(() => {
    mockAddToCart.mockClear();
  });

  test('renders product information', () => {
    render(<ProductCard {...mockProduct} onAddToCart={mockAddToCart} />);

    expect(screen.getByText('Test Product')).toBeInTheDocument();
    expect(screen.getByText('$99.99')).toBeInTheDocument();
  });

  test('handles add to cart action', async () => {
    mockAddToCart.mockResolvedValue(undefined);

    render(<ProductCard {...mockProduct} onAddToCart={mockAddToCart} />);

    const button = screen.getByRole('button', { name: /add to cart/i });
    fireEvent.click(button);

    expect(button).toHaveTextContent('Adding...');
    expect(button).toBeDisabled();

    await waitFor(() => {
      expect(mockAddToCart).toHaveBeenCalledWith('1');
      expect(button).toHaveTextContent('Add to Cart');
      expect(button).not.toBeDisabled();
    });
  });
});
```

### Integration Testing
```typescript
import { renderHook, act } from '@testing-library/react';
import { useCartStore } from './useCartStore';

describe('Cart Store', () => {
  beforeEach(() => {
    useCartStore.setState({ items: [], total: 0 });
  });

  test('adds item to cart', () => {
    const { result } = renderHook(() => useCartStore());

    act(() => {
      result.current.addItem({
        id: '1',
        name: 'Test',
        price: 10,
        description: 'Test item',
        image: '/test.jpg',
        category: 'test',
        stock: 5
      });
    });

    expect(result.current.items).toHaveLength(1);
    expect(result.current.total).toBe(10);
  });

  test('updates item quantity', () => {
    const { result } = renderHook(() => useCartStore());

    act(() => {
      result.current.addItem({
        id: '1',
        name: 'Test',
        price: 10,
        description: 'Test item',
        image: '/test.jpg',
        category: 'test',
        stock: 5
      });

      result.current.updateQuantity('1', 3);
    });

    expect(result.current.items[0].quantity).toBe(3);
    expect(result.current.total).toBe(30);
  });
});
```

## Documentation Links

### Official Documentation
- [React 18 Documentation](https://react.dev/)
- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [Vite Guide](https://vitejs.dev/guide/)
- [React Testing Library](https://testing-library.com/docs/react-testing-library/intro/)
- [Zustand Documentation](https://docs.pmnd.rs/zustand/getting-started/introduction)

### API References
- [React Hooks Reference](https://react.dev/reference/react)
- [TypeScript React Types](https://github.com/DefinitelyTyped/DefinitelyTyped/tree/master/types/react)
- [Testing Library Queries](https://testing-library.com/docs/queries/about)

### Best Practices
- [React TypeScript Cheatsheet](https://react-typescript-cheatsheet.netlify.app/)
- [Component Testing Best Practices](https://kentcdodds.com/blog/common-mistakes-with-react-testing-library)
- [Accessibility Guidelines (WCAG 2.1)](https://www.w3.org/WAI/WCAG21/quickref/)