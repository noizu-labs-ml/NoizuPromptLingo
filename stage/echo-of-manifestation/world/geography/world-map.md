# Echo of Manifestation — World Map Structure

The Twilight Zone is procedurally generated each run, but follows a fixed macro-structure. Each zone is a depth layer the player descends through, composed of 3-5 randomly assembled room templates connected by shadow corridors.

## Zone Layout (per run)

```
Zone Layout (per run):
┌──────────────────────────────────────────────────────────┐
│                    ZONE LAYER (Depth N)                    │
│                                                            │
│  ┌─────────┐    ┌──────────┐    ┌──────────┐              │
│  │ Entry    │───▶│ Room A   │───▶│ Room B   │              │
│  │ Shrine   │    │ (combat) │    │ (puzzle) │              │
│  └─────────┘    └────┬─────┘    └────┬─────┘              │
│                      │               │                     │
│                      ▼               ▼                     │
│               ┌──────────┐    ┌──────────┐                │
│               │ Room C   │───▶│ Room D   │                │
│               │ (loot)   │    │ (boss)   │──▶ Threshold    │
│               └──────────┘    └──────────┘    Shrine       │
│                      ▲                                     │
│                      │                                     │
│               ┌──────────┐                                 │
│               │ Secret   │                                 │
│               │ Room     │ (lore fragment + rare essence)  │
│               └──────────┘                                 │
│                                                            │
│  Key:  ▶ = shadow corridor    ◀ = one-way drop            │
│        [TDP] = Time Dilation Pocket  [SN] = Shadow Node   │
└──────────────────────────────────────────────────────────┘
```

## Procedural Rules

- Each zone layer contains 3-5 rooms from a pool of 12-18 templates per zone theme
- At least 1 Time Dilation Pocket per layer (max 3)
- 1 secret room per layer (requires specific item or Insight ability to access)
- Boss room always in the final room of each zone
- Shadow Nodes spawn at semi-random positions within rooms (varies per run)
- Room connections are randomized but guarantee a path from Entry to Boss

## Zone Index

| Zone | Theme | Essence Density | Chimera Tier | Boss | Unique Hazard |
|------|-------|----------------|-------------|------|--------------|
| 1 — Faded Chapel | Crumbling church, pews and stained glass half-materialized | Low (nodes yield 5-12) | Tier 1 (HP 50-80, damage 8-12) | The Echoed Deacon | Collapsing floor tiles |
| 2 — Sunken Market | Flooded bazaar stalls, goods floating in chest-deep shadow-water | Medium (nodes yield 10-20) | Tier 1-2 (HP 60-120, damage 10-18) | The Merchant of Mirrors | Rising shadow-water |
| 3 — Bleached Asylum | White corridors, flickering lights, medical equipment fused with shadow | Medium (nodes yield 15-25) | Tier 2 (HP 100-160, damage 15-22) | The Attending Shadow | Hallway loops |
| 4 — Petrified Forest | Trees turned to black stone, leaves frozen mid-fall, silence | Medium-high (nodes yield 20-35) | Tier 2-3 (HP 140-220, damage 18-28) | The Heartwood Echo | Petrification zones |
| 5 — Shattered Observatory | Broken telescopes, star charts showing wrong constellations, zero gravity pockets | High (nodes yield 30-50) | Tier 3 (HP 200-300, damage 22-35) | The Astral Chimera | Gravity inversions |
| 6 — The Resonance Core | Engine room of reality, gears and pistons made of solidified shadow | High (nodes yield 40-60) | Tier 3-4 (HP 280-400, damage 28-42) | The Grand Manifestation | Essence overload |
| 7 — Plane of Echoes | Mirror of the material world, everything reversed and corrupted | Very high (nodes yield 50-80) | Tier 4 (HP 350-500, damage 35-50) | The First Alchemist | Shadow doubles |
| 8 — The Threshold | The boundary itself, nothing is fixed, reality and echo merge | Extreme (nodes yield 60-100) | Tier 4-5 (HP 450-600, damage 40-60) | The Manifestation | Total manifestation |
