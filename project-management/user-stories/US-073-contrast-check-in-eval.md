---
id: US-073
title: "Check color contrast in eval criteria"
slug: contrast-check-in-eval
personas: [P-007]
epic: "Accessibility"
priority: could-have
complexity: high
tags: [accessibility, contrast, wcag, eval]
---

# US-073: Check color contrast in eval criteria

## User Story

**As an** accessibility consultant
**I want to** define eval criteria that check WCAG contrast ratios
**So that** generated assets meet accessibility standards automatically

## Acceptance Criteria

- **Given** an eval criterion checking contrast ratio
  **When** an image is evaluated
  **Then** the dominant text/background contrast is measured against WCAG 2.2 AA (4.5:1)

- **Given** the contrast check fails
  **When** the eval results are reported
  **Then** the asset is flagged with the specific contrast ratio and the required minimum

## Notes
Planned feature. Requires image analysis to extract dominant colors and measure contrast.
