---
id: US-047
title: "Receive email alert when scan completes"
slug: "receive-email-alert-when-scan-completes"
personas: [P-002, P-005]
epic: "Defender — Results & Reporting"
priority: "should-have"
complexity: "S"
tags: [defender, results, notifications, email, alerts]
---

# US-047: Receive Email Alert When Scan Completes

## User Story

**As a** Enterprise AppSec Manager (P-002),
**I want to** receive an email notification when a scan finishes,
**So that** I don't need to keep the results page open while a long scan runs, and I'm immediately informed of new critical findings regardless of what I'm working on.

## Acceptance Criteria

- [ ] Given I launch a scan, when the scan completes (success or failure), then I receive an email at my account address within 2 minutes of completion.
- [ ] Given a scan completes with findings, when I receive the email, then it contains: scan name, target domain, total finding counts by severity, and a direct link to the results page.
- [ ] Given a scan completes with zero findings, when I receive the email, then it clearly states the scan passed with no findings rather than showing an empty summary.
- [ ] Given a scan fails due to a connectivity or authentication error, when I receive the email, then it describes the failure reason and links to the scan error log.
- [ ] Given I want to control notifications, when I open notification settings, then I can configure: notify on all completions, notify only on findings above a severity threshold, or disable scan completion emails entirely.

## Notes

Email notifications should be transactional (not marketing), delivered via a reliable provider (e.g., SendGrid, Postmark). Digest mode (batch notifications for scheduled scans) is a future enhancement. Notification preferences should be per-user, not per-scan.
