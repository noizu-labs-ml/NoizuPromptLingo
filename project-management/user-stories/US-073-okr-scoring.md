---
id: US-073
title: "Score OKRs at end of cycle with historical comparison"
personas: [sarah-kim]
domain: goals
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Sarah Kim (Small Team Eng Lead)**, I want to score OKRs at the end of each cycle with historical comparison and agent analysis so that my team can objectively assess performance and improve goal-setting over time.

## Acceptance Criteria

- [ ] End-of-cycle scoring workflow prompts for final KR scores (0.0-1.0) with auto-suggested values based on progress data
- [ ] Agent provides a scoring analysis: comparison to previous cycles, pattern identification, and calibration suggestions
- [ ] Historical score trends are visualized per team and per individual across cycles (quarter-over-quarter)
- [ ] Scoring supports both self-assessment and lead-assessment with optional discrepancy highlighting
- [ ] Scored OKRs are archived and queryable for retrospectives and planning

## Notes

Google-style 0.0-1.0 scoring with 0.7 as "strong." The agent analysis should help calibrate ambition: if a team consistently scores 1.0, goals are too easy; if consistently 0.3, goals are unrealistic. Sarah uses this to coach her team and plan next cycle. Historical data becomes valuable after 2-3 cycles, so design for long-term accumulation from day one.
