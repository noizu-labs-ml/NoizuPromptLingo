---
id: US-006
title: "AI agent authenticates via API key and presents caller identity"
slug: "agent-authenticates-via-api-key"
personas: [P-008, P-004]
epic: "Auth & Onboarding"
priority: "must-have"
complexity: "M"
tags: [auth, api-key, dual-principal, machine-caller]
---

# US-006: AI Agent Authenticates via API Key and Presents Caller Identity

## User Story

**As a** MCP Client System (P-008) orchestrated by an AI/ML Engineer (P-004),
**I want to** authenticate to MCP Host using an API key and present my caller identity on each request,
**So that** the system can enforce caller-specific policies and attribute actions to the correct agent.

## Acceptance Criteria

- [ ] Given an API key `mcp_live_...` included in the `Authorization: Bearer` header, when the agent sends a request to any MCP Host endpoint, then the Auth Gateway validates the key, resolves the caller identity (caller ID, name, bound policy), and attaches it to the request context.
- [ ] Given a valid API key, when the bound policy has `require_user_context: true`, then the Auth Gateway also requires a valid user token (JWT in `X-User-Token` header) and rejects the request with HTTP 401 if absent.
- [ ] Given an invalid, expired, or revoked API key, when the agent sends a request, then the Auth Gateway rejects it with HTTP 401 and a JSON error body including an `error_code` field.
- [ ] Given an API key that lacks permission for the requested tool (per the bound policy), when the agent invokes the tool, then the system returns HTTP 403 with a message indicating the caller policy denied the request.
- [ ] Given a valid request with both API key and user token, when the Auth Gateway processes it, then the resulting request context contains both `caller` and `user` principal objects for downstream policy evaluation.

## Notes

This is the machine-side entry point for dual-principal authorization. The caller identity established here is one of the two principals evaluated in US-007 and US-008. API keys are created in US-004. The `X-User-Token` header carries the human principal, establishing the dual-principal pair. Related to US-004, US-007, US-008, US-009.
