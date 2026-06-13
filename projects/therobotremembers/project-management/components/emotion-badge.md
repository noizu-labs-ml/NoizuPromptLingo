---
id: component-emotion-badge
name: "Emotion Badge"
used_in: [screen-memory-explorer, screen-memory-timeline, screen-recall-console, screen-guardian-alerts, screen-agent-dashboard]
---

# Emotion Badge

## Purpose
A compact, color-coded badge that communicates the emotional state attached to a memory or agent at a glance. Maps the 7-dimensional emotional vector (valence, arousal, dominance + 4 hormones) to a human-readable label and background color. Used wherever a memory's emotional context needs to be shown in a small space.

## Props/Inputs
- `valence`: float (-1.0 to 1.0) -- Emotional valence
- `arousal`: float (0.0 to 1.0) -- Arousal level
- `dominance`: float (0.0 to 1.0) -- Dominance level
- `cortisol`: float (0.0 to 1.0) -- Stress level (optional, for tooltip)
- `dopamine`: float (0.0 to 1.0) -- Reward level (optional, for tooltip)
- `confidence`: enum (high | medium | low) -- Metadata confidence
- `size`: enum (sm | md | lg) -- Badge size variant (default: md)
- `showTooltip`: boolean -- Whether to show detailed tooltip on hover (default: true)

## Visual Description

The badge is a rounded pill shape with a background color, a text label, and an optional confidence indicator.

### Color Mapping (valence-primary, arousal-modified)

| Valence Range | Arousal | Label | Background Color |
|---------------|---------|-------|-----------------|
| -1.0 to -0.6 | > 0.6 | frustrated | `#E53E3E` (red-500) |
| -1.0 to -0.6 | <= 0.6 | dejected | `#9B2C2C` (red-800) |
| -0.6 to -0.2 | > 0.6 | anxious | `#ED8936` (orange-400) |
| -0.6 to -0.2 | <= 0.6 | uneasy | `#C05621` (orange-700) |
| -0.2 to 0.2 | > 0.6 | alert | `#ECC94B` (yellow-400) |
| -0.2 to 0.2 | <= 0.6 | neutral | `#A0AEC0` (gray-400) |
| 0.2 to 0.6 | > 0.6 | engaged | `#48BB78` (green-400) |
| 0.2 to 0.6 | <= 0.6 | content | `#276749` (green-700) |
| 0.6 to 1.0 | > 0.6 | excited | `#4299E1` (blue-400) |
| 0.6 to 1.0 | <= 0.6 | satisfied | `#2B6CB0` (blue-700) |

Text color: white for all backgrounds. Font: system monospace, uppercase, small.

### Confidence Indicator
- `high`: No additional indicator
- `medium`: Small `~` suffix after the label
- `low`: Dashed border instead of solid, `?` suffix

### Size Variants
- `sm`: 20px height, 10px font, 4px padding
- `md`: 26px height, 12px font, 6px padding
- `lg`: 32px height, 14px font, 8px padding

## Interaction
- **Hover**: Tooltip showing the full emotional vector: valence, arousal, dominance, and all hormone levels as labeled values. If confidence is low, tooltip includes "Low confidence: emotional readings may be inaccurate."
- **Click**: No default action. Parent component can attach a click handler (e.g., filter by similar emotion).
