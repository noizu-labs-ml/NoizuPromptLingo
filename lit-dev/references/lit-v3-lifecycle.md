# Lit v3 Lifecycle

Complete lifecycle reference — from element construction through reactive update cycles and cleanup.

## Lifecycle Overview

```
Element created / upgraded
  → constructor()
    → connectedCallback()
      → Reactive Update Cycle (async, microtask timing)
        → shouldUpdate(changedProperties)
          → willUpdate(changedProperties)      ← RUNS IN SSR
            → update(changedProperties)
              → render()                       ← RUNS IN SSR
            → firstUpdated(changedProperties)  ← first time only
            → updated(changedProperties)
              → updateComplete resolves
  → disconnectedCallback()
  → adoptedCallback()
  → attributeChangedCallback()
```

---

## Standard Custom Element Callbacks

### constructor()

Called when the element is created or upgraded. Lit uses it to:
- Call `requestUpdate()` to schedule the first update
- Save any pre-set property values (properties set before upgrade)

```typescript
constructor() {
  super();
  // Set defaults, create non-reactive state
  this._controller = new MyController(this);
}
```

Rules:
- Always call `super()` first
- No attributes or children — element isn't in the DOM yet
- No DOM access — `renderRoot` doesn't exist yet

### connectedCallback()

Called when the element is inserted into the DOM. Lit uses it to:
- Create the `renderRoot` (shadow root) if it doesn't exist
- Initiate the first reactive update cycle
- Notify reactive controllers via `hostConnected()`

```typescript
connectedCallback() {
  super.connectedCallback();
  window.addEventListener('resize', this._handleResize);
  this._observer = new IntersectionObserver(this._handleIntersect);
  this._observer.observe(this);
}
```

### disconnectedCallback()

Called when the element is removed from the DOM. Lit pauses the reactive update cycle.

```typescript
disconnectedCallback() {
  super.disconnectedCallback();
  window.removeEventListener('resize', this._handleResize);
  this._observer?.disconnect();
}
```

Elements may be disconnected and reconnected — design for this.

### attributeChangedCallback(name, old, new)

Called when an observed attribute changes. Lit handles this automatically for `@property()` declarations — it syncs the attribute value to the property.

You rarely need to override this directly.

### adoptedCallback()

Called when the element is moved to a new document (e.g., via `document.adoptNode()`). No default Lit behavior.

---

## Reactive Update Cycle

Updates are **asynchronous** — they batch at microtask timing (before the next browser paint). Multiple property changes in the same synchronous block trigger only one update.

### shouldUpdate(changedProperties)

Return `false` to skip the update entirely.

```typescript
shouldUpdate(changedProperties: PropertyValues): boolean {
  // Only update when 'important' property changes
  return changedProperties.has('important');
}
```

Default: returns `true`.

### willUpdate(changedProperties)

Compute derived values before render. Called before `update()` and `render()`. **Runs in SSR.**

```typescript
willUpdate(changedProperties: PropertyValues) {
  if (changedProperties.has('firstName') || changedProperties.has('lastName')) {
    this.fullName = `${this.firstName} ${this.lastName}`;
  }
}
```

Setting reactive properties in `willUpdate()` does **not** trigger an additional update cycle — changes are included in the current cycle.

### update(changedProperties)

Calls `render()` and applies the template to the DOM. You rarely override this.

```typescript
update(changedProperties: PropertyValues) {
  // Pre-render DOM manipulation (rare)
  super.update(changedProperties); // MUST call super
  // Post-render DOM manipulation (rare)
}
```

### render()

Return a `TemplateResult` (or string, number, nothing). **Runs in SSR.**

```typescript
render() {
  return html`<p>Hello, ${this.name}!</p>`;
}
```

Rules:
- Must be a pure function of component state
- No side effects
- No DOM queries (DOM may not be updated yet)
- Return a single `TemplateResult` (or compose multiple)

### firstUpdated(changedProperties)

Called once after the first render. DOM is available.

```typescript
firstUpdated(changedProperties: PropertyValues) {
  // Focus an input, measure layout, initialize third-party libraries
  this.renderRoot.querySelector('input')?.focus();
}
```

Setting reactive properties here **will** trigger an additional update cycle.

### updated(changedProperties)

Called after every render. DOM is available and up-to-date.

```typescript
updated(changedProperties: PropertyValues) {
  if (changedProperties.has('collapsed')) {
    this._animateCollapse();
  }
}
```

Setting reactive properties here **will** trigger an additional update cycle. Guard against infinite loops.

---

## updateComplete

Promise that resolves when the current update cycle finishes:

```typescript
async _loginClickHandler() {
  this.loggedIn = true;
  await this.updateComplete;
  // DOM is now updated with logged-in state
  this.dispatchEvent(new Event('login'));
}
```

### Awaiting Child Updates

Override `getUpdateComplete()` to include child component updates:

```typescript
protected async getUpdateComplete(): Promise<boolean> {
  const result = await super.getUpdateComplete();
  await this._myChild.updateComplete;
  return result;
}
```

---

## requestUpdate()

Manually schedule an update for changes Lit can't detect:

```typescript
// Non-property state change
connectedCallback() {
  super.connectedCallback();
  this._timerInterval = setInterval(() => {
    this._elapsedTime = Date.now() - this._startTime;
    this.requestUpdate();
  }, 1000);
}

// With property name and old value (for changedProperties)
this.requestUpdate('myProp', oldValue);
```

---

## scheduleUpdate()

Override to customize update timing:

```typescript
// Defer to next macrotask (instead of microtask)
protected async scheduleUpdate(): Promise<void> {
  await new Promise(resolve => setTimeout(resolve));
  super.scheduleUpdate();
}

// Wait for animation frame
protected async scheduleUpdate(): Promise<void> {
  await new Promise(resolve => requestAnimationFrame(resolve));
  super.scheduleUpdate();
}
```

---

## External Lifecycle Hooks

### addInitializer

Run code during construction — useful for custom decorators and controllers:

```typescript
// In a custom decorator
function myDecorator(target, name) {
  target.constructor.addInitializer((instance) => {
    new MyController(instance);
  });
}
```

### addController / removeController

Manage reactive controllers:

```typescript
connectedCallback() {
  super.connectedCallback();
  this.addController(this._myController);
}
```

---

## SSR Lifecycle Subset

Only these methods run during server-side rendering:
- `constructor()`
- `willUpdate()`
- `render()`

Everything else (`connectedCallback`, `firstUpdated`, `updated`, DOM access) is client-only. Design components so critical state computation happens in `willUpdate()`, not `updated()`.

---

## Common Patterns

### Debounced Update

```typescript
private _debounceTimer?: ReturnType<typeof setTimeout>;

private _debouncedUpdate() {
  clearTimeout(this._debounceTimer);
  this._debounceTimer = setTimeout(() => this.requestUpdate(), 200);
}
```

### Waiting for First Render

```typescript
async performAfterRender() {
  // Wait for first update if element hasn't rendered yet
  if (!this.hasUpdated) {
    await this.updateComplete;
  }
  // Safe to access DOM
}
```

### Property Change Reactions

```typescript
updated(changedProperties: PropertyValues) {
  // React to specific changes
  if (changedProperties.has('src')) {
    this._loadImage(this.src);
  }

  // React to any of several changes
  if (changedProperties.has('width') || changedProperties.has('height')) {
    this._resize();
  }
}
```
