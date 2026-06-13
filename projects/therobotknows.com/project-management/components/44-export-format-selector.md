# Export Format Selector

| Field | Value |
|-------|-------|
| **ID** | `export-format-selector` |
| **Category** | Forms / Export |
| **Used In** | S21 Export Options |

## Description

Card-based radio selector for choosing the output format of a canon universe export. Each option is a visual card showing a format icon, format name, a one-sentence description of the format's use case, and any relevant caveats (e.g., "PDF exports do not preserve internal links"). Selecting a card updates the export options panel below with format-specific settings. Supports Markdown, JSON, PDF, and Game Engine Schema (Foundry VTT / JSON-LD).

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | 2-column grid of small cards with icon + name only; description on hover tooltip |
| **Expanded** | Single-column list with icon, name, description, and caveat note per format; default |

## Props / Configuration

- `value` — Currently selected format key: `markdown | json | pdf | game-engine-schema`
- `onChange` — Callback `(format: string) => void`
- `options` — Optional override array of `{ value, label, description, caveat, icon }`; replaces defaults
- `disabledFormats` — String array of format keys unavailable on the current plan; renders those cards in muted state with an upgrade tooltip
- `size` — `compact | expanded`

## Interactions

- Clicking a card selects it (radio behavior — only one active at a time); selected card shows border highlight and checkmark
- Disabled format cards are not clickable; hovering shows tooltip: "Available on Pro plan — Upgrade"
- Selecting a format emits `onChange` and triggers the parent export panel to show format-specific sub-options (e.g., section scope for Markdown, schema version for Game Engine)
- Keyboard: arrow keys navigate between cards; Space/Enter selects; Tab moves to sub-options panel
