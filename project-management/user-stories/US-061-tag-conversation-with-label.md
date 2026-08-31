---
id: US-061
title: "Tag a conversation with a label"
slug: tag-conversation-with-label
personas: [P-001, P-005]
epic: "Conversation Operations"
priority: must-have
complexity: low
tags: [ops, tagging]
---

# US-061: Tag a Conversation With a Label

## User Story

**As a** solo power-user developer (or engineering lead auditing team AI usage)
**I want to** attach one or more free-text tags to a conversation from the thread header
**So that** I can label sessions by client, project, or review status and find them again later

## Acceptance Criteria

- **Given** a conversation is open in the thread viewer
  **When** I click the tag control in the thread header and type a new tag (e.g. "acme-client")
  **Then** the tag is saved against the conversation and appears as a chip in the header immediately

- **Given** a conversation already has one or more tags
  **When** I open the tag control
  **Then** existing tags are shown pre-populated and I can add additional tags without removing the existing ones

- **Given** a conversation has a tag I no longer need
  **When** I click the remove (x) affordance on that tag chip
  **Then** the tag is removed from the conversation and no longer appears in tag-filtered Browse views

- **Given** I attempt to add a duplicate tag that already exists on the conversation
  **When** I submit it
  **Then** the UI de-dupes silently (no duplicate chip, no error)

## Notes
Marcus tags by client/project name to keep 4-6 concurrent client repos separated when searching; Daniel uses tags during his weekly oversight scan to mark threads he's reviewed. Tags should be plain free-text (no fixed taxonomy) since both personas invent their own conventions.
