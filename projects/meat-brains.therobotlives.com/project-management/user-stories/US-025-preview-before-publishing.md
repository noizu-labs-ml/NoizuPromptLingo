---
id: US-025
title: "Preview Prompt Before Publishing"
slug: "preview-before-publishing"
personas: [P-001, P-002, P-006]
epic: "Content Formatting"
priority: "should-have"
complexity: "M"
tags: [formatting, preview, submission, ux, publishing]
---

# US-025: Preview Prompt Before Publishing

## User Story

**As a** Content Creator (P-006),
**I want to** preview how my prompt will look to other users before I publish it,
**So that** I can catch formatting issues, verify the Markdown renders correctly, and ensure the submission looks polished.

## Acceptance Criteria

- [ ] Given I am on the prompt submission or edit form, when I click the "Preview" tab above the description editor, then the description field switches to a read-only rendered view showing how the content will appear to other users, including Markdown (US-021), code blocks (US-022), and template variables (US-024).
- [ ] Given I am in preview mode, when I click "Edit" tab, then I am returned to the editable form with all my content intact and my cursor position preserved (or restored to the last known position).
- [ ] Given I am in preview mode for the prompt body field, when the body contains template variables, then the variables are rendered as highlighted pills exactly as they would appear on the published detail page.
- [ ] Given I am previewing my submission, when I click "Publish" directly from preview mode, then the form is submitted without requiring me to switch back to edit mode, provided all required fields are valid.
- [ ] Given the preview renders a description containing an image (US-023), when the preview loads, then the image is displayed using a temporary pre-signed URL for the uploaded asset, identical to how it will appear after publishing.

## Notes

The preview tab should not require a round-trip to the server — all rendering should happen client-side using the same renderer as the production detail page, ensuring pixel-perfect fidelity. This story is a dependency target for US-024 (template variable highlighting in editor preview). Publishing directly from preview (AC-4) reduces an extra step for P-001 who iterates rapidly.
