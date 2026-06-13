---
id: US-057
title: "Earn Verifiable Credential Upon Lab Completion"
slug: "earn-verifiable-credential-upon-lab-completion"
personas: [P-008, P-001, P-002]
epic: "Academy — Labs"
priority: "could-have"
complexity: "L"
tags: [academy, credentials, badges, verification, gamification]
---

# US-057: Earn Verifiable Credential Upon Lab Completion

## User Story

**As an** enterprise AppSec manager (P-002),
**I want** my team members to earn verifiable credentials when they complete labs or learning paths,
**So that** I can demonstrate to auditors and leadership that the team has completed structured AI security training.

## Acceptance Criteria

- [ ] Given a user completes a lab or learning path with a passing score, when the completion is recorded, then a credential is issued and appears in their profile's credential wallet
- [ ] Given a credential is issued, when I click "Verify," then I am taken to a public verification URL that confirms the credential is authentic, shows the issuing date, lab name, and score tier (pass/merit/distinction)
- [ ] Given a credential exists, when I click "Share," then I can copy a shareable verification link or download a PDF certificate suitable for HR records
- [ ] Given credentials are issued for individual labs, when a full learning path is completed, then a path-level credential is also issued that supersedes and summarizes the individual lab credentials
- [ ] Given a credential was earned with hints used or solution viewed, when the credential is displayed publicly, then it does not show that distinction — private scoring detail is separate from the public credential

## Notes

Initial implementation can use a simple signed JWT credential with a public verification endpoint rather than a full open-badges or W3C Verifiable Credential implementation. Upgrade path to standards-compliant credentials should be designed in from the start.
