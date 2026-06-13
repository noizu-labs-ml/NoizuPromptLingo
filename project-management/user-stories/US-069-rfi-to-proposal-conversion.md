---
id: US-069
title: "RFI-to-Proposal Conversion Workflow"
slug: "rfi-to-proposal-conversion"
personas: [P-007]
epic: "RFI Dashboard"
priority: "should-have"
complexity: "L"
tags: [admin, rfi, proposal, conversion, workflow]
---

# US-069: RFI-to-Proposal Conversion Workflow

## User Story

**As a** site administrator,
**I want to** convert a qualified RFI into a formal proposal with scoped services, pricing, and timeline, then deliver it to the prospect through the platform,
**So that** I can close the gap between initial inquiry and signed engagement without emailing raw documents back and forth.

## Acceptance Criteria

- [ ] Given I am viewing a qualified RFI, when I click "Convert to Proposal", then a proposal draft is created pre-populated with the RFI's service type, budget range, and timeline.
- [ ] Given a proposal draft exists, when I edit the scope narrative, line items, estimated hours, and proposed start date and save, then the draft is persisted.
- [ ] Given a finalized proposal, when I click "Send to Prospect", then the proposal status changes to "Issued", the prospect receives an email notification with a link, and the proposal is visible on their RFI status page.
- [ ] Given a prospect views the proposal, when they click "Accept" or "Decline", then the proposal status updates accordingly and the admin receives a notification.
- [ ] Given a prospect accepts a proposal, when confirmed, then a client account is automatically created (or linked if one exists) and the proposal is archived against the new engagement.
- [ ] Given a proposal has been issued for more than 14 days with no response, when this is detected, then it is automatically flagged for follow-up in the admin RFI queue.

## Notes

Proposal acceptance does not auto-create a signed contract — that step remains manual (e-signature tool integration is future scope). This workflow closes the CRM gap for solo consulting ops. Related: US-052, US-068, US-070.
