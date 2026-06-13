# TUI Layout Worksheet

## Project Info

| Field | Value |
|-------|-------|
| **App name** | |
| **Purpose** | |
| **Target framework** | |
| **Min terminal size** | 80×24 |
| **Typical terminal size** | 120×40 |
| **Max terminal size** | 200×60 |

## Information Hierarchy

| Priority | Content | Description | Always Visible? |
|----------|---------|-------------|-----------------|
| Primary | | | Yes |
| Primary | | | Yes |
| Secondary | | | Yes (if space) |
| Secondary | | | Yes (if space) |
| Contextual | | | No (on demand) |
| Contextual | | | No (on demand) |

## Layout Pattern

**Selected pattern:** _(full-screen / split-pane / wizard / tabbed / modal / log-viewer / form / dashboard)_

## ASCII Sketch (80×24)

```
         1111111111222222222233333333334444444444555555555566666666667777777777
1234567890123456789012345678901234567890123456789012345678901234567890123456789
┌──────────────────────────────────────────────────────────────────────────────┐
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

## Widget Inventory

| Widget | Type | Data Source | Min Size | Priority | Notes |
|--------|------|-------------|----------|----------|-------|
| | | | | P1 | |
| | | | | P1 | |
| | | | | P2 | |
| | | | | P2 | |
| | | | | P3 | |

## Keybinding Assignments

| Key | Action | Context |
|-----|--------|---------|
| `q` | Quit | Global |
| `?` | Help overlay | Global |
| `Ctrl+C` | Force quit | Global |
| `↑` / `↓` | Navigate | List/table |
| `Enter` | Select/confirm | Focused widget |
| `Esc` | Back/cancel | Modal/submenu |
| `Tab` | Next focus | Global |
| `/` | Search/filter | List/table |
| | | |
| | | |
| | | |

## Color Tier

- [ ] **Tier 1 only** (8 ANSI) — maximum compatibility
- [ ] **Tier 2** (256 colors) — with Tier 1 fallback
- [ ] **Tier 3** (truecolor) — with Tier 1 fallback

### Semantic Colors

| Semantic | Tier 1 | Tier 2/3 |
|----------|--------|----------|
| Primary | | |
| Accent | | |
| Error | red | |
| Warning | yellow | |
| Success | green | |
| Info | cyan | |
| Muted | white (dim) | |
| Selected | yellow (bold) | |

## Responsive Degradation

| Terminal Width | What Changes |
|---------------|-------------|
| ≥120 cols | Full layout |
| 80–119 cols | |
| 60–79 cols | |
| <60 cols | |

| Terminal Height | What Changes |
|----------------|-------------|
| ≥40 rows | Full layout |
| 24–39 rows | |
| <24 rows | |
