---
id: US-066
title: "Agents auto-generate contextual checklists based on item type and history"
personas: [lin-zhao]
domain: checklists
priority: medium
mvp_phase: "v0.4"
---

## User Story

As a **Lin Zhao (AI-Forward Platform Engineer)**, I want agents to auto-generate contextual checklists based on item type and historical patterns so that process coverage improves automatically as the system learns from past work.

## Acceptance Criteria

- [ ] Agent analyzes item type, labels, linked items, and project history to generate a relevant checklist
- [ ] Generated checklists are presented as suggestions (not auto-attached) requiring human approval
- [ ] Each generated checklist item includes a confidence score and rationale visible on hover
- [ ] Agent learns from checklist modifications: items consistently added/removed adjust future suggestions
- [ ] Generation is auditable: audit log records which agent generated what, based on which inputs

## Notes

This is the AI-native differentiator for checklists. Lin cares about governance and auditability, so the agent must never silently enforce its own checklists. The learning loop should be transparent: show users what the agent learned and allow them to correct the model. Consider a "checklist diff" view showing what the agent added vs. the base template.
