# HTML/CSS Implementation Guide

> Vanilla HTML and CSS patterns for static sites, email templates, and framework-free implementations.

---

## 1. When to Use Vanilla HTML/CSS

| Use Case | Why Vanilla |
|----------|-------------|
| Static marketing sites | No build step needed |
| Email templates | Framework JS won't work |
| Embedded widgets | Minimal dependencies |
| Legacy system integration | Compatibility |
| Learning/prototyping | Simplicity |
| Performance-critical | Zero JS overhead |

---

## 2. Project Structure

```
project/
├── index.html
├── css/
│   ├── reset.css        # CSS reset
│   ├── tokens.css       # Design tokens
│   ├── base.css         # Typography, base styles
│   ├── components.css   # Reusable components
│   ├── layout.css       # Layout utilities
│   └── pages/
│       └── landing.css  # Page-specific styles
├── js/
│   └── main.js          # Minimal JS (if needed)
├── images/
└── fonts/
```

---

## 3. CSS Architecture

### 3.1 Design Tokens

```css
/* css/tokens.css */
:root {
  /* Colors */
  --color-primary: #3B82F6;
  --color-primary-dark: #2563EB;
  --color-secondary: #64748B;
  --color-accent: #F59E0B;
  
  --color-success: #22C55E;
  --color-warning: #F59E0B;
  --color-error: #EF4444;
  
  --color-bg: #FFFFFF;
  --color-bg-alt: #F8FAFC;
  --color-text: #1E293B;
  --color-text-muted: #64748B;
  --color-border: #E2E8F0;
  
  /* Typography */
  --font-sans: system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, monospace;
  
  --text-xs: 0.75rem;    /* 12px */
  --text-sm: 0.875rem;   /* 14px */
  --text-base: 1rem;     /* 16px */
  --text-lg: 1.125rem;   /* 18px */
  --text-xl: 1.25rem;    /* 20px */
  --text-2xl: 1.5rem;    /* 24px */
  --text-3xl: 1.875rem;  /* 30px */
  --text-4xl: 2.25rem;   /* 36px */
  --text-5xl: 3rem;      /* 48px */
  
  --leading-tight: 1.25;
  --leading-normal: 1.5;
  --leading-relaxed: 1.75;
  
  /* Spacing */
  --space-1: 0.25rem;    /* 4px */
  --space-2: 0.5rem;     /* 8px */
  --space-3: 0.75rem;    /* 12px */
  --space-4: 1rem;       /* 16px */
  --space-5: 1.25rem;    /* 20px */
  --space-6: 1.5rem;     /* 24px */
  --space-8: 2rem;       /* 32px */
  --space-10: 2.5rem;    /* 40px */
  --space-12: 3rem;      /* 48px */
  --space-16: 4rem;      /* 64px */
  --space-20: 5rem;      /* 80px */
  --space-24: 6rem;      /* 96px */
  
  /* Radii */
  --radius-sm: 0.25rem;
  --radius-md: 0.375rem;
  --radius-lg: 0.5rem;
  --radius-xl: 0.75rem;
  --radius-2xl: 1rem;
  --radius-full: 9999px;
  
  /* Shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  
  /* Transitions */
  --transition-fast: 150ms ease;
  --transition-normal: 200ms ease;
  --transition-slow: 300ms ease;
  
  /* Container */
  --container-max: 1200px;
  --container-padding: var(--space-4);
}

/* Dark mode */
@media (prefers-color-scheme: dark) {
  :root {
    --color-bg: #0F172A;
    --color-bg-alt: #1E293B;
    --color-text: #F8FAFC;
    --color-text-muted: #94A3B8;
    --color-border: #334155;
  }
}
```

### 3.2 CSS Reset

```css
/* css/reset.css */
*, *::before, *::after {
  box-sizing: border-box;
}

* {
  margin: 0;
}

html {
  -webkit-text-size-adjust: 100%;
}

body {
  line-height: var(--leading-normal);
  -webkit-font-smoothing: antialiased;
}

img, picture, video, canvas, svg {
  display: block;
  max-width: 100%;
}

input, button, textarea, select {
  font: inherit;
}

p, h1, h2, h3, h4, h5, h6 {
  overflow-wrap: break-word;
}

a {
  color: inherit;
  text-decoration: none;
}

button {
  background: none;
  border: none;
  cursor: pointer;
}
```

### 3.3 Base Styles

```css
/* css/base.css */
body {
  font-family: var(--font-sans);
  font-size: var(--text-base);
  color: var(--color-text);
  background-color: var(--color-bg);
}

h1, h2, h3, h4, h5, h6 {
  font-weight: 700;
  line-height: var(--leading-tight);
}

h1 { font-size: var(--text-5xl); }
h2 { font-size: var(--text-4xl); }
h3 { font-size: var(--text-3xl); }
h4 { font-size: var(--text-2xl); }
h5 { font-size: var(--text-xl); }
h6 { font-size: var(--text-lg); }

p {
  color: var(--color-text-muted);
}

a:hover {
  color: var(--color-primary);
}

/* Focus styles */
:focus-visible {
  outline: 2px solid var(--color-primary);
  outline-offset: 2px;
}
```

---

## 4. Components

### 4.1 Buttons

```css
/* css/components.css */

/* Base button */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: var(--space-2) var(--space-4);
  font-size: var(--text-sm);
  font-weight: 500;
  line-height: 1;
  border-radius: var(--radius-md);
  transition: all var(--transition-fast);
  cursor: pointer;
}

.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

/* Sizes */
.btn--sm {
  padding: var(--space-1) var(--space-3);
  font-size: var(--text-xs);
}

.btn--lg {
  padding: var(--space-3) var(--space-6);
  font-size: var(--text-base);
  border-radius: var(--radius-lg);
}

/* Variants */
.btn--primary {
  background-color: var(--color-primary);
  color: white;
}

.btn--primary:hover {
  background-color: var(--color-primary-dark);
}

.btn--secondary {
  background-color: transparent;
  color: var(--color-text);
  border: 1px solid var(--color-border);
}

.btn--secondary:hover {
  background-color: var(--color-bg-alt);
}

.btn--ghost {
  background-color: transparent;
  color: var(--color-primary);
}

.btn--ghost:hover {
  background-color: var(--color-primary);
  background-opacity: 0.1;
}
```

```html
<button class="btn btn--primary">Primary Button</button>
<button class="btn btn--secondary">Secondary Button</button>
<button class="btn btn--primary btn--lg">Large Primary</button>
```

### 4.2 Forms

```css
/* Input */
.input {
  display: block;
  width: 100%;
  padding: var(--space-2) var(--space-3);
  font-size: var(--text-sm);
  color: var(--color-text);
  background-color: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  transition: border-color var(--transition-fast), box-shadow var(--transition-fast);
}

.input:focus {
  outline: none;
  border-color: var(--color-primary);
  box-shadow: 0 0 0 3px rgb(59 130 246 / 0.1);
}

.input::placeholder {
  color: var(--color-text-muted);
}

.input--error {
  border-color: var(--color-error);
}

/* Label */
.label {
  display: block;
  margin-bottom: var(--space-1);
  font-size: var(--text-sm);
  font-weight: 500;
  color: var(--color-text);
}

/* Form group */
.form-group {
  margin-bottom: var(--space-4);
}

/* Error message */
.form-error {
  margin-top: var(--space-1);
  font-size: var(--text-sm);
  color: var(--color-error);
}

/* Inline form */
.form-inline {
  display: flex;
  gap: var(--space-2);
}

.form-inline .input {
  flex: 1;
}
```

```html
<div class="form-group">
  <label class="label" for="email">Email</label>
  <input class="input" type="email" id="email" placeholder="you@example.com">
</div>

<form class="form-inline">
  <input class="input" type="email" placeholder="Enter your email">
  <button class="btn btn--primary">Subscribe</button>
</form>
```

### 4.3 Cards

```css
/* Card */
.card {
  background-color: var(--color-bg);
  border-radius: var(--radius-xl);
  overflow: hidden;
}

.card--bordered {
  border: 1px solid var(--color-border);
}

.card--elevated {
  box-shadow: var(--shadow-lg);
}

.card__image {
  aspect-ratio: 16/9;
  object-fit: cover;
}

.card__content {
  padding: var(--space-4);
}

.card__title {
  margin-bottom: var(--space-2);
  font-size: var(--text-lg);
}

.card__description {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
}

.card__footer {
  padding: var(--space-4);
  padding-top: 0;
}
```

```html
<article class="card card--elevated">
  <img class="card__image" src="image.jpg" alt="">
  <div class="card__content">
    <h3 class="card__title">Card Title</h3>
    <p class="card__description">Card description goes here.</p>
  </div>
  <div class="card__footer">
    <a href="#" class="btn btn--primary">Learn More</a>
  </div>
</article>
```

---

## 5. Layout

### 5.1 Container

```css
/* css/layout.css */
.container {
  width: 100%;
  max-width: var(--container-max);
  margin-left: auto;
  margin-right: auto;
  padding-left: var(--container-padding);
  padding-right: var(--container-padding);
}

.container--narrow {
  max-width: 768px;
}

.container--wide {
  max-width: 1440px;
}
```

### 5.2 Grid System

```css
/* Flexbox grid */
.row {
  display: flex;
  flex-wrap: wrap;
  margin-left: calc(var(--space-4) * -0.5);
  margin-right: calc(var(--space-4) * -0.5);
}

.col {
  padding-left: calc(var(--space-4) * 0.5);
  padding-right: calc(var(--space-4) * 0.5);
  flex: 1;
}

/* Fixed columns */
.col-1 { flex: 0 0 8.333%; max-width: 8.333%; }
.col-2 { flex: 0 0 16.666%; max-width: 16.666%; }
.col-3 { flex: 0 0 25%; max-width: 25%; }
.col-4 { flex: 0 0 33.333%; max-width: 33.333%; }
.col-5 { flex: 0 0 41.666%; max-width: 41.666%; }
.col-6 { flex: 0 0 50%; max-width: 50%; }
.col-7 { flex: 0 0 58.333%; max-width: 58.333%; }
.col-8 { flex: 0 0 66.666%; max-width: 66.666%; }
.col-9 { flex: 0 0 75%; max-width: 75%; }
.col-10 { flex: 0 0 83.333%; max-width: 83.333%; }
.col-11 { flex: 0 0 91.666%; max-width: 91.666%; }
.col-12 { flex: 0 0 100%; max-width: 100%; }

/* CSS Grid alternative */
.grid {
  display: grid;
  gap: var(--space-4);
}

.grid--2 { grid-template-columns: repeat(2, 1fr); }
.grid--3 { grid-template-columns: repeat(3, 1fr); }
.grid--4 { grid-template-columns: repeat(4, 1fr); }

/* Auto-fit responsive grid */
.grid--auto {
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
}
```

### 5.3 Utilities

```css
/* Flexbox */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.items-center { align-items: center; }
.items-start { align-items: flex-start; }
.items-end { align-items: flex-end; }
.justify-center { justify-content: center; }
.justify-between { justify-content: space-between; }
.justify-end { justify-content: flex-end; }
.gap-2 { gap: var(--space-2); }
.gap-4 { gap: var(--space-4); }
.gap-6 { gap: var(--space-6); }
.gap-8 { gap: var(--space-8); }

/* Spacing */
.mt-4 { margin-top: var(--space-4); }
.mt-8 { margin-top: var(--space-8); }
.mt-12 { margin-top: var(--space-12); }
.mb-4 { margin-bottom: var(--space-4); }
.mb-8 { margin-bottom: var(--space-8); }
.py-16 { padding-top: var(--space-16); padding-bottom: var(--space-16); }
.py-24 { padding-top: var(--space-24); padding-bottom: var(--space-24); }

/* Text */
.text-center { text-align: center; }
.text-muted { color: var(--color-text-muted); }
.text-primary { color: var(--color-primary); }
.text-sm { font-size: var(--text-sm); }
.text-lg { font-size: var(--text-lg); }
.font-bold { font-weight: 700; }

/* Display */
.hidden { display: none; }
.block { display: block; }

/* Responsive */
@media (max-width: 768px) {
  .md\:hidden { display: none; }
  .md\:col-12 { flex: 0 0 100%; max-width: 100%; }
  .grid--3 { grid-template-columns: 1fr; }
}
```

---

## 6. Page Sections

### 6.1 Header

```html
<header class="header">
  <div class="container">
    <div class="header__inner">
      <a href="/" class="header__logo">ProductName</a>
      
      <nav class="header__nav">
        <a href="#features">Features</a>
        <a href="#pricing">Pricing</a>
        <a href="#about">About</a>
      </nav>
      
      <a href="#signup" class="btn btn--primary">Get Started</a>
    </div>
  </div>
</header>
```

```css
.header {
  position: sticky;
  top: 0;
  background-color: var(--color-bg);
  border-bottom: 1px solid var(--color-border);
  z-index: 100;
}

.header__inner {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 64px;
}

.header__logo {
  font-size: var(--text-xl);
  font-weight: 700;
  color: var(--color-text);
}

.header__nav {
  display: flex;
  gap: var(--space-6);
}

.header__nav a {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
  transition: color var(--transition-fast);
}

.header__nav a:hover {
  color: var(--color-text);
}
```

### 6.2 Hero Section

```html
<section class="hero">
  <div class="container container--narrow">
    <h1 class="hero__title">Stop Wasting Time on Manual Tasks</h1>
    <p class="hero__subtitle">
      Automate your workflow and focus on what matters most.
    </p>
    
    <form class="hero__form form-inline">
      <input class="input" type="email" placeholder="Enter your email">
      <button class="btn btn--primary btn--lg">Join Waitlist</button>
    </form>
    
    <p class="hero__social-proof">
      Join 1,234 others already on the waitlist
    </p>
  </div>
</section>
```

```css
.hero {
  padding: var(--space-24) 0;
  text-align: center;
  background-color: var(--color-bg-alt);
}

.hero__title {
  margin-bottom: var(--space-6);
}

.hero__subtitle {
  margin-bottom: var(--space-8);
  font-size: var(--text-xl);
}

.hero__form {
  max-width: 500px;
  margin: 0 auto var(--space-6);
}

.hero__social-proof {
  font-size: var(--text-sm);
  color: var(--color-text-muted);
}
```

### 6.3 Features Grid

```html
<section class="section" id="features">
  <div class="container">
    <h2 class="section__title">Why Choose Us</h2>
    
    <div class="grid grid--3">
      <article class="feature-card">
        <div class="feature-card__icon">⚡</div>
        <h3 class="feature-card__title">Lightning Fast</h3>
        <p class="feature-card__description">
          Get results in seconds, not hours. Our AI processes instantly.
        </p>
      </article>
      
      <article class="feature-card">
        <div class="feature-card__icon">🔒</div>
        <h3 class="feature-card__title">Secure by Default</h3>
        <p class="feature-card__description">
          Enterprise-grade encryption. Your data stays private.
        </p>
      </article>
      
      <article class="feature-card">
        <div class="feature-card__icon">🎯</div>
        <h3 class="feature-card__title">Simple to Use</h3>
        <p class="feature-card__description">
          No learning curve required. Start in under 2 minutes.
        </p>
      </article>
    </div>
  </div>
</section>
```

```css
.section {
  padding: var(--space-24) 0;
}

.section__title {
  margin-bottom: var(--space-12);
  text-align: center;
}

.feature-card {
  padding: var(--space-6);
  text-align: center;
  background-color: var(--color-bg);
  border-radius: var(--radius-xl);
  box-shadow: var(--shadow-md);
}

.feature-card__icon {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 48px;
  height: 48px;
  margin-bottom: var(--space-4);
  font-size: 24px;
  background-color: var(--color-bg-alt);
  border-radius: var(--radius-lg);
}

.feature-card__title {
  margin-bottom: var(--space-2);
  font-size: var(--text-lg);
}

.feature-card__description {
  font-size: var(--text-sm);
}
```

---

## 7. Responsive Patterns

### 7.1 Mobile-First Media Queries

```css
/* Base styles: mobile */
.grid--3 {
  grid-template-columns: 1fr;
}

/* Tablet and up */
@media (min-width: 768px) {
  .grid--3 {
    grid-template-columns: repeat(2, 1fr);
  }
  
  .header__nav {
    display: flex;
  }
}

/* Desktop and up */
@media (min-width: 1024px) {
  .grid--3 {
    grid-template-columns: repeat(3, 1fr);
  }
}
```

### 7.2 Container Query Support

```css
/* Modern browsers with container query support */
@supports (container-type: inline-size) {
  .card-container {
    container-type: inline-size;
  }
  
  @container (min-width: 400px) {
    .card {
      display: flex;
    }
    
    .card__image {
      flex: 0 0 40%;
    }
  }
}
```

---

## 8. Performance Tips

### 8.1 Critical CSS

```html
<head>
  <!-- Inline critical CSS -->
  <style>
    /* Only above-fold styles */
    :root { /* tokens */ }
    body { font-family: system-ui; }
    .header { /* header styles */ }
    .hero { /* hero styles */ }
  </style>
  
  <!-- Defer non-critical CSS -->
  <link rel="preload" href="css/main.css" as="style" onload="this.onload=null;this.rel='stylesheet'">
  <noscript><link rel="stylesheet" href="css/main.css"></noscript>
</head>
```

### 8.2 Image Optimization

```html
<!-- Responsive images -->
<img 
  src="hero-400.jpg"
  srcset="hero-400.jpg 400w, hero-800.jpg 800w, hero-1200.jpg 1200w"
  sizes="(max-width: 600px) 100vw, 50vw"
  alt="Hero image"
  loading="lazy"
  decoding="async"
>

<!-- Modern formats with fallback -->
<picture>
  <source srcset="hero.avif" type="image/avif">
  <source srcset="hero.webp" type="image/webp">
  <img src="hero.jpg" alt="Hero image">
</picture>
```

---

## References

- `CORE.md` - Design principles
- `PATTERNS/components.md` - Component patterns
- `PATTERNS/layout.md` - Layout patterns
- `landing-pages.md` - Conversion-focused patterns

---

*Version: 0.1.0*
