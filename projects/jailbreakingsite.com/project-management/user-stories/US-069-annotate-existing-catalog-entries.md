---
id: US-069
title: "Annotate Existing Catalog Entries"
slug: "annotate-existing-catalog-entries"
personas: [P-001, P-006, P-004]
epic: "Community & Disclosure"
priority: "could-have"
complexity: "M"
tags: [community, annotations, catalog, collaboration, knowledge]
---

# US-069: Annotate Existing Catalog Entries

## User Story

**As an** AI red team lead (P-001),
**I want to** add annotations to existing catalog entries with observations from my own testing,
**So that** the community benefits from practical field experience that supplements the canonical entry without requiring a full new submission.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing a catalog technique entry, when I click "Add Annotation," then I see a form to write a short annotation (max 500 characters) with an optional category tag (e.g., "confirmed working," "partial bypass," "model-specific," "mitigation observation")
- [ ] Given I submit an annotation, when it passes a basic content policy check, then it appears in the Annotations section of the catalog entry with my display name, date, and category tag — pending community upvotes before being featured
- [ ] Given an annotation is displayed, when I view it, then I can see the annotator's profile link, the date, the category tag, and the current upvote count
- [ ] Given I want to edit or delete an annotation I authored, when I revisit the entry, then I see edit/delete controls on my own annotations
- [ ] Given a catalog entry has more than 10 annotations, when I view the entry, then annotations are paginated and sorted by upvote count by default, with a "most recent" sort option

## Notes

Annotations are community-contributed observations, not editorial content — they should be visually distinct from the canonical catalog entry to avoid confusion. Annotation moderation is lightweight at launch: content policy automated check on submit, human review only if flagged by community.
