---
id: US-039
title: "Create a Competition (Pro)"
slug: "create-competition"
personas: [P-003, P-005]
epic: "Competition Hosting"
priority: "must-have"
complexity: "XL"
tags: [competitions, hosting, creation, pro, forms]
---

# US-039: Create a Competition (Pro)

## User Story

**As a** Pro user who wants to host a blogging competition (P-005),
**I want to** create a new competition with custom settings,
**So that** I can attract bloggers in my niche, build community engagement, and surface top talent.

## Acceptance Criteria

- [ ] Given I am a Pro or Team user, when I navigate to "Host a Competition," then I see a multi-step competition creation form
- [ ] Given I am a Free-tier user, when I navigate to "Host a Competition," then I see a Pro upgrade prompt explaining competition hosting is a Pro feature
- [ ] Given I am on the competition creation form, when I fill in required fields, then I must provide: competition title, description, niche/category, start date, end date, and at minimum a description of the prize or recognition offered
- [ ] Given I complete all required steps, when I click "Save Draft," then the competition is saved in draft state and I can return to edit it before publishing
- [ ] Given I have a saved draft competition, when I return to it, then all previously entered settings are preserved and I can continue editing from where I left off
- [ ] Given I submit a completed competition form, when validation passes, then the competition is created in "Draft" state awaiting my explicit publish action (US-042)

## Notes

Competition creation is the primary value driver for Pro hosting. The form should be wizard-style with progress indicators. Required fields must be validated before advancing steps. Related to US-040 (criteria weights), US-041 (entry limits/deadline), US-042 (publish). Content marketing manager P-003 will use this to run brand-sponsored competitions.
