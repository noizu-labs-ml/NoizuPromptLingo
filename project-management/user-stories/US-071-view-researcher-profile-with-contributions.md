---
id: US-071
title: "View Researcher Profile with Contributions"
slug: "view-researcher-profile-with-contributions"
personas: [P-004, P-006, P-001]
epic: "Community & Disclosure"
priority: "should-have"
complexity: "M"
tags: [community, profiles, researcher, contributions, reputation]
---

# US-071: View Researcher Profile with Contributions

## User Story

**As an** academic researcher (P-004),
**I want to** have a public researcher profile that displays my catalog contributions, Academy credentials, and community activity,
**So that** my work is visible to the field and I can build professional reputation through my contributions to the platform.

## Acceptance Criteria

- [ ] Given any user navigates to a researcher's public profile URL, when the page loads, then they see: display name, optional bio, optional affiliation, join date, and a contributions summary (techniques discovered, annotations added, labs completed)
- [ ] Given the profile shows contributions, when I view the Techniques section, then I see a list of catalog entries attributed to this researcher with technique name, category, publication date, and link to the entry
- [ ] Given the profile shows Academy activity, when I view the Credentials section, then I see earned credentials and completion badges the researcher has chosen to make public
- [ ] Given I am viewing my own profile, when I click "Edit Profile," then I can update my display name, bio, affiliation, profile photo, and control which sections (contributions/credentials/activity) are publicly visible
- [ ] Given a researcher has chosen to make their leaderboard activity public, when I view their profile, then I see their top lab scores and competitive rank alongside their other contributions

## Notes

Profiles are public by default but individual sections can be hidden. Researchers who prefer anonymity should be able to suppress the profile entirely — the platform should never expose a real name without explicit consent. Profile pages are indexable by search engines by default (unless the user opts out), supporting organic discoverability for researchers building public reputation.
