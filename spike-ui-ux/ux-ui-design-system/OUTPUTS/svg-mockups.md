# SVG Mockup Generation Guide

> Creating visual mockups as SVG for stakeholder presentations, design documentation, and feedback collection.

---

## 1. Why SVG for Mockups

| Advantage | Benefit |
|-----------|---------|
| **Scalable** | Crisp at any zoom level |
| **Text-based** | Version control friendly (git diff) |
| **Embeddable** | Works in Markdown, HTML, docs |
| **Editable** | Inline comments for feedback |
| **Lightweight** | Small file sizes |
| **Interactive** | Can add hover states, links |

---

## 2. SVG Mockup Structure

### 2.1 Basic Template

```svg
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" 
     viewBox="0 0 1440 900"
     width="1440" 
     height="900">
  
  <!-- Metadata -->
  <title>Landing Page Mockup v1</title>
  <desc>Desktop landing page for Product X</desc>
  
  <!-- Definitions (reusable elements) -->
  <defs>
    <!-- Colors -->
    <linearGradient id="primary-gradient" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#3B82F6"/>
      <stop offset="100%" style="stop-color:#2563EB"/>
    </linearGradient>
    
    <!-- Shadows -->
    <filter id="shadow-sm" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="1" stdDeviation="2" flood-opacity="0.1"/>
    </filter>
    
    <filter id="shadow-md" x="-10%" y="-10%" width="120%" height="120%">
      <feDropShadow dx="0" dy="4" stdDeviation="6" flood-opacity="0.1"/>
    </filter>
    
    <!-- Button symbol -->
    <symbol id="btn-primary" viewBox="0 0 160 44">
      <rect width="160" height="44" rx="8" fill="url(#primary-gradient)"/>
      <text x="80" y="27" text-anchor="middle" fill="white" 
            font-family="system-ui" font-size="14" font-weight="600">
        Button Text
      </text>
    </symbol>
  </defs>
  
  <!-- Background -->
  <rect width="100%" height="100%" fill="#FFFFFF"/>
  
  <!-- Content groups -->
  <g id="header">
    <!-- Header content -->
  </g>
  
  <g id="hero">
    <!-- Hero section -->
  </g>
  
  <g id="features">
    <!-- Features section -->
  </g>
  
  <g id="footer">
    <!-- Footer content -->
  </g>
  
  <!-- Feedback comments (hidden by default) -->
  <!-- FEEDBACK: [reviewer] [date] - Comment here -->
  
</svg>
```

### 2.2 Grayscale Template (Structural)

```svg
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 900">
  
  <defs>
    <!-- Grayscale palette -->
    <style>
      .bg { fill: #FFFFFF; }
      .surface { fill: #F8FAFC; }
      .border { stroke: #E2E8F0; stroke-width: 1; fill: none; }
      .text-primary { fill: #1E293B; }
      .text-secondary { fill: #64748B; }
      .placeholder { fill: #CBD5E1; }
      .interactive { fill: #94A3B8; }
    </style>
  </defs>
  
  <!-- Background -->
  <rect class="bg" width="100%" height="100%"/>
  
  <!-- Header placeholder -->
  <g id="header">
    <rect class="surface" x="0" y="0" width="1440" height="64"/>
    <rect class="border" x="0" y="0" width="1440" height="64"/>
    
    <!-- Logo placeholder -->
    <rect class="placeholder" x="80" y="20" width="120" height="24" rx="4"/>
    
    <!-- Nav items -->
    <rect class="placeholder" x="800" y="24" width="60" height="16" rx="2"/>
    <rect class="placeholder" x="880" y="24" width="60" height="16" rx="2"/>
    <rect class="placeholder" x="960" y="24" width="60" height="16" rx="2"/>
    
    <!-- CTA button -->
    <rect class="interactive" x="1240" y="16" width="120" height="32" rx="6"/>
  </g>
  
  <!-- Hero section -->
  <g id="hero" transform="translate(0, 64)">
    <!-- Headline placeholder -->
    <rect class="placeholder" x="480" y="120" width="480" height="40" rx="4"/>
    
    <!-- Subheadline -->
    <rect class="placeholder" x="520" y="180" width="400" height="20" rx="2"/>
    <rect class="placeholder" x="560" y="210" width="320" height="20" rx="2"/>
    
    <!-- CTA -->
    <rect class="interactive" x="600" y="280" width="240" height="48" rx="8"/>
    
    <!-- Social proof -->
    <rect class="placeholder" x="580" y="360" width="280" height="16" rx="2"/>
  </g>
  
</svg>
```

---

## 3. Component Library

### 3.1 Buttons

```svg
<!-- Primary Button -->
<g id="button-primary">
  <rect x="0" y="0" width="160" height="44" rx="8" fill="#3B82F6"/>
  <text x="80" y="27" text-anchor="middle" fill="white" 
        font-family="system-ui" font-size="14" font-weight="600">
    Join Waitlist
  </text>
</g>

<!-- Secondary Button -->
<g id="button-secondary">
  <rect x="0" y="0" width="160" height="44" rx="8" fill="none" 
        stroke="#E2E8F0" stroke-width="1"/>
  <text x="80" y="27" text-anchor="middle" fill="#1E293B" 
        font-family="system-ui" font-size="14" font-weight="500">
    Learn More
  </text>
</g>

<!-- Ghost Button -->
<g id="button-ghost">
  <text x="0" y="16" fill="#3B82F6" 
        font-family="system-ui" font-size="14" font-weight="500">
    View all →
  </text>
</g>
```

### 3.2 Form Elements

```svg
<!-- Input Field -->
<g id="input-default">
  <rect x="0" y="0" width="320" height="44" rx="6" 
        fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1"/>
  <text x="16" y="27" fill="#94A3B8" 
        font-family="system-ui" font-size="14">
    Enter your email
  </text>
</g>

<!-- Input with value -->
<g id="input-filled">
  <rect x="0" y="0" width="320" height="44" rx="6" 
        fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1"/>
  <text x="16" y="27" fill="#1E293B" 
        font-family="system-ui" font-size="14">
    user@example.com
  </text>
</g>

<!-- Input focused -->
<g id="input-focused">
  <rect x="0" y="0" width="320" height="44" rx="6" 
        fill="#FFFFFF" stroke="#3B82F6" stroke-width="2"/>
  <text x="16" y="27" fill="#1E293B" 
        font-family="system-ui" font-size="14">
    |
  </text>
</g>

<!-- Checkbox -->
<g id="checkbox-checked">
  <rect x="0" y="0" width="20" height="20" rx="4" fill="#3B82F6"/>
  <path d="M4 10 L8 14 L16 6" stroke="white" stroke-width="2" fill="none"/>
</g>

<g id="checkbox-unchecked">
  <rect x="0" y="0" width="20" height="20" rx="4" 
        fill="white" stroke="#E2E8F0" stroke-width="1"/>
</g>
```

### 3.3 Cards

```svg
<!-- Basic Card -->
<g id="card">
  <rect x="0" y="0" width="360" height="200" rx="12" 
        fill="#FFFFFF" filter="url(#shadow-md)"/>
  
  <!-- Image placeholder -->
  <rect x="0" y="0" width="360" height="120" rx="12 12 0 0" fill="#F1F5F9"/>
  
  <!-- Content -->
  <text x="20" y="150" fill="#1E293B" 
        font-family="system-ui" font-size="16" font-weight="600">
    Card Title
  </text>
  <text x="20" y="175" fill="#64748B" 
        font-family="system-ui" font-size="14">
    Card description text goes here
  </text>
</g>

<!-- Stat Card -->
<g id="stat-card">
  <rect x="0" y="0" width="240" height="120" rx="12" 
        fill="#FFFFFF" stroke="#E2E8F0" stroke-width="1"/>
  
  <text x="24" y="40" fill="#64748B" 
        font-family="system-ui" font-size="14">
    Total Users
  </text>
  <text x="24" y="80" fill="#1E293B" 
        font-family="system-ui" font-size="32" font-weight="700">
    1,234
  </text>
  <text x="24" y="100" fill="#22C55E" 
        font-family="system-ui" font-size="14">
    ↑ 12% from last month
  </text>
</g>
```

### 3.4 Navigation

```svg
<!-- Header -->
<g id="header">
  <rect x="0" y="0" width="1440" height="64" fill="#FFFFFF"/>
  <line x1="0" y1="64" x2="1440" y2="64" stroke="#E2E8F0"/>
  
  <!-- Logo -->
  <text x="80" y="38" fill="#1E293B" 
        font-family="system-ui" font-size="20" font-weight="700">
    ProductName
  </text>
  
  <!-- Nav links -->
  <text x="800" y="38" fill="#64748B" font-family="system-ui" font-size="14">
    Features
  </text>
  <text x="880" y="38" fill="#64748B" font-family="system-ui" font-size="14">
    Pricing
  </text>
  <text x="960" y="38" fill="#64748B" font-family="system-ui" font-size="14">
    About
  </text>
  
  <!-- CTA -->
  <use href="#button-primary" x="1200" y="10" transform="scale(0.8)"/>
</g>

<!-- Footer -->
<g id="footer" transform="translate(0, 800)">
  <rect x="0" y="0" width="1440" height="100" fill="#F8FAFC"/>
  
  <text x="80" y="50" fill="#64748B" 
        font-family="system-ui" font-size="14">
    © 2026 Company Name. All rights reserved.
  </text>
  
  <text x="1200" y="50" fill="#64748B" 
        font-family="system-ui" font-size="14">
    Privacy · Terms · Contact
  </text>
</g>
```

---

## 4. Complete Page Templates

### 4.1 Landing Page

```svg
<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1440 2000" width="1440" height="2000">
  <title>Landing Page - v1.0</title>
  
  <defs>
    <!-- Include all component defs -->
    <filter id="shadow-md">
      <feDropShadow dx="0" dy="4" stdDeviation="6" flood-opacity="0.1"/>
    </filter>
  </defs>
  
  <!-- Background -->
  <rect width="100%" height="100%" fill="#FFFFFF"/>
  
  <!-- ===== HEADER ===== -->
  <g id="header">
    <rect width="1440" height="64" fill="#FFFFFF"/>
    <line x1="0" y1="64" x2="1440" y2="64" stroke="#E2E8F0"/>
    
    <text x="80" y="38" fill="#1E293B" font-family="system-ui" font-size="20" font-weight="700">
      ProductName
    </text>
    
    <g transform="translate(750, 24)">
      <text x="0" fill="#64748B" font-family="system-ui" font-size="14">Features</text>
      <text x="100" fill="#64748B" font-family="system-ui" font-size="14">Pricing</text>
      <text x="200" fill="#64748B" font-family="system-ui" font-size="14">About</text>
    </g>
    
    <rect x="1200" y="14" width="140" height="36" rx="6" fill="#3B82F6"/>
    <text x="1270" y="38" text-anchor="middle" fill="white" 
          font-family="system-ui" font-size="14" font-weight="500">
      Get Started
    </text>
  </g>
  
  <!-- ===== HERO ===== -->
  <g id="hero" transform="translate(0, 64)">
    <rect width="1440" height="600" fill="#F8FAFC"/>
    
    <!-- Content -->
    <text x="720" y="180" text-anchor="middle" fill="#1E293B" 
          font-family="system-ui" font-size="56" font-weight="700">
      Stop Wasting Time
    </text>
    <text x="720" y="240" text-anchor="middle" fill="#1E293B" 
          font-family="system-ui" font-size="56" font-weight="700">
      on Manual Tasks
    </text>
    
    <text x="720" y="300" text-anchor="middle" fill="#64748B" 
          font-family="system-ui" font-size="20">
      Automate your workflow and focus on what matters most.
    </text>
    
    <!-- Email capture -->
    <rect x="440" y="360" width="400" height="52" rx="8" fill="#FFFFFF" stroke="#E2E8F0"/>
    <text x="460" y="392" fill="#94A3B8" font-family="system-ui" font-size="16">
      Enter your email
    </text>
    
    <rect x="860" y="360" width="140" height="52" rx="8" fill="#3B82F6"/>
    <text x="930" y="392" text-anchor="middle" fill="white" 
          font-family="system-ui" font-size="14" font-weight="600">
      Join Waitlist
    </text>
    
    <!-- Social proof -->
    <text x="720" y="460" text-anchor="middle" fill="#64748B" 
          font-family="system-ui" font-size="14">
      Join 1,234 others on the waitlist
    </text>
    
    <!-- Trust logos -->
    <g transform="translate(520, 500)">
      <rect width="80" height="32" rx="4" fill="#E2E8F0"/>
      <rect x="100" width="80" height="32" rx="4" fill="#E2E8F0"/>
      <rect x="200" width="80" height="32" rx="4" fill="#E2E8F0"/>
      <rect x="300" width="80" height="32" rx="4" fill="#E2E8F0"/>
    </g>
  </g>
  
  <!-- ===== FEATURES ===== -->
  <g id="features" transform="translate(0, 700)">
    <text x="720" y="80" text-anchor="middle" fill="#1E293B" 
          font-family="system-ui" font-size="36" font-weight="700">
      Why Choose Us
    </text>
    
    <!-- Feature cards -->
    <g transform="translate(80, 140)">
      <!-- Card 1 -->
      <rect width="400" height="200" rx="12" fill="#FFFFFF" filter="url(#shadow-md)"/>
      <circle cx="40" cy="40" r="24" fill="#EFF6FF"/>
      <text x="40" y="46" text-anchor="middle" font-size="20">⚡</text>
      <text x="24" y="100" fill="#1E293B" font-family="system-ui" font-size="18" font-weight="600">
        Lightning Fast
      </text>
      <text x="24" y="130" fill="#64748B" font-family="system-ui" font-size="14">
        Get results in seconds, not hours.
      </text>
      <text x="24" y="150" fill="#64748B" font-family="system-ui" font-size="14">
        Our AI processes instantly.
      </text>
    </g>
    
    <g transform="translate(520, 140)">
      <!-- Card 2 -->
      <rect width="400" height="200" rx="12" fill="#FFFFFF" filter="url(#shadow-md)"/>
      <circle cx="40" cy="40" r="24" fill="#F0FDF4"/>
      <text x="40" y="46" text-anchor="middle" font-size="20">🔒</text>
      <text x="24" y="100" fill="#1E293B" font-family="system-ui" font-size="18" font-weight="600">
        Secure by Default
      </text>
      <text x="24" y="130" fill="#64748B" font-family="system-ui" font-size="14">
        Enterprise-grade encryption.
      </text>
      <text x="24" y="150" fill="#64748B" font-family="system-ui" font-size="14">
        Your data stays private.
      </text>
    </g>
    
    <g transform="translate(960, 140)">
      <!-- Card 3 -->
      <rect width="400" height="200" rx="12" fill="#FFFFFF" filter="url(#shadow-md)"/>
      <circle cx="40" cy="40" r="24" fill="#FEF3C7"/>
      <text x="40" y="46" text-anchor="middle" font-size="20">🎯</text>
      <text x="24" y="100" fill="#1E293B" font-family="system-ui" font-size="18" font-weight="600">
        Simple to Use
      </text>
      <text x="24" y="130" fill="#64748B" font-family="system-ui" font-size="14">
        No learning curve required.
      </text>
      <text x="24" y="150" fill="#64748B" font-family="system-ui" font-size="14">
        Start in under 2 minutes.
      </text>
    </g>
  </g>
  
  <!-- ===== CTA ===== -->
  <g id="final-cta" transform="translate(0, 1100)">
    <rect width="1440" height="300" fill="#1E293B"/>
    
    <text x="720" y="100" text-anchor="middle" fill="#FFFFFF" 
          font-family="system-ui" font-size="36" font-weight="700">
      Ready to get started?
    </text>
    <text x="720" y="150" text-anchor="middle" fill="#94A3B8" 
          font-family="system-ui" font-size="18">
      Join thousands of users automating their workflow.
    </text>
    
    <rect x="620" y="190" width="200" height="52" rx="8" fill="#3B82F6"/>
    <text x="720" y="222" text-anchor="middle" fill="white" 
          font-family="system-ui" font-size="16" font-weight="600">
      Start Free Trial
    </text>
  </g>
  
  <!-- ===== FOOTER ===== -->
  <g id="footer" transform="translate(0, 1420)">
    <rect width="1440" height="80" fill="#F8FAFC"/>
    <text x="80" y="45" fill="#64748B" font-family="system-ui" font-size="14">
      © 2026 ProductName. All rights reserved.
    </text>
    <text x="1200" y="45" fill="#64748B" font-family="system-ui" font-size="14">
      Privacy · Terms · Contact
    </text>
  </g>
  
  <!-- ===== ANNOTATIONS (for review) ===== -->
  <!--
  FEEDBACK: [Designer] [2026-01-29] - Hero headline might be too generic
  TODO: Test alternative "Save 10 hours every week"
  
  FEEDBACK: [Stakeholder] [2026-01-29] - Can we add a product screenshot?
  TODO: Add hero image placeholder on right side
  -->
  
</svg>
```

---

## 5. Annotation System

### 5.1 Comment Convention

```svg
<!-- 
  VERSION: 1.0
  DATE: 2026-01-29
  AUTHOR: Designer Name
  STATUS: Draft | Review | Approved
-->

<!-- Section comments -->
<!-- ===== HEADER ===== -->
<!-- ===== HERO ===== -->

<!-- Feedback comments -->
<!-- FEEDBACK: [reviewer] [date] - Comment text -->
<!-- TODO: [assignee] - Action item -->
<!-- APPROVED: [approver] [date] -->
<!-- CHANGE: [date] - Description of change -->
```

### 5.2 Visual Annotations

```svg
<!-- Annotation overlay (toggle visibility) -->
<g id="annotations" style="display: none;">
  
  <!-- Callout box -->
  <g transform="translate(100, 100)">
    <rect width="200" height="60" rx="4" fill="#FEF3C7" stroke="#F59E0B"/>
    <text x="10" y="25" fill="#92400E" font-family="system-ui" font-size="12" font-weight="600">
      Note:
    </text>
    <text x="10" y="45" fill="#92400E" font-family="system-ui" font-size="11">
      Consider adding animation here
    </text>
    <!-- Connector line -->
    <line x1="200" y1="30" x2="300" y2="80" stroke="#F59E0B" stroke-dasharray="4"/>
  </g>
  
  <!-- Measurement guide -->
  <g transform="translate(500, 200)">
    <line x1="0" y1="0" x2="0" y2="100" stroke="#3B82F6" stroke-dasharray="2"/>
    <line x1="200" y1="0" x2="200" y2="100" stroke="#3B82F6" stroke-dasharray="2"/>
    <line x1="0" y1="50" x2="200" y2="50" stroke="#3B82F6"/>
    <text x="100" y="45" text-anchor="middle" fill="#3B82F6" font-size="10">200px</text>
  </g>
  
</g>

<!-- Toggle with JavaScript or CSS -->
<style>
  #annotations:target { display: block; }
</style>
```

---

## 6. Export & Delivery

### 6.1 Optimization

```bash
# Optimize SVG with SVGO
npx svgo input.svg -o output.svg

# Custom config for mockups (preserve text)
npx svgo input.svg -o output.svg --config='{
  "plugins": [
    "removeDoctype",
    "removeComments",
    "cleanupIds",
    {
      "name": "convertPathData",
      "params": { "floatPrecision": 2 }
    }
  ]
}'
```

### 6.2 PNG Export

```bash
# Using Inkscape CLI
inkscape input.svg --export-filename=output.png --export-width=2880

# Using Chrome headless
chrome --headless --screenshot=output.png --window-size=1440,900 file:///path/to/mockup.svg
```

### 6.3 Embedding in Documentation

```markdown
# Design Documentation

## Landing Page v1

![Landing Page Mockup](./mockups/landing-v1.svg)

### Feedback

- [ ] Hero headline needs testing
- [x] Feature cards approved
- [ ] CTA color to be finalized

### Versions

| Version | Date | Status | Notes |
|---------|------|--------|-------|
| v1 | 2026-01-29 | Review | Initial design |
| v2 | 2026-01-30 | Draft | Added hero image |
```

---

## References

- `CORE.md` - Design principles
- `WIREFRAMES.md` - Text-based wireframes (precursor to SVG)
- `STYLES/INDEX.md` - Style selection
- `PATTERNS/layout.md` - Layout patterns

---

*Version: 0.1.0*
