---
id: US-024
title: "Attach Resource to Space"
slug: "attach-resource-space"
personas: [P-001, P-002, P-003, P-005]
epic: "Resources - Basic"
priority: "must-have"
complexity: "S"
tags: [resources, spaces, sharing]
---

# US-024: Attach Resource to Space

## User Story

**As a** Engineering Team Lead (P-003),
**I want to** attach a resource to one or more spaces,
**So that** space members can discover, discuss, and fork resources relevant to their community.

## Acceptance Criteria

- [ ] Given a resource owner, when they view their resource and click "Attach to Space", then they see a searchable list of spaces they are a member of
- [ ] Given a resource owner, when they select one or more spaces and click "Attach", then the resource appears in the space's resource library
- [ ] Given a space member, when they view the space's resource library, then they see all attached resources with name, description, owner, and version
- [ ] Given a resource owner, when they detach a resource from a space, then it is removed from that space's library but the resource itself remains
- [ ] Given a resource is attached to a space, when space members view the resource detail, then they see which spaces it is attached to

## Notes

Depends on US-005 for spaces and US-023 for resources. Resources can be attached to unlimited spaces. Detaching does not delete the resource. Spaces can have unlimited resources; pagination applies (20 per page).