---
id: US-081
title: "View Invoice History"
slug: "invoice-history"
personas: [P-002, P-003]
epic: "Billing & Subscription"
priority: "should-have"
complexity: "S"
tags: [billing, invoices, history, receipts, accounting]
---

# US-081: View Invoice History

## User Story

**As a** Pro blogger who needs to track expenses (P-002),
**I want to** view and download my past invoices,
**So that** I can submit them for reimbursement or business tax records.

## Acceptance Criteria

- [ ] Given I am on the billing page, when I scroll to the "Invoice History" section, then I see a table of past charges with columns: Date, Description, Amount, Status (Paid/Failed), and a Download link.
- [ ] Given an invoice exists, when I click "Download PDF," then the browser downloads a Stripe-generated PDF invoice with my name, email, amount, and a unique invoice number.
- [ ] Given I have no prior invoices (new account or always Free), when I view the invoice history section, then an empty state message reads "No invoices yet — charges will appear here after your first payment."
- [ ] Given a past payment failed and was retried successfully, when I view invoice history, then I see both the failed attempt and the successful charge as separate line items.
- [ ] Given I am a Team member (not owner), when I view billing, then invoice history is visible only to the Team owner; members see a message "Contact your team owner for billing details."
- [ ] Given the invoice list exceeds 12 items, when viewing invoice history, then older invoices are paginated or accessible via a "Load more" control.

## Notes

Invoice data sourced from Stripe API (`invoices.list`). PDF links use Stripe's hosted invoice URL. No local storage of invoice data needed. Relates to US-076, US-082.
