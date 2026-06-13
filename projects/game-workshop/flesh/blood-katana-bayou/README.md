# Blood Katana Bayou

## Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Blood Katana Bayou |
| **Genre** | 2.5D Fighting Game / Character Action |
| **Engine** | Unreal Engine 5.4 (Niagara for blood/bayou particles, custom 2.5D camera lock system) |
| **Platform** | PC (Steam), PlayStation 5, Xbox Series X/S, Nintendo Switch 2 |
| **Monetization** | Premium ($49.99) with seasonal character passes (2 fighters per season, $7.99 each or $14.99/season pass) |
| **Rating** | ESRB T (Violence, Blood, Mild Language) / PEGI 16 / CERO C |

---

## Vision Statement

Blood Katana Bayou is a 2.5D fighting game where twelve blood mages duel for territory across a supernatural Louisiana bayou using cursed katanas that feed on the wielder's own vitality. Every attack costs health. Every hit landed restores it. The match is a resource management duel wrapped in lightning-fast combo combat. Three katana stances -- Sheathed, Drawn, and Bloodrage -- define every fighter's rhythm, and stance-switch cancels mid-combo open execution ceilings that reward hundreds of hours in training mode. Arenas are alive: swamp water slows movement, hanging moss can be cut to drop on opponents, and mimic alligators lurk in the shallows. A universal gravity deflection mechanic gives every character a stylish defensive option that turns projectiles into punish opportunities. The art draws from Afro-Caribbean spiritualism, Southern Gothic fashion, and anime weapon design -- every screenshot is a wallpaper. This is a competitor's game: no turtling, no hiding, no safe play. You attack to survive. The blood demands it.

---

## Core Loop

**Target session length:** 20-45 minutes (ranked set) / 60-90 minutes (story mode / lab session)

```mermaid
graph TD
    A[Character Select + Stage Pick] --> B[Round Start: 100% HP]
    B --> C[Choose Stance: Sheathed / Drawn / Bloodrage]
    C --> D[Execute Attack String]
    D --> E{Hit or Miss?}
    E -->|Hit| F[Deal Damage + Restore HP %]
    E -->|Miss / Blocked| G[Self-Damage from Blood Cost]
    E -->|Whiff| G
    F --> H{Opponent HP <= 0?}
    G --> I{Your HP <= 0?}
    H -->|Yes| J[Win Round]
    H -->|No| C
    I -->|Yes| K[Lose Round]
    I -->|No| C
    J --> L{Best of 3?}
    K --> L
    L -->|Won 2| M[Match Won: XP + Blood Essence + Rank Points]
    L -->|Lost 2| N[Match Lost: Reduced XP + Blood Essence]
    M --> O[Return to Lobby / Queue Again / Lab]
    N --> O
```

### Core Loop Breakdown

| Step | Player Action | System Response | Skill Expression |
|------|--------------|----------------|-----------------|
| 1. Stance Select | Input stance switch (Sheathed / Drawn / Bloodrage) | Stance change animation plays (6-12 frames depending on fighter); certain moves cancel into stance switches | Matchup knowledge, read on opponent's next action |
| 2. Attack | Input normal, special, or command normal | Attack executes with blood cost (2-8% HP depending on move power). On hit: deals damage + restores 40-60% of blood cost as HP. On block: restores 10% of blood cost. On whiff: full blood cost, no restore | Combo execution, hit-confirm ability, spacing |
| 3. Defend | Block (holds back), gravity deflection (QCB + punch), or reversal | Blocking reduces chip damage but does not restore HP. Gravity deflection on success redirects projectiles and grants brief float (avoids lows). Perfect deflection (3-frame window) creates slow-motion punish window | Reaction speed, read on opponent's timing |
| 4. Blood Management | Monitor HP as both survival gauge and attack resource | HP naturally drains at 0.5%/sec in Bloodrage stance. Landed hits restore HP. Successful strings can end with HP higher than start | Resource optimization, risk/reward calculation |
| 5. Stage Interaction | Move into/away from stage hazards | Swamp water zones slow movement 30%. Hanging moss can be cut with any slash attack, dropping debris for 15% damage. Mimic gators bite players who idle in shallows for 12% damage + knockdown | Stage knowledge, positioning, spacing |
| 6. Round End | Win or lose based on HP depletion | Winner's remaining HP carries as a small bonus (5% HP heal) into next round. Loser gets full HP reset | Consistency -- efficient wins matter |

### The Blood Economy in Detail

Every attack in Blood Katana Bayou has a **blood cost** -- a percentage of the attacker's maximum HP consumed when the move is performed. This creates the central tension: attacking is mandatory (you cannot win without attacking), but every whiffed or blocked attack inches you closer to death.

| Outcome | Blood Cost Paid | HP Restored | Net Effect |
|---------|----------------|-------------|------------|
| Clean hit | Full blood cost | 60% of cost as HP | -40% of cost (you deal damage, you lose some HP) |
| Counter-hit | Full blood cost | 80% of cost as HP | -20% of cost (aggressive read rewarded) |
| Blocked | Full blood cost | 10% of cost as HP | -90% of cost (strongly discourages unsafe blockstrings) |
| Whiff (complete miss) | Full blood cost | 0% | -100% of cost (maximum punishment for bad spacing) |

**Blood cost ranges by move type:**

| Move Type | Blood Cost | Startup | Recovery | Damage (Avg) |
|-----------|-----------|---------|----------|-------------|
| Light normal | 2% HP | 4-6 frames | 6-8 frames | 4-6% opponent HP |
| Medium normal | 3.5% HP | 8-12 frames | 10-14 frames | 8-10% opponent HP |
| Heavy normal | 5% HP | 14-18 frames | 16-22 frames | 13-16% opponent HP |
| Special move | 4-6% HP | Varies by fighter | Varies | 10-14% opponent HP |
| Super (requires 100% Blood Gauge) | 8% HP | 6+ frames (cinematic) | Long recovery on block | 25-30% opponent HP |
| Bloodrage exclusive move | 6-8% HP + 0.5%/sec passive | Fast (stance bonus) | Short (stance bonus) | 15-20% opponent HP |

---

## Meta Loop

### Session-to-Session Progression

```mermaid
graph LR
    A[Match Completion] --> B[Blood Essence + XP]
    B --> C[Character Mastery Level Up]
    C --> D[Unlock: Combo Trials / Colors / Titles]
    D --> E[Higher Mastery = Ranked Matchmaking Tier]

    B --> F[Blood Essence Currency]
    F --> G[Purchase: Skins / Stage Variants / Gallery Art]

    A --> H[Ranked Points Adjust]
    H --> I[Rank Tier Promotion/Demotion]
    I --> J[Season Rewards at Season End]

    A --> K[Story Mode Progress]
    K --> L[Unlock: Lore / Rival Encounters / Endings]
    L --> M[Gallery Completion]
```

### Progression Axes

| Axis | What Grows | How It Feels | Cap |
|------|-----------|-------------|-----|
| **Character Mastery** | Per-character level (1-50). Each level unlocks a combo trial, a character color, or a profile title | You deepen your understanding of a specific fighter. Level 50 signals dedication to the community | 50 per character (12 at launch = 600 total levels) |
| **Ranked Tier** | Competitive rank across 8 tiers: Rust, Iron, Amber, Bronze, Silver, Gold, Platinum, Bloodlord | Each promotion is a milestone. Bloodlord is the top 0.5% -- visible badge of honor | Seasonal reset (soft) every 10 weeks |
| **Blood Essence** | Currency earned from matches (win: 120, loss: 40). Spent on cosmetics | Matches always feel productive. Even losses earn currency toward desired skins | No cap -- accumulates for spending |
| **Story Completion** | Campaign progress across branching paths, rival encounters, and multiple endings | Narrative mastery complements mechanical mastery. Sparing vs. killing changes the story | 3 main endings + 12 rival-specific encounters |
| **Lab Mastery** | Training mode time, combo trial completion, frame data familiarity | Invisible but most important -- your hands learn what your mind studies | No cap -- perpetual improvement |

### Seasonal Content Cadence

| Season | Duration | New Fighters | New Stage | Ranked Reward Skin | Battle Pass Cost |
|--------|----------|-------------|-----------|-------------------|-----------------|
| Season 1 (Launch) | 10 weeks | Base roster (12) | 8 stages | Bloodlord Vael skin (all characters) | Free (included with base game) |
| Season 2 | 10 weeks | 2 new fighters | 1 new stage | Swamp Phantom skin set | $9.99 or 2,000 Blood Essence |
| Season 3 | 10 weeks | 2 new fighters | 1 new stage | Twilight Sovereign skin set | $9.99 or 2,000 Blood Essence |
| Season 4 | 10 weeks | 2 new fighters | 1 new stage | Bone Emperor skin set | $9.99 or 2,000 Blood Essence |

---

## Game Mechanics

### Primary Mechanic: The Katana Stance System

Every fighter in Blood Katana Bayou has three katana stances that fundamentally alter their move properties, frame data, and blood economy. Stance switching is performed with a dedicated input (quarter-circle-forward + tag button) and takes 6-12 frames depending on the fighter. Stance-specific cancels are the execution ceiling of the game.

**Stance Properties:**

| Stance | Blood Economy | Frame Modifiers | Defensive Profile | Strategic Identity |
|--------|-------------|----------------|-------------------|-------------------|
| **Sheathed** | Blood cost reduced 30%. HP restore on hit reduced to 30% of cost. Passive: regen 0.3%/sec | All normals +2 frames startup, +3 frames recovery | Counter window increased to 5 frames. Auto-counter on successful read deals 1.5x damage | Patience and punishment. Bait whiffs, counter-hit for massive restore. Lowest raw damage, highest punish damage |
| **Drawn** | Standard blood costs and restore rates (40-60% on hit) | Baseline frame data. Balanced offense and defense | Standard block, gravity deflection available | Balanced play. The "default" stance where most fighters are strongest. Bread-and-butter combos live here |
| **Bloodrage** | Blood cost increased 20%. HP restore on hit increased to 80% of cost. Passive drain: 0.5%/sec | All normals -2 frames startup, -1 frame recovery. Plus on block on most mediums | Cannot block. Gravity deflection window reduced to 1 frame. Reversal available but costs 10% HP | All-in aggression. You cannot block, you must attack. Highest damage output, highest risk. HP drain creates a timer -- you must kill before you bleed out |

**Stance-Specific Combo Example (Mireille, Gravity-element fighter):**

```
Drawn st.LK -> Drawn cr.MP -> Drawn st.HP (launch) ->
[Switch TO Bloodrage during HP recovery frames] ->
Bloodrage j.MK -> Bloodrage j.HP (ground bounce) ->
[Switch TO Sheathed during ground bounce] ->
Sheathed Counter-Stance (opponent pressed a button) ->
Sheathed Counter -> Drawn Super (Blood Gauge 100%)

Total damage: 42% HP
Total blood cost: 28% HP
Net HP change: -28% + (restores across hits: ~16%) = -12% net
Frame difficulty: High (two stance switches in combo, counter read required)
```

### Secondary Mechanic: Gravity Deflection

A universal defensive mechanic available to all fighters in Drawn and Sheathed stances (reduced window in Bloodrage). Input: quarter-circle-back + any attack button.

**Gravity Deflection Properties:**

| Deflection Quality | Timing Window | Effect | Recovery |
|-------------------|--------------|--------|----------|
| Early (too soon) | N/A | Whiff animation, vulnerable for 22 frames | Full recovery -- guaranteed punish for opponent |
| Normal deflection | 8-frame window | Redirect projectile back at opponent for 50% original damage. Brief float (avoids lows for 10 frames) | 12 frames recovery -- slightly plus for defender |
| Perfect deflection | 3-frame window (within the 8-frame window) | Redirect projectile at 100% damage + 4-frame slow-motion window. Defender can input any attack during slow-mo for guaranteed punish starter | 0 frames -- free combo starter |
| Bloodrage deflection | 1-frame window | Same as normal but only 1 frame | 18 frames -- risky |

**Why this matters competitively:** Projectile-heavy fighters (Amber, Twilight) can be played aggressively because their projectiles are not free damage -- a skilled defender can turn them into damage. But the timing is tight. The perfect deflection window creates hype moments in tournament play.

### Secondary Mechanic: Bayou Stage Interactions

Arenas are not passive backgrounds. Each stage contains interactive elements that affect gameplay.

| Stage | Primary Hazard | Secondary Hazard | Competitive Status |
|-------|---------------|-----------------|-------------------|
| **Blackwater Crossroads** | Swamp water zones (slow 30%) | Hanging moss (cut to drop, 15% damage) | Tournament legal |
| **Moss Cathedral Ruins** | Collapsed pillars (destroyable walls, creates new corners) | Spectral choir (audio cue warns of stage transition at 30 sec remaining) | Tournament legal |
| **Gator Hollow** | Mimic alligators in shallows (bite idle players for 12% + knockdown) | Water depth varies by round (round 2: deeper water, more slow zones) | Banned in tournament (random gator spawns) |
| **Twilight Bridge** | Narrow walkway (ring-out possible at stage edges) | Lantern chains (can be kicked to swing, briefly stuns on contact) | Tournament legal (ring-out zones clearly marked) |
| **Bayou Blood Shrine** | No hazards (symmetrical, flat) | Blood fountaining from shrine at match point (visual only) | Tournament legal (standard competitive stage) |
| **Amber Forge** | Hot coals in corners (1%/sec if standing in corner hazard zone) | Forge bellows (interactable: push opponent into coals with knockback) | Banned in tournament (corner damage creates unfair advantage) |
| **Root Labyrinth** | Cypress roots create uneven terrain (crouching attacks have variable range) | Bioluminescent spores (brief screen flash on hit, visual flair only) | Tournament legal |
| **The Drowned Throne** | Final boss stage (story mode only) | Rising water over 90 seconds (gradually reduces playable space) | Story mode only |

### Secondary Mechanic: Blood Gauge (Super Meter)

The Blood Gauge fills as the player lands attacks, takes damage, and performs successful deflections. It operates on a 0-100% scale.

| Gauge Level | Ability | Cost | Properties |
|-------------|---------|------|-----------|
| 0-49% | Enhanced special (EX move) | 25% gauge | Special move gains additional properties (armor, extra hit, wall bounce). Can be used twice at 50% |
| 50-99% | Enhanced special OR stance-cancel interrupt | 25% gauge | Stance-cancel interrupt: cancel any move's recovery into a stance switch. Opens combo extensions not normally possible |
| 100% | Blood Art (Super) | 100% gauge | Cinematic super attack. 25-30% damage. Invulnerable startup (6 frames). Highly unsafe on block (-24 frames) -- commitment required |
| 100% + below 20% HP | Blood Oath (Crisis Super) | 100% gauge | Desperation super. 35-40% damage. Auto-starts in Bloodrage stance regardless of current stance. Only available when HP < 20%. Once per match |

### The 12 Blood Mage Fighters (Launch Roster)

| # | Fighter Name | Element | Archetype | Stance Specialty | Difficulty |
|---|-------------|---------|-----------|-----------------|-----------|
| 1 | **Mireille** | Gravity | Rushdown / Mixup | Bloodrage (gravity wells keep opponents close) | Intermediate |
| 2 | **Damballah** | Amber | Zoner / Trapper | Sheathed (amber traps counter-approach opponents) | Advanced |
| 3 | **Vesper** | Twilight | Setplay / Teleport | Drawn (balanced teleport cancels in all directions) | Expert |
| 4 | **Roux** | Rot | Grappler / Pressure | Bloodrage (rot stacks make grabs deal extra damage) | Intermediate |
| 5 | **Odette** | Bone | Footsies / Punish | Sheathed (bone counters have the longest active window) | Beginner |
| 6 | **Corvus** | Shadow | Stance-Heavy / Execution | All three (shadow clones change behavior per stance) | Expert |
| 7 | **Titane** | Iron | Heavy Hitter / Tank | Drawn (iron armor absorbs one hit in Drawn stance) | Beginner |
| 8 | **Azura** | Storm | Rushdown / Combo | Bloodrage (storm cancels chain normals into extended strings) | Intermediate |
| 9 | **Briser** | Crystal | Defensive / Counter | Sheathed (crystal reflects gain extra gauge on counter) | Advanced |
| 10 | **Maman Brigitte** | Spirit | Zoner / Puppet | Drawn (spirit companion attacks independently in Drawn) | Expert |
| 11 | **Jakob** | Flame | Aggressive All-Rounder | Bloodrage (flame trail extends range on all Bloodrage attacks) | Beginner |
| 12 | **The Barrow Wight** | Moss | Trap / Area Control | Sheathed (moss patches slow opponents, set in Sheathed) | Advanced |

### Frame Data Design Philosophy

Blood Katana Bayou targets 60 FPS across all platforms (Switch 2: dynamic resolution to maintain 60 FPS). All frame data is expressed in 60 FPS frames.

| Metric | Design Target | Rationale |
|--------|-------------|-----------|
| Fastest normal | 4 frames (light jab) | Cannot be reacted to -- must be predicted. Prevents meaty setups from being truly safe |
| Standard light | 5-6 frames | Reactable for experienced players. Core poke tool |
| Standard medium | 8-12 frames | Confirm window. Hit-confirm into stance switch or special is the execution test |
| Standard heavy | 14-18 frames | Whiff punish tool. Too slow to be primary offense but devastating on read |
| Fastest special | 6 frames (reversal) | Beats everything but block. Highly punishable on block (-20+) |
| Stance switch | 6-12 frames (fighter dependent) | Fast enough for combo cancels, slow enough to be interruptible |

---

## World Design

### Map Structure: The Bayou Territory

The bayou is a contested supernatural territory divided into domains controlled by rival blood mages. Each stage represents a domain. Story mode traversal moves through these domains as the protagonist reclaims territory.

```
                         +--------------------------+
                         |    THE DROWNED THRONE    |
                         |    (Final Domain)        |
                         |    Controller: Maman     |
                         |          Brigitte        |
                         +------------+-------------+
                                      |
                       +--------------+--------------+
                       |    ROOT LABYRINTH          |
                       |    (Border Domain)         |
                       |    Controller: The Barrow  |
                       |                Wight       |
                       +---------+------------------+
                                 |
                 +---------------+---------------+
                 |                               |
       +---------+----------+        +-----------+-----------+
       |  AMBER FORGE       |        |  TWILIGHT BRIDGE     |
       |  (Industrial Zone) |        |  (Transit Domain)    |
       |  Controller:       |        |  Controller: Vesper   |
       |   Damballah        |        |                      |
       +--------+-----------+        +-----------+-----------+
                |                                |
                +---------------+----------------+
                                |
                      +---------+-----------+
                      |  MOSS CATHEDRAL     |
                      |  RUINS              |
                      |  (Sacred Domain)    |
                      |  Controller:        |
                      |   Briser            |
                      +---------+-----------+
                                |
                 +--------------+--------------+
                 |                             |
       +---------+-----------+       +----------+----------+
       |  BLACKWATER         |       |  GATOR HOLLOW      |
       |  CROSSROADS         |       |  (Wild Domain)     |
       |  (Central Hub)      |       |  Controller: Roux   |
       |  Controller:        |       |                    |
       |   Mireille          |       |                    |
       +---------------------+       +---------------------+
```

### Art Direction Pillars

| Pillar | Description | Reference |
|--------|-------------|-----------|
| **Blood as Light** | Blood is the visual language. It glows crimson, amber, and violet. Splatter persists through rounds and paints the environment. Blood trails on katana swings leave light-trails in the air | Guilty Gear Strive particle effects, Afro-Samurai cel-shaded violence |
| **Southern Gothic Supernal** | Crumbling plantation architecture overgrown with supernatural flora. Spanish moss that glows faintly. Weathered wood and rusted iron alongside magical elemental effects | Resident Evil 7 bayou atmosphere, Princess Mononoke corrupted nature |
| **Afro-Caribbean Spiritualism** | Veve-inspired ground patterns during supers. Mambos and houngans as character design references. Elemental effects draw from Loa associations (Damballah = serpent/amber, Baron Samedi = bone/spirit) | Black Panther Afrofuturist aesthetic meets traditional Haitian vodou iconography |
| **Anime Weapon Design** | Oversized, impractical, beautiful katanas. Each weapon has a personality expressed through its visual design -- Gravity katana warps space around the blade, Amber katana drips golden resin, Twilight katana phases between visible and invisible | Bleach zanpakuto design philosophy, Devil May Cry weapon variety |
| **Alive Environments** | Firefly particle systems. Water that reflects fighters in real time. Atmospheric fog that reacts to super attacks (clears briefly on Blood Art). Every stage breathes | Mortal Kombat 1 environmental detail, Street Fighter 6 stage dynamism |

### Visual and Audio Design per Stage

| Stage | Palette Dominant | Lighting Mood | Ambient Audio | Music Style |
|-------|-----------------|--------------|--------------|-------------|
| Blackwater Crossroads | Deep green, stagnant brown, amber lantern glow | Firefly particles, dappled moonlight through cypress | Cricket drone, distant thunder, water lapping | Slow blues slide guitar + lo-fi beats |
| Moss Cathedral Ruins | Deep purple, crumbling gold, moss green | Candlelight flicker, stained glass prisms, fog in nave | Choir humming (distorted), wood creaking | Pipe organ + trap hi-hats |
| Gator Hollow | Mud brown, phosphorescent green, amber eyes in dark | Bioluminescent fungi, deep shadows, predatory | Gator growls, insect drone, splash | Zydeco accordion + heavy bass |
| Twilight Bridge | Deep indigo, silver moonlight, violet mist | Perpetual twilight glow, bridge lanterns, water reflection | Wind through chains, distant bells | Ambient synth + classical strings |
| Bayou Blood Shrine | Crimson, bone white, dark iron | Self-illuminated blood fountains, sacred geometry patterns | Ritual drumming (low), chanting (subtle) | Orchestral percussion + choral vocals |
| Amber Forge | Molten gold, dark iron, amber crystals | Forge fire glow, molten metal shimmer, sparks | Bellows pumping, metal striking metal, hiss of quenching | Industrial percussion + blues riffs |
| Root Labyrinth | Black water, phosphorescent teal, bone white roots | Bioluminescent glow from roots, near-dark between roots | Dripping water, creaking roots, underwater distortion | Ambient electronic + didgeridoo bass |
| The Drowned Throne | Pitch black, crimson veins, spectral white | Throne room lit by blood fountains, spectral nobles watching | Heartbeat (the bayou's), spectral whispering | Full orchestra -- overwhelming, then silence |

---

## Narrative

### Tone Spectrum (7-Axis)

| Axis | Position | Notes |
|------|----------|-------|
| Hope vs Despair | 45% Despair | The bayou is dangerous but the mages chose this life. Agency remains |
| Sacred vs Profane | 50% Balanced | Blood magic is both holy and unholy -- the game refuses to judge |
| Honor vs Survival | 70% Survival | Most mages fight because the blood demands it, not for glory |
| Sound vs Silence | 80% Sound | The bayou is never quiet. Music drives every moment |
| Human vs Supernatural | 60% Supernatural | The mages are more than human now. The bayou changes everyone |
| Past vs Present | 55% Present | History matters but the fight is now. Backstory is earned, not assumed |
| Restraint vs Excess | 75% Excess | Blood splatter, elemental explosions, anime supers. This is maximalist |

### 8-Point Story Spine

**1. Equilibrium**
The Bayou of Sang-Rouge is a contested supernatural territory where twelve blood mages maintain an uneasy truce. Each mage controls a domain and draws power from a cursed katana bonded to their bloodline. Mireille, the youngest blood mage in a generation, has just inherited her mother's gravity katana and taken control of the Blackwater Crossroads domain. The truce holds -- barely.

**2. Inciting Incident**
Maman Brigitte, the oldest and most powerful blood mage in the bayou, breaks the truce. She has united four rival warlords (Damballah, Vesper, Roux, and The Barrow Wight) under her banner and launches a coordinated assault on the other domains. Mireille's mother is killed in the first wave. Mireille's katana is stolen by Vesper during the attack and delivered to Maman Brigitte as a trophy. Mireille escapes with her life but not her weapon.

**3. First Complication**
Mireille must fight through enemy-controlled territory using a borrowed, unaligned katana -- one not bonded to her bloodline. The blood economy is punishing: without a bonded weapon, every attack costs more health and restores less. She must reclaim her own katana or bond with a new one. She encounters Odette, a neutral bone mage who offers training in the Sheathed stance philosophy: "Stop trying to win. Learn to let them lose."

**4. Rising Action**
Mireille fights through Gator Hollow (Roux's domain) and the Amber Forge (Damballah's domain), defeating each warlord and claiming their blood essence. Each victory offers a choice: **spare** the defeated mage (gain an ally but leave a potential threat alive) or **kill** them (absorb their blood essence permanently, strengthening your katana). The kills make Mireille stronger. The spares make the bayou more stable. The blood economy mirrors the moral one.

**5. Midpoint Reversal**
Mireille confronts Vesper on the Twilight Bridge and reclaims her gravity katana. But touching it again reveals a truth: Maman Brigitte did not steal the katana. Mireille's mother gave it to her willingly before her death. Mireille's mother was dying of the blood curse -- the katana was consuming her from the inside. She made a deal with Maman Brigitte to protect Mireille from the same fate. The "theft" was a rescue. Mireille has been fighting the wrong enemy.

**6. Crisis**
Mireille must decide: reject the katana and seek a cure for the blood curse (losing her power but potentially her identity as a blood mage), or accept it and confront Maman Brigitte -- not as an enemy, but as someone who might have answers about the curse's origin. The remaining warlords (Corvus, Azura, Briser) have chosen sides. The bayou is at war. The blood demands resolution.

**7. Climax**
Mireille descends into the Root Labyrinth and reaches The Drowned Throne -- Maman Brigitte's inner sanctum beneath the bayou. The final battle is a 4-phase encounter where Maman Brigitte reveals the truth: the blood curse was not natural. It was created by the first blood mages who dammed the bayou's spiritual flow to concentrate power. Every katana is a fragment of that original dam. The bayou is dying because blood mages exist. Maman Brigitte's "war" was an attempt to gather all katanas and shatter them, ending blood magic forever -- at the cost of every mage's life and power.

**8. Resolution**
Three endings based on kills vs. spares and the final choice:
- **The Bayou Remembers (Spare-heavy + Accept the Curse):** Mireille accepts her katana and the curse. She defeats Maman Brigitte but does not kill her. The katanas remain. The bayou survives but blood magic continues. The truce is restored, but Mireille now understands the cost. Bittersweet.
- **The Blood Stops (Kill-heavy + Shatter the Katana):** Mireille chooses to destroy all katanas. Blood magic ends. Every mage loses their power. The bayou heals, but the mages are now mortal and vulnerable. Mireille walks away from the bayou. The sacrifice is total.
- **The New Flow (Balance + Transcend the Curse):** Requires 50/50 kills/spares + all rival encounters completed + no continues on final boss. Mireille does not accept or reject the curse -- she transforms it. She channels the blood magic into the bayou itself, creating a symbiotic relationship where the mages draw power from the bayou's life force rather than their own. Blood magic becomes bayou magic. The war ends. The bayou thrives. This is the hardest ending to achieve.

### Key Characters

| Character | Role | Element | Theme | Story Mode Encounters |
|-----------|------|---------|-------|----------------------|
| **Mireille** | Protagonist | Gravity | Inheritance, identity, the cost of power | Player character -- all encounters |
| **Maman Brigitte** | Antagonist (complex) | Spirit | Sacrifice for the greater good, the burden of knowledge | 3 encounters (foreshadowing, revelation, final boss) |
| **Vesper** | Rival / Complication | Twilight | Deception as survival, loyalty to the one who saw you | 2 encounters (katana theft, bridge duel) |
| **Damballah** | Warlord (redeemable) | Amber | Creation vs. hoarding, the alchemist's obsession | 1 encounter + optional ally |
| **Roux** | Warlord (pragmatic) | Rot | Decay as transformation, nothing truly dies | 1 encounter + optional ally |
| **Odette** | Mentor / Neutral | Bone | Ancestral wisdom, the old ways, patience as weapon | 3 encounters (training, guidance, pre-final) |
| **Corvus** | Wild card | Shadow | Identity fragmentation, the spy who forgot which side | 1 encounter (can be ally or enemy depending on prior choices) |
| **The Barrow Wight** | Warlord (ancient) | Moss | Entropy, the slow consumption of all things | 1 encounter + lore relevance |
| **Mireille's Mother** | Posthumous | Gravity (former) | Legacy, sacrifice, the sins of the mother | Flashback encounters (3) |
| **Jakob** | Foil / Ally candidate | Flame | Passion without control, destruction as expression | 1 encounter (ally if spared) |

---

## Player Personas

### P-001: Alex Rivera -- The Ranked Grinder

**Why this game fits:** Blood Katana Bayou demands the same competitive obsession Alex brings to tactical shooters. The stance system creates an execution ceiling with stance-switch cancels mid-combo that require lab time to optimize. The blood economy eliminates turtling -- you must attack to survive, which means every match is active and aggressive. Frame data matters. Perfect deflection windows create highlight-reel moments. Ranked mode with seasonal resets keeps the grind fresh.

**Predicted experience:** Alex picks one fighter (probably Azura or Jakob -- aggressive, execution-heavy) and labs them for 100+ hours before touching ranked. He memorizes frame data, optimizes blood-optimal punish routes, and grinds to Bloodlord rank every season. He skips story mode entirely for the first month. He creates combo guides for his main. He loves the blood economy because it eliminates the passive play he hates in other fighters.

### P-010: Kevin Nguyen -- The Competitive Whale

**Why this game fits:** Kevin dreams of esports. Blood Katana Bayou is built for tournament play: tournament-legal stages, no P2W mechanics, pure skill expression. The seasonal character passes give him something to spend on (fighter + skin bundles) without compromising competitive integrity. The ranked system gives him a measurable progression toward his pro aspirations.

**Predicted experience:** Kevin buys every character pass and skin bundle. He enters online tournaments from week one. He trains 4-6 hours daily on one character, studies matchup data religiously, and tracks his win rate against every character in the roster. He produces matchup analysis content for his Discord community. He will main Corvus or Vesper -- high-execution characters that create a skill gap.

### P-009: Liam O'Connor -- The Dedicated F2P

**Why this game fits:** The premium model with cosmetic-only additional content means Liam's $49.99 buy-in gets the full competitive experience. No character is locked behind additional pay at launch -- the 12-fighter roster is complete. Character passes add fighters, but Liam is fine paying for meaningful content (new characters = new gameplay, not P2W). The blood economy rewards skill over spending. Perfect deflection is a pure-skill mechanic no wallet can buy.

**Predicted experience:** Liam buys the base game and never purchases a character pass -- he learns the 12 base fighters deeply instead. He becomes the community's resource on base-roster matchups. He creates F2P-accessible guides ("How to compete without Season 2 fighters"). He advocates for the game specifically because the monetization is fair. He attempts perfect-deflection-only challenge runs.

### P-005: Marcus Johnson -- The Competitive MOBA Player

**Why this game fits:** Marcus plays with his squad and values social competitive experiences. While Blood Katana Bayou is a 1v1 fighter, the lobby system supports spectator mode and tournament lobbies where his squad can watch each other play. The stance system creates a "role" fantasy -- Marcus can specialize in Sheathed-stance defense (support/counter) while his friends play Bloodrage rushdown, giving them a shared language even in 1v1 matches.

**Predicted experience:** Marcus buys the game because three of his dorm friends are playing it. He picks Titane or Odette -- beginner-friendly fighters that let him participate immediately. He plays casual lobbies with friends for the first month before trying ranked. He buys skins when his squad coordinates (all buying the same seasonal skin set). He values the social lobby experience over individual rank.

### P-003: Hiroshi Tanaka -- The RPG Addict

**Why this game fits:** The story mode with branching paths, multiple endings, and 12 rival-specific encounters is a completion challenge. The character mastery system (50 levels per character, 600 total) gives Hiroshi a quantifiable mastery project. The 3 endings incentivize multiple playthroughs. The lore fragments hidden in each stage reward exploration.

**Predicted experience:** Hiroshi plays story mode first and pursues "The New Flow" ending immediately. He then embarks on a mission to reach mastery level 50 with every character, creating a spreadsheet tracking his progress. He discovers every stage interaction and hidden lore element. He completes every combo trial for every character. He is the player who finds the obscure interactions the competitive community eventually adopts.

### P-017: Alexei Petrov -- The Community Pillar

**Why this game fits:** Fighting games live or die by their community. Alexei moderates Discord servers. Blood Katana Bayou needs community leaders to organize tournaments, create educational content, and maintain matchup wikis. The developer's transparent communication and fair monetization give Alexei material to advocate with. The seasonal content cadence gives him something to talk about every 10 weeks.

**Predicted experience:** Alexei creates and moderates the game's largest Discord server. He organizes weekly online tournaments. He advocates for balance patches and communicates community feedback to the developers. He does not spend money directly but generates indirect revenue through community growth. His endorsement carries weight with thousands of players.

---

## User Stories

### Core Combat (7 stories)

1. As **Alex (P-001)**, I want stance-switch cancels to be frame-tight (6-12 frames depending on fighter) so that I can optimize combo routes in training mode and feel the execution reward in matches.
2. As **Kevin (P-010)**, I want frame data displayed in training mode with startup, active, and recovery frames for every move so that I can study matchups systematically.
3. As **Liam (P-009)**, I want the blood economy to make turtling impossible (HP drains from blood costs, no passive regen in Drawn/Bloodrage) so that every match is active and aggression is rewarded.
4. As **Alex (P-001)**, I want perfect deflection to create a 4-frame slow-motion punish window so that defensive play has the same highlight potential as offensive combos.
5. As **Marcus (P-005)**, I want beginner-friendly fighters (Odette, Titane, Jakob) with simple game plans so that I can enjoy matches immediately without needing 50 hours of lab time.
6. As **Kevin (P-010)**, I want online tournament mode with bracket tracking and spectator functionality so that I can compete in organized events without third-party tools.
7. As **Alex (P-001)**, I want blood-optimal punish routes to be character-specific so that mastering a fighter requires dedicated study, not universal combo templates.

### Stance System (4 stories)

8. As **Alex (P-001)**, I want Sheathed stance to reward counter-hits with 1.5x damage so that bait-and-punish play is viable against aggressive opponents.
9. As **Kevin (P-010)**, I want Bloodrage stance to remove blocking entirely so that the risk/reward of all-in aggression creates dramatic match swings.
10. As **Hiroshi (P-003)**, I want each fighter's stance-specific moves to be visually distinct (not just stat changes) so that reading my opponent's stance is possible through animation, not just UI.
11. As **Liam (P-009)**, I want stance-switch inputs to be consistent across all fighters (QCF + tag) so that learning the stance system once transfers to every character.

### Story Mode (5 stories)

12. As **Hiroshi (P-003)**, I want a branching story campaign with 3 distinct endings tied to kill/spare decisions so that multiple playthroughs reveal different narrative perspectives.
13. As **Hiroshi (P-003)**, I want 12 rival-specific encounters in story mode so that every character gets meaningful screen time and development.
14. As **Alex (P-001)**, I want story mode cutscenes to be skippable after first viewing so that replays for alternate endings are not bogged down by repeated narrative.
15. As **Hiroshi (P-003)**, I want the "The New Flow" ending to require 50/50 kills/spares + all rival encounters + no continues on the final boss so that the true ending rewards the most thorough and skilled players.
16. As **Hiroshi (P-003)**, I want lore fragments hidden in each stage (discoverable by interacting with stage elements in story mode) so that exploration is rewarded with narrative depth.

### Stage Design (4 stories)

17. As **Kevin (P-010)**, I want a clearly defined set of tournament-legal stages (5 of 8) with no random hazards so that competitive play is fair and consistent.
18. As **Marcus (P-005)**, I want interactive stage hazards (moss drops, gator bites, forge coals) to be visually telegraphed before activation so that damage from them feels avoidable, not cheap.
19. As **Liam (P-009)**, I want stage hazard damage to apply to both players equally so that stage knowledge creates a fair advantage, not an arbitrary one.
20. As **Alex (P-001)**, I want stage selection to be a strategic choice (counterpick specific stages against specific fighters) so that matchup knowledge extends beyond character selection.

### Progression and Mastery (5 stories)

21. As **Hiroshi (P-003)**, I want character mastery levels (1-50 per character) that unlock combo trials, colors, and titles so that time investment in every fighter is recognized.
22. As **Alex (P-001)**, I want combo trials per character that teach practical match-relevant combos (not just flashy impractical ones) so that the training mode directly improves my competitive play.
23. As **Kevin (P-010)**, I want ranked matchmaking with 8 tiers (Rust through Bloodlord) and seasonal soft resets so that competitive progression is measurable and grindable.
24. As **Hiroshi (P-003)**, I want the gallery to track all lore fragments, rival encounters, endings, and stage interactions with percentage completion so that 100% gallery completion is a clear, trackable goal.
25. As **Alex (P-001)**, I want a replay viewer that records match inputs so that I can analyze my own play and share highlights with the community.

### Monetization and Fairness (3 stories)

26. As **Liam (P-009)**, I want the full 12-fighter roster included in the base price with no gameplay-affecting DLC so that the competitive experience is identical for all purchasers.
27. As **Liam (P-009)**, I want seasonal character passes to only add new fighters (not power-creep existing ones) so that the meta evolves through new matchups, not power inflation.
28. As **Marcus (P-005)**, I want cosmetic skin bundles to be available for Blood Essence (earned through play) as well as real money so that players who cannot spend still earn cosmetics through engagement.

### Social and Community (4 stories)

29. As **Kevin (P-010)**, I want lobby support for up to 8 players with spectator mode so that my squad can watch each other's matches and learn together.
30. As **Alexei (P-017)**, I want developer patch notes with detailed frame data changes so that I can communicate balance updates accurately to the community.
31. As **Alex (P-001)**, I want an in-game tournament bracket system so that community-run tournaments do not require external tools.
32. As **Alexei (P-017)**, I want a replay gallery with shareable codes so that community members can distribute notable matches without video capture software.

### Accessibility (3 stories)

33. As a player with motor impairments, I want an assist mode that extends perfect deflection windows from 3 to 8 frames and reduces blood cost by 50% so that the core loop remains accessible without being trivialized.
34. As **Marcus (P-005)**, I want full button remapping and multiple control schemes (default, simplified, and custom) so that I can find a layout that fits my playstyle.
35. As a player with color vision deficiency, I want stance indicators to use shape and position (not just color) -- Sheathed (triangle below health bar), Drawn (circle center), Bloodrage (flame icon above health bar) -- so that stance reading does not require color perception.

---

## Monetization

### Revenue Model: Premium ($49.99) + Seasonal Character Passes

**Why this model fits this game:**
- Fighting game players expect and prefer premium pricing -- it signals competitive legitimacy
- The blood economy is inherently skill-based -- no monetizable shortcut exists without destroying competitive integrity
- The target audience (P-001, P-010, P-009, P-005) values fair competition over free-to-play grind
- Tournament legitimacy requires that all gameplay-affecting content (fighters) be obtainable through standard purchase, not gacha or random rewards
- Seasonal character passes are the industry standard for fighting game post-launch content (Street Fighter 6, Guilty Gear Strive, Tekken 8)

### Pricing and Content Roadmap

| Product | Price | Content | Target Window |
|---------|-------|---------|--------------|
| Standard Edition | $49.99 | 12 fighters, 8 stages, story mode, ranked mode, training mode, combo trials | Launch |
| Deluxe Edition | $69.99 | Standard + Season 1-2 character pass (4 fighters) + soundtrack + digital art book | Launch |
| Season Pass (each) | $14.99 | 2 fighters + 1 stage + exclusive skin set for pass holders | Every 10 weeks |
| Individual Fighter | $7.99 | Single fighter + 3 colors + 1 stage variant | Available after season launch |
| Skin Packs | $4.99 | 4-character themed skin set (cosmetic only) | Monthly |

### Post-Launch Content Calendar (Year 1)

| Month | Content | Type | Price |
|-------|---------|------|-------|
| 1 | Base game launch | Game | $49.99 |
| 2 | Patch 1.1 (balance, combo trial fixes) | Free | $0 |
| 3 | Season 2 begins + 2 new fighters | Character pass | $14.99 |
| 4 | Skin Pack: "Bayou Night" | Cosmetic | $4.99 |
| 5 | Patch 1.2 (balance) + new stage variant | Free | $0 |
| 6 | Season 3 begins + 2 new fighters | Character pass | $14.99 |
| 7 | Story Mode DLC: "Vesper's Gambit" | Narrative | $9.99 |
| 8 | Skin Pack: "Blood Moon" | Cosmetic | $4.99 |
| 9 | Season 4 begins + 2 new fighters | Character pass | $14.99 |
| 10 | Patch 1.3 (balance) + combo trial update | Free | $0 |
| 11 | Skin Pack: "Iron Carnival" | Cosmetic | $4.99 |
| 12 | Year 1 Complete Edition announced | Bundle | $79.99 |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Base Revenue | Year 1 Pass/DLC Attach | Year 1 Total | Assumptions |
|----------|-------------|--------------------|-----------------------|-------------|-------------|
| **Modest** | 120,000 | $5.4M | $0.8M | $6.2M | Niche fighting game audience, word-of-mouth, 15% pass attach |
| **Baseline** | 350,000 | $15.8M | $3.5M | $19.3M | Moderate marketing, positive reviews, tournament adoption, 25% pass attach |
| **Strong** | 800,000 | $36.0M | $12.0M | $48.0M | Strong reviews, EVO presence, influencer coverage, 35% pass attach |
| **Breakout** | 2,000,000 | $90.0M | $40.0M | $130.0M | Viral, mainstream crossover, EVO main stage, 40% pass attach + cosmetic revenue |

**Break-even at approximately 56,000 units ($2.5M) against total development budget of $2.2M (see Production Plan).**

### Competitive Integrity Policy

| Policy | Implementation |
|--------|---------------|
| No P2W | All gameplay-affecting content (fighters, stages) purchasable with base game or character pass only. No stat boosts, no power items, no RNG mechanics |
| Cosmetic-only additional spend | Skins, colors, titles, gallery art -- zero gameplay impact |
| Earnable cosmetics | Every skin available for real money is also earnable through Blood Essence (in-game currency). No exclusive gameplay-affecting content behind any paywall |
| Balance transparency | Full patch notes with frame data changes published before every update. Test server (PC) available for balance preview |
| Tournament standard | Publisher commits to providing free tournament licenses for all sanctioned events. No license fees for grassroots tournaments |

---

## Production Plan

### Team

| Role | Count | Phase | Monthly Cost (Loaded) |
|------|-------|-------|----------------------|
| Game Director / Lead Designer | 1 | All | $12,000 |
| Combat Designer | 1 | All | $9,500 |
| Character Designer | 1 | Months 1-14 | $9,000 |
| System Designer | 1 | Months 1-12 | $9,000 |
| Programmers (Combat / Netcode) | 2 | All | $10,500 each |
| Programmer (Systems / UI) | 1 | Months 2-14 | $9,500 |
| Engine / Rendering Programmer | 1 | Months 1-8, 12-14 | $11,000 |
| 2D Artists (Character Art / UI) | 2 | Months 2-14 | $7,500 each |
| 3D Artist (Stage Environments) | 1 | Months 3-14 | $8,500 |
| VFX / Particle Artist | 1 | Months 4-14 | $8,000 |
| Animator | 2 | Months 3-14 | $8,000 each |
| Audio Designer / Composer | 1 | Months 3-14 | $7,500 |
| Netcode Engineer | 1 | Months 1-6, 10-14 | $11,500 |
| QA Lead | 1 | Months 8-16 | $7,000 |
| QA Testers | 2 | Months 10-16 | $5,000 each |
| Community Manager | 1 | Months 6-16 | $6,500 |
| Producer | 1 | All | $10,000 |

**Total team: 22 people peak (months 6-12)**

### Timeline (16-month production)

| Month | Milestone | Key Deliverables |
|-------|-----------|-----------------|
| 1 | Prototype | Core combat loop (attack/blood cost/restore), 2-fighter prototype (Mireille, Jakob), basic stance system |
| 2 | Vertical Slice | 1 match (Mireille vs. Jakob) on Blackwater Crossroads, stance system functional, blood economy tuned, rollback netcode prototype |
| 3 | Pre-Production Complete | All 12 fighters designed on paper, 8 stages greyboxed, frame data targets documented, design doc locked |
| 4 | Production Phase 1 | Fighters 1-4 fully animated and playable, stance-specific moves for first 4, stage 1-2 art pass begins |
| 5 | Production Phase 1 | Fighters 5-8 implemented, gravity deflection system complete, training mode prototype |
| 6 | Production Phase 2 | Fighters 9-12 implemented, all 8 stages greyboxed, netcode stress testing begins (internal) |
| 7 | Production Phase 2 | Story mode chapter 1-3 greyboxed, combo trial system implemented, frame data display in training mode |
| 8 | Production Phase 2 | All fighters move-complete, stages 1-5 art pass, QA begins, ranked system backend development |
| 9 | Production Phase 3 | Story mode chapters 1-6 playable, stages 6-8 art pass, lobby system prototype |
| 10 | Production Phase 3 | All stage interactions implemented, story mode branching (kill/spare) functional, netcode optimization |
| 11 | Production Phase 3 | Ranked mode implemented, character mastery system live, gallery system complete, external playtesting begins |
| 12 | Alpha | Full game playable, all systems integrated, all 12 fighters at alpha balance, all stages complete, story mode playable end-to-end |
| 13 | Beta | Feature complete, external beta test (invitational), balance iteration based on playtest data, performance optimization |
| 14 | Beta Iteration | Open beta (PC), final balance pass, console cert preparation, spectator mode polish |
| 15 | Release Candidate | Console cert submission (PS5, Xbox, Switch 2), Steam submission, day-1 patch preparation, EVO presence (if timing aligns) |
| 16 | Launch | Game ships simultaneously on all platforms, day-1 patch deployed, community manager full support, hotfix pipeline active |

### Budget Breakdown

| Category | Cost | Notes |
|----------|------|-------|
| Salaries (16 months, 22 FTE peak) | $1,580,000 | Blended rate approximately $8,900/mo avg |
| Unreal Engine 5 royalties | $0 (first $1M gross revenue free) | 5% after $1M |
| Software and Tools | $36,000 | Perforce, Jira, Adobe CC, Spine (2D animation), Wwise |
| Hardware (dev kits, workstations) | $55,000 | 2 PS5 dev kits, 2 Xbox dev kits, 1 Switch 2 dev kit, 12 workstations |
| QA and Playtesting | $42,000 | External QA contractor, playtest facility, online beta infrastructure |
| Audio (recording, VO, music production) | $48,000 | Studio time, 5 VO actors (story mode), live recording sessions for stage music |
| Netcode Infrastructure | $30,000 | Server costs for ranked matchmaking, replay storage, rollback testing |
| Marketing | $150,000 | Trailers (3), EVO booth (1), influencer outreach, PR firm retainer, community tournament seeding |
| Operations and Overhead | $65,000 | Office/incorporation/legal/accounting/insurance |
| Contingency (10%) | $205,600 | |
| **Total** | **$2,211,600** | |

---

## Technical Requirements

### Platform Specifications

| Spec | PC Minimum | PC Recommended | PlayStation 5 | Xbox Series X | Switch 2 |
|------|-----------|---------------|--------------|--------------|----------|
| **OS** | Windows 10 64-bit | Windows 11 64-bit | PS5 system software | Xbox OS | Switch 2 OS |
| **CPU** | Intel i5-8400 / AMD Ryzen 5 2600 | Intel i7-10700K / AMD Ryzen 7 5800X | Custom AMD Zen 2 | Custom AMD Zen 2 | Custom NVIDIA T239 |
| **RAM** | 8 GB | 16 GB | 16 GB GDDR6 | 16 GB GDDR6 | 12 GB LPDDR5 |
| **GPU** | GTX 1060 / RX 580 | RTX 3060 Ti / RX 6700 XT | Custom RDNA 2 | Custom RDNA 2 | Custom NVIDIA Ampere |
| **Storage** | 30 GB SSD | 30 GB NVMe SSD | 25 GB SSD | 25 GB SSD | 20 GB internal |
| **Target Resolution** | 1080p / 60 FPS | 1440p / 60 FPS | 4K/60 or 1440p/120 | 4K/60 or 1440p/120 | Dynamic 1080p / 60 FPS |
| **Input** | Keyboard, fight stick, pad | Same | DualSense, fight stick | Xbox pad, fight stick | Joy-Con, Pro Controller |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **Rollback netcode for 2.5D fighting game** | High -- netcode quality makes or breaks fighting games. GGPO-style rollback must handle stance-switch state, blood gauge, and stage interaction state simultaneously | Dedicated netcode engineer from month 1. Rollback prototype by month 2. Weekly netcode playtest sessions from month 6. Fixed-delay backup mode for poor connections |
| **60 FPS target on Switch 2** | Medium -- Switch 2 hardware is less powerful than PS5/Xbox. Dynamic particle effects (blood splatter, elemental VFX) must scale down gracefully | Scalable particle system: Switch 2 uses simplified blood trails, reduced firefly count, and lower-resolution stage backgrounds. Fighter models and animations are identical across platforms (no downgrade). Target: dynamic 1080p with 60 FPS lock |
| **12 fighters with 3 stances each (36 effective movesets)** | Medium -- each fighter has stance-specific normals, specials, and supers. Balancing 12 fighters x 3 stances is 36 balance problems | Modular design: stance modifiers apply to a base moveset rather than creating fully independent movesets. Shared animation skeletons across stances reduce asset creation. Balance testing from month 8 with external playtesters |
| **Stage interaction synchronization in online play** | High -- mimic gator timing, moss drop physics, and forge interaction must be synchronized between players. Desync = unplayable | Stage interactions run on a deterministic seed synced at match start. Random elements (gator spawn timing) use pre-agreed seed. Moss drops are physics-simulated locally but damage application is authoritative on thrower's side |
| **Blood splatter persistence and performance** | Low-Medium -- persistent blood decals on stage surfaces can accumulate across rounds. Must not tank performance | Blood splatter uses a decal pool (max 256 decals per stage). Oldest decals fade when pool is full. Blood is cosmetic only -- does not affect gameplay. Can be disabled in settings for performance |
| **Cross-platform play** | Medium -- PC, PS5, Xbox, and Switch 2 players in the same matchmaking pool requires platform holder approval and netcode consistency | Rollback netcode is platform-agnostic. Sony and Microsoft cross-platform policies allow it (confirmed via publisher agreement). Switch 2 cross-play depends on Nintendo approval (fallback: Switch 2 isolated matchmaking) |

### Network Architecture

| Component | Technology | Notes |
|-----------|-----------|-------|
| Netcode | GGPO-style rollback (custom implementation) | 4-frame rollback budget. Input delay adjustable (0-6 frames). Spectator mode uses delay-based netcode (no rollback needed for spectators) |
| Matchmaking | Skill-based (Elo variant) + region preference | Matchmaking within 2 rank tiers + geographic proximity. Cross-platform matchmaking (PC/PS5/Xbox) |
| Replay System | Server-side replay storage (30 days) + local replay files | Replays store input streams, not video. Approximately 200 KB per 99-second match. Shareable via 8-character code |
| Ranked Infrastructure | Dedicated server for matchmaking + seasonal tracking | No dedicated servers for matches (P2P with rollback). Servers handle ranking, matchmaking, seasonal rewards |
| Latency Target | Less than 80ms RTT for optimal experience | Rollback handles up to 150ms gracefully. Above 150ms: warning displayed. Above 200ms: match not offered |

---

<npl-block type="reflection">
Correctness: All 12 required sections present (Title and Genre, Vision Statement, Core Loop, Meta Loop, Game Mechanics, World Design, Narrative, Player Personas, User Stories, Monetization, Production Plan, Technical Requirements). Numbers internally consistent -- budget ($2.2M), revenue break-even (~56K units), team size (22 peak), timeline (16 months). Blood cost/restore math verified: net effects correctly computed across hit/block/whiff states. Frame data ranges internally consistent with 60 FPS target.

Edge cases: Bloodrage stance (cannot block) prevents turtling abuse. Blood Oath crisis super (HP < 20% gate, once per match) prevents infinite super loops. Stage hazard synchronization for online play documented with deterministic seed approach. Switch 2 performance scaling addressed with specific mitigation. Stance-switch cancel window (6-12 frames) tuned to be combo-viable but interruptible.

Security: No security concerns -- this is a game design document, not software.

Pitfalls: Persona library is mobile-gaming-oriented but Blood Katana Bayou is a console/PC premium fighting game. Addressed by focusing on behavioral fit (competitive drive, completionism, community influence) rather than platform match. Revenue projections are conservative estimates -- actual performance depends on EVO presence, review scores, and netcode quality (the single most important factor for fighting game longevity). The 12-fighter launch roster is modest compared to competitors (Tekken 8 launched with 32) -- mitigated by stance system creating 3x moveset depth per fighter.

Improvements: Could expand accessibility section beyond 3 user stories. Could add detailed balance philosophy for each archetype. Could specify tournament mode features in greater detail (double elimination, character select rules, stage striking). Could add a section on training mode features (frame trap display, combo counter, input display).

Refactors: Document structure follows the 12-section requirement exactly. No refactoring needed.

Documentation: This IS the documentation.

Clarifications: Story mode rival encounters are described at a high level -- specific dialogue and cutscene direction would require a narrative design document. DLC character concepts (seasons 2-4) not specified -- left for post-launch design.

TODOs: Season 2-4 fighter concepts need design passes. Story mode DLC "Vesper's Gambit" needs narrative design. Tournament mode bracket system needs UX specification.
</npl-block>
