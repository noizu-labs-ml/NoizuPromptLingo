---
id: US-058
title: "Explore Empty State"
slug: "explore-empty-state"
personas: [P-006, P-004]
epic: "Explore & Discovery"
priority: "should-have"
complexity: "S"
tags: [explore, empty-state, ux, onboarding]
---

# US-058: Explore Empty State

## User Story

**As a** blog reader and discoverer (P-006),
**I want to** see a helpful empty state when my filters return no results,
**So that** I understand why nothing is showing and know what to do next instead of staring at a blank page.

## Acceptance Criteria

- [ ] Given I apply filters that match no blogs, when the results render, then I see an empty state illustration with the message "No blogs match your filters" and a "Clear filters" CTA
- [ ] Given the platform has zero publicly listed blogs (e.g., launch day), when /explore loads with no filters, then I see a "Be the first!" empty state with a CTA to submit a blog
- [ ] Given a keyword search returns zero results, when the empty state displays, then the message includes the searched term (e.g., "No blogs found for 'permaculture'")
- [ ] Given the empty state is shown, when I click "Clear filters," then all active filters and search terms are reset and the full blog grid reloads
- [ ] Given the empty state is shown, when I am not logged in, then a secondary CTA "Submit your blog" links to the registration/submission flow

## Notes

Empty states are a first-class UX moment — avoid generic "No results" text. Illustration should be friendly and brand-consistent. Three distinct empty state variants: no-filter-match, zero-platform-blogs, and keyword-no-match. See US-051 for the base explore page.
