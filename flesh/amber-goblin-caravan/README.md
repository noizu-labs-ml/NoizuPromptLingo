# Amber Goblin Caravan

## Title and Genre

| Attribute | Detail |
|-----------|--------|
| **Title** | Amber Goblin Caravan |
| **Genre** | Cozy Social Trading Simulation |
| **Engine** | Unity 2024 LTS (2D URP, cross-platform) |
| **Platform Targets** | PC (Steam), Nintendo Switch, PlayStation 5, iOS, Android |
| **Monetization** | Premium ($24.99 base), cosmetic wagon skins ($2.99-$7.99 each), seasonal skin bundles ($12.99) |
| **Rating** | ESRB E (Everyone) -- Alcohol Reference (goblin ale served at taverns, no consumption depicted) |
| **Max Players** | 4-player online co-op caravan; asynchronous trading across all connected players |

---

## Vision Statement

Amber Goblin Caravan is a warm, hand-painted trading simulation where the player commands a crew of goblin merchants across a whimsical 60-day journey through the continent of Golvaris. It blends the satisfaction of buy-low-sell-high arbitrage with a deep crafting system that turns raw ingredients into exotic luxury goods -- amber candies, enchanted trinkets, bottled starlight -- each with its own supply chain and market dynamics. The game exists because the gap between "cozy" and "strategically deep" is underserved: players want to feel smart without feeling stressed, and they want to care about characters without being punished for taking a rest day. The aesthetic is amber-and-teal warmth -- stop-motion-inspired animations, hand-painted environments, a soundtrack of lutes, accordions, and crickets by a campfire -- and the tone is gently comedic, like a folk tale told by a goblin who is exaggerating only slightly.

---

## Core Loop

**Target session length:** 20-45 minutes (one in-game "day" takes approximately 15-25 minutes of real time; players typically play 1-3 days per session).

```
┌─────────────────────────────────────────────────────────┐
│                     MORNING PHASE                       │
│  ┌───────────┐   ┌──────────────┐   ┌───────────────┐  │
│  │ Check     │──>│ Buy          │──>│ Craft         │  │
│  │ Market    │   │ Ingredients  │   │ Goods (Cook,  │  │
│  │ Prices &  │   │ & Supplies   │   │ Tinker, Brew) │  │
│  │ Town News │   │ from Vendors │   │               │  │
│  └───────────┘   └──────────────┘   └───────┬───────┘  │
│                                              │          │
│                     AFTERNOON PHASE          │          │
│  ┌───────────┐   ┌──────────────┐   ┌───────▼───────┐  │
│  │ Travel to │──>│ Random       │──>│ Sell Goods    │  │
│  │ Next Town │   │ Encounters   │   │ at New Town   │  │
│  │ (Route    │   │ (Events,     │   │ Market,       │  │
│  │ Choice)   │   │ NPCs, Stops) │   │ Haggle,       │  │
│  └───────────┘   └──────────────┘   │ Fulfill       │  │
│                                     │ Orders        │  │
│                                     └───────┬───────┘  │
│                                              │          │
│                     EVENING PHASE            │          │
│  ┌───────────┐   ┌──────────────┐   ┌───────▼───────┐  │
│  │ Campfire  │──>│ Crew         │──>│ Plan Next     │  │
│  │ Bonding & │   │ Management   │   │ Day (Review   │  │
│  │ Meals     │   │ (Rest, Gift, │   │ Map, Set      │  │
│  │           │   │ Quests)      │   │ Route, Queue  │  │
│  └───────────┘   └──────────────┘   │ Crafts)       │  │
│                                     └───────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### Phase Breakdown

**Morning Phase (5-8 minutes real time):**
The player arrives at a town or wakes at camp. They open the Town Market Board, which displays current buy/sell prices for 47 trade goods across 6 commodity families (Produce, Minerals, Crafted Goods, Exotics, Contraband, Seasonal). Prices are color-coded: green (below regional average -- buy signal), yellow (average), red (above average -- sell signal). Town News shows one or two headlines that hint at upcoming price shifts ("Frost expected in Brambleheath -- amber candy demand rising"). The player visits 3-5 NPC vendors per town, each with a rotating stock of raw ingredients and a personality that affects their willingness to haggle.

**Afternoon Phase (8-12 minutes real time):**
The player chooses a route to the next town from 2-3 options (fast/safe, slow/scenic, shortcut/risky). Travel triggers 1-3 random encounters drawn from a pool of 120 events: a roadside merchant offering rare ingredients, a bandit toll that can be paid, negotiated, or evaded, a lost traveler with a side quest, a scenic overlook with a collectible lore fragment, or a rival caravan already setting up at the next town's market. Upon arrival, the player sells goods through the Town Market interface, which supports instant sell (current price), limit orders (sell when price reaches a target), and haggling (a risk/reward mini-game where pushing too hard angers the vendor and locks the sale for that day).

**Evening Phase (5-8 minutes real time):**
The caravan camps. The player cooks a meal from collected ingredients (each meal provides a buff for the next day: +10% haggling success, +15% crafting quality, +20% travel speed). The player manages crew: assign rest days to recover morale, give gifts to deepen relationships, advance personal questlines through dialogue choices, or push crew for bonus productivity at a morale cost. Finally, the player reviews the map and plans the next day's route, queuing up to 3 crafting jobs to complete overnight.

---

## Meta Loop

### Session-to-Session Progression

```
┌────────────────────────────────────────────────────────────────┐
│                    PROGRESSION AXES                            │
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ WEALTH       │  │ REPUTATION   │  │ CREW DEPTH           │ │
│  │ (Gold total, │  │ (Per-town    │  │ (Relationship rank   │ │
│  │  wagon tier, │  │  favor,      │  │  with each crew      │ │
│  │  crafting    │  │  festival    │  │  member, personal    │ │
│  │  recipes     │  │  standing,   │  │  questlines,         │ │
│  │  unlocked)   │  │  merchant    │  │  specialist skills)  │ │
│  │              │  │  guild rank) │  │                      │ │
│  └──────┬───────┘  └──────┬───────┘  └──────────┬───────────┘ │
│         │                 │                      │             │
│         ▼                 ▼                      ▼             │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │           CARRY-OVER BETWEEN JOURNEYS                   │  │
│  │                                                         │  │
│  │  - Festival reputation persists across playthroughs     │  │
│  │  - Recipes and crafting mastery carry over              │  │
│  │  - Crew relationship progress resets partially (70%)    │  │
│  │  - Wagon upgrades persist (modular slot system)         │  │
│  │  - Gold resets to starting amount (+10% per completed   │  │
│  │    journey as a "veteran bonus")                        │  │
│  │  - Lore journal entries persist permanently             │  │
│  │  - Market manipulation history affects economy seed     │  │
│  │  - Multiplayer trade routes established in prior runs   │  │
│  │    remain available                                    │  │
│  └─────────────────────────────────────────────────────────┘  │
│                                                                │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │           GROWTH FEEL                                   │  │
│  │                                                         │  │
│  │  Early: Scraping by, buying flour and sugar, selling    │  │
│  │         plain cookies for razor-thin margins. Every     │  │
│  │         gold coin matters.                               │  │
│  │                                                         │  │
│  │  Mid:   Unlocking exotic recipes (amber candy, bottled  │  │
│  │         starlight). Markets open up. The player feels   │  │
│  │         like a real merchant -- buying in bulk,         │  │
│  │         cornering scarce goods, anticipating demand.    │  │
│  │                                                         │  │
│  │  Late:  Running a luxury caravan. Custom wagon with    │  │
│  │         kitchen, display cases, hidden compartments.    │  │
│  │         Crew members are friends with resolved arcs.    │  │
│  │         The player manipulates markets across towns     │  │
│  │         like a puppeteer.                               │  │
│  └─────────────────────────────────────────────────────────┘  │
└────────────────────────────────────────────────────────────────┘
```

### Journey Structure

A single playthrough is 60 in-game days across 18 towns. Each town visit occupies 1-2 days. The 60-day clock creates gentle urgency without harsh failure -- the journey ends when the clock runs out, and the player's score is measured in total wealth, reputation, crew happiness, and recipes completed. There is no "game over" -- only "how well did you do?"

| Journey Segment | Days | Towns Visited | Focus |
|-----------------|------|---------------|-------|
| Starting Region (Ambermeadow) | 1-10 | 4 | Learn basics, build initial capital ($200-$800), recruit first 2 crew |
| Middle Region (Tealwood) | 11-30 | 7 | Crafting depth opens, market manipulation possible, 2 festivals occur |
| Upper Region (Starcrest Highlands) | 31-50 | 5 | High-value exotic goods, rival caravan competition peaks, story climax |
| Final Region (Golvaris Capital) | 51-60 | 2 | Endgame trading, grand market, final festival, story resolution |

---

## Game Mechanics

### Primary Mechanic: The Crafting-Commerce Pipeline

The central system is a two-stage pipeline: **source raw ingredients, then craft them into high-value goods for sale**. Every crafting recipe has 2-4 inputs, a crafting station requirement, a quality modifier, and a sell-value multiplier relative to the raw inputs.

**Ingredient Families and Counts:**

| Family | Count | Examples | Sources |
|--------|-------|----------|---------|
| Produce | 14 | Sunroot, Frostberry, Glowshroom, Ambergrain, Honeybloom | Farm vendors, foraging encounters |
| Minerals | 11 | Copperite, Starshard, Dewstone, Moonquartz, Ashvein Ore | Mine vendors, mountain encounters |
| Rarities | 9 | Bottled Starlight, Phoenix Ash, Dreamweave Thread, Shadow Sap | Special vendors, quest rewards |
| Spices | 8 | Cinnamoss, Pepperbloom, Saffronpetal, Emberleaf | Spice merchant (appears at festivals) |
| Base Materials | 5 | Flour, Sugar, Salt, Water, Wood | Available in every town |

**Crafting Stations and Recipe Counts:**

| Station | Unlocked | Recipes | Output Category | Example Recipe |
|---------|----------|---------|-----------------|----------------|
| Kitchen | Day 1 | 18 | Food and Drink | Amber Candy (Ambergrain + Honeybloom + Sugar) -- sell value 3.2x ingredients |
| Tinker Bench | Day 5 | 14 | Enchanted Trinkets | Starshard Pendant (Starshard + Dewstone + Copperite) -- sell value 4.1x |
| Brew Kettle | Day 12 | 11 | Potions and Elixirs | Bottled Starlight (Starlight + Moonquartz + Emberleaf) -- sell value 5.8x |
| Artificer Table | Day 25 | 9 | Luxury Exotics | Dreamcatcher (Dreamweave Thread + Shadow Sap + Phoenix Ash) -- sell value 7.3x |
| Secret Still | Day 40 | 5 | Contraband | Goblin Ale (any Grain + any Spice + Shadow Sap) -- sell value 9.0x but risks guard encounters |

**Crafting Quality System:**

Each crafted item rolls a quality tier based on three factors: ingredient freshness (ingredients degrade 10% quality per day in storage), crew specialist skill (the cook's skill affects kitchen outputs, etc.), and crafting buffs (from campfire meals or crew abilities).

| Quality | Probability (Base) | Sell Multiplier | Visual Indicator |
|---------|---------------------|-----------------|------------------|
| Rough | 40% | 1.0x (break even) | Gray border |
| Fine | 30% | 1.5x | Green border |
| Superb | 20% | 2.2x | Blue border |
| Masterwork | 8% | 3.5x | Purple border |
| Legendary | 2% | 6.0x | Gold border with sparkle animation |

The player cannot directly control quality rolls but influences them through crew skill upgrades (each specialist gains 1% per crafting session, capping at +25% to Superb+ chance), fresh ingredients, and crafting buffs. This creates a satisfying mastery curve without requiring twitch skill.

### Secondary Mechanics

**Haggling Mini-Game:**

When buying or selling, the player can initiate a haggle. A circular gauge appears with a "sweet spot" zone (varies per vendor personality). The player taps once to start a rotating needle, then again to stop it. Landing in the sweet spot grants a 10-25% price improvement. Landing outside gives 0-5%. Landing in the "offend" zone (10% of the circle) angers the vendor, who refuses the deal and remembers the slight for 3 days.

Vendor personalities determine the sweet spot size and position:

| Vendor Type | Sweet Spot Size | Sweet Spot Position | Forgiveness |
|-------------|----------------|--------------------:|-------------|
| Friendly | 35% of gauge | Center | High -- rarely offended |
| Shrewd | 20% of gauge | Offset right | Medium -- offended by bad misses |
| Gruff | 25% of gauge | Offset left | Low -- quick to anger |
| Mysterious | 15% of gauge | Random per attempt | Unknown -- unpredictable |

**Wagon Customization:**

The wagon has 34 upgrade slots across 7 modules. Slots are unlocked with gold and rare materials. Each module provides distinct gameplay benefits:

| Module | Slots | Unlock Cost | Function |
|--------|-------|-------------|----------|
| Cargo Hold | 8 | $50-$400/slot | Increases inventory capacity (base 20 items, +5 per slot) |
| Kitchen | 5 | $80-$300/slot | Unlocks food recipes, +1 queued craft per slot |
| Display Case | 4 | $100-$250/slot | +5-15% sell price in town, visual customizations |
| Reinforced Wheels | 4 | $60-$200/slot | Unlocks mountain and swamp routes, +10% travel speed per slot |
| Crew Quarters | 5 | $70-$350/slot | +10% morale recovery per slot, unlocks crew abilities |
| Hidden Compartment | 4 | $120-$400/slot | Smuggles contraband past guards (base 40% catch rate, -10% per slot) |
| Tinker Bench | 4 | $90-$300/slot | Unlocks trinket recipes, +5% quality per slot |

**Crew Relationship System:**

Four specialist roles, each recruitable at specific story points:

| Specialist | Recruited | Skill Domain | Personal Quest | Max Relationship Ability |
|------------|-----------|--------------|----------------|--------------------------|
| Skizzle (Cook) | Day 3 | Kitchen quality, meal buffs | Find her lost recipe book across 5 towns | "Skizzle's Special" -- auto-crafts one Masterwork per day |
| Grak (Haggler) | Day 8 | Better prices, vendor rapport | Prove himself to his disapproving merchant father | "Grak's Guarantee" -- locks in best price once per town |
| Thornack (Guard) | Day 15 | Encounter resolution, safety | Confront his past as a bandit | "Thornack's Intimidation" -- auto-resolves bandit encounters |
| Plix (Tinkerer) | Day 22 | Trinket quality, wagon repairs | Build the legendary Automaton Companion | "Plix's Perfection" -- +15% quality on all crafts |

Crew morale operates on a 0-100 scale. Morale drains at 3 points per day baseline, increases by 10 from rest days, 5 from favorite gifts, 8 from cooked meals they enjoy, and decreases by 15 from being pushed for extra work. Below 30 morale, the crew member's skill bonus halves. Below 10, they may leave (with a 2-day warning). At 80+ morale, they gain a 10% skill bonus and trigger unique campfire dialogue.

**Dynamic Market Economy:**

Each of the 18 towns tracks supply and demand for all 47 trade goods. The core formula:

```
Current Price = Base Price x (1 + Demand Modifier - Supply Modifier + Seasonal Modifier + Event Modifier)
```

- **Demand Modifier**: Increases when players (including online multiplayer participants) buy a good. Recovers 5% per day toward baseline.
- **Supply Modifier**: Increases when players sell a good. A single large sale (20+ units) can crash the price 30-40%.
- **Seasonal Modifier**: Every 15 days, the season shifts (Spring, Summer, Autumn, Winter), adjusting demand for seasonal goods.
- **Event Modifier**: Town news events (blight, festival, trade embargo, royal visit) create temporary price spikes or crashes.

Solo players experience a simulated economy with NPC caravans also buying and selling. Multiplayer players share a live economy where their trades directly affect each other's markets.

### Difficulty Progression

| Segment | Days | New Mechanics Introduced | Economic Pressure | Crew Complexity | Risk Level |
|---------|------|--------------------------|-------------------|-----------------|------------|
| Starting | 1-5 | Basic buy/sell, kitchen crafting, first crew member | Low -- margins are forgiving (50-80%) | 1 crew, no morale pressure | Minimal -- no encounters that cost gold |
| Early | 6-15 | Haggling, wagon upgrades, second crew member, route choices | Medium -- margins tighten (30-50%), must craft to profit | 2 crew, morale introduced | Low -- encounters are beneficial or neutral |
| Mid-Game | 16-30 | Advanced crafting (brewing), festivals, market manipulation, rival caravan | Moderate -- competing for best prices, festival timing matters | 3 crew, personal quests begin | Medium -- bandits, broken wagon events, spoiled ingredients |
| Late-Mid | 31-45 | Artificer recipes, contraband, guard encounters, complex supply chains | High -- best margins require multi-town supply chains | 4 crew, relationship decisions impact story | Medium-High -- guards seize contraband, rival undercuts prices |
| Endgame | 46-60 | Secret recipes, legendary crafts, grand market, story resolution | Very High -- capital-intensive plays, market cornering | All crew, final relationship outcomes | High -- everything interacts, but the player is powerful enough to manage it |

---

## World Design

### Map Structure

Golvaris is an interconnected route map, not an open world. The player travels along a branching path of roads connecting 18 towns. At each junction, the player chooses between 2-3 routes. Routes are not reversible during a single journey (the 60-day clock prevents backtracking), creating strategic commitment.

```
                    [Ambermeadow] (Start)
                         │
                    [Millbrook]
                    ╱          ╲
            [Thornfield]    [Glimmerfen]
                 │              │
            [Copperdale]──[Mossbridge]──[Brambleheath]
                               │
                          [Frostholm]
                         ╱          ╲
                 [Emberpeak]    [Starwatch]
                      │              │
                 [Cinderhaven]──[Cloudrest]
                                │
                           [Highspire]
                          ╱          ╲
                  [Galeport]    [Moonveil]
                       │              │
                  [Dawnmere]────[Golvaris Capital] (End)
```

### Art Direction Pillars

1. **Warm Amber Dominance**: The primary palette is amber, honey, and gold tones. Every scene feels sun-warmed, even at night (firelight, lantern glow).
2. **Teal Contrast**: Secondary color is deep teal and seafoam green, used for shadows, water, magical effects, and UI accents.
3. **Hand-Painted Texture**: All environments use digital gouache-style painting. No photorealism. Visible brush strokes on terrain, sky, and buildings.
4. **Stop-Motion Character Animation**: Goblins move at 12 fps with deliberate "chunky" keyframes. Idle animations loop with slight irregularity to feel hand-cranked.
5. **Layered Parallax Depth**: Environments have 4-6 parallax layers creating diorama-like depth. The caravan travels "through" the scene rather than "on top of" it.
6. **Cozy Lighting**: Warm light sources dominate. Even dungeons and caves have bioluminescent mushrooms or amber crystal formations providing golden illumination.

### World Progression Table

| Region | Visual Palette | Ambient Audio | Architecture Style | Key Visual Feature |
|--------|---------------|---------------|-------------------|-------------------|
| Ambermeadow | Gold, wheat, green | Crickets, wind through grain, distant laughter | Thatched cottages, wooden fences | Rolling wheat fields under amber sunset |
| Millbrook | Warm brown, blue water | Water wheel creaking, bird song, market chatter | Watermills, stone bridges, canals | Central waterfall with rainbow mist |
| Thornfield | Deep green, rust red | Crows, rustling thorns, distant forge | Blacksmith forges, thorn-wrapped walls | Massive wrought-iron gate entangled with roses |
| Glimmerfen | Teal, silver, purple mist | Frogs, dripping water, ethereal chimes | Stilt houses, bioluminescent walkways | Glowing swamp gas that forms shapes at night |
| Brambleheath | Frost blue, amber hearth glow | Howling wind, crackling fires, crunching snow | Nordic longhouses, smoke holes | Northern lights reflected in frozen lakes |
| Starcrest Highlands | Indigo, gold, white | Wind at altitude, eagle calls, bell chimes | Mountaintop observatories, rope bridges | Constellations visible even during daytime |
| Golvaris Capital | Rich gold, crimson, marble | Crowd murmur, cathedral bells, fountain splash | Grand markets, clocktowers, mosaics | 60-foot amber crystal at city center, glowing |

---

## Narrative

### Story Spine (8-Point Structure)

| Beat | Day Range | Event |
|------|-----------|-------|
| **1. Equilibrium** | Day 1-2 | The player inherits a broken-down wagon from their late Uncle Boggle, a once-legendary goblin merchant. The wagon is in Ambermeadow. The player has 60 days before the Merchant Guild repossesses it for Uncle Boggle's outstanding debts ($5,000 gold). Starting capital: $200. |
| **2. Inciting Incident** | Day 3-5 | The player discovers a locked compartment in the wagon containing Uncle Boggle's journal. The journal reveals he was searching for the legendary Amber Keystone -- a gem said to guarantee any merchant who holds it prosperity forever. The journal has fragments torn out, one recovered at each major town. |
| **3. First Complication** | Day 8-12 | A rival caravan led by Vex Snarltooth (a charming but ruthless goblin merchant) appears at the same market. Vex claims Uncle Boggle owed him money too and demands the player's best goods as payment. The player must choose: pay (lose significant inventory), refuse (Vex undercuts prices in future towns), or negotiate (opens a rivalry subplot). |
| **4. Rising Action** | Day 15-30 | The player collects journal fragments and discovers Uncle Boggle was close to finding the Amber Keystone before he died. Each fragment reveals a clue about the Keystone's location. Simultaneously, the player builds crew relationships, uncovers town secrets (the blacksmith in Copperdale secretly writes love poetry; the mayor of Frostholm is hoarding supplies), and navigates three seasonal festivals with exclusive trading opportunities. |
| **5. Midpoint Reversal** | Day 31-35 | The player discovers that Vex Snarltooth is Uncle Boggle's estranged son -- the player's cousin. Vex reveals Uncle Boggle abandoned him as a child to pursue merchant glory. The Keystone quest destroyed their family. Vex is searching for the Keystone too, not for wealth, but to destroy it. The player must reconcile family history with their own motivations. |
| **6. Crisis** | Day 40-45 | A massive trade disruption hits Golvaris -- the Frost Crawl, a magical winter storm, blocks key mountain passes for 5 days. Routes are cut off, supply chains collapse, and the player must survive on stored inventory and creative trading. Vex uses the chaos to corner the market on fire-related goods. The player's crew morale is tested -- Thornack's bandit past resurfaces when former gang members appear during the crisis. |
| **7. Climax** | Day 50-55 | The player reaches the Starcrest Highlands and finds the Amber Keystone's resting place -- the Amber Sanctum beneath the central crystal in Golvaris Capital. Vex arrives simultaneously. Both caravans race through the final towns to reach the capital first. The player's trading prowess, crew relationships, and accumulated reputation determine whether they arrive ahead of Vex. The Keystone chamber requires solving a trading puzzle -- offering goods that represent true merchant wisdom, not just wealth. |
| **8. Resolution** | Day 56-60 | The ending is determined by choices made throughout: crew relationship levels, Vex rivalry resolution (reconciled, competitive peace, or bitter enemies), total wealth, and reputation. There are 6 distinct endings ranging from "Family Reunited, Merchant Guild Master" (best) to "The Road Goes On" (bittersweet -- the player pays the debt but chooses the traveling life over the Keystone). No ending is a failure -- each is a valid conclusion to a goblin merchant's story. |

### Tone Spectrum (7-Axis)

| Axis | Position | Detail |
|------|----------|--------|
| Humor | 7/10 -- Predominantly comedic | Goblins are inherently absurd; humor comes from their earnest attempts at sophistication |
| Darkness | 2/10 -- Very light | No character death on screen; conflicts are economic and emotional, not violent |
| Complexity | 6/10 -- Moderate depth | Economic systems are genuinely complex, but the game never punishes the player for not optimizing |
| Whimsy | 8/10 -- High whimsy | Bottled starlight, enchanted trinkets, goblins wearing tiny top hats |
| Warmth | 9/10 -- Extremely warm | Campfire scenes, shared meals, found-family crew dynamics |
| Tension | 3/10 -- Low tension | The 60-day clock creates gentle urgency; there is no real "lose" state |
| Player Agency | 7/10 -- High agency | Route choices, crew management, market manipulation, and story choices all meaningfully affect outcomes |

### Character Table

| Character | Role | Theme | Personality Trait | Personal Quest Fragments | Relationship to Player |
|-----------|------|-------|-------------------|--------------------------|------------------------|
| Skizzle | Cook | Nourishment as love | Anxious perfectionist, speaks in recipe metaphors | 5 -- recipe book pages found across towns | Recruit Day 3, motherly figure |
| Grak | Haggler | Proving worth | Brash, secretly insecure, competitive | 5 -- letters from his father | Recruit Day 8, friendly rival turned ally |
| Thornack | Guard | Redemption | Stoic, dry humor, fiercely protective | 5 -- tokens from his bandit past | Recruit Day 15, reveals vulnerability slowly |
| Plix | Tinkerer | Creation for its own sake | Excitable, distracted, genius at crafting | 5 -- blueprints for the legendary Automaton | Recruit Day 22, eccentric mentor |
| Vex Snarltooth | Rival / Cousin | Family and forgiveness | Charming, calculating, wounded | N/A -- central antagonist | Revealed as family at midpoint |
| Uncle Boggle (deceased) | Legacy | The weight of ambition | Only seen through journal entries | 18 -- one per town, drives main quest | Posthumous mentor |
| Mayor Briarheart | Recurring NPC | Corruption with a heart of gold | Greedy but genuinely loves her town | N/A | Comic relief, occasional ally |
| The Hermit of Glimmerfen | Quest NPC | Prophecy and mystery | Cryptic, speaks in riddles, trades in prophecies | 3 -- prophecy fragments | Provides market predictions for rare goods |

---

## Player Personas

### P-002: Sarah Chen -- "The Micro-Gamer"

**Why this game fits:** Amber Goblin Caravan respects Sarah's fragmented play schedule. Each in-game day is 15-25 minutes -- perfect for her between-chores sessions. The cozy aesthetic, cute goblin characters, and absence of energy gates mean she can always make progress when she has time. The crafting system gives her the collection satisfaction she gets from gacha, but through gameplay rather than RNG.

**Predicted experience:** Sarah plays 2-3 in-game days per real day, spread across morning, lunch, and evening. She gravitates toward crafting (especially food recipes -- the cooking animations charm her) and crew relationship building. She treats Skizzle's questline as her main emotional investment. She ignores market manipulation entirely and sells at whatever price is current, but still finishes the journey profitably because the base economy is generous. She buys 2-3 cosmetic wagon skins because the aesthetic variety delights her. She plays through twice: once to learn, once to "do it right."

### P-006: Eleanor Vance -- "The Loyal Strategist"

**Why this game fits:** Eleanor wants strategic depth without predatory monetization. Amber Goblin Caravan's market economy has genuine complexity -- supply/demand modeling, seasonal shifts, multi-town supply chains, and the ability to corner markets. The premium model (no energy, no consumable IAP) aligns with her fixed-income budget and anti-gambling stance. The 60-day journey structure gives her a clear long-term planning horizon.

**Predicted experience:** Eleanor plays one full in-game day each morning with her coffee, carefully reading Town News and planning her route. She maps price histories in a notebook (or mentally), identifies arbitrage opportunities between towns, and builds supply chains. She maxes out the Tinker Bench first because the crafting quality system rewards patience and planning. She completes every crew questline and reads every journal fragment. She plays through 4-5 times, optimizing her strategy each journey. She does not buy cosmetics -- she spends her $24.99 once and considers it excellent value.

### P-008: David Park -- "The Achievement Hunter"

**Why this game fits:** David needs fair, achievable 100% completion targets. Amber Goblin Caravan's achievement system tracks 127 achievements across trading (sell 1,000 total goods), crafting (craft one Legendary item), crew (max all relationships in a single journey), exploration (visit all 18 towns in one run), story (see all 6 endings), and economy (accumulate $50,000 gold). None are time-limited or RNG-gated -- all are achievable through skill and persistence.

**Predicted experience:** David approaches the game as a completion project. He creates a tracking spreadsheet on day one. He plays through 3 times minimum: once for story and learning, once for 100% crew relationships and all recipes, once for the remaining endings and economic achievements. He spends $12.99 on a skin bundle after his second playthrough because the game has earned his money. He writes a 2,000-word Steam guide on optimal trading routes. His one frustration: the Legendary quality roll (2% base) requires roughly 50 crafting attempts on average to guarantee, which he finds mildly irritating but not unfair since he can raise the probability to 15% with max crew and buffs.

### P-012: Jessica Lee -- "The Friend-Follower"

**Why this game fits:** Jessica plays for social connection. Amber Goblin Caravan's multiplayer mode lets her form a caravan with up to 3 friends, sharing the journey, trading between caravans, and competing for market positions. The asynchronous trading system means she can participate even when her friends are offline -- she sets up trade offers and they accept when they log in. No one falls behind because the game scales difficulty based on caravan size, and shared wealth pools mean the group progresses together.

**Predicted experience:** Jessica joins her friend group's weekly "caravan night" every Thursday. She picks the cook role (crafting ingredients her friends source) because it requires less market knowledge and more pattern matching. She loves the campfire scenes where all four players' goblins interact with unique multiplayer dialogue. She spends $5-10 on a cosmetic skin after her friends all buy matching caravan themes. She would never play solo -- but she logs in twice a week outside of caravan night to manage her asynchronous trades because she wants to contribute to the group economy.

---

## User Stories

### Exploration

1. As a player (P-006), I want to see price trends for the last 5 days at each town I have visited so that I can make informed trading decisions.
2. As a player (P-002), I want to discover new towns by choosing routes on a visual map so that each travel decision feels meaningful and personal.
3. As a player (P-008), I want to unlock a journal entry for each town that documents its culture, economy, and secrets so that I feel rewarded for thorough exploration.
4. As a player (P-012), I want to see my friends' caravan positions on the world map so that I can plan routes to meet up at the same town.
5. As a player (P-006), I want to encounter random events during travel that offer meaningful choices (not just stat checks) so that each journey feels unique.

### Core Mechanics -- Trading

6. As a player (P-006), I want to see supply and demand indicators for each good at each town so that I can identify arbitrage opportunities before committing my capital.
7. As a player (P-002), I want to sell goods instantly at the current market price with one tap so that I can make progress even when I do not have time to optimize.
8. As a player (P-008), I want to place limit orders that sell my goods automatically when the price reaches my target so that I can execute complex trading strategies while offline.
9. As a player (P-006), I want to see how my trades and other players' trades have shifted prices over time so that I can understand the living economy.
10. As a player (P-008), I want to receive a notification when a rare good appears at a vendor so that I never miss a time-sensitive opportunity.

### Core Mechanics -- Crafting

11. As a player (P-002), I want to queue up to 3 crafting jobs before ending my session so that I make progress even when I am not actively playing.
12. As a player (P-006), I want to see the quality probability breakdown before crafting so that I can decide whether to use fresh ingredients or save them for a higher-value recipe.
13. As a player (P-008), I want to unlock new recipes by discovering ingredient combinations experimentally so that crafting feels like discovery, not a checklist.
14. As a player (P-006), I want ingredient freshness to visibly degrade over time in my inventory so that I am incentivized to use ingredients quickly and plan my supply chain.
15. As a player (P-002), I want a "quick craft" option that automatically uses the freshest ingredients so that I can craft efficiently without managing each slot.

### Core Mechanics -- Crew

16. As a player (P-002), I want each crew member to have visible mood indicators and unique campfire dialogue so that they feel like real companions, not stat blocks.
17. As a player (P-008), I want to track my relationship progress with each crew member on a clear progression bar so that I know exactly how far I am from unlocking their max ability.
18. As a player (P-006), I want crew specialists to gain skill through use (not just XP purchases) so that their growth feels organic and tied to my decisions.
19. As a player (P-002), I want to give crew members gifts that I have crafted or bought so that building relationships is integrated with the trading loop, not a separate system.
20. As a player (P-012), I want my multiplayer crew to have shared campfire scenes with unique dialogue so that co-op feels socially intimate.

### Narrative

21. As a player (P-002), I want Uncle Boggle's journal fragments to reveal story gradually (one per town) so that I am motivated to keep traveling to learn what happens next.
22. As a player (P-006), I want the rivalry with Vex Snarltooth to have multiple resolution paths (reconciliation, competition, or enmity) so that my choices feel consequential.
23. As a player (P-008), I want to see all 6 endings across multiple playthroughs so that the story rewards repeated engagement.
24. As a player (P-002), I want the Frost Crawl crisis event to create dramatic tension without blocking my progress entirely so that I feel challenged, not punished.
25. As a player (P-012), I want multiplayer narrative events that are unique to co-op (e.g., two caravans meeting at a crossroads) so that the story feels different with friends.

### Progression

26. As a player (P-008), I want 127 achievements organized by category (trading, crafting, crew, exploration, story, economy) so that I always have a clear next goal.
27. As a player (P-006), I want festival reputation to persist between playthroughs so that my long-term investment in towns feels meaningful.
28. As a player (P-002), I want a "journey summary" screen at the end of each 60-day run that shows my best trades, favorite crew moments, and total wealth so that the ending feels celebratory.
29. As a player (P-008), I want a recipe mastery system that tracks how many times I have crafted each item so that I can pursue 100% mastery as a long-term goal.
30. As a player (P-006), I want wagon upgrades to persist between journeys so that my mechanical progression feels permanent.

### Accessibility

31. As a player, I want full controller support on all platforms so that I can play comfortably regardless of input preference.
32. As a player, I want color-blind friendly price indicators (shapes and patterns in addition to color coding) so that market data is accessible to all players.
33. As a player, I want adjustable game speed (0.5x, 1x, 1.5x) for all timed elements so that I can play at my own pace.
34. As a player, I want text size options (small, medium, large, extra-large) so that dialogue and market data are readable on all screen sizes.

### Social

35. As a player (P-012), I want asynchronous trading between my caravan and my friends' caravans so that we interact meaningfully even when we cannot play simultaneously.

---

## Monetization

### Revenue Model: Premium Base with Cosmetic DLC

**Why this model fits this game:** Amber Goblin Caravan is a cozy experience built on trust between the player and the game. Energy systems, consumable IAP, or pay-to-skip mechanics would undermine the core fantasy of being a skilled merchant earning every gold coin through savvy. The premium model signals quality and respects the player's time. Cosmetic DLC is additive -- it changes how the wagon looks, not how the game plays -- which preserves economic fairness in multiplayer.

### Pricing Structure

| Product | Price | Content |
|---------|-------|---------|
| Base Game | $24.99 | Full 60-day journey, all 18 towns, all 4 crew members, all recipes, all endings, 127 achievements, online multiplayer |
| Caravan Paint Pack | $2.99 | 5 wagon paint themes (Sunset Gold, Forest Canopy, Midnight Teal, Cherry Blossom, Starfield) |
| Wagon Charm Collection | $4.99 | 12 hanging charms that dangle from the wagon (lucky coin, amber crystal, tiny goblin hat, etc.) |
| Festival Costume Pack | $7.99 | 4 crew member festival outfits (one per season), animated campfire emotes |
| Complete Cosmetic Bundle | $12.99 | All of the above at a 35% discount |

### Revenue Projections (4 Scenarios)

| Scenario | Unit Sales (Year 1) | Base Revenue | Cosmetic Attach Rate | Cosmetic Revenue | Total Revenue |
|----------|--------------------:|-------------:|--------------------:|-----------------:|--------------:|
| Modest (niche success) | 15,000 | $374,975 | 8% | $17,580 | $392,555 |
| Moderate (genre hit) | 45,000 | $1,124,925 | 15% | $101,475 | $1,226,400 |
| Strong (viral cozy hit) | 120,000 | $2,999,800 | 22% | $317,160 | $3,316,960 |
| Breakout (cultural moment) | 350,000 | $8,749,650 | 28% | $1,177,620 | $9,927,270 |

Cosmetic revenue assumes weighted average price of $5.99 across all DLC options. "Modest" assumes 70% of sales at full price, 30% during Steam sales at 30% off.

### Post-Launch DLC Roadmap

| Window | Content | Price | Purpose |
|--------|---------|-------|---------|
| Month 3 | "The Southern Spice Route" -- 6 new towns, 12 new recipes, 2 new crew specialists | $9.99 | Expand the map for returning players |
| Month 6 | "Skizzle's Kitchen" -- cooking-focused DLC with 25 new recipes and a cooking competition event chain | $6.99 | Deepen the most popular mechanic |
| Month 9 | "The Underground Market" -- contraband-focused DLC with smuggling routes, guard evasion, and black market economy | $7.99 | Add risk/reward depth for advanced players |
| Month 12 | "Golvaris Expanded" -- free update with 3 new endings, 20 new random encounters, and 15 new achievements | Free | Reward the community, drive re-engagement |

---

## Production Plan

### Team Composition

| Role | Count | Phase(s) | Monthly Cost (avg) | Duration |
|------|-------|----------|--------------------:|----------|
| Game Director / Lead Designer | 1 | All | $9,000 | 18 months |
| Systems Designer (economy, crafting) | 1 | Pre-prod through Alpha | $7,500 | 14 months |
| Narrative Designer | 1 | Pre-prod through Beta | $7,000 | 12 months |
| UI/UX Designer | 1 | Production through Gold | $6,500 | 10 months |
| 2D Artist (environments) | 2 | Production through Beta | $6,000 each | 10 months |
| 2D Artist (characters, items) | 1 | Production through Beta | $6,000 | 10 months |
| Animator (stop-motion style) | 1 | Production through Beta | $7,000 | 10 months |
| Unity Developer (gameplay) | 2 | Production through Gold | $8,000 each | 14 months |
| Unity Developer (multiplayer, networking) | 1 | Production through Gold | $8,500 | 12 months |
| Audio Designer / Composer | 1 | All (part-time pre-prod, full-time prod+) | $5,000 | 14 months |
| QA Tester | 1 | Alpha through Gold | $4,500 | 6 months |
| Producer / Project Manager | 1 | All | $7,000 | 18 months |

**Total team:** 15 people at peak (production phase). Pre-production is 5-6 people.

### Timeline and Milestones

| Month | Phase | Milestone | Team Active |
|-------|-------|-----------|-------------|
| 1-3 | Pre-Production | Core loop prototype, economy model validated in spreadsheet, art style locked, narrative spine approved | 6 |
| 4-6 | Early Production | 4 towns playable, crafting system implemented (kitchen only), first crew member (Skizzle) functional, wagon customization system operational | 12 |
| 7-9 | Mid Production | All 18 towns in-game, all 4 crew recruitable, full recipe tree (57 recipes), dynamic market economy running, haggling mini-game complete | 15 |
| 10-11 | Late Production | Full narrative implemented (all 6 endings), festival system complete, all 120 random encounters scripted, multiplayer co-op functional | 15 |
| 12 | Alpha | Content complete, all features integrated, first full playthrough possible, internal QA begins | 15 |
| 13-14 | Beta / Polish | Bug fixing, balance pass on economy (2 rounds), accessibility implementation, localization (6 languages: EN, JP, KO, ZH, DE, ES), Switch and PS5 port testing | 13 |
| 15-16 | Certification and Gold | Platform holder certification (Nintendo, Sony), Steam submission, final balance tweaks, day-one patch prepared | 8 |
| 17-18 | Launch and Post-Launch | PC and console launch, day-one patch, community management, first DLC planning begins | 6 |

### Budget Breakdown

| Category | Total Cost | Notes |
|----------|-----------|-------|
| Salaries (18 months, 15 peak staff) | $1,340,000 | Weighted average across phases with ramp-up/ramp-down |
| Art Outsourcing (additional assets, UI polish) | $85,000 | Background detail work, icon sheets, marketing art |
| Audio Outsourcing (orchestral sessions for main theme) | $30,000 | 12-piece folk ensemble for title theme, trailer music |
| Software and Tools (Unity Pro, source control, project management) | $45,000 | Unity Pro licenses ($2,040/seat/year x 15), GitHub Enterprise, Notion, Figma |
| Platform Certification and Dev Kits | $20,000 | Nintendo Switch dev kit ($450), PS5 dev kit ($2,500), certification fees |
| QA and Playtesting | $35,000 | External QA firm for 3-month beta test, playtest group recruitment |
| Localization (6 languages) | $55,000 | 45,000 words of dialogue and UI text |
| Marketing (trailer, conventions, influencer outreach) | $120,000 | Announcement trailer, Steam page optimization, PAX booth, influencer keys |
| Contingency (15%) | $259,500 | Industry standard buffer |
| **Total** | **$1,989,500** | **Rounds to approximately $2M** |

### Break-Even Analysis

At $24.99 per unit with a 70% developer share (Steam standard after 30% platform cut, before publisher split if applicable):

- **Net revenue per unit:** $17.49
- **Break-even units:** $1,989,500 / $17.49 = 113,750 units
- **Break-even timeline:** At the "Moderate" scenario (45,000 units Year 1), the game does not break even in Year 1. However, the "Strong" scenario (120,000 units) covers the budget in Year 1 with a small surplus.
- **DLC revenue** is not included in break-even calculation (conservative assumption).

---

## Technical Requirements

### PC (Steam)

| Spec | Minimum | Recommended |
|------|---------|-------------|
| OS | Windows 10 (64-bit) | Windows 11 (64-bit) |
| Processor | Intel i5-6600 / AMD Ryzen 3 1200 | Intel i5-9600 / AMD Ryzen 5 3600 |
| Memory | 4 GB RAM | 8 GB RAM |
| Graphics | NVIDIA GTX 760 / AMD Radeon R9 280 / Intel HD 530 | NVIDIA GTX 1060 / AMD Radeon RX 580 |
| Storage | 4 GB available space | 6 GB available space (SSD recommended) |
| DirectX | Version 11 | Version 12 |
| Network | Broadband for multiplayer | Broadband for multiplayer |

### macOS

| Spec | Minimum | Recommended |
|------|---------|-------------|
| OS | macOS 12 Monterey | macOS 14 Sonoma |
| Processor | Apple M1 | Apple M2 |
| Memory | 4 GB RAM | 8 GB RAM |
| Storage | 4 GB available space | 6 GB available space (SSD) |

### Nintendo Switch

| Target | Specification |
|---------|--------------|
| Resolution | 1080p docked, 720p handheld |
| Frame Rate | 30 fps locked (both modes) |
| File Size | 3.5 GB |
| Controller | Single Joy-Con, Pro Controller, handheld mode |
| Online | Nintendo Switch Online required for multiplayer |

### PlayStation 5

| Target | Specification |
|---------|--------------|
| Resolution | 4K at 30 fps or 1440p at 60 fps (player choice) |
| File Size | 5 GB |
| DualSense Features | Haptic feedback on haggle gauge, adaptive trigger resistance during travel events |
| Online | PS Plus required for multiplayer |

### iOS

| Target | Specification |
|---------|--------------|
| Devices | iPhone 12 and later, iPad Air (4th gen) and later |
| Resolution | Native device resolution |
| Storage | 2 GB |
| Controls | Touch-optimized UI (larger tap targets, swipe navigation), MFi controller support |

### Android

| Target | Specification |
|---------|--------------|
| Minimum | Snapdragon 750G / Exynos 980 or equivalent, 3 GB RAM |
| Recommended | Snapdragon 870 / Exynos 2100 or equivalent, 6 GB RAM |
| Storage | 2 GB |
| Controls | Touch-optimized UI, Bluetooth controller support |

### Key Technical Challenges and Mitigations

| Challenge | Risk | Mitigation |
|-----------|------|------------|
| **Dynamic economy in multiplayer** -- price calculation must handle concurrent trades from multiple players without race conditions or exploitable delays | High | Server-authoritative economy with deterministic price resolution. All trades batch-processed in 5-second windows. Client shows predicted prices but server confirms actual prices. If prediction differs, the player sees the true price before the trade finalizes. |
| **Stop-motion animation at 12 fps** -- Unity's animation system defaults to smooth interpolation; forcing 12 fps with irregular timing requires custom animation logic | Medium | Custom animation controller that snaps keyframes instead of interpolating. Pre-render character animation frames as sprite sheets (512x512 per frame, approximately 200 unique frames per character). Use Unity's Sprite Library for swappable parts. |
| **Hand-painted art at multiple resolutions** -- 2D painted assets must look crisp on 4K PS5 and readable on 720p Switch handheld | Medium | Source assets rendered at 4K (3840x2160), then downsampled per platform. Switch gets 720p-optimized assets. UI elements use vector-based rendering where possible. Text is always vector. |
| **Cross-platform multiplayer** -- PC, console, and mobile players sharing an economy requires unified server infrastructure | High | Dedicated authoritative server using Unity Netcode for GameObjects with a relay architecture. All platforms connect to the same regional servers. Mobile players share economies with PC players but are matched with other mobile caravans for co-op to prevent input-speed advantages. Asynchronous trading is platform-agnostic. |
| **Save game compatibility across platforms** -- Cross-save between PC and mobile requires consistent serialization | Low | Cloud save system using a platform-agnostic JSON schema. Save data is versioned with migration paths. No binary serialization. Save files average 200 KB uncompressed. |
| **Memory budget on Switch** -- 4 GB shared RAM with 2D painted assets and parallax layers can exceed the approximately 1.5 GB game budget | Medium | Aggressive texture streaming -- only load assets for the current town and adjacent routes. Parallax layers use tiled textures (256x256 repeating) rather than full-screen images. Audio streams from cartridge/storage, not memory. Target: 900 MB peak on Switch. |
