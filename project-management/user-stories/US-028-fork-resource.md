---
id: US-028
title: "Fork a Resource"
slug: "fork-resource"
personas: [P-001, P-002, P-005]
epic: "Resources - Advanced Versioning"
priority: "must-have"
complexity: "M"
tags: [resources, forking, collaboration]
---

# US-028: Fork a Resource

## User Story

**As a** Prompt Engineer Power User (P-001),
**I want to** fork a resource to create my own derived version,
**So that** I can iterate on existing public resources without modifying the original.

## Acceptance Criteria

- [ ] Given a public resource I have read access to, when I click "Fork", then a copy is created in my workspace with a fork link back to the original
- [ ] Given a forked resource, when I view it, then I can clearly see it's a fork with a link to the original source
- [ ] Given a forked resource, when I make changes, then those changes do not affect the original resource
- [ ] Given a forked resource, when I create new versions, then my version history tracks separately from the original

## Notes

Forking creates a new resource with `fork_of` reference. Original resource is not notified of forks (privacy). Fork visibility inherits from original unless modified by forker.