---
id: US-005
title: "About Page — Bio & Credibility Signals"
slug: "about-bio-credibility"
personas: [P-003, P-006, P-001]
epic: "Public Portfolio"
priority: "must-have"
complexity: "S"
tags: [about, bio, credibility, trust-signals]
---

# US-005: About Page — Bio & Credibility Signals

## User Story

**As a** non-technical CEO researching Keith before a call (P-003),
**I want to** read a clear, human biography with concrete credentials and past outcomes,
**So that** I can feel confident I'm engaging with a real expert and not a generic consultant.

## Acceptance Criteria

- [ ] Given a visitor navigates to `/about`, when the page renders, then a professional photo, name, and narrative bio are present.
- [ ] Given the bio is rendered, when a visitor reads it, then it includes: years of experience, technology domains, types of companies served, and at least one concrete outcome or achievement.
- [ ] Given an enterprise procurement manager (P-006) views the page, then credentials or recognizable company/project affiliations are present as trust anchors.
- [ ] Given any visitor, when they finish reading the About page, then a CTA to contact or view services is visible at the bottom.
- [ ] Given the page is indexed by search engines, when the About page is crawled, then structured data (Person schema) is present in the page head.

## Notes

Photo should be present at the path expected by the template; a placeholder should not ship to production. LinkedIn link acceptable as an additional trust signal. Related: US-007 (SEO/structured data).
