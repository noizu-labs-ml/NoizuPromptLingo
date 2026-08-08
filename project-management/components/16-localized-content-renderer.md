# Localized Content Renderer

| Field | Value |
|-------|-------|
| **ID** | `localized-content-renderer` |
| **Category** | Data Display |
| **Used In** | 26-ticket-detail, 28-wiki-browser |

## Description

Renders rich, user-authored content — ticket bodies, wiki pages — with correct handling of non-English text and Unicode. Both usages trace to the same underlying requirement (US-093), confirming this is meant to be one shared renderer rather than two independent implementations.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Expanded** | Full rich-content view within a ticket or wiki page |

## Props / Configuration

- `content` — rich-text/markdown source
- `locale` — hints for correct script/direction rendering

## Interactions

- Content renders with correct glyph shaping, direction, and font fallback for non-English/Unicode text — no user-facing interaction beyond normal reading/scrolling
