---
id: US-068
title: "Configure webhook for mockup generation events"
slug: "configure-webhook-for-events"
personas: [P-001, P-008]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "M"
tags: [webhook, events, integration, automation, settings]
---

# US-068: Configure Webhook for Mockup Generation Events

## User Story

**As a** CI/CD Pipeline Agent (P-008),
**I want to** register a webhook URL that receives notifications when generation jobs complete or fail,
**So that** downstream pipeline steps can be triggered without polling the API for job status.

## Acceptance Criteria

- [ ] Given the webhook settings page, when I register a URL with a selected event type (generation.complete, generation.failed, feedback.received), then the platform sends a POST to that URL when those events fire
- [ ] Given a webhook delivery, when the payload is sent, then it includes the event type, artifact ID, timestamp, and a HMAC-SHA256 signature header for verification
- [ ] Given a webhook endpoint returns a non-2xx response, when this occurs, then the platform retries up to 3 times with exponential backoff and logs the failure
- [ ] Given the webhook settings page, when I click "Send test event", then a sample payload is immediately delivered to the configured URL

## Notes

HMAC signature is mandatory for security — callers must verify the signature header. Retry logic and delivery logs connect to US-074 (audit log). This story primarily serves automation personas (P-001, P-008).
