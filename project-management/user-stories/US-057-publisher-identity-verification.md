---
id: US-057
title: "Publisher verifies identity to obtain verified badge"
slug: "publisher-identity-verification"
personas: [P-001]
epic: "Registry & Discovery"
priority: "should-have"
complexity: "M"
tags: [registry, verification, publisher, trust]
---

# US-057: Publisher Verifies Identity to Obtain Verified Badge

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** verify my identity as a publisher and receive a verified badge on my profile and published servers,
**So that** users can trust that my tools come from a legitimate, authenticated source rather than an impersonator.

## Acceptance Criteria

- [ ] Given the user navigates to their publisher profile settings, when they click "Request Verification," then the system presents a verification flow requiring: a verified email address, a linked GitHub account or organization, and a domain ownership proof via DNS TXT record.
- [ ] Given the user submits all required verification materials, when the system validates them, then the verification request enters a review queue and the user receives a confirmation that it is being processed.
- [ ] Given the system validates DNS domain ownership, when the TXT record matches the expected token, then the domain is marked as verified automatically without manual review.
- [ ] Given the verification is approved, when the user views their profile or any of their published servers (US-074), then a verified badge icon is displayed next to their publisher name.
- [ ] Given a verified publisher changes their display name or linked accounts, when the change is saved, then the system re-validates the verification criteria and temporarily removes the badge if criteria are no longer met.
- [ ] Given the user is browsing the registry, when they see a verified badge on a publisher name, then clicking the badge displays a tooltip explaining what verification means and which criteria were met.

## Notes

Verification increases the trust score (US-056) for all servers published by that publisher. The process should be mostly automated with manual review only as a fallback for edge cases. Related: US-054, US-056, US-074.
