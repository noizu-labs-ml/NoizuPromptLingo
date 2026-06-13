---
id: US-094
title: "Form Data Recovery After Browser Crash"
slug: "form-data-recovery-browser-crash"
personas: [P-007, P-001, P-002, P-003]
epic: "Edge Cases & Error States"
priority: "could-have"
complexity: "M"
tags: [forms, recovery, crash-resilience, ux, autosave]
---

# US-094: Form Data Recovery After Browser Crash

## User Story

**As a** client filling out a detailed RFI or contact form (P-007),
**I want** my in-progress form data to be automatically saved and restored if my browser crashes or I accidentally close the tab,
**So that** I do not have to re-enter lengthy responses after an unexpected interruption.

## Acceptance Criteria

- [ ] Given a user filling out the RFI or contact form, when they have typed more than 30 characters in any field, then form state is auto-saved to localStorage every 30 seconds
- [ ] Given auto-saved form data in localStorage, when the user returns to the same form URL, then a banner appears: "We saved your previous progress. Restore it?" with Restore and Dismiss actions
- [ ] Given the user clicking Restore, when the form data is loaded, then all previously entered field values are populated exactly as left
- [ ] Given the user clicking Dismiss, when dismissed, then the saved draft is deleted and the form starts fresh
- [ ] Given a form successfully submitted, when the submission completes, then the localStorage draft for that form is cleared
- [ ] Given localStorage unavailable (private/incognito mode with storage blocked), then the autosave feature degrades gracefully with no errors shown

## Notes

Key the localStorage entry by `form_draft_{formId}_{userId or 'anon'}` to avoid collisions. Do not store sensitive fields (e.g., passwords) in localStorage. Draft auto-save should be debounced (not on every keystroke). Related to US-092 (session expiry data preservation), US-091 (rate limiting). Draft retention TTL: 7 days.
