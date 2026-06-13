# Lit v3 Composition Patterns

Component composition, mixins, reactive controllers, events, slots, and the mediator pattern.

## Core Principle: Properties Down, Events Up

Data flows down via properties. Changes propagate up via CustomEvents. Children never reach up or communicate directly with siblings.

```
┌─────────────────────────────────────┐
│ Parent Component                     │
│                                      │
│  .items=${this.items}     ←── data   │
│  @item-selected=${this.handle}  ←── events │
│                                      │
│  ┌──────────┐  ┌──────────┐         │
│  │ Child A   │  │ Child B   │        │
│  └──────────┘  └──────────┘         │
└─────────────────────────────────────┘
```

---

## Passing Data Down (Properties)

```typescript
@customElement('parent-el')
class ParentEl extends LitElement {
  @property() items: Item[] = [];
  @property() selectedItem: Item | null = null;

  render() {
    return html`
      <child-menu
        .items=${this.items}
        .selectedItem=${this.selectedItem}
        @item-selected=${this._handleSelection}
      ></child-menu>
      <child-detail .item=${this.selectedItem}></child-detail>
    `;
  }

  private _handleSelection(e: CustomEvent<{item: Item}>) {
    this.selectedItem = e.detail.item;
  }
}
```

---

## Custom Events

### Basic CustomEvent

```typescript
this.dispatchEvent(new CustomEvent('item-selected', {
  detail: {item: selectedItem},
  bubbles: true,    // flows up the DOM tree
  composed: true,   // crosses shadow DOM boundaries
}));
```

### Typed Custom Events (Best Practice)

Subclass `Event` for type-safe, self-documenting events:

```typescript
export class StatusChangedEvent extends Event {
  static readonly eventName = 'status-changed' as const;

  constructor(public readonly status: 'active' | 'inactive') {
    super(StatusChangedEvent.eventName, {bubbles: true, composed: true});
  }
}

// Dispatch
this.dispatchEvent(new StatusChangedEvent('active'));

// Listen (type-safe)
el.addEventListener(StatusChangedEvent.eventName, (e: StatusChangedEvent) => {
  console.log(e.status); // typed as 'active' | 'inactive'
});

// In template
html`<my-el @status-changed=${(e: StatusChangedEvent) => this._handle(e)}></my-el>`
```

### Event Options

| Option | Default | Purpose |
|--------|---------|---------|
| `bubbles` | `false` | Event flows up the DOM tree |
| `composed` | `false` | Event crosses shadow DOM boundaries |
| `cancelable` | `false` | `preventDefault()` can cancel the event |

Most standard UI events (mouse, touch, keyboard) are already bubbling and composed.

### Event Retargeting

Composed events from shadow DOM appear to come from the host element. Use `composedPath()` for the actual source:

```typescript
handleEvent(event: Event) {
  const origin = event.composedPath()[0]; // actual source element
}
```

### Bidirectional Event Communication

The listener can write back to the event detail:

```typescript
// Dispatcher
const event = new CustomEvent('request-data', {
  detail: {response: null},
  bubbles: true, composed: true,
});
this.dispatchEvent(event);
const data = event.detail.response; // read back from listener

// Listener
el.addEventListener('request-data', (e: CustomEvent) => {
  e.detail.response = this.getData();
});
```

The `preventDefault()` handshake:

```typescript
// Dispatcher — check if listener vetoed
const event = new CustomEvent('before-close', {
  bubbles: true, composed: true, cancelable: true,
});
this.dispatchEvent(event);
if (!event.defaultPrevented) {
  this._close(); // proceed only if not vetoed
}
```

### Dispatching After Render

```typescript
async handleChange() {
  this.myProperty = newValue;
  await this.updateComplete;
  this.dispatchEvent(new Event('my-change'));
}
```

### External Listeners (Window, Document)

Use arrow functions or bind for correct `this`:

```typescript
private _handleResize = () => { this._width = window.innerWidth; };

connectedCallback() {
  super.connectedCallback();
  window.addEventListener('resize', this._handleResize);
}

disconnectedCallback() {
  window.removeEventListener('resize', this._handleResize);
  super.disconnectedCallback();
}
```

### Removing Event Listeners

Pass `nothing` to remove:

```typescript
html`<button @click=${this.active ? this._handler : nothing}>Click</button>`
```

---

## Slot-Based Composition

### Default and Named Slots

```typescript
@customElement('top-bar')
class TopBar extends LitElement {
  render() {
    return html`
      <div class="nav"><slot name="nav-button"></slot></div>
      <div class="title"><slot name="title"></slot></div>
      <div class="actions"><slot></slot></div>
    `;
  }
}

// Usage
html`
<top-bar>
  <icon-button icon="menu" slot="nav-button"></icon-button>
  <span slot="title">My App</span>
  <icon-button icon="settings"></icon-button>
</top-bar>
`
```

### Fallback Content

```typescript
html`<slot name="header"><h2>Default Header</h2></slot>`
```

### Responding to Slot Changes

```typescript
render() {
  return html`<slot @slotchange=${this._onSlotChange}></slot>`;
}

private _onSlotChange(e: Event) {
  const slot = e.target as HTMLSlotElement;
  const children = slot.assignedElements({flatten: true});
  this._hasContent = children.length > 0;
  this.requestUpdate();
}
```

### Querying Slotted Children

```typescript
// Decorator approach
@queryAssignedElements({slot: 'list', selector: '.item'})
_listItems!: HTMLElement[];

@queryAssignedNodes({slot: 'header', flatten: true})
_headerNodes!: Node[];
```

---

## Reactive Controllers

Reusable behaviors that hook into a component's lifecycle without inheritance.

### ReactiveController Interface

```typescript
interface ReactiveController {
  hostConnected?(): void;       // Host added to DOM
  hostDisconnected?(): void;    // Host removed from DOM
  hostUpdate?(): void;          // Before host's update() and render()
  hostUpdated?(): void;         // After updates, before host's updated()
}
```

### Creating a Controller

```typescript
export class ClockController implements ReactiveController {
  private _timerID?: ReturnType<typeof setInterval>;
  value = new Date();

  constructor(
    private host: ReactiveControllerHost,
    private timeout = 1000
  ) {
    this.host.addController(this);
  }

  hostConnected() {
    this._timerID = setInterval(() => {
      this.value = new Date();
      this.host.requestUpdate();
    }, this.timeout);
  }

  hostDisconnected() {
    clearInterval(this._timerID);
  }
}
```

### Using a Controller

```typescript
@customElement('my-element')
class MyElement extends LitElement {
  private clock = new ClockController(this, 1000);

  render() {
    return html`<p>Time: ${this.clock.value.toLocaleTimeString()}</p>`;
  }
}
```

### Controller + Directive Composition

A controller that owns a `ref()` directive for per-element DOM observation:

```typescript
import {ref, createRef} from 'lit/directives/ref.js';

export class ResizeController implements ReactiveController {
  private _observer?: ResizeObserver;
  private _ref = createRef<HTMLElement>();
  width = 0;
  height = 0;

  constructor(private host: ReactiveControllerHost) {
    this.host.addController(this);
  }

  observe() {
    return ref(this._ref);
  }

  hostConnected() {
    this._observer = new ResizeObserver(([entry]) => {
      this.width = entry.contentRect.width;
      this.height = entry.contentRect.height;
      this.host.requestUpdate();
    });
    if (this._ref.value) {
      this._observer.observe(this._ref.value);
    }
  }

  hostDisconnected() {
    this._observer?.disconnect();
  }
}

// Usage
class MyElement extends LitElement {
  private _resize = new ResizeController(this);

  render() {
    return html`
      <div ${this._resize.observe()}>
        Size: ${this._resize.width} x ${this._resize.height}
      </div>
    `;
  }
}
```

### Composing Controllers

Controllers can own other controllers:

```typescript
class DualClockController {
  clock1: ClockController;
  clock2: ClockController;

  constructor(host: ReactiveControllerHost, delay1: number, delay2: number) {
    this.clock1 = new ClockController(host, delay1);
    this.clock2 = new ClockController(host, delay2);
  }
}
```

---

## Mixins

"Subclass factories" for sharing behavior — add properties, methods, and lifecycle hooks.

### Basic Mixin

```typescript
type Constructor<T = {}> = new (...args: any[]) => T;

export const LoggingMixin = <T extends Constructor<LitElement>>(superClass: T) => {
  class LoggingMixinClass extends superClass {
    connectedCallback() {
      super.connectedCallback();
      console.log(`${this.localName} connected`);
    }
  }
  return LoggingMixinClass as T;
};
```

### Mixin with Public API (TypeScript)

Declare the interface separately for proper typing:

```typescript
export declare class HighlightInterface {
  highlight: boolean;
  protected renderHighlight(content: unknown): unknown;
}

export const HighlightMixin = <T extends Constructor<LitElement>>(superClass: T) => {
  class HighlightMixinClass extends superClass {
    @property() highlight = false;

    protected renderHighlight(content: unknown) {
      return html`<div class=${this.highlight ? 'highlight' : ''}>${content}</div>`;
    }
  }
  return HighlightMixinClass as Constructor<HighlightInterface> & T;
};
```

### Applying Mixins

```typescript
@customElement('my-element')
class MyElement extends LoggingMixin(HighlightMixin(LitElement)) {
  render() {
    return this.renderHighlight(html`<p>Hello</p>`);
  }
}
```

### Decorator Gotcha

Decorators must be applied to **class declarations**, not class expressions:

```typescript
// WORKS — named class
class MyMixinClass extends superClass {
  @property() mode = 'on';
}

// FAILS — anonymous class expression
class extends superClass {
  @property() mode = 'on'; // decorators can't apply here
}
```

---

## Mixins vs Controllers

| Criterion | Mixins | Controllers |
|-----------|--------|------------|
| Diamond problem | Possible with conflicting mixins | None — multiple instances OK |
| Dynamic application | No — fixed at class definition | Yes — add/remove at runtime |
| TypeScript ergonomics | Requires interface declaration | Standard class |
| Multiple instances | No — one mixin applied once | Yes — multiple controllers |
| Adds to prototype chain | Yes | No |
| Access to lifecycle | Yes (override methods) | Yes (hostConnected etc.) |
| Best for | Cross-cutting concerns (logging, theming) | Reusable behaviors (timers, observers) |

**Prefer controllers** for most cases. Use mixins only when you need to add properties/methods to the component's public API.

---

## Mediator Pattern (Sibling Communication)

The parent owns shared state and coordinates children — children never communicate directly:

```typescript
@customElement('app-shell')
class AppShell extends LitElement {
  @state() private _selectedItem: Item | null = null;
  @state() private _items: Item[] = [];

  render() {
    return html`
      <item-list
        .items=${this._items}
        @item-selected=${this._onItemSelected}
      ></item-list>
      <item-detail
        .item=${this._selectedItem}
        @item-updated=${this._onItemUpdated}
      ></item-detail>
    `;
  }

  private _onItemSelected(e: CustomEvent<{item: Item}>) {
    this._selectedItem = e.detail.item;
  }

  private _onItemUpdated(e: CustomEvent<{item: Item}>) {
    this._items = this._items.map(i =>
      i.id === e.detail.item.id ? e.detail.item : i
    );
  }
}
```
