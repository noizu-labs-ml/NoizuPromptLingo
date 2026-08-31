---
id: US-092
title: "Event stream for newly indexed conversations"
slug: event-stream-newly-indexed-conversations
personas: [P-008]
epic: "Integration & API"
priority: wont-have
complexity: high
tags: [api, integration, automation]
---

# US-092: Event Stream For Newly Indexed Conversations

## User Story

**As a** multi-provider agent tinkerer
**I want to** subscribe to a webhook/SSE stream that fires whenever a new conversation is indexed
**So that** I can trigger my own automation (e.g. skill-manage checks) the moment new session activity lands

## Acceptance Criteria

- **Given** a webhook/SSE endpoint exists
  **When** a new conversation is indexed
  **Then** subscribers receive a notification event containing the conversation id and project

- **Given** multiple subscribers are connected
  **When** an indexing event fires
  **Then** all connected subscribers receive it

## Notes
wont-have — deferred, not part of the current release scope per the manifest. Recorded as a placeholder spec for Yusuf's future automation use case should event-driven integration be prioritized in a later release.
