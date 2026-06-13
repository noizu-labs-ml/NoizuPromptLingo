# US-010: Accessible Command Input with Autocomplete

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want the command input field to offer accessible autocomplete suggestions so that I can discover and execute commands at 90 WPM without memorizing every syntax variant.

## Acceptance Criteria
- [ ] The command input is a `<input type="text">` with `role="combobox"`, `aria-expanded`, `aria-autocomplete="list"`, and `aria-controls` pointing to the suggestion listbox
- [ ] Autocomplete suggestions appear in a `role="listbox"` with each suggestion as `role="option"`
- [ ] Arrow keys navigate the suggestion list; the input value updates to show the selected suggestion; active option is announced by screen reader
- [ ] Escape clears the suggestion list and returns focus to the input without submitting
- [ ] Enter submits the currently selected suggestion or the raw input text if no suggestion is selected
- [ ] The listbox is positioned below the input and does not overlap critical game information; it is dismissed on outside click or focus loss
- [ ] Input history (up/down arrow when listbox is closed) cycles through previous commands; each recalled command is announced
- [ ] A "Command help" trigger (e.g., `?` prefix or F1) opens a searchable command reference accessible by screen reader

## Notes
This is the primary game interaction surface — it must be bulletproof across all AT. The combobox ARIA pattern (APG 1.2) is the correct baseline. NVDA in forms mode handles combobox differently than browse mode — test both. Ensure the listbox does not receive `aria-live` (it causes double-announcements); rely on `aria-activedescendant` instead.
