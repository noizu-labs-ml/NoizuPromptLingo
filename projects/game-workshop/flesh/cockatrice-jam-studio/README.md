# Cockatrice Jam Studio

**Casual Zen / Rhythm Cooking**

---

## Vision Statement

You are a cockatrice -- half chicken, half dragon, all chef -- piloting a magical food truck across floating sky islands, cooking fantasy dishes by performing rhythm-based minigames synchronized to a chill lo-fi soundtrack. Chop dragon peppers on the beat, stir phoenix broth during sustained melodies, and flambe during crescendos. Serve picky griffins, ravenous minotaurs, and melancholy sphinxes their favorite meals to earn coins, unlock recipes, and unravel the mystery of why the sky islands are slowly sinking. A storybook-illustrated meditation on cooking, music, and the creatures we feed.

**Genre**: Casual zen rhythm-cooking simulation
**Platforms**: PC (Steam), Nintendo Switch, iOS, Android
**Engine**: Unity (URP) -- cross-platform, lightweight rendering, strong mobile and Switch support, shader graph for sky island atmospherics
**Monetization**: Premium $14.99 with recipe DLC packs ($3.99-$5.99 each)
**Rating**: E (Everyone)

---

## Core Loop

```
Choose Island Route → Arrive at Sky Island → Take Customer Orders → Rhythm Cook (chop/stir/plate) → Serve Dishes → Earn Coins + Tips → Unlock Recipes + Upgrades → Plan Next Route → (repeat)
```

**Session target**: 10-25 minutes of self-paced rhythm cooking.

### Loop Detail

1. **Route Planning** -- Each in-game day, choose which floating islands to visit from a route map. Islands have different creature populations, ingredient availability, and difficulty tiers. Harpy Cliffs have great spices but picky customers; Dragon Peaks have premium ingredients but dangerous cooking conditions with ember hazards.
2. **Take Orders** -- Creature customers line up at your truck window. Each shows a speech bubble with their desired dish and a patience meter (visible as a slowly depleting musical note). You can see their preference history if they are a regular.
3. **Rhythm Cook** -- Enter the cooking phase. Each recipe maps to a unique rhythm sequence: dicing dragon peppers requires rapid tapping on the beat; simmering phoenix broth needs sustained hold notes during legato passages; plating involves precision timing during crescendos. The lo-fi soundtrack drives the timing windows.
4. **Serve** -- Slide completed dishes to customers. Accuracy rating (S/A/B/C/D) determines tip multiplier. Serve a griffin its favorite fish dish on-tempo and it does a happy dance. Burn a satyr's order and it plays a sad tune on its pan flute.
5. **Earn** -- Collect coins, tips, and recipe XP. Customer mood and accuracy affect earnings. High-accuracy streaks trigger "Perfect Service" bonus rounds.
6. **Upgrade** -- Spend coins on new recipes, truck decorations, ingredient storage, and cooking station upgrades. Decorations provide passive bonuses (e.g., the Celestial Lantern boosts dessert recipe accuracy by 5%).

---

## Meta Loop

```
Day Cycle Complete → Coins + Recipe XP Earned → Recipe Mastery Ranks → New Recipe Unlocks → Truck Expansion Tiers → New Sky Island Regions Discovered → Story Events Trigger → Rival Cook-Offs → Overarching Mystery Progresses → (repeat across 8 story chapters)
```

### Progression Axes

| Axis | What Grows | How It Feels |
|------|-----------|-------------|
| **Recipes** | Unlock from 8 base recipes to 40+ signature dishes | "My menu is becoming legendary" |
| **Mastery** | Each recipe ranks from Novice to Grandmaster based on accuracy history | "I can cook phoenix broth in my sleep" |
| **Truck** | Expand from cramped counter to flying restaurant with themed rooms | "This started as a cart, now it's a destination" |
| **Reputation** | Island reputation unlocks new routes, rare ingredients, and VIP customers | "Every island knows my name" |
| **Story** | Customer relationships deepen, rival cooks appear, the sinking mystery unfolds | "I need to know what's happening to these islands" |
| **Collection** | Creature codex fills with customer profiles, flavor preferences, and backstories | "I've served every creature in the Skylands" |

### Day Cycle Structure

| Phase | Duration (in-game) | Real Time | Player Action |
|-------|-------------------|-----------|---------------|
| **Morning** | Route selection + ingredient stocking | 1-2 min | Choose 2-3 islands, buy/forage ingredients |
| **Service** | Cook and serve customers at each island | 8-15 min | Rhythm cooking, customer management |
| **Evening** | Upgrade, decorate, review codex | 2-5 min | Spend coins, read story entries, customize truck |
| **Rest** | Day ends, story events may trigger | Auto | Cutscenes, rival challenges, mystery fragments |

---

## Game Mechanics

### Rhythm Cooking System

**Design Philosophy**: Every dish is a song. Cooking is playing music. The player builds muscle memory for recipes the way a musician learns songs -- through repetition that feels meditative, not grindy.

#### Input Types

| Input | Gesture | Recipe Use | Difficulty |
|-------|---------|-----------|------------|
| **Tap** | Press on the beat | Chopping, dicing, cracking eggs | Easy -- visual beat marker |
| **Hold** | Press and sustain through a note | Simmering, reduction, melting | Medium -- must release on time |
| **Slide** | Drag between positions | Stirring, folding, spreading | Medium -- path follows melody contour |
| **Flick** | Quick directional swipe | Tossing, flambeing, garnishing | Hard -- synced to percussive hits |
| **Flourish** | Circular gesture during crescendo | Plating finale, special techniques | Expert -- only on complex recipes |

#### Timing Windows

| Rating | Window (ms) | Score Multiplier | Visual Feedback |
|--------|------------|-----------------|-----------------|
| **Perfect** | +/- 30 | 1.5x | Golden spark, ingredient glows |
| **Great** | +/- 60 | 1.2x | Silver shimmer |
| **Good** | +/- 100 | 1.0x | Soft white pulse |
| **OK** | +/- 150 | 0.7x | Dim flash, no sparkle |
| **Miss** | Outside | 0x | Ingredient wobbles, slight wobble sound |

**No failure state on individual dishes.** Even a fully missed dish gets served (at D rating with sad customer reaction). The game never stops the music or restarts -- every attempt produces a result.

#### Difficulty Scaling

| Tier | Recipes | Input Types | BPM Range | Unlocks At |
|------|---------|-------------|-----------|-----------|
| **Beginner** | 8 base recipes | Tap, Hold | 80-100 | Start |
| **Apprentice** | 12 recipes | Tap, Hold, Slide | 90-110 | Day 5 |
| **Journeyman** | 10 recipes | Tap, Hold, Slide, Flick | 100-120 | Day 12 |
| **Expert** | 8 recipes | All inputs including Flourish | 110-130 | Day 20 |
| **Grandmaster** | 6 signature recipes | All inputs, extended sequences | 120-140 | Post-story |

### Customer Mood System

Every creature customer has preferences, patience levels, and mood that affects tips and story progression.

#### Customer Attributes

| Attribute | Description | Gameplay Effect |
|-----------|------------|-----------------|
| **Favorite Dish** | The one meal that triggers maximum happiness | 2x tip, happy dance animation, story dialogue |
| **Patience** | How long they wait before mood degrades | High patience = slow note drain, low = fast |
| **Mood** | Current emotional state (Happy/Neutral/Impatient/Angry) | Affects tip percentage and story dialogue |
| **Regularity** | How often this customer visits this island | Regulars build relationship, unlock story arcs |
| **Tolerance** | Acceptance of wrong or imperfect dishes | High tolerance forgives wrong order, low = angry |

#### Customer Mood States

| Mood | Tip % | Animation | Story Effect |
|------|-------|-----------|-------------|
| **Delighted** | 200% + bonus coins | Happy dance, leaves a gift | Unlocks story fragment |
| **Happy** | 150% | Satisfied hum, bows | Positive relationship |
| **Content** | 100% | Nods, eats quietly | Neutral |
| **Impatient** | 70% | Taps foot, sighs | Minor relationship drain |
| **Angry** | 30% | Leaves, plays sad tune | Skips story beat for this visit |
| **Enraged** | 0% + truck damage | Storms off, shakes truck | Relationship reset for next 2 visits |

#### Creature Types (18 species across 6 island regions)

| Species | Home Island | Favorite Dish Category | Patience | Special Behavior |
|---------|-----------|----------------------|----------|-----------------|
| **Griffin** | Zephyr Plains | Fish dishes | Medium | Does a soaring dance when delighted |
| **Harpy** | Harpy Cliffs | Spicy aerial cuisine | Low | Sings along to cooking rhythm if you are accurate |
| **Minotaur** | Ironwood Grove | Heavy stews, large portions | High | Struggles adorably with tiny dessert spoons |
| **Satyr** | Moss Dell | Fruity desserts, wine sauces | Medium | Plays pan flute based on your accuracy (happy or sad) |
| **Sphinx** | Starfall Ruins | Elegant, complex dishes | Very Low | Asks riddles about ingredients; correct answer = bonus |
| **Dragon** | Dragon Peaks | Meat, flame-charred | Medium | Accidentally scorches nearby ingredients if kept waiting |
| **Mermaid** | Tidal Shelf | Seafood, kelp-based | Medium | Humming harmonizes with the cooking soundtrack |
| **Goblin** | Ironwood Grove | Anything fried, quantity over quality | Very High | Orders 3 dishes at once, tips in bulk |
| **Treant** | Moss Dell | Salads, herbal infusions | Very High | Falls asleep if you take too long -- no penalty |
| **Phoenix** | Starfall Ruins | Self-immolating dishes, spicy | Low | Reborn from ashes if dish is burned -- tips for the show |
| **Centaur** | Zephyr Plains | Hearty grain bowls, breads | Medium | Stomps hoof on beat if you are in sync |
| **Fairy** | Tidal Shelf | Tiny delicate pastries | Very Low | Multiplies tips with fairy dust if delighted |
| **Ogre** | Dragon Peaks | Massive portions, simple flavors | High | Pats truck affectionately when happy |
| **Siren** | Tidal Shelf | Seafood with musical plating | Medium | Voice boosts accuracy window for next dish if served well |
| **Gnome** | Ironwood Grove | Technically precise dishes | Medium | Rates your plating technique with a score card |
| **Unicorn** | Zephyr Plains | Pure, unprocessed ingredients | Low | Blesses your truck with a temporary accuracy buff |
| **Pegasus** | Starfall Ruins | Light, airy desserts | Medium | Creates a wind gust that tosses ingredients (hazard + opportunity) |
| **Basilisk** | Dragon Peaks | Gaze-cooked eggs, stone-pressed dishes | High | Turns slow customers to stone briefly, buying you time |

### Truck Customization

Decorate the flying food truck with unlockable themes. Decorations are cosmetic with minor passive bonuses.

#### Theme Sets

| Theme | Cost | Visual Style | Passive Bonus | Unlocks At |
|-------|------|-------------|---------------|-----------|
| **Cozy Tavern** | Free (default) | Warm wood, fairy lights, checkered curtains | None | Start |
| **Celestial Diner** | 2,000 coins | Silver surfaces, star-map ceiling, nebula steam | +5% dessert accuracy | Day 8 |
| **Dragon's Belly** | 3,500 coins | Molten metal accents, forge-iron counters | +5% spicy dish tips | Day 15 |
| **Siren's Songboat** | 3,500 coins | Driftwood hull, shell lanterns, wave patterns | +5% seafood accuracy | Day 15 |
| **Garden Kitchen** | 4,000 coins | Living walls, herb canopy, flower beds | Ingredients regenerate 10% faster | Day 20 |
| **Sky Palace** | 5,000 coins | Marble columns, cloud flooring, golden utensils | +10% tips from VIP customers | Post-chapter 4 |
| **Rival's Revenge** | Event reward | Patched-together rival truck parts | +5% accuracy during cook-offs | Rival questline |

#### Cooking Station Upgrades

| Station | Level 1 (Base) | Level 2 (2,000 coins) | Level 3 (5,000 coins) |
|---------|---------------|----------------------|----------------------|
| **Cutting Board** | 4 slots | 6 slots, +5% chop accuracy | Auto-align, +10% chop accuracy |
| **Stove** | 1 burner | 2 burners, +5% simmer hold window | 3 burners, flame color guide |
| **Oven** | Basic | +5% bake timing window | Perfect-time indicator |
| **Plating Station** | Standard | Garnish slot, +5% plating accuracy | Flourish guide overlay |

### Ingredient System

#### Ingredient Categories

| Category | Examples | Sourced From | Used In |
|----------|---------|-------------|---------|
| **Dragon Spices** | Dragon pepper, ember salt, smoke paprika | Dragon Peaks, market | Spicy dishes, flame-cooked |
| **Sky Herbs** | Cloud basil, wind thyme, zephyr mint | Zephyr Plains, foraging | Seasonings, teas |
| **Forest Produce** | Moss mushrooms, ironroot, harpy berries | Ironwood Grove, market | Stews, baked goods |
| **Ocean Catch** | Cloud-koi, starfish scallop, pearl shrimp | Tidal Shelf, fishing | Seafood dishes |
| **Enchanted Staples** | Phoenix egg, basilisk milk, unicorn butter | Special events, VIP rewards | Premium recipes |
| **Basics** | Flour, sugar, salt, oil | Market (cheap, always available) | All recipes |

#### Ingredient Acquisition

| Method | Cost | Availability | Notes |
|--------|------|-------------|-------|
| **Market purchase** | Coins (5-50 per ingredient) | Every morning | Standard stock rotates daily |
| **Island foraging** | Free | During route travel | Tap floating ingredient clusters |
| **Customer gifts** | Free | Random from delighted customers | Rare ingredients, not buyable |
| **Recipe mastery reward** | Free | On rank-up | Guaranteed rare ingredient |
| **Rival cook-off prize** | Free | Winning rival events | Unique ingredient, limited supply |

---

## World Design

### Map Structure

```
The Skylands (hub -- route map view from truck cockpit)
├── Zephyr Plains (Chapter 1) -- Tutorial region, gentle breezes, open skies
│   ├── Windmill Village (first stop, griffins + centaurs)
│   ├── Cloud Fields (ingredient foraging, unicorns)
│   └── The Nesting Spire (story event: first regular customer arc)
├── Moss Dell (Chapter 2) -- Lush floating gardens, sleepy atmosphere
│   ├── Sunpetal Market (satyrs + treants, ingredient bazaar)
│   ├── The Bramble Kitchen (rival cook-off arena)
│   └── The Ancient Oak (story event: the island's song begins fading)
├── Ironwood Grove (Chapter 3) -- Industrial forest, goblin tinkerers
│   ├── Gearwork Grill (goblins + gnomes, technical cooking challenges)
│   ├── The Mole Tunnel (minotaur hangout, heavy portions)
│   └── The Clockmaker's Table (story event: first island begins sinking)
├── Harpy Cliffs (Chapter 4) -- Windy precipices, aerial ingredient routes
│   ├── Stormspire Roost (harpies + pegasus, wind hazard cooking)
│   ├── The Spice Loft (rare spice trading post)
│   └── The Wind Caller's Perch (story event: rival reveals island sinking pattern)
├── Tidal Shelf (Chapter 5) -- Floating reef islands, ocean mist
│   ├── Coral Kitchen (mermaids + sirens + fairies, seafood focus)
│   ├── The Pearl Market (premium ingredient exchange)
│   └── The Deepwell (story event: discover the sinkhole source)
├── Starfall Ruins (Chapter 6) -- Ancient magical ruins, celestial energy
│   ├── The Observatory (sphinx + phoenix, complex recipe challenges)
│   ├── The Star Kitchen (grandmaster recipes unlock here)
│   └── The Astral Gate (story event: the architect behind the sinking)
├── Dragon Peaks (Chapter 7) -- Volcanic islands, extreme cooking conditions
│   ├── Ember Forge (dragons + ogres + basilisks, fire hazard cooking)
│   ├── The Magma Market (rarest ingredients, highest prices)
│   └── The Caldera (story event: the final rival cook-off)
└── The First Island (Chapter 8) -- The original sky island, the source
    ├── The Ancient Kitchen (final cooking challenges, all creature types)
    ├── The Anchor Chamber (story climax: stop the sinking)
    └── The Grand Feast (ending sequence: all creatures gather)
```

### Art Direction

**Visual Pillars**:
- **Hand-drawn storybook** -- Every element looks illustrated with colored pencil and watercolor wash. Menus look like recipe cards. The route map is a hand-drawn chart.
- **Soft watercolor gradients** -- Sky islands float in pastel clouds. No harsh edges. The sky shifts from dawn peach to evening lavender during each day cycle.
- **Creature charm and humor** -- Every creature has delightful animation details: the way a sphinx delicately eats soup, a minotaur wrestling with tiny spoons, a goblin shoveling food with both hands.
- **Musical visual language** -- Beat markers float as musical notes. Ingredient particles pulse to the rhythm. The truck's steam puffs sync to the beat.

**Color Progression by Region**:

| Region | Sky Palette | Ingredient Palette | Mood |
|--------|-----------|-------------------|------|
| Zephyr Plains | Soft blue, white clouds | Green herbs, golden wheat | Peaceful, tutorial warmth |
| Moss Dell | Emerald canopy, filtered gold | Deep green, purple berries | Cozy, dappled shade |
| Ironwood Grove | Bronze gears, copper sky | Metallic herbs, warm brown | Industrial, busy charm |
| Harpy Cliffs | Windy gray-white, sharp blue | Bright orange-red spices | Exciting, vertiginous |
| Tidal Shelf | Turquoise, seafoam, coral pink | Iridescent blues, pearl white | Dreamy, liquid calm |
| Starfall Ruins | Deep indigo, silver starlight | Glowing celestial ingredients | Mysterious, reverent |
| Dragon Peaks | Molten orange, ash gray, lava red | Smoky reds, blackened spice | Intense, dangerous beauty |
| The First Island | All palettes converge to gold | All ingredients available | Triumphant, bittersweet |

---

## Narrative

### Story Spine

1. **Equilibrium**: You are a young cockatrice who inherited a run-down food truck from your grandmother, a legendary sky chef. The truck barely flies. You have three recipes and a dream.
2. **Inciting incident**: On your first day of business, a melancholy sphinx tells you the sky islands are sinking -- slowly, imperceptibly, but measurably. She says your grandmother knew why.
3. **First complication**: Each island has its own song -- a harmonic frequency that keeps it aloft. The songs are fading. Your cooking, when done with rhythm and soul, temporarily restores the song in each island you visit.
4. **Rising action**: As you expand your truck and master recipes, you encounter six rival chefs who also run food trucks in the Skylands. Each has a piece of the puzzle -- fragments of your grandmother's original recipe book that was torn apart and distributed among them.
5. **Midpoint reversal**: Your grandmother was not just a chef -- she was the original Architect who tuned the islands' songs. She created the harmonic recipes that kept the Skylands aloft. When she died, the songs began fading. The recipe book was torn apart not by accident but by the rivals, who each believed they alone could carry on her legacy.
6. **Crisis**: The First Island (source of all sky magic) is weeks from sinking. You must defeat all six rivals in cook-offs to recover the recipe fragments, reassemble the Grand Recipe, and perform the Song of Anchoring at the Caldera. But performing the Grand Recipe requires cooking with every creature in the Skylands present -- they must all want to stay.
7. **Climax**: The Grand Feast. You cook the Song of Anchoring as a 7-minute rhythm masterpiece with every creature type contributing ingredients. The rivals, won over through the cook-off journey, assist on their stations. The music swells. The First Island stabilizes. All the Skylands sing.
8. **Resolution**: The Skylands are saved. Your truck is legendary. The rivals become your fleet. The sphinx, finally satisfied, asks for seconds. Post-game: endless service mode with all recipes and islands unlocked.

### Tone

```
HOPEFUL ●●●●●○○ GRIM
SERIOUS ●●●○○○○ WHIMSICAL
SIMPLE  ●●●●○○○ COMPLEX
GROUND  ●●○○○○○ FANTASTICAL
STATIC  ●●●●○○○ DYNAMIC
```

Warm, charming, and genuinely funny with an undercurrent of bittersweet loss (the grandmother, the fading songs). Never dark. The stakes feel real without ever being threatening. Think Studio Ghibli meets Cooking Mama with a rhythm game soul.

### Rival Characters

| Rival | Species | Specialty | Island | Personality | Fragment Recipe |
|-------|---------|-----------|--------|-------------|----------------|
| **Smokestack** | Dragon | Flame-cooked meats | Dragon Peaks | Gruff, competitive, secretly respects you | Dragon's Breath Stew |
| **Silverbell** | Fairy | Delicate pastries | Tidal Shelf | Perfectionist, condescending, brittle ego | Starshine Souffle |
| **Thornbucket** | Goblin | Fried everything | Ironwood Grove | Chaotic, enthusiastic, surprisingly skilled | Ironwood Fried Feast |
| **Zephyrine** | Harpy | Aerial spice blends | Harpy Cliffs | Dramatic, vain, deeply insecure | Windcaller's Curry |
| **Mossberg** | Treant | Slow-cooked herbal dishes | Moss Dell | Ancient, patient, speaks in riddles | Ancient Root Remedy |
| **Caldwell** | Sphinx | Intellectual haute cuisine | Starfall Ruins | Superior, testing, ultimately fair | Riddle of the Perfect Broth |

---

## Player Personas

### Primary Personas

#### P-002: Sarah Chen -- "The Micro-Gamer" (Primary)

A 35-year-old marketing manager and mother of two who plays in 15-20 minute bursts during nap time and after bedtime. Values fair progression, cute aesthetics, and low-stress gameplay. Spends $10-15/month on games that respect her time.

**Why Cockatrice Jam Studio fits Sarah**:
- Session length matches her play windows perfectly (10-25 min per day cycle)
- Creature customers are designed to be endearing -- she will want to serve them all well
- No energy system, no gacha -- every session makes clear, tangible progress
- The hand-drawn storybook art appeals to her aesthetic sensibility
- Rhythm cooking is satisfying without requiring deep mechanical knowledge
- Premium purchase = no predatory monetization, perfect for a parent's peace of mind

**Sarah's experience**: Plays during nap time and evening wind-down. Gets attached to regular customers (names her favorite griffin "Reginald"). Masters 3-4 recipes deeply rather than unlocking everything. Completes story over 4-5 weeks. Will recommend to mom-friends as "the cute cooking game."

#### P-003: Hiroshi Tanaka -- "The RPG Addict" (Primary)

A 16-year-old completionist who treats every game as a mastery project. Plays 3-4 hours daily. Wants to achieve 100% completion, max every rank, and discover every secret.

**Why Cockatrice Jam Studio fits Hiroshi**:
- 40+ recipes to master from Novice to Grandmaster rank = clear completion targets
- 18 creature types to serve perfectly = codex to fill
- 6 rival cook-offs to win = structured challenge progression
- Grandmaster-tier recipes with 120-140 BPM sequences = skill ceiling worth chasing
- S-rank accuracy on every dish = achievement hunter's dream
- Post-game endless mode with leaderboards = ongoing engagement

**Hiroshi's experience**: Speedruns to unlock all recipes, then systematically grinds each one to Grandmaster rank. Builds spreadsheet of optimal cooking patterns. Achieves 100% codex in ~35 hours. Checks leaderboards. Writes a guide on Steam.

### Secondary Personas

#### P-013: Robert Thompson -- "The Relaxation Player" (Secondary)

A 41-year-old burnt accountant who plays 10-15 minutes nightly to decompress. Wants zero stress, zero decisions, zero timers. Spends money rarely but loyally.

**Why Cockatrice Jam Studio fits Robert**:
- No failure state -- every dish gets served regardless of accuracy
- The lo-fi soundtrack is genuinely calming, designed as background music
- No timers in the hub/route-planning phase; cooking is the only timed element
- Can play one island stop per night (5-8 min) and feel satisfied
- Premium game = no ads, no pop-ups, no interruptions
- The cooking rhythms are meditative rather than stressful at beginner difficulty

**Robert's experience**: Plays one island stop per night before bed. Never advances past Apprentice difficulty recipes voluntarily. Doesn't engage with story but enjoys the ambient charm. Plays for 3-4 months at this pace. Will buy recipe DLC if it stays relaxing.

#### P-014: Emma Wilson -- "The Trend-Chaser" (Secondary)

A 24-year-old social media manager who downloads viral games, plays intensely for 2-4 weeks, then moves on. Never spends money. Discovers games through TikTok and social media.

**Why Cockatrice Jam Studio fits Emma**:
- The hand-drawn art style is screenshot-worthy and shareable
- Creature reactions (happy dances, sad tunes) are TikTok-ready content
- First 3-4 days provide a complete, satisfying gameplay loop
- Premium model means no paywall hitting her on day 3 to drive churn
- The music + cooking combination is a unique hook for short-form video

**Emma's experience**: Plays intensely for 2 weeks, posts 3-4 TikToks of creature reactions and recipe mastery moments. Does not finish the story but generates organic social exposure worth 50+ non-organic customer acquisitions.

#### P-011: Maria Rodriguez -- "The Commuter Gamer" (Secondary)

A 33-year-old graphic designer who plays 30-45 minutes daily during her Buenos Aires metro commute. Needs offline play. Spends under $20 annually.

**Why Cockatrice Jam Studio fits Maria**:
- Full offline support -- no online connection required for any gameplay
- Day cycle (10-25 min) matches her commute perfectly
- Touch controls are natural on mobile (tap, hold, slide, flick)
- No live-service elements that punish offline play
- Art direction appeals to her designer eye

**Maria's experience**: Plays one full day cycle per commute direction. Appreciates the art direction as a fellow designer. Unlocks all islands over 2 months. Buys one DLC recipe pack after 3 months of daily play.

---

## User Stories

### Rhythm Cooking

- **US-001**: As a player, I want each recipe to play like a unique song with its own rhythm pattern, so cooking different dishes feels musically distinct.
- **US-002**: As a player, I want to see my accuracy rating (Perfect/Great/Good/OK/Miss) in real-time as I cook, so I can adjust my timing mid-recipe.
- **US-003**: As a player (Hiroshi), I want a post-recipe breakdown showing accuracy percentage, best streak, and areas where I lost timing, so I can improve my mastery.
- **US-004**: As a player, I want input types (tap/hold/slide/flick/flourish) introduced gradually across the recipe tiers, so I am never overwhelmed by new mechanics.
- **US-005**: As a player (Robert), I want beginner recipes to be completable with 70%+ accuracy using only tap and hold inputs, so I can enjoy cooking without mastering complex gestures.
- **US-006**: As a player, I want the music to continue playing seamlessly even when I miss notes, so the rhythm never breaks and the vibe stays intact.
- **US-007**: As a player, I want every dish to be served regardless of accuracy (no restarts, no failures), so the game never feels punishing.

### Customer Interaction

- **US-008**: As a player, I want creature customers to display visible patience meters (depleting musical notes), so I can prioritize orders strategically.
- **US-009**: As a player, I want regular customers to build a relationship over time (remembering their favorite dishes, unlocking story dialogue), so serving feels personal.
- **US-010**: As a player, I want delighted customers to perform unique animations (griffin soaring dance, minotaur happy headbutt), so high-accuracy cooking feels visually rewarding.
- **US-011**: As a player (Sarah), I want to see a "favorite dish" indicator on regular customers before they order, so I can plan my cooking queue efficiently.
- **US-012**: As a player, I want wrong orders to result in character-appropriate sad reactions rather than generic failure states, so even mistakes feel like part of the story.

### Route Planning and Islands

- **US-013**: As a player, I want to choose my daily island route from a visual sky map, so route planning feels like plotting a journey.
- **US-014**: As a player, I want each island to have a distinct visual identity, ingredient set, and creature population, so every stop feels like a new destination.
- **US-015**: As a player, I want environmental hazards on certain islands (wind gusts on Harpy Cliffs, ember bursts on Dragon Peaks) that affect cooking, so island choice has gameplay consequence.
- **US-016**: As a player, I want the route map to show island stability (sinking speed), so story urgency is visible alongside gameplay planning.
- **US-017**: As a player (Hiroshi), I want a completion tracker per island showing recipes mastered, creatures served, and story fragments found, so I know what is left to 100%.

### Truck Customization

- **US-018**: As a player, I want to visually customize my truck with themed decoration sets, so my truck reflects my personality.
- **US-019**: As a player, I want decorations to provide minor passive bonuses (+5% accuracy, +10% tips), so customization has gameplay weight without being mandatory.
- **US-020**: As a player (Sarah), I want to preview decoration themes before purchasing, so I never regret spending coins on a look I do not like.
- **US-021**: As a player, I want to upgrade cooking stations (cutting board, stove, oven, plating) across three tiers, so progression feels tangible and mechanical.

### Story and Rival System

- **US-022**: As a player, I want to encounter rival chefs who challenge me to cook-offs with special rules, so the story has dramatic tension.
- **US-023**: As a player, I want rival cook-offs to be multi-round competitions where each round features a different recipe, so the challenge tests breadth of skill.
- **US-024**: As a player, I want to recover recipe fragments from defeated rivals that reassemble my grandmother's cookbook, so the rival system serves the narrative.
- **US-025**: As a player, I want customer dialogue to reveal story fragments about the sinking islands, so the narrative emerges naturally from gameplay.
- **US-026**: As a player, I want the Grand Feast finale to be a 7-minute rhythm sequence combining all recipes and creature types, so the climax feels earned and spectacular.
- **US-027**: As a player, I want both rivals and regular customers to appear in the ending sequence, so my relationships throughout the game are acknowledged.

### Progression and Mastery

- **US-028**: As a player, I want each recipe to have a mastery rank (Novice/Apprentice/Journeyman/Expert/Grandmaster) based on cumulative accuracy, so cooking the same dish repeatedly feels like improvement, not repetition.
- **US-029**: As a player, I want recipe mastery to unlock visual flourishes (golden steam, spark effects on Perfect hits), so mastery has visible expression.
- **US-030**: As a player (Hiroshi), I want a post-game endless service mode with online leaderboards (highest single-day earnings, longest Perfect streak), so there is reason to keep playing after 100% completion.
- **US-031**: As a player, I want a creature codex that fills with customer profiles, backstories, and flavor preferences as I serve them, so every creature feels like a character worth knowing.

### Accessibility and Comfort

- **US-032**: As a player, I want a "Zen Mode" that removes timing pressure (no accuracy ratings, no patience meters), so I can enjoy the cooking and music without any stress.
- **US-033**: As a player, I want to adjust audio sync offset to compensate for Bluetooth speaker lag, so rhythm timing is accurate regardless of my setup.
- **US-034**: As a player (Maria), I want full offline play with no online requirement for any feature, so I can play during my subway commute without connectivity.
- **US-035**: As a player, I want full touch control support on mobile with gesture alternatives for every input type, so mobile play is first-class, not ported.

---

## Monetization

### Premium Model ($14.99)

**Why premium**: The game's identity is zen, music, and cooking. Any monetization that introduces pressure (energy systems, timers, paywalls, gacha) shatters the meditative loop. Premium pricing guarantees the complete experience is available from the first session.

| Element | Included in Base | DLC |
|---------|-----------------|-----|
| 8 story chapters, full narrative arc | Yes | - |
| 40+ recipes across 5 difficulty tiers | Yes | - |
| 18 creature types with full codex | Yes | - |
| 6 rival cook-off battles | Yes | - |
| 7 truck decoration themes | Yes | - |
| Grand Feast finale + both endings | Yes | - |
| Post-game endless service mode | Yes | - |
| "Celestial Spice Route" (8 new recipes, new island chain) | - | $5.99 |
| "Deep Sky Kitchen" (6 abyssal recipes, underwater island) | - | $4.99 |
| "Festival of Feasts" (seasonal event recipes, 12 dishes) | - | $3.99 |
| Original soundtrack (30 tracks, lo-fi + orchestral) | - | $7.99 |

### DLC Strategy

Each DLC adds a new island chain (3-5 stops), new creature types (2-3), new recipes (6-12), and a self-contained story that references the main narrative. DLC does not gate base-game completion. All DLC recipes integrate into the post-game endless mode.

### Revenue Projections (conservative, indie + mobile)

| Scenario | Units (Year 1) | Base Revenue (after 30% cut) | DLC Attach (15%) | Total |
|----------|---------------|------------------------------|-------------------|-------|
| Modest | 20,000 | $209,860 | $18,000 | $227,860 |
| Good | 75,000 | $786,975 | $67,500 | $854,475 |
| Strong | 250,000 | $2,623,250 | $225,000 | $2,848,250 |
| Breakout | 1,000,000 | $10,493,000 | $900,000 | $11,393,000 |

**DLC revenue model**: Average DLC price $4.99, 15% attach rate on base purchasers, ~1.5 DLC per purchasing player = ~$7.49 DLC revenue per 15% of base buyers.

### Marketing Strategy

- **Steam Next Fest**: Feature a demo with first 3 in-game days (full tutorial + first rival encounter)
- **Nintendo eShop**: Position alongside Spiritfarer, Overcooked, and Cooking Mama audiences
- **Mobile launch**: Target "New Games We Love" featuring on App Store and Google Play
- **Streamer outreach**: Target cozy game streamers, rhythm game community, and "wholesome games" curators
- **Social media hook**: Creature reaction clips (griffin happy dance, satyr sad pan flute) are designed for TikTok/Shorts shareability
- **Indie showcases**: Day of the Devs, Wholesome Games Direct, Indie World

---

## Production Plan

### Team

| Role | Count | Phase | Cost |
|------|-------|-------|------|
| Game Designer / Director | 1 | All | $85K |
| Unity Developer | 2 | All | $180K |
| Rhythm Systems Engineer | 1 | Phase 1-2 | $95K |
| 2D Artist (characters, UI, environments) | 2 | Phase 1+ | $130K |
| Technical Artist (shaders, VFX) | 1 | Phase 2+ | $80K |
| Animator (creature reactions, cooking gestures) | 1 | Phase 2+ | $70K |
| Composer (lo-fi + orchestral) | 1 (contract) | Phase 2-3 | $30K |
| Sound Designer | 1 (contract) | Phase 3 | $15K |
| Writer | 1 (contract) | Phase 1-2 | $20K |
| QA | 1 | Phase 3+ | $35K |
| Producer | 1 | All | $75K |

### Timeline (16 months)

```
Month 1-3: PRE-PRODUCTION
├── GDD complete, rhythm engine prototype
├── Art style guide (storybook reference, creature designs)
├── Prototype: 1 recipe, 1 creature, 1 island, basic truck
├── Playtest prototype for rhythm "feel" validation
├── Music direction: compose 5 reference tracks for rhythm mapping
└── Team: Designer + Rhythm Engineer + 1 Artist + Producer

Month 4-8: PRODUCTION ALPHA
├── Chapters 1-4 fully playable (Zephyr Plains through Harpy Cliffs)
├── Rhythm cooking system complete across all input types
├── Customer mood system implemented
├── Truck customization framework functional
├── First 3 rival encounters playable
├── 20+ recipes implemented with rhythm mapping
└── Team: Full team onboarded

Month 9-12: PRODUCTION BETA
├── All 8 chapters playable
├── All 40+ recipes, all 18 creature types
├── All 6 rival cook-offs implemented
├── Full narrative arc with Grand Feast finale
├── All truck themes and station upgrades
├── Music fully composed and integrated (30 tracks)
├── Mobile touch controls polished
└── QA begins parallel testing

Month 13-14: POLISH
├── Performance optimization (Switch, mobile targets)
├── Accessibility pass (Zen Mode, audio sync, touch alternatives)
├── Creature animation polish (reaction variety, personality)
├── Rhythm timing calibration across all platforms
└── Console certification prep

Month 15-16: LAUNCH
├── Steam Next Fest demo (Month 14)
├── Steam + Nintendo Switch launch (Month 15)
├── iOS + Android launch (Month 16, after console stability confirmed)
├── Press embargoes, review copies, streamer keys
└── Post-launch patch (week 1 bug fixes, audio sync refinements)
```

### Budget: $615K

| Category | Amount | % |
|----------|--------|---|
| Personnel | $430K | 70% |
| Art/audio outsourcing | $25K | 4% |
| Music composition + sound | $45K | 7% |
| Tools and licenses | $15K | 2% |
| Marketing (PR, events, influencers) | $50K | 8% |
| Console certification (Switch) | $10K | 2% |
| Mobile platform fees | $5K | 1% |
| Contingency | $35K | 6% |

### Post-Launch Roadmap

| Month | Content |
|-------|---------|
| Month 17-18 | Free update: Leaderboards, 2 bonus recipes, photo mode |
| Month 19-20 | DLC 1: "Celestial Spice Route" ($5.99) |
| Month 22-23 | DLC 2: "Deep Sky Kitchen" ($4.99) |
| Month 25-26 | DLC 3: "Festival of Feasts" ($3.99) |
| Month 28+ | Evaluate sequel or expansion based on sales |

---

## Technical Requirements

### PC Specs

| | Minimum | Recommended |
|---|---------|-------------|
| **OS** | Windows 10 | Windows 10/11 |
| **CPU** | Intel i3-6100 / AMD FX-6300 | Intel i5-10600K / AMD Ryzen 5 3600 |
| **GPU** | Intel HD 630 / R7 240 | GTX 1060 / RX 580 |
| **RAM** | 2 GB | 4 GB |
| **Storage** | 2 GB HDD | 2 GB SSD |
| **DirectX** | 10 | 11 |

### Mobile Specs

| | Minimum | Recommended |
|---|---------|-------------|
| **iOS** | iPhone 8+ / iOS 15 | iPhone 12+ / iOS 16 |
| **Android** | Snapdragon 660 / Android 11 | Snapdragon 870 / Android 12 |
| **RAM** | 2 GB | 4 GB |
| **Storage** | 2 GB | 2 GB |

### Console Specs

| Platform | Resolution | FPS | Notes |
|----------|-----------|-----|-------|
| Nintendo Switch (docked) | 1080p | 60 | Full visual effects |
| Nintendo Switch (handheld) | 720p | 30 | Reduced particle effects, maintained rhythm precision |
| Nintendo Switch 2 | 1440p-4K | 60 | Full effects at higher resolution |

### Key Technical Challenges

1. **Audio-latency compensation** -- Rhythm game accuracy depends on consistent audio latency. Must implement configurable audio offset (-200ms to +200ms) with per-platform calibration. Bluetooth audio on mobile requires special handling (typical 100-200ms latency).
2. **Cross-platform rhythm precision** -- Touch, controller, and keyboard inputs have different timing characteristics. Input polling must be unified at the engine level to ensure identical timing windows across platforms.
3. **Mobile touch gesture recognition** -- Slide, flick, and flourish gestures need reliable detection on diverse touch hardware. Must handle edge cases (palm rejection, accidental multi-touch, screen protectors).
4. **Dynamic music system** -- The soundtrack must layer and transition seamlessly based on gameplay state (island arrival, cooking intensity, customer reactions). Implement FMOD or Wwise middleware for adaptive audio.
5. **Switch performance at 30 FPS handheld** -- Handheld mode reduces to 30 FPS but rhythm timing must still feel accurate. Visual beat markers and timing windows must be calibrated separately for 30 vs 60 FPS modes.
6. **Offline play on mobile** -- Full game must run without network connection. No always-online checks, no server-dependent features in the base game.
7. **Creature animation system** -- 18 creature types with 5+ mood states each, plus cooking reaction animations, requires an efficient animation state machine. Use Unity Animator with blend trees for mood transitions.
