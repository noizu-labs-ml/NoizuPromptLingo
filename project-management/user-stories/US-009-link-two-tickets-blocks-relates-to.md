---
id: US-009
title: "Link two tickets together (blocks/relates-to)"
slug: "link-two-tickets-blocks-relates-to"
personas: [P-003, P-002]
epic: "Tickets & Boards"
priority: "should-have"
complexity: "S"
tags: [tickets, linking, dependencies]
---

# US-009: Link two tickets together (blocks/relates-to)

## User Story

**As a** Delivery Lead (P-003) coordinating work a coding agent (P-002) is executing,
**I want to** link two tickets with a typed relationship such as "blocks" or "relates-to",
**So that** dependency chains and related work are visible to both humans and agents before they start on a ticket that can't actually be completed yet.

## Acceptance Criteria

- [ ] Given two existing tickets A and B, when a "blocks" link is created from A to B, then viewing ticket B shows A listed under "blocked by" and viewing ticket A shows B under "blocks".
- [ ] Given ticket A already linked to B as "blocks", when the agent (P-002) queries ticket B before starting work on it, then the blocking relationship and ticket A's current stage are visible in the response.
- [ ] Given an attempt to link a ticket to itself, when submitted, then the call is rejected with a validation error.
- [ ] Given a "relates-to" link, non-directional, between two tickets, when either ticket is viewed, then the other appears under "related tickets" symmetrically.

## Notes

Distinct from US-010, which links a ticket to a non-ticket entity; this story covers ticket-to-ticket typed relationships only. Relevant to US-014's PRD-to-user-story linkage, though that story models a specific "implements" relationship rather than generic blocks/relates-to.
