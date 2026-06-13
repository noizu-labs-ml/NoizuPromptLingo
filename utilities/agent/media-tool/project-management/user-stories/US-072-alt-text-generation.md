---
id: US-072
title: "Auto-generate alt text for images"
slug: alt-text-generation
personas: [P-007]
epic: "Accessibility"
priority: could-have
complexity: medium
tags: [accessibility, alt-text, vision, a11y]
---

# US-072: Auto-generate alt text for images

## User Story

**As an** accessibility engineer
**I want to** generated images to include auto-generated alt text
**So that** the assets are accessible when embedded in web pages and documents

## Acceptance Criteria

- **Given** an image is generated
  **When** a vision API is available
  **Then** alt text is generated describing the image content

- **Given** the `description` field in attachments or prompt metadata
  **When** alt text is generated
  **Then** the user-provided description is used as the alt text basis

## Notes
Planned feature. Could use vision API to describe the generated image, or derive from prompt text.
