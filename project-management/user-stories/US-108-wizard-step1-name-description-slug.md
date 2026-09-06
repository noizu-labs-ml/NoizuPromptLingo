---
id: US-108
title: "Creation wizard step 1: name, description, and auto-slug"
slug: "wizard-step1-name-description-slug"
personas: [P-009]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "S"
tags: [mcp-endpoints, wizard, slug-validation, frontend]
---

# US-108: Creation wizard step 1: name, description, and auto-slug

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** start endpoint creation with just a name and a plain-language description of what the endpoint is for,
**So that** I can describe intent in seconds and let the system handle the details.

## Acceptance Criteria

- [ ] Given the wizard is started via "New endpoint", when step 1 renders, then it collects a display name and a description ("What is this endpoint for?").
- [ ] Given the description is empty, when Quinn attempts to continue, then Continue is disabled and the field is marked required (the description drives tool proposal).
- [ ] Given a name is entered, when the slug field is in auto mode, then a slug is auto-derived from the name; manual slug edits take over permanently, with the same inline regex validation and availability feedback as US-105.
- [ ] Given Quinn entered the wizard via Clone (US-105/US-106), when step 1 renders, then fields are prefilled from the source and Continue skips the proposal steps.
- [ ] Given valid name + description, when Continue is pressed, then the wizard advances to the clarify step (US-110) carrying the entered context.

## Notes

Validation UI shared with the US-105 clone dialog (same slug field component); availability check depends on US-113 with graceful degradation.
