---
id: US-063
title: "Set default output format preference"
slug: "set-default-output-format"
personas: [P-001, P-003, P-006]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "S"
tags: [settings, preferences, output-format, user-config]
---

# US-063: Set Default Output Format Preference

## User Story

**As a** Full-Stack Developer (P-001),
**I want to** configure my preferred default output format (PNG, SVG, PDF) in my account settings,
**So that** every generation request returns my preferred format without me specifying it each time.

## Acceptance Criteria

- [ ] Given the settings page, when I select a default output format from the available options (PNG, SVG, PDF), then the preference is saved to my account profile
- [ ] Given my default format is set to SVG, when I make a generation request without specifying a format, then SVG is returned
- [ ] Given I explicitly specify a format in a request (e.g., `format: "png"`), when processed, then the explicit value overrides my saved default for that request
- [ ] Given I have no default set, when a request is made without a format parameter, then the system default (PNG) is used

## Notes

This preference is stored per-user in the Phoenix backend. The precedence chain is: request-level parameter → user default → system default. Related to US-065 (default theme) as part of the same settings surface.
