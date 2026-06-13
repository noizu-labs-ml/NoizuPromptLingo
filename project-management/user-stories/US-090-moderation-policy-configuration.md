---
id: US-090
title: "Moderation Policy Configuration"
slug: "moderation-policy-configuration"
personas: [P-006]
epic: "Admin & Moderation"
priority: "could-have"
complexity: "M"
tags: [admin, moderation, policy, configuration, content]
---

# US-090: Moderation Policy Configuration

## User Story

**As a** platform administrator (P-006),
**I want to** define and version-control content policies and moderation rules through an admin UI,
**So that** moderation behavior is transparent, auditable, and adjustable without a code deployment.

## Acceptance Criteria

- [ ] Given I am on /admin/policies, when I view the policy list, then I see each active policy with its name, version, effective date, and the number of moderation actions taken under it.
- [ ] Given I create a new policy rule (e.g., "no adult content in public universes"), when I set the severity to "remove and warn," then that action is automatically applied when content matching the rule is detected.
- [ ] Given I update an existing policy rule, when I save, then a new version is created and the previous version is archived (never deleted), preserving the audit trail.
- [ ] Given a moderation action is taken under a policy rule, when I view the audit log, then the specific policy version that triggered the action is referenced by ID.
- [ ] Given I deactivate a policy rule, when I confirm, then the rule stops being applied to new content within 60 seconds and existing flags created by that rule remain in the queue.

## Notes

Depends on US-087 (content moderation), US-089 (abuse detection). Policy versioning is critical for legal defensibility. Consider a simple DSL or tag-based rule builder rather than free-form regex to reduce admin error.
