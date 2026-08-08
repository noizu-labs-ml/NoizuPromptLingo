---
id: US-033
title: "Track a Domain Name Against a Campaign"
slug: "track-domain-name-for-campaign"
personas: [P-005]
epic: "Creative Assets & Campaigns"
priority: "could-have"
complexity: "S"
tags: [domains, campaigns, tracking]
---

# US-033: Track a Domain Name Against a Campaign

## User Story

**As the** Growth Operator (P-005),
**I want to** associate a domain name with a campaign and track its status,
**So that** I know at a glance which domains are reserved, pointed, or live for which campaigns.

## Acceptance Criteria

- [ ] Given an open campaign, when I add a domain name (e.g., "example.com") to it, then the domain is saved and listed under that campaign's tracked domains.
- [ ] Given a tracked domain, when I update its status (e.g., "reserved", "pointed", "live"), then the new status is persisted and immediately reflected in the campaign's domain list.
- [ ] Given a domain name is already tracked under one campaign, when I attempt to add the same domain name to a second campaign, then the system warns me of the existing association instead of silently creating a duplicate.

## Notes

Complements landing page generation (US-032) — a tracked domain is typically where a generated landing page eventually gets pointed.
