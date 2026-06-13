---
id: US-086
title: "User sets timezone and date format preferences"
slug: "timezone-date-format"
personas: [P-005, P-001]
epic: "Settings & Preferences"
priority: "could-have"
complexity: "S"
tags: [settings, timezone, date-format, localization, i18n]
---

# US-086: User Sets Timezone and Date Format Preferences

## User Story

**As an** Engineering Manager (P-005),
**I want to** configure my timezone and preferred date/time format,
**So that** all timestamps across dashboards, audit logs, and notifications display in my local time and preferred format rather than a fixed server timezone.

## Acceptance Criteria

- [ ] Given a user navigates to Settings > Regional, when the timezone selector loads, then it displays a searchable dropdown of IANA timezones with the user's detected browser timezone pre-selected
- [ ] Given a user selects a timezone and saves, when they view any dashboard or log entry with timestamps, then all timestamps render in the selected timezone with the correct UTC offset displayed
- [ ] Given a user selects a date format (ISO 8601, US format, European format, relative time), when the preference is saved, then all date displays across the platform update to reflect the chosen format
- [ ] Given a user has not set timezone preferences, when they first visit the platform, then the system defaults to the browser's reported timezone and ISO 8601 date format

## Notes

This is a prerequisite for US-098 (language switching) and part of the broader i18n effort. Timestamps stored in the database are always UTC; timezone conversion happens at render time. Relative time format (e.g., "3 minutes ago") should be offered as an option alongside absolute formats.
