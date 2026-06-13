---
id: US-058
title: "Revenue and Billing Dashboard"
slug: "revenue-billing-dashboard"
personas: [P-007]
epic: "Admin Dashboard"
priority: "should-have"
complexity: "L"
tags: [admin, billing, revenue, invoicing, finance]
---

# US-058: Revenue and Billing Dashboard

## User Story

**As a** site administrator,
**I want to** view a billing dashboard showing active contracts, invoice statuses, monthly recurring revenue, and outstanding balances,
**So that** I can track business financials without context-switching to a separate accounting tool.

## Acceptance Criteria

- [ ] Given I navigate to `/admin/billing`, when the page loads, then I see summary metrics: MTD revenue, outstanding invoices total, and count of overdue invoices.
- [ ] Given the billing dashboard, when I view the invoice list, then each invoice shows: client name, amount, issue date, due date, status (Draft, Sent, Paid, Overdue).
- [ ] Given I create a new invoice record, when I fill in client, line items, and due date and save, then the invoice is stored and can be marked Sent.
- [ ] Given an invoice due date passes with status "Sent", when this is detected, then the status automatically updates to "Overdue" and a notification is generated.
- [ ] Given I mark an invoice as "Paid", when confirmed, then the paid date is recorded and the invoice moves to the Paid archive.
- [ ] Given the billing dashboard, when I filter by date range, then revenue metrics and invoice list update to reflect the selected period.

## Notes

This is an internal tracking tool — not a payment processor. Actual invoicing may happen in QuickBooks or similar; this mirrors status for at-a-glance visibility. Integration with external invoicing tools is a future enhancement. Related: US-051, US-052.
