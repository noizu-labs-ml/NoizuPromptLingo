---
id: US-039
title: "Select target language for scaffolded project"
slug: "select-target-language"
personas: [P-001, P-007]
epic: "MCP Jumpstart"
priority: "must-have"
complexity: "S"
tags: [mcp-jumpstart, scaffolding, language-selection]
---

# US-039: Select Target Language for Scaffolded Project

## User Story

**As a** MCP Tool Developer (P-001),
**I want to** select the target programming language for my scaffolded MCP project,
**So that** the generated code matches my team's technical stack and existing development workflow.

## Acceptance Criteria

- [ ] Given the user is on the MCP Jumpstart project generator page, when the language selection step loads, then it displays supported languages: TypeScript, Python, Go, Rust, Java, and Elixir.
- [ ] Given the user selects a language, when they confirm the selection, then the system highlights compatible templates (US-040) that are available for that language and dims unavailable ones.
- [ ] Given the user hovers over a language option, when the tooltip displays, then it shows the language version (e.g., TypeScript 5.x, Python 3.12+), the MCP SDK maturity level (stable/beta/alpha), and a link to SDK documentation.
- [ ] Given the user has previously created projects, when they start a new scaffold, then the system pre-selects their most-used language as the default option.
- [ ] Given a language is selected, when the user proceeds, then the selection is persisted in the project generation wizard state and all subsequent configuration steps adapt to the chosen language's conventions (package manager, file structure, test framework).

## Notes

Language support depends on MCP SDK availability. The UI should clearly communicate SDK maturity so users can make informed choices. Related: US-040 (template selection), US-041 (project generation).
