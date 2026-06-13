---
id: US-086
title: "Webhook Notifications on New Listings in Category"
slug: "webhook-new-category-listings"
personas: [P-007, P-008]
epic: "API & Integration"
priority: "could-have"
complexity: "L"
tags: [api, webhooks, notifications, developer, real-time]
---

# US-086: Webhook Notifications on New Listings in Category

## User Story

**As an** API Developer (P-007),
**I want to** register a webhook endpoint to receive notifications when new sites are approved in a category I'm watching,
**So that** my application can react to new quality listings in real-time without polling the API.

## Acceptance Criteria

- [ ] Given I am in my API settings dashboard, when I click "Add Webhook," then I can specify a target URL, a secret for signature verification, and one or more category slugs to watch
- [ ] Given a new site listing is approved in a watched category, when the approval is recorded, then gotta.cc sends a POST request to my webhook URL within 5 minutes containing the new listing's full JSON payload
- [ ] Given gotta.cc sends a webhook, when I inspect the request headers, then a `X-Gotta-Signature` header is present containing an HMAC-SHA256 signature of the payload using my webhook secret
- [ ] Given my webhook endpoint returns a non-2xx response, when gotta.cc receives the failure, then it retries with exponential backoff (1m, 5m, 30m) before marking the delivery as failed
- [ ] Given a webhook delivery fails permanently, when I view my webhook dashboard, then I can see the failed delivery log with response code and timestamp, and manually re-trigger delivery

## Notes

Webhook signature verification is mandatory to prevent spoofing — document the verification process clearly in the API docs (US-089). Retry logic protects against transient endpoint unavailability. Rate limit webhook registrations per account tier to prevent abuse.
