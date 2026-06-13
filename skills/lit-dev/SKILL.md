---
name: trl-lit-dev
description: >
  Design and implement production-ready Lit v3 web components, from single elements
  through full design systems. Use this skill when the user wants to build a web
  component with Lit, create a custom element, design a component library, implement
  reactive properties, use Shadow DOM, add context or signals, set up Lit SSR, test
  web components, publish a component package, integrate Lit with React or Angular,
  migrate from Lit 2 to Lit 3, or architect a design system with Lit — even if they
  don't say "Lit" or "web component." Also trigger when users mention LitElement,
  lit-html, @customElement, reactive properties, Shadow DOM styling, :host selector,
  css tagged template, html tagged template, @property decorator, @state decorator,
  Constructable Stylesheets, Custom Elements, @lit/context, @lit/task, @lit-labs/signals,
  @lit-labs/ssr, lit/directives, or web component design patterns.
---

# Lit Web Component Designer

Design methodology and comprehensive API reference for building production-ready web components with Lit v3. Covers single elements through full design systems, with deep reference documentation sourced from lit.dev post-training.

## Overview

This skill transforms component requirements into production-ready Lit v3 web components through a structured, standards-first methodology. It provides:

- **Complete Lit v3 API reference** — Core API, decorators, lifecycle, reactive properties, templates, directives, styles, events, Shadow DOM, context, tasks, signals
- **Component design patterns** — Composition, mixins, reactive controllers, slot-based architecture
- **Design system architecture** — Token systems, theme switching, component libraries with CSS custom properties
- **Testing and publishing** — Web Test Runner setup, production builds, npm package publishing
- **Framework integration** — React wrappers via @lit/react, Angular compatibility
- **Migration guidance** — Lit 2 to Lit 3 upgrade path with breaking change inventory

## Core Philosophy

**Five Principles:**

1. **Standards-first** — Web components are a web standard; Lit adds minimal abstraction over Custom Elements, Shadow DOM, and HTML templates
2. **Small surface area** — Lit is ~5 KB; components should be similarly lean — no framework-scale abstractions in component code
3. **Properties down, events up** — Data flows down via properties, changes propagate up via CustomEvents — never reach up or across
4. **Encapsulation by default** — Shadow DOM provides style and DOM encapsulation; break it only with explicit intent (CSS custom properties, slots)
5. **Reactive minimalism** — Declare what's reactive, let Lit batch and schedule updates — don't manage render timing manually

## When to Use This Skill

- **Building a single web component** — From `@customElement` through Shadow DOM, styles, events, and testing
- **Designing a component library** — Architecture for a multi-component system with shared tokens and styles
- **Implementing reactive data patterns** — Context protocol, async tasks, signals integration
- **Migrating from Lit 2 to Lit 3** — Breaking changes, decorator migration, SSR hydration changes
- **Integrating Lit into React/Angular** — Wrapper generation, event mapping, property binding
- **Publishing components to npm** — Package.json config, build pipeline, what NOT to bundle
- **Setting up component testing** — Web Test Runner, browser-based testing, shadow DOM queries
- **Understanding Lit internals** — Lifecycle, update batching, Constructable Stylesheets, template parsing

> For landing pages showcasing a component library, see **trl-user-experience-engineer** (`references/outputs/landing-pages.md`).
> For SEO optimization of component documentation sites, see **trl-seo-guru** (`kb/01-ai-seo-complete-guide.md`).
> For packaging components as sellable digital products, see **trl-ai-templates**.

## Lit v3 at a Glance

### What's New in Lit 3

| Feature | Details |
|---------|---------|
| **Standard TC39 Decorators** | Stage 3 decorators with `accessor` keyword alongside experimental decorators |
| **ES2021 output** | Published as ES2021 (was ES2019) — Webpack 4 needs Babel plugins |
| **Signals integration** | `@lit-labs/signals` — TC39 Signals Proposal support via `SignalWatcher` mixin |
| **Full Lit 2 interop** | Lit 2 and 3 components coexist — templates, base classes, directives cross-compatible |
| **Minimal breaking changes** | `UpdatingElement` removed, decorator imports changed, SSR hydration module moved |

### Package Map

| Package | Purpose | Status |
|---------|---------|--------|
| `lit` | Core: LitElement, html, css, decorators | Stable |
| `@lit/context` | Context protocol (provide/consume across shadow boundaries) | Stable |
| `@lit/task` | Async task management with status rendering | Stable |
| `@lit/react` | React wrapper generation for Lit components | Stable |
| `@lit/localize` | Localization with runtime or transform modes | Stable |
| `@lit-labs/signals` | TC39 Signals integration | Labs |
| `@lit-labs/ssr` | Server-side rendering | Labs |
| `@lit-labs/ssr-client` | Client-side hydration | Labs |

## Component Anatomy

Every Lit component follows the same structure:

```typescript
import {LitElement, html, css} from 'lit';
import {customElement, property, state} from 'lit/decorators.js';

@customElement('my-component')
export class MyComponent extends LitElement {
  // 1. Styles — static, shared via Constructable Stylesheets
  static styles = css`
    :host { display: block; }
  `;

  // 2. Reactive properties — public API
  @property({type: String}) label = '';
  @property({type: Boolean, reflect: true}) disabled = false;

  // 3. Internal state — triggers re-render but not public
  @state() private _count = 0;

  // 4. Lifecycle — setup/teardown
  connectedCallback() {
    super.connectedCallback();
  }

  // 5. Render — declarative template
  render() {
    return html`
      <button ?disabled=${this.disabled} @click=${this._onClick}>
        ${this.label} (${this._count})
      </button>
    `;
  }

  // 6. Event handlers — private methods
  private _onClick() {
    this._count++;
    this.dispatchEvent(new CustomEvent('count-changed', {
      detail: {count: this._count},
      bubbles: true,
      composed: true,
    }));
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'my-component': MyComponent;
  }
}
```

## Design Workflow

### Phase 1: Component Specification

| Activity | Output |
|----------|--------|
| Define component API (properties, events, slots, CSS custom properties) | API surface document |
| Choose composition strategy (inheritance, mixins, controllers, slots) | Architecture decision |
| Identify shared dependencies (contexts, controllers, style tokens) | Dependency map |

### Phase 2: Implementation

| Activity | Reference |
|----------|-----------|
| Scaffold component class | [component-scaffold-template.md](assets/component-scaffold-template.md) |
| Implement reactive properties | [lit-v3-reactive-properties.md](references/lit-v3-reactive-properties.md) |
| Build template with directives | [lit-v3-templates-directives.md](references/lit-v3-templates-directives.md) |
| Add styles with theming support | [lit-v3-styles.md](references/lit-v3-styles.md) |
| Wire lifecycle hooks | [lit-v3-lifecycle.md](references/lit-v3-lifecycle.md) |

### Phase 3: Integration

| Activity | Reference |
|----------|-----------|
| Add context providers/consumers | [lit-v3-context-tasks-signals.md](references/lit-v3-context-tasks-signals.md) |
| Implement composition patterns | [lit-v3-composition-patterns.md](references/lit-v3-composition-patterns.md) |
| Create React/Angular wrappers | [lit-v3-framework-integration.md](references/lit-v3-framework-integration.md) |

### Phase 4: Quality

| Activity | Reference |
|----------|-----------|
| Write browser-based tests | [lit-v3-testing-publishing.md](references/lit-v3-testing-publishing.md) |
| Configure production build | [lit-v3-testing-publishing.md](references/lit-v3-testing-publishing.md) |
| Publish to npm | [lit-v3-testing-publishing.md](references/lit-v3-testing-publishing.md) |

## Quick Reference: Expression Syntax

| Type | Syntax | Example |
|------|--------|---------|
| Child | `${expr}` | `html`\``<p>${this.name}</p>`\`` |
| Attribute | `attr=${expr}` | `html`\``<div class=${cls}></div>`\`` |
| Boolean | `?attr=${expr}` | `html`\``<div ?hidden=${!show}></div>`\`` |
| Property | `.prop=${expr}` | `html`\``<input .value=${val}>`\`` |
| Event | `@event=${handler}` | `html`\``<button @click=${this.go}>Go</button>`\`` |
| Element | `${directive()}` | `html`\``<div ${ref(myRef)}></div>`\`` |

## Quick Reference: Directives

| Directive | Category | Import |
|-----------|----------|--------|
| `classMap` | Styling | `lit/directives/class-map.js` |
| `styleMap` | Styling | `lit/directives/style-map.js` |
| `when` | Conditional | `lit/directives/when.js` |
| `choose` | Conditional | `lit/directives/choose.js` |
| `map` | List | `lit/directives/map.js` |
| `repeat` | List | `lit/directives/repeat.js` |
| `join` | List | `lit/directives/join.js` |
| `range` | List | `lit/directives/range.js` |
| `ifDefined` | Attribute | `lit/directives/if-defined.js` |
| `cache` | Performance | `lit/directives/cache.js` |
| `keyed` | Performance | `lit/directives/keyed.js` |
| `guard` | Performance | `lit/directives/guard.js` |
| `live` | Sync | `lit/directives/live.js` |
| `ref` | DOM | `lit/directives/ref.js` |
| `until` | Async | `lit/directives/until.js` |
| `asyncAppend` | Async | `lit/directives/async-append.js` |
| `asyncReplace` | Async | `lit/directives/async-replace.js` |
| `unsafeHTML` | Unsafe | `lit/directives/unsafe-html.js` |
| `unsafeSVG` | Unsafe | `lit/directives/unsafe-svg.js` |
| `templateContent` | HTML | `lit/directives/template-content.js` |

## Quick Reference: Lifecycle

```
Property change / requestUpdate()
  → shouldUpdate(changedProperties)
    → willUpdate(changedProperties)     ← runs in SSR
      → update(changedProperties)
        → render()                      ← runs in SSR
      → firstUpdated(changedProperties) ← first time only
      → updated(changedProperties)
        → updateComplete resolves
```

## Quick Reference: Decorator Summary

| Decorator | Purpose |
|-----------|---------|
| `@customElement('tag')` | Register custom element |
| `@property(opts?)` | Public reactive property with attribute sync |
| `@state()` | Internal reactive state (no attribute) |
| `@query(sel, cache?)` | querySelector on renderRoot |
| `@queryAll(sel)` | querySelectorAll on renderRoot |
| `@queryAsync(sel)` | Async query, resolves after render |
| `@queryAssignedElements(opts?)` | Elements assigned to a slot |
| `@queryAssignedNodes(opts?)` | Nodes assigned to a slot |
| `@eventOptions(opts)` | addEventListener options |

## Reference Guide

| Task | Read These |
|------|-----------|
| **Building any component** | `lit-v3-core-api.md`, `lit-v3-reactive-properties.md` |
| **Template logic and rendering** | `lit-v3-templates-directives.md` |
| **Component lifecycle** | `lit-v3-lifecycle.md` |
| **Styling and theming** | `lit-v3-styles.md` |
| **Shared state and async data** | `lit-v3-context-tasks-signals.md` |
| **Component architecture** | `lit-v3-composition-patterns.md` |
| **Testing and shipping** | `lit-v3-testing-publishing.md` |
| **Server rendering** | `lit-v3-ssr.md` |
| **Framework interop** | `lit-v3-framework-integration.md` |
| **Upgrading from Lit 2** | `lit-v3-migration.md` |
| **Full design system example** | `worked-example-design-system.md` |

## Related Skills

- **trl-user-experience-engineer** — Design landing pages and product pages for component library documentation
- **trl-skill-engineer** — Meta-skill for creating and evaluating skills
- **trl-ai-templates** — Package component libraries as sellable digital products
- **trl-seo-guru** — Optimize component library documentation for search engines

## Bundled Resources

### References

**Core API** (read first for any component work):
- [lit-v3-core-api.md](references/lit-v3-core-api.md) — LitElement, html, css, decorators, complete API surface
- [lit-v3-reactive-properties.md](references/lit-v3-reactive-properties.md) — @property, @state, converters, hasChanged, custom accessors
- [lit-v3-lifecycle.md](references/lit-v3-lifecycle.md) — Full lifecycle: construction through updateComplete, SSR considerations
- [lit-v3-templates-directives.md](references/lit-v3-templates-directives.md) — Expression types, all 20 built-in directives, static templates

**Styling and Architecture**:
- [lit-v3-styles.md](references/lit-v3-styles.md) — css tag, Shadow DOM selectors, CSS custom properties, shared styles, theming
- [lit-v3-composition-patterns.md](references/lit-v3-composition-patterns.md) — Slots, mixins, reactive controllers, mediator pattern, events

**Data and State**:
- [lit-v3-context-tasks-signals.md](references/lit-v3-context-tasks-signals.md) — @lit/context, @lit/task, @lit-labs/signals, SignalWatcher

**Integration and Deployment**:
- [lit-v3-testing-publishing.md](references/lit-v3-testing-publishing.md) — Web Test Runner, production Rollup config, npm publishing rules
- [lit-v3-ssr.md](references/lit-v3-ssr.md) — @lit-labs/ssr, hydration, framework integrations (Astro, Next.js, Eleventy)
- [lit-v3-framework-integration.md](references/lit-v3-framework-integration.md) — @lit/react createComponent, Angular setup, useController hook
- [lit-v3-migration.md](references/lit-v3-migration.md) — Lit 2 → 3 breaking changes, decorator migration, upgrade strategy

**Execution**:
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows

**Worked Examples**:
- [worked-example-design-system.md](references/worked-example-design-system.md) — End-to-end: building a themed design system with Lit v3

**External KB** (supplementary deep-dive articles in `components/docs/kb/`):
- [lit-v3-core-concepts.md](../../components/docs/kb/lit-v3-core-concepts.md) — Installation, setup, CDN usage, class fields gotcha
- [lit-v3-reactive-and-templates.md](../../components/docs/kb/lit-v3-reactive-and-templates.md) — Deep-dive on reactive update cycle and template composition
- [lit-v3-advanced-patterns.md](../../components/docs/kb/lit-v3-advanced-patterns.md) — Controllers+directives composition, typed events, bidirectional events
- [lit-v3-migration-and-whats-new.md](../../components/docs/kb/lit-v3-migration-and-whats-new.md) — Full release timeline, post-3.0 patches, anti-patterns, ecosystem libraries
- [lit-v3-ssr-tooling-ecosystem.md](../../components/docs/kb/lit-v3-ssr-tooling-ecosystem.md) — SSR execution contexts, bundler comparison, Vite HMR, testing ecosystem

### Assets

- [component-scaffold-template.md](assets/component-scaffold-template.md) — Copy-paste component scaffolds for common patterns
- [design-system-worksheet.md](assets/design-system-worksheet.md) — Planning worksheet for Lit-based design systems
