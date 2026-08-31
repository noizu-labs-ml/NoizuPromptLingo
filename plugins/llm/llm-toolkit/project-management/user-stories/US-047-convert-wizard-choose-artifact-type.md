---
id: US-047
title: "Convert Wizard: Choose Artifact Type"
slug: convert-wizard-choose-artifact-type
personas: [P-002, P-004]
epic: "Convert"
priority: must-have
complexity: medium
tags: [convert, wizard]
---

# US-047: Convert Wizard: Choose Artifact Type

## User Story

**As a** skill-authoring developer advocate (or staff engineer curating team knowledge)
**I want to** see step 1 of the Convert wizard present all five target artifact types — agent, skill, slash command, snippet, runbook — each with a short description
**So that** I can pick the right output format before investing time in configuring it

## Acceptance Criteria

- **Given** I open the Convert wizard from a thread or a selected message range
  **When** step 1 loads
  **Then** all five artifact types (agent, skill, slash command, snippet, runbook) are shown as selectable cards, each with a one-line description of what it produces

- **Given** I select an artifact type
  **When** I click "Next"
  **Then** the wizard advances to step 2 (range selection) with the chosen type retained in the wizard state

- **Given** I navigate back to step 1 from a later step
  **When** I change the selected artifact type
  **Then** any type-specific configuration already entered in step 3 is reset or flagged as needing review

## Notes

Tobias uses this as the entry point for turning a demonstrated pattern into a reusable skill; Priya uses it primarily to select the runbook type when curating incident docs.
