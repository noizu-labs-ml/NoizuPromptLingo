# Accessibility Controls

| Field | Value |
|-------|-------|
| **ID** | `accessibility-controls` |
| **Category** | Input & Forms |
| **Used In** | 09-Settings |

## Description

Grouped accessibility settings panel including color vision mode, reduced motion toggle, haptic feedback toggle, and Switch Control preferences. All controls follow 48px minimum touch targets.

## Size Variants

| Variant | Description |
|---------|-------------|
| Expanded | Full settings group with all accessibility controls |

## Props / Configuration

- `colorVisionMode` — Color vision mode enum value
- `reducedMotion` — Boolean toggle for reduced motion animations
- `hapticFeedback` — Boolean toggle for haptic feedback
- `switchControlEnabled` — Boolean toggle for Switch Control mode
- `touchTargetSize` — Minimum touch target size in px (default 48)

## Interactions

- Toggle each accessibility setting individually
- Preview accessibility changes in real time
- Auto-detect Switch Control and suggest list editor mode
