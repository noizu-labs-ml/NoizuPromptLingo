# US-178: Character Class Selection

**Persona:** Marcus — Blind power gamer prioritizing competitive viability
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Marcus, I want to select from five distinct base classes during character creation with accessible comparison of abilities, stat weights, and playstyle so that I can make an informed strategic choice without needing sighted assistance.

## Acceptance Criteria
- [ ] Five base classes available at character creation: Warrior (high Strength/Endurance, melee focus), Rogue (high Agility/Perception, stealth/burst), Mage (high Intelligence, ranged spellcasting), Ranger (balanced Agility/Perception, ranged physical), Healer (high Intelligence/Charisma, support/restoration)
- [ ] Class selection screen fully navigable via keyboard; arrow keys cycle through classes, each class focus triggers immediate SR announcement of class name, primary stats, signature ability, and recommended playstyle descriptor
- [ ] Side-by-side comparison mode accessible via keyboard command: SR reads two selected classes attribute-by-attribute with delta values ("Warrior Strength weight: 1.5x vs Mage: 0.8x")
- [ ] Each class has a plain-language narrative description of combat experience read aloud on selection (e.g., "As a Warrior, you stand at the front line, absorbing blows and dealing crushing melee strikes")
- [ ] Class selection is confirmed with an explicit two-step confirmation to prevent accidental locking of choice
- [ ] Starting attribute array displayed per class showing base values for all six attributes before confirmation
- [ ] Class abilities list (at least three signature active abilities and two passive traits) readable in SR before confirming selection
- [ ] Class choice stored server-side and immutable after confirmation; changing class requires character deletion with explicit warning

## Notes
For Marcus, class selection is a high-stakes decision made entirely through audio. The comparison mode is critical — sighted players scan a table in seconds; Marcus needs a structured traversal that delivers equivalent information. The narrative playstyle descriptor should be evocative and functional simultaneously: "Rogues attack from shadow, dealing massive burst damage but dying quickly if caught in open combat" tells him both flavor and mechanical truth. Priya (accessibility advocate) should be consulted during QA to verify the comparison flow works across NVDA, JAWS, and VoiceOver. The two-step confirmation mirrors best practices from US-074 (modal dialogs); the warning about immutability must be unambiguous. Future expansion: subrace selection layered onto class (see US-181 specialization).
