# Lit v3 Core API Reference

Complete API surface for the `lit` package — LitElement, html, css, decorators, and sentinels.

## LitElement

The foundation class for all Lit components. Extends `HTMLElement` via `ReactiveElement`. Weighs ~5 KB minified+compressed.

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property} from 'lit/decorators.js';

@customElement('my-element')
export class MyElement extends LitElement {
  static styles = css`
    :host { display: block; border: 1px solid black; }
    p { color: green; }
  `;

  @property() name = 'World';

  render() {
    return html`<p>Hello, ${this.name}!</p>`;
  }
}
```

### Class Hierarchy

```
HTMLElement
  → ReactiveElement (reactive properties, update lifecycle)
    → LitElement (lit-html templating, styles)
      → Your Component
```

### Key Static Members

| Member | Type | Purpose |
|--------|------|---------|
| `styles` | `CSSResult \| CSSResult[]` | Component styles via `css` tag |
| `properties` | `PropertyDeclarations` | Reactive property definitions (alternative to decorators) |
| `shadowRootOptions` | `ShadowRootInit` | Options passed to `attachShadow()` |

### Key Instance Members

| Member | Type | Purpose |
|--------|------|---------|
| `renderRoot` | `HTMLElement \| DocumentFragment` | Where templates render (shadow root by default) |
| `updateComplete` | `Promise<boolean>` | Resolves when current update cycle completes |
| `isConnected` | `boolean` | Whether element is in the DOM |

---

## html Template Tag

Tagged template literal returning a `TemplateResult`. Lit parses the static strings once, then efficiently updates only dynamic parts on re-render.

```typescript
render() {
  return html`
    <h1>${this.title}</h1>
    <p>${this.body}</p>
  `;
}
```

### How It Works

1. First render: Lit parses the static string parts into an HTML `<template>`, clones it, and populates dynamic parts
2. Subsequent renders: Lit only updates the dynamic expression values — no DOM diffing, no template re-parsing
3. Static strings are identical across calls (template literal identity), so Lit caches the parsed template

### svg Tag

For SVG content that needs to be rendered inside an `<svg>` element:

```typescript
import {svg} from 'lit';

render() {
  return html`
    <svg viewBox="0 0 100 100">
      ${svg`<circle cx="50" cy="50" r="${this.radius}"/>`}
    </svg>
  `;
}
```

---

## css Tag

Tagged template literal for defining component styles. Returns a `CSSResult` usable in the static `styles` field.

```typescript
static styles = css`
  :host { display: block; }
  .highlight { color: red; }
`;
```

### Security Model

Only `css`-tagged strings or numbers are allowed as expressions inside `css`:

```typescript
// ALLOWED — css tag
const shared = css`.btn { padding: 8px; }`;
static styles = [shared, css`.local { color: red; }`];

// ALLOWED — number
const size = 16;
static styles = css`.text { font-size: ${size}px; }`;

// BLOCKED — plain string (XSS vector)
const userInput = 'red; } * { display: none';
static styles = css`.text { color: ${userInput}; }`; // TypeError!
```

### unsafeCSS

Escape hatch for trusted dynamic CSS strings:

```typescript
import {css, unsafeCSS} from 'lit';

const mainColor = 'red';
static styles = css`div { color: ${unsafeCSS(mainColor)} }`;
```

Only use with developer-controlled values. Never use with user input.

---

## Decorators

### Import Paths

```typescript
// Combined import
import {customElement, property, state, query, queryAll,
        queryAsync, eventOptions} from 'lit/decorators.js';

// Individual imports (tree-shakeable)
import {customElement} from 'lit/decorators/custom-element.js';
import {property} from 'lit/decorators/property.js';
import {state} from 'lit/decorators/state.js';
import {query} from 'lit/decorators/query.js';
import {queryAll} from 'lit/decorators/queryAll.js';
import {queryAsync} from 'lit/decorators/queryAsync.js';
import {queryAssignedElements} from 'lit/decorators/queryAssignedElements.js';
import {queryAssignedNodes} from 'lit/decorators/queryAssignedNodes.js';
import {eventOptions} from 'lit/decorators/event-options.js';
```

### Complete Decorator Reference

| Decorator | Purpose | Example |
|-----------|---------|---------|
| `@customElement('tag')` | Register custom element | `@customElement('my-el')` |
| `@property(opts?)` | Public reactive property | `@property({type: Number}) count = 0` |
| `@state()` | Internal reactive state | `@state() private _active = false` |
| `@query(sel, cache?)` | querySelector on renderRoot | `@query('#input') _input!: HTMLInputElement` |
| `@queryAll(sel)` | querySelectorAll on renderRoot | `@queryAll('div') _divs!: NodeListOf<HTMLDivElement>` |
| `@queryAsync(sel)` | Async query, resolves after render | `@queryAsync('#dynamic') _node!: Promise<HTMLElement>` |
| `@queryAssignedElements(opts?)` | Elements assigned to a slot | `@queryAssignedElements({slot: 'item'}) _items!: HTMLElement[]` |
| `@queryAssignedNodes(opts?)` | Nodes (incl. text) assigned to slot | `@queryAssignedNodes({flatten: true}) _nodes!: Node[]` |
| `@eventOptions(opts)` | addEventListener options | `@eventOptions({passive: true})` |

### Standard vs Experimental Decorators

**Experimental decorators** (recommended for production — smaller output):

```jsonc
// tsconfig.json
{
  "compilerOptions": {
    "experimentalDecorators": true,
    "useDefineForClassFields": false
  }
}
```

```typescript
@property() myProp = 'value';
@state() private _count = 0;
```

**Standard TC39 decorators** (Stage 3 — requires `accessor` keyword):

```jsonc
// tsconfig.json — remove experimentalDecorators, set useDefineForClassFields: true
```

```typescript
@property() accessor myProp = 'value';
@state() accessor _count = 0;
```

Standard decorators require TypeScript 5.2+ with metadata support. Babel: `@babel/plugin-proposal-decorators` version `"2023-05"`.

---

## Sentinel Values

### nothing

Renders no nodes in child position; removes the attribute in attribute position:

```typescript
import {nothing} from 'lit';

html`<button aria-label="${this.ariaLabel || nothing}">X</button>`;
html`<div>${this.showContent ? html`<p>Content</p>` : nothing}</div>`;
```

### noChange

Leaves the current rendered value unchanged. Used inside custom directives:

```typescript
import {noChange} from 'lit';

// In a directive: return noChange to skip updating this expression
```

---

## Without Decorators

For projects that cannot use decorators (e.g., plain JavaScript):

```javascript
import {LitElement, html, css} from 'lit';

export class MyElement extends LitElement {
  static properties = {
    name: {type: String},
    count: {type: Number, reflect: true},
    data: {attribute: false},
  };

  static styles = css`:host { display: block; }`;

  constructor() {
    super();
    this.name = 'World';
    this.count = 0;
    this.data = {};
  }

  render() {
    return html`<p>Hello, ${this.name}!</p>`;
  }
}
customElements.define('my-element', MyElement);
```

---

## TypeScript Configuration

Essential `tsconfig.json` settings for Lit v3:

```jsonc
{
  "compilerOptions": {
    "target": "es2021",
    "module": "es2015",
    "moduleResolution": "node",
    "lib": ["es2021", "DOM", "DOM.Iterable"],
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "experimentalDecorators": true,
    "useDefineForClassFields": false
  }
}
```

### HTMLElementTagNameMap

Always declare for type-safe `querySelector` and `createElement`:

```typescript
declare global {
  interface HTMLElementTagNameMap {
    'my-element': MyElement;
  }
}
```
