---
id: US-034
title: "AI auto-triage incoming bugs"
personas: [sarah-kim]
domain: bugs
priority: high
mvp_phase: "v0.2"
---

## User Story

As a **Sarah Kim (Eng Lead)**, I want AI to auto-triage incoming bugs by severity based on content analysis, affected systems, and SLA context so that critical issues get immediate attention without waiting for a human to classify them.

## Acceptance Criteria

- [ ] Triage agent analyzes each new bug within 30 seconds of creation and assigns a suggested severity (critical, high, medium, low) with a confidence score and written rationale
- [ ] Severity assessment considers: keywords and patterns in the description, affected component/service criticality, number of users likely impacted, SLA tier of the reporting client (if applicable), and similarity to past bugs of known severity
- [ ] Critical and high severity bugs trigger immediate notifications to the on-call engineer or team lead; medium and low are queued for next grooming session
- [ ] Sarah can override the AI-assigned severity with one click, and overrides feed back into the triage model as training signal
- [ ] Triage agent also suggests an assignee based on component ownership and current workload distribution

## Notes

Auto-triage is about reducing response latency for real emergencies, not removing human judgment. The confidence score is critical — a low-confidence triage should be flagged for human review rather than silently applied. Consider a "triage review" queue that shows all AI-triaged bugs sorted by confidence for efficient bulk review. False positives (over-triaging severity) are preferable to false negatives in the early days.
