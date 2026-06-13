---
id: US-109
title: Promote a flagged capture to a dataset entry
issue_type: story
slug: promote-flag-to-dataset-entry
status: in-progress
priority: P1
story_points: 5
estimated_scope: M
category: flagged-captures
components:
  - backend
  - frontend
labels:
  - wave-2
  - capture
  - promotion
  - datasets
assignee: null
reporter: null
epic: post-mvp-capture
wave: 2
fix_version: "0.1.0"
sprint: null
most_impacted_personas:
  - derek-support-engineer
  - sofia-product-manager
secondary_personas:
  - nia-academic
related_stories:
  - US-101
  - US-103
  - US-106
  - US-107
  - US-108
dependencies:
  - US-107
  - US-103
blocks: []
duplicates: []
schema_refs:
  - flagged_captures
  - dataset_entries
external_refs:
  jira: null
  linear: null
  github: null
  notion: null
created_at: "2026-04-20"
updated_at: "2026-04-21"
---

# Promote a flagged capture to a dataset entry

## Story

As a **Support Automation Engineer**,
I want to **convert a flagged production capture into a row in an existing dataset with the captured input and the agent's actual response as `expected_output`**
so that **real-world production behavior becomes a traditional req/resp benchmark row I can use in dataset eval (US-105)**.

## Acceptance Criteria

- [ ] From a flagged capture's detail, "Promote to dataset" opens a picker: target dataset (required; creates a new draft version if target has no open draft)
- [ ] Promotion creates a new `dataset_entries` row with `input = capture.input`, `expected_output = capture.agent_response` (editable before confirm)
- [ ] Tags carry over; promoter can add more
- [ ] Option "mark as negative" — creates the entry with a rubric expectation `direction='negative'` ("must NOT produce this response")
- [ ] Flagged capture's `promoted_to_dataset_entry_id` recorded; promotion is one-to-many
- [ ] Redaction state preserved

## Notes

- "Mark as negative" is the bug-promotion flow: the flagged response was wrong; future agents should NOT produce it
- Combines with dataset eval (US-105) to make production deviations become part of a CI-gateable regression corpus

## Out of Scope

- Editing the `expected_output` to write what the agent *should have* said (would require a different UX — Wave 3)
- Automated canonical-expected generation (Wave 3)
