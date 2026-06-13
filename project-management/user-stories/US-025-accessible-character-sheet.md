---
id: US-025
title: "Accessible character sheet output"
slug: "accessible-character-sheet"
personas: [P-005]
epic: "Character System"
priority: "should-have"
complexity: "M"
tags: [accessibility, character, screen-reader, aria, text-output, a11y]
---

# US-025: Accessible Character Sheet Output

## User Story

**As a** blind accessibility game developer (P-005),
**I want to** render a character's state as a structured, screen-reader-friendly text output,
**So that** blind and low-vision players can navigate their character sheet in a logical reading order without visual layout dependencies.

## Acceptance Criteria

- [ ] Given a `Character` object, when I call `character.to_accessible_text()`, then the output is a plain-text string organized into clearly labeled sections: Identity, Stats, Inventory, Relationships, Knowledge — in that order with section headers.
- [ ] Given `character.to_accessible_text()` output, when it is fed to a screen reader, then each section header is distinguishable (e.g., prefixed with `##` for text mode, or rendered as an ARIA heading in HTML mode) and items within each section are separated by newlines.
- [ ] Given a character with 15 inventory items, when I call `character.to_accessible_html()`, then the output is a valid HTML fragment using `<section>`, `<h2>`, `<ul>`, and `<li>` elements with appropriate `aria-label` attributes on each section.
- [ ] Given the HTML character sheet, when a screen reader user navigates by heading (e.g., using H key in NVDA/JAWS), then they can jump directly to any of the five sections without traversing all items.
- [ ] Given a stat value change (e.g., health decreasing in combat), when the HTML character sheet is embedded in a game UI and updated, then the changed stat region is marked with `aria-live="polite"` so screen readers announce the update automatically.
- [ ] Given a character with no items in a section (e.g., empty inventory), when I call `to_accessible_text()`, then the section is still rendered with the header followed by "None." rather than being omitted entirely.

## Notes

Tomás (P-005) is building an accessibility-first text MMORPG (Blade of Eternity) on top of NoizuRPG. The accessible character sheet is a prerequisite for that use case and mirrors the ARIA live region patterns Blade of Eternity uses for combat and world event announcements. Both `to_accessible_text()` (for CLI/terminal games) and `to_accessible_html()` (for web-rendered games) must be supported. See US-011 for the base character stat model and US-005 for the game loop where character state is surfaced.
