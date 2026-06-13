---
id: US-034
title: "Preview Estimated Score Before Final Submission"
slug: "preview-score-before-submit"
personas: [P-002, P-008]
epic: "Site Submission"
priority: "should-have"
complexity: "L"
tags: [submission, scoring, preview, transparency]
---

# US-034: Preview Estimated Score Before Final Submission

## User Story

**As an** indie web developer (P-002),
**I want to** see an estimated quality score for my site before I officially submit it,
**So that** I can decide whether it is ready for review or needs improvement before spending one of my monthly submission slots.

## Acceptance Criteria

- [ ] Given I have entered a URL, when I click "Preview Score," then the AI scores the site across all 5 dimensions and displays the estimated scores with a clear "not yet submitted" label
- [ ] Given the preview score is below the acceptance threshold, when it is displayed, then I see which dimensions are failing and receive improvement suggestions before being shown the final Submit button
- [ ] Given the preview score is above the acceptance threshold, when it is displayed, then the Submit button is prominently enabled with the score visible as a confidence indicator
- [ ] Given I request a preview, when the analysis is running, then I see a progress indicator and the preview result within 30 seconds for typical sites

## Notes

Preview scoring consumes compute but does not use a submission slot. A preview result is valid for 24 hours — if a user submits within that window, the cached preview score is used to avoid redundant re-scoring. Related to score recalibration workflow in US-050.
