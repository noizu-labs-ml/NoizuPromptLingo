---
id: US-095
title: "Template Marketplace (Share & Sell Universe Templates)"
slug: "template-marketplace"
personas: [P-001, P-002, P-003, P-005, P-008]
epic: "Collaboration & Sharing"
priority: "won't-have-yet"
complexity: "XL"
tags: [marketplace, templates, monetization, community, sharing]
---

# US-095: Template Marketplace (Share & Sell Universe Templates)

## User Story

**As a** experienced worldbuilder with reusable frameworks (P-001, P-002, P-003, P-008),
**I want to** publish my universe templates to a marketplace where others can discover, download, and optionally pay for them,
**So that** my structural work has value beyond my own projects and newer users (P-005) can accelerate their worldbuilding.

## Acceptance Criteria

- [ ] Given I have a universe template, when I submit it to the marketplace, then I provide a title, description, preview images, category tags, and a pricing option (free or paid via Stripe).
- [ ] Given a buyer purchases a paid template, when the transaction completes, then the template is added to their library and the creator receives their revenue share (minus platform fee) in the next monthly payout.
- [ ] Given I am browsing the marketplace, when I filter by genre tag and sort by rating, then results update within 500ms and display title, creator, price, and star rating.
- [ ] Given I install a template, when I create a new universe from it, then the template's entry types, categories, relationship schemas, and example entries are pre-populated and I retain full ownership of the new universe.
- [ ] Given a template is reported for policy violations, when the report is submitted, then it enters the admin moderation queue and is suspended from sale pending review.

## Notes

This is a large, high-risk epic deferred to a post-MVP phase. Depends on US-091 (collaboration), US-087 (content moderation), US-086 (billing). Revenue share model, tax compliance (1099-K), and template versioning are significant design challenges requiring separate spikes.
