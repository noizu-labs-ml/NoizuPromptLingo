---
id: US-033
title: "Suggest Category During Submission"
slug: "suggest-category-on-submit"
personas: [P-002, P-008]
epic: "Site Submission"
priority: "should-have"
complexity: "M"
tags: [submission, categorization, ai, taxonomy]
---

# US-033: Suggest Category During Submission

## User Story

**As an** indie web developer (P-002),
**I want to** receive an AI-suggested category for my site as I submit it,
**So that** my site lands in the right place in the directory without me having to manually navigate the full category tree.

## Acceptance Criteria

- [ ] Given I have entered a URL in the submission form, when I move focus away from the URL field, then the system fetches the page and returns up to 3 category suggestions ranked by confidence
- [ ] Given category suggestions are shown, when I select one, then it is set as my submission's proposed category and I can confirm or change it via the full category picker
- [ ] Given I disagree with all suggestions, when I open the full category picker, then I can browse and select any category in the taxonomy manually
- [ ] Given the AI cannot determine a suitable category (e.g., site is unreachable), when suggestions fail, then I see a clear message and the manual picker is shown immediately

## Notes

Suggested categories are advisory — final categorization is confirmed during human review (US-044). The category taxonomy browsable here is the same one used in the main directory navigation.
