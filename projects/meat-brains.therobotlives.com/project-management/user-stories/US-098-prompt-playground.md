---
id: US-098
title: "Prompt Playground (Test Prompt Against Models In-App)"
slug: "prompt-playground"
personas: [P-001, P-002, P-003, P-005]
epic: "Advanced Features"
priority: "could-have"
complexity: "XL"
tags: [playground, model-testing, advanced, llm-integration, interactive]
---

# US-098: Prompt Playground (Test Prompt Against Models In-App)

## User Story

**As a** Prompt Engineer (P-001) or ML Researcher (P-003),
**I want to** run a prompt directly against one or more LLMs inside the platform,
**So that** I can see example outputs, compare model responses, and validate a prompt's effectiveness without leaving Meat Brains or setting up my own API access.

## Acceptance Criteria

- [ ] Given a user views a public prompt detail page, when they click "Try in Playground," then an in-page panel opens with the prompt pre-loaded and a model selector (initially supporting GPT-4o, Claude 3 Sonnet, Gemini 1.5 Flash)
- [ ] Given the user has selected a model and optionally edited the prompt, when they click "Run," then the request is sent and the model response streams into the output panel token by token
- [ ] Given a run is in progress, when the user clicks "Stop," then the streaming is cancelled and the partial output is preserved in the panel
- [ ] Given a user runs the same prompt against multiple models, when all runs complete, then responses are displayed side-by-side in a comparison view with token count and latency shown per model
- [ ] Given a user is not logged in or has exhausted their free playground credits, when they attempt to run a prompt, then they see a clear message about the credit limit and options to log in or upgrade
- [ ] Given a playground run completes, when the user finds the output useful, then they can click "Save as example output" to attach it to the prompt as a community-contributed example

## Notes

The playground must proxy all LLM API calls through the Meat Brains backend — API keys must never be exposed to the client. A credit system (e.g., 10 free runs/day for registered users) is needed to control costs. This is the highest-complexity feature in the backlog; consider phasing it as: (1) single model run, (2) streaming, (3) multi-model comparison. Depends on US-094 for authenticated usage tracking.
