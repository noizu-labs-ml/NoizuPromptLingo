---
id: US-105
title: "Clone a built-in template from the user-facing endpoint manager"
slug: "clone-builtin-template-from-endpoint-manager"
personas: [P-009, P-001]
epic: "MCP Endpoint UX Overhaul"
priority: "must-have"
complexity: "M"
tags: [mcp-endpoints, clone, slug-validation, frontend]
---

# US-105: Clone a built-in template from the user-facing endpoint manager

## User Story

**As** Quinn Harper, the Endpoint Composer (P-009),
**I want to** clone a built-in template (`tobor`, `core`) from the user-facing endpoint manager and assign it my own slug, name, and description,
**So that** I get an editable starting point instead of hitting the 403 "copy it to edit" dead end.

## Acceptance Criteria

- [ ] Given the endpoint manager lists built-in templates (read-only, nil owner), when Quinn views one, then a Clone affordance is available; and when Quinn attempts to edit a template, the "copy it to edit" messaging offers the same Clone entry point instead of dead-ending.
- [ ] Given the clone dialog is opened, when it loads, then slug, name, and description fields are prefilled from the template (e.g., name "Copy of tobor") and all three are editable before creation.
- [ ] Given a name is typed while the slug field is in auto mode, when the name changes, then a valid slug is auto-derived from it; once the user edits the slug manually, auto-derivation stops and the field stays hand-editable.
- [ ] Given a slug that violates `^[a-z0-9][a-z0-9-]{0,62}$`, when typed, then an inline validation message appears and Create remains disabled.
- [ ] Given a well-formed but taken slug, when checked, then inline uniqueness feedback appears before submit; and if a conflict still reaches the server (409 on create), it is surfaced inline without losing any form state.
- [ ] Given all fields valid, when Create is submitted, then the endpoint is created via the existing create API (`source_slug`), is owned by Quinn, appears in the manager list, and is editable and deletable.
- [ ] Given Quinn cancels at any point, when the dialog closes, then no endpoint has been created.

## Notes

Uses the existing `POST /api/v1/auth/mcp/endpoints` create with `source_slug`; no backend copy logic changes expected. The debounced availability check rides on US-113 and degrades gracefully (submit-time 409 only) if that endpoint is unavailable. Story form shared with US-106.
