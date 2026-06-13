---
id: US-028
title: "Post-process: crop with gravity"
slug: post-process-crop
personas: [P-001, P-008]
epic: "Post-Processing"
priority: should-have
complexity: medium
tags: [post-processing, crop, image-magick]
---

# US-028: Post-process: crop with gravity

## User Story

**As a** developer creating OG card images
**I want to** crop generated images to specific social media dimensions
**So that** previews look correct when shared on Twitter, LinkedIn, and Slack

## Acceptance Criteria

- **Given** a post-processing step `action: crop` with `gravity: center`, `width: 1200`, `height: 630`
  **When** generation completes
  **Then** the image is center-cropped to the specified dimensions

- **Given** `gravity: north`
  **When** cropping
  **Then** the crop is anchored to the top of the image

## Notes
Gravity options: center, north, south, east, west, and combinations (northeast, etc.).
