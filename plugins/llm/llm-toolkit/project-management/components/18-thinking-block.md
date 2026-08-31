# 18: Thinking Block

| Field | Value |
|-------|-------|
| ID | CMP-18 |
| Category | AI-Specific |
| Surfaces | web, cli-ink |
| Used In | SCR-04, SCR-19 |

## Description
Collapsible, visually dimmed rendering of extended-thinking content within an Assistant message. Collapsed by default; a single toggle key/click expands it in place.

## Size Variants

| Variant | Use Case |
|---------|---------|
| Collapsed (default) | Summary line only ("Thinking — N lines") |
| Expanded | Full thinking text, `--text-dim` / dimmed styling per style guide |

## Props / Configuration
- `content` — string (markdown/plaintext)
- `expanded` — boolean, toggled via `x` (cli-ink) or click (web)

## Interactions
- Toggle is per-block; expanding one thinking block doesn't affect others
- Web "expand all" / "collapse all" convenience may apply at the MessageList level
