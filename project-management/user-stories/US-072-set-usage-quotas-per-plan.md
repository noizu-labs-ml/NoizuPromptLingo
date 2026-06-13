---
id: US-072
title: "Set usage quotas per plan tier"
slug: "set-usage-quotas-per-plan"
personas: [P-004, P-005]
epic: "Admin & Moderation"
priority: "should-have"
complexity: "M"
tags: [admin, quotas, billing, plan-tiers, rate-limiting]
---

# US-072: Set Usage Quotas Per Plan Tier

## User Story

**As a** Startup Founder (P-004),
**I want to** define generation limits (daily, monthly) for each subscription plan tier,
**So that** I can enforce fair use, protect infrastructure costs, and upsell users who hit their limits.

## Acceptance Criteria

- [ ] Given the admin plan settings page, when I set a monthly generation limit for the "Free" tier to 50, then users on that plan are blocked from generating once they exceed 50 generations in a calendar month
- [ ] Given a user hits their quota, when they attempt a generation via MCP, then a structured error response is returned with the quota limit, current usage, reset date, and a link to upgrade
- [ ] Given a per-user override is set (e.g., a beta tester granted extra quota), when enforcing limits, then the override takes precedence over the plan-tier default
- [ ] Given quota resets at the end of the billing period, when the period rolls over, then usage counters reset and blocked users can generate again without manual admin action

## Notes

Quota enforcement must occur in the API layer before the generation job is dispatched — not after. Per-user overrides should be configurable from the user detail page (US-071). Reset timing must align with billing period, not calendar month, for paid tiers.
