---
id: US-093
title: "Internationalization support (English, Spanish, Japanese)"
slug: "internationalization-support"
personas: [P-004, P-002, P-006]
epic: "Accessibility & Internationalization"
priority: "could-have"
complexity: "L"
tags: [i18n, internationalization, localization]
---

# US-093: Internationalization support (English, Spanish, Japanese)

## User Story

**As a** Startup Founder (P-004),
**I want to** use the companion site in my preferred language,
**So that** I can work efficiently without language barriers when sharing mockups with international stakeholders.

## Acceptance Criteria

- [ ] Given the companion site loads, when the user's browser locale is Spanish or Japanese, then the UI is automatically rendered in that language for all static strings
- [ ] Given the user is authenticated, when they update their language preference in settings, then the entire UI switches to the selected language immediately without a page reload
- [ ] Given a locale is active, when dates, numbers, and currency values are displayed, then they are formatted according to locale conventions (e.g., date format, decimal separator)

## Notes

Use `next-intl` for Next.js 15 i18n routing and message catalogs. Machine-translated strings should be reviewed by a native speaker before launch for each locale. AI-generated mockup content is not translated — only UI chrome. RTL support is out of scope for v1.
