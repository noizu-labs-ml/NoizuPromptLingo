# Currency Design -- Essence

> Essence is raw creative energy distilled from the Twilight Zone. It is the sole currency, the fuel for transmutation, and the measure of how much reality the player has stolen from the boundary between worlds.

---

## Definition

**Essence** is the condensed form of the Threshold's boundary energy. When the membrane between reality and manifestation is disturbed -- by killing chimeras, clearing zones, or harvesting natural deposits -- it bleeds a luminous residue that the Survivor can collect and spend. Essence is not gold. It is not abstract. It is a tangible substance in the Zone's ecology: the difference between what is real and what is imagined, rendered portable.

In game terms, Essence is the single currency unit. There are no secondary currencies, no premium tokens, no real-money equivalents. All economic transactions flow through Essence.

---

## Sources and Yields

### Essence Nodes (Environmental Deposits)

Scattered through each zone in fixed and semi-random locations. Density increases with zone depth.

| Zone | Essence per Node | Nodes per Zone (avg) | Zone Node Total |
|------|-----------------|---------------------|----------------|
| 1 -- Faded Chapel | 5-15 | 8-12 | 40-180 |
| 2 -- Sunken Market | 10-25 | 8-12 | 80-300 |
| 3 -- Bleached Asylum | 15-35 | 10-14 | 150-490 |
| 4 -- Petrified Forest | 20-45 | 10-14 | 200-630 |
| 5 -- Shattered Observatory | 30-60 | 10-14 | 300-840 |
| 6 -- Resonance Core | 40-75 | 10-14 | 400-1,050 |
| 7 -- Plane of Echoes | 50-90 | 10-14 | 500-1,260 |
| 8 -- The Threshold | 60-100 | 10-14 | 600-1,400 |

### Chimera Kills

| Chimera Tier | Essence Yield | Notes |
|-------------|--------------|-------|
| Lesser (Tier 1) | 10-15 | Common in zones 1-3 |
| Greater (Tier 2) | 15-25 | Common in zones 3-6 |
| Apex (Tier 3) | 20-30 | Common in zones 5-8 |
| Boss (All zones) | 100-200 | Per boss kill; scales with zone |

### Zone Clear Bonus

Awarded upon defeating a zone boss and clearing the exit transition.

| Zone | Clear Bonus |
|------|------------|
| 1 | 25 |
| 2 | 35 |
| 3 | 45 |
| 4 | 55 |
| 5 | 60 |
| 6 | 65 |
| 7 | 70 |
| 8 | 75 |

### Environmental Interactions

| Source | Yield | Frequency |
|--------|-------|-----------|
| Twisted Dimensional Pockets (cleared) | 2-5 | 1-3 per zone |
| Secret room discovery | 5-10 | 0-2 per zone |
| Lore fragment pickup | 0 (no essence) | -- |

---

## Sinks (Expenditure)

### Transmutation Recipes

Every transmutation costs Essence. The cost scales by tier:

| Tier | Essence Cost Range | Recipe Count | Notes |
|------|-------------------|-------------|-------|
| 1 | 10-20 | 8 | Starting recipes |
| 2 | 25-40 | 6 | Zones 1-2 |
| 3 | 45-65 | 8 | Zones 3-4 |
| 4 | 70-90 | 6 | Zones 5-6 |
| 5 | 95-120 | 4 | Zone 7 |
| 6 | 125-160 | 6 | Zone 8 |

**Average transmutation cost per tier:**

| Tier | Average Cost |
|------|-------------|
| 1 | 14.5 |
| 2 | 30.0 |
| 3 | 53.0 |
| 4 | 80.0 |
| 5 | 107.5 |
| 6 | 142.5 |

A typical run involves 5-12 transmutations depending on playstyle. A conservative player spends ~200-350 essence on transmutations per run; an aggressive alchemist can spend 400-600.

### Divination System

Each use of the Divination system (revealing hidden rooms, traps, chimera positions) costs **5 essence per use**. Divination tier determines accuracy and range, not cost. A typical run uses Divination 10-25 times, costing 50-125 essence.

### Librarian Exchanges

| Exchange Type | Cost | Typical Uses per Run |
|--------------|------|---------------------|
| Lore Hint | 50 | 0-3 (150 max) |
| Chimera Behavioral Data | 75 | 0-2 (150 max) |
| Zone Preview | 100 | 0-1 per zone transition |
| Dialogue Chain Unlock | 150 | 0-1 per run (sequential unlock) |

A player who uses the Librarian heavily will spend 150-400 essence per run on exchanges.

### Time Dilation Surcharge

Time Dilation Pockets allow the player to slow time temporarily. Activating a pocket costs 50% more essence than a standard transmutation of equivalent tier. The base cost is drawn from the zone's transmutation tier range; the surcharge is applied on top.

Example: A Tier 3 Time Dilation activation costs 45-65 base + 50% = 67.5-97.5 essence (rounded).

---

## Resonance Mechanic

Carrying large quantities of Essence has consequences. The Zone is aware of stolen boundary energy and responds to concentrated Essence the way a body responds to a foreign object.

### Resonance Meter

The player has a **Resonance Meter** (0-100%) that fills based on current Essence carried:

| Essence Carried | Resonance Level | Effect |
|----------------|----------------|--------|
| 0-50 | 0% (Safe) | No effect |
| 51-100 | 1-30% (Low) | Subtle visual distortion; faint ambient sound changes |
| 101-150 | 31-60% (Moderate) | Chimera spawn rate +15%; Guardian chimeras begin appearing |
| 151-200 | 61-85% (High) | Chimera spawn rate +30%; environmental hazards activate near player |
| 200+ | 86-100% (Extreme) | Chimera spawn rate +50%; Guardians actively hunt the player; environmental damage ticks (1 HP/sec) |

### Resonance Fill Rate

The meter fills at approximately **1% per second** when above the safe threshold. This means:

- At 100 essence: ~30 seconds before Moderate resonance
- At 150 essence: ~25 seconds before High resonance
- At 200+ essence: ~15 seconds before Extreme resonance

### Reducing Resonance

| Method | Reduction | Notes |
|--------|-----------|-------|
| Spend Essence (any sink) | Immediate drop proportional to spend | Most common method |
| Enter a safe zone | Drops to 0% over 10 seconds | Safe zones are few per zone |
| Die | Drops to 0% (but carried essence is lost) | Harsh but effective |
| Resonance Dampener (Insight 85) | Fills at 0.5% per second instead of 1% | Halves accumulation rate |

### Guardian Chimeras

At Moderate resonance (31%+) and above, **Guardian chimeras** spawn. These are elite variants that:

- Are 25% faster and deal 30% more damage than standard chimeras of the same tier
- Drop 50% more essence when killed
- Have a distinctive visual (amber-glow aura)
- Prioritize the player over other targets

Guardian spawn rate scales with resonance level. At Extreme, Guardians spawn every 45-60 seconds.

---

## Essence Balance per Zone Depth

Estimated essence flow for a mid-skill player per zone:

| Zone | Income (nodes + kills + bonus) | Avg Expenditure (transmute + divine) | Net Flow |
|------|-------------------------------|-------------------------------------|---------|
| 1 | 115-395 | 50-80 | +65 to +315 |
| 2 | 175-545 | 80-140 | +95 to +465 |
| 3 | 255-815 | 120-200 | +135 to +695 |
| 4 | 335-1,005 | 140-240 | +195 to +865 |
| 5 | 475-1,305 | 180-320 | +295 to +1,125 |
| 6 | 615-1,655 | 200-400 | +315 to +1,455 |
| 7 | 745-1,945 | 240-480 | +505 to +1,705 |
| 8 | 845-2,155 | 280-560 | +585 to +1,875 |

**Design intent:** The early zones (1-3) are essence-tight to teach resource discipline. Mid zones (4-6) provide comfortable surplus for players who engage with the Librarian and transmutation systems. Late zones (7-8) are essence-rich to compensate for extreme danger, but the Resonance mechanic punishes hoarding.

---

## Essence Economy Design Principles

1. **Scarcity creates tension.** Essence is the only resource that matters. Every expenditure is a decision.
2. **Resonance prevents hoarding.** Players cannot stockpile essence without consequence. The game actively punishes greed.
3. **Spending is power.** Essence spent on transmutations directly translates to combat capability. A player who saves too much is weaker than one who spends.
4. **The Librarian taxes knowledge.** Information costs essence. The player must choose between combat power (transmutations) and narrative/strategic advantage (Librarian exchanges).
5. **The economy accelerates.** Income scales faster than expenditure across zones, but Resonance keeps the surplus dangerous. The design goal is that a skilled player feels increasingly wealthy but never safe.

---

*This document is the canonical currency design reference for Echo of Manifestation. All economy balancing, tuning, and QA testing should reference this file alongside the balance sheet.*
