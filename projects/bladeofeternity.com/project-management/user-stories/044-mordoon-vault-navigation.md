# US-044: Mordoon Vault Navigation

**Persona:** Marcus — Blind Power Gamer (NVDA + Firefox, 90WPM)
**Priority:** P1
**Epic:** World & Exploration

## Story
As Marcus, I want to navigate Mordoon's vault system using numbered vault identifiers and directional memory so that I can efficiently traverse the city of the dead during PvP and raid scenarios.

## Acceptance Criteria
- [ ] Mordoon vaults are uniquely addressable by vault number (e.g., `Vault 7`, `the Ossuary`, `Upper Charnel Hall`)
- [ ] `map` command in Mordoon outputs a text-based adjacency list of known vaults ("Vault 7 connects to: Vault 3 [west], Vault 12 [down], the Antechamber [north]")
- [ ] `breadcrumbs` command shows the player's path from current location back to city entrance
- [ ] `shortcut <destination>` suggests the fastest known route as a sequence of direction commands
- [ ] Vault descriptions reference the "Night at Mordoon" lore — rooms feel continuous with the Twine heritage
- [ ] Darkness mechanic: some vaults are unlit; description changes and navigation warnings are issued (blind users receive equivalent information via alternate sensory cues: sound, smell)
- [ ] `vault-index` command lists all discovered vaults in the player's memory, sortable by name or discovery order

## Notes
- Mordoon is a late-game zone; navigation complexity is intentionally higher than Rune
- "Night at Mordoon" (40-passage Twine story) is canonical lore — vault names and geography must match
- Darkness mechanic must not disadvantage blind players — sound/smell descriptions replace visual cues
- Marcus uses Mordoon for PvP ambushes; low-latency navigation output is critical
- Vault adjacency map is player-discovered, not pre-revealed — discovery state persists per character
