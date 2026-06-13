---
id: US-082
title: "Related Papers Recommendations"
slug: "related-papers-recommendations"
personas: [P-008, P-001]
epic: "Research & Community"
priority: "could-have"
complexity: "M"
tags: [research, recommendations, discovery, navigation]
---

# US-082: Related Papers Recommendations

## User Story

**As an** AI ethics researcher / academic (P-008),
**I want to** see recommendations for related papers at the end of each paper I read,
**So that** I can discover other relevant work from Keith without having to navigate away and browse manually.

## Acceptance Criteria

- [ ] Given a user finishing a research paper, when they reach the end of the article, then a "Related Papers" section displays 2–4 paper cards
- [ ] Given the related papers section, when a card is clicked, then the user navigates to that paper's full reading page
- [ ] Given paper cards, then each shows the paper title, a one-sentence excerpt, publication year, and estimated read time
- [ ] Given a paper with manually curated related papers in its frontmatter, then those are shown; otherwise fall back to tag-based similarity
- [ ] Given a paper that is the only paper in its topic area, then the section shows "Explore all research" with a link to the research index instead of forcing unrelated cards

## Notes

Phase 1: manual curation via frontmatter `related: [slug1, slug2]`. Phase 2: automated tag/keyword similarity scoring. Related to US-076 (reading experience), US-080 (sharing). Keep card design consistent with other content card patterns across the site.
