---
id: US-095
title: "Webhook on New Prompt in Followed Tags"
slug: "webhook-new-prompt-followed-tag"
personas: [P-005, P-007]
epic: "Integration & API"
priority: "won't-have-yet"
complexity: "L"
tags: [api, webhooks, integration, notifications, developer]
---

# US-095: Webhook on New Prompt in Followed Tags

## User Story

**As an** Indie Developer (P-005) or Enterprise AI Lead (P-007),
**I want to** register a webhook URL that receives a POST payload when new prompts are published in tags I follow,
**So that** I can trigger downstream automations (Slack notifications, pipeline runs, aggregators) without polling the API.

## Acceptance Criteria

- [ ] Given a logged-in user with an API key, when they POST to `/api/v1/webhooks` with a URL and a list of tag slugs, then a webhook subscription is created and confirmed with a 201 response
- [ ] Given a new prompt is published in a subscribed tag, when it passes moderation checks (or is published directly), then the webhook endpoint receives a POST within 30 seconds containing the prompt payload
- [ ] Given a webhook delivery fails (non-2xx response or timeout), when the failure occurs, then the system retries with exponential backoff up to 3 attempts before marking the subscription as failing
- [ ] Given a webhook subscription accumulates 10 consecutive failures, when the threshold is hit, then the subscription is automatically disabled and the owner is notified by email
- [ ] Given a user wants to test their webhook, when they trigger a test delivery from settings, then a synthetic example payload is sent to the configured URL

## Notes

Webhook payloads should include a signature header (`X-Meat-Brains-Signature: sha256=...`) using a per-subscription secret key so receivers can verify authenticity. Webhook delivery should be handled by a background job queue, not synchronously during the prompt publish flow. Deferring to post-launch due to infrastructure complexity.
