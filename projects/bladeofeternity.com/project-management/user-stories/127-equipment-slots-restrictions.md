# US-127: Equipment Slots and Restrictions

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P0
**Epic:** Item Framework & Equipment

## Story
As Marcus, I want a clearly structured equipment slot system with screen-reader-friendly labels and comparison output so that I can optimize my gear loadout at competitive speed without visual reference.

## Acceptance Criteria
- [ ] Eleven named equipment slots: weapon (main-hand), off-hand (shield/weapon/focus), head, chest, legs, feet, ring-left, ring-right, amulet, belt, back — each with a stable ARIA label and landmark role
- [ ] Each slot enforces type restrictions (e.g., off-hand accepts: shield, dagger, focus, torch — not two-handed weapons); violation returns an immediate narrated error: "The greatsword requires both hands; your off-hand slot must be empty."
- [ ] Class restrictions enforced at equip time with prose explanation: "Mages may not equip heavy armor — the weight disrupts spellweaving."
- [ ] Level restrictions enforced with narrated gap: "Requires level 20; you are level 14."
- [ ] Equipment screen renders as a screen-reader navigable list: each slot announces slot name, equipped item (or "empty"), and item level/rarity in a single readable line
- [ ] Equipping an item triggers a one-sentence change summary via ARIA live region (polite): "You equip the iron kite shield in your off-hand slot."
- [ ] Two-handed weapons automatically clear the off-hand slot with confirmation prompt and narrated consequence
- [ ] Equipment screen supports keyboard shortcut to compare highlighted item with current slot occupant without leaving the inventory screen

## Notes
NVDA+Firefox combination is Marcus's environment. All interactive elements must work with arrow key navigation, Enter to activate, and Escape to cancel. No mouse-only affordances.

Slot labels must be consistent across all surfaces (inventory, shop, loot, comparison tooltip) — if it is called "ring-left" in the equipment screen it must be called "ring-left" everywhere. Inconsistent naming causes silent navigation errors for screen reader users.

The two-handed weapon clearing off-hand behavior is a footgun: a user mid-combat might accidentally clear a valued shield. Confirmation prompt should be bypassed if the off-hand is empty but required if an item is present. Prompt must be keyboard-dismissable.

Ring slots present an accessibility question: "ring-left" and "ring-right" are spatial metaphors that are meaningless to a blind user. Consider renaming to "ring (slot 1)" and "ring (slot 2)" or allowing user to label them. This is worth a follow-up UX discussion before P0 implementation.

Class restriction data should live in a config file (not hardcoded) so that new classes added later automatically inherit the restriction framework without code changes.
