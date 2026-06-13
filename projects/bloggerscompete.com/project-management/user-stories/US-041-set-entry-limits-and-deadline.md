---
id: US-041
title: "Set Entry Limits and Deadline"
slug: "set-entry-limits-and-deadline"
personas: [P-003, P-005]
epic: "Competition Hosting"
priority: "must-have"
complexity: "S"
tags: [competitions, hosting, entry-limits, deadline, configuration]
---

# US-041: Set Entry Limits and Deadline

## User Story

**As a** competition host (P-005),
**I want to** set the maximum number of entries allowed and the entry deadline,
**So that** I can control the scale and timeline of my competition to match my capacity for reviewing results.

## Acceptance Criteria

- [ ] Given I am creating a competition, when I reach the entry settings step, then I can set an optional maximum entry count (numeric field with no upper bound, or toggle "Unlimited")
- [ ] Given I set a maximum entry count, when I save the competition, then the entry count cap is enforced during the entry flow and displayed to potential entrants (US-031)
- [ ] Given I am setting dates, when I configure the start and end date/time, then both fields require a value and the end date must be at least 24 hours after the start date
- [ ] Given I set a deadline, when the deadline passes, then the system automatically closes entries and triggers the scoring pipeline without requiring manual action from me
- [ ] Given I want to extend the deadline after publishing, when I edit the competition settings, then I can push the deadline forward (but not backward if entries already exist) and existing entrants are notified by email
- [ ] Given I leave the maximum entry count blank, when I publish the competition, then entry is unlimited and the competition card shows "Open Entry" instead of a capacity progress bar

## Notes

Deadline enforcement must be automated — hosts should not need to manually close competitions. Auto-close should trigger at exactly the deadline timestamp with a 5-minute grace window for in-progress submissions. Related to US-039 (create competition), US-031 (entry count display), US-044 (close competition and finalize). Extension notification email should reference the updated deadline.
