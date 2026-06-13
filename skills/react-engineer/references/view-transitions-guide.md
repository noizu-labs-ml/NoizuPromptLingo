# View Transitions API for React/Next.js

## Overview

The View Transitions API provides native browser support for smooth animated transitions between DOM states. It works for both SPA state changes and cross-document navigations (MPA). This guide covers browser support, API usage, React/Next.js integration, and production patterns.

---

## 1. Browser Support and Progressive Enhancement

| Browser | Version | Status |
|---------|---------|--------|
| Chrome | 111+ | Shipped |
| Edge | 111+ | Shipped |
| Safari | 18+ | Shipped |
| Firefox | 130+ (behind flag in earlier) | Shipped |

### Progressive Enhancement Pattern

```tsx
function isViewTransitionSupported(): boolean {
  return typeof document !== 'undefined' &&
    'startViewTransition' in document;
}

// Always wrap in a feature check
function updateWithTransition(updateCallback: () => void) {
  if (isViewTransitionSupported()) {
    document.startViewTransition(updateCallback);
  } else {
    updateCallback(); // fallback: instant update
  }
}
```

---

## 2. SPA Transitions: `document.startViewTransition()`

The core API for single-page applications. It takes a callback that updates the DOM.

```tsx
// Basic usage
document.startViewTransition(() => {
  // Update your React state here
  setCurrentPage('about');
});
```

### How It Works

1. Browser takes a screenshot of the current state
2. Your callback runs (state update, DOM change)
3. Browser takes a screenshot of the new state
4. Browser animates between the two snapshots using CSS

```tsx
// React integration with useState
function Navigation() {
  const [page, setPage] = useState('home');

  function navigate(newPage: string) {
    if (!document.startViewTransition) {
      setPage(newPage);
      return;
    }

    document.startViewTransition(() => {
      flushSync(() => {
        setPage(newPage);
      });
    });
  }

  return (
    <nav>
      <button onClick={() => navigate('home')}>Home</button>
      <button onClick={() => navigate('about')}>About</button>
      <button onClick={() => navigate('contact')}>Contact</button>
      <main>{page === 'home' ? <Home /> : page === 'about' ? <About /> : <Contact />}</main>
    </nav>
  );
}
```

**Important**: Use `flushSync` from `react-dom` inside the callback so React synchronously commits the DOM update before the transition captures the new state.

```tsx
import { flushSync } from 'react-dom';

function TransitionButton({ onClick, children }: { onClick: () => void; children: React.ReactNode }) {
  function handleClick() {
    if (!document.startViewTransition) {
      onClick();
      return;
    }
    document.startViewTransition(() => {
      flushSync(() => {
        onClick();
      });
    });
  }

  return <button onClick={handleClick}>{children}</button>;
}
```

---

## 3. Cross-Document (MPA) Transitions

For multi-page apps or full navigations between routes, use the `@view-transition` CSS rule.

```css
/* Enable cross-document transitions globally */
@view-transition {
  navigation: auto;
}
```

This alone enables default cross-fade transitions between page navigations. Pair with `view-transition-name` to create shared element transitions.

### `<link rel="expect">` for Critical Content

Hints to the browser which elements should be ready before starting the transition:

```html
<link rel="expect" href="#main-content" />
```

---

## 4. CSS Pseudo-Elements for Transition Customization

The View Transitions API creates a pseudo-element tree during the transition:

```
::view-transition
  └── ::view-transition-group(root)
        └── ::view-transition-image-pair(root)
              ├── ::view-transition-old(root)
              └── ::view-transition-new(root)
```

### Default Cross-Fade

```css
/* Default animation (cross-fade) */
::view-transition-old(root) {
  animation: 0.25s ease both fade-out;
}

::view-transition-new(root) {
  animation: 0.25s ease both fade-in;
}

@keyframes fade-out {
  to { opacity: 0; }
}

@keyframes fade-in {
  from { opacity: 0; }
}
```

### Slide Transition

```css
::view-transition-old(root) {
  animation: 0.3s ease both slide-out;
}

::view-transition-new(root) {
  animation: 0.3s ease both slide-in;
}

@keyframes slide-out {
  to {
    transform: translateX(-100%);
    opacity: 0;
  }
}

@keyframes slide-in {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
}
```

### Customizing Specific Elements with `view-transition-name`

```css
/* Assign a unique name to elements you want custom animations on */
.hero-image {
  view-transition-name: hero;
}

.page-title {
  view-transition-name: title;
}

.sidebar {
  view-transition-name: sidebar;
}

/* Custom animation for the hero image */
::view-transition-old(hero) {
  animation: 0.4s ease both fade-and-scale-out;
}

::view-transition-new(hero) {
  animation: 0.4s ease both fade-and-scale-in;
}

@keyframes fade-and-scale-out {
  to {
    opacity: 0;
    transform: scale(0.95);
  }
}

@keyframes fade-and-scale-in {
  from {
    opacity: 0;
    transform: scale(1.05);
  }
}

/* Exclude elements from the transition (e.g., ads, chat widgets) */
.chat-widget {
  view-transition-name: none;
}
```

### Group Transitions

```css
/* The group controls position and size interpolation */
::view-transition-group(card) {
  animation-duration: 0.35s;
  animation-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

/* Image pair controls cross-fade */
::view-transition-image-pair(card) {
  isolation: auto; /* override default isolation for blending */
}
```

---

## 5. Next.js Integration

### Next.js 15.2+ (Experimental)

```js
// next.config.js
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    viewTransition: true,
  },
};

module.exports = nextConfig;
```

Enables automatic view transitions on route navigations using `@view-transition { navigation: auto; }` and provides a `useViewTransition` hook.

### Next.js 16 (Stable)

View transitions are enabled by default for App Router navigations.

```tsx
'use client';

import { useRouter } from 'next/navigation';
import { useViewTransition } from 'next/navigation';

function NavigationLink({ href, children }: { href: string; children: React.ReactNode }) {
  const router = useRouter();
  const startTransition = useViewTransition();

  function handleClick(e: React.MouseEvent) {
    e.preventDefault();
    startTransition(() => {
      router.push(href);
    });
  }

  return <a href={href} onClick={handleClick}>{children}</a>;
}
```

### Custom Transition Names in Next.js

```tsx
// Assign view-transition-name via CSS modules or inline styles
// app/products/[id]/page.module.css
.productImage {
  view-transition-name: product-image;
}

// app/products/page.module.css
.productCardImage {
  view-transition-name: none; /* don't transition grid thumbnails */
}
```

```tsx
// app/products/page.tsx
import styles from './page.module.css';

export default function ProductGrid({ products }: { products: Product[] }) {
  return (
    <div className="grid grid-cols-4 gap-4">
      {products.map((product) => (
        <Link key={product.id} href={`/products/${product.id}`}>
          <img
            src={product.image}
            className={styles.productCardImage}
            alt={product.name}
          />
          <h3>{product.name}</h3>
        </Link>
      ))}
    </div>
  );
}

// app/products/[id]/page.tsx
import styles from './page.module.css';

export default function ProductDetail({ product }: { product: Product }) {
  return (
    <div>
      <img
        src={product.image}
        className={styles.productImage}
        alt={product.name}
      />
      <h1>{product.name}</h1>
    </div>
  );
}
```

---

## 6. Navigation API + View Transitions: Directional Animations

Use `navigateEvent.info` to pass direction metadata for slide animations:

```tsx
'use client';

import { useCallback } from 'react';
import { useRouter } from 'next/navigation';

function useDirectionalNavigation() {
  const router = useRouter();

  const navigateForward = useCallback(
    (href: string) => {
      document.documentElement.dataset.transitionDirection = 'forward';
      router.push(href);
    },
    [router]
  );

  const navigateBack = useCallback(
    (href: string) => {
      document.documentElement.dataset.transitionDirection = 'back';
      router.push(href);
    },
    [router]
  );

  return { navigateForward, navigateBack };
}
```

```css
/* Directional slide animations */
[data-transition-direction='forward']::view-transition-old(root) {
  animation: 0.3s ease both slide-left-out;
}

[data-transition-direction='forward']::view-transition-new(root) {
  animation: 0.3s ease both slide-left-in;
}

[data-transition-direction='back']::view-transition-old(root) {
  animation: 0.3s ease both slide-right-out;
}

[data-transition-direction='back']::view-transition-new(root) {
  animation: 0.3s ease both slide-right-in;
}

@keyframes slide-left-out {
  to { transform: translateX(-30%); opacity: 0; }
}
@keyframes slide-left-in {
  from { transform: translateX(30%); opacity: 0; }
}
@keyframes slide-right-out {
  to { transform: translateX(30%); opacity: 0; }
}
@keyframes slide-right-in {
  from { transform: translateX(-30%); opacity: 0; }
}
```

---

## 7. Common Patterns

### List-to-Detail Transition

```tsx
// Product list card
<div
  style={{ viewTransitionName: `product-${product.id}` }}
  className="product-card"
>
  <img src={product.image} alt={product.name} />
  <h3>{product.name}</h3>
</div>

// Product detail page (same view-transition-name)
<div
  style={{ viewTransitionName: `product-${product.id}` }}
  className="product-detail"
>
  <img src={product.image} alt={product.name} />
  <h1>{product.name}</h1>
  <p>{product.description}</p>
</div>
```

The browser will automatically animate the card from its list position to its detail position.

### Theme Switching

```tsx
function ThemeToggle() {
  const [theme, setTheme] = useState<'light' | 'dark'>('light');

  function toggle() {
    if (!document.startViewTransition) {
      setTheme(theme === 'light' ? 'dark' : 'light');
      return;
    }

    document.startViewTransition(() => {
      flushSync(() => {
        setTheme(theme === 'light' ? 'dark' : 'light');
      });
    });
  }

  return <button onClick={toggle}>Toggle Theme</button>;
}
```

```css
/* Smooth color transition during theme switch */
::view-transition-old(root),
::view-transition-new(root) {
  animation: none;
  mix-blend-mode: normal;
}

/* Invert the old snapshot for a circular reveal effect */
.dark::view-transition-old(root) {
  animation: 0.5s ease both circle-reveal;
}

@keyframes circle-reveal {
  from {
    clip-path: circle(0% at var(--toggle-x, 50%) var(--toggle-y, 50%));
  }
  to {
    clip-path: circle(100% at var(--toggle-x, 50%) var(--toggle-y, 50%));
  }
}
```

---

## 8. Performance Considerations

### Avoiding Layout Thrash During Snapshots

The browser needs to take a screenshot of the old and new states. If the DOM is changing during the snapshot, you get visual glitches.

```tsx
// BAD: Async operations inside startViewTransition
document.startViewTransition(async () => {
  const data = await fetchData(); // Layout thrash!
  flushSync(() => setData(data));
});

// GOOD: Fetch data first, then transition with synchronous update
async function handleTransition() {
  const data = await fetchData();
  document.startViewTransition(() => {
    flushSync(() => setData(data));
  });
}
```

### Transition Naming Best Practices

```css
/* BAD: Dynamically generated names on many elements */
.grid-item:nth-child(1) { view-transition-name: item-1; }
.grid-item:nth-child(2) { view-transition-name: item-2; }
/* ...hundreds of items = hundreds of snapshots = jank */

/* GOOD: Name only the transitioning element, use unique IDs */
.selected-item {
  view-transition-name: selected-item;
}
```

### Reducing Snapshot Overhead

```css
/* Exclude expensive elements from transitions */
.video-player,
.canvas-element,
.third-party-widget {
  view-transition-name: none;
}
```

---

## 9. Accessibility: Respecting `prefers-reduced-motion`

```css
/* Disable view transitions for users who prefer reduced motion */
@media (prefers-reduced-motion: reduce) {
  ::view-transition-group(*),
  ::view-transition-old(*),
  ::view-transition-new(*) {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
  }
}
```

```tsx
// Also check in JS before starting transitions
function prefersReducedMotion(): boolean {
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

function safeStartViewTransition(callback: () => void) {
  if (prefersReducedMotion() || !document.startViewTransition) {
    callback();
    return;
  }
  document.startViewTransition(() => flushSync(callback));
}
```

---

## 10. Custom Hook for React

```tsx
import { flushSync } from 'react-dom';
import { useCallback, useRef } from 'react';

export function useViewTransition() {
  const isTransitioning = useRef(false);

  const startTransition = useCallback((callback: () => void) => {
    if (isTransitioning.current) {
      callback(); // don't queue transitions
      return;
    }

    if (typeof document === 'undefined' || !document.startViewTransition) {
      callback();
      return;
    }

    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
      callback();
      return;
    }

    isTransitioning.current = true;
    const transition = document.startViewTransition(() => {
      flushSync(callback);
    });

    transition.finished.finally(() => {
      isTransitioning.current = false;
    });
  }, []);

  return { startTransition, isTransitioning };
}

// Usage
function MyComponent() {
  const { startTransition } = useViewTransition();
  const [view, setView] = useState<'grid' | 'list'>('grid');

  return (
    <button
      onClick={() => startTransition(() => setView(view === 'grid' ? 'list' : 'grid'))}
    >
      Toggle View
    </button>
  );
}
```
