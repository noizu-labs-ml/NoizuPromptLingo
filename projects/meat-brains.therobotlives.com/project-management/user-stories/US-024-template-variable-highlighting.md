---
id: US-024
title: "Template Variable Highlighting in Prompt Body"
slug: "template-variable-highlighting"
personas: [P-001, P-005, P-007]
epic: "Content Formatting"
priority: "could-have"
complexity: "M"
tags: [formatting, template, variables, prompt-engineering, readability]
---

# US-024: Template Variable Highlighting in Prompt Body

## User Story

**As a** Prompt Engineer (P-001),
**I want to** have template variables (e.g., `{{topic}}`, `{{user_input}}`) visually highlighted in the prompt body,
**So that** readers can immediately identify which parts of the prompt are meant to be customized.

## Acceptance Criteria

- [ ] Given I write a prompt body containing text wrapped in double curly braces (e.g., `{{variable_name}}`), when the prompt is rendered on the detail page, then each `{{variable}}` token is displayed with a distinct visual treatment (highlighted pill/badge in a muted accent color).
- [ ] Given a prompt body contains highlighted template variables, when I hover over a variable pill, then a tooltip appears showing the variable name and, if specified, a placeholder description entered by the author.
- [ ] Given a prompt body is rendered with template variables, when I click a "Fill template" button on the detail page, then an interactive form appears with one labeled text input per unique variable, and submitting fills in the values to produce a copy-ready prompt.
- [ ] Given I write a malformed template token (single brace `{var}` or unclosed `{{var`), when the prompt is rendered, then the text is displayed as-is without visual treatment and no error is thrown.
- [ ] Given I am on the submission form and type a `{{`, when I type a variable name and close with `}}`, then the editor shows a live preview of the highlighting in the prompt body preview pane.

## Notes

The double-curly-brace convention (Jinja/Handlebars-style) is the de facto standard in the LLM community. The "Fill template" interactive form (AC-3) is the highest-value feature for P-005 and P-007 who want to quickly adapt prompts for their workflows. Depends on US-025 (preview) for the live editor preview in AC-5.
