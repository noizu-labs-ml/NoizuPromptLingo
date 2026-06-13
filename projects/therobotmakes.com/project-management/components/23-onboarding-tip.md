# Onboarding Tip

| Field | Value |
|-------|-------|
| **ID** | `onboarding-tip` |
| **Category** | Feedback & Indicators |
| **Used In** | 07-Pitch Input, 09-Persona Curation, 10-Story Curation |

## Description

Contextual tooltip overlay for first-run users. Points to specific UI elements with explanatory text. Dismissible with "Don't show again" persistence. Part of progressive disclosure system.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Small info icon with hover tooltip |
| **Compact** | Floating tooltip with arrow pointing to target element |
| **Expanded** | Coach mark with backdrop dimming and step counter |

## Props / Configuration

- `target` — Element selector to point at
- `content` — Tip text (plain English, non-technical)
- `placement` — top | bottom | left | right
- `step` — Step number in onboarding sequence
- `totalSteps` — Total tips in sequence
- `dismissible` — Boolean

## Interactions

- Appears on first visit to screen
- "Got it" / "Next" advances sequence
- "Don't show again" persists dismissal
- "Skip all" dismisses entire onboarding
- Backdrop dimming focuses attention on target
