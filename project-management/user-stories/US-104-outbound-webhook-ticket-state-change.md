---
id: US-104
title: "Receive an Outbound Webhook on Ticket State Change"
slug: "outbound-webhook-ticket-state-change"
personas: [P-003]
epic: "Integration & External APIs"
priority: "could-have"
complexity: "M"
tags: [webhooks, integration, tickets, events]
---

# US-104: Receive an Outbound Webhook on Ticket State Change

## User Story

**As** Priya Anand, the Delivery Lead (P-003),
**I want to** register an outbound webhook that fires when a ticket's state changes,
**So that** I can pipe ticket events into external tools like Slack, status pages, or custom dashboards without polling the platform's API.

## Acceptance Criteria

- [ ] Given Priya registers a webhook URL for ticket state-change events on a project, when a ticket transitions state, for example open to in-progress to done, then the platform sends a POST identifying the ticket, old state, new state, and timestamp.
- [ ] Given a webhook delivery fails because the target is unreachable or returns a non-2xx response, when this happens, then the platform retries with backoff up to a bounded number of attempts and marks the delivery failed with a viewable reason after exhausting retries.
- [ ] Given Priya wants to verify authenticity, when she inspects the webhook configuration, then each delivered payload is signed, for example via an HMAC header, so her receiving endpoint can validate it came from the platform.
- [ ] Given Priya disables or deletes the webhook, when subsequent ticket state changes occur, then no further deliveries are attempted for that webhook.

## Notes

Could-have — useful integration glue but not a blocker for core ticket workflows. Shares delivery/retry infrastructure conceptually with US-101's PR-status sync-back, which consumes a similar webhook pattern from GitHub's side.
