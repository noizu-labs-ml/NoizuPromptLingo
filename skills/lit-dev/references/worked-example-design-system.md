# Worked Example: Building a Themed Design System with Lit v3

End-to-end walkthrough — from token architecture through themed components with context-based theme switching.

## Goal

Build a small design system with:
- Design tokens (colors, spacing, typography, radii)
- Theme switching (light/dark) via `@lit/context`
- Three components: `ds-button`, `ds-card`, `ds-theme-provider`
- Shared styles
- Type-safe events

---

## Step 1: Token Architecture

```typescript
// src/tokens.ts
import {css} from 'lit';

export const primitiveTokens = css`
  :host {
    /* Colors */
    --ds-blue-50: #eff6ff;
    --ds-blue-500: #3b82f6;
    --ds-blue-600: #2563eb;
    --ds-blue-700: #1d4ed8;
    --ds-gray-50: #f9fafb;
    --ds-gray-100: #f3f4f6;
    --ds-gray-200: #e5e7eb;
    --ds-gray-700: #374151;
    --ds-gray-800: #1f2937;
    --ds-gray-900: #111827;
    --ds-white: #ffffff;
    --ds-red-500: #ef4444;

    /* Spacing */
    --ds-space-xs: 4px;
    --ds-space-sm: 8px;
    --ds-space-md: 16px;
    --ds-space-lg: 24px;
    --ds-space-xl: 32px;

    /* Typography */
    --ds-font-sans: system-ui, -apple-system, sans-serif;
    --ds-font-mono: ui-monospace, monospace;
    --ds-text-sm: 0.875rem;
    --ds-text-base: 1rem;
    --ds-text-lg: 1.125rem;
    --ds-text-xl: 1.25rem;
    --ds-font-medium: 500;
    --ds-font-semibold: 600;

    /* Radii */
    --ds-radius-sm: 4px;
    --ds-radius-md: 8px;
    --ds-radius-lg: 12px;

    /* Shadows */
    --ds-shadow-sm: 0 1px 2px rgba(0,0,0,0.05);
    --ds-shadow-md: 0 4px 6px rgba(0,0,0,0.1);
  }
`;

export const lightThemeTokens = css`
  :host {
    --ds-color-bg: var(--ds-white);
    --ds-color-surface: var(--ds-gray-50);
    --ds-color-border: var(--ds-gray-200);
    --ds-color-text: var(--ds-gray-900);
    --ds-color-text-muted: var(--ds-gray-700);
    --ds-color-primary: var(--ds-blue-600);
    --ds-color-primary-hover: var(--ds-blue-700);
    --ds-color-primary-text: var(--ds-white);
  }
`;

export const darkThemeTokens = css`
  :host {
    --ds-color-bg: var(--ds-gray-900);
    --ds-color-surface: var(--ds-gray-800);
    --ds-color-border: var(--ds-gray-700);
    --ds-color-text: var(--ds-gray-50);
    --ds-color-text-muted: var(--ds-gray-200);
    --ds-color-primary: var(--ds-blue-500);
    --ds-color-primary-hover: var(--ds-blue-600);
    --ds-color-primary-text: var(--ds-white);
  }
`;
```

---

## Step 2: Shared Styles

```typescript
// src/shared-styles.ts
import {css} from 'lit';

export const resetStyles = css`
  *, *::before, *::after {
    box-sizing: border-box;
  }
  :host {
    font-family: var(--ds-font-sans);
    color: var(--ds-color-text);
  }
`;

export const buttonStyles = css`
  .btn {
    display: inline-flex;
    align-items: center;
    gap: var(--ds-space-sm);
    padding: var(--ds-space-sm) var(--ds-space-md);
    border: 1px solid transparent;
    border-radius: var(--ds-radius-sm);
    font: inherit;
    font-size: var(--ds-text-sm);
    font-weight: var(--ds-font-medium);
    cursor: pointer;
    transition: background-color 0.15s, border-color 0.15s;
  }
  .btn:focus-visible {
    outline: 2px solid var(--ds-color-primary);
    outline-offset: 2px;
  }
  .btn[disabled] {
    opacity: 0.5;
    cursor: not-allowed;
  }
  .btn--primary {
    background: var(--ds-color-primary);
    color: var(--ds-color-primary-text);
  }
  .btn--primary:hover:not([disabled]) {
    background: var(--ds-color-primary-hover);
  }
  .btn--secondary {
    background: transparent;
    color: var(--ds-color-text);
    border-color: var(--ds-color-border);
  }
  .btn--secondary:hover:not([disabled]) {
    background: var(--ds-color-surface);
  }
`;
```

---

## Step 3: Theme Context

```typescript
// src/theme-context.ts
import {createContext} from '@lit/context';

export type Theme = 'light' | 'dark';
export const themeContext = createContext<Theme>(Symbol.for('ds-theme'));
```

---

## Step 4: Theme Provider Component

```typescript
// src/ds-theme-provider.ts
import {LitElement, html, css} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import {provide} from '@lit/context';
import {themeContext, type Theme} from './theme-context.js';
import {primitiveTokens, lightThemeTokens, darkThemeTokens} from './tokens.js';

@customElement('ds-theme-provider')
export class DsThemeProvider extends LitElement {
  static styles = [
    primitiveTokens,
    lightThemeTokens,
    css`
      :host { display: contents; }
      :host([theme="dark"]) {
        ${darkThemeTokens.cssText ? '' : ''}
      }
    `,
    darkThemeTokens,
  ];

  @provide({context: themeContext})
  @property({reflect: true})
  theme: Theme = 'light';

  render() {
    return html`<slot></slot>`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'ds-theme-provider': DsThemeProvider;
  }
}
```

Alternative approach using `styleMap` for theme switching:

```typescript
// Simpler: apply dark tokens as CSS class on host
static styles = [primitiveTokens, lightThemeTokens, css`
  :host { display: contents; }
`];

willUpdate(changed: PropertyValues) {
  if (changed.has('theme')) {
    // Toggle dark theme tokens via adoptedStyleSheets
    const sheets = [primitiveTokens.styleSheet!];
    sheets.push(this.theme === 'dark'
      ? darkThemeTokens.styleSheet!
      : lightThemeTokens.styleSheet!
    );
    this.shadowRoot!.adoptedStyleSheets = sheets;
  }
}
```

---

## Step 5: Button Component

```typescript
// src/ds-button.ts
import {LitElement, html, css} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import {classMap} from 'lit/directives/class-map.js';
import {resetStyles, buttonStyles} from './shared-styles.js';

export type ButtonVariant = 'primary' | 'secondary';

@customElement('ds-button')
export class DsButton extends LitElement {
  static styles = [resetStyles, buttonStyles, css`
    :host { display: inline-block; }
  `];

  @property() variant: ButtonVariant = 'primary';
  @property({type: Boolean, reflect: true}) disabled = false;
  @property() type: 'button' | 'submit' | 'reset' = 'button';

  render() {
    const classes = {
      btn: true,
      'btn--primary': this.variant === 'primary',
      'btn--secondary': this.variant === 'secondary',
    };

    return html`
      <button
        class=${classMap(classes)}
        ?disabled=${this.disabled}
        type=${this.type}
        @click=${this._handleClick}
      >
        <slot></slot>
      </button>
    `;
  }

  private _handleClick(e: MouseEvent) {
    if (this.disabled) {
      e.stopPropagation();
      return;
    }
    this.dispatchEvent(new CustomEvent('ds-click', {
      bubbles: true,
      composed: true,
    }));
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'ds-button': DsButton;
  }
}
```

---

## Step 6: Card Component

```typescript
// src/ds-card.ts
import {LitElement, html, css} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import {resetStyles} from './shared-styles.js';

@customElement('ds-card')
export class DsCard extends LitElement {
  static styles = [resetStyles, css`
    :host {
      display: block;
    }
    .card {
      background: var(--ds-color-bg);
      border: 1px solid var(--ds-color-border);
      border-radius: var(--ds-radius-md);
      box-shadow: var(--ds-shadow-sm);
      overflow: hidden;
    }
    .card__header {
      padding: var(--ds-space-md) var(--ds-space-lg);
      border-bottom: 1px solid var(--ds-color-border);
      font-size: var(--ds-text-lg);
      font-weight: var(--ds-font-semibold);
    }
    .card__body {
      padding: var(--ds-space-lg);
    }
    .card__footer {
      padding: var(--ds-space-md) var(--ds-space-lg);
      border-top: 1px solid var(--ds-color-border);
      display: flex;
      gap: var(--ds-space-sm);
      justify-content: flex-end;
    }
    /* Hide sections when no content slotted */
    .card__header:not(:has(::slotted(*))) { display: none; }
    .card__footer:not(:has(::slotted(*))) { display: none; }
  `];

  render() {
    return html`
      <div class="card">
        <div class="card__header">
          <slot name="header"></slot>
        </div>
        <div class="card__body">
          <slot></slot>
        </div>
        <div class="card__footer">
          <slot name="footer"></slot>
        </div>
      </div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'ds-card': DsCard;
  }
}
```

---

## Step 7: Usage

```html
<!DOCTYPE html>
<html>
<head>
  <script type="module">
    import './src/ds-theme-provider.js';
    import './src/ds-button.js';
    import './src/ds-card.js';

    document.getElementById('toggle').addEventListener('click', () => {
      const provider = document.querySelector('ds-theme-provider');
      provider.theme = provider.theme === 'light' ? 'dark' : 'light';
    });
  </script>
</head>
<body>
  <ds-theme-provider theme="light">
    <ds-card>
      <span slot="header">Welcome</span>
      <p>This card respects the theme context.</p>
      <div slot="footer">
        <ds-button variant="secondary" id="toggle">Toggle Theme</ds-button>
        <ds-button>Primary Action</ds-button>
      </div>
    </ds-card>
  </ds-theme-provider>
</body>
</html>
```

---

## Step 8: Testing

```typescript
// test/ds-button.test.ts
import {fixture, html, expect} from '@open-wc/testing';
import '../src/ds-button.js';
import type {DsButton} from '../src/ds-button.js';

describe('ds-button', () => {
  it('renders with default variant', async () => {
    const el = await fixture<DsButton>(html`<ds-button>Click</ds-button>`);
    const btn = el.shadowRoot!.querySelector('button')!;
    expect(btn.classList.contains('btn--primary')).to.be.true;
    expect(btn.textContent).to.include('Click');
  });

  it('reflects disabled state', async () => {
    const el = await fixture<DsButton>(html`<ds-button disabled>Click</ds-button>`);
    const btn = el.shadowRoot!.querySelector('button')!;
    expect(btn.disabled).to.be.true;
  });

  it('fires ds-click event', async () => {
    const el = await fixture<DsButton>(html`<ds-button>Click</ds-button>`);
    let fired = false;
    el.addEventListener('ds-click', () => { fired = true; });
    el.shadowRoot!.querySelector('button')!.click();
    expect(fired).to.be.true;
  });

  it('does not fire when disabled', async () => {
    const el = await fixture<DsButton>(html`<ds-button disabled>Click</ds-button>`);
    let fired = false;
    el.addEventListener('ds-click', () => { fired = true; });
    el.shadowRoot!.querySelector('button')!.click();
    expect(fired).to.be.false;
  });

  it('is accessible', async () => {
    const el = await fixture(html`<ds-button>Click me</ds-button>`);
    await expect(el).to.be.accessible();
  });
});
```

---

## Key Decisions Explained

| Decision | Why |
|----------|-----|
| Primitive + semantic tokens | Themes override semantics, primitives stay constant |
| Context for theme | Avoids prop drilling through deep component trees |
| `display: contents` on provider | Provider doesn't affect layout |
| Shared style modules | Parse once, share across components |
| `reflect: true` on theme | Enables CSS attribute selectors for external styling |
| No bundling | Consumers bundle; avoids duplicate Lit |
| Typed events | Self-documenting API, TypeScript support |
