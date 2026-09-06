---
id: US-112
title: "Manual tool picker with LLM-unavailable fallback"
slug: "manual-tool-picker-llm-fallback"
personas: [P-009, P-001]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "M"
tags: [mcp-endpoints, tool-picker, fallback, frontend, catalog]
---

# US-112: Manual tool picker with LLM-unavailable fallback

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** pick tools manually from a searchable catalog whenever the LLM proposal is unavailable — or because I prefer to choose myself —
**So that** I can always complete endpoint creation, with or without AI assistance.

## Acceptance Criteria

- [ ] Given the tool catalog is enumerable, when the picker opens, then it lists tools with name, category, and description, with text search and category filtering.
- [ ] Given tools are selected in the picker, when Quinn confirms, then they return to the review step (US-111) with Enabled/Visible toggles available per selected tool.
- [ ] Given the wizard's clarify step (US-110), when Quinn reaches it, then an explicit "pick tools manually" option is offered up front, in addition to automatic routing on `llm_unavailable` or timeout.
- [ ] Given a fallback route is taken, when the picker renders, then an explanation of why is visible and all previously entered wizard state (name, description, answers) is preserved.
- [ ] Given the picker component, when reviewed, then it is a standalone reusable component (not wizard-coupled) so the endpoint editor and admin page (US-114) can embed it.

## Notes

Fallback is a first-class path, not an error page: proposal failure never blocks creation. Grounded catalog data comes from the existing catalog/tool-search plumbing; no new backend surface required for the picker itself.
