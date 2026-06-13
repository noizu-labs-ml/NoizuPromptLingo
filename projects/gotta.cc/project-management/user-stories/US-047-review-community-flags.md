---
id: US-047
title: "Review Community Flags on Listed Sites"
slug: "review-community-flags"
personas: [P-005]
epic: "Moderation & Review"
priority: "must-have"
complexity: "M"
tags: [moderation, flags, community, quality-control]
---

# US-047: Review Community Flags on Listed Sites

## User Story

**As a** content moderator (P-005),
**I want to** review listings that the community has flagged as low-quality or problematic,
**So that** I can take corrective action quickly and maintain directory quality after initial listing approval.

## Acceptance Criteria

- [ ] Given a listing reaches the auto-escalation flag threshold (US-037), when I open the flag review sub-queue, then I see it listed with a summary of flag reasons and the count per reason category
- [ ] Given I am reviewing a flagged listing, when I view the detail, then I see the original approval decision, the current AI score, all community flags with submitter reputation context, and a live preview of the site
- [ ] Given I decide the flags are valid, when I choose to delist the site, then the listing is hidden from public view, the submitter is notified, and a note is added explaining which flag reason led to removal
- [ ] Given I decide the flags are invalid or a misunderstanding, when I dismiss the flags, then the listing is cleared, flaggers are not penalized, and the site is marked as "reviewed — no action" to suppress future duplicate flags for 30 days

## Notes

Flag dismissal with a 30-day suppression window prevents coordinated brigading from repeatedly re-triggering the same listing. Flag review feeds into moderator dashboard stats (US-046) and patterns inform anti-spam tuning (US-049).
