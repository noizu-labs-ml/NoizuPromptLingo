# Lit v3 Styles

Complete reference for component styling — css tag, Shadow DOM selectors, CSS custom properties, shared styles, theming, and Constructable Stylesheets.

## Static Styles (Recommended)

Styles declared via the static `styles` field are parsed once per class and shared across all instances via Constructable Stylesheets (`adoptedStyleSheets`). No FOUC, minimal memory.

```typescript
static styles = css`
  :host { display: block; color: var(--text-color, black); }
  .container { padding: 16px; }
`;
```

### Array Form

Compose from multiple style sources:

```typescript
static styles = [resetStyles, buttonStyles, css`.custom { color: red; }`];
```

### Style Inheritance

Subclasses must explicitly include parent styles:

```typescript
class ChildElement extends ParentElement {
  static styles = [
    ...ParentElement.styles as CSSResult[],
    css`.child-only { margin: 8px; }`
  ];
}
```

Note: spread `...super.styles` (or cast to array) since `styles` can be a single `CSSResult` or an array.

---

## Shadow DOM Selectors

### :host

Style the host element itself:

```css
/* Default host styles */
:host {
  display: block;
  border: 1px solid #ccc;
}

/* Conditional on host attributes */
:host([active]) {
  border-color: blue;
}

/* Conditional on host classes */
:host(.primary) {
  background: var(--primary);
}

/* Context-dependent (host inside specific parent) */
:host-context(.dark-theme) {
  background: #333;
  color: white;
}
```

### ::slotted()

Style slotted (light DOM) children — **direct children only**:

```css
/* All slotted children */
::slotted(*) {
  margin: 4px;
}

/* Specific slotted elements */
::slotted(p) {
  color: green;
}

/* Named slot children */
::slotted([slot="header"]) {
  font-weight: bold;
}
```

Limitation: `::slotted()` only selects direct children of the slot, not deeper descendants.

### :defined

Style only when the custom element is registered:

```css
my-element:defined {
  opacity: 1;
}
my-element:not(:defined) {
  opacity: 0.5;
}
```

---

## CSS Custom Properties (Theming)

CSS custom properties cross shadow boundaries — the primary theming mechanism:

```typescript
// Component definition
@customElement('themed-card')
class ThemedCard extends LitElement {
  static styles = css`
    :host {
      display: block;
      background: var(--card-bg, white);
      color: var(--card-color, black);
      border-radius: var(--card-radius, 4px);
      padding: var(--card-padding, 16px);
      font-family: var(--card-font, inherit);
    }
    .title {
      font-size: var(--card-title-size, 1.25rem);
      color: var(--card-title-color, var(--card-color, black));
    }
  `;
}
```

Consumer styling:

```css
/* Global theme */
:root {
  --card-bg: #f5f5f5;
  --card-color: #333;
  --card-radius: 8px;
}

/* Per-instance override */
themed-card.dark {
  --card-bg: #1a1a1a;
  --card-color: #eee;
}
```

### Naming Convention

Prefix custom properties with the component name:

```css
/* Good */
--my-button-bg: blue;
--my-button-text-color: white;
--my-button-border-radius: 4px;

/* Bad — too generic, will collide */
--bg: blue;
--color: white;
```

---

## Sharing Styles

### Shared Style Modules

```typescript
// button-styles.ts
import {css} from 'lit';

export const buttonStyles = css`
  .btn {
    padding: 8px 16px;
    border-radius: 4px;
    border: none;
    cursor: pointer;
    font: inherit;
  }
  .btn-primary { background: var(--primary, blue); color: white; }
  .btn-secondary { background: var(--secondary, gray); color: white; }
`;
```

```typescript
// my-component.ts
import {buttonStyles} from './button-styles.js';

@customElement('my-component')
class MyComponent extends LitElement {
  static styles = [buttonStyles, css`.local { margin: 8px; }`];
}
```

### Reset Styles

```typescript
// reset.ts
export const resetStyles = css`
  *, *::before, *::after { box-sizing: border-box; }
  :host { font-family: system-ui, sans-serif; }
`;
```

---

## Per-Instance Dynamic Styles

Use `classMap` and `styleMap` directives — **never** `<style>` elements in templates:

```typescript
import {classMap} from 'lit/directives/class-map.js';
import {styleMap} from 'lit/directives/style-map.js';

render() {
  const classes = {
    card: true,
    'card--active': this.active,
    'card--disabled': this.disabled,
  };
  const styles = {
    width: `${this.width}px`,
    '--accent': this.accentColor,
  };

  return html`<div class=${classMap(classes)} style=${styleMap(styles)}>
    ${this.content}
  </div>`;
}
```

### Why Not `<style>` in Templates?

`<style>` elements in templates are parsed on every render and create per-instance stylesheets instead of shared Constructable Stylesheets. Extremely inefficient — avoid entirely.

---

## Constructable Stylesheets (Internals)

Under the hood, Lit's `css` tag creates `CSSStyleSheet` objects that are:
- Parsed once per component class
- Shared across all instances via `adoptedStyleSheets`
- Applied without FOUC (no flash of unstyled content)
- Memory-efficient (one stylesheet object, many shadow roots)

This is why `static styles` is preferred over any other styling approach.

---

## Design System Token Pattern

Structure tokens as CSS custom properties with semantic naming:

```typescript
// tokens.ts
export const tokens = css`
  :host {
    /* Primitive tokens */
    --color-blue-500: #3b82f6;
    --color-gray-100: #f3f4f6;
    --color-gray-900: #111827;
    --space-sm: 8px;
    --space-md: 16px;
    --space-lg: 24px;
    --radius-sm: 4px;
    --radius-md: 8px;
    --font-sans: system-ui, -apple-system, sans-serif;

    /* Semantic tokens (reference primitives) */
    --color-primary: var(--color-blue-500);
    --color-surface: var(--color-gray-100);
    --color-text: var(--color-gray-900);
    --space-component: var(--space-md);
    --radius-component: var(--radius-sm);
  }
`;
```

Components reference semantic tokens:

```typescript
static styles = [tokens, css`
  :host {
    background: var(--color-surface);
    color: var(--color-text);
    padding: var(--space-component);
    border-radius: var(--radius-component);
  }
`];
```

### Theme Switching

Override semantic tokens at the document level:

```css
/* Light theme (default via component tokens) */

/* Dark theme */
.dark-theme {
  --color-primary: #60a5fa;
  --color-surface: #1f2937;
  --color-text: #f9fafb;
}
```

---

## Advanced: unsafeCSS

For trusted dynamic values only:

```typescript
import {css, unsafeCSS} from 'lit';

// From a trusted config
const breakpoint = '768px';
static styles = css`
  @media (min-width: ${unsafeCSS(breakpoint)}) {
    :host { display: grid; }
  }
`;
```

Never use with user input — CSS injection vulnerability.

---

## Light DOM Rendering (Advanced)

Override `createRenderRoot()` to render into light DOM instead of shadow DOM:

```typescript
createRenderRoot() {
  return this; // renders into light DOM — no style encapsulation!
}
```

This loses all shadow DOM benefits (style encapsulation, DOM encapsulation). Only use when:
- Integrating with legacy CSS frameworks that expect light DOM
- Building layout components where children need to participate in parent CSS context
- Server-rendering constraints require it

When using light DOM, styles affect the entire page — use very specific selectors or CSS Modules.
