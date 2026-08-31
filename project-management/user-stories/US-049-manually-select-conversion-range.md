---
id: US-049
title: "Manually Select Conversion Range"
slug: manually-select-conversion-range
personas: [P-002, P-006]
epic: "Convert"
priority: must-have
complexity: low
tags: [convert, wizard]
---

# US-049: Manually Select Conversion Range

## User Story

**As a** staff engineer curating team knowledge (or open-source maintainer)
**I want to** override the AI-suggested range and manually select any contiguous set of messages as the conversion source
**So that** I retain full control when the suggestion panel doesn't match what I actually want to convert

## Acceptance Criteria

- **Given** the Convert wizard's candidate panel has suggested a range
  **When** I instead click-drag to select a different contiguous message range in the thread view
  **Then** that manual selection replaces the suggested one in the wizard state

- **Given** I have manually selected a range
  **When** I click "Next"
  **Then** step 3 (configure) proceeds using my manual selection, not the AI suggestion

- **Given** I attempt to select messages that are non-contiguous
  **When** I try to proceed
  **Then** the wizard blocks advancing and indicates the selection must be contiguous

## Notes

Sofia relies on manual selection since her repos' AI suggestions may be sparse or unavailable, and she often knows exactly which range belongs in the runbook without needing the confidence-scored panel.
