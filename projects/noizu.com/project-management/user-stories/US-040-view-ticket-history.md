---
id: US-040
title: "View Ticket History"
slug: "view-ticket-history"
personas: [P-007, P-002]
epic: "Support & Communication"
priority: "must-have"
complexity: "S"
tags: [support, tickets, history, dashboard]
---

# US-040: View Ticket History

## User Story

**As an** active client who has submitted support tickets (P-007),
**I want to** view all my past and current tickets with their statuses and response history,
**So that** I can track the resolution of each issue and reference prior communications without relying on email search.

## Acceptance Criteria

- [ ] Given I navigate to the Support section, when the page loads, then I see a list of all my tickets sorted by last-updated date descending
- [ ] Given a ticket is open, when I view the list, then it shows status "open" with the number of days since creation
- [ ] Given a ticket is resolved or closed, when I view the list, then it is clearly marked with the resolution date
- [ ] Given I click a ticket in the list, when the detail view opens, then I see the full conversation thread, status history, and any attached files
- [ ] Given I have more than 20 tickets, when I scroll or paginate, then older tickets load without losing my scroll position context

## Notes

Ticket list should support filtering by status (open/in-progress/resolved/closed) and sorting by date or priority. Related to US-039 (create ticket) and US-041 (email notifications). Consider a "reopen ticket" action on recently resolved tickets. Ticket detail should show each message with sender (client or Keith), timestamp, and any attachments.
