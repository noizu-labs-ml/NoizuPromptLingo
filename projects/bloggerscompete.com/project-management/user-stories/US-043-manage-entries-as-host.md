---
id: US-043
title: "Manage Entries as Competition Host"
slug: "manage-entries-as-host"
personas: [P-003, P-005]
epic: "Competition Hosting"
priority: "should-have"
complexity: "M"
tags: [competitions, hosting, entries, management, moderation]
---

# US-043: Manage Entries as Competition Host

## User Story

**As a** competition host with active entries (P-005),
**I want to** view and manage all entries in my competition,
**So that** I can monitor participation, remove any entries that violate competition rules, and ensure a fair competition.

## Acceptance Criteria

- [ ] Given I am a competition host, when I navigate to my competition's management page, then I see a table of all entries with: blog name, entrant username, entry timestamp, selected post count, and current AI score
- [ ] Given I want to review a specific entry, when I click on it, then I see the entrant's blog profile, selected posts, and their AI score breakdown
- [ ] Given an entry violates competition rules (e.g., off-niche content, spam), when I click "Remove Entry," then a reason input is required and the entrant receives a notification explaining their removal
- [ ] Given I remove an entry, when the action is confirmed, then the entry count decrements and the entrant's competition entry slot is restored for that month
- [ ] Given I want to export entry data, when I click "Export CSV," then a CSV file downloads with all entry details including blog URLs, scores, and timestamps
- [ ] Given entries are being actively submitted during an open competition, when I view the management page, then the entry list updates in near real-time or with a refresh button showing new entry count

## Notes

Entry removal must notify the entrant to be transparent and defensible. Bulk removal is not required in this story. Export CSV is useful for P-003 (content marketing managers) who want to analyze competition data for brand reporting. Related to US-039 (create), US-042 (publish), US-044 (close and finalize). P-008 (admin) can override host removals if abused.
