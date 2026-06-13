# Lit v3 Reactive Properties

Deep reference for `@property()`, `@state()`, converters, change detection, and the attribute-property bridge.

## @property — Public Reactive Properties

Public API surface of the component. Syncs with HTML attributes by default.

```typescript
@property({type: String}) mode?: string;
@property({attribute: false}) data = {};
@property({type: Number, reflect: true}) count = 0;
```

### Property Options

| Option | Default | Purpose |
|--------|---------|---------|
| `type` | `String` | Built-in converter type (String, Number, Boolean, Object, Array) |
| `attribute` | `true` | Associates with HTML attribute. `false` to disable, string for custom name |
| `reflect` | `false` | Write property changes back to the HTML attribute |
| `converter` | built-in | Custom attribute↔property conversion logic |
| `hasChanged` | `!==` (strict inequality) | Custom change detection function |
| `noAccessor` | `false` | Prevent Lit from generating getter/setter |
| `useDefault` | `false` | Reset to default when attribute removed; prevent initial default reflection |

### Built-in Type Converters

| Type | Attribute → Property | Property → Attribute |
|------|---------------------|---------------------|
| `String` | Identity | Identity |
| `Number` | `Number(attr)` | `String(prop)` |
| `Boolean` | Attribute present = `true`, absent = `false` | `true` adds attribute, `false` removes |
| `Object` | `JSON.parse(attr)` | `JSON.stringify(prop)` |
| `Array` | `JSON.parse(attr)` | `JSON.stringify(prop)` |

### Boolean Properties

Boolean properties **must default to `false`** to work correctly from HTML markup:

```typescript
// CORRECT
@property({type: Boolean}) disabled = false;
// Usage: <my-el disabled></my-el>  → true
// Usage: <my-el></my-el>           → false

// WRONG — no way to set false from markup
@property({type: Boolean}) enabled = true;
```

---

## @state — Internal Reactive State

Triggers re-render but is not part of the component's public API. No corresponding HTML attribute.

```typescript
@state() private _active = false;
@state() protected _items: Item[] = [];
```

Use `@state()` for:
- Derived/computed values
- UI state (open/closed, selected index)
- Internal data that consumers shouldn't set

---

## Custom Converters

For complex attribute↔property transformations:

```typescript
// Full converter object
@property({
  converter: {
    fromAttribute(value: string | null, type?: unknown): Date | null {
      return value ? new Date(value) : null;
    },
    toAttribute(value: Date | null, type?: unknown): string | null {
      return value?.toISOString() ?? null;
    }
  }
})
date: Date | null = null;

// Shorthand (fromAttribute only — no reflect support)
@property({
  converter: (value: string | null) => value ? parseInt(value, 16) : 0
})
hexValue = 0;
```

---

## Custom hasChanged

Control when a property change triggers an update:

```typescript
// Case-insensitive string comparison
@property({
  hasChanged(newVal: string, oldVal: string) {
    return newVal?.toLowerCase() !== oldVal?.toLowerCase();
  }
})
mode = 'default';

// Deep equality for objects
@property({
  hasChanged(newVal: Config, oldVal: Config) {
    return JSON.stringify(newVal) !== JSON.stringify(oldVal);
  }
})
config: Config = {theme: 'light'};
```

---

## Custom Accessors

Add validation, transformation, or side effects to property access:

```typescript
private _prop = 0;

@property()
set prop(val: number) {
  this._prop = Math.floor(val); // clamp to integer
}
get prop() {
  return this._prop;
}
```

With experimental decorators, the decorated setter automatically calls `requestUpdate()`.

With standard TC39 decorators, use `accessor`:

```typescript
// Standard decorators — accessor does the reactive plumbing
@property() accessor name = 'World';
```

For custom setters with standard decorators, apply `@property()` to the setter directly:

```typescript
private _foo = 42;

@property()
set foo(v: number) { this._foo = v; }
get foo() { return this._foo; }
```

---

## Static Properties (No Decorators)

```typescript
export class MyElement extends LitElement {
  static properties = {
    name: {type: String},
    count: {type: Number, reflect: true},
    data: {attribute: false},
    mode: {
      type: String,
      hasChanged(newVal: string, oldVal: string) {
        return newVal !== oldVal;
      }
    },
  };

  constructor() {
    super();
    // Defaults MUST be set in constructor when using static properties
    this.name = 'World';
    this.count = 0;
    this.data = {};
    this.mode = 'light';
  }
}
```

---

## Attribute Name Mapping

```typescript
// Default: lowercase property name
@property() myProp;        // attribute: "myprop"

// Custom attribute name
@property({attribute: 'my-prop'}) myProp;  // attribute: "my-prop"

// No attribute
@property({attribute: false}) data;  // no attribute mapping
```

---

## Reflection

Writing property values back to attributes (for CSS selectors, accessibility):

```typescript
@property({type: Boolean, reflect: true}) active = false;
// When active = true:  <my-el active></my-el>
// When active = false: <my-el></my-el>

@property({type: String, reflect: true}) status = 'idle';
// <my-el status="idle"></my-el>
// CSS: my-el[status="active"] { ... }
```

Avoid reflecting frequently-changing properties (performance cost of setAttribute on every update).

---

## Mutating Objects and Arrays

Mutations don't trigger updates because the reference is unchanged:

```typescript
// DOES NOT TRIGGER UPDATE
this.items.push(newItem);

// TRIGGERS UPDATE — immutable pattern
this.items = [...this.items, newItem];

// TRIGGERS UPDATE — manual requestUpdate
this.items.push(newItem);
this.requestUpdate();

// TRIGGERS UPDATE — replace reference
this.config = {...this.config, theme: 'dark'};
```

Prefer immutable patterns. Use `requestUpdate()` as a last resort.

---

## changedProperties Map

Available in lifecycle methods. Keys are property names; values are **previous** values.

```typescript
willUpdate(changedProperties: PropertyValues) {
  // Check if a specific property changed
  if (changedProperties.has('firstName')) {
    const oldFirstName = changedProperties.get('firstName');
    console.log(`firstName changed from ${oldFirstName} to ${this.firstName}`);
  }
}
```

The `PropertyValues` type is `Map<string, unknown>` (or `Map<PropertyKey, unknown>` more precisely).

---

## Property Metadata

Access property options at runtime:

```typescript
// Get all declared properties
const props = MyElement.elementProperties;
// Map<PropertyKey, PropertyDeclaration>

// Check a specific property's options
const countOpts = MyElement.elementProperties.get('count');
// {type: Number, reflect: true, ...}
```
