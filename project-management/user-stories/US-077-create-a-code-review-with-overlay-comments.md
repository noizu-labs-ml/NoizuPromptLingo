---
id: US-077
title: "Create a Code Review with Overlay Comments"
slug: "create-a-code-review-with-overlay-comments"
personas: [P-007]
epic: "Social & Collaboration"
priority: "must-have"
complexity: "M"
tags: [code-review, screenshots, overlay-comments, visual-review]
---

# US-077: Create a Code Review with Overlay Comments

## User Story

**As a** Design & Code Reviewer (Sofia Reyes, P-007),
**I want to** create a Code Review against a screenshot and drop pixel-anchored comments at specific x/y/width/height regions,
**So that** I can point precisely at the visual element I'm giving feedback on instead of describing its location in prose.

## Acceptance Criteria

- [ ] Given a screenshot uploaded to a new Code Review, when a comment is added with x, y, width, and height coordinates, then the comment is stored anchored to that exact region and renders as an overlay box at those coordinates when the review is viewed.
- [ ] Given an existing Code Review with one overlay comment, when a second overlay comment is added at a non-overlapping region, then both render independently without one overwriting or displacing the other.
- [ ] Given a Code Review, when overlay comment coordinates are supplied outside the bounds of the screenshot's pixel dimensions, then the comment is rejected with a validation error instead of being silently clamped or accepted off-canvas.
- [ ] Given a Code Review in progress, when the reviewer adds a text-only comment with no coordinates, then it is still accepted and shown as a general (non-anchored) review comment.

## Notes

Precursor to US-078 (compiling the review into a verdict); the overlay coordinate model is screenshot-pixel-space, not DOM-selector-based.
