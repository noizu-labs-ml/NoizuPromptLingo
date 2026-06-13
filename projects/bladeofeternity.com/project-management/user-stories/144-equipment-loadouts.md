# US-144: Equipment Loadouts

**Persona:** Marcus — Blind power gamer (28, NVDA+Firefox, PvP)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Marcus, I want to save and instantly switch between equipment presets so that I can transition between combat, crafting, and exploration configurations without manually re-equipping eleven slots mid-session.

## Acceptance Criteria
- [ ] Players can save up to five named loadouts: `loadout save [name]` captures the current state of all eleven equipment slots
- [ ] Loadout switch: `loadout [name]` swaps all equipment to the saved configuration in a single server-side transaction; partial swaps (if some items are missing) are rejected with a clear error listing missing items
- [ ] Loadout switch announces a full change summary via ARIA live region: "Switched to Combat loadout — equipped: steel longsword, iron kite shield, plate helm, plate chest, plate legs, iron boots, ring of strength, ring of fury, battle amulet, fighter's belt, warrior's cloak."
- [ ] Condensed announcement option: `loadout [name] brief` announces only changed slots: "Combat loadout: weapon → steel longsword (was iron longsword), off-hand → iron kite shield (was empty), head → plate helm (was leather cap)."
- [ ] Loadout names are freeform strings (max 24 characters); loadout list displayed via `loadout list` showing names and the item in the weapon slot as a mnemonic
- [ ] Loadouts tolerate missing items gracefully: if a saved item has been sold or destroyed, the slot is left empty and the user is warned: "Combat loadout: ring of strength not found — ring (slot 1) left empty."
- [ ] Loadout switching in combat: allowed but costs one action (does not bypass action economy); switching mid-fight is announced to other combatants: "Marcus begins swapping equipment."
- [ ] Loadout data stored server-side; persists across sessions and devices

## Notes
The full vs. condensed announcement toggle (AC-4) is the key accessibility design decision for Marcus. In calm moments he wants the full confirmation that every slot changed correctly. In mid-combat he wants a fast brief summary. The default should be brief for switches during combat and full for switches outside combat, with explicit override available.

Loadout switching cost of one action (AC-7) is a PvP balance consideration: a player who can instantly swap from a defensive loadout to an offensive loadout with zero cost would have an unfair advantage. One action is a small but real cost that makes loadout timing a tactical skill rather than a free mechanic.

The "missing item" graceful degradation (AC-6) must not silently apply an incomplete loadout: if Marcus saved a loadout with a legendary ring and that ring was destroyed, switching to that loadout and equipping it partially would leave him weaker than expected without knowing why. The warning is mandatory.

Five loadout slots may seem limiting; consider making it configurable per-character (default 5, extendable via a premium slot or high-level achievement). This creates a meaningful goal for organized players.

Loadout data should also record the date of last save so players can see when a loadout was created or last updated — useful when reviewing old loadouts.
