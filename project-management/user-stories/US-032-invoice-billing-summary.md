---
id: US-032
title: "Invoice and Billing Summary View"
slug: "invoice-billing-summary"
personas: [P-007, P-006, P-003]
epic: "Customer Dashboard"
priority: "should-have"
complexity: "M"
tags: [dashboard, billing, invoices, finance]
---

# US-032: Invoice and Billing Summary View

## User Story

**As a** client managing vendor spend and procurement (P-006, P-007),
**I want to** view a summary of invoices and billing history within the dashboard,
**So that** I can track outstanding amounts, download invoices for my accounting team, and reconcile payments without emailing Keith's finance contact.

## Acceptance Criteria

- [ ] Given I navigate to the Billing section of my dashboard, when the page loads, then I see a list of invoices with date, amount, status (paid/outstanding/overdue), and a download link
- [ ] Given an invoice has status "outstanding", when I view it, then the due date is prominently shown
- [ ] Given I click download on an invoice, when the file loads, then I receive a PDF invoice
- [ ] Given I have an overdue invoice, when I view the billing summary, then an alert banner is shown at the top of the page
- [ ] Given I want to filter by date range, when I apply a filter, then only invoices within that range are shown

## Notes

Invoice data sourced from external billing system (e.g. Stripe, QuickBooks, or manual uploads by Keith). This view is read-only — payment handled externally. Do not display raw payment method details. Enterprise persona (P-006) may require PO number references. Consider a "total billed YTD" summary figure at the top.
