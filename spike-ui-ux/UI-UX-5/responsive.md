# Responsive Patterns

> Strategies for creating interfaces that work across all screen sizes. Mobile-first, fluid, and adaptive.

---

## 1. Responsive Philosophy

### 1.1 Mobile-First Approach

Start with mobile constraints, enhance for larger screens:

```css
/* Mobile base (default) */
.component {
  padding: 16px;
  font-size: 16px;
}

/* Tablet enhancement */
@media (min-width: 768px) {
  .component {
    padding: 24px;
    font-size: 18px;
  }
}

/* Desktop enhancement */
@media (min-width: 1024px) {
  .component {
    padding: 32px;
  }
}
```

### 1.2 Why Mobile-First?

| Benefit | Explanation |
|---------|-------------|
| Performance | Mobile gets minimal CSS, no overrides |
| Prioritization | Forces focus on essential content |
| Progressive enhancement | Features added, not removed |
| Future-proof | New devices tend toward mobile patterns |

### 1.3 Breakpoint System

```css
:root {
  --bp-xs: 320px;   /* Small phones */
  --bp-sm: 480px;   /* Large phones */
  --bp-md: 768px;   /* Tablets */
  --bp-lg: 1024px;  /* Small laptops */
  --bp-xl: 1280px;  /* Desktops */
  --bp-2xl: 1536px; /* Large desktops */
}

/* Named breakpoints for clarity */
@custom-media --mobile (max-width: 767px);
@custom-media --tablet (min-width: 768px) and (max-width: 1023px);
@custom-media --desktop (min-width: 1024px);
```

---

## 2. Fluid Design

### 2.1 Fluid Typography

```css
:root {
  /* Fluid type scale using clamp() */
  --text-xs: clamp(0.75rem, 0.7rem + 0.25vw, 0.875rem);
  --text-sm: clamp(0.875rem, 0.8rem + 0.35vw, 1rem);
  --text-base: clamp(1rem, 0.9rem + 0.5vw, 1.125rem);
  --text-lg: clamp(1.125rem, 1rem + 0.75vw, 1.5rem);
  --text-xl: clamp(1.5rem, 1.2rem + 1.5vw, 2.25rem);
  --text-2xl: clamp(2rem, 1.5rem + 2.5vw, 3rem);
  --text-3xl: clamp(2.5rem, 1.8rem + 3.5vw, 4.5rem);
  --text-display: clamp(3rem, 2rem + 5vw, 6rem);
}

/* Usage */
h1 { font-size: var(--text-3xl); }
h2 { font-size: var(--text-2xl); }
p { font-size: var(--text-base); }
```

### 2.2 Fluid Spacing

```css
:root {
  /* Fluid spacing scale */
  --space-xs: clamp(4px, 1vw, 8px);
  --space-sm: clamp(8px, 2vw, 16px);
  --space-md: clamp(16px, 3vw, 24px);
  --space-lg: clamp(24px, 4vw, 48px);
  --space-xl: clamp(48px, 6vw, 80px);
  --space-2xl: clamp(64px, 10vw, 120px);
}

/* Section spacing */
.section {
  padding-block: var(--space-xl);
}

/* Component spacing */
.card {
  padding: var(--space-md);
  gap: var(--space-sm);
}
```

### 2.3 Fluid Containers

```css
.container {
  width: 100%;
  max-width: 1280px;
  margin-inline: auto;
  padding-inline: clamp(16px, 5vw, 64px);
}

/* Narrow container for reading */
.container-narrow {
  max-width: 65ch;
}

/* Wide container for full layouts */
.container-wide {
  max-width: 1440px;
}

/* Full bleed */
.container-full {
  max-width: none;
  padding-inline: 0;
}
```

---

## 3. Container Queries

Container queries allow components to respond to their container, not the viewport.

### 3.1 Basic Container Query

```css
/* Define container */
.card-wrapper {
  container-type: inline-size;
  container-name: card;
}

/* Component responds to container */
.card {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

@container card (min-width: 400px) {
  .card {
    flex-direction: row;
    align-items: center;
  }
  
  .card-image {
    width: 150px;
    flex-shrink: 0;
  }
}

@container card (min-width: 600px) {
  .card {
    gap: 24px;
  }
  
  .card-image {
    width: 200px;
  }
}
```

### 3.2 Container Query Use Cases

| Use Case | Why Container Query |
|----------|---------------------|
| Card in sidebar vs main area | Same component, different contexts |
| Widget on dashboard | Grid cell size varies |
| Product card in list vs grid | Layout changes based on parent |
| Navigation in header vs drawer | Different available space |

### 3.3 Named Containers

```css
/* Multiple container contexts */
.sidebar {
  container-type: inline-size;
  container-name: sidebar;
}

.main-content {
  container-type: inline-size;
  container-name: main;
}

/* Component adapts to its container */
@container sidebar (min-width: 250px) {
  .widget { /* sidebar-specific styles */ }
}

@container main (min-width: 600px) {
  .widget { /* main-content-specific styles */ }
}
```

### 3.4 Container Query Units

```css
.card-title {
  /* Size relative to container */
  font-size: clamp(1rem, 5cqi, 1.5rem);
}

/* cqi = container query inline size
   cqb = container query block size
   cqw = container width
   cqh = container height
   cqmin = smaller of cqi/cqb
   cqmax = larger of cqi/cqb */
```

---

## 4. Responsive Layout Patterns

### 4.1 Stack to Grid

```css
.grid-adaptive {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(min(300px, 100%), 1fr));
  gap: 24px;
}
```

### 4.2 Sidebar Layout

```css
.layout-sidebar {
  display: grid;
  grid-template-columns: 1fr;
  gap: 24px;
}

@media (min-width: 768px) {
  .layout-sidebar {
    grid-template-columns: 260px 1fr;
  }
}

/* Or with container queries */
@container (min-width: 800px) {
  .layout-sidebar {
    grid-template-columns: 260px 1fr;
  }
}
```

### 4.3 Holy Grail Layout

```css
.layout-holy-grail {
  display: grid;
  grid-template-areas:
    "header"
    "main"
    "sidebar"
    "footer";
  gap: 24px;
}

@media (min-width: 768px) {
  .layout-holy-grail {
    grid-template-areas:
      "header  header"
      "sidebar main"
      "footer  footer";
    grid-template-columns: 200px 1fr;
  }
}

@media (min-width: 1024px) {
  .layout-holy-grail {
    grid-template-areas:
      "header header header"
      "nav    main   sidebar"
      "footer footer footer";
    grid-template-columns: 200px 1fr 260px;
  }
}
```

### 4.4 Responsive Bento Grid

```css
.bento {
  display: grid;
  gap: 16px;
  grid-template-columns: 1fr;
}

@media (min-width: 640px) {
  .bento {
    grid-template-columns: repeat(2, 1fr);
  }
  .bento-featured {
    grid-column: span 2;
  }
}

@media (min-width: 1024px) {
  .bento {
    grid-template-columns: repeat(4, 1fr);
  }
  .bento-featured {
    grid-column: span 2;
    grid-row: span 2;
  }
}
```

---

## 5. Responsive Components

### 5.1 Navigation

```css
/* Mobile: hamburger menu */
.nav {
  display: none;
}

.nav-toggle {
  display: block;
}

/* Desktop: horizontal nav */
@media (min-width: 768px) {
  .nav {
    display: flex;
    gap: 32px;
  }
  
  .nav-toggle {
    display: none;
  }
}

/* Alternative: Bottom tab bar on mobile */
.tab-bar {
  display: flex;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
}

@media (min-width: 768px) {
  .tab-bar {
    display: none;
  }
}
```

### 5.2 Tables

```css
/* Responsive table: cards on mobile */
.table-responsive {
  width: 100%;
}

@media (max-width: 768px) {
  .table-responsive thead {
    display: none;
  }
  
  .table-responsive tr {
    display: block;
    margin-bottom: 16px;
    padding: 16px;
    border: 1px solid var(--border);
    border-radius: 8px;
  }
  
  .table-responsive td {
    display: flex;
    justify-content: space-between;
    padding: 8px 0;
    border-bottom: 1px solid var(--border);
  }
  
  .table-responsive td::before {
    content: attr(data-label);
    font-weight: 600;
  }
  
  .table-responsive td:last-child {
    border-bottom: none;
  }
}
```

### 5.3 Cards

```css
.card {
  display: flex;
  flex-direction: column;
}

/* Horizontal card on larger screens */
@container (min-width: 500px) {
  .card-horizontal {
    flex-direction: row;
  }
  
  .card-horizontal .card-image {
    width: 40%;
    flex-shrink: 0;
  }
}
```

### 5.4 Forms

```css
.form-row {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

@media (min-width: 640px) {
  .form-row {
    flex-direction: row;
  }
  
  .form-row > * {
    flex: 1;
  }
}

/* Button placement */
.form-actions {
  display: flex;
  flex-direction: column-reverse;
  gap: 12px;
}

@media (min-width: 640px) {
  .form-actions {
    flex-direction: row;
    justify-content: flex-end;
  }
}
```

---

## 6. Responsive Images

### 6.1 Responsive Image Basics

```html
<!-- Simple responsive -->
<img 
  src="image.jpg"
  alt="Description"
  style="max-width: 100%; height: auto;"
/>

<!-- Art direction with picture -->
<picture>
  <source media="(min-width: 1024px)" srcset="large.jpg">
  <source media="(min-width: 640px)" srcset="medium.jpg">
  <img src="small.jpg" alt="Description">
</picture>

<!-- Resolution switching -->
<img
  srcset="image-400.jpg 400w,
          image-800.jpg 800w,
          image-1200.jpg 1200w"
  sizes="(min-width: 1024px) 50vw,
         (min-width: 640px) 75vw,
         100vw"
  src="image-800.jpg"
  alt="Description"
/>
```

### 6.2 Aspect Ratio

```css
.image-container {
  aspect-ratio: 16 / 9;
  overflow: hidden;
}

.image-container img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* Different ratios */
.aspect-square { aspect-ratio: 1; }
.aspect-video { aspect-ratio: 16 / 9; }
.aspect-photo { aspect-ratio: 4 / 3; }
.aspect-portrait { aspect-ratio: 3 / 4; }
```

### 6.3 Background Images

```css
.hero-bg {
  background-image: url('hero-mobile.jpg');
  background-size: cover;
  background-position: center;
}

@media (min-width: 768px) {
  .hero-bg {
    background-image: url('hero-tablet.jpg');
  }
}

@media (min-width: 1024px) {
  .hero-bg {
    background-image: url('hero-desktop.jpg');
  }
}

/* Or use image-set for resolution */
.hero-bg {
  background-image: image-set(
    url('hero.jpg') 1x,
    url('hero@2x.jpg') 2x
  );
}
```

---

## 7. Touch Considerations

### 7.1 Touch Targets

```css
/* Minimum touch target: 44x44px (iOS), 48x48px (Material) */
.touch-target {
  min-width: 44px;
  min-height: 44px;
  
  /* Increase tap area without changing visual size */
  position: relative;
}

.touch-target::before {
  content: '';
  position: absolute;
  inset: -8px; /* Extends touch area */
}
```

### 7.2 Hover vs Touch

```css
/* Hover only on devices that support it */
@media (hover: hover) {
  .card:hover {
    transform: translateY(-4px);
  }
}

/* Touch devices: show on tap */
@media (hover: none) {
  .card:active {
    transform: scale(0.98);
  }
}

/* Or use pointer media query */
@media (pointer: fine) {
  /* Mouse/stylus precision */
  .button { padding: 8px 16px; }
}

@media (pointer: coarse) {
  /* Touch/finger */
  .button { padding: 12px 24px; }
}
```

### 7.3 Swipe Gestures

```css
.carousel {
  display: flex;
  overflow-x: auto;
  scroll-snap-type: x mandatory;
  -webkit-overflow-scrolling: touch;
}

.carousel-item {
  flex: 0 0 100%;
  scroll-snap-align: start;
}

/* Hide scrollbar but keep functionality */
.carousel {
  scrollbar-width: none;
}

.carousel::-webkit-scrollbar {
  display: none;
}
```

---

## 8. Responsive Typography

### 8.1 Reading Width

```css
/* Optimal reading width */
.prose {
  max-width: 65ch; /* About 65 characters */
}

/* Wider for UI text */
.ui-text {
  max-width: 45ch;
}

/* Full width for headings */
h1, h2 {
  max-width: none;
}
```

### 8.2 Responsive Line Height

```css
/* Tighter line height for large text */
h1 {
  font-size: var(--text-3xl);
  line-height: 1.1;
}

/* Looser for body text */
p {
  font-size: var(--text-base);
  line-height: 1.6;
}

@media (min-width: 768px) {
  p {
    line-height: 1.7; /* More generous on larger screens */
  }
}
```

### 8.3 Truncation

```css
/* Single line truncate */
.truncate {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

/* Multi-line truncate */
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.line-clamp-3 {
  -webkit-line-clamp: 3;
}
```

---

## 9. Testing Responsive Design

### 9.1 Key Test Points

| Viewport Width | Device Class | Critical Tests |
|----------------|--------------|----------------|
| 320px | iPhone SE, small Android | Content fits, no overflow |
| 375px | iPhone standard | Primary target |
| 414px | iPhone Plus/Max | Large phone |
| 768px | iPad portrait | Tablet breakpoint |
| 1024px | iPad landscape, laptop | Desktop breakpoint |
| 1280px | Standard desktop | Content max-width |
| 1920px+ | Large monitors | No awkward stretching |

### 9.2 Testing Checklist

- [ ] No horizontal scroll at any breakpoint
- [ ] Touch targets ≥44px on mobile
- [ ] Text readable without zooming (≥16px)
- [ ] Images scale proportionally
- [ ] Navigation accessible at all sizes
- [ ] Forms usable on mobile
- [ ] Modals fit viewport
- [ ] Tables don't break layout
- [ ] Spacing feels appropriate
- [ ] No orphaned words in headlines

### 9.3 Debug CSS

```css
/* Highlight elements breaking layout */
* {
  outline: 1px solid red !important;
}

/* Show breakpoint indicator */
body::before {
  content: 'Mobile';
  position: fixed;
  top: 0;
  left: 0;
  background: red;
  color: white;
  padding: 4px 8px;
  font-size: 12px;
  z-index: 9999;
}

@media (min-width: 768px) {
  body::before { content: 'Tablet'; background: orange; }
}

@media (min-width: 1024px) {
  body::before { content: 'Desktop'; background: green; }
}
```

---

## 10. Responsive Best Practices

### 10.1 Do's

- Start mobile-first
- Use relative units (rem, em, %, vw)
- Test on real devices
- Consider thumb zones on mobile
- Use container queries for components
- Keep breakpoints content-driven

### 10.2 Don'ts

- Don't hide critical content on mobile
- Don't use fixed widths
- Don't assume viewport = device
- Don't forget landscape orientation
- Don't ignore notches/safe areas
- Don't test only in browser DevTools

### 10.3 Safe Area Handling

```css
/* iOS notch and home indicator */
.header {
  padding-top: env(safe-area-inset-top);
}

.bottom-bar {
  padding-bottom: env(safe-area-inset-bottom);
}

.content {
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
}
```

---

*Version: 0.1.0*
*Last updated: 2026-01-29*
