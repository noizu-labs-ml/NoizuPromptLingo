---
id: US-100
title: "User configures webhook to receive real-time events on tool invocations"
slug: "webhook-events"
personas: [P-004, P-001]
epic: "Performance & Integration"
priority: "should-have"
complexity: "M"
tags: [integration, webhooks, real-time, events, api, observability]
---

# US-100: User Configures Webhook to Receive Real-Time Events on Tool Invocations

## User Story

**As an** AI/ML Engineer (P-004),
**I want to** configure webhook endpoints that receive real-time event payloads whenever specific tool invocation events occur,
**So that** I can build custom integrations, trigger downstream workflows, and maintain audit trails in external systems without polling the API.

## Acceptance Criteria

- [ ] Given a user navigates to Settings > Webhooks, when they create a new webhook, then they can specify the endpoint URL, select which event types to subscribe to (invocation.started, invocation.completed, invocation.failed, policy.violated, server.health_changed), and optionally set a secret for payload verification
- [ ] Given a webhook is configured for invocation events, when a matching tool invocation occurs, then the platform delivers an HTTP POST to the configured URL within 5 seconds of the event with a JSON payload containing the event type, timestamp, server ID, tool name, invocation ID, and outcome
- [ ] Given a webhook delivery fails (non-2xx response, timeout, connection error), when the failure is detected, then the platform retries delivery with exponential backoff (1min, 5min, 30min, 2h, 12h) for up to 5 attempts and records the delivery status in the webhook delivery log
- [ ] Given each webhook payload is delivered, when the user configured a webhook secret, then the payload includes a HMAC-SHA256 signature in the `X-MCPHost-Signature` header that the receiving system can use to verify the payload authenticity

## Notes

Webhooks are a complement to the in-app notification system (US-082) and audit store for users who need to integrate MCP Host events into external workflows (e.g., trigger a Slack notification on policy violation, log invocation metrics to Datadog). The webhook delivery log should be visible in Settings > Webhooks with the last 100 delivery attempts per endpoint. Related to US-082 (notification preferences) and the Audit Store component.
