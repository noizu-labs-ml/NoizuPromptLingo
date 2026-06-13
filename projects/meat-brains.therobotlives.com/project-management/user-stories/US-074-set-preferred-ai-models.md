---
id: US-074
title: "Set Preferred AI Models (Filter Defaults)"
slug: "set-preferred-ai-models"
personas: [P-001, P-003, P-005, P-007]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "M"
tags: [settings, preferences, models, filters, personalization]
---

# US-074: Set Preferred AI Models (Filter Defaults)

## User Story

**As a** prompt engineer (P-001),
**I want to** set my preferred AI models in my account settings,
**So that** the site automatically pre-filters prompt feeds and search results to show content relevant to the models I use.

## Acceptance Criteria

- [ ] Given I am authenticated and in settings, when I navigate to "AI Model Preferences," then I see a list of supported models (GPT-4, Claude, Gemini, Llama, etc.) with multi-select checkboxes
- [ ] Given I select one or more preferred models and save, when I return to the prompt feed or search, then results are pre-filtered to my selected models by default
- [ ] Given my model preferences are set, when I manually override the filter on the feed, then my one-time override is respected without changing my saved defaults
- [ ] Given a new AI model is added to the platform, when I view my preferences, then the new model appears unchecked and does not affect my existing filter until I explicitly add it

## Notes

Model preferences serve as persistent filter defaults, not hard exclusions — users should always be able to temporarily override them at the feed level. The model list should be driven by a configurable data source to allow new models to be added without code changes.
