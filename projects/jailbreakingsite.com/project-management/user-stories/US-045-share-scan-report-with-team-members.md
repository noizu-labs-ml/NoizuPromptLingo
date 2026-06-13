---
id: US-045
title: "Share scan report with team members"
slug: "share-scan-report-with-team-members"
personas: [P-002, P-005]
epic: "Defender — Results & Reporting"
priority: "should-have"
complexity: "S"
tags: [defender, results, sharing, collaboration, access-control]
---

# US-045: Share Scan Report with Team Members

## User Story

**As a** Enterprise AppSec Manager (P-002),
**I want to** share a scan report with colleagues inside or outside my organization,
**So that** developers can act on findings, executives can review risk posture, and external auditors can access evidence without requiring a full platform account.

## Acceptance Criteria

- [ ] Given I have a completed scan, when I click "Share Report", then I can generate a shareable link with configurable access (org-only, link-only with expiry, or specific email invites).
- [ ] Given I share a link with an expiry date, when the link is accessed after expiry, then the viewer sees an "Access expired" page and cannot view findings.
- [ ] Given a link recipient opens the shared report, when they view it, then they see the summary and findings but cannot trigger retests, modify the scan, or access other scans in my account.
- [ ] Given I share with a specific email address, when that user logs in, then the shared scan appears in their "Shared with me" list.
- [ ] Given I need to revoke access, when I open the share settings for a scan, then I can revoke any active share link or email invite immediately.

## Notes

Link-based sharing should not require account creation for external viewers — a read-only guest view with no authentication is acceptable if the link is treated as a secret. Finding payloads in shared views may need a "redact sensitive content" toggle for external audiences.
