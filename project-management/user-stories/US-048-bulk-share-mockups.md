---
id: US-048
title: "Bulk Share Multiple Mockups"
slug: "bulk-share-mockups"
personas: [P-002, P-004, P-006]
epic: "Team & Collaboration"
priority: "could-have"
complexity: "M"
tags: [sharing, bulk-operations, mockups, efficiency]
---

# US-048: Bulk Share Multiple Mockups

## User Story

**As a** freelance consultant (P-006),
**I want to** share multiple mockups with a client in a single action,
**So that** I can deliver a complete design package without sending individual links for each artifact.

## Acceptance Criteria

- [ ] Given multiple mockups in my workspace, when I select them using checkboxes and click "Share", then a single share configuration dialog appears covering all selected mockups
- [ ] Given the bulk share dialog, when I configure permissions and recipients, then all selected mockups are shared with the same settings simultaneously
- [ ] Given a bulk share, when it is completed, then I receive a confirmation listing how many mockups were shared and to whom
- [ ] Given a bulk share link is generated, when the recipient opens it, then they see a gallery view of all shared mockups

## Notes

Bulk operations should enforce the same permission checks as individual sharing. A shared gallery URL should be optionally generated as a single entry point. Bulk operations should be transactional — if any mockup fails to share, none are committed and the error is reported.
