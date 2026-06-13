---
id: US-045
title: "Save Search Filters as Presets"
slug: "save-search-filters-as-presets"
personas: [P-001, P-003, P-005, P-007]
epic: "Search & Discovery"
priority: "could-have"
complexity: "M"
tags: [search, filters, presets, personalization]
---

# US-045: Save Search Filters as Presets

## User Story

**As a** prompt engineer who runs the same searches repeatedly (P-001),
**I want to** save my current search query and filter combination as a named preset,
**So that** I can re-run my regular searches with a single click instead of reconstructing them each session.

## Acceptance Criteria

- [ ] Given I have configured a search query with filters applied, when I click "Save as Preset," then I am prompted for a name and the preset is stored to my account
- [ ] Given I have saved presets, when I open the search bar or the Presets panel, then my saved presets are listed and clicking one populates the search bar and filters instantly
- [ ] Given I want to update a preset, when I run it, modify the query or filters, and click "Update Preset," then the existing preset is overwritten with the new configuration
- [ ] Given I delete a preset, when the deletion is confirmed, then the preset is removed from my list and is no longer accessible

## Notes

Presets are stored server-side per user account, not in localStorage, so they persist across devices. A user should be able to save up to 20 presets; exceeding this limit should prompt them to delete an existing one. Presets can optionally be shared via a public URL.
