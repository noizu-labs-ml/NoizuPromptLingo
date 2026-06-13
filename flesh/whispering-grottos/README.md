# Whispering Grottos

**Narrative / Puzzle / Atmospheric**

---

## Vision Statement

A peaceful narrative puzzle game where you heal wounded creatures with herbal remedies in a bioluminescent cave system, slowly restoring a corrupted ecosystem while uncovering the intertwined stories of twelve forgotten spirits. No combat, no timers — just thoughtful exploration, gentle crafting, and environmental storytelling.

**Genre**: Atmospheric puzzle-adventure (comparable to A Short Hike, Abzu, Ori's exploration)
**Platform**: PC (Steam), PlayStation 5, Xbox Series X/S, Nintendo Switch
**Engine**: Unity (URP) — lightweight rendering, strong Switch support, shader graph for bioluminescence
**Monetization**: Premium $24.99 — complete standalone experience, no IAP, no microtransactions
**Rating**: E (Everyone) — thematic elements of death and loss (non-graphic, handled with care)

---

## Core Loop

```
Explore Grotto → Discover Wounded Creature → Diagnose Symptoms → Forage Herbs → Craft Remedy → Heal Creature → Ecosystem Restores → New Area / Spirit Memory Unlocked → (repeat)
```

**Session target**: 20-40 minutes of peaceful, self-paced play.

### Loop Detail

1. **Explore** — Wander bioluminescent cave chambers. No enemies, no danger. The grotto IS the puzzle — paths open as you heal creatures and restore areas.
2. **Discover** — Find a wounded creature. Observe its symptoms through visual cues (shivering, discoloration, unusual growths, behavior patterns). No UI diagnostic — pure visual reading.
3. **Diagnose** — Cross-reference symptoms with your herbal codex (built from experience). Earlier cures teach you patterns that apply to later, more complex cases.
4. **Forage** — Search the grotto for herbs. Herb locations change based on ecosystem health — restored areas grow rarer herbs, creating a positive feedback loop.
5. **Craft** — Mix herbs at sacred springs. A gentle timing minigame: pour, stir, infuse. Timing affects potency but never fails — there's no "wrong" outcome, just "better."
6. **Heal** — Apply the remedy. The creature recovers in a beautiful animation sequence — the room's corruption fades, bioluminescence returns, ambient music swells.
7. **Unlock** — Ecosystem restoration opens new paths. Spirit memory fragments appear. New creatures with new symptoms emerge in restored areas.

---

## Meta Loop

```
Chapter Completion → Spirit Story Reveal → New Grotto Region Unlocked → New Herb Families → More Complex Diagnoses → Codex Filling → World State Changes → (repeat across 6 chapters)
```

### Progression Axes

| Axis | What Grows | How It Feels |
|------|-----------|-------------|
| **Knowledge** | Herbal codex fills with remedies | "I'm becoming a healer" |
| **Ecosystem** | Grotto transforms from corrupt to luminous | "I'm making this place beautiful" |
| **Narrative** | Spirit memories form a coherent story | "I understand what happened here" |
| **Skill** | Diagnosis becomes intuitive, not lookup-based | "I can read creatures without my codex" |
| **World state** | Previously visited areas change as creatures return | "My actions have lasting impact" |

---

## Game Mechanics

### Herbal Crafting System

**Design Philosophy**: Pattern recognition, not recipe lookup. Players learn herb properties through observation and experimentation, building internal knowledge rather than consulting a wiki.

#### Herb Families (6 families, 47 total herbs)

| Family | Properties | Visual Theme | Found In |
|--------|-----------|-------------|----------|
| **Luminos** (8 herbs) | Glow-based healing, treats light deprivation | Pale blue-white, emits faint glow | Deep caves, low-light areas |
| **Verdantis** (9 herbs) | Growth and regrowth, treats physical wounds | Green with golden veins, leafy | Restored mossy areas |
| **Umbralis** (8 herbs) | Shadow purging, treats corruption | Deep purple-black, absorbs light | Corrupted zones (must purify first) |
| **Aquarion** (7 herbs) | Water-based, treats internal ailments | Translucent, flowing, water-like | Sacred spring pools |
| **Crystallis** (8 herbs) | Structural healing, treats bone/shell damage | Geometric, faceted, gem-like | Crystal formations |
| **Aetheris** (7 herbs) | Spirit-binding, treats soul afflictions | Ethereal, floating, barely visible | Spirit memory locations |

#### Crafting Mechanics

**Gathering**: Herbs grow in specific biomes. Player learns where to find them through visual environment cues (moss patterns, water color, crystal formations). No random drops — deterministic placement with some variation per playthrough.

**Mixing**: At sacred springs, combine 2-3 herbs into remedies.

```
Herb A + Herb B = Base Remedy (cures 1 symptom)
Herb A + Herb B + Herb C = Advanced Remedy (cures 2-3 symptoms)
Timing the pour/stir/infuse = Potency modifier (standard / enhanced / perfect)
```

**Potency affects**: Healing speed (animation duration), ecosystem restoration quality (visual richness), and spirit memory clarity (full vs partial memory fragment).

**There is no failure state.** Even a "poor" remedy heals the creature. Potency is about mastery, not pass/fail.

#### Diagnosis System

Creatures show 2-5 visual symptoms per case. Player must identify which herbs treat which symptoms.

| Complexity | Symptoms | Chapter | Example |
|-----------|----------|---------|---------|
| Simple | 1-2 | 1-2 | "Shivering + pale skin → Luminos + Aquarion" |
| Moderate | 2-3 | 3-4 | "Corrupted spots + limping + dark eyes → Umbralis + Verdantis + Crystallis" |
| Complex | 3-4 | 5 | "Floating aimlessly + transparent + cold aura + faint song → Aetheris + Luminos + Aquarion + Umbralis" |
| Master | 4-5 | 6 | Multi-creature cascade where healing one reveals another's hidden symptoms |

### Spirit Dialogue System

12 spirits, each with a complete story arc told through 5-8 memory fragments scattered across the grotto.

#### Spirit Story Structure

| Spirit | Role in Kingdom | Central Theme | Fragment Count |
|--------|----------------|--------------|----------------|
| **The Gardener** | Royal botanist | Sacrifice for beauty | 6 |
| **The Shieldmaiden** | Palace guard | Duty vs compassion | 7 |
| **The Child** | Young princess | Innocence lost | 5 |
| **The Smith** | Forge master | Creation and destruction | 6 |
| **The Singer** | Court musician | Art as resistance | 8 |
| **The Healer** | Predecessor to player | Legacy and failure | 7 |
| **The Builder** | Architect of the grotto | Hubris | 6 |
| **The Judge** | Kingdom's magistrate | Justice vs mercy | 5 |
| **The Scholar** | Keeper of knowledge | Truth vs comfort | 7 |
| **The Mother** | Village elder | Generational grief | 6 |
| **The King** | Ruler of the fallen kingdom | Power and regret | 8 |
| **The Voice** | The grotto itself | Everything connects | 5 (final, unlocks after all others) |

**Fragment Discovery**: Memory fragments appear as environmental objects — a cracked lantern, a torn letter, a frozen musical note. Interacting with them triggers a brief voice-over (2-30 seconds) in the spirit's voice, revealing a piece of their story.

**No text walls.** Every fragment is short, atmospheric, and voiced. Players piece together the full narrative through exploration, not reading.

**Recontextualization**: Late-game fragments change the meaning of earlier discoveries. The Gardener's final fragment reveals the kingdom didn't fall to invasion — it was poisoned by its own remedies. This recontextualizes every cure the player has made.

### Ecosystem Restoration

**The core visual hook**: The grotto transforms in real-time as you heal creatures.

| Ecosystem Stage | Visual State | Music | Gameplay Effect |
|----------------|-------------|-------|-----------------|
| **Corrupted** | Purple-black shadows, silence, decay | Low ambient drone | Limited herbs, few creatures |
| **Fading** | Spots of color appearing, distant sounds | Gentle melody emerges | Common herbs return |
| **Recovering** | Bioluminescence spreading, wildlife sounds | Full ambient track | Rare herbs grow, new creatures |
| **Restored** | Full luminous teal, rich ambient life | Complete orchestral score | All herbs available, spirit memories clear |
| **Thriving** | Player-enhanced beauty (bonus for perfect potency) | Unique variation per area | Secret creatures appear |

**Restoration is permanent.** Once you heal a creature in an area, that area stays healed. Players build a beautiful world through care, not combat.

---

## World Design

### Map Structure

```
The Grotto (hub — always accessible)
├── The Crystal Caverns (Chapter 1) — Tutorial area, Luminos + Crystallis herbs
│   ├── The Shimmering Pool (sacred spring)
│   ├── The Fracture (first wounded creature)
│   └── The Gardener's Greenhouse (spirit area)
├── The Moss Labyrinth (Chapter 2) — Verdantis herbs, path puzzles
│   ├── The Living Walls
│   ├── The Pollen Chambers
│   └── The Shieldmaiden's Armory
├── The Shadow Depths (Chapter 3) — Umbralis herbs, corruption puzzles
│   ├── The Void Gardens
│   ├── The Whispering Hall
│   └── The Child's Nursery
├── The Flooded Vaults (Chapter 4) — Aquarion herbs, water puzzles
│   ├── The Sunken Library
│   ├── The Reflecting Pools
│   └── The Smith's Forge
├── The Crystal Spires (Chapter 5) — Complex multi-symptom creatures
│   ├── The Resonance Chamber
│   ├── The Frozen Orchestra
│   └── The Healer's Sanctuary
└── The Heart of the Grotto (Chapter 6) — Final chapter, all herbs, all spirits converge
    ├── The Memory Gardens
    ├── The King's Throne
    └── The Voice (final spirit encounter)
```

### Art Direction

**Visual Pillars**:
- **Serene decay** — Crumbling architecture reclaimed by nature, not destroyed by violence
- **Bioluminescent beauty** — Teal, amber, soft purple lighting; no harsh white or red
- **Creature vulnerability** — Animations emphasize fragility, gentleness, trust
- **Environmental storytelling** — Every object placement tells a story; no set dressing without purpose

**Color Progression**:

| Chapter | Corruption Palette | Restored Palette |
|---------|-------------------|-----------------|
| 1. Crystal Caverns | Pale gray, faint shadows | Warm amber, crystal refraction |
| 2. Moss Labyrinth | Sickly brown, withered vines | Rich green, golden pollen |
| 3. Shadow Depths | Deep purple-black, corrupted growth | Soft violet, healthy darkness |
| 4. Flooded Vaults | Murky green, stagnant water | Clear turquoise, gentle currents |
| 5. Crystal Spires | Cracked, dim crystals | Brilliant refraction, rainbow light |
| 6. Heart of Grotto | All corruption types combined | Unified luminous teal |

---

## Narrative

### Story Spine

1. **Equilibrium**: You are a lone traveler who discovers the entrance to an ancient grotto. The air hums with faint life — something here needs help.
2. **Inciting incident**: You find the first wounded creature, and instinctively begin to heal it. The grotto responds — paths open, light returns.
3. **First complication**: The spirits don't remember why they're here. Their memories are fragmented, scattered by the corruption. Healing creatures unlocks fragments, but the full story resists assembly.
4. **Rising action**: Each spirit's story intersects with others. The Gardener grew the herbs. The Healer used them. The King ordered their use. The truth is uncomfortable.
5. **Midpoint reversal**: The kingdom didn't fall to external forces. The Healer (your predecessor) made a mistake — a remedy that cured the king but poisoned the land. The corruption is the kingdom's own medicine, mutated.
6. **Crisis**: The grotto itself is the final spirit — "The Voice." It has been guiding you to heal it, but the only complete cure requires dissolving all spirit memories. Healing the grotto means the spirits finally rest — and disappear.
7. **Climax**: You must choose — leave the grotto partially healed (spirits remain as echoes) or heal it completely (spirits find peace, but their stories end). Both are valid endings.
8. **Resolution**: The grotto thrives. Nature reclaims the sanctum. The spirits' stories are preserved in the herb knowledge they shared — every future cure carries their legacy.

### Tone

```
HOPEFUL ●●●●●○○ GRIM
SERIOUS ●●●●○○○ WHIMSICAL
SIMPLE  ●●●○○○○ COMPLEX
GROUND  ●●○○○○○ FANTASTICAL
STATIC  ●●●●●○○ DYNAMIC
```

Melancholic beauty with persistent hope. Sadness is present but never despairing. Loss is acknowledged, not denied. The overall feeling: gentle, contemplative, restorative.

---

## Player Personas

### Primary Personas

#### P-006: Eleanor Vance — "The Loyal Strategist" (Primary)

Eleanor is the ideal player. A 62-year-old retired teacher who plays 2-3 hours daily, values depth and intellectual engagement, and despises predatory monetization. She wants games that respect her intelligence and time.

**Why Whispering Grottos fits Eleanor**:
- Premium purchase = no microtransactions, no energy systems
- Herbal diagnosis system rewards careful observation and pattern recognition
- Spirit stories reward the patience and attention she brings from decades of strategy gaming
- No timers, no pressure — she can play at her own pace during morning coffee sessions
- Environmental storytelling appeals to her love of complex, interconnected systems

**Eleanor's experience**: Treats each creature diagnosis as a puzzle. Fills her herbal codex methodically. Takes notes on spirit fragments. Plays one chapter per week, savoring the experience. Likely to 100% the game. Will recommend it to her book club.

#### P-008: David Park — "The Completionist" (Primary)

A 34-year-old software engineer who treats every game as a completion project. Uses spreadsheets. Never drops below 90% completion.

**Why Whispering Grottos fits David**:
- 47 herbs to discover + codex entries to complete = clear 100% target
- Perfect potency challenges for each remedy = skill-based achievements
- 12 spirit story completions + 76 memory fragments = collectible tracking
- Ecosystem restoration percentage per area = measurable progress
- No RNG-based achievements — everything achievable through exploration and skill

**David's experience**: Will map every herb location, optimize every remedy for perfect potency, collect every spirit fragment. Will finish in ~25 hours, achieve 100%, then check if there's a "thriving" state beyond "restored" for bonus completion. Will be slightly disappointed if there isn't a post-game completion tracker.

### Secondary Personas

#### P-013: Robert Thompson — "The Relaxation Player" (Secondary)

A 41-year-old burnt accountant who plays 10-15 minutes nightly to decompress. Wants zero stress, zero decisions, zero timers.

**Why Whispering Grottos fits Robert**:
- No combat, no timers, no fail states — pure relaxation
- Herb gathering is meditative, not demanding
- Bioluminescence and ambient soundtrack are genuinely calming
- No ads, no pop-ups, no interruptions (premium game)
- Can pick up and put down at any point — no session commitments

**Robert's experience**: Plays one creature per night before bed. The healing animations and music are his reward. Doesn't engage deeply with spirit stories but enjoys the ambient narrative. Will play for 6-8 weeks at this pace. Worth every penny of $24.99 for the stress relief alone.

#### P-002: Sarah Chen — "The Micro-Gamer" (Secondary)

A 35-year-old marketing manager and mother who plays in 15-20 minute bursts. Collects cute characters, values fair progression.

**Why Whispering Grottos fits Sarah**:
- Short session loops (diagnose + gather + craft + heal = 15-20 min)
- Creatures are designed to be empathetic and endearing (she'll want to heal them all)
- Visual transformation of the grotto = satisfying progress feedback
- No gacha, no energy systems, no predatory mechanics
- She can play between family duties without losing progress

**Sarah's experience**: Plays during nap time and after kids' bedtime. Gets emotionally attached to specific creatures. Will tear up at The Child's spirit story. Will recommend to her mom-friends as "the peaceful game."

---

## User Stories

### Exploration & Navigation

- **US-001**: As a player, I want to explore the grotto at my own pace without enemies or timers, so I can feel peaceful and unpressured.
- **US-002**: As a player, I want to see visual changes in previously visited areas as I heal creatures, so I feel my actions have lasting impact.
- **US-003**: As a player, I want paths to open organically as the ecosystem restores, so discovery feels earned rather than gated.
- **US-004**: As a player, I want a gentle guidance system (bioluminescent trails) that shows me where to go next without a minimap or quest markers, so I maintain immersion.
- **US-005**: As a player (David), I want a map that fills in as I explore and shows restoration percentage per area, so I can track my completion progress.
- **US-006**: As a player (Eleanor), I want to fast-travel between restored sacred springs, so I don't replay navigated areas.

### Creature Healing

- **US-007**: As a player, I want to observe creature symptoms visually (shivering, discoloration) rather than through UI prompts, so diagnosis feels immersive.
- **US-008**: As a player, I want my herbal codex to fill with knowledge as I discover and use herbs, so I feel like I'm becoming a skilled healer.
- **US-009**: As a player, I want herb gathering to be deterministic (same herbs in same biomes) with some seasonal variation, so I can plan my gathering routes.
- **US-010**: As a player, I want the crafting minigame to be satisfying but never punishing, so even imperfect remedies succeed.
- **US-011**: As a player (David), I want a potency rating (standard/enhanced/perfect) for each remedy I craft, so I can optimize and track mastery.
- **US-012**: As a player, I want to see a beautiful healing animation where the creature recovers and the room transforms, so curing feels emotionally rewarding.
- **US-013**: As a player (Robert), I want the crafting to be simple enough to do while half-asleep, so I can play before bed without frustration.

### Spirit Stories

- **US-014**: As a player, I want to discover spirit memory fragments by exploring and interacting with environmental objects, so the story feels earned rather than told.
- **US-015**: As a player, I want memory fragments to be short (2-30 seconds) and voiced, so I absorb the story without reading text walls.
- **US-016**: As a player (Eleanor), I want late-game fragments to recontextualize earlier discoveries, so I experience genuine surprise and insight.
- **US-017**: As a player, I want a spirit journal that tracks which fragments I've found and shows connections between spirits, so I can piece together the overarching narrative.
- **US-018**: As a player, I want the final spirit (The Voice) to synthesize all stories into a coherent whole, so the ending feels earned and complete.

### Ecosystem & World State

- **US-019**: As a player, I want each healed creature to visibly restore its surrounding area (new growth, clearer water, brighter light), so the world transforms as I play.
- **US-020**: As a player, I want the music to evolve from sparse ambient drone to rich orchestral score as areas restore, so the audio reinforces visual progress.
- **US-021**: As a player, I want restored areas to grow rarer herbs, creating a positive feedback loop between healing and foraging, so progress accelerates naturally.
- **US-022**: As a player (David), I want a "thriving" state beyond "restored" achievable only through perfect-potency cures, so there's a mastery layer for completionists.
- **US-023**: As a player, I want wildlife to return to restored areas (butterflies, fireflies, small fish), so the grotto feels alive.

### Accessibility & Comfort

- **US-024**: As a player, I want to pause at any time with no penalty, so I can attend to real-life interruptions.
- **US-025**: As a player, I want customizable text size and contrast for the herbal codex and spirit journal, so I can read comfortably.
- **US-026**: As a player, I want to adjust the intensity of bioluminescent effects (for photosensitive players), so the game is accessible.
- **US-027**: As a player, I want full controller support across all platforms with customizable button mapping, so I can play comfortably.
- **US-028**: As a player (Robert), I want an explicit "no fail" mode that guarantees even the simplest remedy heals the creature, so I never feel stuck.

### Narrative & Ending

- **US-029**: As a player, I want the ending choice (partial vs complete healing) to feel genuinely difficult, so the narrative has emotional weight.
- **US-030**: As a player, I want both endings to feel valid and satisfying, so I don't feel punished for either choice.
- **US-031**: As a player (Eleanor), I want a post-game state where I can continue exploring the fully restored grotto, so the world doesn't end with the credits.
- **US-032**: As a player, I want the spirits' stories preserved in the herbal codex after the ending, so their knowledge (and legacy) persists.

---

## Monetization

### Premium Model ($24.99)

**Why premium**: The game's identity is peace, patience, and care. Any monetization that introduces pressure (energy systems, timers, paywalls) contradicts the core fantasy. Premium pricing respects the player's time and matches the complete-experience promise.

| Element | Included in Base | DLC Potential |
|---------|-----------------|---------------|
| 6 chapters, 30+ creatures | Yes | - |
| 12 spirit stories (76 fragments) | Yes | - |
| 47 herbs, full crafting system | Yes | - |
| Full ecosystem restoration | Yes | - |
| Both endings | Yes | - |
| Post-game exploration | Yes | - |
| New Game+ (re-diagnose with harder symptoms) | - | Potential $7.99 DLC |
| "The Architect's Journal" (behind-the-scenes + concept art) | - | Potential $4.99 DLC |
| Soundtrack | - | Potential $9.99 separate |

**Revenue Projections** (conservative, indie title):

| Scenario | Units (Year 1) | Revenue | Notes |
|----------|---------------|---------|-------|
| Modest | 10,000 | $174,930 (after 30% platform cut) | Niche indie |
| Good | 30,000 | $524,790 | Word of mouth + indie coverage |
| Strong | 100,000 | $1,749,300 | Viral moment + award nomination |
| Breakout | 500,000 | $8,746,500 | Major award + streamer attention |

**Marketing Strategy**:
- Target indie game showcases (Day of the Devs, Indie Direct, Next Fest)
- Pitch to streamers who play cozy/atmospheric games (animal crossing audience)
- Position as "the peaceful game" in a high-stress market
- Leverage bioluminescence visuals for social media shareability

---

## Production Plan

### Team

| Role | Count | Phase | Cost |
|------|-------|-------|------|
| Game Designer / Director | 1 | All | $90K |
| Unity Developer | 2 | All | $200K |
| 3D Artist (environment) | 1 | All | $85K |
| 2D Artist (UI, herbs, codex) | 1 | Phase 2+ | $60K |
| Technical Artist (shaders, VFX) | 1 | Phase 2+ | $80K |
| Composer | 1 (contract) | Phase 2-3 | $25K |
| Sound Designer | 1 (contract) | Phase 3 | $15K |
| VO Director + 12 Actors | Contract | Phase 3 | $30K |
| Writer | 1 (contract) | Phase 1-2 | $20K |
| QA | 1 | Phase 3+ | $40K |
| Producer | 1 | All | $80K |

### Timeline (18 months)

```
Month 1-3: PRE-PRODUCTION
├── GDD complete
├── Art style guide (bioluminescence reference, creature designs)
├── Prototype: one creature, one herb, one room, one spirit fragment
├── Playtest prototype for "feel" validation
└── Team: Designer + 1 dev + producer

Month 4-9: PRODUCTION ALPHA
├── Chapter 1-3 fully playable
├── Herbal crafting system complete
├── Ecosystem restoration tech working
├── Spirit dialogue system implemented
└── Team: Full team onboarded

Month 10-14: PRODUCTION BETA
├── All 6 chapters playable
├── All 30+ creatures, all 47 herbs
├── All 12 spirit stories written and recorded
├── Art replacing placeholders
└── Music composed and integrated

Month 15-16: POLISH
├── Performance optimization (especially Switch)
├── Accessibility pass
├── QA regression testing
└── Console certification prep

Month 17-18: LAUNCH
├── Steam Next Fest demo (Month 16)
├── Press embargoes, review copies
├── Steam launch (Month 17)
├── Console launches (Month 18)
└── Post-launch support patch
```

### Budget: $725K

| Category | Amount | % |
|----------|--------|---|
| Personnel | $500K | 69% |
| Art/audio outsourcing | $45K | 6% |
| VO (12 actors + director) | $30K | 4% |
| Tools & licenses | $20K | 3% |
| Marketing (PR, events, influencers) | $60K | 8% |
| Console certification | $15K | 2% |
| Contingency | $55K | 8% |

---

## Technical Requirements

### PC Specs

| | Minimum | Recommended |
|---|---------|-------------|
| **CPU** | i3-6100 / FX-6300 | i5-10600K / Ryzen 5 3600 |
| **GPU** | Intel HD 630 / R7 | GTX 1060 / RX 580 |
| **RAM** | 6 GB | 8 GB |
| **Storage** | 8 GB HDD | 8 GB SSD |
| **DirectX** | 11 | 12 |

### Console Specs

| Platform | Resolution | FPS | Notes |
|----------|-----------|-----|-------|
| PlayStation 5 | Native 4K | 60 | DualSense haptics for herb mixing |
| Xbox Series X | Native 4K | 60 | Standard |
| Xbox Series S | 1440p | 60 | Reduced ambient particle effects |
| Nintendo Switch | 720p handheld / 1080p docked | 30 | Optimized shader pipeline |

### Key Technical Challenges

1. **Bioluminescence shader system** — Custom Unity URP shader that responds to ecosystem state. Must perform well on Switch.
2. **World state persistence** — Ecosystem changes must persist seamlessly across area transitions and save/load.
3. **Dynamic music system** — Adaptive score that layers instruments as ecosystem restores.
4. **Switch performance** — Bioluminescent particle effects must be scaled for 30 FPS on mobile hardware.
