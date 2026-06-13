---
id: US-040
title: "Set Judging Criteria Weights"
slug: "set-judging-criteria-weights"
personas: [P-003, P-005]
epic: "Competition Hosting"
priority: "should-have"
complexity: "M"
tags: [competitions, hosting, criteria, weights, judging, customization]
---

# US-040: Set Judging Criteria Weights

## User Story

**As a** competition host (P-005),
**I want to** customize the weighting of AI judging criteria for my competition,
**So that** I can design competitions that emphasize the qualities most relevant to my niche and community goals.

## Acceptance Criteria

- [ ] Given I am creating or editing a competition, when I reach the judging criteria step, then I see all 6 AI scoring dimensions (Originality, Engagement, Consistency, Writing Quality, SEO, Visual Design) each with an adjustable weight input
- [ ] Given I adjust criterion weights, when the total deviates from 100%, then an inline error is shown and the save/advance button is disabled until weights sum to exactly 100%
- [ ] Given I want to use default equal weighting, when I click "Reset to Default," then all 6 criteria are set to equal weights (~16.67% each, rounded to sum to 100%)
- [ ] Given I set a criterion weight to 0%, when I confirm, then that dimension is effectively excluded from scoring and a warning clarifies it will not influence results
- [ ] Given I have set custom weights, when I advance to the next step, then a summary of my criteria weights is shown in the review step with a visual breakdown chart
- [ ] Given I save and publish my competition with custom weights, when bloggers view the competition detail page, then they see the exact weights I configured (US-030)

## Notes

Custom weights enable differentiated competition types — e.g., an SEO agency might host a competition weighted 50% SEO, while a literary blog might weight Writing Quality at 60%. Weights should be locked once the competition has its first entry to prevent retroactive gaming. Related to US-039 (create competition), US-030 (criteria display to entrants).
