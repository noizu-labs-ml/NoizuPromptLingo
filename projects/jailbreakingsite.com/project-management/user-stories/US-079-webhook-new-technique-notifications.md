---
id: US-079
title: "Set Up Webhook for New Technique Notifications"
slug: "webhook-new-technique-notifications"
personas: [P-002, P-007, P-005]
epic: "API & Integration"
priority: "should-have"
complexity: "M"
tags: [api, webhook, notifications, integration, automation]
---

# US-079: Set Up Webhook for New Technique Notifications

## User Story

**As a** security or DevSecOps engineer maintaining automated threat feeds (P-002, P-007, P-005),
**I want to** configure a webhook that fires when new techniques are added or existing ones are updated,
**So that** my downstream systems (SIEMs, ticketing, Slack) are updated automatically without polling the API.

## Acceptance Criteria

- [ ] Given account settings, when I navigate to "Webhooks", then I can add a webhook URL, name it, and select event types (`technique.created`, `technique.updated`, `technique.deprecated`)
- [ ] Given a configured webhook, when a matching event occurs, then a `POST` is sent to my URL within 60 seconds with a JSON payload containing the full technique object and event metadata
- [ ] Given webhook delivery, when the payload is sent, then a `X-JBS-Signature` header contains an HMAC-SHA256 signature computed with my webhook secret for verification
- [ ] Given a failed delivery (non-2xx response or timeout), when the system retries, then it uses exponential backoff with up to 5 attempts before marking the delivery as failed
- [ ] Given the webhooks UI, when I view a webhook, then I see a delivery history log with status, timestamp, response code, and a "Redeliver" button for failed events
- [ ] Given I want to test my endpoint, when I click "Send test event", then a sample `technique.created` payload is dispatched immediately

## Notes

Webhook secrets are generated at creation time and shown once. Payload schema must be stable and versioned alongside the REST API. Delivery logs should be retained for 30 days.
