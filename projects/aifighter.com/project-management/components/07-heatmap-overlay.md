# Heatmap Overlay

| Field | Value |
|-------|-------|
| **ID** | `heatmap-overlay` |
| **Category** | Data Display |
| **Used In** | 01-Fighter Studio (post-battle), 03-Post-Battle Screen, 04-Training Gym, 10-Education Portal |

## Description

Color-intensity overlay on a fighter graph showing node activation frequency. Supports phase filtering (opening/midgame/closing), color vision modes, and export as image/CSV.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Small preview thumbnail showing heatmap at reduced scale |
| **Expanded** | Full overlay rendered on top of graph canvas |
| **Full Page** | Exportable art print at 3000x3000px with theme-aware color rendering |

## Props / Configuration

- `activationData` — Per-node activation count data from training or battle
- `phaseFilter` — Match phase to isolate: `opening`, `midgame`, or `closing`
- `colorMode` — Accessibility color mode for color vision deficiencies
- `theme` — Graph color theme applied during art print export
- `exportResolution` — Resolution multiplier for art print export target

## Interactions

- Toggle overlay on or off
- Filter activation data by match phase
- Export current heatmap view as PNG or CSV
- View color intensity legend
