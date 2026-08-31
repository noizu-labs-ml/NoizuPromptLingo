---
id: US-024
title: "Filter search results by role"
slug: filter-search-by-role
personas: [P-001, P-003]
epic: "Search & Discovery"
priority: should-have
complexity: low
tags: [search, filter]
---

# US-024: Filter Search Results by Role

## User Story

**As an** ML fine-tuning engineer
**I want to** filter search results by message role (user / assistant / tool)
**So that** I can focus on assistant responses or tool output when triaging candidate training examples, without my own prompts cluttering the results

## Acceptance Criteria

- **Given** a search has returned results spanning user, assistant, and tool-role messages
  **When** I toggle off "user" in the role filter
  **Then** only assistant- and tool-role matches remain in the result list

- **Given** I select only the "tool" role filter
  **When** results render
  **Then** the list shows only matches found within tool-call/tool-result content

- **Given** no role filters are active (default state)
  **When** results render
  **Then** matches from all roles are shown, matching current unfiltered behavior

## Notes
Marcus also benefits — skipping his own prompts to jump straight to the assistant's answer or a command's output speeds up recall. Low complexity: role is already a field on indexed messages, this exposes it as a filter facet.
