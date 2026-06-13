---
id: US-052
title: "Geographic Impossibility Flags"
slug: "geographic-impossibility-flags"
personas: [P-001, P-002, P-008]
epic: "Consistency Engine"
priority: "should-have"
complexity: "L"
tags: [consistency, geography, travel, validation]
---

# US-052: Geographic Impossibility Flags

## User Story

**As a** veteran game master (P-002),
**I want to** flag when a character travels between two locations faster than their established travel speed or available transport should allow,
**So that** my world's geography remains internally coherent and players don't catch me in logical errors.

## Acceptance Criteria

- [ ] Given two location entries with defined distance or travel time between them and an event sequence placing a character at both, when the consistency engine runs, then it calculates whether the elapsed time between events is sufficient for the stated travel method and flags impossibilities as "warning" severity.
- [ ] Given a geographic impossibility flag, when I view the issue detail, then the system shows the two locations, the character, the time gap between events, and the estimated minimum travel time based on the defined distance and transport.
- [ ] Given locations without defined distances or travel times, when the geographic check runs, then those location pairs are skipped and listed in an "insufficient data" section rather than flagged as errors.
- [ ] Given I define a canon-breaking fast-travel mechanism (e.g., teleportation spell), when I tag an event with that mechanism, then the geographic check exempts that leg of the journey from distance-time validation.

## Notes

Depends on US-051 (timeline contradiction detection). Requires location entries to support distance/travel-time metadata fields. Related: US-057 (consistency dashboard).
