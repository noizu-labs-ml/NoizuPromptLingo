---
id: US-024
title: "Rabbit Hole Navigation — Related Sites Chain"
slug: "rabbit-hole-navigation"
personas: [P-001, P-004]
epic: "Discovery & Exploration"
priority: "could-have"
complexity: "L"
tags: [rabbit-hole, related, navigation, exploration, chain]
---

# US-024: Rabbit Hole Navigation — Related Sites Chain

## User Story

**As a** Web Nostalgia Explorer (P-001),
**I want to** follow a chain of related sites — clicking from one to the next — without ever returning to the main listing,
**So that** I can experience the kind of serendipitous discovery I used to get following blogrolls and link pages.

## Acceptance Criteria

- [ ] Given I am on a site detail page with related sites (US-020), when I click "Go deeper →" on a related site, then I navigate to that site's detail page and a "breadcrumb chain" panel shows my trail of visited sites this session.
- [ ] Given my rabbit hole chain has 3 or more sites, when I view the chain panel, then I can click any site in the chain to return to it, or click "Start over" to clear the chain.
- [ ] Given I have followed a rabbit hole of 5+ sites, when the panel updates, then a "Share this rabbit hole" option appears generating a shareable URL encoding my visited chain.

## Notes

This is an advanced discovery pattern — the spiritual successor to browsing blogrolls. It depends on US-020 (related sites) for each hop. The chain state should be stored in-session (URL params or sessionStorage). Shareable rabbit holes could become a community feature for P-008.
