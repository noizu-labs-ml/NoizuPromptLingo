# Accessibility Utilities

| Field | Value |
|-------|-------|
| **ID** | `accessibility-utilities` |
| **Category** | Feedback & Indicators |
| **Used In** | 17-org-dashboard, 23-chat-room-view, 24-ticket-board |

## Description

A shared bundle of cross-cutting accessibility primitives rather than one visible widget: a live-region announcer for assistive tech, a visible keyboard-navigation focus ring enabling full keyboard control of otherwise pointer-driven surfaces (like a kanban board), and a reduced-motion-aware transition layer that substitutes instant state changes for animation when the user prefers reduced motion.

## Size Variants

_Not applicable — this is a behavioral/infrastructure bundle rather than a rendered UI size variant._

## Props / Configuration

- `liveRegion` — enables screen-reader announcements when bound data changes
- `focusRing` — enables a visible, keyboard-navigable focus indicator for drag-and-drop-style surfaces
- `respectReducedMotion` — substitutes instant state changes for animated transitions when `prefers-reduced-motion` is set

## Interactions

- Bound data changes (e.g. a dashboard stat) → `liveRegion` announces the update to screen readers without requiring a re-scan of the page
- Keyboard user tabs into a draggable surface → `focusRing` shows a visible focus state and arrow/enter keys perform the equivalent of a pointer drag
- Any animated transition (card move, message arrival) checks `respectReducedMotion` and substitutes an instant change when set
