---
id: US-034
title: "Preview Competition Submission"
slug: "preview-competition-submission"
personas: [P-001, P-002]
epic: "Competition Entry"
priority: "should-have"
complexity: "M"
tags: [competitions, entry, preview, submission, review]
---

# US-034: Preview Competition Submission

## User Story

**As a** blogger about to submit a competition entry (P-001),
**I want to** preview exactly how my submission will appear to judges and other participants,
**So that** I can verify everything looks correct before committing to the entry.

## Acceptance Criteria

- [ ] Given I have selected my posts, when I advance to the preview step, then I see a read-only summary of my entry: blog name, selected posts, my current overall AI score, and how my score breaks down by the competition's judging criteria weights
- [ ] Given the competition has specific judging criteria weights, when I view the preview, then I see a projected score breakdown showing my estimated standing for each weighted dimension
- [ ] Given I want to change my post selection, when I click "Back" from the preview step, then I return to the post selection step with my previous selections preserved
- [ ] Given I review my preview and spot an issue, when I click "Edit Blog Profile," then I am taken to my blog settings with a breadcrumb back to the competition entry flow
- [ ] Given the preview renders, when I view it on mobile, then the layout is responsive and all information is legible without horizontal scrolling
- [ ] Given I am satisfied with my preview, when I click "Confirm Submission," then I advance to the final confirmation step (US-035)

## Notes

The preview creates confidence and reduces entry abandonment. Showing projected score breakdown under competition weights helps bloggers understand how they'll be judged. Related to US-033 (post selection), US-035 (submit entry), US-030 (criteria display).
