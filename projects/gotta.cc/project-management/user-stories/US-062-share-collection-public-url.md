---
id: US-062
title: "Share Collection with Public URL"
slug: "share-collection-public-url"
personas: [P-008, P-001, P-002]
epic: "Collections & Lists"
priority: "must-have"
complexity: "S"
tags: [collections, share, public, url, social]
---

# US-062: Share Collection with Public URL

## User Story

**As a** community curator (P-008),
**I want to** make my collection publicly accessible via a shareable URL,
**So that** I can share my curated list with my audience or community.

## Acceptance Criteria

- [ ] Given I am viewing my collection, when I click "Make Public" or toggle visibility to Public, then the collection becomes accessible at a stable public URL (e.g., `gotta.cc/u/{username}/c/{slug}`)
- [ ] Given a collection is public, when I copy the share link, then the link is copied to clipboard and a confirmation toast is shown
- [ ] Given a public collection URL is visited by an unauthenticated user, when the page loads, then all sites and the collection description are visible without requiring login
- [ ] Given I switch a collection from public to private, when the change is saved, then the public URL returns a 404 or access-denied page immediately
- [ ] Given a public collection page, when it is viewed by any user, then social preview metadata (Open Graph title, description, image) is set appropriately

## Notes

Stable public URLs are critical for shareability in blog posts, social media, and blogrolls — the primary distribution channels for P-001 and P-008. Slug should be auto-generated from collection name but editable. Related: US-060 (create collection), US-064 (follow collection).
