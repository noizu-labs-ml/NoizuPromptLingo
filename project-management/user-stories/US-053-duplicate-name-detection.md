---
id: US-053
title: "Duplicate Name Detection"
slug: "duplicate-name-detection"
personas: [P-001, P-003, P-004]
epic: "Consistency Engine"
priority: "must-have"
complexity: "M"
tags: [consistency, naming, duplicates, validation]
---

# US-053: Duplicate Name Detection

## User Story

**As a** narrative designer (P-003),
**I want to** be alerted when two entries share the same name or a near-identical alias,
**So that** my team's shared universe doesn't accumulate confusing duplicate entities that erode player trust.

## Acceptance Criteria

- [ ] Given a user saves a new entry with a name that exactly matches an existing entry's name or any of its aliases within the same universe, when the save completes, then a "warning" severity issue is immediately created in the consistency system identifying both entries.
- [ ] Given a user saves an entry whose name is within an edit distance of 2 characters of an existing entry's name (e.g., "Aldrath" vs "Aldrath"), when the save completes, then a "suggestion" severity issue is created recommending the user review whether these are the same entity.
- [ ] Given a duplicate name flag exists, when I open the issue detail, then I see both entries side by side with a one-click option to merge, differentiate (add a disambiguator), or dismiss the flag as intentional.
- [ ] Given a universe has cross-type entries (e.g., a character and a location named "Ember"), when the duplicate check runs, then same-name cross-type pairs are flagged at "suggestion" severity rather than "warning."

## Notes

Depends on US-056 (resolution workflow). Fuzzy matching should be configurable per universe to allow intentional naming patterns. Related: US-051 (timeline contradiction detection), US-057 (consistency dashboard).
