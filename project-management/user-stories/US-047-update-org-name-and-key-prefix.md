---
id: US-047
title: "Update Organization Name and Key Prefix"
slug: "update-org-name-and-key-prefix"
personas: [P-004]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "S"
tags: [org-settings, self-service, branding]
---

# US-047: Update Organization Name and Key Prefix

## User Story

**As a** Org Owner, Marcus Chen (P-004),
**I want to** update my organization's display name and key prefix,
**So that** the org's identity in tobor stays accurate as the company evolves (rebrand, merger, etc.) and generated resource keys reflect the correct namespace.

## Acceptance Criteria

- [ ] Given Marcus is on the org settings page as an org owner, when he changes the org display name and saves, then the new name is persisted and immediately reflected in the org switcher and page header.
- [ ] Given Marcus attempts to change the key prefix to a value already in use by another org, when he submits the form, then validation blocks the save with an inline "prefix already taken" error and no change is persisted.
- [ ] Given Marcus enters a key prefix containing invalid characters (spaces, uppercase, symbols), when he submits, then the form rejects it with a format error before any API call is made.
- [ ] Given the key prefix is successfully changed, when existing projects generate new resource keys afterward, then those keys use the updated prefix while previously issued keys remain unchanged.

## Notes

Key-prefix changes are non-retroactive for already-issued keys. Distinct from project-level MCP scope configuration in US-050.
