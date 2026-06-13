# Lit v3 Server-Side Rendering

`@lit-labs/ssr` for server rendering and `@lit-labs/ssr-client` for client hydration. Labs status — API may change.

## Overview

Renders Lit components to static HTML on the server (Node.js), including shadow DOM content and styles, before JavaScript loads on the client.

### Benefits

- **Performance** — static HTML visible before JS loads; optional hydration for interactivity
- **SEO** — content available to crawlers without JavaScript execution
- **Robustness** — content accessible if JavaScript fails to load

### Installation

```bash
npm i @lit-labs/ssr @lit-labs/ssr-client
```

---

## SSR Lifecycle Subset

Only these methods run during server-side rendering:

| Method | Runs in SSR |
|--------|:-----------:|
| `constructor()` | Yes |
| `willUpdate()` | Yes |
| `render()` | Yes |
| `connectedCallback()` | No |
| `update()` | No |
| `firstUpdated()` | No |
| `updated()` | No |

Design components so critical state computation happens in `willUpdate()`, not `updated()`.

---

## Server-Side Rendering

### Execution Contexts

#### Global Scope (Simpler)

```typescript
import {render} from '@lit-labs/ssr';
import {html} from 'lit';
import './my-element.js'; // registers in global customElements

const result = render(html`
  <my-element name="SSR"></my-element>
`);
```

Limitation: shared `customElements` registry — all requests share the same global state.

#### VM Module Isolation (Production)

Per-request isolation using Node.js VM modules:

```typescript
import {ModuleLoader} from '@lit-labs/ssr/lib/module-loader.js';

// Requires --experimental-vm-modules flag
const loader = new ModuleLoader();
const {render, html} = await loader.importModule('@lit-labs/ssr');
await loader.importModule('./my-element.js');

const result = render(html`<my-element name="SSR"></my-element>`);
```

### Consumption Patterns

#### Streaming (Recommended)

```typescript
import {RenderResultReadable} from '@lit-labs/ssr/lib/render-result-readable.js';
import Koa from 'koa';

const app = new Koa();
app.use(async (ctx) => {
  const result = render(html`<my-element></my-element>`);
  ctx.type = 'text/html';
  ctx.body = new RenderResultReadable(result);
});
```

#### Async Collection

```typescript
import {collectResult} from '@lit-labs/ssr/lib/render-result.js';

const result = render(html`<my-element></my-element>`);
const htmlString = await collectResult(result);
```

#### Sync Collection (throws on Promises)

```typescript
import {collectResultSync} from '@lit-labs/ssr/lib/render-result.js';

const htmlString = collectResultSync(result); // throws if async work needed
```

---

## Generated HTML

SSR produces Declarative Shadow DOM using `<template shadowrootmode="open">`:

```html
<my-element>
  <template shadowrootmode="open">
    <style>:host { display: block; }</style>
    <p>Hello, SSR!</p>
  </template>
</my-element>
```

### Polyfill for Older Browsers

Browsers without Declarative Shadow DOM support need the `template-shadowroot` polyfill:

```html
<script type="module">
  if (!HTMLTemplateElement.prototype.hasOwnProperty('shadowRootMode')) {
    const {hydrateShadowRoots} = await import('@webcomponents/template-shadowroot/template-shadowroot.js');
    hydrateShadowRoots(document.body);
  }
</script>
```

---

## Client Hydration

Hydration attaches Lit's reactive system to existing server-rendered DOM without re-rendering.

### Lit 3 Hydration Imports

```typescript
// MUST be loaded BEFORE any Lit imports — order matters!
import '@lit-labs/ssr-client/lit-element-hydrate-support.js';

// Then your components
import './my-element.js';
```

### Hydrating Standalone Templates

```typescript
import {hydrate} from '@lit-labs/ssr-client';
import {html} from 'lit';

const container = document.getElementById('app')!;
hydrate(html`<my-element name="Hydrated"></my-element>`, container);
```

### Lit 2 vs Lit 3 Hydration Imports

```typescript
// Lit 2 (deprecated)
import 'lit/experimental-hydrate-support.js';
import {hydrate} from 'lit/experimental-hydrate.js';

// Lit 3 (current)
import '@lit-labs/ssr-client/lit-element-hydrate-support.js';
import {hydrate} from '@lit-labs/ssr-client';
```

---

## Framework Integrations

| Framework | Package/Plugin | Notes |
|-----------|---------------|-------|
| **Eleventy** | Lit Eleventy Plugin | First-class support |
| **Astro** | Built-in `@astrojs/lit` | `npx astro add lit` |
| **Rocket** | Native support | Lit team project |
| **Next.js** | `@lit-labs/nextjs` | Pages router only |
| **Nuxt 3** | `nuxt-ssr-lit` | Community package |

### Astro Example

```bash
npx astro add lit
```

```astro
---
// src/pages/index.astro
import '../components/my-element.js';
---
<my-element name="Astro" client:idle></my-element>
```

---

## Limitations

- Only **shadow DOM** components supported (no light DOM rendering via `createRenderRoot`)
- **Async** component work not supported during SSR
- Declarative Shadow DOM requires polyfill in some browsers
- **Labs/experimental** status — API may change before graduation
- No support for `@lit/task` or `@lit-labs/signals` during SSR

---

## Best Practices

1. Keep SSR-critical logic in `willUpdate()` and `render()` — these are the only lifecycle methods that run server-side
2. Guard browser-only APIs (`window`, `document`, `localStorage`) with `typeof window !== 'undefined'`
3. Use `isServer` from `lit` to detect SSR context:
   ```typescript
   import {isServer} from 'lit';
   if (!isServer) {
     // browser-only code
   }
   ```
4. Avoid `connectedCallback` for data initialization — it doesn't run in SSR
5. Test SSR output separately from client tests
