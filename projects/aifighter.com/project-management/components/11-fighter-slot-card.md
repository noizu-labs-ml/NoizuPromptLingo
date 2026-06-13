# Fighter Slot Card

| Field | Value |
|-------|-------|
| **ID** | `fighter-slot-card` |
| **Category** | Cards & Tiles |
| **Used In** | 06-Ranked Arena, 24-Fighter Win-Rate Analytics |

## Description

Card representing a single fighter slot showing per-slot ELO, win count, last match date, and active/inactive state. Supports 2-tap switching.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Name and ELO chip only |
| **Compact** | Card with ELO, win count, last match date, and active state indicator |

## Props / Configuration

- `fighter` — Slot data object (name, build reference, slot index)
- `isActive` — Whether this slot is the currently active fighter
- `locked` — When true, slot requires Fighter Pass to unlock
- `stats` — Per-slot metrics (ELO, win count, last match date)

## Interactions

- Tap to switch active fighter to this slot (2-tap confirmation)
- View per-slot performance stats
- Navigate to Fighter Studio to edit this slot's build
