---
id: US-078
title: "AI Model Selection"
slug: "ai-model-selection"
personas: [P-001, P-002, P-003, P-004, P-005]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "M"
tags: [settings, ai, model, generation, preferences]
---

# US-078: AI Model Selection

## User Story

**As a** worldbuilder who uses AI generation (P-001, P-002, P-003, P-004, P-005),
**I want to** select which AI model powers my generation requests,
**So that** I can balance quality, speed, and cost according to my needs.

## Acceptance Criteria

- [ ] Given I am on Settings > AI, when I view the page, then I see a dropdown of available models (e.g., GPT-4o, Claude Sonnet, Claude Haiku) with per-request cost estimates displayed.
- [ ] Given I select a model and save, when I make a generation request in the Generation Studio, then that model is used unless overridden at the session level.
- [ ] Given I am on a free plan, when I view the model selector, then premium-only models are shown but disabled with an upgrade prompt.
- [ ] Given a model becomes unavailable due to provider outage, when I attempt generation, then the system falls back to the default model and displays a banner explaining the fallback.
- [ ] Given I change my default model, when I navigate to the Generation Studio, then the model selector there reflects my updated default.

## Notes

Related: US-079 (generation budget/limits). Model availability is tier-gated — free users get access to one or two cost-efficient models. Cost estimates should reflect the platform's token pricing, not raw API costs.
