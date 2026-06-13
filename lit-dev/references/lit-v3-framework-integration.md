# Lit v3 Framework Integration

React wrappers via `@lit/react`, Angular setup, Vue configuration, and the `useController()` hook.

## React Integration (@lit/react)

### Why a Wrapper is Needed

React has fundamental mismatches with web components:
- React assumes all JSX props map to HTML attributes (not properties)
- Complex data (objects, arrays) can't be passed via attributes
- React's synthetic event system doesn't work with custom element events
- Without the wrapper, developers must use `ref()` and imperative DOM calls

React 19 improves native custom element support, but `@lit/react` still provides better TypeScript typing and event mapping.

### Installation

```bash
npm i @lit/react
```

### createComponent() Wrapper

```typescript
import React from 'react';
import {createComponent} from '@lit/react';
import {MyElement} from './my-element.js';

export const MyElementComponent = createComponent({
  tagName: 'my-element',
  elementClass: MyElement,
  react: React,
  events: {
    onactivate: 'activate',
    onchange: 'change',
  },
});
```

Usage in React:

```tsx
function App() {
  const [isActive, setIsActive] = useState(false);

  return (
    <MyElementComponent
      active={isActive}
      items={complexArray}
      onactivate={(e) => setIsActive(e.detail.active)}
    />
  );
}
```

### Type-Safe Events

```typescript
import {createComponent, type EventName} from '@lit/react';

export const MyElementComponent = createComponent({
  tagName: 'my-element',
  elementClass: MyElement,
  react: React,
  events: {
    'onmy-event': 'my-event' as EventName<MyCustomEvent>,
  },
});
```

### Named Slots in React

React components need a wrapper div for slotted content. Use `display: contents` to avoid layout interference:

```tsx
<MyElementComponent>
  <div slot="header" style={{display: 'contents'}}>
    <ReactHeader />
  </div>
  <p>Default slot content</p>
</MyElementComponent>
```

### useController() Hook

Adapt Lit reactive controllers for React function components:

```typescript
import {useController} from '@lit/react/use-controller.js';
import {MouseController} from './mouse-controller.js';

function useMouse() {
  const controller = useController(React, (host) => new MouseController(host));
  return controller.pos;
}

function MyReactComponent() {
  const pos = useMouse();
  return <p>Mouse: {pos.x}, {pos.y}</p>;
}
```

This enables sharing controller logic between Lit and React components — write once, use in both.

---

## Angular Integration

### Setup

Add `CUSTOM_ELEMENTS_SCHEMA` to your module or component:

```typescript
// Module-level
import {NgModule, CUSTOM_ELEMENTS_SCHEMA} from '@angular/core';

@NgModule({
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
})
export class AppModule {}

// Standalone component
@Component({
  standalone: true,
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
  template: `<my-element [name]="userName" (status-changed)="onStatus($event)"></my-element>`,
})
export class AppComponent {
  userName = 'Angular';
  onStatus(event: CustomEvent) {
    console.log(event.detail);
  }
}
```

### Property Binding

```html
<!-- Attribute binding -->
<my-element name="static"></my-element>

<!-- Property binding (passes JS values) -->
<my-element [items]="itemsArray" [config]="configObject"></my-element>

<!-- Event binding -->
<my-element (item-selected)="onSelect($event)"></my-element>

<!-- Two-way (with custom event) -->
<my-element [value]="val" (value-changed)="val = $event.detail.value"></my-element>
```

### No Wrapper Needed

Unlike React, Angular's template syntax natively supports:
- Property binding via `[prop]`
- Event binding via `(event-name)`
- Attribute binding via `attr.name`

No special wrapper library required.

---

## Vue Integration

### Vite Configuration

Tell Vue to skip custom elements (don't try to resolve them as Vue components):

```typescript
// vite.config.ts
import {defineConfig} from 'vite';
import vue from '@vitejs/plugin-vue';

export default defineConfig({
  plugins: [
    vue({
      template: {
        compilerOptions: {
          isCustomElement: (tag) => tag.includes('-'),
        },
      },
    }),
  ],
});
```

### Usage in Vue Templates

```vue
<template>
  <my-element
    :name="userName"
    :items="itemsArray"
    @item-selected="onSelect"
  ></my-element>
</template>

<script setup lang="ts">
import './my-element.js';
import {ref} from 'vue';

const userName = ref('Vue');
const itemsArray = ref([{id: 1, name: 'Item 1'}]);

function onSelect(e: CustomEvent) {
  console.log(e.detail);
}
</script>
```

Vue 3 handles web components well out of the box:
- `:prop` syntax sets properties (not just attributes)
- `@event` syntax works with custom events
- No wrapper library needed

---

## Framework Compatibility Summary

| Feature | React | Angular | Vue |
|---------|-------|---------|-----|
| Property binding | Wrapper needed | Native `[prop]` | Native `:prop` |
| Event binding | Wrapper needed | Native `(event)` | Native `@event` |
| Complex data (objects, arrays) | Via wrapper | Via `[prop]` | Via `:prop` |
| Type safety | Via wrapper types | Via schema | Via `defineCustomElement` |
| Wrapper library | `@lit/react` | None | None |
| SSR support | Via `@lit-labs/nextjs` | Limited | Via `nuxt-ssr-lit` |

---

## Vanilla HTML/JS

No framework needed — web components work natively:

```html
<script type="module">
  import './my-element.js';
</script>

<my-element name="Vanilla" count="5"></my-element>

<script>
  const el = document.querySelector('my-element');
  el.items = [{id: 1, name: 'Item'}]; // property
  el.addEventListener('item-selected', (e) => {
    console.log(e.detail);
  });
</script>
```
