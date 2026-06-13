---
id: US-075
title: "Report False Positive in Catalog Entry"
slug: "report-false-positive-in-catalog-entry"
personas: [P-001, P-006, P-003]
epic: "Community & Disclosure"
priority: "should-have"
complexity: "S"
tags: [community, catalog, false-positive, quality, feedback]
---

# US-075: Report False Positive in Catalog Entry

## User Story

**As an** AI red team lead (P-001),
**I want to** report a false positive or inaccuracy in a catalog entry when I find that a technique no longer works or has been misclassified,
**So that** the catalog maintains accuracy over time and the community is not misled by stale or incorrect entries.

## Acceptance Criteria

- [ ] Given I am authenticated and viewing any catalog entry, when I click "Report Issue," then I see a short form with a required issue type selector (false positive / technique no longer works / incorrect classification / incorrect severity / other) and an optional details field
- [ ] Given I submit a report, when it is received, then I get a confirmation with a report ID and the entry is flagged internally for editorial review — no immediate public change is made
- [ ] Given a catalog entry has one or more unresolved reports, when I view the entry as an authenticated user, then a small "Under Review" indicator is visible (visible to authenticated users only, not public search results)
- [ ] Given an editorial reviewer resolves a report (confirmed fix / dismissed), when the report is resolved, then the reporter receives an email notification with the resolution and a brief explanation
- [ ] Given I have submitted reports, when I navigate to My Reports in my account, then I see all my submitted reports with their current resolution status

## Notes

False positive reporting is a catalog data quality mechanism as much as a community trust feature — stale technique entries erode confidence in the platform. Reports should be triaged within a defined SLA (suggested: 5 business days for acknowledgment, 30 days for resolution). Reporters who consistently file high-quality, confirmed reports could be recognized in their researcher profile.
