---
id: US-053
title: "Configure a Media-Provider API Key for an Org"
slug: "configure-org-media-provider-api-key"
personas: [P-005, P-004]
epic: "Settings & Preferences"
priority: "should-have"
complexity: "S"
tags: [genai, api-keys, media-provider]
---

# US-053: Configure a Media-Provider API Key for an Org

## User Story

**As a** Growth Operator, Renee Okafor (P-005), working with Org Owner Marcus Chen (P-004),
**I want to** configure an org-level media-provider (genai) API key,
**So that** image/media-generation tools used for campaigns and ad creative run under the org's own account and billing.

## Acceptance Criteria

- [ ] Given Renee has the appropriate permission and is on the org's media-provider settings page, when she enters a valid API key for a supported provider and saves, then the key is stored and the provider shows as "connected" for the org.
- [ ] Given an invalid or malformed API key is entered, when the save is attempted, then the system rejects it with a clear error before persisting.
- [ ] Given a media-provider key is already configured, when Marcus or Renee views the settings page, then the key is displayed masked, never in plaintext, with an option to replace it.
- [ ] Given the key is replaced with a new value, when the save completes, then all subsequent media-generation calls use the new key and the prior key is no longer usable by the app.

## Notes

Org-level self-service scope only. The platform-admin equivalent (configuring on an org's behalf) is covered separately in US-061.
