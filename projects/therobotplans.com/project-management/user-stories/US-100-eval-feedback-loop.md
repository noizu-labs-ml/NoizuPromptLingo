---
id: US-100
title: "Eval results feed back into prompt refinement suggestions"
personas: [lin-zhao]
domain: agent-eval
priority: high
mvp_phase: "v1.0"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want eval results to automatically feed back into prompt refinement suggestions, creating a continuous improvement loop so that agent quality improves systematically over time rather than relying on manual prompt tuning.

## Acceptance Criteria

- [ ] When an agent's eval scores drop below a configurable threshold, the platform generates specific prompt refinement suggestions based on failure pattern analysis
- [ ] Suggestions reference concrete examples: "In 7 of 12 low-rated code reviews this week, the agent missed null-check edge cases — consider adding explicit instruction for null safety analysis"
- [ ] Suggestions are presented as proposed diffs against the current prompt, reviewable and applicable with one click (creating a new prompt version)
- [ ] The feedback loop respects human oversight — suggestions are never auto-applied; they require explicit human approval
- [ ] Applied suggestions are tracked as a distinct change type in the prompt-archival audit trail, linking the suggestion back to the eval data that triggered it

## Notes

This is the capstone story that closes the loop between the three new domains: agent-eval detects quality issues, prompt-archival provides the history and versioning infrastructure, and the feedback loop generates actionable improvements. The human-in-the-loop constraint is critical — autonomous prompt self-modification is a governance risk that most organizations aren't ready for. The suggestion quality depends on having sufficient eval data with detailed feedback (ties back to US-096 ratings and US-097 rubrics). The concrete example requirement prevents vague suggestions like "improve accuracy" — every suggestion must be grounded in specific observed failures. Consider a suggestion confidence score so users can prioritize high-confidence refinements over speculative ones.
