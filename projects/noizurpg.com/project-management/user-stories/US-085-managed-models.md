---
id: US-085
title: "Managed Models with No API Key Setup"
slug: "managed-models"
personas: [P-004, P-002]
epic: "Cloud & Commercial Services"
priority: "won't-have-yet"
complexity: "XL"
tags: [cloud, models, saas, no-code, onboarding]
---

# US-085: Managed Models with No API Key Setup

## User Story

**As a** tabletop GM (P-004) and interactive fiction author (P-002),
**I want to** use NoizuRPG locally with a $29/mo subscription that handles all AI model access without me obtaining or managing any API keys,
**So that** I can run sophisticated AI-powered games without navigating OpenAI/Anthropic account setup, billing, and key management.

## Acceptance Criteria

- [ ] Given a Managed Models subscriber, when they install NoizuRPG and configure `ManagedModelsProvider(subscription_key=key)`, then all LLM calls are proxied through the managed endpoint with no individual cloud provider API key needed
- [ ] Given a `ManagedModelsProvider`, when the user's subscription is active, then they have access to at least one hosted model for each of: narrative generation, dialogue, and quest logic use cases
- [ ] Given a managed subscription, when monthly usage exceeds the included allocation, then the user receives an email warning at 80% and 100% usage, and a soft cap prevents unexpected overages
- [ ] Given a managed subscription, when the NoizuRPG docs are followed, then a non-developer can complete the "first game session" tutorial in under 30 minutes without touching any external service's dashboard
- [ ] Given a managed subscription key, when the user calls `provider.check_status()`, then it returns current usage, remaining quota, and subscription renewal date as a structured object

## Notes

Deferred due to provider cost modeling complexity and legal/billing infrastructure requirements. This is the primary monetization lever for non-developer personas. The Cloud Playground (US-083) serves this audience in the interim with browser-based access. Pairs with FallbackProvider (US-081) to implement the proxied call routing.
