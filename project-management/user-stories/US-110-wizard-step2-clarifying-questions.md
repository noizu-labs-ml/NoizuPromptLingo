---
id: US-110
title: "Creation wizard step 2: LLM clarifying questions"
slug: "wizard-step2-clarifying-questions"
personas: [P-009]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "M"
tags: [mcp-endpoints, wizard, llm, frontend]
---

# US-110: Creation wizard step 2: LLM clarifying questions

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** be asked a few clarifying questions about my endpoint description,
**So that** the proposed tool set matches what I actually need instead of a generic guess.

## Acceptance Criteria

- [ ] Given Quinn completes step 1 and continues, when the clarify step loads, then it presents the short series of clarifying questions returned by US-109, each answerable inline.
- [ ] Given Quinn skips one or all questions, when continuing, then the wizard proceeds with a description-only proposal and skipped questions are simply omitted from the request.
- [ ] Given answers are provided, when continuing, then the answers are passed verbatim to the propose-tools call and the wizard advances to the review step (US-111) while the proposal is loading.
- [ ] Given a proposal request in flight, when it is pending, then a loading state is shown and Quinn can cancel it.
- [ ] Given the propose-tools call fails with `llm_unavailable` or times out, when the failure is received, then the wizard routes to the manual picker (US-112) with name, description, and any answers preserved, and shows a visible explanation of the fallback.

## Notes

Questions and proposals are two calls to the same US-109 endpoint (answers omitted vs. supplied). Never blocks creation: every failure path lands on the manual picker.
