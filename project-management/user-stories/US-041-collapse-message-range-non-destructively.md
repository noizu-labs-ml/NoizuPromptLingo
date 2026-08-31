---
id: US-041
title: "Collapse Message Range Non-Destructively"
slug: collapse-message-range-non-destructively
personas: [P-002]
epic: "Thread Editing"
priority: must-have
complexity: medium
tags: [editing, non-destructive]
---

# US-041: Collapse Message Range Non-Destructively

## User Story

**As a** staff engineer curating team knowledge
**I want to** select a contiguous range of messages in the thread viewer and collapse them into a single summarized block within an edited version
**So that** I can turn a long, noisy debugging session into a compact narrative without touching the original transcript

## Acceptance Criteria

- **Given** a thread open in the Thread Editor with multiple messages
  **When** I select a contiguous range of messages and choose "Collapse"
  **Then** those messages are replaced by a single summarized block in the edited version, and message order outside the range is unchanged

- **Given** I have collapsed a range and saved the edited version
  **When** I inspect the source `.jsonl` file on disk
  **Then** it is byte-for-byte identical to before the edit

- **Given** a collapsed block in an edited version
  **When** I click to expand it
  **Then** the original messages in that range are shown inline for review

- **Given** I select a non-contiguous set of messages
  **When** I try to collapse them
  **Then** the editor disallows the action and shows contiguous-range guidance

## Notes

Priya uses this to strip verbose tool-call back-and-forth from a debugging session before converting the cleaned thread into a runbook. The non-destructive guarantee (source JSONL never touched) is the load-bearing behavior for this entire epic.
