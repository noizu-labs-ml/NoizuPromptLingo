---
id: US-056
title: "View Lab Debrief After Completion"
slug: "view-lab-debrief-after-completion"
personas: [P-008, P-001, P-003]
epic: "Academy — Labs"
priority: "should-have"
complexity: "M"
tags: [academy, labs, debrief, learning, post-completion]
---

# US-056: View Lab Debrief After Completion

## User Story

**As an** ML engineer building agents (P-003),
**I want to** view a detailed debrief after completing a lab,
**So that** I understand the underlying technique, why my approach worked or almost worked, and how to apply the lesson to my own systems.

## Acceptance Criteria

- [ ] Given I complete a lab (pass or exhaust attempts), when I navigate to the debrief, then I see: full solution walkthrough, technique breakdown linked to catalog entry, annotated example of a successful exploit or defense, and common mistakes
- [ ] Given I completed the lab without hints, when I view the debrief, then I additionally see a "Variant techniques" section showing alternative approaches I could have used
- [ ] Given the debrief is displayed, when I scroll to the "Defend Against This" section, then I see mitigations mapped to catalog technique data with links to relevant Defender scanner checks
- [ ] Given I completed the lab as part of a learning path, when the debrief loads, then it surfaces the next recommended lab in the path
- [ ] Given I want to revisit a debrief, when I navigate to the lab detail page after completion, then a "View Debrief" button is always available

## Notes

Debriefs are the primary knowledge-transfer mechanism in Academy — they should read as authored technical write-ups, not auto-generated summaries. The Catalog cross-link in debriefs is a key retention driver that ties Academy back to the core product.
