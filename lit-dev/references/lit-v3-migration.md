# Lit v3 Migration Guide

Lit 2 to Lit 3 breaking changes, decorator migration, post-3.0 features, anti-patterns, and ecosystem libraries.

## Release Timeline

| Version | Date | Key Changes |
|---------|------|-------------|
| 3.0.0 | May 2023 | ES2021 output, standard decorators, UpdatingElement removed |
| 3.1.0 | Late 2023 | Bug fixes, `@query` caching fix |
| 3.2.0 | 2024 | MathML support via `mathml` template tag |
| 3.3.0 | 2025 | `useDefault` property option |
| 3.3.3 | May 2025 | Latest stable |

---

## Breaking Changes (Minimal)

Lit 3 introduces **minimal breaking changes**. No required code changes for the vast majority of users. Lit 2 and 3 are **fully interoperable** — templates, base classes, and directives from one version work with the other.

### 1. ES2021 Publication Format

Lit 3 publishes as ES2021 (was ES2019). Webpack 4 users need Babel plugins:

```bash
npm i -D @babel/plugin-transform-optional-chaining \
         @babel/plugin-transform-nullish-coalescing-operator \
         @babel/plugin-transform-logical-assignment-operators
```

### 2. Removed `UpdatingElement` Alias

```typescript
// Old — removed
import {UpdatingElement} from 'lit';

// New
import {ReactiveElement} from 'lit';
```

### 3. Decorator Imports Changed

```typescript
// Old — no longer works
import {customElement, property, state} from 'lit-element';

// New
import {customElement, property, state} from 'lit/decorators.js';
```

### 4. queryAssignedNodes() Signature

```typescript
// Old
@queryAssignedNodes('list', true, '.item')

// New
@queryAssignedElements({slot: 'list', flatten: true, selector: '.item'})
```

### 5. SSR Hydration Module Moved

```typescript
// Old (Lit 2)
import 'lit/experimental-hydrate-support.js';
import {hydrate} from 'lit/experimental-hydrate.js';

// New (Lit 3)
import '@lit-labs/ssr-client/lit-element-hydrate-support.js';
import {hydrate} from '@lit-labs/ssr-client';
```

### 6. Type Change

`renderRoot` and `createRenderRoot()` type changed from `Element | ShadowRoot` to `HTMLElement | DocumentFragment`. Type-only change — no runtime impact.

---

## Upgrade Strategy

Most apps: extend version ranges to `"^2.7.0 || ^3.0.0"`. Projects without deprecation warnings in Lit 2 should encounter zero breaking changes.

### Incremental Decorator Migration

Two-step approach:

1. **While on `experimentalDecorators: true`**: Add `accessor` keyword to properties — both work simultaneously
2. **When ready**: Remove `experimentalDecorators`, set `useDefineForClassFields: true`

```typescript
// Step 1: works with experimentalDecorators
@property() accessor name = 'World';

// Step 2: flip tsconfig, remove experimentalDecorators
// Same code works with standard decorators
```

---

## TC39 Standard Decorators (The Big Feature)

Lit 3's most significant new capability. Stage 3 standard decorators use the `accessor` keyword:

```typescript
// Experimental decorators (still supported, recommended for now)
@property() myProp = 'value';

// Standard TC39 decorators (future-proof)
@property() accessor myProp = 'value';
```

Requirements:
- TypeScript 4.9+ (for `accessor` keyword)
- TypeScript 5.2+ (for decorator metadata)
- Babel: `@babel/plugin-proposal-decorators` version `"2023-05"`

---

## Post-3.0 Features

### Lit 3.1 — Bug Fixes

- `@query` caching bug fixed
- `ref` directive disconnect behavior fixed
- Various TypeScript type improvements

### Lit 3.2 — MathML Support

```typescript
import {mathml} from 'lit';

render() {
  return html`
    <math>
      ${mathml`<mrow><mi>x</mi><mo>=</mo><mn>${this.value}</mn></mrow>`}
    </math>
  `;
}
```

### Lit 3.3 — useDefault Property Option

Controls attribute removal behavior:

```typescript
@property({type: String, reflect: true, useDefault: true})
mode = 'auto';
// When attribute is removed, property resets to 'auto' (the default)
// Without useDefault, removing attribute sets property to undefined
```

Also prevents reflecting the initial default value as an attribute (avoids unnecessary DOM writes on first render).

---

## The Lit Compiler (@lit-labs/compiler)

Compiles Lit templates at build time for better performance:

- **46% faster** first render
- **21% faster** updates
- ~5% bundle size increase

```typescript
// rollup.config.js
import {compileLitTemplates} from '@lit-labs/compiler';

export default {
  plugins: [compileLitTemplates()],
};
```

Labs status — expected to graduate in a future release.

---

## Anti-Patterns

### 1. Derived State in updated() Instead of willUpdate()

```typescript
// WRONG — triggers unnecessary additional render cycle
updated(changedProperties: PropertyValues) {
  if (changedProperties.has('firstName') || changedProperties.has('lastName')) {
    this.fullName = `${this.firstName} ${this.lastName}`;
  }
}

// RIGHT — computed during current cycle, no extra render
willUpdate(changedProperties: PropertyValues) {
  if (changedProperties.has('firstName') || changedProperties.has('lastName')) {
    this.fullName = `${this.firstName} ${this.lastName}`;
  }
}
```

### 2. Overusing composed: true

```typescript
// WRONG — leaks internal events across shadow boundaries
this.dispatchEvent(new CustomEvent('_internal-click', {
  bubbles: true, composed: true // why?
}));

// RIGHT — internal events stay internal
this.dispatchEvent(new CustomEvent('_internal-click', {
  bubbles: true // composed: false (default)
}));
```

### 3. Boolean Property Defaulting to true

```typescript
// WRONG — no way to set false from HTML markup
@property({type: Boolean}) enabled = true;

// RIGHT — absence of attribute = false
@property({type: Boolean}) disabled = false;
```

### 4. Mutating Objects Without Triggering Update

```typescript
// WRONG — reference unchanged, no update
this.items.push(newItem);

// RIGHT — new reference triggers update
this.items = [...this.items, newItem];
```

### 5. <style> Elements in Templates

```typescript
// WRONG — parsed every render, per-instance stylesheet
render() {
  return html`
    <style>.box { color: ${this.color}; }</style>
    <div class="box">Text</div>
  `;
}

// RIGHT — static styles + styleMap for dynamic values
static styles = css`.box { color: var(--box-color); }`;
render() {
  return html`<div class="box" style=${styleMap({'--box-color': this.color})}>Text</div>`;
}
```

### 6. Side Effects in render()

```typescript
// WRONG
render() {
  this.fetchData(); // side effect!
  return html`<p>${this.data}</p>`;
}

// RIGHT — use Task or connectedCallback
private _data = new Task(this, {
  task: async () => this.fetchData(),
  args: () => [],
});
```

### 7. Class Fields Shadowing Lit Accessors

```typescript
// WRONG — plain class field shadows Lit's reactive accessor
class MyEl extends LitElement {
  myProp = 'value'; // breaks reactivity!
}

// RIGHT — declare (with experimentalDecorators)
@property() myProp = 'value';

// RIGHT — accessor (with standard decorators)
@property() accessor myProp = 'value';

// RIGHT — declare keyword (plain JS/TS without decorators)
declare myProp: string;
```

### 8. Reflecting Object/Array Properties

```typescript
// WRONG — JSON.stringify runs on every property change
@property({type: Object, reflect: true}) config = {};

// RIGHT — don't reflect complex types
@property({type: Object}) config = {};
```

---

## Ecosystem Libraries

### Design Systems Built on Lit

| Library | Maintainer | Components |
|---------|-----------|------------|
| Material Web (@material/web) | Google | 30+ Material Design 3 |
| Carbon Web Components | IBM | 60+ Carbon Design |
| Spectrum Web Components | Adobe | 50+ Spectrum Design |
| Vaadin Components | Vaadin | 40+ enterprise |
| PatternFly Elements | Red Hat | 30+ PatternFly |
| Shoelace (@shoelace-style/shoelace) | Community | 60+ accessible |

### Developer Tools

| Tool | Purpose |
|------|---------|
| `lit-analyzer` / `lit-plugin` | IDE template type checking |
| `eslint-plugin-lit` | Lit-specific linting |
| `eslint-plugin-lit-a11y` | Accessibility linting for templates |
| `@custom-elements-manifest/analyzer` | CEM generation |
| `@lit-labs/virtualizer` | Virtual scrolling |
| `@lit-labs/motion` | Animations |
| `@lit-labs/router` | Client-side routing |

### Lit Labs Status

| Package | Status |
|---------|--------|
| `@lit-labs/scoped-registry-mixin` | Near graduation |
| `@lit-labs/ssr` | Active development |
| `@lit-labs/signals` | Active development |
| `@lit-labs/virtualizer` | Active development |
| `@lit-labs/motion` | Active development |
| `@lit-labs/observers` | Active development |
| `@lit-labs/compiler` | Prototyping |
| `@lit-labs/router` | Prototyping |
| `@lit-labs/cli` | Prototyping |

---

## Lit 4 Trajectory (Unofficial)

Based on community signals and maintainer discussions:
- Standard decorators likely required (drop experimental decorator support)
- Compiler graduation (built-in template optimization)
- Signals possibly integrated at core level
- No official timeline announced

### Community Resources

- [lit.dev](https://lit.dev) — Official docs
- [lit.dev/playground](https://lit.dev/playground) — Interactive examples
- [Lit Discord](https://lit.dev/discord/) — Community support
- [GitHub: lit/lit](https://github.com/lit/lit) — Source and issues
- [Open Web Components](https://open-wc.org/) — Community standards and tools
- Lit joined the **OpenJS Foundation** — ensures long-term governance
