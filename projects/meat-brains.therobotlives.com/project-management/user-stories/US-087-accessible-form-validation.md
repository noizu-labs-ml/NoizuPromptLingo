---
id: US-087
title: "Accessible Form Validation Messages"
slug: "accessible-form-validation-messages"
personas: [P-001, P-005, P-008]
epic: "Accessibility & i18n"
priority: "should-have"
complexity: "S"
tags: [accessibility, forms, validation, aria, wcag, a11y]
---

# US-087: Accessible Form Validation Messages

## User Story

**As an** AI Newcomer (P-008) or Indie Developer (P-005),
**I want to** receive form validation errors that are clearly associated with their fields and announced by my screen reader,
**So that** I can correct mistakes in forms without needing to visually hunt for error messages.

## Acceptance Criteria

- [ ] Given a user submits a form with invalid or missing required fields, when validation errors are shown, then each error message is programmatically associated with its field via `aria-describedby` or `aria-errormessage`
- [ ] Given validation errors appear, when focus is on the invalid field, then the screen reader announces both the field label and the error message when the field is focused
- [ ] Given a form submission is blocked by validation, when the submission fails, then focus is moved to the first invalid field and a summary of errors is announced via an `aria-live="assertive"` region
- [ ] Given a user corrects an invalid field, when the field passes validation, then the error message disappears and the screen reader announces the field is now valid

## Notes

Error messages must not rely solely on color (e.g., red text) to communicate the error state — an icon or text prefix like "Error:" is required. Inline validation on blur is acceptable but must not be overly aggressive (do not validate on every keystroke). Applies to all forms: login, registration, prompt submission, and settings.
