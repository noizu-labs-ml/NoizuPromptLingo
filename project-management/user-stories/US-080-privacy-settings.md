---
id: US-080
title: "Privacy Settings"
slug: "privacy-settings"
personas: [P-001, P-002, P-004, P-005, P-008]
epic: "Settings & Preferences"
priority: "must-have"
complexity: "S"
tags: [settings, privacy, data, gdpr, visibility]
---

# US-080: Privacy Settings

## User Story

**As a** user concerned about how my data and content are used (P-001, P-002, P-004, P-005, P-008),
**I want to** control the visibility of my profile, my universes, and whether my content may be used to improve platform AI models,
**So that** I retain ownership and control over my creative work.

## Acceptance Criteria

- [ ] Given I am on Settings > Privacy, when I toggle "Profile visibility" to private, then my profile page returns a 404 or access-denied view to unauthenticated visitors.
- [ ] Given I opt out of "Use my content to improve AI models," when I save, then a flag is persisted to my account and honored in any model training pipeline.
- [ ] Given I request a data export, when I click "Download my data," then I receive a ZIP containing all my canon entries, universe metadata, and generation history in JSON within 24 hours.
- [ ] Given I request account deletion, when I confirm the action, then my account and all owned universes are scheduled for deletion within 30 days per GDPR Article 17, and I receive a confirmation email.
- [ ] Given I have collaborators on a universe I own, when I delete my account, then those universes are flagged for ownership transfer or deletion, and collaborators are notified.

## Notes

GDPR and CCPA compliance is essential. Data export and deletion workflows must be logged in the admin audit trail. Related: US-083 (admin dashboard).
