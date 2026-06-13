# therobotbrowses — Design Direction

## Style Selection

**Primary**: Nocturne (80%) — dark-native, data-dense, professional instrument feel
**Accent**: Minimal Tech (20%) — clean typography, monochrome + single accent, competence signal

### Rationale

A browser built for developers, researchers, and AI agents is a professional tool. Nocturne provides the dark-native canvas that power users expect (code editors, terminal emulators, IDEs are all dark-first). Minimal Tech accent keeps the chrome restrained and signals technical sophistication without the boldness that would distract from web content.

## Visual Identity

### Color Palette

| Token | Value | Usage |
|-------|-------|-------|
| `bg-primary` | `#0d1117` | Main background (browser chrome) |
| `bg-secondary` | `#161b22` | Panels, sidebars, tab bar |
| `bg-surface` | `#21262d` | Cards, dropdowns, menus |
| `bg-content` | `#ffffff` | Web content viewport (respects page styles) |
| `text-primary` | `#e6edf3` | Primary text |
| `text-secondary` | `#8b949e` | Secondary text, labels |
| `text-muted` | `#484f58` | Disabled, placeholder |
| `accent` | `#58a6ff` | Links, active states, focus rings |
| `accent-hover` | `#79c0ff` | Hover states |
| `success` | `#3fb950` | Security OK, loaded, connected |
| `warning` | `#d29922` | Mixed content, slow load |
| `danger` | `#f85149` | TLS error, blocked, security alert |

### Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Tab titles | System sans (Inter / SF Pro / Segoe) | 13px | 400 |
| URL bar | System mono (JetBrains Mono / SF Mono) | 14px | 400 |
| Status bar | System mono | 11px | 400 |
| Panel headings | System sans | 14px | 600 |
| Panel body | System mono | 12px | 400 |

### Browser Chrome Layout

```
┌─────────────────────────────────────────────────────────┐
│ [←] [→] [⟳]  ┌─────────────────────────────────┐  [⚙] │  ← Navigation bar
│               │ https://example.com             │      │  ← URL bar (mono)
│               └─────────────────────────────────┘      │
├─────────────────────────────────────────────────────────┤
│ Tab 1  │  Tab 2  │  Tab 3  │  +                        │  ← Tab bar
├─────────────────────────────────────────────────────────┤
│                                                         │
│                                                         │
│                   Web Content                           │  ← Content viewport
│                   (page styles)                         │     (white/page bg)
│                                                         │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ 🟢 TLS │ 47 requests │ 1.2s │ 3.4 MB │ JS: 12 │ A11y │  ← Status bar
└─────────────────────────────────────────────────────────┘
```

### TUI Mode Layout (Phase 0)

```
┌─────────────────────────────────────────────────────────┐
│ trb ▸ https://example.com                    [1/3] ⚙   │  ← URL + tab count
├─────────────────────────────────────────────────────────┤
│                                                         │
│  <!DOCTYPE html>                                        │
│  <html>                                                 │
│    <head>                                               │  ← Raw HTML view
│      <title>Example</title>                             │     (syntax highlighted)
│    </head>                                              │
│    <body>                                               │
│      <h1>Hello World</h1>                               │
│    </body>                                              │
│  </html>                                                │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ GET 200 OK │ 1.2KB │ 142ms │ text/html │ TLS 1.3      │  ← Status line
└─────────────────────────────────────────────────────────┘
```

## Interaction Model

### Keyboard-First

All actions are keyboard-accessible. Mouse is supported but not required.

| Key | Action |
|-----|--------|
| `o` / `Ctrl+L` | Focus URL bar |
| `t` / `Ctrl+T` | New tab |
| `w` / `Ctrl+W` | Close tab |
| `J` / `K` | Next / previous tab |
| `j` / `k` | Scroll down / up (vim) |
| `g g` / `G` | Top / bottom of page |
| `f` | Follow mode (label links, type label to click) |
| `/` | Search in page |
| `Ctrl+Shift+I` | Toggle dev panel |
| `Ctrl+Shift+A` | Toggle AI panel (Claude) |
| `:` | Command mode (vim-style ex commands) |

### AI Interaction

Claude is invoked via panel or command mode, never unsolicited (unless user enables proactive mode):

```
:ai summarize this page
:ai find the pricing section
:ai extract all email addresses
:ai compare this page with tab 2
```

Results appear in a side panel that can be dismissed with `Esc`.

## Logo Concept

**Logomark**: A stylized browser window frame where the viewport contains an eye — representing the AI that sees and understands web content. The eye is geometric (circles + arcs), not realistic. Constructed on an 8-unit grid.

**Wordmark**: "therobotbrowses" in a monospace font (JetBrains Mono or similar), lowercase, with subtle letter-spacing.

**Colors**: Accent blue (`#58a6ff`) on dark background (`#0d1117`), or inverted for light contexts.
