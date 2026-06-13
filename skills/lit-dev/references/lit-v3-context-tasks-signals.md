# Lit v3 Context, Tasks & Signals

Deep reference for the three data management packages: `@lit/context` (stable), `@lit/task` (stable), and `@lit-labs/signals` (labs).

## Context Protocol (@lit/context)

Built on the W3C Web Components Community Group Context Protocol. Uses DOM events for cross-library interoperability — any framework implementing the protocol can provide/consume context.

### Installation

```bash
npm i @lit/context
```

### Creating Contexts

A context is a key that connects providers and consumers:

```typescript
import {createContext} from '@lit/context';

// String key — equal across calls (safe for cross-package use)
export const loggerContext = createContext<Logger>('logger');

// Symbol.for key — equal across calls (safe for cross-package use)
export const themeContext = createContext<Theme>(Symbol.for('app-theme'));

// Symbol() key — unique per call (private, no collisions)
export const privateContext = createContext<InternalState>(Symbol('internal'));
```

### Providing Context — @provide Decorator

```typescript
import {provide} from '@lit/context';

@customElement('my-app')
class MyApp extends LitElement {
  // Static value
  @provide({context: loggerContext})
  logger = new Logger();

  // Reactive — consumers update when this changes
  @provide({context: themeContext})
  @property({attribute: false})
  theme: Theme = {mode: 'light', accent: 'blue'};
}
```

### Providing Context — ContextProvider Controller

For imperative control and external updates:

```typescript
import {ContextProvider} from '@lit/context';

@customElement('my-app')
class MyApp extends LitElement {
  private _provider = new ContextProvider(this, {
    context: loggerContext,
    initialValue: new Logger(),
  });

  updateLogger(newLogger: Logger) {
    this._provider.setValue(newLogger);       // notifies subscribers
    this._provider.setValue(newLogger, true); // force notify even if same reference
  }
}
```

### Consuming Context — @consume Decorator

```typescript
import {consume} from '@lit/context';

@customElement('my-element')
class MyElement extends LitElement {
  // One-time read (value at connection time)
  @consume({context: loggerContext})
  @property({attribute: false})
  logger!: Logger;

  // Subscribe to changes — re-renders when provider updates
  @consume({context: themeContext, subscribe: true})
  @property({attribute: false})
  theme!: Theme;
}
```

### Consuming Context — ContextConsumer Controller

```typescript
import {ContextConsumer} from '@lit/context';

@customElement('my-element')
class MyElement extends LitElement {
  private _theme = new ContextConsumer(this, {
    context: themeContext,
    subscribe: true,
    callback: (value, dispose) => {
      console.log('Theme changed:', value);
    },
  });

  render() {
    return html`<p>Mode: ${this._theme.value?.mode}</p>`;
  }
}
```

### ContextRoot (Late Provider Support)

When providers may be added to the DOM after consumers:

```typescript
import {ContextRoot} from '@lit/context';

// At app initialization
const root = new ContextRoot();
root.attach(document.body);
// Re-dispatches unsatisfied context requests when new providers appear
```

### Use Cases

| Pattern | Example |
|---------|---------|
| Application state | User session, locale, permissions |
| Service injection | Logger, analytics, API client |
| Theming | Color mode, design tokens |
| Plugin APIs | Let light DOM children access host capabilities |

---

## Tasks (@lit/task)

Manages async operations with status tracking and automatic re-execution.

### Installation

```bash
npm i @lit/task
```

### Task Status States

```
INITIAL → PENDING → COMPLETE or ERROR
```

### Basic Usage

```typescript
import {Task} from '@lit/task';

@customElement('product-view')
class ProductView extends LitElement {
  @property() productId?: string;

  private _product = new Task(this, {
    task: async ([productId], {signal}) => {
      const response = await fetch(`/api/products/${productId}`, {signal});
      if (!response.ok) throw new Error(`${response.status}`);
      return response.json() as Promise<Product>;
    },
    args: () => [this.productId],
  });

  render() {
    return this._product.render({
      initial: () => html`<p>Enter a product ID</p>`,
      pending: () => html`<p>Loading...</p>`,
      complete: (product) => html`
        <h1>${product.name}</h1>
        <p>${product.description}</p>
        <span>$${product.price}</span>
      `,
      error: (e) => html`<p class="error">Error: ${e}</p>`,
    });
  }
}
```

### Auto-Run vs Manual

```typescript
// Auto-run (default) — runs when args change
private _data = new Task(this, {
  task: async ([id]) => fetchData(id),
  args: () => [this.id],
});

// Manual — call .run() explicitly
private _submitTask = new Task(this, {
  autoRun: false,
  task: async ([formData]) => submitForm(formData),
  args: () => [this.formData],
});

private _handleSubmit() {
  this._submitTask.run();
}
```

### Abort Signal

Tasks automatically abort previous runs when args change:

```typescript
task: async ([url], {signal}) => {
  const response = await fetch(url, {signal}); // auto-cancels on arg change
  return response.json();
}

// Manual abort check for long computations
task: async ([data], {signal}) => {
  const result = await processData(data);
  signal.throwIfAborted(); // throws if task was superseded
  return result;
}
```

### Task Chaining

One task's output feeds another:

```typescript
private _rawData = new Task(this, {
  task: async ([id]) => fetchRawData(id),
  args: () => [this.dataId],
});

private _processedData = new Task(this, {
  task: async ([data, param]) => processData(data, param),
  args: () => [this._rawData.value, this.processingParam],
});
```

The second task runs when the first completes (because `_rawData.value` changes).

### Task Properties

| Property | Type | Description |
|----------|------|-------------|
| `status` | `TaskStatus` | Current status (INITIAL, PENDING, COMPLETE, ERROR) |
| `value` | `T \| undefined` | Result on completion |
| `error` | `unknown` | Error object on failure |
| `render(config)` | `TemplateResult` | Choose template by status |

---

## Signals (@lit-labs/signals)

Reactive data structures for shared observable state. Integrates with the TC39 Signals Proposal.

### Installation

```bash
npm i @lit-labs/signals
```

**Singleton warning**: Only one copy of `signal-polyfill` can exist per page. Verify:

```bash
npm ls signal-polyfill
npm dedupe  # if duplicates found
```

### Core Concepts

```typescript
import {signal, computed} from '@lit-labs/signals';

// State signal — holds a mutable value
const count = signal(0);
count.get();        // read: 0
count.set(1);       // write: 1

// Computed signal — derived value, auto-tracks dependencies
const doubled = computed(() => count.get() * 2);
doubled.get();      // 2
```

### SignalWatcher Mixin

Auto-updates component when any signal read during `render()` changes:

```typescript
import {SignalWatcher, signal} from '@lit-labs/signals';

const count = signal(0);

@customElement('my-counter')
class MyCounter extends SignalWatcher(LitElement) {
  render() {
    return html`
      <p>Count: ${count.get()}</p>
      <button @click=${() => count.set(count.get() + 1)}>+</button>
    `;
  }
}
```

Multiple component instances sharing the same signal all update when it changes. No prop drilling, no context — just shared reactive state.

### watch() Directive

Pinpoint DOM updates — only the specific binding with the changed signal updates (not the whole component):

```typescript
import {SignalWatcher, watch, signal} from '@lit-labs/signals';

const count = signal(0);
const name = signal('World');

@customElement('my-element')
class MyElement extends SignalWatcher(LitElement) {
  render() {
    return html`
      <p>Count: ${watch(count)}</p>
      <p>Name: ${watch(name)}</p>
    `;
  }
}
```

When `count` changes, only the first `<p>` updates.

### Signals html Tag

Auto-applies `watch()` to signal values — no `.get()` needed:

```typescript
import {SignalWatcher, html, signal} from '@lit-labs/signals';
// Note: import html from @lit-labs/signals, not lit

const count = signal(0);

@customElement('my-element')
class MyElement extends SignalWatcher(LitElement) {
  render() {
    return html`<p>Count: ${count}</p>`; // auto-watched, no .get()
  }
}
```

Note: doesn't yet work well with `lit-analyzer`.

### signal-utils Package

Observable collections and class decorators:

```typescript
import {SignalArray} from 'signal-utils/array';
import {signal as signalDecorator} from 'signal-utils';

// Observable array — mutations trigger updates
const items = new SignalArray([1, 2, 3]);
items.push(4); // triggers dependent computeds/watchers

// Class with signal-backed properties
class GameState {
  @signalDecorator accessor score = 0;
  @signalDecorator accessor gameOver = false;
}
```

### Three Integration Methods Summary

| Method | Granularity | Syntax | Best For |
|--------|-------------|--------|----------|
| `SignalWatcher` mixin | Component-level re-render | `count.get()` in render | Simple cases |
| `watch()` directive | Per-binding update | `watch(count)` | Performance-critical |
| Signals `html` tag | Per-binding update (auto) | `${count}` (no .get) | Cleanest syntax |

### Planned Features (Not Yet Available)

- Signal-aware `repeat()` directive
- `@property()` using signals for storage
- `@computed()` decorator
- `@effect()` decorator

### Status

Labs/experimental. Relies on TC39 proposal polyfill. API may change before graduation to stable.

---

## Choosing Between Context, Tasks, and Signals

| Need | Use |
|------|-----|
| Pass data down a component tree without prop drilling | Context |
| Provide services (logger, API client) to descendants | Context |
| Manage a single async operation with loading/error states | Task |
| Auto-cancel/retry async operations on input change | Task |
| Share reactive state across unrelated components | Signals |
| Fine-grained per-binding reactivity | Signals with `watch()` |
| Global app state (like a store) | Signals |

These are complementary — a single app might use all three:
- Context for dependency injection (services, config)
- Tasks for async data fetching
- Signals for shared UI state
