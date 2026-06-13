---
id: story-002
title: "Attach contextual metadata to memories"
persona: persona-the-archivist
priority: must-have
complexity: M
status: draft
---

# Attach contextual metadata to memories

**As** The Archivist,
**I want to** enrich each memory with contextual metadata including time-of-day, time-of-year, session topic, conversation domain, and interaction modality,
**So that** the free-association web can leverage temporal and situational context for richer recall patterns.

## Acceptance Criteria
- [ ] Each memory includes `temporal_context` with UTC timestamp, local time-of-day bucket (morning/afternoon/evening/night), day-of-week, and season
- [ ] `session_context` captures the active topic/domain, conversation length at time of memory, and turn number
- [ ] `interaction_modality` records the channel (chat, voice, API, background task)
- [ ] Holiday and notable date proximity is flagged when within 7 days of configured observances
- [ ] All contextual fields are indexable for query-time filtering

## Scenario: Memory formed during a late-night debugging session
- **Given** a memory is formed at 2:34 AM local time on December 23rd during a 45-minute debugging session
- **When** The Archivist attaches contextual metadata
- **Then** the memory includes time-of-day: "night", season: "winter", holiday_proximity: ["christmas": 2 days], session_topic: "debugging", and session_duration_at_capture: 45min

## Scenario: Memory formed via background API call
- **Given** a memory arrives via the batch ingestion API with no active user session
- **When** The Archivist processes it
- **Then** interaction_modality is set to "api_batch", session_context fields default to null with a flag indicating no live session

## Technical Notes
- Time-of-year and holiday proximity are important for seasonal free-association (e.g., "last Christmas we had a similar outage")
- Holiday calendar should be configurable per deployment (different cultural calendars)
- The temporal bucketing (morning/afternoon/evening/night) boundaries should be configurable
- Consider storing both UTC and the agent's configured timezone

## Related Stories
- story-001: Emotional metadata is the companion enrichment to this contextual metadata
- story-013: Weaver cross-domain bridging uses session_context.domain to find inter-domain links
- story-019: Dreamer background consolidation uses temporal patterns to find seasonal recurrences
