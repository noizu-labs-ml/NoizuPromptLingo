---
id: US-014
title: "Add Description and Context to a Prompt"
slug: "add-description-and-context"
personas: [P-001, P-003, P-006]
epic: "Prompt Submission"
priority: "should-have"
complexity: "S"
tags: [prompt, description, context, documentation]
---

# US-014: Add Description and Context to a Prompt

## User Story

**As a** Content Creator (P-006),
**I want to** add a description and usage context to my prompt submission,
**So that** community members understand the intended use case, what problem it solves, and how to adapt it effectively.

## Acceptance Criteria

- [ ] Given I am on the prompt submission form, when I locate the "Description / Context" field, then I see a rich text area that accepts Markdown input (rendered in preview mode) with a 5,000 character limit.
- [ ] Given I am writing a description, when I toggle the preview mode, then the Markdown is rendered with proper formatting including headers, bold, lists, and inline code (handled by US-021).
- [ ] Given I submit a prompt with an empty description field, when the prompt is published, then it is accepted without error — the description is optional but prompted with placeholder text: "Explain what this prompt does, when to use it, and any tips for getting the best results."
- [ ] Given I am viewing a published prompt's detail page, when the description contains more than 500 characters, then the description is collapsed by default showing a "Show more" expand control.
- [ ] Given I am a community member viewing a prompt, when I click the description area, then I can see the rendered Markdown in a clean, readable layout distinct from the raw prompt body.

## Notes

The description field is separate from the prompt body itself — the body is the actual LLM input, while the description is human-facing documentation. This distinction should be visually clear in the UI. The character limit (5,000) is generous enough for thorough P-003 documentation.
