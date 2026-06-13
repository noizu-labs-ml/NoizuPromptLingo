# Font Size Control

| Field | Value |
|-------|-------|
| **ID** | `font-size-control` |
| **Category** | Appearance Settings |
| **Used In** | S-28 Appearance Settings |

## Description

Slider or stepper control for adjusting the editor body font size in the range 12px–24px. Includes a live preview text sample that updates in real time as the user drags or steps through values.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Stepper with decrement/increment buttons and a numeric display; used in settings sidebar panels with limited width |
| **Expanded** | Slider with labeled endpoints, current value display, and a live preview paragraph; used in Appearance Settings |

## Props / Configuration

- `value` — Current font size in pixels (integer, 12–24)
- `min` — Minimum value (default: 12)
- `max` — Maximum value (default: 24)
- `step` — Step increment (default: 1)
- `previewText` — Sample text shown in the live preview area (default: a short lorem-style passage)
- `variant` — `"compact"` | `"expanded"` (default: `"expanded"`)
- `onValueChange` — Callback receiving new pixel value as integer during drag/step
- `onCommit` — Callback receiving final value on mouse-up or blur; triggers the persistence API call

## Interactions

- Slider thumb dragging updates `value` in real time; preview text re-renders at the new size with each tick
- Stepper buttons increment/decrement by `step`; holding the button repeats at 200ms intervals
- Live preview area renders an excerpt of body text in the editor's actual font family and current theme colors so the user sees an accurate representation
- Value is displayed numerically adjacent to the control (e.g., "16px") and updates during drag
- `onValueChange` fires on every tick for preview; `onCommit` fires only on release to avoid excessive API calls
- Committed value is saved to user preferences; local state is updated optimistically
- Keyboard: focused slider responds to Arrow Left/Right for fine adjustment; Home/End jump to min/max
- Reset to Default link restores the value to 16px with a single click
