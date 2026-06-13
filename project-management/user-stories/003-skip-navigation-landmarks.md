# US-003: Skip Navigation and Landmark Regions

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P0
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want skip-navigation links and properly labeled landmark regions so that I can jump directly to the game area, chat, or status panel without tabbing through every UI element on every page load.

## Acceptance Criteria
- [ ] A "Skip to game" link is the first focusable element on every page; it becomes visible on focus and jumps to `main` landmark
- [ ] The layout uses semantic HTML5 landmarks: `<main>` (game output), `<nav>` (primary navigation), `<aside>` (status/stats panel), `<footer>` (system info)
- [ ] All landmark regions have unique `aria-label` or `aria-labelledby` values (e.g., `<nav aria-label="Primary navigation">`, `<aside aria-label="Character status">`)
- [ ] NVDA landmark navigation (Insert+F7) produces a meaningful, non-redundant list of regions
- [ ] At minimum 5 skip links are offered for the main game view: Skip to game output, Skip to command input, Skip to chat, Skip to character status, Skip to ability bar
- [ ] Skip links work correctly in both NVDA+Firefox and VoiceOver+Safari

## Notes
Multiple skip links must be presented as a list (`<ul>`) that is itself visually hidden but appears on focus. Avoid `display:none` — use the `.sr-only` / clip-rect pattern so screen readers can reach them. Test landmark list in JAWS, NVDA, and VoiceOver separately as each surfaces landmarks differently.
