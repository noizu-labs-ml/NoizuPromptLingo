# Lit v3 Templates & Directives

Complete reference for expression types, all 20 built-in directives, static templates, and template composition patterns.

## Expression Types

Lit templates use tagged template literals with six expression types, each with distinct syntax.

### Child Expressions

```typescript
html`<h1>Hello ${name}</h1>`
```

Accepted values:
- **Primitives** — strings, numbers rendered as text
- **`TemplateResult`** — nested `html`\`...\`` templates
- **DOM nodes** — inserted directly (removed from previous location)
- **Arrays/iterables** — each item rendered (can mix types)
- **`nothing`** — renders no nodes
- **`noChange`** — leaves current value (directives only)

`null`, `undefined`, and empty string render nothing. Booleans render as their string representation (`"true"`, `"false"`).

### Attribute Expressions

```typescript
html`<div class=${this.textClass}>Text</div>`
html`<img src="/images/${this.image}">`
```

Values converted to strings. Use `nothing` sentinel to remove the attribute entirely:

```typescript
import {nothing} from 'lit';
html`<img src=${this.src || nothing}>`;
```

### Boolean Attribute Expressions

```typescript
html`<div ?hidden=${!this.showAdditional}>Text</div>`
html`<button ?disabled=${this.isDisabled}>Click</button>`
```

Prefix: `?`. Truthy adds the attribute; falsy removes it.

### Property Expressions

```typescript
html`<input .value=${this.itemCount}>`
html`<my-list .listItems=${this.items}></my-list>`
```

Prefix: `.`. Passes any JS value (objects, arrays, functions). Case-sensitive (unlike attributes).

### Event Listener Expressions

```typescript
html`<button @click=${this.clickHandler}>Click</button>`
```

Prefix: `@`. Accepts:
- Plain functions (auto-bound to component instance in LitElement)
- Objects with `handleEvent` method (for listener options without decorators):

```typescript
html`<button @click=${{handleEvent: () => this.onClick(), once: true}}>click</button>`
```

Remove listener by passing `nothing`:

```typescript
html`<button @click=${this.active ? this._handler : nothing}>Click</button>`
```

### Element Expressions

```typescript
html`<div ${ref(this.myRef)}></div>`
```

Placed in the opening tag after the tag name. Only directives work here.

---

## Static Expressions

For dynamic tag names and attribute names that rarely change:

```typescript
import {html, literal, unsafeStatic} from 'lit/static-html.js';

// literal — for trusted, cacheable values
const tag = literal`button`;
html`<${tag}>Click</${tag}>`;

// unsafeStatic — for trusted dynamic strings (XSS risk with untrusted input!)
html`<${unsafeStatic(tagName)}>...</${unsafeStatic(tagName)}>`;
```

Changing `literal` values is expensive — triggers full template re-parse. Use only for values that change rarely (e.g., tag name based on a prop that changes once).

---

## Invalid Expression Locations

Expressions **cannot** appear in:
- Tag names or attribute names (use static expressions)
- `<template>` element content
- `<textarea>` element content (use `.value` property instead)
- Inside HTML comments
- `<style>` elements (when using ShadyCSS polyfill)
- `contenteditable` element content (use `.innerText` property)

---

## Built-in Directives

All imported from `lit/directives/*.js`.

### Styling Directives

#### classMap

Dynamic CSS classes from an object:

```typescript
import {classMap} from 'lit/directives/class-map.js';

render() {
  const classes = {enabled: this.enabled, hidden: false, active: this.active};
  return html`<div class=${classMap(classes)}>Classy text</div>`;
}
```

**Gotcha**: Must be the only expression in the `class` attribute. Cannot combine with a static class string in the same attribute.

#### styleMap

Inline styles from an object:

```typescript
import {styleMap} from 'lit/directives/style-map.js';

render() {
  const styles = {backgroundColor: this.bg, color: 'white', '--custom-color': 'steelblue'};
  return html`<p style=${styleMap(styles)}>Hello style!</p>`;
}
```

- Use camelCase for dashed properties (`fontFamily` for `font-family`)
- CSS custom properties require quoted keys: `{'--custom-color': 'steelblue'}`

---

### Conditional Directives

#### when

Binary template selection (cleaner ternary):

```typescript
import {when} from 'lit/directives/when.js';

render() {
  return html`${when(this.user,
    () => html`User: ${this.user!.username}`,
    () => html`Sign In...`
  )}`;
}
```

#### choose

Multi-case template selection (switch-like):

```typescript
import {choose} from 'lit/directives/choose.js';

render() {
  return html`${choose(this.section, [
    ['home', () => html`<h1>Home</h1>`],
    ['about', () => html`<h1>About</h1>`],
    ['contact', () => html`<h1>Contact</h1>`]
  ], () => html`<h1>Not Found</h1>`)}`;
}
```

Uses strict equality; first match wins.

---

### List/Iteration Directives

#### map

Transform iterables without DOM diffing:

```typescript
import {map} from 'lit/directives/map.js';

render() {
  return html`<ul>${map(this.items, (item) => html`<li>${item}</li>`)}</ul>`;
}
```

#### repeat

Keyed list rendering with stable DOM identity:

```typescript
import {repeat} from 'lit/directives/repeat.js';

render() {
  return html`<ul>${repeat(this.employees,
    (emp) => emp.id,
    (emp, index) => html`<li>${index}: ${emp.name}</li>`
  )}</ul>`;
}
```

**When to use `repeat` vs `map`:**

| Scenario | Use |
|----------|-----|
| Large lists with frequent reordering | `repeat()` with keys |
| DOM items have uncontrolled state (checkbox, focus, animation) | `repeat()` with keys |
| Simple render, no reordering | `map()` or `Array.map()` |
| Simplicity is priority | `map()` or `Array.map()` |

Key difference: `map()` reassigns values to existing DOM nodes. `repeat()` reorders existing DOM nodes to match new data order.

#### join

Interleave separators between items:

```typescript
import {join} from 'lit/directives/join.js';
import {map} from 'lit/directives/map.js';

render() {
  return html`${join(
    map(this.menuItems, (i) => html`<a href=${i.href}>${i.label}</a>`),
    html`<span class="separator">|</span>`
  )}`;
}
```

#### range

Generate numeric sequences:

```typescript
import {range} from 'lit/directives/range.js';
import {map} from 'lit/directives/map.js';

// range(end) — 0 to end-1
html`${map(range(5), (i) => html`<star-icon ?filled=${i < this.rating}></star-icon>`)}`

// range(start, end, step)
html`${map(range(0, 100, 10), (i) => html`<option>${i}%</option>`)}`
```

---

### Attribute Directives

#### ifDefined

Set attribute only when value is defined:

```typescript
import {ifDefined} from 'lit/directives/if-defined.js';

render() {
  return html`<img src="/images/${ifDefined(this.filename)}">`;
}
```

Removes the attribute entirely when value is `undefined` or `null`.

---

### Performance/Caching Directives

#### cache

Preserve DOM when switching between templates:

```typescript
import {cache} from 'lit/directives/cache.js';

render() {
  return html`${cache(this.showDetails
    ? html`<detail-view .data=${this.data}></detail-view>`
    : html`<summary-view .data=${this.data}></summary-view>`
  )}`;
}
```

Useful for expensive views that toggle frequently. Caches DOM per template identity.

#### keyed

Force DOM replacement when key changes (opposite of `cache`):

```typescript
import {keyed} from 'lit/directives/keyed.js';

render() {
  return html`${keyed(this.userId, html`<user-card .userId=${this.userId}></user-card>`)}`;
}
```

Opts out of Lit's default DOM reuse. Clears all element state (form values, scroll position, animation state) on key change.

#### guard

Skip re-evaluation unless dependencies change:

```typescript
import {guard} from 'lit/directives/guard.js';

render() {
  return html`<div>${guard([this.value], () => expensiveComputation(this.value))}</div>`;
}
```

Checks identity (reference equality), not deep equality.

#### live

Compare against live DOM value instead of last-rendered value:

```typescript
import {live} from 'lit/directives/live.js';

render() {
  return html`<input .value=${live(this.data.value)}>`;
}
```

Essential for form inputs where the DOM value may diverge from component state (user types, then component re-renders with stale value).

---

### DOM Reference Directive

#### ref

Get element references imperatively:

```typescript
import {ref, createRef} from 'lit/directives/ref.js';

inputRef = createRef<HTMLInputElement>();

render() {
  return html`<input ${ref(this.inputRef)}>`;
}

firstUpdated() {
  this.inputRef.value!.focus();
}
```

Also accepts a callback:

```typescript
html`<input ${ref((el) => el?.focus())}>`
```

Callbacks receive `undefined` when the element is removed from the DOM.

---

### Async Directives

#### until

Placeholder until promises resolve:

```typescript
import {until} from 'lit/directives/until.js';

render() {
  return html`${until(
    this.fetchData(),
    html`<span>Loading...</span>`
  )}`;
}
```

Values prioritized left to right — first resolved promise or non-promise value displays.

#### asyncAppend

Accumulate values from async iterables:

```typescript
import {asyncAppend} from 'lit/directives/async-append.js';

render() {
  return html`<ul>${asyncAppend(this.logStream, (entry) => html`<li>${entry}</li>`)}</ul>`;
}
```

#### asyncReplace

Show only the latest value from async iterables:

```typescript
import {asyncReplace} from 'lit/directives/async-replace.js';

render() {
  return html`Timer: <span>${asyncReplace(this.countdown)}</span>`;
}
```

---

### Unsafe Rendering Directives

#### unsafeHTML / unsafeSVG

Render trusted strings as HTML/SVG:

```typescript
import {unsafeHTML} from 'lit/directives/unsafe-html.js';

render() {
  return html`${unsafeHTML(this.trustedMarkup)}`;
}
```

**Security**: Only use with developer-controlled strings. Never use with user input — XSS vulnerability.

#### templateContent

Clone and render an HTML `<template>` element:

```typescript
import {templateContent} from 'lit/directives/template-content.js';

const tpl = document.querySelector('template#myContent') as HTMLTemplateElement;
render() {
  return html`${templateContent(tpl)}`;
}
```

---

## Template Composition Patterns

### Private Render Methods

Break complex templates into focused methods:

```typescript
render() {
  return html`
    ${this._renderHeader()}
    ${this._renderBody()}
    ${this._renderFooter()}
  `;
}

private _renderHeader() {
  return html`<header>${this.title}</header>`;
}
```

### Standalone Template Functions

Importable across components — no `this` binding:

```typescript
// shared-templates.ts
export const userBadge = (user: User) =>
  html`<span class="badge">${user.name} (${user.role})</span>`;

// component.ts
import {userBadge} from './shared-templates.js';

render() {
  return html`<div>${userBadge(this.user)}</div>`;
}
```

### Slot-Based Composition

Let consumers provide content:

```typescript
render() {
  return html`
    <div class="card">
      <slot name="header"><h2>Default Header</h2></slot>
      <slot></slot>
      <slot name="footer"></slot>
    </div>
  `;
}
```

---

## Directive Summary Table

| Directive | Category | Key Use Case |
|-----------|----------|-------------|
| `classMap` | Styling | Dynamic CSS classes from objects |
| `styleMap` | Styling | Inline styles from objects |
| `when` | Conditional | Binary template selection |
| `choose` | Conditional | Multi-case template selection |
| `map` | List | Transform iterables without diffing |
| `repeat` | List | Keyed list rendering with DOM stability |
| `join` | List | Interleave separators |
| `range` | List | Numeric sequence generation |
| `ifDefined` | Attribute | Conditional attribute presence |
| `cache` | Performance | Preserve DOM across template switches |
| `keyed` | Performance | Force element replacement on key change |
| `guard` | Performance | Skip re-evaluation unless deps change |
| `live` | Sync | Compare against live DOM value |
| `ref` | DOM | Imperative element references |
| `until` | Async | Placeholder until promise resolves |
| `asyncAppend` | Async | Accumulate async iterable values |
| `asyncReplace` | Async | Replace with latest async value |
| `unsafeHTML` | Unsafe | Render trusted HTML strings |
| `unsafeSVG` | Unsafe | Render trusted SVG strings |
| `templateContent` | HTML | Clone `<template>` elements |
