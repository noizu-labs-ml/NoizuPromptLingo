---
id: P-006
name: "David Park"
slug: "david-the-admin"
archetype: "The Platform Admin"
segment: "edge-case"
tags: [admin, moderation, platform-ops, abuse-prevention, billing]
---

# David Park — The Platform Admin

## Demographics

| Field | Value |
|-------|-------|
| **Age** | 32-40 |
| **Role** | Platform operations / community manager |
| **Technical Level** | Advanced |
| **Industry** | SaaS platform operations |
| **Location** | San Francisco, USA |

## Bio

David manages the operational side of the Knowledge Base platform. He handles abuse reports, monitors API usage and generation costs, manages billing escalations, and ensures the platform stays healthy as it scales. He doesn't build fictional worlds — he builds the infrastructure that lets others do so safely.

## Goals

1. Keep generation costs under control — identify and throttle users who abuse the system
2. Handle content moderation for publicly shared universes
3. Monitor platform health: uptime, generation queue depth, error rates

## Frustrations

1. Heavy users can run up massive inference costs with bulk generation — needs granular usage controls
2. Public universe sharing means someone will eventually try to generate harmful content
3. No existing tooling for "lore moderation" — standard content moderation doesn't understand fictional violence vs. real-world harm

## Behaviors

- Monitors dashboards daily for cost anomalies and abuse patterns
- Reviews flagged content from automated moderation and user reports
- Manages billing escalations and plan overages
- Coordinates with engineering on rate limiting and cost optimization

## Job to Be Done

> "When a user's generation costs spike 10x overnight, I want to see their usage pattern and throttle them before it blows our margin, so the platform stays financially sustainable."

## Relationship to Product

David is an internal user — he doesn't discover the product, he operates it. He needs admin dashboards, usage analytics, content moderation tools, and billing management. He'd be frustrated by a platform that launches without these tools, forcing him to query databases directly.

## Scenarios

1. **Cost spike investigation** — David notices a Studio-tier user generated 500 entries in one day. He checks the usage dashboard, confirms it's a legitimate game studio doing a sprint, and adjusts their rate limit temporarily rather than throttling.
2. **Content moderation** — A publicly shared universe is flagged by another user for containing hate speech dressed up as "in-universe cultural norms." David reviews the entries, makes a moderation decision, and documents the policy precedent.
