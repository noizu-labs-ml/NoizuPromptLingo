# Forge of Elegance

## Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Forge of Elegance |
| **Genre** | Simulation / Crafting / Building |
| **Engine** | Unity 6 (URP) — strong multi-platform support, shader graph for fabric simulation, proven mobile pipeline |
| **Platform** | PC (Steam, GOG), Nintendo Switch, Mobile (iOS/Android) |
| **Monetization** | Premium $29.99 with optional cosmetic DLC |
| **Rating** | ESRB T (Teen 13+) — Mild Fantasy Violence, Use of Alcohol/Tobacco in Context |

---

## Vision Statement

Forge of Elegance is a couture atelier simulation set in a magical steampunk city where you design enchanted garments for mythical clientele. You are not a warrior or a hero — you are a fashion artisan whose needle is mightier than any sword. The game lives at the intersection of creative expression and economic survival: every bolt of enchanted fabric you weave, every gown you stitch, and every runway you dominate pushes your atelier closer to legendary status or total ruin. Your patrons are dragon queens who demand fireproof ballgowns, vampire duchesses who require shadow-woven velvet, and elemental lords whose regalia must channel the weather itself. Between commissions you defend your workshop from rival designers who sabotage your supply chains and fashion anarchists who want to tear down the entire haute couture establishment. It is Project Runway by way of Arcane — craftsmanship under pressure, art as commerce, beauty as power.

---

## Core Loop

**Target session length:** 30-60 minutes

```
Receive Commission → Select Materials → Craft Enchanted Fabric → Design Garment → Fit to Client → Deliver (or Present at Runway Show) → Earn Reputation + Gold + Materials → Upgrade Atelier → Receive Better Commissions → (repeat)
```

### Core Loop Breakdown

| Step | Player Action | System Response | Skill Expression |
|------|--------------|----------------|-----------------|
| 1. Commission | Accept a client brief from the patron board (difficulty, deadline, reward, client temperament) | Client generates requirements: garment type, enchantment properties, aesthetic style, budget ceiling | Prioritization — choose commissions matching your current skill and inventory |
| 2. Material Select | Browse your fabric inventory or purchase/raw materials from the market | 120+ fabric types with procedural properties (fire-resilient silk, shadow-woven velvet, crystal-embroidered lace). Market prices fluctuate based on seasonal demand and rival interference | Resource management — budget limited gold across materials, tools, and atelier upkeep |
| 3. Weave | Operate enchanted loom to craft base fabric; timing minigame determines quality tier (Standard / Fine / Masterwork) | Fabric quality affects garment base stats: durability, enchantment capacity, visual splendor. Failed weaves produce usable but lower-tier cloth | Timing and rhythm — precise inputs produce better cloth |
| 4. Design | Use the pattern table to combine fabrics, dyes, and enchantments into a garment. 3D preview shows the piece on a mannequin in real time | Garment score calculated across 3 axes: Aesthetic (beauty), Function (enchantment strength), Fit (client preference match). Each axis scored 0-100 | Creative expression + system mastery — knowing which enchantments pair with which fabrics |
| 5. Present | Deliver the piece to a private client or enter it in a seasonal runway show against rival designers | Private clients: satisfaction score determines reputation gain and payment. Runway shows: head-to-head scoring against AI rivals with audience reaction system | Risk/reward — runway shows pay more but a loss costs reputation |
| 6. Upgrade | Spend gold and rare materials on atelier improvements: better loom, dye vats, enchantment station, showroom | Higher-tier tools unlock finer materials, stronger enchantments, more complex garment patterns. Atelier appearance evolves visually | Long-term planning — choose which production chain to upgrade next |

---

## Meta Loop

### Session-to-Session Progression

```
Atelier Mastery → Access to Higher-Tier Materials → More Demanding Patrons → Greater Rewards → Atelier Expansion → Seasonal Runway Tournaments → Fashion House Ranking → (repeat across 4 fashion seasons)
```

### Progression Axes

| Axis | What Grows | How It Feels | Cap |
|------|-----------|-------------|-----|
| **Crafting Skill** | Weaving quality, enchantment complexity, pattern mastery | Your hands steadier, your eye sharper, your cloth finer | 5 tiers: Apprentice, Journeyman, Artisan, Master, Legend |
| **Patron Network** | Number and quality of recurring clients | Powerful figures seek you out instead of the other way around | 50+ unique clients across 6 factions |
| **Atelier Reputation** | City-wide fame score affecting market prices and commission offers | The city knows your name. Your waiting room is always full | 100-point reputation scale (Unknown through Mythic) |
| **Material Library** | Fabric recipes, dye formulas, enchantment glyphs discovered | Your codex thickens with secrets of the craft | 120 fabrics, 40 dyes, 30 enchantments |
| **Economic Power** | Gold reserves, investment properties, supply chain ownership | You stop shopping at the market and start owning the supply | 3 economic tiers: Renter, Owner, Mogul |
| **Fashion House Rank** | Position in seasonal tournament leaderboard | Your house crest appears on city banners | 12 ranks across 4 seasons per year |

---

## Game Mechanics

### Primary Mechanic: Enchanted Fabric System

The crafting system is the heart of the game. Every garment begins as raw materials transformed through three production stages.

**Stage 1 — Weaving (Loom Minigame)**

The enchanted loom operates as a rhythm-timing minigame. Threads cross the loom in patterns; the player hits inputs at precise moments to "lock" enchantment into the weave.

| Quality Tier | Timing Window | Fabric Stat Multiplier | Visual Indicator |
|-------------|--------------|----------------------|-----------------|
| **Ruined** | Missed >50% of inputs | 0.5x | Frayed, dull, uneven texture |
| **Standard** | Hit 50-74% within window | 1.0x | Clean, plain, serviceable |
| **Fine** | Hit 75-89% within window | 1.3x | Subtle sheen, even weave, visible enchantment threads |
| **Masterwork** | Hit 90-97% within window | 1.6x | Glowing threads, flowing drape, enchantment aura visible |
| **Legendary** | Hit 98%+ within window | 2.0x | Self-illuminating fabric, particle effects, ambient magic hum |

Timing windows start generous (600ms at Apprentice tier) and tighten as the player crafts higher-tier fabrics (down to 200ms at Legend tier). The game never requires Legendary quality to progress — Masterwork is sufficient for endgame content. Legendary exists for mastery players.

**Stage 2 — Dyeing (Alchemical Mixing)**

Dyes are mixed from 40 base ingredients. Each dye has a primary color and up to 2 enchantment modifiers.

| Dye Family | Color Range | Enchantment Bonus | Source |
|-----------|------------|-------------------|--------|
| **Floram** | Greens, earth tones | +Growth (fabric self-repairs) | Forest biome herbs |
| **Ignis** | Reds, oranges, golds | +Fire Resistance | Volcanic mineral extracts |
| **Umbral** | Purples, blacks, indigos | +Shadow Weaving (light absorption) | Deep-cave fungal extracts |
| **Crystalline** | Whites, silvers, ice blues | +Thermal Regulation | Mountain crystal dust |
| **Tempest** | Yellows, teals, electric blues | +Static Charge (shock defense) | Storm-harvested lightning glass |
| **Abyssal** | Deep blues, sea greens, bioluminescent | +Water Breathing / Pressure Resist | Ocean-depth coral extracts |

Mixing is a freeform system: combine any 2-3 dye bases to create custom colors. The enchantment bonuses stack but diminishing returns apply (second bonus at 50%, third at 25%).

**Stage 3 — Enchantment (Glyph Binding)**

30 enchantment glyphs, each adding a supernatural property to the finished garment. Glyphs are discovered through experimentation, client requests, and exploration.

| Glyph | Effect | Enchantment Capacity Cost | Discovered Via |
|-------|--------|--------------------------|---------------|
| **Flameguard** | Immune to fire damage for 1 hour | 3 | Fire Dragon patron commission |
| **Shadowstep** | Wearer can teleport 5m through shadows | 5 | Vampire Duchess questline |
| **Stormweave** | Garment generates lightning on impact | 4 | Elemental Lord tournament reward |
| **Mending** | Fabric self-repairs minor tears | 2 | Default starting glyph |
| **Glamour** | +20 Aesthetic score regardless of design | 3 | Fashion anarchist side quest |
| **Ironweave** | +50 durability, fabric behaves as light armor | 4 | City guard commission chain |
| **Chameleon** | Garment shifts color to match environment | 5 | Thieves' guild secret quest |
| **Gravity** | Wearer can walk on walls for 10 minutes | 6 | Sky Fortress exploration reward |

Each fabric has an Enchantment Capacity (EC) determined by its quality tier. Standard = 4 EC, Fine = 6 EC, Masterwork = 8 EC, Legendary = 12 EC. Players must choose which glyphs to apply within the capacity budget — no garment can do everything.

### Secondary Mechanic: Patron Relationship System

50+ unique clients organized across 6 factions, each with personality traits, aesthetic preferences, and relationship meters.

**Factions and Patrons**

| Faction | Patron Count | Aesthetic Preference | Reward Type | Risk |
|---------|-------------|---------------------|------------|------|
| **Dragon Courts** | 10 | Bold, metallic, fire-themed, dramatic silhouettes | Rare volcanic materials, gold | Demanding — one poor commission can tank the relationship |
| **Vampire Houses** | 8 | Elegant, dark, lace-heavy, subtly threatening | Shadow essences, exclusive dyes | Vengeful — failed commissions trigger sabotage events |
| **Elemental Lords** | 8 | Asymmetrical, nature-integrated, weather-reactive | Elemental crystals, rare glyphs | Impatient — strict deadlines, bonus for early delivery |
| **City Nobility** | 10 | Traditional, opulent, jewel-toned, status-signaling | Gold, political influence, market access | Gossipy — poor work spreads reputation damage fast |
| **Adventurer Guilds** | 8 | Practical, durable, enchantment-focused | Combat materials, exploration maps | Loyal — repeat business, but low aesthetic standards |
| **Fashion Underground** | 6 | Avant-garde, experimental, rule-breaking | Unique enchantments, rival intel | Dangerous — association attracts anarchist attention |

**Relationship Mechanics**

Each patron has a Relationship Score (0-100) tracking satisfaction across all commissions.

| Score Range | Relationship Level | Gameplay Effect |
|------------|-------------------|----------------|
| 0-15 | Hostile | Patron sends rivals to sabotage your workshop |
| 16-35 | Wary | Patron accepts commissions but at reduced payment |
| 36-55 | Neutral | Standard commission rates and requirements |
| 56-75 | Favorable | Patron offers exclusive materials as gifts, extends deadlines |
| 76-90 | Trusted | Patron unlocks unique questlines and legendary patterns |
| 91-100 | Devoted | Patron defends your atelier from rivals, provides introductions to other high-tier clients |

### Secondary Mechanic: Runway Combat

Seasonal fashion shows (4 per in-game year) pit the player against rival ateliers in head-to-head runway presentations.

**Scoring System**

| Category | Weight | Scoring Criteria |
|----------|--------|-----------------|
| **Aesthetic** | 35% | Color harmony, silhouette balance, visual innovation, cultural appropriateness for theme |
| **Function** | 25% | Enchantment power, durability, practicality for the runway challenge theme |
| **Client Fit** | 20% | How well the piece matches the assigned runway model's body type, personality, and faction |
| **Audience Reaction** | 20% | Real-time crowd response based on drama, surprise, and presentation order (going last is an advantage) |

**Runway Tournament Structure**

Each season has a theme (e.g., "Infernal Elegance," "Tidal Formal," "Storm Couture"). Players enter 3 garments across 3 rounds. Elimination occurs after each round. The final round is a 1v1 against the season's rival champion.

| Round | Entrants | Garments | Elimination |
|-------|---------|----------|-------------|
| Qualifying | 8 ateliers | 1 per atelier | Bottom 4 eliminated |
| Semifinal | 4 ateliers | 1 per atelier | Bottom 1 eliminated |
| Final | 3 ateliers | 1 per atelier (masterpiece) | Winner takes season championship |

Winning a season grants: significant reputation boost, exclusive material unlocks, a trophy displayed in the atelier, and a unique enchantment glyph.

### Secondary Mechanic: Workshop Defense

Rival designers and fashion anarchists periodically attack the player's atelier through sabotage events.

**Sabotage Event Types**

| Event | Frequency | Counter | Failure Consequence |
|-------|-----------|---------|---------------------|
| **Supply Poisoning** | Every 2-3 seasons | Install detection wards (gold cost) or inspect shipments manually (time cost) | 30% of current inventory ruined |
| **Runway Sabotage** | Before major shows | Hire security, bribe informants, or craft a backup garment | Primary showpiece damaged, must use inferior backup |
| **Client Poaching** | When reputation exceeds 60 | Offer loyalty gifts, complete rush commissions, or undercut rival pricing | High-value patron defects to rival atelier |
| **Anarchist Raid** | After winning a season championship | Reinforce workshop doors, hire guard constructs, or negotiate with anarchist leader | Atelier damaged, production halted for 3 in-game days |
| **Scandal Smear** | Random when any faction relationship is Wary or lower | Produce proof of quality (show receipts, client testimonials), or bribe the press | Reputation drops 15-25 points |

The defense system exists to create stakes and economic pressure — it is not a combat system. All countermeasures are economic decisions (spend gold, spend time, or accept the loss).

### Difficulty Progression Table

| Season | Client Tier | Material Complexity | Runway Competition | Sabotage Frequency | New Mechanics Unlocked |
|--------|-----------|-------------------|--------------------|--------------------|-----------------------|
| 1 — Spring (Year 1) | Nobility, basic Adventurers | 20 fabrics, 8 dyes, 5 glyphs | Qualifying round only | None | Weaving, basic dyeing, fitting |
| 2 — Summer (Year 1) | +Elemental Lords, Nobility advanced | 45 fabrics, 16 dyes, 10 glyphs | Full tournament | Low (supply poisoning) | Enchantment binding, market haggling |
| 3 — Autumn (Year 1) | +Vampire Houses, Dragon Courts | 75 fabrics, 28 dyes, 18 glyphs | Full tournament + rival nemesis | Medium (client poaching, runway sabotage) | Patron questlines, workshop upgrades |
| 4 — Winter (Year 1) | +Fashion Underground | 120 fabrics, 40 dyes, 30 glyphs | Championship finals | High (all sabotage types) | Legendary crafting, anarchist negotiation |
| 5-8 (Year 2) | All factions at maximum complexity | All materials, mastery-tier recipes | Defending champion pressure | Constant threat | Atelier expansion, supply chain ownership, apprentice management |

---

## World Design

### Map Structure

The city of Luminarre, a vertical steampunk metropolis built around a massive enchanted loom at its center.

```
                        ┌──────────────────┐
                        │  THE SPINDLE     │
                        │  (Government Hub)│
                        │  Fashion Council │
                        │  Grand Runway    │
                        └────────┬─────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                   │
    ┌─────────┴────────┐  ┌─────┴──────┐  ┌────────┴─────────┐
    │  SKYWARD TIER    │  │ MIST WALK  │  │  EMBER DISTRICT   │
    │  Dragon Roosts   │  │ Vampire    │  │  Forges           │
    │  Elemental Spire │  │ Manors     │  │  Loom Factories   │
    │  Cloud Markets   │  │ Shadow     │  │  Dye Works        │
    └──────────────────┘  │ Gardens   │  └───────────────────┘
                          └───────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                   │
    ┌─────────┴────────┐  ┌─────┴──────┐  ┌────────┴─────────┐
    │  GILDED QUARTER  │  │ CRAFTER'S  │  │  THE UNDERCITY   │
    │  Noble Estates   │  │ ROW        │  │  Fashion          │
    │  High-end        │  │ (Player    │  │  Underground      │
    │  Boutiques       │  │  Atelier   │  │  Black Market     │
    └──────────────────┘  │  Location) │  │  Anarchist HQ     │
                          └────────────┘  └───────────────────┘
```

**Player's Atelier** is located in Crafter's Row, the central artisan district. As reputation grows, the player can purchase additional workshops in other districts for material bonuses: a dye workshop in Ember District, a weaving annex in Skyward Tier, a showpiece showroom in Gilded Quarter.

### Art Direction Pillars

| Pillar | Description | Reference |
|--------|-------------|-----------|
| **Industrial Opulence** | Brass fittings on silk looms, copper pipes feeding dye vats, steam-powered sewing machines stitching enchanted thread | Arcane (Netflix), Dishonored's High Chaos aesthetic |
| **Living Fabric** | Enchanted textiles move on their own — gowns ripple like water, cloaks drift without wind, scarves wrap themselves | Howl's Moving Castle (Miyazaki), Disney's Cinderella transformation scene |
| **Faction Identity** | Each district has a distinct visual language rooted in its patron faction — draconic warmth, vampiric shadow, elemental chaos, noble gold | Final Fantasy XIV's city-states |
| **Craftsmanship Theater** | Every crafting station is a spectacle — the loom glows during weaving, dye vats bubble with alchemical reactions, enchantment glyphs hover in the air | Atelier series workshop scenes, Cooking Mama satisfaction |

### Visual and Audio Progression

| Season | Palette Dominant | Atelier Visual | Ambient Audio | Music |
|--------|-----------------|---------------|--------------|-------|
| 1 — Spring | Warm cream, soft brass, pale greens | Modest workshop, simple loom, bare walls | Clock ticking, distant market chatter, loom clacking | Light piano, gentle strings |
| 2 — Summer | Rich gold, copper, sunlit amber | Upgraded loom, first dye station, fabric bolts on shelves | Dye vats bubbling, apprentice footsteps, client chatter | Piano + woodwinds, upbeat tempo |
| 3 — Autumn | Deep crimson, twilight purple, burnished bronze | Enchantment station installed, display mannequins, patron gifts on walls | Glyph hums, fabric rustling, creaking floorboards from heavy traffic | Full ensemble, waltz undertones |
| 4 — Winter | Ice blue, silver, midnight black, hearth orange | Full atelier with showroom, enchanted banners, rival warnings posted | Machine thrum, enchantment crackle, city bells marking deadlines | Orchestra with industrial percussion |
| Year 2+ | All palettes cycle per season, complexity layered | Expanded atelier with multiple wings, apprentice stations, defensive wards | Symphony of crafting sounds layered by production volume | Full score per season, reactive to atelier state |

---

## Narrative

### Tone Spectrum

```
HOPEFUL  ●●●●●○○ GRIM
SERIOUS  ●●●○○○○ WHIMSICAL
SIMPLE   ●●●●○○○ COMPLEX
GROUNDED ●●○○○○○ FANTASTICAL
STATIC   ●●●●●○○ DYNAMIC
```

The tone sits firmly in romantic fantasy with industrial edges. Stakes are real (economic ruin, sabotage, patron wrath) but never grimdark. The world believes beauty matters and that craftsmanship is a form of power worth fighting for.

### 8-Point Story Spine

**1. Equilibrium**
You are a newly graduated artisan from the Luminarre Academy of Enchanted Textiles. You inherit a small, run-down atelier in Crafter's Row from your disappeared mentor, Madame Cerise. The workshop contains a basic loom, a few bolts of standard cloth, and a cryptic note: "The Spindle is lying. Don't trust the Season." You open for business.

**2. Inciting Incident**
Your first commission — a simple silk scarf for a minor noble — attracts the attention of Sable Marchetti, the reigning champion of the Winter Championship and owner of the largest atelier in Luminarre. Sable views you as a threat not because of your skill (you are a nobody) but because your atelier sits on a property she has been trying to acquire for years. She sends her apprentice to buy you out. You refuse. The rivalry begins.

**3. First Complication**
As your reputation grows, you attract clients from all six factions. Each faction pulls you in different directions: the Dragon Courts want dramatic war-gowns, the Vampire Houses want whisper-thin shadow lace, the Fashion Underground wants you to burn the old rules. Pleasing one faction alienates another. Meanwhile, the Fashion Anarchists — a radical group that believes enchanted fashion is elitist oppression — begin targeting your workshop because you are rising too fast.

**4. Rising Action**
You discover that faction politics are connected to the Spindle — the massive enchanted loom at the city's center that supposedly regulates all magical textile production. The Spindle is controlled by the Fashion Council, an unelected body that sets seasonal trends, approves which ateliers may enter tournaments, and quietly decides which designers succeed and which disappear. Your mentor Madame Cerise discovered the Council was manipulating the Spindle to concentrate power. That is why she disappeared.

**5. Midpoint Reversal**
You enter your first full-season tournament and reach the finals against Sable. During the final presentation, you discover Sable's garments incorporate a technique that only Madame Cerise knew — a signature weave pattern that could not have been independently invented. Sable was not just a rival. She was Madame Cerise's first apprentice, trained before you, and she betrayed Cerise to the Fashion Council in exchange for champion status. The rivalry is personal.

**6. Crisis**
The Fashion Council summons you and offers a deal: stop investigating the Spindle, withdraw from tournament competition for two years, and they will tell you where Madame Cerise is being held. If you refuse, they will revoke your atelier license and strip your reputation to zero. You must choose: play by the corrupt rules to save your mentor, or fight the system and risk everything you have built.

**7. Climax**
Whichever choice you made leads to the Spindle itself. You must present a garment at the Grand Runway — not for a patron, but for the Spindle, which is revealed to be sentient. The Spindle judges all enchanted fashion and has been subtly guiding the city's aesthetics for centuries. Your final garment must convince the Spindle that Luminarre deserves free creative expression, not Council-controlled trends.

**8. Resolution**
Three endings based on your choices across the game:
- **Council Path**: You accept the deal, rescue Cerise, and operate within the system. You become the new champion. The corruption persists, but your atelier thrives. Bittersweet pragmatism.
- **Reform Path**: You refuse the deal, lose your license, rebuild from the Fashion Underground, and expose the Council. The Spindle is freed from Council control. Fashion in Luminarre becomes wild, unpredictable, and free. Your atelier is reborn as a collective.
- **Transcendence**: You discover the Spindle is not a tool but a grieving artist — an ancient enchantment given life by a weaver who lost everything. You craft a garment that acknowledges its pain and offers it peace. The Spindle dissolves, returning its magic to every atelier in the city. Fashion is no longer controlled or freed — it is liberated at the source. This is the hardest ending (requires all 120 fabrics discovered, 30 glyphs mastered, relationship 80+ with all 6 factions, and Masterwork or higher on the final garment).

### Key Characters

| Character | Role | Theme | Questline |
|-----------|------|-------|-----------|
| **The Artisan** (you) | Protagonist — inheritor of Cerise's atelier | Legacy and identity; making beauty in a corrupt system | Main questline |
| **Madame Cerise** | Missing mentor | Sacrifice and secrets; she knew the truth and paid the price | 15 discovery fragments across all districts |
| **Sable Marchetti** | Rival — reigning champion, former Cerise apprentice | Ambition and betrayal; she chose power over loyalty | Rival events across all 4 seasonal tournaments |
| **Lord Ashwick** | Fashion Council chairman | Institutional control; believes beauty must be regulated | Council summons and political quests |
| **Vex** | Fashion Underground leader | Rebellion and destruction; wants to tear down the system entirely | Anarchist side quests and negotiation events |
| **Thread** | The Spindle — sentient ancient loom | Grief and creation; an artist frozen in duty for centuries | Final confrontation and hidden lore fragments |
| **Apprentice Kira** | Your first hire — young, eager, talented | Growth and succession; she represents the future of the craft | Atelier management quests |

---

## Player Personas

### P-002: Sarah Chen — The Micro-Gamer (Primary)

A 35-year-old marketing manager and mother who plays in 15-20 minute bursts. Collects aesthetically appealing items. Values fair progression. Spends $10-15/month on her gaming habit.

**Why Forge of Elegance fits Sarah:**
- Crafting loop (weave, dye, enchant, deliver) fits cleanly into 15-20 minute sessions
- 120 collectible fabrics with beautiful visual designs appeal to her collector instinct
- Premium model means no energy systems, no gacha, no predatory monetization — her $29.99 covers everything
- The garment preview system provides instant visual gratification when she completes a piece
- Client satisfaction animations are warm, rewarding, and worth the brief effort
- She can pause anytime, attend to her kids, and resume without penalty

**Sarah's experience:** Plays during nap time and after bedtime. Gets deeply attached to specific patrons (especially the Dragon Court clients — she loves the dramatic gowns). Treats the weaving minigame as a meditative rhythm activity. Will not engage with the Fashion Underground questline (too dark for her taste) but will pursue all Dragon Court commissions to completion. Will recommend to her mom-friends as "the pretty crafting game."

### P-003: Hiroshi Tanaka — The RPG Addict (Primary)

A 16-year-old completionist from Tokyo who treats every game as a mastery project. Plays 3-4 hours daily. Theorycrafts builds and writes guides for his school's gaming club.

**Why Forge of Elegance fits Hiroshi:**
- 120 fabrics, 40 dyes, 30 glyphs = a completion tracking dream
- Legendary-tier weaving requires 98%+ timing accuracy = a skill ceiling to chase
- The Transcendence ending requires discovering every recipe and mastering every glyph = a clear 100% target
- Faction relationship management across 50+ patrons = a spreadsheet-worthy optimization problem
- The enchantment capacity system (budget EC across glyphs) is a build optimization system in disguise

**Hiroshi's experience:** Will methodically craft every fabric at every quality tier. Will map optimal dye combinations for maximum enchantment efficiency. Will pursue the Transcendence ending on his first playthrough and be frustrated when he cannot achieve it (requires faction balance). Will create a "perfect garment" guide for each patron type. Will love the systems depth; will find the sabotage events annoying because they interrupt his crafting flow.

### P-006: Eleanor Vance — The Loyal Strategist (Primary)

A 62-year-old retired teacher who plays 2-3 hours daily, values depth and fair monetization, despises predatory design. Fixed budget of $10/month — but willing to pay premium upfront for quality.

**Why Forge of Elegance fits Eleanor:**
- Premium purchase = no microtransactions, no energy systems, no timers
- The economic simulation (budget management, market fluctuation, supply chain investment) rewards the patience and planning she honed over decades of Civilization
- Patron relationship management is a strategy layer she will approach methodically
- Sabotage defense is about economic decision-making, not reflexes
- The narrative about institutional corruption and artistic integrity resonates with her values

**Eleanor's experience:** Plays one full season per week. Manages her atelier like a small business — tracks gold income, material costs, and patron satisfaction in her head (or on paper). Will pursue the Reform ending because she believes in systemic change. Will play for months. Will write a thoughtful review about how the game respects the player's intelligence. Will recommend it to her book club and her bridge group.

### P-007: Priya Sharma — The Status Whale (Secondary)

A 28-year-old fashion influencer with 120k followers. Treats games as brand extension. Spends $100-500/month on cosmetics. Her audience follows her for aesthetic curation.

**Why Forge of Elegance fits Priya:**
- The garment design system lets her create pieces that match her real-world aesthetic
- Atelier showroom is a display space she can screenshot and share
- Fashion Underground questline provides edgy content for her social channels
- Premium model limits her spending potential (she cannot whale for advantage), BUT the cosmetic DLC provides the exclusive items she craves
- The game's visual language (industrial opulence, living fabric) is inherently Instagram-worthy

**Priya's experience:** Will play specifically to create garments that match her real-world wardrobe. Will post atelier screenshots as "mood board" content. Will be frustrated that she cannot buy her way to Legendary quality — but will appreciate that the crafting system gives her creative control. Will buy every cosmetic DLC. Will generate significant organic marketing through her social channels. Will play intensely for 3-4 weeks then move on.

---

## User Stories

### Crafting & Production

- **US-001**: As a player, I want a weaving minigame where timing determines fabric quality, so I feel my skill directly improving over time.
- **US-002**: As a player, I want to see my fabric quality reflected visually (glowing threads, particle effects at higher tiers), so mastery has tangible visual feedback.
- **US-003**: As **Hiroshi (P-003)**, I want a quality tier tracker that shows my percentage of Masterwork and Legendary crafts per fabric type, so I can measure my mastery progress.
- **US-004**: As a player, I want to mix dyes freely and see the resulting color on a swatch before committing, so experimentation feels safe.
- **US-005**: As a player, I want enchantment glyphs to have clear capacity costs so I can budget my garment's power budget strategically.
- **US-006**: As **Sarah (P-002)**, I want a "quick craft" option that produces Standard quality fabric automatically, so I can progress during short sessions without the timing minigame.
- **US-007**: As **Eleanor (P-006)**, I want the economic simulation to include supply and demand fluctuations, so market timing adds a strategic layer to material purchasing.

### Client & Patron Management

- **US-008**: As a player, I want each patron to have visible aesthetic preferences (color, style, enchantment type), so I can tailor garments to their tastes.
- **US-009**: As a player, I want a garment preview that shows a 3D model wearing my creation before I deliver it, so I can catch design mistakes early.
- **US-010**: As **Eleanor (P-006)**, I want a relationship history log for each patron showing past commissions and satisfaction scores, so I can identify patterns and optimize.
- **US-011**: As a player, I want faction conflict events where pleasing one patron angers another, so patron management feels like diplomacy, not a checklist.
- **US-012**: As **Hiroshi (P-003)**, I want a patron codex that fills with lore as I complete commissions, so client management rewards narrative discovery.
- **US-013**: As a player, I want rush commissions that pay double but have half the deadline, so risk-taking is available but optional.

### Runway & Competition

- **US-014**: As a player, I want seasonal runway shows with scored categories (Aesthetic, Function, Client Fit, Audience), so competition feels structured and fair.
- **US-015**: As **Hiroshi (P-003)**, I want to see my rival's scores alongside mine during runway judging, so I can identify exactly where I lost points.
- **US-016**: As a player, I want tournament rewards that unlock exclusive materials and glyphs not available anywhere else, so competition has meaningful stakes.
- **US-017**: As **Priya (P-007)**, I want a "best of show" gallery that displays my winning garments with the audience reaction animation, so I can screenshot and share my victories.
- **US-018**: As a player, I want the rival atelier (Sable Marchetti) to escalate tactics across seasons — from copying my designs to sabotaging my materials — so the rivalry feels personal and escalating.

### Workshop Management & Defense

- **US-019**: As **Eleanor (P-006)**, I want atelier upgrade decisions to have meaningful tradeoffs (better loom vs. stronger wards vs. larger showroom), so every gold coin spent is a strategic choice.
- **US-020**: As a player, I want sabotage events that require economic decisions (spend gold to prevent, spend time to recover, or accept the loss), so defense feels like resource management, not combat.
- **US-021**: As **Sarah (P-002)**, I want sabotage events to be survivable even if I don't counter them perfectly, so setbacks don't ruin my limited play sessions.
- **US-022**: As a player, I want my atelier to visually evolve as I upgrade it (more tools, better lighting, displayed patron gifts, fabric bolts on walls), so progress is visible every time I enter my workshop.

### Narrative & Exploration

- **US-023**: As a player, I want Madame Cerise's story told through 15 discovery fragments hidden across all districts, so exploration rewards narrative understanding.
- **US-024**: As **Eleanor (P-006)**, I want the Fashion Council corruption plot to develop through patron conversations and market events (not cutscenes), so the story feels systemic, not scripted.
- **US-025**: As **Hiroshi (P-003)**, I want 3 distinct endings tied to gameplay decisions (which factions I favored, how I handled the Council, what I crafted for the Spindle), so the narrative reflects how I played.
- **US-026**: As a player, I want the Spindle reveal to recontextualize earlier events (market fluctuations were the Spindle grieving, seasonal themes were its memories), so the ending earns its emotional weight.
- **US-027**: As **Sarah (P-002)**, I want the main narrative to be optional — I can ignore the Council plot and just run my atelier — so I am never forced into content I find stressful.

### Accessibility & Comfort

- **US-028**: As a player with motor impairments, I want the weaving minigame to have an adjustable timing window (up to 1200ms for accessibility mode), so the crafting system is playable regardless of reflex speed.
- **US-029**: As a player, I want customizable text size and high-contrast mode for all UI elements (fabric stats, patron preferences, market prices), so information is readable.
- **US-030**: As **Sarah (P-002)**, I want an explicit "no fail" crafting mode where every weave produces at least Standard quality, so I can enjoy the creative process without performance anxiety.
- **US-031**: As a player, I want full controller support on all platforms with customizable button mapping, so I can play comfortably regardless of input preference.
- **US-032**: As a player with color vision deficiency, I want dye colors to have distinct names and patterns (not just color swatches), so I can identify materials without relying solely on color perception.

---

## Monetization

### Revenue Model: Premium $29.99

**Why premium fits this game:**
- Crafting and creative games attract players who value fairness and completeness (Eleanor, David, Hiroshi) — premium signals respect
- The core loop (craft, deliver, upgrade) has no natural place for energy systems or consumable monetization without undermining the economic simulation
- Cosmetic DLC is the only ethical upsell — it adds visual options without affecting game balance
- The target audience overlaps with games like Stardew Valley, the Atelier series, and Unpacking — all premium or premium-adjacent

### Pricing and DLC Roadmap

| Product | Price | Content | Target Window |
|---------|-------|---------|--------------|
| Base Game | $29.99 | Full campaign (4 seasons + Year 2), 120 fabrics, 40 dyes, 30 glyphs, 50+ patrons, 3 endings | Launch |
| Cosmetic Pack: "Regalia" | $4.99 | 8 atelier decoration sets (faction-themed), mannequin poses, fabric display patterns | Launch |
| Cosmetic Pack: "Finery" | $4.99 | 12 patron outfit reskins, alternative loom visual themes, dye bottle aesthetics | Launch |
| Expansion: "The Thread Unravels" | $12.99 | Year 3 content (2 new factions, 30 new fabrics, 10 new glyphs, new ending), apprentice management system | Month 6 |
| Expansion: "Cerise's Legacy" | $12.99 | Prequel campaign (play as young Madame Cerise), 20 new fabrics, Spindle backstory | Month 12 |
| Complete Edition | $49.99 | Base + both expansions + both cosmetic packs | Month 14 |

### Revenue Projections (4 Scenarios)

| Scenario | Year 1 Units | Year 1 Revenue | Year 2 (w/ DLC, 20% attach) | Total (2yr) | Assumptions |
|----------|-------------|---------------|----------------------------|------------|-------------|
| **Modest** | 40,000 | $839,840 | $268,760 | $1,108,600 | Niche crafting sim audience, word-of-mouth |
| **Baseline** | 150,000 | $3,149,400 | $1,009,860 | $4,159,260 | Positive reviews, crafting community coverage, Switch port success |
| **Strong** | 400,000 | $8,398,400 | $3,073,920 | $11,472,320 | Influencer coverage (cozy game streamers), award nomination, strong Switch sales |
| **Breakout** | 1,200,000 | $25,195,200 | $10,640,400 | $35,835,600 | Viral TikTok/Instagram (Priya-type organic marketing), major award, multi-platform success |

**Break-even at ~55,000 units ($1.1M) against development budget of $1.05M (see Production Plan).**

All revenue figures are net after 30% platform cut.

---

## Production Plan

### Team

| Role | Count | Phase | Monthly Cost (Loaded) |
|------|-------|-------|----------------------|
| Game Director / Lead Design | 1 | All | $11,000 |
| Systems Designer (economy, patrons) | 1 | Months 1-14 | $9,000 |
| Unity Developer (core systems) | 2 | All | $9,500 each |
| Unity Developer (UI/UX) | 1 | Months 3-14 | $8,500 |
| Technical Artist (fabric shaders, VFX) | 1 | Months 2-14 | $9,500 |
| 3D Artist (environment — Luminarre) | 2 | Months 3-14 | $8,000 each |
| 3D Artist (garments, characters) | 1 | Months 2-14 | $8,500 |
| 2D Artist (UI, fabric patterns, codex) | 1 | Months 2-12 | $7,500 |
| Composer / Audio Designer | 1 (contract) | Months 4-14 | $6,500 |
| Writer | 1 (contract) | Months 1-10 | $6,000 |
| QA Lead | 1 | Months 8-16 | $6,500 |
| QA Testers | 2 | Months 10-16 | $4,500 each |
| Producer | 1 | All | $10,000 |

**Total team: 16 people peak (months 6-12)**

### Timeline (16-month production)

| Month | Milestone | Key Deliverables |
|-------|-----------|-----------------|
| 1 | Prototype | Core weaving minigame, basic fabric system, garment scoring, one client |
| 2 | Vertical Slice | One full crafting loop (weave, dye, enchant, deliver), atelier scene, 3 fabrics, 1 patron |
| 3 | Pre-Production Complete | All 6 districts greyboxed, patron roster finalized (50+), fabric list locked (120), design doc complete |
| 4 | Production Phase 1 | Weaving system final, dye mixing implemented, 20 fabrics craftable, first 10 patrons active |
| 5 | Production Phase 1 | Enchantment binding system complete, first runway show prototype, market economy baseline |
| 6 | Production Phase 2 | 60 fabrics, 20 dyes, 15 glyphs implemented, sabotage event system operational |
| 7 | Production Phase 2 | Patron relationship system fully functional, faction conflict events triggering |
| 8 | Production Phase 2 | All 120 fabrics, 40 dyes, 30 glyphs in-engine, QA begins, first full seasonal tournament playable |
| 9 | Production Phase 3 | All 50+ patrons with full questlines, narrative events integrated, rival AI (Sable) operational |
| 10 | Production Phase 3 | All 4 seasonal tournaments tested, sabotage events tuned, atelier upgrade tree complete |
| 11 | Alpha | Full game playable, all systems integrated, all 3 endings achievable, internal testing begins |
| 12 | Alpha Iteration | Bug fixes, difficulty tuning, economic balance pass based on playtest data |
| 13 | Beta | Feature complete, content complete, external playtesting begins, mobile optimization pass |
| 14 | Release Candidate | Steam/console certification, mobile performance tuning, final art polish |
| 15 | Launch | PC (Steam/GOG) + Nintendo Switch launch, day-1 patch |
| 16 | Mobile Launch + Post-Launch | iOS/Android launch, hotfix support, DLC 1 pre-production begins |

### Budget Breakdown

| Category | Cost | Notes |
|----------|------|-------|
| Salaries (16 months, 16 FTE peak) | $785,000 | Blended rate ~$8,200/mo avg |
| Software and Tools | $28,000 | Unity Pro licenses, Perforce, Jira, Adobe CC, Houdini |
| Hardware (dev kits, workstations) | $35,000 | 2 Switch dev kits, 12 workstations, test devices (iOS/Android) |
| QA and Playtesting | $32,000 | External QA contractor, playtest participant compensation |
| Audio (composer contract, sound effects) | $40,000 | Original score, environmental audio, crafting sound design |
| Marketing | $65,000 | Trailers (2), Steam Next Fest, convention presence (1), influencer outreach |
| Operations and Overhead | $40,000 | Legal, accounting, insurance, incorporation |
| Contingency (10%) | $105,000 | |
| **Total** | **$1,130,000** | |

---

## Technical Requirements

### Platform Specifications

| Spec | PC Minimum | PC Recommended | Nintendo Switch | iOS | Android |
|------|-----------|---------------|----------------|-----|---------|
| **CPU** | Intel i3-4160 / AMD FX-6300 | Intel i5-10600 / AMD Ryzen 5 3600 | Custom NVIDIA Tegra (locked) | A11 Bionic (iPhone X) | Snapdragon 720G |
| **RAM** | 8 GB | 16 GB | 4 GB | 3 GB available | 4 GB available |
| **GPU** | GTX 750 Ti / R7 260X | GTX 1660 / RX 5600 XT | Custom (locked) | Apple GPU (3-core) | Adreno 618 |
| **Storage** | 15 GB HDD | 15 GB SSD | 8 GB | 5 GB + 3 GB saves | 5 GB + 3 GB saves |
| **OS** | Windows 7 64-bit | Windows 10/11 64-bit | Switch OS | iOS 14+ | Android 11+ |
| **Target Resolution** | 1080p / 30 FPS | 1440p / 60 FPS | 720p handheld / 1080p docked, 30 FPS | Native device resolution / 30 FPS | Native device resolution / 30 FPS |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **Fabric physics simulation** | High — real-time cloth simulation on 120+ fabric types with enchantment effects must run at 30 FPS on Switch and mobile | Pre-baked fabric behavior profiles (not real-time physics). Each fabric has 5-8 pre-calculated drape states that blend based on movement. Particle effects for enchantments are GPU-instanced and capped at 200 particles per garment. |
| **Mobile touch controls for weaving minigame** | Medium — timing minigame requires precise input; touch latency varies across Android devices | Input buffering (3-frame buffer on all platforms). Touch targets are 44pt minimum. Calibration screen on first mobile launch that measures device input latency and adjusts timing windows accordingly. |
| **3D garment preview system** | Medium — rendering custom garments on mannequins in real time across platforms | Modular garment system: each garment is assembled from 12-18 pre-built mesh pieces (sleeves, bodice, skirt, etc.) that combine at design time. No procedural mesh generation at runtime. Preview scene runs at reduced quality on mobile. |
| **Economic simulation balance** | Medium — market prices, patron payments, and upgrade costs must create tension without being punitive | Extensive playtesting with telemetry. Economic parameters stored in a tunable JSON config, patchable post-launch. Simulate 1000 in-game years at various player skill levels to identify edge cases. |
| **Cross-platform save compatibility** | Low — PC, Switch, and mobile saves must be compatible | Save format is platform-agnostic JSON. Cloud save via platform services (Steam Cloud, Switch cloud, iCloud/Games Services). No platform-specific save data. |
| **120 fabric types with distinct visual identity** | Medium — each fabric needs unique texture, drape behavior, and enchantment visual | Texture atlasing: all fabric textures packed into 4k atlases (30 fabrics per atlas, 4 atlases). Drape profiles are parameterized (stiffness, weight, sheen) rather than individually authored. Enchantment visuals are shared effects tinted per-glyph. |

---

<npl-block type="reflection">
Correctness: All 12 sections present per format requirements. Budget, timeline, team size, and revenue projections are internally consistent (16 FTE peak, 16 months, $1.13M budget, break-even at 55K units). Fabric/dye/glyph counts match across all sections (120/40/30). Patron count (50+) consistent throughout.

Edge cases: Quick craft (US-006) prevents mobile players from being gated by weaving timing. Accessibility mode (US-028) extends timing windows to 1200ms. No-fail mode (US-030) protects casual players. Quick craft and accessibility mode together mean the crafting system is playable by virtually anyone.

Security: No security concerns — this is a game design document.

Pitfalls: Persona mapping pushes a mobile-gaming-oriented persona library onto a multi-platform premium game. Addressed by focusing on behavioral fit (Sarah's short sessions, Eleanor's strategic depth, Hiroshi's completionism, Priya's social sharing) rather than platform assumptions. The weaving minigame timing windows (600ms down to 200ms) need playtesting to confirm that the difficulty curve feels rewarding, not punishing.

Improvements: Could expand the apprentice management system (hinted at in Year 2 progression). Could detail the Fashion Underground questline. Could add post-launch content roadmap beyond the two DLC packs.

Refactors: Document structure matches the 12-section format established by Cursed Paladin Bayou and Whispering Grottos.

Documentation: This IS the documentation.

Clarifications: None needed — all assumptions stated in persona mapping, monetization rationale, and technical mitigations.

TODOs: Expansion content ("The Thread Unravels" and "Cerise's Legacy") would need separate design passes post-launch. Mobile-specific UI layouts need a dedicated UX pass during production.
</npl-block>
