# Pixel-Anchored Overlay Commenter

| Field | Value |
|-------|-------|
| **ID** | `pixel-anchored-overlay-commenter` |
| **Category** | Domain-Specific |
| **Used In** | 30-review-detail |

## Description

The core review-annotation surface: a screenshot with x/y pixel-anchored comment pins, a sidebar list of all pins for quick navigation, and a verdict compiler that aggregates the open comments into a final pass/fail/changes-requested decision once the review is complete. Only named on one screen, but this is exactly the kind of genuinely complex, bespoke interaction pattern worth extracting on its own — pixel-anchored positioning, per-pin threads, and a decision-compilation step layered on top.

## Size Variants

| Variant | Description |
|---------|-------------|
| **Compact** | Comment Marker List only — sidebar navigation across existing pins |
| **Expanded** | Screenshot canvas with pins, open for adding/viewing annotations |
| **Full Page** | Verdict compilation view — resolves pins into a pass/fail/changes-requested decision |

## Props / Configuration

- `image` — the target screenshot
- `pins` — x/y-anchored comment threads
- `verdictOptions` — pass / fail / changes-requested

## Interactions

- User clicks a point on the screenshot → drops a new pin and opens its comment field
- User clicks an entry in the Comment Marker List → the canvas scrolls/highlights the corresponding pin
- User resolves outstanding pins and opens the verdict compiler → selects a verdict, compiling the review
