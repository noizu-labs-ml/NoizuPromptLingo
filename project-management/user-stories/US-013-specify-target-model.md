---
id: US-013
title: "Specify Target Model for a Prompt"
slug: "specify-target-model"
personas: [P-001, P-003, P-007]
epic: "Prompt Submission"
priority: "must-have"
complexity: "S"
tags: [prompt, model, llm, metadata, discovery]
---

# US-013: Specify Target Model for a Prompt

## User Story

**As a** Prompt Engineer (P-001),
**I want to** specify which AI model(s) my prompt is designed for,
**So that** users can filter the feed by their preferred model and understand the intended context.

## Acceptance Criteria

- [ ] Given I am on the prompt submission form, when I interact with the "Target Model" field, then I see a searchable multi-select with a curated list including GPT-4, GPT-4o, Claude 3 Opus, Claude 3.5 Sonnet, Llama 3, Mistral, Gemini Pro, and an "Other / Model-agnostic" option.
- [ ] Given I select "Other / Model-agnostic", when I submit the form, then the prompt is tagged as applicable to any model and appears in all model-filtered feed views.
- [ ] Given I select multiple models, when I submit the form, then all selected model tags are stored and the prompt appears in each model's filtered feed.
- [ ] Given the model list needs updating (new model release), when an admin adds a new model to the approved list, then it appears immediately in the target model selector without a code deploy.
- [ ] Given I am viewing the main feed, when I use the model filter dropdown, then only prompts tagged with the selected model (or as model-agnostic) are shown.

## Notes

The model list must be admin-editable (AC-4) as new frontier models release frequently — hardcoding requires engineering effort for what should be content management. Model-agnostic prompts (system prompts, meta-prompts) are highly valued by P-001 and P-007 and must not be excluded by model filters.
