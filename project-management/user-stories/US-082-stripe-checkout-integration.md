---
id: US-082
title: "Stripe Checkout Integration"
slug: "stripe-checkout-integration"
personas: [P-008]
epic: "Billing & Subscription"
priority: "must-have"
complexity: "L"
tags: [billing, stripe, integration, webhooks, backend]
---

# US-082: Stripe Checkout Integration

## User Story

**As a** platform admin responsible for billing infrastructure (P-008),
**I want to** a fully integrated Stripe Checkout and webhook pipeline,
**So that** subscription state is always synchronized between Stripe and the BloggersCompete database.

## Acceptance Criteria

- [ ] Given a user initiates a plan upgrade, when the server creates a Stripe Checkout Session, then the session includes `customer_email`, `client_reference_id` (user ID), and correct `price` ID for the selected plan/interval.
- [ ] Given Stripe sends a `checkout.session.completed` webhook, when the server receives and verifies the signature, then the user's `plan` field is updated in the database within 5 seconds.
- [ ] Given Stripe sends a `customer.subscription.deleted` webhook, when received, then the user's plan is downgraded to Free effective immediately.
- [ ] Given Stripe sends a `invoice.payment_failed` webhook, when received, then the user's account enters a grace period and they receive an automated email notification.
- [ ] Given any webhook delivery failure on Stripe's side, when Stripe retries the webhook up to 72 hours later, then the system is idempotent and processes the event correctly without duplicate state changes.
- [ ] Given a webhook is received, when processing, then the raw event is logged with its Stripe event ID, timestamp, and processing status for auditability.
- [ ] Given the Stripe Customer Portal is enabled, when a user clicks "Manage Billing," then they are redirected to the Stripe-hosted portal where they can update payment methods and view invoices directly.

## Notes

Webhook endpoint must be excluded from CSRF protection. Signature verification uses `STRIPE_WEBHOOK_SECRET` env var. Idempotency key: use `stripe_event_id` as deduplication key in webhook log table. Relates to US-077, US-078, US-079, US-080, US-081.
