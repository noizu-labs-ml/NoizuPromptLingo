---
id: US-024
title: "Refine updates prompt text in-place"
slug: refine-updates-prompt-in-place
personas: [P-001, P-006]
epic: "Interactive Refinement"
priority: must-have
complexity: medium
tags: [refine, yaml, in-place-edit]
---

# US-024: Refine updates prompt text in-place

## User Story

**As a** developer iterating on prompts
**I want to** the refined prompt text to be written back to the `.media.prompt` file
**So that** future runs use the improved prompt automatically

## Acceptance Criteria

- **Given** a refinement cycle with feedback "make the background lighter"
  **When** the refined prompt is generated
  **Then** the `prompt.text` field in the `.media.prompt` file is updated with the new text

- **Given** the original prompt text is lost
  **When** I check the refinement history
  **Then** the original text is preserved in the history comments

## Notes
In-place update means the YAML file is always in the latest state. History comments preserve the audit trail.
