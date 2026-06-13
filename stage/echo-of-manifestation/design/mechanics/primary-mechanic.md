# Echo of Manifestation — Primary Mechanic: The Manifestation System

Every transmutation creates both an item for the player and a chimera for the world. The chimera's power is a warped echo of the item's function. This is the central tension of the game: creation IS summoning.

## Manifestation Echo Table

| Item Category | Player's Item | Chimera's Warped Echo | Threat Modifier |
|--------------|---------------|----------------------|-----------------|
| **Melee Weapon** | Iron Sword (25 damage, 80 durability) | Shadow Blade — fast, lunging chimera with jagged shadow-sword. Deals 15 damage per hit, moves 40% faster than base chimeras | x1.2 |
| **Ranged Weapon** | Essence Bow (20 damage, 15 arrows) | Shadow Archer — chimera that fires tracking shadow-bolts from elevated positions. Bolts deal 12 damage and slow player 20% for 2s | x1.3 |
| **Barrier** | Stone Barricade (blocks 200 damage, 120s duration) | Shadow Wall — chimera that creates shadow-barriers to trap the player in enclosed spaces, then closes in | x1.1 |
| **Trap** | Spike Snare (deals 40 damage, triggers on proximity) | Shadow Trap — chimera that places invisible shadow-snares that deal 25 damage and immobilize player for 1.5s | x1.4 |
| **Healing** | Vitality Elixir (restores 50 HP over 5s) | Shadow Leech — chimera that drains 3 HP/second from the player when within 8m range. Heals itself from stolen HP | x1.5 |
| **Utility** | Lantern (reveals hidden shadow nodes within 15m) | Shadow Eye — chimera that cloaks itself and nearby chimeras, becoming invisible until it attacks | x1.6 |
| **Explosive** | Essence Bomb (60 damage in 5m radius) | Shadow Blast — chimera that detonates on death, dealing 35 damage in 4m radius | x1.3 |
| **Shield** | Transmuter's Ward (absorbs 100 damage, 60s cooldown) | Shadow Shell — chimera armored with shadow plating; takes 50% less damage until shell is broken by 3 consecutive hits | x1.2 |

**Threat Modifier** multiplies the base chimera stats (HP, damage, speed) for that echo type. Higher modifiers mean deadlier chimeras but also more useful items.

## The Divination System

Before transmuting, the player can use the Crystal Ball to preview the manifestation.

**Divination Tiers** (unlocked via Insight):

| Tier | Insight Cost | Information Revealed | When Available |
|------|-------------|---------------------|----------------|
| 1 — Glimmer | Free (base ability) | Chimera threat level only (weak / moderate / deadly) | From run 1 |
| 2 — Flicker | 5 Insight | Chimera type + threat level | After 3 runs |
| 3 — Pulse | 15 Insight | Chimera type + threat + primary behavior pattern | After 10 runs |
| 4 — Flash | 35 Insight | Full chimera stat preview (HP, damage, speed, weakness) | After 25 runs |
| 5 — Revelation | 60 Insight | All stats + map location where chimera will spawn | After 50 runs |

**Divination Usage**: Each use of the Crystal Ball costs 5 essence and takes 3 seconds (player is vulnerable during divination). The crystal ball has a 15-second cooldown between uses.

## Essence Economy

| Source | Essence Yield | Notes |
|--------|--------------|-------|
| Essence Node (shallow zone) | 5-15 | Common, depletes in 45 seconds after discovery |
| Essence Node (deep zone) | 20-50 | Rare, guarded by ambient chimeras, depletes in 30 seconds |
| Chimera Kill | 10-30 | Depends on chimera tier; stronger chimeras yield more |
| Zone Clear Bonus | 25-75 | Clearing all shadow nodes in a zone layer |
| Environmental Hazards | 2-5 | Collapsing structures, fog traps, twilight surges — risky but free |
| Boss Kill | 100-200 | Major payout; boss essence does not deplete over time |

**Essence Attraction Mechanic**: Carrying more than 100 essence at once begins attracting boss-tier manifestations. A "Resonance Meter" fills at 1% per second while over 100 essence. At 100% Resonance, a Manifested Guardian (mini-boss) spawns and hunts the player until killed or the player drops below 100 essence.

| Essence Carried | Resonance Effect | Risk |
|----------------|-----------------|------|
| 0-50 | None | Safe to scavenge freely |
| 51-100 | Faint hum, shadow nodes glow brighter | Ambient chimeras spawn 10% faster |
| 101-150 | Screen edge darkens, ambient audio distorts | Manifested Guardians spawn at Resonance 100% |
| 151-200 | Camera subtly shakes, footsteps echo louder | Guardians spawn faster (Resonance fills at 2%/s) |
| 200+ | Full visual distortion, chimeras frenzy within 20m | Multiple Guardians possible |
