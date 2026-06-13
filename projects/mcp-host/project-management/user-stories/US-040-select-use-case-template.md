---
id: US-040
title: "Select use case template for scaffolded project"
slug: "select-use-case-template"
personas: [P-001, P-004, P-007]
epic: "MCP Jumpstart"
priority: "must-have"
complexity: "M"
tags: [mcp-jumpstart, scaffolding, templates]
---

# US-040: Select Use Case Template for Scaffolded Project

## User Story

**As a** AI/ML Engineer (P-004),
**I want to** select a use case template (CRUD, LLM tool, data pipeline, etc.) for my scaffolded MCP project,
**So that** the generated project is pre-configured with the right tool patterns, dependencies, and handler stubs for my specific use case.

## Acceptance Criteria

- [ ] Given the user has selected a target language (US-039), when the template selection step loads, then it displays available templates as visual cards with name, description, and estimated complexity.
- [ ] Given the template catalog loads, when the user browses it, then the following templates are available: CRUD API, LLM Tool Wrapper, Data Pipeline, File Processor, Webhook Receiver, Database Connector, and Custom (blank).
- [ ] Given the user selects a template, when the template detail panel opens, then it shows the tools that will be generated, the required dependencies, a brief architecture diagram, and a sample use case description.
- [ ] Given the user selects a template incompatible with the chosen language, when the system evaluates compatibility, then it displays a warning explaining the limitation and suggests an alternative template or language.
- [ ] Given the user selects the "Custom (blank)" template, when they proceed, then the system generates a minimal MCP server scaffold with a single example tool and no use-case-specific logic.
- [ ] Given a template is selected, when the user proceeds, then the selection is stored and the next steps (US-048 for customization) are presented with template-relevant options.

## Notes

Templates are the primary value differentiator of MCP Jumpstart. Each template should encode best practices for its use case. The template catalog should be extensible to support community-contributed templates in the future. Related: US-039 (language), US-041 (generation), US-048 (customization).
