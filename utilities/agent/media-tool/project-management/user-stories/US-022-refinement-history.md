---
id: US-022
title: "See refinement history in prompt file"
slug: refinement-history
personas: [P-001, P-006]
epic: "Interactive Refinement"
priority: should-have
complexity: low
tags: [refine, history, yaml, comments]
---

# US-022: See refinement history in prompt file

## User Story

**As a** developer iterating on assets
**I want to** see the history of refinements as comments in the `.media.prompt` file
**So that** I understand how the prompt evolved over iterations

## Acceptance Criteria

- **Given** a prompt file that has been refined 3 times
  **When** I open the `.media.prompt` file
  **Then** I see a `# --- Refinement History ---` section with timestamps, original text, feedback, and refined text for each iteration

- **Given** the current prompt text
  **When** a refinement occurs
  **Then** the prompt text is updated in-place (not duplicated)

## Notes
History is appended as YAML comments, preserving the file's validity as parseable YAML.
