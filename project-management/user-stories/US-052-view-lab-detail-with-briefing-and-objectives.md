---
id: US-052
title: "View Lab Detail with Briefing and Objectives"
slug: "view-lab-detail-with-briefing-and-objectives"
personas: [P-008, P-001]
epic: "Academy — Labs"
priority: "must-have"
complexity: "S"
tags: [academy, labs, detail, briefing, objectives]
---

# US-052: View Lab Detail with Briefing and Objectives

## User Story

**As a** CTF competitor and security student (P-008),
**I want to** view a lab's full briefing, learning objectives, and prerequisites before launching,
**So that** I can confirm it matches my skill level and understand what I will learn before committing.

## Acceptance Criteria

- [ ] Given I click a lab from the browse view, when the detail page loads, then I see: title, type badge, difficulty, estimated duration, linked catalog techniques, learning objectives list, and prerequisite labs (if any)
- [ ] Given the lab detail page is loaded, when I scroll, then I see a scenario briefing narrative (the "mission brief") that contextualizes the challenge without revealing the solution
- [ ] Given I am not authenticated, when I view a lab detail, then I see the full briefing but the Launch button prompts sign-in
- [ ] Given a lab has prerequisite labs, when I view the detail and have not completed them, then prerequisites are shown with completion status and links

## Notes

The briefing narrative is the engagement hook — it should read like a red team mission brief or incident scenario, not a dry description. Linked catalog techniques on the detail page create a direct bridge between Catalog and Academy.
