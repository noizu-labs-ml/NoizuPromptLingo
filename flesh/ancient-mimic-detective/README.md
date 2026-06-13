# Ancient Mimic Detective

---

## 1. Title & Genre

| Field | Value |
|-------|-------|
| **Title** | Ancient Mimic Detective |
| **Genre** | Detective Mystery Adventure / Narrative Puzzle |
| **Sub-genre** | Noir Investigation RPG |
| **Engine** | Unity 2023 LTS (2D/3D hybrid with isometric exploration) |
| **Platform Targets** | PC (Steam/GOG), Nintendo Switch, PlayStation 5 |
| **Monetization** | Premium $34.99 base + 3 case DLC at $9.99 each |
| **Rating** | T (Teen) -- Violence, Blood, Mild Language, Disturbing Themes |
| **Target Session** | 45-90 minutes |
| **Total Playtime** | 18-25 hours main story, 35-40 hours completionist |
| **Save System** | Per-case auto-save + manual slots (3 per case) |
| **Languages** | English, Japanese, French, German, Spanish, Portuguese, Korean, Simplified Chinese |

---

## 2. Vision Statement

You are a retired inquisitor dragged back into service in Oakhaven, a decaying port city where mimics have evolved sentience and begun replacing citizens one by one. Your only reliable ally is a friendly mimic chest named Gullet who rides in your satchel and can "taste" objects at crime scenes to distinguish genuine from shape-shifted. Every investigation is a locked-room mystery where the room itself might be alive. The game is a love letter to classic detective fiction wrapped in dark fantasy -- each case is self-contained but threads into a conspiracy about why mimics gained intelligence, what the inquisition buried, and why Gullet chose to betray its own kind for you specifically.

---

## 3. Core Loop

```
                    +------------------+
                    |  CASE INTRO      |
            +-------+  Briefing from   |
            |       |  City Council    |
            |       +--------+---------+
            |                |
            v                v
    +---------------+  +-----------------+
    | CRIME SCENE   |  | INTERROGATION   |
    | EXAMINATION   |  | PHASE           |
    | + Gullet      |  | Interview       |
    |   Tasting     <--+ suspects,       |
    | + Evidence    |  | cross-reference |
    |   Collection  |  | claims          |
    +-------+-------+  +--------+--------+
            |                   |
            v                   v
    +-------------------------------+
    |       DEDUCTION BOARD         |
    |  Pin evidence, link claims,   |
    |  surface contradictions,      |
    |  build accusation case        |
    +---------------+---------------+
                    |
            +-------+--------+
            v                v
    +---------------+  +-----------------+
    | ACCUSATION    |  | CITY TRUST      |
    | PHASE         |  | CONSEQUENCE     |
    | Name mimic,   |--+ Gain/lose trust |
    | present proof |  | Unlock/lock     |
    +---------------+  | future leads    |
                       +-----------------+
```

### Core Loop Breakdown

| Phase | Duration | Player Actions | Systems Engaged |
|-------|----------|----------------|-----------------|
| **Case Intro** | 2-3 min | Watch briefing, receive case file, review victim profile | Narrative, journal |
| **Crime Scene** | 15-25 min | Explore scene, direct Gullet to taste objects (furniture, food, body parts, doorframes), collect physical evidence, photograph anomalies | Mimic Taste Test, Evidence Log |
| **Interrogation** | 15-25 min | Interview 3-6 suspects, ask about whereabouts and relationships, note claims in Interrogation Web UI | Interrogation Web, Trust System |
| **Deduction Board** | 10-15 min | Pin evidence to board, draw connections between testimonies, surface contradictions, formulate accusation | Deduction Board, Journal |
| **Accusation** | 5-10 min | Name suspect, present supporting evidence chain, face consequences of correct/incorrect call | Trust System, Narrative Branches |
| **Consequence** | 2-5 min | Trust adjustment, new leads or locked paths, Gullet commentary on your performance | Trust System, Gullet Relationship |

### Target Session Length

| Session Type | Duration | Content |
|-------------|----------|---------|
| Quick session | 30-40 min | One crime scene sweep + initial interviews |
| Standard session | 60-75 min | Full case phase (scene + interrogation) |
| Deep session | 90-120 min | Complete a case start-to-finish |
| Completionist session | 120+ min | Full case with all optional evidence and side conversations |

---

## 4. Meta Loop

### Session-to-Session Progression

```
Case 1 ──> Case 2 ──> Case 3 ──> ... ──> Case 10 (Finale)
  |          |          |                    |
  v          v          v                    v
Trust +=     Trust      Trust +=            Trust
+10/─15      adjusts    +20/─25             determines
             per        per case            ending
             case       resolution          (3 endings)
```

### Progression Axes

| Axis | What Advances | Max | Impact |
|------|--------------|-----|--------|
| **City Trust** | Correct accusations, careful public statements | 100 | High trust: witnesses cooperate, bonus evidence. Low trust: doors close, mimics adapt faster |
| **Gullet Relationship** | Feeding Gullet rare items, asking about mimic culture | 5 ranks | Higher rank: Gullet's emotional palette expands (more precise taste readings), reveals mimic lore |
| **Inquisitor Reputation** | Case closures, zero false accusations, finding hidden evidence | 5 ranks | Unlocks past case files, inquisition tools, and flashback investigations |
| **Case Journal** | Every case completed | 10 cases | Completing all entries with 100% evidence unlocks the true ending path |
| **Mimic Codex** | Each unique mimic identified and documented | 15 entries | Lore rewards, Gullet comments on each entry, unlocks bestiary gallery |

### Difficulty Progression Across Cases

| Case | Title | Mimics | Suspects | Evidence Items | Gullet Reading Complexity | Trust Swing |
|------|-------|--------|----------|----------------|--------------------------|-------------|
| 1 | The Butcher's Apprentice | 1 | 3 | 8 | Simple (4 emotions) | +/- 10 |
| 2 | The Countess Who Cried Wolf | 1 | 4 | 10 | Simple (4 emotions) | +/- 12 |
| 3 | Stones That Weep | 1 | 4 | 12 | Moderate (6 emotions) | +/- 14 |
| 4 | The Chair at the Table | 2 | 5 | 14 | Moderate (6 emotions) | +/- 15 |
| 5 | A Door With Opinions | 2 | 5 | 16 | Complex (8 emotions) | +/- 16 |
| 6 | The Inquisitor's Shadow | 2 | 6 | 18 | Complex (8 emotions) | +/- 18 |
| 7 | The Replacement Mayor | 3 | 6 | 20 | Complex (8 emotions) | +/- 20 |
| 8 | Gullet's Confession | 2 | 7 | 22 | Full palette (10 emotions) | +/- 22 |
| 9 | The Origin Vault | 3 | 7 | 24 | Full palette (10 emotions) | +/- 25 |
| 10 | The City Itself | 4+ | 8 | 28 | Full palette + deception | +/- 30 |

---

## 5. Game Mechanics

### 5.1 Primary Mechanic: Mimic Taste Test

Gullet is a friendly mimic chest who rides in the player's satchel. At crime scenes and during investigations, the player directs Gullet to "taste" objects -- furniture, food samples, clothing, body parts, doorframes, weapons, documents. Gullet responds in emotional language rather than clinical data.

**How It Works:**

1. Player points at an interactable object and selects "Feed to Gullet"
2. Gullet opens, extends a tongue-like appendage, and samples the object
3. Gullet delivers an emotional response from its vocabulary
4. Player must interpret the emotional response to determine what it means

**Emotional Palette (unlocked by Gullet Relationship rank):**

| Rank | Emotions Unlocked | Example Reading | What It Means |
|------|-------------------|-----------------|---------------|
| 1 (Base) | Sorrow, Lies, Hunger, Comfort | "This tastes like sorrow" | Genuine -- belonged to the victim |
| 1 (Base) | Sorrow, Lies, Hunger, Comfort | "This tastes like lies" | Mimic residue -- a shape-shifted creature touched this |
| 2 | + Confusion, Warmth | "This tastes like confusion" | Touched by multiple mimics -- conflicting residue |
| 2 | + Confusion, Warmth | "This tastes like warmth" | Genuine, and recently handled with care |
| 3 | + Iron, Ash | "This tastes like iron" | The inquisition was here -- old investigation residue |
| 3 | + Iron, Ash | "This tastes like ash" | Something was destroyed here recently |
| 4 | + Memory, Silence | "This tastes like a memory I lost" | Gullet recognizes the mimic -- personal connection |
| 4 | + Memory, Silence | "This tastes like silence" | Nothing -- no residue at all, suspiciously clean |
| 5 (Max) | + Truth, Dread | "This tastes like truth itself" | The object IS a mimic in disguise |
| 5 (Max) | + Truth, Dread | "This tastes like dread" | The mimic who touched this knows you're hunting them |

**Taste Test Constraints:**

| Constraint | Detail |
|-----------|--------|
| Tastes per scene | 8 (base) + 2 per Gullet rank |
| Cooldown between tastes | None (but each taste is final -- no re-sampling) |
| False readings | Gullet never lies, but player misinterpretation is the challenge |
| Cost | None (resource is scene-limited) |

### 5.2 Secondary Mechanic: Interrogation Web

Every suspect provides claims about their whereabouts, relationships, and observations. The Interrogation Web visualizes these claims as nodes connected by lines.

| Element | Detail |
|---------|--------|
| **Claim nodes** | Each statement a suspect makes becomes a node |
| **Tension lines** | When two claims contradict, a red tension line appears between them |
| **Corroboration links** | When two claims support each other, a green link appears |
| **Evidence pins** | Physical evidence can be pinned to claim nodes to confirm or refute them |
| **Hidden contradictions** | On Normal difficulty, all contradictions surface automatically. On Hard, only contradictions involving directly interviewed suspects appear -- cross-referencing requires manual comparison |

**Interrogation Actions:**

| Action | Description | Trust Cost |
|--------|-------------|-----------|
| Ask about whereabouts | Standard question, generates claim node | 0 |
| Present evidence | Show evidence to witness, may trigger new claim or shift demeanor | 0 |
| Accuse subtly | Hint that you suspect them -- may cause nervous behavior or confession | -2 if wrong |
| Press hard | Forceful questioning -- risky but can break reluctant witnesses | -5 if wrong, -1 if right but rude |
| Ask about another suspect | Cross-reference -- generates links between suspect webs | 0 |
| Gullet observation | Gullet watches the suspect and reports emotional state (1 use per interview) | 0 |

### 5.3 Secondary Mechanic: City Trust System

Trust is a 0-100 meter tracking Oakhaven's faith in the inquisition.

| Trust Level | Range | Effects |
|-------------|-------|---------|
| **Revered** | 81-100 | Witnesses volunteer information, bonus evidence spawns, mimics are less cautious (easier to catch) |
| **Respected** | 61-80 | Standard investigation, witnesses cooperative | 
| **Wary** | 41-60 | Some witnesses refuse to talk, evidence is hidden, must earn access |
| **Suspicious** | 21-40 | Most witnesses hostile, must use stealth investigation, bribes required |
| **Hostile** | 0-20 | City actively obstructs, riots possible, mimics emboldened (harder to identify), locked ending path |

**Trust Modifiers:**

| Action | Trust Change |
|--------|-------------|
| Correct mimic identification | +8 to +15 (scaled by case difficulty) |
| False accusation (genuine citizen named) | -15 to -30 |
| Finding all evidence in a case (bonus) | +5 |
| Public statement aligned with truth | +3 |
| Collateral damage during investigation | -5 |
| Helping a citizen with side request | +2 |

### 5.4 Secondary Mechanic: Deduction Board

The Deduction Board is a cork-board interface where the player physically arranges evidence, photos, suspect profiles, and testimony transcripts, drawing string connections between them.

| Feature | Detail |
|---------|--------|
| **Evidence cards** | Physical evidence from crime scenes, each with Gullet's taste reading |
| **Testimony cards** | Key quotes from interrogations |
| **Connection strings** | Player draws connections between cards -- correct connections glow, incorrect ones remain inert |
| **Contradiction markers** | When a connection reveals a contradiction, the board auto-flags it |
| **Accusation trigger** | When enough connections point to one suspect, the accusation option activates |
| **Minimum evidence** | Accusation requires at least 3 connected pieces of evidence pointing to the suspect |

### 5.5 Difficulty Progression Table

| Difficulty | Gullet Readings | Interrogation Web | Trust Sensitivity | Hint System |
|-----------|----------------|-------------------|-------------------|-------------|
| **Story** | Full emotional labels + player-facing tooltips explaining each emotion | All contradictions auto-surfaced, color-coded | Trust loss halved | Gullet suggests next steps |
| **Normal** | Full emotional labels, player interprets meaning | Contradictions auto-surfaced | Standard trust swing | Journal hints available |
| **Hard** | Emotions given as metaphorical riddles ("This tastes like a song half-remembered") | Only direct contradictions shown, cross-suspect links manual | Trust loss 1.5x | No hints, journal factual only |
| **Inquisitor** | Same as Hard + Gullet occasionally withholds readings if Trust is low | Same as Hard + suspect can lie without visual tell | Trust loss 2x | No journal, no map markers |

---

## 6. World Design

### Map Structure

Oakhaven is divided into 6 districts, each with distinct architecture, population, and mimic activity level.

```
                    [THE HARBOR]
                   Sailors, warehouses,
                   fish markets
                       |
    [NOBLE QUARTER]──[CITY CENTER]──[MARKET DISTRICT]
     Estates,          Town hall,     Shops, taverns,
     gardens           inquisition     merchant guilds
                       HQ
                       |
                  [OLD TOWN]────[THE UNDERCITY]
                   Historic,       Sewers, catacombs,
                   crumbling,      abandoned mimic
                   churches        breeding grounds
```

| District | Cases Set Here | Visual Identity | Mimic Density | Key Locations |
|----------|---------------|-----------------|---------------|---------------|
| **City Center** | 1, 7 | Stone civic buildings, clock tower, gas lamps | Low (cases 1-5), High (case 7) | Town Hall, Inquisition HQ, Clock Tower Plaza |
| **Market District** | 2, 5 | Wooden stalls, canvas awnings, narrow alleys | Medium | Butcher's Row, The Waxed Candle tavern, Merchant Guild |
| **Noble Quarter** | 3, 7 | Manicured hedges, iron gates, stained glass | Low (hidden mimics in luxury) | Vance Estate, Countess Morow's Manor, Private Gardens |
| **Old Town** | 4, 6, 8 | Crumbling stone, ivy, candlelit churches | High | Cathedral of St. Dolen, Abandoned Inquisitor's Office, Graveyard |
| **The Harbor** | 5, 9 | Salt-worn wood, fog, creaking ships | Very High | Warehouse 13, Docks, Lighthouse, Smuggler's Tunnels |
| **The Undercity** | 9, 10 | Damp stone, bioluminescent moss, mimic architecture | Maximum | The Origin Vault, Mimic Queen's Chamber, Collapsed Sewer System |

### Art Direction Pillars

1. **Dark Fantasy Noir** -- Oil-painting textures, muted warm tones, deep shadows cast by gaslight
2. **Architectural Decay** -- Every building shows its age; cracked plaster, warped wood, weathered stone. Nothing looks new because nothing is
3. **Living Furniture** -- After the midpoint reveal, players second-guess every chair and chest. Environmental art subtly hints at mimic presence (slightly asymmetrical furniture, drawers that breathe, hinges that blink)
4. **Emotional Color Language** -- Gullet's taste readings are accompanied by color washes: sorrow=deep blue, lies=amber, hunger=crimson, warmth=gold, confusion=violet, iron=gunmetal, ash=charcoal, memory=teal, silence=white, truth=radiant white-gold, dread=black with red edge

### Visual & Audio Progression Table

| Case | Color Palette Shift | Audio Signature | Environmental Tells |
|------|--------------------|-----------------|--------------------|
| 1-2 | Warm amber, honey tones | Lute, soft rain, market chatter | Subtle: furniture proportions slightly off |
| 3-4 | Cooler, steel blue creeping in | Church organ, echoing footsteps, distant bells | Moderate: shadow movement in periphery |
| 5-6 | Desaturated, fog thickening | Dripping water, creaking wood, muted voices | Overt: furniture visibly shifts when unobserved |
| 7-8 | High contrast, noir black-and-white with color accents | Single violin, heartbeat, distant screaming | Aggressive: mimics drop disguise for frames when startled |
| 9-10 | Bioluminescent greens and purples against deep black | Synthesized organic drones, chittering, Gullet humming | Maximum: environment is alive, walls pulse, floors breathe |

---

## 7. Narrative

### Story Spine (8-Point)

| Beat | Case | Story Event |
|------|------|-------------|
| **1. Once upon a time...** | Case 1 | Retired Inquisitor Aldric Thorne lives quietly in the countryside. A letter from Oakhaven's City Council drags him back -- a butcher's apprentice found dead, and the body keeps changing shape after death |
| **2. And every day...** | Cases 1-3 | Aldric establishes his investigation pattern with Gullet. Each case reveals mimics are more organized than anyone knew. The city insists these are isolated incidents |
| **3. But one day...** | Case 4 | Aldric discovers a mimic that was posing as a City Council member. The conspiracy goes higher than street-level replacements. Someone in power is protecting the mimics |
| **4. Because of that...** | Cases 5-6 | Aldric's investigation draws attention. Mimics begin adapting to Gullet's detection -- coating themselves in emotional "decoys." The inquisition's own archives reveal they knew about sentient mimics 20 years ago and suppressed the information |
| **5. Because of that...** | Case 7 | The Mayor is replaced by a mimic mid-investigation. Public panic. Trust system goes volatile. Aldric is framed for a murder he didn't commit |
| **6. Until finally...** | Case 8 | Gullet confesses: it was sent by the Mimic Queen to watch Aldric. It chose to defect because Aldric showed it kindness 20 years ago during the original inquisition. Gullet reveals the location of the Origin Vault |
| **7. And ever since...** | Case 9-10 | Aldric descends into the Undercity to confront the Mimic Queen. Discovery: mimics gained sentience because the inquisition's magical containment sigils degraded. The city built its prosperity on imprisoned, silenced mimics. The Queen demands either freedom or war |
| **8. The moral** | Ending | Trust determines ending: High trust = negotiated coexistence. Medium trust = mimic exile. Low trust = open war with massive casualties. True ending (100% journal) = Aldric reveals the inquisition's original sin and both sides must reckon with shared guilt |

### 7-Axis Tone Spectrum

| Axis | Position | Detail |
|------|----------|--------|
| **Hope <> Despair** | 60% Despair | The city is dying, but individual acts of kindness (including Gullet's choice) prove redemption is possible |
| **Humor <> Gravity** | 75% Gravity | Gullet provides occasional dark humor, but the stakes are real and death is permanent |
| **Clarity <> Ambiguity** | 65% Ambiguity | No character is purely good or evil. The inquisition committed atrocities. The mimics commit murders. Both sides have justification |
| **Action <> Contemplation** | 80% Contemplation | This is a detective game. Violence is rare and always consequential. The dominant verb is "think" |
| **Warmth <> Coldness** | 55% Coldness | Oakhaven is cold and foggy, but warm moments exist in Gullet's loyalty and rare citizen kindness |
| **Order <> Chaos** | 70% Order | The investigation follows structured phases. Chaos creeps in as trust drops and mimics adapt |
| **Familiarity <> Strangeness** | 50/50 | Noir detective tropes are familiar; the mimic twist makes everything uncanny. Chairs might be alive. Trust nothing |

### Character Table

| Character | Role | Age | Motivation | Secret | Appears In |
|-----------|------|-----|------------|--------|------------|
| **Aldric Thorne** | Player character, retired inquisitor | 54 | Wants peace but cannot ignore injustice | Led the original mimic suppression 20 years ago | All cases |
| **Gullet** | Companion mimic chest | Unknown | Loyalty to Aldric, curious about human culture | Was sent by the Mimic Queen as a spy | All cases |
| **Magistrate Sera Voss** | City Council liaison | 47 | Maintain order, protect the city's reputation | Her husband was replaced by a mimic 3 years ago and she hasn't told anyone | Cases 1-8 |
| **Corporal Dren Briggs** | City Watch officer | 31 | Do his job, survive the chaos | Takes bribes from both sides -- humans and mimics | Cases 2, 4, 6, 7 |
| **Countess Isara Morow** | Noble, mimic sympathizer | Appears 40s (actually 200+) | Coexistence between humans and mimics | She IS a mimic who replaced the original countess 180 years ago and has governed well | Cases 3, 5, 7, 10 |
| **The Mimic Queen** | Antagonist/anti-hero | Ancient | Free her kind from underground imprisonment | The inquisition's original sigils were powered by draining mimic consciousness | Cases 8, 9, 10 |
| **Apprentice Fen Calder** | Young inquisitor-in-training | 19 | Prove himself, follow in Aldric's footsteps | Unknowingly has mimic blood -- his grandmother was replaced before his mother was born | Cases 4-10 |
| **Brother Aldwin** | Cathedral archivist | 68 | Preserve truth, even uncomfortable truth | Has known about the mimics' sentience for decades and chose silence over conflict | Cases 4, 6, 8 |

---

## 8. Player Personas

### P-006: Eleanor Vance -- "The Loyal Strategist" (Primary Target)

| Attribute | Assessment |
|-----------|-----------|
| **Fit** | Excellent. Eleanor wants strategic depth, patient gameplay, fair one-time purchases, and no predatory mechanics. Ancient Mimic Detective is premium-only with no microtransactions, deep deduction systems, and rewards careful thought over reflexes |
| **Engagement Pattern** | Morning and evening 90-minute sessions, one full case per day |
| **Spending** | Base game ($34.99) + likely all DLC ($29.97). $65 LTV |
| **Retention Driver** | 10 cases over 10 days of consistent play, then DLC extends to 13 days. Deep enough to replay on Hard for new evidence paths |
| **Risk** | Fixed-income constraint means the $34.99 price point must deliver clear value. Demo/first-case-free could convert her |
| **Predicted Experience** | Eleanor will methodically build her Deduction Board each morning, treat the Interrogation Web as a puzzle system, and appreciate that Gullet never lies -- only her interpretation can fail. She will play on Normal first, then Hard for the intellectual challenge |

### P-003: Hiroshi Tanaka -- "The RPG Addict" (Primary Target)

| Attribute | Assessment |
|-----------|-----------|
| **Fit** | Strong. Hiroshi craves system mastery and 100% completion. The 15-entry Mimic Codex, Gullet relationship ranks, Trust optimization, and 100% journal completion give him clear mastery targets |
| **Engagement Pattern** | 3-4 hour marathon sessions, completing 2-3 cases per sitting |
| **Spending** | Base game ($34.99) + all DLC ($29.97). May buy guide or strategy content. $65 LTV |
| **Retention Driver** | Achievement system with per-case completion metrics, hidden evidence, and the true ending path requiring 100% journal. Theorycrafting optimal Trust paths on Discord/Reddit |
| **Risk** | No live-service or repeatable grind means Hiroshi completes the game in 40 hours and moves on. The DLC cadence must keep up with his consumption speed |
| **Predicted Experience** | Hiroshi will treat the taste system as a mastery challenge -- memorizing the full 10-emotion palette, optimizing Gullet relationship rank before each case, and achieving zero false accusations across all 10 cases |

### P-008: David Park -- "The Achievement Hunter" (Primary Target)

| Attribute | Assessment |
|-----------|-----------|
| **Fit** | Very strong. David wants fair, achievable 100% completion. The game has clear, deterministic achievement paths (find all evidence, identify all mimics, max trust, complete codex) with no RNG gating |
| **Engagement Pattern** | 1-2 hours/day across multiple sessions, rotating with 4-5 other games |
| **Spending** | Base game ($34.99) + all DLC ($29.97). Spreadsheet-ready completion tracking. $65 LTV |
| **Retention Driver** | Per-case achievement breakdown, hidden achievements tied to specific investigation choices, platform-specific achievement infrastructure (Steam achievements, PlayStation trophies, Switch no equivalent but in-game checklist) |
| **Risk** | Bugged achievements would destroy his relationship with the product. QA must be ironclad. Time-limited achievements would also alienate him -- none are planned |
| **Predicted Experience** | David will map every achievement on a spreadsheet before starting, optimize his investigation route per case to hit all evidence nodes, and platinum the game within 3 weeks of purchase |

### P-011: Maria Rodriguez -- "The Commuter Gamer" (Secondary Target)

| Attribute | Assessment |
|-----------|-----------|
| **Fit** | Moderate. Ancient Mimic Detective is PC/console-only, not mobile. Maria cannot play during her commute. However, the 45-minute case phases match her session length if she plays at home, and the save system respects short sessions |
| **Engagement Pattern** | Would play on Switch in docked mode during evenings, 30-45 min sessions |
| **Spending** | Base game only ($34.99) if she plays regularly for months. $35 LTV |
| **Retention Driver** | Per-case save system lets her stop mid-investigation without penalty. The deduction board state persists. No penalty for leaving and returning |
| **Risk** | Not a mobile game -- Maria may never encounter it. The Switch release is her only realistic entry point. Marketing must reach commuter/relaxation gamers on console |
| **Predicted Experience** | Maria plays one investigation phase per evening -- crime scene one night, interrogation the next, deduction the third. The game respects her pace. She never buys DLC unless she finishes the base game and wants more |

---

## 9. User Stories

### Investigation Mechanics (INV)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| INV-001 | As a player, I want to direct Gullet to taste any interactable object at a crime scene so I can determine if it is genuine or touched by a mimic | P-006, P-003 | Gullet responds with correct emotion from current palette rank within 2 seconds of selection. Response appears as text + color wash |
| INV-002 | As a player, I want Gullet's emotional readings to be consistent across the same object on reload so I can trust the system | P-008 | Re-loading a save and re-tasting the same object produces identical emotional response. No RNG in taste readings |
| INV-003 | As a player, I want a limited number of tastes per crime scene so that each choice feels meaningful | P-006 | Scene displays taste counter (8 base + 2 per Gullet rank). Counter decrements on each use. Zero tastes remaining disables the ability |
| INV-004 | As a player, I want to collect physical evidence items by clicking on them so I can build my case | P-003 | Clicking an interactable evidence item adds it to the Evidence Log with name, description, and Gullet reading (if tasted). Evidence persists across saves |
| INV-005 | As a player, I want to photograph anomalies at crime scenes so I can review them on my Deduction Board later | P-008 | Camera mode captures a screenshot of the current view and adds it as a photo card to the board. Minimum 5 photo opportunities per crime scene |
| INV-006 | As a player on Hard difficulty, I want Gullet's readings to be metaphorical rather than literal so the deduction challenge increases | P-003, P-008 | Hard mode replaces "This tastes like lies" with "This tastes like a promise broken at dawn." Same underlying meaning, requires interpretation. Full metaphor table has 3 variants per emotion |

### Interrogation (INT)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| INT-001 | As a player, I want to interview suspects and see their claims appear as nodes on the Interrogation Web so I can visualize contradictions | P-006, P-003 | Each claim generates a visible node in the Web UI. Contradictory claims auto-connect with red tension lines on Normal, manual detection on Hard |
| INT-002 | As a player, I want to present evidence to a suspect and see them react so I can gauge their truthfulness | P-006 | Dragging an evidence card to a suspect portrait triggers a reaction animation (3 variants: calm, nervous, panicked). Nervous/panicked reactions generate new claim nodes |
| INT-003 | As a player, I want to use Gullet once per interrogation to read the suspect's emotional state so I get an additional data point | P-003 | Gullet observation action available once per interview. Returns a single emotion describing the suspect's dominant feeling (not about specific claims -- their overall state) |
| INT-004 | As a player, I want suspects to remember what I asked previously so that re-interviewing them yields different responses | P-008 | Second interview with same suspect unlocks 2-3 new claim nodes based on what evidence the player has collected since last interview. No repeated dialogue |
| INT-005 | As a player, I want to press a suspect hard at the cost of City Trust so I can break a reluctant witness | P-006 | "Press Hard" action available when trust > 20. Succeeds on a 70/30 split based on whether suspect is hiding something. Failure costs -5 trust regardless |

### Deduction & Accusation (DED)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| DED-001 | As a player, I want to arrange evidence cards on a cork board and draw string connections between them so I can build my case visually | P-006, P-003 | Drag-and-drop cards from Evidence Log to cork board. Click-and-drag between cards to draw colored strings. Board state persists across sessions |
| DED-002 | As a player, I want the board to glow when I make a correct connection so I know I am on the right track | P-003 | Connected cards that share a logical link glow gold. Incorrect connections remain inert gray. No penalty for wrong connections |
| DED-003 | As a player, I want the accusation option to activate only when I have sufficient evidence so I cannot guess randomly | P-006 | Accusation button grayed out until minimum 3 evidence cards are connected to a single suspect. Button activates with visual indicator |
| DED-004 | As a player, I want to see the consequences of my accusation immediately so I understand the impact of my decision | P-008 | Post-accusation sequence plays within 30 seconds: correct = mimic reveal animation + trust gain + Gullet celebration. Incorrect = citizen outrage animation + trust loss + Gullet distress |
| DED-005 | As a player, I want a case summary screen after each accusation showing my performance metrics so I can track my mastery | P-003, P-008 | Summary shows: evidence found / total, correct contradictions identified, false accusations, trust change, Gullet relationship change, time spent |

### Trust & World (TRU)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| TRU-001 | As a player, I want the City Trust meter visible in my HUD so I can factor it into my decisions | P-006 | Trust meter displayed as a segmented bar (5 segments matching 5 trust levels) in the top-right corner. Current level label visible at all times |
| TRU-002 | As a player, I want high trust to unlock bonus evidence and cooperative witnesses so I am rewarded for careful investigation | P-003 | At "Revered" trust (81-100), 1-2 additional evidence items appear per crime scene. At "Respected" (61-80), 1 additional item. Below 60, standard evidence only |
| TRU-003 | As a player, I want low trust to lock doors and require alternative investigation methods so the game adapts to my performance | P-006 | At "Suspicious" trust (21-40), 30% of doors in each district are locked. Player must find alternate routes or bribe guards (costs in-game currency). At "Hostile" (0-20), 60% locked |
| TRU-004 | As a player, I want NPC dialogue to change based on trust level so the world feels reactive | P-008 | NPCs have 3 dialogue tiers: cooperative (trust 61+), reluctant (41-60), hostile (0-40). Each tier has unique lines per NPC. No recycled dialogue across tiers |

### Gullet Relationship (GUL)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| GUL-001 | As a player, I want to feed Gullet rare items I find during investigation so I can deepen our relationship | P-003 | Rare items (1-2 per case) can be offered to Gullet. Each feeding advances a 5-point relationship bar by 1. Gullet delivers unique lore dialogue on each rank-up |
| GUL-002 | As a player, I want higher Gullet relationship to unlock new emotional readings so I have incentive to invest | P-008 | Rank 2 unlocks Confusion + Warmth. Rank 3 unlocks Iron + Ash. Rank 4 unlocks Memory + Silence. Rank 5 unlocks Truth + Dread. Unlocked emotions apply retroactively to previously sampled objects in the current case |
| GUL-003 | As a player, I want Gullet to offer unsolicited commentary during investigations so it feels like a living companion | P-006 | Gullet speaks 2-3 unprompted lines per crime scene and 1-2 per interrogation. Commentary is context-aware (references specific evidence, suspects, or trust level) |

### Accessibility & Quality (ACC)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| ACC-001 | As a player, I want to adjust text size and UI scaling so the game is readable on different displays | P-006 | Settings offer 3 text sizes (small, medium, large) and UI scale slider (80%-120%). All text remains readable at all sizes |
| ACC-002 | As a player, I want color-blind friendly alternatives to Gullet's color washes so I can interpret readings without relying on color | P-008 | Settings toggle for "Pattern Mode" -- replaces color washes with distinct visual patterns (dots, stripes, crosshatch, waves, etc.) |
| ACC-003 | As a player, I want full controller support on all platforms so I can play comfortably | P-006, P-011 | All actions mapped to standard controller layout. Interrogation Web, Deduction Board, and Crime Scene navigation fully playable with gamepad |
| ACC-004 | As a player, I want to skip any previously viewed cutscene so replay sessions are not gated by narrative | P-003 | Skip button appears after first viewing. Hold-to-skip for accidental press protection. Skipped cutscenes still log any evidence or claims they contain |

### Narrative & Progression (NAR)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| NAR-001 | As a player, I want each case to be a self-contained mystery with a clear beginning, middle, and end so I feel closure between sessions | P-006, P-011 | Each case has: briefing (beginning), investigation (middle), accusation (end). Case summary screen provides closure. Next case begins with a time-skip bridge |
| NAR-002 | As a player, I want recurring characters to remember my actions so the world feels persistent | P-008 | NPCs reference previous case outcomes in dialogue. Magistrate Voss comments on trust trends. Corporal Briggs adjusts bribery costs based on past interactions |
| NAR-003 | As a player, I want the overarching conspiracy to reveal itself gradually across all 10 cases so I am motivated to continue | P-003 | Each case reveals 1 piece of the conspiracy puzzle (document, flashback, Gullet confession fragment). Full picture only visible after case 8 |
| NAR-004 | As a player, I want 3 distinct endings based on my trust level so my choices have meaningful consequences | P-006 | Ending A (trust 70+): coexistence. Ending B (trust 40-69): exile. Ending C (trust 0-39): war. True ending (100% journal + trust 80+): full truth revealed |
| NAR-005 | As a player, I want a New Game+ mode that carries over Gullet's relationship rank so I can pursue the true ending on a second playthrough | P-003, P-008 | NG+ preserves Gullet rank, unlocks Hard difficulty from case 1, adds 2 hidden evidence items per case, and tracks cumulative journal completion across playthroughs |

### Platform & Performance (PLT)

| ID | Story | Persona | Acceptance Criteria |
|----|-------|---------|---------------------|
| PLT-001 | As a player, I want the game to run at 60fps on minimum spec PCs so my investigation is not interrupted by technical issues | P-006 | Stable 60fps at 1080p/low settings on GTX 1060. Frame drops below 45fps acceptable only during scene transitions |
| PLT-002 | As a Switch player, I want the game to work in both docked and handheld mode so I can play on my TV or during travel | P-011 | Docked: 1080p/60fps. Handheld: 720p/30fps minimum. Touch controls supported in handheld mode for Deduction Board |
| PLT-003 | As a player, I want fast load times between districts so I am not waiting during investigation | P-003 | District transition loads in under 5 seconds on SSD, under 10 seconds on HDD. Case start loads in under 8 seconds |
| PLT-004 | As a player, I want the game to auto-save at every phase transition so I never lose significant progress | P-008 | Auto-save triggers at: case start, crime scene entry, interrogation start, deduction board entry, accusation, case end. Manual save available at any time in non-cutscene state |

---

## 10. Monetization

### Revenue Model

| Revenue Stream | Price | Content | Expected Attach Rate |
|---------------|-------|---------|---------------------|
| **Base Game** | $34.99 | 10 cases, all core systems, 3 endings | 100% |
| **DLC 1: The Lighthouse Keeper** | $9.99 | Side case (bridges cases 5-6), new district (lighthouse), 1 new mimic type | 35% |
| **DLC 2: Inquisitor's Regret** | $9.99 | Prequel case (Aldric 20 years ago), flashback mechanics, origin of Gullet's loyalty | 30% |
| **DLC 3: The Undercity Files** | $9.99 | 2 bonus cases set in Undercity post-campaign, new mimic variants, codex expansions | 25% |
| **Digital Deluxe** | $54.99 | Base game + season pass (all 3 DLC) + digital artbook + soundtrack | 15% of base buyers |

### Revenue Projections (18-Month Window)

| Metric | Conservative | Moderate | Optimistic |
|--------|-------------|----------|------------|
| Base units sold | 25,000 | 60,000 | 120,000 |
| Base revenue | $612,250 (after 30% platform cut) | $1,469,400 | $2,938,800 |
| DLC revenue (weighted avg) | $109,375 | $262,500 | $525,000 |
| Deluxe upgrade revenue | $56,250 | $135,000 | $270,000 |
| **Total Net Revenue** | **$777,875** | **$1,866,900** | **$3,733,800** |

### Justification

The premium model is chosen over F2P because: (a) the target audience (P-006, P-008) explicitly rejects microtransactions and energy systems, (b) the narrative structure requires fixed pacing that live-service monetization would disrupt, (c) detective games historically perform better as premium (Return of the Obra Dinn, Disco Elysium, Pentiment all succeeded at $20-30 price points). The $34.99 price reflects the 18-25 hour runtime and production quality. DLC extends engagement for completionists (P-003, P-008) without fragmenting the core audience.

---

## 11. Production Plan

### Team Table

| Role | Count | Responsibility | Phase |
|------|-------|----------------|-------|
| **Game Director** | 1 | Creative vision, case design, narrative oversight | All phases |
| **Narrative Designer** | 1 | Story spine, dialogue, interrogation scripts, case logic | Pre-production through Alpha |
| **Systems Designer** | 1 | Taste mechanics, Trust system, Deduction Board, difficulty tuning | Pre-production through Beta |
| **Programmers** | 3 | Unity C# development, save system, UI, AI, platform ports | Production through Ship |
| **2D Artists** | 2 | Character portraits, evidence art, UI elements, Deduction Board art | Production through Beta |
| **3D/Environment Artist** | 1 | Isometric scene building, district architecture, lighting | Production through Beta |
| **Animator** | 1 | Character animations, Gullet animations, mimic reveal sequences | Production through Beta |
| **Audio Designer** | 1 | Sound effects, ambient audio, Gullet voice direction | Production through Ship |
| **Composer** | 1 | Original score (30+ tracks), per-district themes, tension music | Production through Ship |
| **QA Lead** | 1 | Test plan, achievement verification, trust system edge cases | Alpha through Ship |
| **QA Testers** | 2 | Playtest, regression, platform-specific testing | Alpha through Ship |
| **Producer** | 1 | Milestone tracking, budget, external contractor coordination | All phases |
| **Total** | **16** | | |

### Timeline (24 Months)

| Phase | Duration | Milestone | Deliverable |
|-------|----------|-----------|-------------|
| **Pre-Production** | Months 1-3 | Vertical Slice | Case 1 fully playable, all systems prototyped, art direction locked |
| **Production 1** | Months 4-9 | Alpha (Cases 1-5) | First half of game playable, all systems functional, placeholder art for later cases |
| **Production 2** | Months 10-15 | Beta (All 10 cases) | Full game playable, all art final, voice acting recorded, trust system fully tuned |
| **Polish** | Months 16-18 | Release Candidate | Bug fixes, performance optimization, platform certification, difficulty tuning |
| **Ship** | Month 19 | Gold Master | Day-1 patch prepared, marketing materials final, press builds sent |
| **Post-Launch 1** | Months 20-22 | DLC 1 + DLC 2 | Lighthouse Keeper (month 20), Inquisitor's Regret (month 22) |
| **Post-Launch 2** | Months 23-24 | DLC 3 + Definitive Edition | Undercity Files (month 24), Definitive Edition bundle |

### Budget Breakdown

| Category | Cost | Notes |
|----------|------|-------|
| **Salaries (16 people x 19 months)** | $1,520,000 | Avg $5,000/person/month (indie rates, remote team) |
| **Voice Acting** | $45,000 | 8 principal actors, 20 hours of dialogue, union rates |
| **Music & Sound** | $60,000 | Original score, sound design, mixing |
| **Art Outsourcing** | $40,000 | Additional environment art, prop art for 6 districts |
| **Software & Tools** | $25,000 | Unity Pro licenses, Perforce, project management, comms |
| **Platform Fees** | $15,000 | Dev kits, certification submissions, age ratings |
| **Marketing** | $80,000 | Trailers, press outreach, influencer seeding, event presence |
| **QA & Testing** | $50,000 | External QA partner, platform compliance testing |
| **Contingency (15%)** | $275,250 | Buffer for scope changes, delays, unforeseen issues |
| **Total Budget** | **$2,110,250** | |

### Break-Even Analysis

| Scenario | Revenue | Budget | ROI |
|----------|---------|--------|-----|
| Conservative | $777,875 | $2,110,250 | -63% (loss) |
| Moderate | $1,866,900 | $2,110,250 | -12% (near break-even with tail sales) |
| Optimistic | $3,733,800 | $2,110,250 | +77% |

Break-even at approximately 85,000 base units sold ($2,083,975 net revenue including DLC attachment). The moderate scenario reaches break-even within 24 months when accounting for long-tail sales and seasonal discounts.

---

## 12. Technical Requirements

### Platform Specifications

| Spec | PC Minimum | PC Recommended | Nintendo Switch | PlayStation 5 |
|------|-----------|----------------|-----------------|---------------|
| **OS** | Windows 10 64-bit | Windows 11 64-bit | Switch OS | PS5 OS |
| **CPU** | Intel i5-8400 / AMD Ryzen 5 2600 | Intel i7-9700K / AMD Ryzen 7 3700X | ARM Cortex-A57 | AMD Zen 2 |
| **RAM** | 8 GB | 16 GB | 4 GB | 16 GB |
| **GPU** | NVIDIA GTX 1060 6GB / AMD RX 580 | NVIDIA RTX 2060 / AMD RX 5700 | Maxwell-based | RDNA 2 |
| **Storage** | 15 GB SSD | 15 GB SSD | 12 GB | 15 GB SSD |
| **Resolution** | 1080p | 1440p | 1080p docked / 720p handheld | 4K |
| **Target FPS** | 60 | 60 | 60 docked / 30 handheld | 60 |
| **Input** | KB+Mouse, Xbox controller | KB+Mouse, Xbox controller | Joy-Con, Pro Controller | DualSense |

### Technical Challenges & Mitigations

| Challenge | Risk | Mitigation |
|-----------|------|-----------|
| **Interrogation Web state complexity** -- 6+ suspects each with 5+ claims, all cross-referenced | Medium | Build the Web as a directed graph data structure. Validate contradictions at claim-insertion time rather than on-demand. Unit test every case's claim web for consistency |
| **Save system integrity** -- mid-case saves must preserve exact Web state, evidence collection state, Gullet taste counter, trust value, and NPC dialogue state | High | Serialize entire case state to JSON on every auto-save. Implement save-file validation on load. QA tests corrupt-save recovery. 3 manual save slots per case prevent single-point failure |
| **Switch performance in handheld mode** -- isometric scenes with dynamic lighting, NPC pathing, and particle effects (mimic reveals) may struggle at 720p/30fps | Medium | Profile handheld performance monthly from Production 1. Reduce particle count and shadow resolution for handheld profile. Use LOD system for NPC detail at distance. Target 30fps lock, not unlocked variable |
| **Localization of emotional language** -- Gullet's metaphor readings in Hard mode rely on English-language wordplay and cultural associations | Medium | Engage localization team in Production 1 (not post-ship). Provide culturalization notes for each emotion metaphor. Allow per-language metaphor replacements that maintain the same interpretive difficulty. Budget $30,000 for 8-language localization |
| **Deduction Board UX across input methods** -- drag-and-drop with mouse is natural; with gamepad it requires cursor emulation; with touch it requires gesture recognition | Medium | Implement 3 input modes: mouse (direct drag), gamepad (virtual cursor with acceleration), touch (tap-to-select, tap-to-place). QA each mode through all 10 cases. No mode is an afterthought -- all three are primary input paths |
| **Narrative branching state tracking** -- 3 endings, trust-dependent dialogue, NPC memory across cases, and NG+ carryover create a large state space | High | Build a centralized Narrative State Manager that tracks: trust, Gullet rank, per-case outcomes, NPC relationship scores, and achievement flags. Every narrative query goes through this single source of truth. Automated test suite validates all 3 endings are reachable from valid state combinations |
| **Memory budget on Switch** -- 4GB shared RAM with 6 districts of environment assets, character models, and UI | Medium | Implement district-level asset streaming. Only the active district and adjacent districts load into memory. UI textures shared across scenes. Target <2.5GB peak allocation on Switch |
| **Achievement system consistency** -- Steam, PlayStation, and in-game achievements must be achievable, deterministic, and bug-free | High | Design achievements with atomic triggers (not compound conditions). Each achievement is a single boolean flag set by one specific event. QA runs automated achievement unlock sweep on every build. P-008 persona (David Park) is the reference user for achievement QA |

---

<npl-block type="reflection">
Correctness: All 12 required sections are present and complete. Every table contains real data with no placeholder values. Personas are referenced by P-ID from the existing library (P-003, P-006, P-008, P-011). User stories are specific, testable, and tagged with persona IDs.

Edge cases: Trust system edge cases (trust = 0 hostile state) are addressed in TRU-003. Save corruption is addressed in the technical challenges section. The 100% journal requirement for the true ending could frustrate players who miss a single piece of evidence across 10 cases -- NG+ mitigates this.

Security: No security concerns for a single-player game design document.

Pitfalls: Budget assumes remote indie team rates which may be low for senior talent in high-cost regions. Conservative revenue scenario is a loss -- the game needs marketing investment to reach the moderate scenario. Switch port adds significant QA burden.

Improvements: Could add a playable prologue / demo case (Case 1 free) as a marketing tool. Could add a hint system toggle for accessibility beyond the 4 difficulty tiers. The DLC cadence assumes team stays intact post-ship -- contractor agreements should be scoped accordingly.

Documentation: This is the documentation.

TODOs: Voice casting not specified. Localization vendor not selected. Platform-specific certification requirements not detailed beyond spec table.
</npl-block>
