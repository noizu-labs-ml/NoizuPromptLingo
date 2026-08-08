---
id: US-034
title: "Research Competitors for a Market Segment"
slug: "research-competitors-for-market-segment"
personas: [P-005]
epic: "Creative Assets & Campaigns"
priority: "should-have"
complexity: "M"
tags: [research, competitors, market-segment, llm]
---

# US-034: Research Competitors for a Market Segment

## User Story

**As the** Growth Operator (P-005),
**I want to** run LLM-assisted competitor research for a market segment,
**So that** I can position campaign messaging against what competitors in that segment are already doing.

## Acceptance Criteria

- [ ] Given a market segment label and a short description, when I trigger "research competitors", then the system returns a list of candidate competitors, each with a name and short summary, stored against that segment.
- [ ] Given a market segment already has a prior competitor research result, when I re-run research for the same segment, then both the prior and new result sets remain viewable rather than the new run silently overwriting the old.
- [ ] Given a competitor entry in the results, when I mark it "relevant" or "dismissed", then that classification persists and controls what appears in the default competitor view going forward.

## Notes

Findings here typically inform keyword research (US-035) and ad copy generation (US-030) for the same segment.
