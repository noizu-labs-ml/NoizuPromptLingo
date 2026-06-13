---
id: component-weight-slider
name: "Weight Slider"
used_in: [screen-weight-tuner, screen-memory-explorer, screen-recall-console]
---

# Weight Slider

## Purpose
Interactive slider for adjusting numeric weight values with real-time preview. Used for tuning system parameters (decay half-lives, reinforcement boosts, recall weights) and for filtering memories by weight range. Provides more precision than a standard range input through numeric input pairing and optional lock/link behaviors.

## Props/Inputs
- `value`: float -- Current value
- `min`: float -- Minimum allowed value
- `max`: float -- Maximum allowed value
- `step`: float -- Step increment (default: 0.01)
- `label`: string -- Display label
- `unit`: string -- Unit suffix (e.g., "hrs", "%", "") (default: "")
- `precision`: int -- Decimal places to display (default: 2)
- `color`: string -- Accent color for the filled track (default: blue-500)
- `lockable`: boolean -- Show lock icon for linked slider groups (default: false)
- `locked`: boolean -- Whether the slider is locked (default: false)
- `disabled`: boolean -- Whether the slider is interactive (default: false)
- `showPreview`: boolean -- Show a mini preview of the impact (default: false)
- `previewFn`: function -- Callback that computes preview text from the current value (optional)
- `onChange`: function -- Callback fired on value change

## Visual Description

```
Reinforcement boost                          [lock icon]
[0.01] ────────────●──────────────── [0.50]
                  0.15
       "A recalled memory gains 15% weight"
```

- **Track**: Horizontal bar, 4px height, rounded ends. Unfilled portion: grey-200. Filled portion (left of thumb): `color` prop.
- **Thumb**: 16px circle, white fill, 2px border in `color`, drop shadow on drag.
- **Value display**: Numeric value centered below the thumb. Updates in real-time during drag.
- **Range labels**: Min value at left end, max value at right end. Grey text, small font.
- **Label**: Above the track, left-aligned. Standard body font.
- **Unit suffix**: Appended to the value display (e.g., "168 hrs").
- **Preview text**: Below the value, italicized grey text. Computed from `previewFn` if provided (e.g., "A recalled memory gains 15% weight").
- **Lock icon** (if `lockable`): Small padlock icon at the right end of the label row. Grey when unlocked, amber when locked. Locked sliders have a dashed track and muted color.
- **Disabled state**: Track and thumb are grey. Cursor shows not-allowed.

### Numeric Input Pairing

Clicking the value display converts it to an editable text input for precise entry. Pressing Enter or clicking away confirms the value and snaps to the nearest valid step. Out-of-range values are clamped with a brief red flash.

## Interaction
- **Drag thumb**: Value updates continuously. `onChange` fires on each step. Track fills/unfills smoothly.
- **Click track**: Thumb jumps to clicked position.
- **Click value display**: Converts to editable text input for precise numeric entry.
- **Arrow keys** (when focused): Increment/decrement by `step`.
- **Shift + arrow keys**: Increment/decrement by `step * 10`.
- **Click lock icon**: Toggle locked state. When locked in a linked group, this slider's value is excluded from auto-redistribution.
- **Hover**: Tooltip showing full label, current value, and preview text.
