# US-007: Focus Management in Modal Dialogs and Overlays

**Persona:** Priya — Accessibility engineer, tests with all screen readers
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Priya, I want modal dialogs and overlay panels to correctly trap focus within themselves and return focus on close so that screen reader users are never stranded outside an active dialog.

## Acceptance Criteria
- [ ] When a modal opens, focus moves immediately to the first focusable element inside (or the dialog `<h2>` if no interactive element precedes it)
- [ ] Tab and Shift+Tab cycle only within the open modal — focus cannot escape to background content
- [ ] Background content receives `aria-hidden="true"` and `inert` attribute when a modal is open
- [ ] Escape key closes the modal and returns focus to the trigger element that opened it
- [ ] If the trigger no longer exists (e.g., enemy died while loot dialog was open), focus returns to the next logical element (command input)
- [ ] `role="dialog"` and `aria-labelledby` pointing to the dialog's heading are set on the modal container
- [ ] Stacked modals (confirm dialog over loot dialog) manage focus correctly through all layers — Escape unwinds one layer at a time

## Notes
The `inert` attribute is now broadly supported (Chrome 102+, Firefox 112+, Safari 15.5+) and is preferred over manual `tabindex="-1"` looping for background content. Test with JAWS 2023 which has historically mis-handled `aria-hidden` on ancestors. Loot dialogs, skill confirmations, and party invites are the primary modal surfaces in-game.
