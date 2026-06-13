---
id: US-075
title: "AI-generated goal retrospective with pattern recommendations"
personas: [lin-zhao]
domain: goals
priority: low
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want AI-generated goal retrospectives that analyze what worked, what did not, and recommend pattern adjustments so that goal-setting quality improves systematically across cycles.

## Acceptance Criteria

- [ ] Agent generates a retrospective document at cycle end covering: achievements, misses, root causes, and patterns
- [ ] Retrospective includes quantitative analysis (score distributions, velocity trends, blocker frequency)
- [ ] Recommendations are specific and actionable (e.g., "Reduce KR count per Objective from avg 5 to 3 based on completion data")
- [ ] Retrospective cites specific items and events as evidence for each finding
- [ ] Agent cost and contribution to goal progress are included in the retrospective (ROI awareness)

## Notes

Lin cares about agent ROI and governance. The retrospective should itself be auditable: what data did the agent use, what model generated it, what confidence level. Consider a "retro diff" showing how this cycle's patterns differ from last cycle's. The retrospective is a living document that the team can annotate and discuss, not a static PDF.
