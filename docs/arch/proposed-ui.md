# Proposed UI Architecture

## Window Layout

```
┌─────────────────────────────────────────────────────────┐
│ [B] [E] [K] [I] │ Watercolor ▾ │ ●● Recent  │  ⚙ Mode │  ← Toolbar
├────────┬────────────────────────────────────┬───────────┤
│        │                                    │           │
│ Layers │         Canvas (MTKView)           │  Brush    │
│        │                                    │  Panel    │
│ [1] ●  │                                    │           │
│ [2]    │                                    │  Size: ── │
│ [3]    │                                    │  Flow: ── │
│ [4]    │                                    │  Opc:  ── │
│ [5]    │                                    │           │
│ [6]    │                                    ├───────────┤
│ [7]    │                                    │           │
│ [8]    │                                    │  Color    │
│        │                                    │  Panel    │
│        │                                    │           │
│        │                                    │  [picker] │
│        │                                    │  [palette]│
│        │                                    │  [history]│
├────────┴────────────────────────────────────┴───────────┤
│ 2048×1536 │ Zoom: 100% │ Layer 1: Watercolor │ 710 MB  │  ← Status Bar
└─────────────────────────────────────────────────────────┘
```

## Toolbar (US-092)

Horizontal bar at window top. Contains:

1. **Tool buttons** — Brush (B), Eraser (E), Knife (K), Eyedropper (I), Pan (H), Zoom (Z)
2. **Media selector** — Dropdown: Watercolor, Oil, Acrylic, Charcoal, Pastel, [Custom...]
3. **Recent brushes** — 5 most recent brush configs as thumbnail buttons (US-037)
4. **Mode toggle** — Simple/Full switch (US-089)

Active tool highlighted. Keyboard shortcuts shown as tooltip.

## Layer Panel (US-061–068)

Left sidebar, collapsible (US-088). Shows all 8 volume layers:

```
┌─ Layer Panel ──────────┐
│ [👁] [1] ●W ▓▓░░ "Wash"│  ← Visible, active, Watercolor, wet, thumbnail
│ [👁] [2]  O ████ "Base"│  ← Oil, dry, opaque
│ [ ] [3]              │  ← Hidden, empty
│ ...                    │
│ [Clear] [Flatten]      │
└────────────────────────┘
```

Per-layer indicators:
- **Eye icon** — visibility toggle (US-062)
- **Number** — layer index, click to select active (US-063)
- **Media badge** — W/O/A/C/P icon (US-065)
- **State badge** — wet (blue dot), dry (gray), depth bar (US-064)
- **Thumbnail** — 48×48 preview, updated on paint change (US-077)
- **Opacity slider** — appears on hover (US-066)

Actions: Clear layer (US-068), Flatten visible (US-067), Drag to reorder (US-078).

## Color Panel (US-072–076)

Right sidebar (lower), collapsible. Three sub-sections:

### Picker (US-072)
Absorption-aware: shows both absorption values and predicted visible color (canvas × exp(-absorption × concentration)). Hue ring + saturation/value square, but mapped through Beer-Lambert.

### Palette (US-073)
Grid of saved colors. Drag to reorder. Right-click to rename/delete. Import/export as JSON.

### History (US-076)
Horizontal strip of last 16 used colors. Click to reselect.

### Mixing Preview (US-075)
Shows predicted result of current color mixed with color under cursor. Updates on hover when eyedropper is active.

## Brush Panel (US-024–032, 038)

Right sidebar (upper), collapsible. Contains:

- **Size slider** — 1-500px, with keyboard shortcut ([ and ]) (US-024)
- **Opacity slider** — 0-100% (US-025)
- **Flow slider** — 0-100% (US-025)
- **Hardness slider** — 0-100% (soft-hard edge)
- **Shape selector** — Round / Flat / Fan / Dry brush (US-029–032)
- **Presets** — Grid of saved configs, click to load (US-038)

In Simple Mode (US-089), only Size and Shape are shown.

## Status Bar (US-093)

Bottom bar, always visible:

| Section | Content | Update Frequency |
|---------|---------|-----------------|
| Canvas info | "2048×1536" | On canvas creation |
| Zoom | "Zoom: 142%" | On viewport change |
| Active layer | "Layer 1: Watercolor (wet)" | On layer/state change |
| GPU memory | "710 MB" with warning at >80% capacity | Per second |
| FPS | "60 FPS" (debug mode only) | Per second |

## Simple Mode (US-089)

Toggle via toolbar button or Cmd+Shift+S. Hides:
- Layer panel (auto-paints on layer 1)
- Brush panel advanced controls (keeps size only)
- Color panel palette/history (keeps picker only)
- Status bar detail (keeps zoom only)
- All debug visualization options

Shows:
- Large media selector buttons (icon + name)
- Large brush size slider
- Simple color picker
- Canvas

Designed for P5 Suki (hobbyist) and P7 Priya (quick sketch).

## Dialogs

### New Canvas (US-087)
- Canvas size presets (1080p, 2K, 4K, custom)
- Paper type dropdown (from CanvasPreset list)
- Default media selector
- Preview of paper texture

### Preferences (US-091)
- **Display** — background color, grid threshold, dark mode
- **Performance** — simulation quality (half/full rate), max particles
- **Input** — pressure curve, trackpad sensitivity
- **Shortcuts** — keybinding editor (US-090)
- **Auto-save** — interval, location

### Export (US-084–086)
- Format: PNG / TIFF
- Resolution: Canvas (1×), 2×, 4×, Custom
- Color profile: sRGB / Display P3
- Include canvas texture: yes/no

## Keyboard Shortcuts (US-036, 090)

Default keymap (customizable via Preferences):

| Shortcut | Action |
|----------|--------|
| B, E, K, I, H, Z, R | Tool selection |
| [ / ] | Decrease/increase brush size |
| Cmd+Z / Cmd+Shift+Z | Undo / Redo |
| Cmd+0 / Double-click | Reset view |
| Cmd+S | Save |
| Cmd+Shift+E | Export |
| Cmd+Shift+S | Toggle Simple Mode |
| Space+drag | Pan (any tool) |
| Alt+click | Eyedropper (any tool) |
| D | Instant dry (US-060) |
| 1-8 | Select layer |
| Cmd+1-3 | Debug viz: wetness/velocity/depth |

## Dark Chrome (US-014)

Default appearance:
- Window chrome: near-black (#1a1a1a)
- Panel backgrounds: dark gray (#222222)
- Panel text: light gray (#cccccc)
- Active highlights: accent blue (#4a9eff)
- Canvas surround: neutral mid-gray (#333333) or user-customizable (US-019)

Matches the Nocturne design system — dark-native immersion for creative tools.

## Accessibility (US-100)

- All panels keyboard-navigable via Tab
- VoiceOver announces: active tool, selected layer, current color (as named color)
- Keyboard-only painting: arrow keys position cursor, Space deposits, [ ] adjust size
- Reduced-motion preference: disables simulation animation, shows static previews
- High-contrast mode: thicker panel borders, stronger active indicators
