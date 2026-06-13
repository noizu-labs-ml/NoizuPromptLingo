---
id: US-087
title: "Duplicate Space as Template"
slug: "duplicate-space-template"
personas: [P-001, P-003]
epic: "Spaces - Advanced"
priority: "could-have"
complexity: "L"
tags: [spaces, templates, duplication]
---

# US-087: Duplicate Space as Template

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** duplicate a successful space structure as a new space template,
**So that** I can quickly spin up similar communities without recreating settings, rules, and metadata.

## Acceptance Criteria

- [ ] Given I am a space owner, when I view space settings, then I see a "Duplicate as Template" option
- [ ] Given I click "Duplicate as Template", when I'm prompted for a new space name, then I enter a unique name and the system creates a new space with copied settings
- [ ] Given I duplicate a space, when the new space is created, then it includes: description, community rules, tags, member roles structure, and space links
- [ ] Given I duplicate a space, when the process completes, then members of the original space are NOT copied to the new space (fresh member list)
- [ ] Given I attempt to duplicate a space with the same name as an existing space, when I submit, then I see an error "A space with this name already exists"

## Notes

Copying includes structure and metadata, NOT content. Threads are not copied. The duplicate link in the original space's settings shows "This space has been forked X times."