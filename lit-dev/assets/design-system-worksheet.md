# Design System Planning Worksheet

Fill out this worksheet before building a Lit-based design system.

## 1. System Identity

| Field | Value |
|-------|-------|
| **System name** | |
| **CSS prefix** | (e.g., `ds-`, `acme-`) |
| **Tag prefix** | (e.g., `ds-button`, `acme-card`) |
| **Target consumers** | (internal team / open source / both) |
| **Package name** | (e.g., `@org/design-system`) |

## 2. Token Architecture

### Color Tokens

| Token | Light Value | Dark Value |
|-------|------------|------------|
| `--{prefix}-color-primary` | | |
| `--{prefix}-color-primary-hover` | | |
| `--{prefix}-color-bg` | | |
| `--{prefix}-color-surface` | | |
| `--{prefix}-color-text` | | |
| `--{prefix}-color-text-muted` | | |
| `--{prefix}-color-border` | | |
| `--{prefix}-color-error` | | |
| `--{prefix}-color-success` | | |
| `--{prefix}-color-warning` | | |

### Spacing Scale

| Token | Value |
|-------|-------|
| `--{prefix}-space-xs` | |
| `--{prefix}-space-sm` | |
| `--{prefix}-space-md` | |
| `--{prefix}-space-lg` | |
| `--{prefix}-space-xl` | |

### Typography

| Token | Value |
|-------|-------|
| `--{prefix}-font-sans` | |
| `--{prefix}-font-mono` | |
| `--{prefix}-text-xs` | |
| `--{prefix}-text-sm` | |
| `--{prefix}-text-base` | |
| `--{prefix}-text-lg` | |
| `--{prefix}-text-xl` | |
| `--{prefix}-text-2xl` | |

### Border Radii

| Token | Value |
|-------|-------|
| `--{prefix}-radius-sm` | |
| `--{prefix}-radius-md` | |
| `--{prefix}-radius-lg` | |
| `--{prefix}-radius-full` | |

### Shadows

| Token | Value |
|-------|-------|
| `--{prefix}-shadow-sm` | |
| `--{prefix}-shadow-md` | |
| `--{prefix}-shadow-lg` | |

## 3. Component Inventory

### Atomic Components (no dependencies)

| Component | Tag | Priority | Properties | Events | Slots |
|-----------|-----|----------|------------|--------|-------|
| Button | | | | | |
| Input | | | | | |
| Badge | | | | | |
| Icon | | | | | |
| | | | | | |

### Composite Components (depend on atomics)

| Component | Tag | Uses | Priority | Properties | Events | Slots |
|-----------|-----|------|----------|------------|--------|-------|
| Card | | | | | | |
| Dialog | | | | | | |
| Form | | | | | | |
| Nav | | | | | | |
| | | | | | | |

## 4. Shared Behaviors

### Controllers Needed

| Controller | Purpose | Used By |
|-----------|---------|---------|
| | | |
| | | |

### Mixins Needed

| Mixin | Purpose | Used By |
|-------|---------|---------|
| | | |
| | | |

### Shared Style Modules

| Module | Contains | Used By |
|--------|----------|---------|
| reset | Box-sizing, font inheritance | All |
| | | |
| | | |

## 5. Context Dependencies

| Context | Type | Provider | Consumers |
|---------|------|----------|-----------|
| Theme | `'light' \| 'dark'` | theme-provider | All themed components |
| | | | |

## 6. Build & Distribution

| Decision | Choice |
|----------|--------|
| **Bundler** | (Rollup / Vite / esbuild / none) |
| **Testing** | (Web Test Runner / Vitest Browser / WebdriverIO) |
| **Registry** | (npm / GitHub Packages / private) |
| **Bundle for consumers?** | No (consumers bundle) |
| **Minify for consumers?** | No (consumers optimize) |
| **Include polyfills?** | No (app-level concern) |
| **CEM generation?** | (Yes / No) |
| **Storybook?** | (Yes / No) |
| **React wrappers?** | (Yes / No — via @lit/react) |

## 7. Theme Strategy

| Decision | Choice |
|----------|--------|
| **Theme switching method** | (Context / CSS class / media query) |
| **Number of themes** | (light+dark / light+dark+high-contrast / custom) |
| **Token organization** | (primitive+semantic / flat) |
| **Custom property prefix** | |

## 8. Accessibility Checklist

- [ ] All interactive elements keyboard accessible
- [ ] ARIA roles and states on custom widgets
- [ ] Focus management for modals/dialogs
- [ ] Color contrast meets WCAG AA (4.5:1 text, 3:1 large text)
- [ ] `prefers-reduced-motion` respected
- [ ] `prefers-color-scheme` supported
- [ ] Screen reader testing planned
- [ ] axe-core in test suite
