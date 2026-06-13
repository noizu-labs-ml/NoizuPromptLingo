---
id: US-100
title: "Pagination for Large Category Listings (100+ Sites)"
slug: "pagination-large-category-listings"
personas: [P-001, P-003, P-004, P-007]
epic: "Accessibility & Performance"
priority: "must-have"
complexity: "M"
tags: [performance, pagination, ux, listings, category, scalability]
---

# US-100: Pagination for Large Category Listings (100+ Sites)

## User Story

**As a** Research Journalist (P-003),
**I want to** navigate through large category listings with clear pagination,
**So that** I can systematically review all listings in a category without performance degradation from loading hundreds of results at once.

## Acceptance Criteria

- [ ] Given a category has more than 25 listings, when I view the category page, then listings are paginated at 25 per page with page navigation controls (previous, next, page numbers) at both the top and bottom of the listing set
- [ ] Given I navigate to page 3 of a category listing, when I copy the URL and open it in a new tab, then the URL contains a `?page=3` parameter and the third page of results loads directly
- [ ] Given I am on page 2 or later, when I press the browser back button, then I return to the previous page in the listing (not to the category root)
- [ ] Given a category listing is paginated, when I sort or filter the listings (e.g., by score dimension, Editor's Picks only), then pagination resets to page 1 and the total count updates to reflect the filtered set
- [ ] Given I am viewing a listing page, when the next page is anticipated (user is near the bottom), then the next page's data is prefetched so the page transition is perceived as instant
- [ ] Given the API endpoint for listings (US-084) is queried, when I request page 3 with `per_page=25`, then the response returns the correct 25 items with `current_page`, `total_pages`, `total_count`, and `has_more` in the metadata

## Notes

Prefer traditional pagination over infinite scroll for category browsing — users need to navigate back to a known position (page N) when returning from an external site, which infinite scroll makes impossible. Prefetching the next page addresses the main UX downside of paginated patterns. The API pagination contract defined here should mirror the web UI pagination to keep them consistent.
