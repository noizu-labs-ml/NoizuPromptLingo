---
id: US-032
title: "Generate a Landing Page Draft"
slug: "generate-landing-page-draft"
personas: [P-005]
epic: "Creative Assets & Campaigns"
priority: "should-have"
complexity: "M"
tags: [landing-page, generation, llm, campaigns]
---

# US-032: Generate a Landing Page Draft

## User Story

**As the** Growth Operator (P-005),
**I want to** generate an LLM-drafted landing page tied to a campaign,
**So that** I have a working starting point for the campaign's destination page without briefing a designer or writer from a blank page.

## Acceptance Criteria

- [ ] Given a campaign with at least one approved ad copy variant, when I trigger "generate landing page draft", then a landing page draft with sectioned copy is created, linked to that campaign, and stored in "draft" status.
- [ ] Given a landing page draft already exists for a campaign, when I request regeneration, then a new draft version is created while the prior version remains retrievable in the campaign's history.
- [ ] Given a landing page draft, when I open it, then it displays which campaign and ad copy variant it was generated from so its provenance is traceable.

## Notes

Typically run after at least one ad copy variant is approved (US-031), so landing-page messaging stays consistent with approved ad copy.
