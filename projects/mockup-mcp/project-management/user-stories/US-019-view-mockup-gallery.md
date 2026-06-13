---
id: US-019
title: "View gallery of all generated mockups"
slug: "view-mockup-gallery"
personas: [P-001, P-002, P-003]
epic: "Mockup Management"
priority: "must-have"
complexity: "M"
tags: [gallery, mockup-management, browse, thumbnails]
---

# US-019: View gallery of all generated mockups

## User Story

**As a** UX designer (P-003),
**I want to** browse a gallery of all mockups I have generated,
**So that** I can quickly find, review, and share past work without relying on memory or external file management.

## Acceptance Criteria

- [ ] Given I have generated at least one mockup, when I navigate to the Gallery, then mockups are displayed as thumbnail cards sorted by creation date descending
- [ ] Given I have more than 24 mockups, when the gallery loads, then pagination or infinite scroll loads mockups in batches of 24
- [ ] Given a mockup card, when I hover over it, then the card shows the mockup name, creation date, tool used, and action buttons (view, download, duplicate, delete)
- [ ] Given I click a thumbnail, when the detail view opens, then the full-resolution artifact is displayed with its prompt, parameters, and version history link

## Notes

Thumbnails are pre-generated at creation time (max 300×200px). Gallery must be filterable by project/folder (US-020) and searchable (US-021). Related to US-020, US-021, US-022, US-023, US-024, US-025.
