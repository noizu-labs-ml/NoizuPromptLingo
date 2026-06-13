---
id: US-023
title: "Attach Images and Screenshots to Prompts"
slug: "attach-images-to-prompts"
personas: [P-002, P-006]
epic: "Content Formatting"
priority: "could-have"
complexity: "M"
tags: [formatting, images, screenshots, upload, media]
---

# US-023: Attach Images and Screenshots to Prompts

## User Story

**As a** Content Creator (P-006),
**I want to** attach screenshots of AI-generated outputs to my prompt submission,
**So that** community members can see a visual example of what the prompt produces without having to run it themselves.

## Acceptance Criteria

- [ ] Given I am on the prompt submission form, when I click the image upload button in the description editor toolbar, then I can select a JPEG, PNG, WebP, or GIF file up to 5MB from my device.
- [ ] Given I upload a valid image, when the upload completes, then the image is stored in object storage, a Markdown image tag is automatically inserted at my cursor position in the description, and a thumbnail preview appears in the editor.
- [ ] Given I attempt to upload a file exceeding 5MB or with an unsupported format, when the upload is attempted, then I see an inline error message specifying the allowed formats and size limit, and no upload occurs.
- [ ] Given an image is embedded in a published prompt, when any user views the prompt detail page, then the image is served via a CDN with lazy loading and includes an alt text input that I filled in during upload (or defaults to "Screenshot of prompt output").
- [ ] Given I am on mobile with a slow connection, when an image-containing prompt page loads, then images display a low-resolution placeholder until fully loaded, and the page is usable before images complete loading.

## Notes

Images are stored externally (S3-compatible object storage) rather than in the database. Animated GIFs should be accepted to support screencasts of multi-turn conversations but must be capped at 5MB. Alt text (AC-4) is required for accessibility compliance. This feature has higher complexity than other formatting stories due to storage and CDN requirements.
