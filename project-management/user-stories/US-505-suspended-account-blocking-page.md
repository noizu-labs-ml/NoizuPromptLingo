---
id: US-505
title: "Block a suspended account on every request and explain it on one page"
slug: "suspended-account-blocking-page"
personas: [P-004, P-006]
epic: "UX Foundations"
priority: "must-have"
complexity: "M"
tags: [ux, security, suspension, authz, error-states]
---

# US-505: Block a suspended account on every request and explain it on one page

## User Story

**As a** Platform Administrator (P-006) suspending an account on behalf of an Org Owner (P-004),
**I want** suspension enforced on every request path and surfaced as a single blocking page,
**So that** a suspended user's existing keys and sessions stop working immediately rather than continuing to function until they next log in.

## Acceptance Criteria

- [ ] Given a user whose status is suspended, when any authenticated request arrives over the Guardian session, MCP-key, or OAuth path, then it is refused with a suspension-specific response rather than being served.
- [ ] Given a suspended user with a browser session, when they load any app route, then they land on the single blocking page at `/suspended`, which states the account is suspended and who to contact without exposing administrative detail.
- [ ] Given a suspended user holding a previously issued MCP key or bearer token, when that credential is presented, then it is rejected for as long as the suspension stands, with no grace window from cached authorization state.
- [ ] Given a suspension that is lifted, when the user next makes a request, then normal access resumes without requiring credential reissue.
- [ ] Given the suspension check on the hot request path, when it runs, then it is served from state invalidated on status change rather than an unconditional extra round trip per request.

## Notes

This story closes **S3** in `work-overhaul.md` §5: the `:suspended` enum and the SSO active-gate exist, but the Guardian, MCP-key, and OAuth request paths never check status, so suspended users' existing keys keep working; §6 item 8 pairs the per-request check with invite redemption. UX-PLAN §2.3 routes it at `/suspended`, §3.2 screen 65 (backend **P**), §5 state matrix (suspended row: global redirect), §7 Phase 1. Related stories: US-039 and US-085 are the adjacent invite and cap gaps in the same auth cluster; US-506 owns every non-suspension denial state.
