---
id: US-031
title: "Entry Count and Competition Progress"
slug: "entry-count-and-progress"
personas: [P-001, P-004, P-005, P-006]
epic: "Competition Browsing"
priority: "should-have"
complexity: "S"
tags: [competitions, social-proof, entries, progress, discovery]
---

# US-031: Entry Count and Competition Progress

## User Story

**As a** blogger browsing competitions (P-001),
**I want to** see how many blogs have entered each competition,
**So that** I can gauge competition difficulty and decide whether the odds are favorable for my skill level.

## Acceptance Criteria

- [ ] Given I am on the Competitions listing page, when competition cards are rendered, then each card displays the current entry count (e.g., "42 entries")
- [ ] Given a competition has a maximum entry limit, when I view the competition card or detail page, then a progress bar shows entries vs. capacity (e.g., "42 / 100 spots filled")
- [ ] Given a competition is approaching capacity (>80% full), when I view its card or detail page, then a visual indicator highlights that spots are filling up
- [ ] Given a competition reaches its entry limit, when I view its card, then the status updates to "Full" and the entry CTA is disabled or hidden for non-entered users
- [ ] Given I am on the competition detail page, when entries increase while I am viewing, then the entry count updates without a full page reload (polling or WebSocket)
- [ ] Given I am the competition host (P-005), when I view my competition's detail page, then I see the full entry count alongside a link to the entry management view

## Notes

Entry count serves as social proof — high entry counts signal prestige while lower counts may attract new bloggers seeking better odds. Related to US-028 (competition details), US-041 (host sets entry limits), US-043 (host manages entries). Platform admin P-008 may monitor entry counts for anomaly detection.
