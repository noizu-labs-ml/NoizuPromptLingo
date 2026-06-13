---
id: US-085
title: "Privacy Settings & Data Export"
slug: "privacy-settings-data-export"
personas: [P-007, P-006, P-003]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, privacy, gdpr, data-export, compliance]
---

# US-085: Privacy Settings & Data Export

## User Story

**As an** enterprise procurement manager (P-006),
**I want to** control my profile visibility and download all personal data held about me,
**So that** I can meet my organization's data governance requirements and verify compliance.

## Acceptance Criteria

- [ ] Given an authenticated user on the Privacy Settings page, then they see a profile visibility toggle (visible to admin only vs. visible in shared project views)
- [ ] Given the data export section, when the user clicks "Request Data Export," then a background job is queued and the user is notified by email when their archive is ready
- [ ] Given the data archive, when downloaded, then it contains a JSON file with all stored personal data: profile, RFI submissions, contact messages, comments, and activity log
- [ ] Given a data export request, when the archive is ready, then the download link expires after 48 hours and is delivered over HTTPS
- [ ] Given the account deletion section, when the user initiates account deletion, then a confirmation dialog explains what will be deleted and requires typing "DELETE" to confirm
- [ ] Given confirmed account deletion, when processed, then all personal data is removed within 30 days and a confirmation email is sent

## Notes

GDPR Article 17 (right to erasure) and Article 20 (data portability) compliance. Project-related data shared with Keith (RFI details, contract scope) may be retained for legal/accounting purposes — this must be disclosed in the deletion confirmation. Related to US-083 (profile).
