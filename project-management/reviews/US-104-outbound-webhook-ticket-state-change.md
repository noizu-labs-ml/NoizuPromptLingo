# Review: Receive an Outbound Webhook on Ticket State Change

- **Story**: `project-management/user-stories/US-104-outbound-webhook-ticket-state-change.md`
- **Status**: Partially Implemented
- **Reviewed**: 2026-09-06

## Implementation Assessment

The delivery half of this story exists on the Elixir backend: a `webhooks` table (migration `backend/db/changelog/011-webhooks.yaml`, schema `backend/lib/noizu_prompt_lingua/schema/events/webhook.ex` with url, events list, secret, active flag, org scoping) and a `WebhookHandler` GenServer (`backend/lib/noizu_prompt_lingua/events/webhook_handler.ex`) that subscribes to platform events, matches active webhooks by event name and org (:32-48), and POSTs a JSON payload containing event, payload, and timestamp with an HMAC-SHA256 `x-webhook-signature` header (:50-66). However, the trigger half is missing: no code anywhere in `lib/` publishes events via `NoizuPromptLingua.Events` (grep finds the handler's own subscribe and `events.ex` definitions only), so a ticket state change never fires a delivery. There is also no webhook registration surface (no CRUD MCP tool or HTTP controller for creating/disabling webhooks was found), no retry/backoff — failures are single-attempt with a log line (:70-75) — and no persisted delivery record with a viewable failure reason.

## Acceptance Criteria Check

| Criterion | Status | Evidence |
|-----------|--------|----------|
| Ticket state transition → POST identifying ticket, old state, new state, timestamp | Not Met | Handler exists (`webhook_handler.ex:19-30`) but no publisher emits events; nothing in `domains/tickets/` calls `NoizuPromptLingua.Events`, and no old→new state payload is constructed |
| Failed delivery retried with backoff, bounded attempts, viewable failure reason | Not Met | `webhook_handler.ex:70-75` — one attempt, logs warning on non-2xx or transport error; no retry, no delivery record |
| Each payload signed via HMAC header for authenticity verification | Met | `webhook_handler.ex:58-64` — `:crypto.mac(:hmac, :sha256, secret, body)` sent as `x-webhook-signature` |
| Disabling/deleting the webhook stops further deliveries | Partially Met | Matching filters `w.active == true` (`webhook_handler.ex:35`), so an inactive webhook gets no deliveries; but no API/tool exists to flip the flag or delete — DB-only operation today |

## Gaps / Risks

- Dead pipeline: `WebhookHandler` starts in the supervision tree (`application.ex:43`) but receives no events — the feature silently does nothing end-to-end.
- No registration/management API: webhooks can only be inserted directly into the database.
- No retry or dead-letter semantics; a transient target outage silently loses the event (logged only).
- The signature uses `webhook.secret || ""` — a webhook created without a secret produces signatures verifiable with the empty-string key, i.e., no real authentication.
- Deliveries are fire-and-forget `Task.start` with a 10s timeout; bursts of events spawn unbounded tasks.

## BDD Scenario

```gherkin
Feature: Outbound webhook on ticket state change

  Scenario: Ticket transitions state (NOT yet possible end-to-end)
    Given a webhook is registered for ticket events on a project
    When a ticket moves from open to in-progress
    Then nothing is delivered, because no code publishes ticket events
    And the WebhookHandler GenServer sits idle

  Scenario: Signed delivery (design as implemented)
    Given an active webhook with a secret matching the event name and org
    When a matching platform event is published
    Then the platform POSTs JSON with event, payload, and timestamp
    And includes an x-webhook-signature HMAC-SHA256 header the receiver can verify

  Scenario: Delivery failure (gap)
    Given the receiving endpoint returns 500
    When the delivery is attempted once
    Then the failure is only logged; no retry, no backoff, and no viewable failure record

  Scenario: Webhook disabled
    Given a webhook row with active = false
    When matching events are published
    Then the handler's query excludes it and no delivery is attempted
```
