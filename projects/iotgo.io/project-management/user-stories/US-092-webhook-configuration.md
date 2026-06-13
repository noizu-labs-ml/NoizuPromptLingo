---
id: US-092
title: "Webhook Configuration"
slug: "webhook-configuration"
personas: [P-001, P-007]
epic: "Integration & API"
priority: "should-have"
complexity: "M"
tags: [webhooks, integration, events, api]
---

# US-092: Webhook Configuration

## User Story

**As an** IoT Platform Engineer (P-001),
**I want to** configure webhooks that push IoTGo events to external endpoints in real time,
**So that** I can trigger downstream automation (e.g., ticketing, Slack notifications, data pipelines) without polling the API.

## Acceptance Criteria

- [ ] Given I navigate to Integrations > Webhooks, when I click Add Webhook, then I can enter a destination URL, select event types (incident created, agent action taken, escalation raised, playbook completed), and save
- [ ] Given a webhook is configured, when a matching event occurs, then IoTGo sends an HTTP POST to the destination within 5 seconds with a JSON payload and an HMAC-SHA256 signature header
- [ ] Given the destination URL is unreachable, when delivery fails, then IoTGo retries with exponential backoff (1s, 2s, 4s, 8s, max 3 retries) and marks the webhook as degraded after consecutive failures
- [ ] Given a webhook is saved, when I click Test Delivery, then a sample payload for the first selected event type is sent immediately and the response status is displayed in the UI
- [ ] Given a webhook has delivered events, when I view its detail page, then I see a delivery log showing timestamp, event type, HTTP response code, and latency for the last 100 deliveries

## Notes

Webhook HMAC secret is displayed only once at creation; users must store it immediately. Relates to US-091 (REST API) and US-095 (third-party alert integrations).
