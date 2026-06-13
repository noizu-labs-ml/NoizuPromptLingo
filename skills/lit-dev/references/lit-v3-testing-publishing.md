# Lit v3 Testing & Publishing

Browser-based testing, production builds, and npm publishing rules for Lit components.

## Testing

### Fundamental Rule

Lit components **must be tested in a real browser** — not jsdom. They depend on Custom Elements, Shadow DOM, and Constructable Stylesheets, which jsdom does not fully support.

### Recommended Stack: Web Test Runner + @open-wc/testing

```bash
npm i -D @web/test-runner @open-wc/testing
```

#### Web Test Runner Config

```javascript
// web-test-runner.config.mjs
export default {
  files: 'test/**/*.test.js',
  nodeResolve: true,
  // Optional: browser launcher
  // browsers: [playwrightLauncher({ product: 'chromium' })],
};
```

#### Package.json Script

```json
{
  "scripts": {
    "test": "web-test-runner"
  }
}
```

### Writing Tests

```typescript
import {fixture, html, expect} from '@open-wc/testing';
import '../src/my-element.js';
import type {MyElement} from '../src/my-element.js';

describe('my-element', () => {
  it('renders with default values', async () => {
    const el = await fixture<MyElement>(html`<my-element></my-element>`);
    expect(el.name).to.equal('World');
    expect(el.shadowRoot!.querySelector('p')!.textContent).to.include('Hello, World');
  });

  it('renders with custom name', async () => {
    const el = await fixture<MyElement>(html`<my-element name="Test"></my-element>`);
    expect(el.shadowRoot!.querySelector('p')!.textContent).to.include('Hello, Test');
  });

  it('updates on property change', async () => {
    const el = await fixture<MyElement>(html`<my-element></my-element>`);
    el.name = 'Updated';
    await el.updateComplete;
    expect(el.shadowRoot!.querySelector('p')!.textContent).to.include('Hello, Updated');
  });

  it('fires custom event on click', async () => {
    const el = await fixture<MyElement>(html`<my-element></my-element>`);
    let detail: unknown;
    el.addEventListener('count-changed', ((e: CustomEvent) => {
      detail = e.detail;
    }) as EventListener);

    el.shadowRoot!.querySelector('button')!.click();
    expect(detail).to.deep.equal({count: 1});
  });
});
```

### Key Testing Patterns

#### Always await updateComplete

```typescript
el.someProp = newValue;
await el.updateComplete;
// NOW assert against DOM
```

#### Query through shadow DOM

```typescript
const inner = el.shadowRoot!.querySelector('.inner');
```

#### Semantic DOM diff snapshots (@open-wc/testing)

```typescript
expect(el).shadowDom.to.equalSnapshot();
```

#### Accessibility assertions (with axe-core)

```typescript
import {axe} from '@open-wc/testing';

it('is accessible', async () => {
  const el = await fixture(html`<my-element></my-element>`);
  await expect(el).to.be.accessible();
});
```

### Alternative: WebdriverIO

```typescript
import {expect, $} from '@wdio/globals';
import './components/my-element.ts';

describe('my-element', () => {
  let elem: HTMLElement;

  beforeEach(() => {
    elem = document.createElement('my-element');
  });

  it('should render', async () => {
    elem.setAttribute('name', 'WebdriverIO');
    document.body.appendChild(elem);
    await expect($(elem)).toHaveText('Hello, WebdriverIO!');
  });

  afterEach(() => { elem.remove(); });
});
```

### Alternative: Vitest Browser Mode

Emerging option with Playwright:

```typescript
// vitest.config.ts
import {defineConfig} from 'vitest/config';

export default defineConfig({
  test: {
    browser: {
      enabled: true,
      provider: 'playwright',
      name: 'chromium',
    },
  },
});
```

### requestAnimationFrame vs updateComplete

For full descendant-tree completion, `requestAnimationFrame` is often more reliable than `updateComplete`:

```typescript
el.someProp = newValue;
await new Promise(r => requestAnimationFrame(r));
// All descendant updates have likely completed
```

`updateComplete` only guarantees the element itself has updated, not its children.

---

## Production Builds

### Recommended: Rollup

```javascript
// rollup.config.js
import html from '@web/rollup-plugin-html';
import {copy} from '@web/rollup-plugin-copy';
import resolve from '@rollup/plugin-node-resolve';
import terser from '@rollup/plugin-terser';
import minifyHTML from 'rollup-plugin-minify-html-literals';
import summary from 'rollup-plugin-summary';

export default {
  plugins: [
    html({input: 'index.html'}),
    resolve(),
    minifyHTML(),
    terser({ecma: 2021, module: true, warnings: true}),
    summary(),
    copy({patterns: ['images/**/*']}),
  ],
  output: {dir: 'build'},
  preserveEntrySignatures: 'strict',
};
```

### Key Optimizations

1. **Bundling** — reduce network requests
2. **Minification** — Terser for JS, `rollup-plugin-minify-html-literals` for template literals
3. **Modern code** — target ES2021 for modern browsers
4. **Asset hashing** — cache invalidation via fingerprinted URLs
5. **Compression** — gzip/brotli at the server level

### Bundler Comparison

| Bundler | Dev Speed | Tree-shaking | Config | Best For |
|---------|-----------|-------------|--------|----------|
| Vite | Fastest | Good | Minimal | Apps with dev server |
| Rollup | N/A (prod only) | Best | Moderate | Libraries, production builds |
| esbuild | Very fast | Good | Minimal | Fast builds, simple apps |
| Webpack | Moderate | Good | Heavy | Legacy projects |

### Vite-Specific Plugins

```bash
npm i -D vite-plugin-web-components-hmr vite-plugin-lit-css
```

```typescript
// vite.config.ts
import {defineConfig} from 'vite';
import webComponentsHmr from 'vite-plugin-web-components-hmr';
import litCss from 'vite-plugin-lit-css';

export default defineConfig({
  plugins: [
    webComponentsHmr({presets: ['lit']}),
    litCss(),
  ],
});
```

`vite-plugin-lit-css` lets you import `.css` files directly as Lit `css` tagged templates.

### Development vs Production Builds

Lit ships both. Development builds include runtime warnings:

```javascript
// Rollup — opt into dev builds
import {nodeResolve} from '@rollup/plugin-node-resolve';
export default {
  plugins: [nodeResolve({exportConditions: ['development']})]
};
```

Control warnings:

```typescript
LitElement.disableWarning?.('change-in-update');
```

---

## Publishing Components to npm

### Critical Rules

| Rule | Reason |
|------|--------|
| **Do NOT bundle** | Bundling causes duplicate Lit instances in consumer apps |
| **Do NOT minify** | Optimization is the consumer's concern |
| **Do NOT include polyfills** | Polyfills are an application-level concern |
| **Include file extensions** in imports | `import './element.js'` not `import './element'` |
| **Self-register** with `customElements.define()` | Components should work when imported |
| **Export the class** | For subclassing and future scoped registries |

### Package.json

```json
{
  "name": "my-element",
  "version": "1.0.0",
  "type": "module",
  "main": "my-element.js",
  "module": "my-element.js",
  "types": "my-element.d.ts",
  "files": [
    "*.js",
    "*.js.map",
    "*.d.ts",
    "*.d.ts.map"
  ],
  "exports": {
    ".": {
      "types": "./my-element.d.ts",
      "default": "./my-element.js"
    }
  },
  "peerDependencies": {
    "lit": "^3.0.0"
  }
}
```

### TypeScript Config for Publishing

```jsonc
{
  "compilerOptions": {
    "target": "es2021",
    "module": "es2015",
    "moduleResolution": "node",
    "lib": ["es2021", "dom"],
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "outDir": "./",
    "rootDir": "./src",
    "experimentalDecorators": true,
    "useDefineForClassFields": false
  },
  "include": ["src/**/*.ts"]
}
```

### HTMLElementTagNameMap Declaration

```typescript
declare global {
  interface HTMLElementTagNameMap {
    'my-element': MyElement;
  }
}
```

This enables type inference when consumers use `document.querySelector('my-element')` or `document.createElement('my-element')`.

### Custom Elements Manifest

Generate a manifest for IDE tooling and documentation:

```bash
npm i -D @custom-elements-manifest/analyzer
npx cem analyze --litelement
```

### IDE Support

Recommend these tools in your component library's README:
- **lit-plugin** (VS Code) — syntax highlighting, type checking, completion inside `html` templates
- **ts-lit-plugin** — same, for non-VS Code editors
- **eslint-plugin-lit** — Lit-specific linting rules
- **eslint-plugin-lit-a11y** — accessibility linting for Lit templates
