# US-072: Housing Purchase and Interior Customization

**Persona:** Sarah — Low-Vision, Toggles VoiceOver
**Priority:** P2
**Epic:** Housing

## Story
As Sarah, I want to purchase a home and customize its interior using text commands so that I have a personal space that reflects my character's identity and is fully accessible in both visual and screen reader modes.

## Acceptance Criteria
- [ ] Housing districts are accessible zones with available properties listed via `HOUSING LIST [district]`: property name, size, price, amenities
- [ ] `PURCHASE PROPERTY [id]` confirms price, location, and size before final commitment with Y/N prompt
- [ ] Interior customization uses a room-based system: `GO TO [room]`, `PLACE [furniture/item] [position]`, `DECORATE [surface] WITH [item]`
- [ ] `DESCRIBE ROOM` generates an accessibility-first prose description of the current room state (readable by VoiceOver)
- [ ] Furniture placement is confirmed in text: "You place the oak writing desk against the north wall. The study now holds: writing desk, bookshelf, hearth."
- [ ] Home can be set to public/private/friends-only access via `HOME ACCESS [setting]`
- [ ] Visual mode renders the home as a styled HTML layout; VoiceOver mode reads room descriptions as navigable sections

## Notes
Sarah needs both modes to work. The visual layout should derive from the same room-description data, not a separate rendering path. Interior customization must never require drag-and-drop — all furniture placement via directional commands. Screen reader output for room state should be a clean list within a `<section>` with descriptive heading.
