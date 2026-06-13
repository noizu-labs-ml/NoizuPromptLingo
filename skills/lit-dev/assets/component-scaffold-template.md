# Component Scaffold Templates

Copy-paste scaffolds for common Lit v3 component patterns.

## Basic Component

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property, state} from 'lit/decorators.js';

@customElement('my-component')
export class MyComponent extends LitElement {
  static styles = css`
    :host {
      display: block;
    }
  `;

  @property({type: String}) label = '';

  render() {
    return html`
      <div>${this.label}</div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-component': MyComponent;
  }
}
```

---

## Interactive Component (with Events)

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property, state} from 'lit/decorators.js';
import {classMap} from 'lit/directives/class-map.js';

@customElement('my-toggle')
export class MyToggle extends LitElement {
  static styles = css`
    :host { display: inline-block; }
    .toggle { /* styles */ }
    .toggle--active { /* active styles */ }
  `;

  @property({type: Boolean, reflect: true}) active = false;
  @property({type: Boolean, reflect: true}) disabled = false;

  render() {
    return html`
      <button
        class=${classMap({toggle: true, 'toggle--active': this.active})}
        ?disabled=${this.disabled}
        role="switch"
        aria-checked=${this.active}
        @click=${this._handleClick}
      >
        <slot></slot>
      </button>
    `;
  }

  private _handleClick() {
    if (this.disabled) return;
    this.active = !this.active;
    this.dispatchEvent(new CustomEvent('toggle-changed', {
      detail: {active: this.active},
      bubbles: true,
      composed: true,
    }));
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-toggle': MyToggle;
  }
}
```

---

## Component with Slots

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property} from 'lit/decorators.js';

@customElement('my-card')
export class MyCard extends LitElement {
  static styles = css`
    :host { display: block; }
    .card {
      border: 1px solid var(--card-border, #e5e7eb);
      border-radius: var(--card-radius, 8px);
      overflow: hidden;
    }
    .header { padding: 16px; border-bottom: 1px solid var(--card-border, #e5e7eb); }
    .body { padding: 16px; }
    .footer { padding: 16px; border-top: 1px solid var(--card-border, #e5e7eb); }
  `;

  render() {
    return html`
      <div class="card">
        <div class="header"><slot name="header"></slot></div>
        <div class="body"><slot></slot></div>
        <div class="footer"><slot name="footer"></slot></div>
      </div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-card': MyCard;
  }
}
```

---

## Component with Task (Async Data)

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import {Task} from '@lit/task';

interface DataItem {
  id: string;
  name: string;
}

@customElement('my-data-list')
export class MyDataList extends LitElement {
  static styles = css`
    :host { display: block; }
    .loading { color: var(--color-muted, #666); }
    .error { color: var(--color-error, #ef4444); }
  `;

  @property() endpoint = '';

  private _data = new Task(this, {
    task: async ([endpoint], {signal}) => {
      const res = await fetch(endpoint, {signal});
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      return res.json() as Promise<DataItem[]>;
    },
    args: () => [this.endpoint],
  });

  render() {
    return this._data.render({
      initial: () => html`<p class="loading">Waiting for endpoint...</p>`,
      pending: () => html`<p class="loading">Loading...</p>`,
      complete: (items) => html`
        <ul>${items.map(item => html`<li>${item.name}</li>`)}</ul>
      `,
      error: (e) => html`<p class="error">Error: ${e}</p>`,
    });
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-data-list': MyDataList;
  }
}
```

---

## Component with Context Consumer

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property} from 'lit/decorators.js';
import {consume} from '@lit/context';
import {themeContext, type Theme} from './theme-context.js';

@customElement('my-themed-widget')
export class MyThemedWidget extends LitElement {
  static styles = css`
    :host { display: block; }
  `;

  @consume({context: themeContext, subscribe: true})
  @property({attribute: false})
  theme!: Theme;

  render() {
    return html`<p>Current theme: ${this.theme}</p>`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-themed-widget': MyThemedWidget;
  }
}
```

---

## Component with Reactive Controller

```typescript
import {LitElement, html, css} from 'lit';
import {customElement} from 'lit/decorators.js';
import type {ReactiveController, ReactiveControllerHost} from 'lit';

class IntervalController implements ReactiveController {
  private _timer?: ReturnType<typeof setInterval>;
  value = 0;

  constructor(
    private host: ReactiveControllerHost,
    private interval: number
  ) {
    this.host.addController(this);
  }

  hostConnected() {
    this._timer = setInterval(() => {
      this.value++;
      this.host.requestUpdate();
    }, this.interval);
  }

  hostDisconnected() {
    clearInterval(this._timer);
  }
}

@customElement('my-counter')
export class MyCounter extends LitElement {
  static styles = css`:host { display: block; }`;

  private _counter = new IntervalController(this, 1000);

  render() {
    return html`<p>Count: ${this._counter.value}</p>`;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-counter': MyCounter;
  }
}
```

---

## Component with Signals

```typescript
import {LitElement, css} from 'lit';
import {customElement} from 'lit/decorators.js';
import {SignalWatcher, html, signal} from '@lit-labs/signals';

const count = signal(0);

@customElement('my-signal-counter')
export class MySignalCounter extends SignalWatcher(LitElement) {
  static styles = css`:host { display: block; }`;

  render() {
    return html`
      <p>Count: ${count}</p>
      <button @click=${() => count.set(count.get() + 1)}>Increment</button>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-signal-counter': MySignalCounter;
  }
}
```

---

## Form Component (with live directive)

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property, state} from 'lit/decorators.js';
import {live} from 'lit/directives/live.js';

@customElement('my-input')
export class MyInput extends LitElement {
  static styles = css`
    :host { display: block; }
    input {
      width: 100%;
      padding: 8px 12px;
      border: 1px solid var(--input-border, #d1d5db);
      border-radius: 4px;
      font: inherit;
    }
    input:focus {
      outline: 2px solid var(--input-focus, #3b82f6);
      outline-offset: -1px;
    }
    .error { color: var(--color-error, #ef4444); font-size: 0.875rem; }
  `;

  @property() value = '';
  @property() placeholder = '';
  @property() label = '';
  @property() error = '';
  @property({type: Boolean, reflect: true}) required = false;

  render() {
    return html`
      ${this.label ? html`<label>${this.label}</label>` : ''}
      <input
        .value=${live(this.value)}
        placeholder=${this.placeholder}
        ?required=${this.required}
        @input=${this._onInput}
      >
      ${this.error ? html`<p class="error">${this.error}</p>` : ''}
    `;
  }

  private _onInput(e: InputEvent) {
    const input = e.target as HTMLInputElement;
    this.value = input.value;
    this.dispatchEvent(new CustomEvent('value-changed', {
      detail: {value: this.value},
      bubbles: true,
      composed: true,
    }));
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-input': MyInput;
  }
}
```
