---
id: US-024
title: "View version history for a mockup"
slug: "version-history"
personas: [P-002, P-003]
epic: "Mockup Management"
priority: "should-have"
complexity: "M"
tags: [mockup-management, version-history, iteration, audit]
---

# US-024: View version history for a mockup

## User Story

**As a** product manager (P-002),
**I want to** view the complete iteration history of a mockup as a visual timeline,
**So that** I can see how the design evolved, compare versions side-by-side, and revert to an earlier state if needed.

## Acceptance Criteria

- [ ] Given a mockup with at least one iteration, when I open "Version History", then a chronological list of versions is shown, each with its iteration prompt, timestamp, and thumbnail
- [ ] Given the version history, when I click any historical version, then the full artifact is displayed in a preview panel alongside the current version for side-by-side comparison
- [ ] Given I select a historical version and click "Restore", when I confirm, then a new mockup is created as a copy of that version (not in-place replacement) and I am navigated to it
- [ ] Given a root mockup with no parent, when I open Version History, then it shows a single entry labeled "Original" with the creation prompt

## Notes

Version history traversal follows `parent_mockup_id` links established by US-008. History display is read-only; restoring creates a new branch via duplication (US-023). Maximum depth displayed is 50 versions; deeper chains show a "Load more" control. Related to US-008, US-022, US-023.
