---
id: US-015
title: "View Technique Detail Page"
slug: "view-technique-detail-page"
personas: [P-001, P-002, P-003, P-004, P-005, P-006]
epic: "Attack Catalog"
priority: "must-have"
complexity: "L"
tags: [catalog, technique, detail, research]
---

# US-015: View Technique Detail Page

## User Story

**As a** security researcher or practitioner (P-001 through P-006),
**I want to** view a comprehensive detail page for a jailbreak technique,
**So that** I have a single authoritative reference for its description, taxonomy position, affected models, severity, mitigations, and history.

## Acceptance Criteria

- [ ] Given I navigate to a technique's detail page, when the page loads, then I see: technique ID, name, taxonomy breadcrumb, description, severity badge, first-seen date, last-updated date, and affected model families
- [ ] Given the page loads, when I scroll the detail sections, then I can access tabbed or sectioned content for: Mitigations, Detection Signatures, Reproduction Steps (auth-gated), Related Techniques, and References
- [ ] Given I am an unauthenticated visitor, when I view the technique detail page, then all sections except Reproduction Steps are visible; the Reproduction Steps section shows a locked state with a sign-in prompt
- [ ] Given I view a technique, when I click the technique ID in the breadcrumb or header, then the ID is copyable to clipboard and a permalink is shown

## Notes

This is the core content page of the platform — analogous to a MITRE ATT&CK technique page. Reproduction steps are gated behind authentication (US-023). Page should be statically renderable for SEO. Related sections are covered by US-016, US-017, US-018, US-019.
