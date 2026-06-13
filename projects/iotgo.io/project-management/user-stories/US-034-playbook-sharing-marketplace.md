---
id: US-034
title: "Playbook Sharing and Marketplace"
slug: "playbook-sharing-marketplace"
personas: [P-007, P-003, P-002]
epic: "Playbook System"
priority: "could-have"
complexity: "XL"
tags: [playbook, marketplace, sharing, community, templates]
---

# US-034: Playbook Sharing and Marketplace

## User Story

**As a** Playbook Author/Automation Engineer (P-007),
**I want to** publish playbooks to a shared marketplace and discover playbooks created by others,
**So that** the community can reuse proven automation patterns rather than reinventing them.

## Acceptance Criteria

- [ ] Given I have an approved playbook, when I choose "Publish to Marketplace", then I provide a title, description, device compatibility tags, and a license type before submitting for marketplace review
- [ ] Given a marketplace listing, when I browse it, then I see usage count, rating, author, last updated date, and a preview of the playbook's logic summary
- [ ] Given I find a marketplace playbook, when I install it, then a copy is added to my workspace as a new draft with all author metadata preserved and a link back to the source listing
- [ ] Given a marketplace playbook is updated by its author, when a new version is published, then workspaces using the playbook receive an optional update notification
- [ ] Given IoTGo operates the marketplace, when a playbook is submitted, then a basic automated safety scan flags playbooks with dangerous action patterns (e.g., mass device restart without conditions)

## Notes

Marketplace is a could-have for v1 but is a key growth driver for platform stickiness. Internal org-scoped sharing (share within team without public listing) should be considered a prerequisite delivered first.
