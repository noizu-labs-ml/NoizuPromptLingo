# Device Switcher

| Field | Value |
|-------|-------|
| **ID** | `device-switcher` |
| **Category** | Navigation & Layout |
| **Used In** | 17-Wireframe Gallery, 26-Demo Preview |

## Description

Toolbar for switching viewport dimensions between desktop (1280px), tablet (768px), and mobile (375px) presets, plus custom dimensions. Optional device frame overlay.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Icon-only toggle buttons |
| **Compact** | Icons with labels and custom input |

## Props / Configuration

- `presets` — Array of {name, width, height, icon}
- `customDimensions` — Boolean (enable custom input)
- `showFrame` — Boolean (device frame overlay)
- `sideBySide` — Boolean (show two viewports simultaneously)
- `activePreset` — Currently selected preset

## Interactions

- Click preset → resizes target viewport
- Custom input → manual width/height entry
- Frame toggle adds/removes device chrome overlay
- Side-by-side shows two viewports at once
