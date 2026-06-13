---
id: US-038
title: "Root cause linking for bug pattern analysis"
personas: [lin-zhao]
domain: bugs
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (Platform Engineer)**, I want to link multiple bugs to a shared root cause item so that I can analyze failure patterns and prioritize systemic fixes over individual symptom patches.

## Acceptance Criteria

- [ ] Any item can be designated as a "root cause" and have multiple bugs linked to it as symptoms, creating a one-to-many cause-symptom relationship
- [ ] Root cause items display an impact summary: count of linked bugs, affected components/services, total user impact, and aggregate severity
- [ ] An agent can suggest root cause groupings by analyzing linked bugs' stack traces, affected components, timing correlation, and description similarity
- [ ] Resolving a root cause item prompts verification of all linked symptom bugs and optionally bulk-transitions them to "verify fix" status
- [ ] A root cause analysis dashboard shows: top root causes by impact, trending failure patterns, and mean time from symptom to root cause identification

## Notes

This is where the scale-free model shines — a root cause is just an item with a "root-cause" relationship type, not a separate entity. Lin's governance needs require full audit trails on root cause linkages. The agent suggestion capability should improve over time as more root cause patterns are established. Consider integration with postmortem workflows where root cause analysis is a standard output.
