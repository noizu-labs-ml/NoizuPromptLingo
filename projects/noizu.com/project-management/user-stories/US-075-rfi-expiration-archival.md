---
id: US-075
title: "RFI Expiration and Archival"
slug: "rfi-expiration-archival"
personas: [P-007]
epic: "RFI Dashboard"
priority: "won't-have-yet"
complexity: "S"
tags: [admin, rfi, archival, expiration, lifecycle]
---

# US-075: RFI Expiration and Archival

## User Story

**As a** site administrator,
**I want to** automatically expire stale RFIs after a configurable inactivity period and archive them to a read-only store,
**So that** the active RFI queue stays clean and focused on live opportunities while historical data is preserved for analytics.

## Acceptance Criteria

- [ ] Given an RFI has had no status change or admin activity for a configurable period (default: 90 days), when the nightly expiration job runs, then the RFI status is updated to "Expired" and it moves out of the active queue.
- [ ] Given an RFI reaches Expired status, when this occurs, then the prospect receives an email notification informing them the RFI has closed and inviting them to resubmit if their needs are still active.
- [ ] Given an expired RFI, when I navigate to the archive view, then I can view it in read-only mode with full history, notes, and attachments intact.
- [ ] Given the archive view, when I search by prospect name or reference number, then matching archived RFIs are returned.
- [ ] Given I want to re-open an archived RFI (e.g., prospect returns), when I click "Reactivate", then the RFI is restored to Active status with a new activity timestamp and an audit entry.
- [ ] Given the expiration threshold is configurable, when I update the setting in admin configuration, then future expiration jobs use the new threshold.

## Notes

Archival is non-destructive. Archived RFIs are included in analytics (US-072) as "Lost — Expired" in funnel reporting. Expiration notification email should clearly include a resubmit link. This is won't-have-yet because it requires the full RFI lifecycle (US-066–074) to be stable first. Related: US-066, US-068, US-072, US-074.
