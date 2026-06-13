---
id: US-009
title: "Generate mobile-responsive mockup variant"
slug: "generate-mobile-responsive-variant"
personas: [P-001, P-003]
epic: "MCP Core Service"
priority: "should-have"
complexity: "M"
tags: [mcp, mobile, responsive, breakpoints, wireframe]
---

# US-009: Generate mobile-responsive mockup variant

## User Story

**As a** full-stack developer (P-001),
**I want to** request a mobile-viewport variant of a wireframe by passing a `viewport` parameter,
**So that** I get a layout adapted for small screens without manually redesigning the desktop mockup.

## Acceptance Criteria

- [ ] Given `viewport: "mobile"` (375px width), when a wireframe generation tool is called, then the returned mockup uses a single-column layout with touch-appropriate element sizes
- [ ] Given `viewport: "tablet"` (768px width), when a wireframe generation tool is called, then the returned mockup uses a two-column or adaptive layout
- [ ] Given `viewport: "desktop"` (default, 1440px), when no viewport parameter is supplied, then behavior is unchanged from prior stories
- [ ] Given a request for both `mobile` and `desktop` variants (via `variant_count: 2` with two viewport entries), when the tool responds, then each artifact is labeled with its viewport in the metadata

## Notes

Viewport parameter accepts `mobile`, `tablet`, `desktop`, or a numeric pixel width. Responsive adaptation is heuristic-based — complex layouts may require iteration (US-008) to achieve correct results. Related to US-007.
