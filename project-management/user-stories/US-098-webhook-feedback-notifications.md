---
id: US-098
title: "Webhook notification on mockup feedback events"
slug: "webhook-feedback-notifications"
personas: [P-001, P-008, P-002]
epic: "Integration & API"
priority: "could-have"
complexity: "M"
tags: [webhooks, integration, notifications, feedback]
---

# US-098: Webhook notification on mockup feedback events

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** register a webhook URL to receive notifications when stakeholders submit feedback on a mockup,
**So that** I can trigger downstream automations (Slack alerts, issue creation, CI triggers) without polling the API.

## Acceptance Criteria

- [ ] Given I have registered a webhook URL in account settings, when a stakeholder submits feedback on one of my mockups, then an HTTP POST is sent to my webhook URL with a JSON payload containing the event type, mockup ID, and feedback content
- [ ] Given the webhook endpoint returns a non-2xx response, when the delivery fails, then the platform retries up to 3 times with exponential backoff before marking the delivery as failed
- [ ] Given I view my webhook delivery history, when I open a specific delivery, then I can see the full request payload, response status, and timestamps for each attempt

## Notes

Webhook payloads should be signed with an HMAC-SHA256 signature in the `X-Mockup-Signature` header so recipients can verify authenticity. Events to support initially: `feedback.created`, `feedback.updated`, `mockup.shared`. Depends on US-097 (REST API infrastructure).
