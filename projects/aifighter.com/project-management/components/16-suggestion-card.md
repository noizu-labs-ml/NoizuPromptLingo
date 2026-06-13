# Suggestion Card

| Field | Value |
|-------|-------|
| **ID** | `suggestion-card` |
| **Category** | AI-Specific |
| **Used In** | 03-Post-Battle Screen, 12-Patch Notes (tip suggestions) |

## Description

Improvement suggestion presented as a card with plain-language description and one-tap deep link to the relevant node in Fighter Studio. Supports dismiss and review-later actions.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Inline** | Single-line suggestion with minimal controls |
| **Compact** | Card with action buttons (deep link, dismiss, review later) |

## Props / Configuration

- `suggestion` — Text description of the improvement suggestion
- `targetNode` — Node ID for deep link into Fighter Studio
- `priority` — Ranking among suggestions (used for ordering)
- `dismissable` — Allow dismiss and save-for-later actions

## Interactions

- Tap to navigate to Fighter Studio with target node highlighted
- Dismiss suggestion (removes from list)
- Save for later review
