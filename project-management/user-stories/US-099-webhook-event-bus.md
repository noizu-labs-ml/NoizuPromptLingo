---
id: US-099
title: "Webhook/Event Bus for External Integrations"
slug: "webhook-event-bus"
personas: [P-006, P-007]
epic: "Accessibility & Integration"
priority: "could-have"
complexity: "L"
tags: [webhooks, events, integration, architecture, extensibility]
---

# US-099: Webhook/Event Bus for External Integrations

## User Story

**As a** game studio lead (P-006) and community contributor (P-007),
**I want to** subscribe to framework lifecycle events (quest completed, character leveled up, memory stored, dialogue ended) via a webhook or in-process event bus,
**So that** I can integrate NoizuRPG with external systems (analytics platforms, notification services, databases, leaderboards) without modifying framework internals.

## Acceptance Criteria

- [ ] Given an `EventBus` configured on `NoizuRPGConfig`, when a `QuestCompleted` event fires, then all registered subscribers receive an event object with `event_type`, `timestamp`, `session_id`, `payload` (typed per event), and `metadata` fields within the same process tick (synchronous subscribers) or queued for async delivery
- [ ] Given an async subscriber registered with `bus.subscribe("quest.completed", handler)`, when the event fires, then the async handler is awaited and any exception raised by the handler is caught, logged, and does not interrupt the game session
- [ ] Given an HTTP webhook URL configured as `bus.subscribe_webhook("https://my-analytics.example.com/hook")`, when any framework event fires, then a POST request is made to the URL with the event JSON payload and a `X-NoizuRPG-Signature` HMAC header for verification
- [ ] Given a webhook endpoint that returns a non-2xx response, when the delivery fails, then the framework retries up to 3 times with exponential backoff and logs a warning after the final failure without crashing the game session
- [ ] Given the framework running without any `EventBus` configured, when events fire internally, then they are silently discarded with zero performance overhead (no-op path is the default)

## Notes

The event bus is the integration backbone for the usage analytics dashboard (US-088) — the analytics pipeline subscribes to the bus rather than being embedded in framework code. The no-op default is critical so existing games are not impacted by this addition. HMAC webhook signing follows the same convention as GitHub/Stripe webhooks for developer familiarity.
