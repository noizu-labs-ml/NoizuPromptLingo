# Banshee's Bazaar

## Title and Genre

| Field | Value |
|-------|-------|
| **Title** | Banshee's Bazaar |
| **Genre** | Narrative Adventure / Detective Mystery |
| **Engine** | Unity 2024 LTS (URP) |
| **Platforms** | PC (Steam), Nintendo Switch, PlayStation 5 |
| **Monetization** | Premium $24.99 base, episodic case DLC at $7.99 each |
| **Rating** | Teen (Violence, Mild Language, Alcohol Reference) |
| **Target session** | 45-90 minutes per case segment; full case 3-5 hours |
| **Save system** | Autosave at every scene transition + manual save anywhere |

---

## Vision Statement

Banshee's Bazaar is a noir-fantasy detective adventure set in a supernatural marketplace where banshees sell prophecies, goblins run pawn shops for cursed items, and every stall hides a secret. The player is the only mortal detective licensed to operate in the bazaar -- a liminal space between the living world and the dead, governed by its own ancient trade laws. The game exists to let players feel the thrill of genuine deduction in a world that plays by unfamiliar rules, where the law of the dead clashes with the law of the living, and where every creature you interrogate has centuries of grudges shaping their testimony. The art direction fuses Art Deco verticality with occult marketplace chaos: neon sigil signs buzzing above cramped stalls, spectral fog rolling through iron-girdered arcades, and a color palette that shifts from amber warmth to cold indigo as the player descends deeper into the bazaar's lower wards. It is a game about thinking like a detective in a world that resists being understood.

---

## Core Loop

```
                     ┌──────────────────────────────────────────────┐
                     │                                              │
                     ▼                                              │
              ┌─────────────┐     ┌───────────────┐     ┌──────────────┐
              │  CRIME SCENE │────▶│  INTERROGATE   │────▶│  EVIDENCE    │
              │  INVESTIGATE │     │  WITNESSES     │     │  BOARD       │
              └─────────────┘     └───────────────┘     └──────────────┘
                     │                     │                     │
                     │                     │                     │
                     ▼                     ▼                     ▼
              ┌─────────────┐     ┌───────────────┐     ┌──────────────┐
              │  GATHER      │     │  APPEASE OR   │     │  CONNECT     │
              │  ENCHANTED   │     │  ANTAGONIZE   │     │  CLUES INTO  │
              │  EVIDENCE    │     │  CREATURES    │     │  THEORIES    │
              └─────────────┘     └───────────────┘     └──────────────┘
                                                                  │
                     ┌────────────────────────────────────────────┘
                     │
                     ▼
              ┌─────────────┐     ┌───────────────┐
              │  TRIBUNAL    │────▶│  VERDICT &    │
              │  SHOWDOWN    │     │  CONSEQUENCES │
              └─────────────┘     └───────────────┘
                     │
                     ▼
              ┌─────────────┐
              │  BAZAAR      │
              │  OPENS NEW   │────▶  (return to top with new case)
              │  STALLS      │
              └─────────────┘
```

### Detailed Breakdown

**1. Crime Scene Investigation (10-15 minutes)**
The player arrives at a supernatural crime scene -- a vandalized prophecy stall, a poisoned merchant, a stolen soul-jar. The scene is a point-and-click environment rendered in the bazaar's distinct visual style. The player uses the **Spectral Lens** (a held item that reveals magical traces invisible to the mortal eye) to scan for enchanted evidence. Evidence types include: spectral residue (glowing traces left by supernatural beings), cursed objects (physical items with magical signatures), emotional echoes (replayable ghostly reenactments of recent events), and material clues (mundane items -- a torn scale, a dropped coin, a broken vial). The player photographs and collects up to 12 pieces of evidence per case. Evidence glows with varying intensity based on relevance; the Spectral Lens has a cooldown that prevents brute-force scanning of every pixel.

**2. Witness Interrogation (15-25 minutes)**
The player questions 3-6 supernatural witnesses per case. Each creature has a **disposition matrix** -- a 4-axis system tracking Trust, Fear, Respect, and Irritation. Every dialogue choice shifts these values. Critically, testimony also shifts based on **lunar phase** (the bazaar operates on a 7-day supernatural calendar; on full-moon nights, ghosts speak freely but goblins lie compulsively), **emotional state** (a grieving banshee gives accurate testimony but omits details about loved ones), and **cultural taboos** (asking a selkie about their pelt triggers an automatic refusal and drops Trust by 20 points). The player tracks which taboos each species holds via the **Bestiary Codex**, which grows as the player encounters new creatures.

**3. Evidence Board (10-15 minutes)**
The signature mechanic. The player pins collected evidence to a magical cork board. The board is a 2D node-link diagram where the player physically drags evidence nodes and draws connections between them. When the player draws a correct connection, the enchanted thread between nodes **glows with spectral fire** -- a visceral, unmistakable confirmation. Incorrect connections produce a dim, cold thread that slowly fades. The player constructs **theories** (connected subgraphs of evidence) and the board tracks up to 3 active theories simultaneously. Each theory has a **coherence score** (0-100%) calculated from the strength and number of verified connections.

**4. Tribunal Showdown (15-25 minutes)**
The player presents their case before the **Spectral Tribunal** -- a court of 3 supernatural judges (one each from the Living, the Dead, and the In-Between). A rival prosecutor (a recurring antagonist) argues the opposing case. The tribunal plays as a structured debate: the player selects evidence to present, chooses which witnesses to call, and makes rhetorical choices (logical appeal, emotional plea, supernatural precedent citation). The tribunal evaluates the case on three axes: **Evidential Weight** (how many verified connections support the theory), **Witness Credibility** (how well the player managed disposition matrices), and **Legal Merit** (whether the player correctly applied living law, dead law, or bazaar trade law). The verdict is never binary -- there are 5 possible verdict outcomes ranging from "Full Conviction" to "Mistrial with Prejudice" (the player is fined for wasting the court's time).

**5. Consequences and Bazaar State (5 minutes)**
The verdict permanently alters the bazaar. A convicted merchant's stall closes, and a new vendor takes its place. An acquitted suspect may offer the player a discount or a rare item. A creature the player allied with opens a new information network. A creature the player antagonized spreads rumors that make future interrogations harder. The bazaar is a living ecosystem of 47 stalls across 6 wards, and every verdict shifts the economic and social equilibrium.

---

## Meta Loop

### Session-to-Session Progression

```
Case 1 (Tutorial) ──▶ Case 2 ──▶ Case 3 ──▶ ... ──▶ Case 12 (Finale)
     │                  │           │                      │
     ▼                  ▼           ▼                      ▼
  Unlock Ward 1     Ward 1-2    Ward 1-3              All 6 Wards
  6 stalls          14 stalls   24 stalls              47 stalls
  Bestiary: 3 spp.  +4 species  +5 species            22 species logged
  Rank: Apprentice  Adept       Inspector             Archon Detective
```

**What carries between sessions:**

| Persistent Element | How It Grows | Effect on Gameplay |
|--------------------|--------------|--------------------|
| **Reputation** | Verdicts, creature alliances, tribunal performance | Unlocks higher-tier cases, opens locked stalls, changes how creatures address the player |
| **Bestiary Codex** | Encountering and successfully interrogating new species | Reveals cultural taboos, lunar phase sensitivities, and preferred interrogation approaches before questioning |
| **Evidence Board Skills** | Completing cases unlocks new analysis tools (timeline reconstruction, magical residue dating, cross-case pattern matching) | Later cases have more complex evidence webs; skills prevent the board from becoming overwhelming |
| **Bazaar Map** | Verdicts physically alter the bazaar -- stalls close, open, relocate | Creates a personalized bazaar state unique to each playthrough |
| **Detective's Journal** | Records all case outcomes, moral choices, and creature relationship states | Referenced by NPCs in later cases -- creatures remember past kindnesses and betrayals |
| **Rank** | Earned through case completions and tribunal scores | Gate for case difficulty; higher ranks unlock harder optional cases |

**Progression Axes:**

1. **Knowledge** -- The player learns the supernatural world's rules. Early cases teach one creature type at a time; later cases layer multiple species with conflicting taboos and overlapping testimonies. Growth feels like genuine understanding, not stat increases.

2. **Reputation** -- The bazaar's creatures develop opinions about the player. A detective who consistently acquits goblin merchants earns goblin allies but loses banshee trust. Growth feels like building (or burning) real relationships.

3. **Skill** -- The evidence board mechanics deepen across 12 cases. Case 1 has 6 evidence nodes with 3 correct connections. Case 12 has 18 evidence nodes, 14 correct connections, 3 red herrings, and cross-case evidence from previous investigations. Growth feels like mastering a genuine craft.

---

## Game Mechanics

### Primary Mechanic: The Cursed Evidence Board

The evidence board is the game's intellectual core -- the mechanic the entire case structure serves.

**Inputs:**
- Physical evidence gathered from crime scenes (max 12 per case, typically 8-10 relevant)
- Witness testimony excerpts (2-4 per witness, captured as written statements in the journal)
- Forensic analysis results (unlocked at the board; e.g., "spectral residue matches Class III apparition")
- Cross-case evidence (in cases 6+, evidence from previous cases can be linked to current theories)

**Outputs:**
- **Verified connections** -- Glowing threads between two evidence nodes that confirm a factual link
- **Theories** -- Named subgraphs of 3+ connected nodes that propose a narrative explanation
- **Contradictions** -- When two verified connections produce logically incompatible conclusions, the board highlights the conflict in red, forcing the player to choose which thread to trust
- **Confidence rating** -- Each theory displays a coherence score: the percentage of its connections that are verified vs. unverified

**Constraints:**
- The board has a **thread budget** of 20 connections per case. The player can draw more, but each additional unverified thread above 20 costs a "focus charge," a limited resource (8 per case) that also powers the Spectral Lens. This creates a genuine decision: scan more evidence or draw more connections?
- **Red herrings** -- Each case includes 1-3 pieces of evidence that seem relevant but are unrelated. Connecting a red herring to a theory reduces its coherence score. Red herrings can only be identified by cross-referencing with witness testimony that explicitly debunks them.
- **Temporal decay** -- Some evidence degrades over the in-game day/night cycle. Spectral residue fades after 2 in-game nights; emotional echoes distort after 3 nights. The player can "preserve" evidence by photographing it before it decays, but the photograph has lower evidential weight than the original.

**Edge Cases:**
- If the player presents a theory with coherence below 40% at the tribunal, the rival prosecutor will dismantle it in a scripted humiliation sequence. The player can still recover by improvising with supplementary evidence, but the tribunal's patience drops.
- If the player connects all evidence nodes in a single massive theory, the coherence score tanks because the theory lacks specificity. The game rewards **multiple focused theories** over one omnibus theory.
- If the player has no verified connections at all (pure guessing), the board enters a "fog of uncertainty" state where all threads appear equally dim, giving no feedback. This is the failure state -- the player must return to investigation.

**Skill Ceiling:**
A master player can complete Case 12 with 95%+ coherence on a single theory, having identified all red herrings, preserved all degradable evidence, and connected cross-case patterns from previous investigations. A first-time player will likely present 2-3 competing theories at 60-70% coherence and rely on strong tribunal rhetoric to compensate. The system rewards both approaches but acknowledges the difference in the final case rating (bronze, silver, gold, or spectral platinum).

### Secondary Mechanics

**1. Spectral Interrogation System**
Each of the 22 creature species in the bazaar has a unique interrogation profile:

| Species | Trust Builders | Trust Killers | Lunar Sensitivity | Taboo |
|---------|---------------|---------------|-------------------|-------|
| Banshee | Acknowledge grief, offer silence | Rush testimony, dismiss wails | +Accuracy during full moon | Never ask about their death |
| Goblin | Haggle, respect their craft | Condescend, threaten legal action | -Accuracy during new moon (paranoid) | Never touch their merchandise |
| Selkie | Speak of the sea, offer fish | Mention pelts, ask about land life | Neutral | Never ask about their other skin |
| Wraith | Show no fear, address directly | Show pity, offer "peace" | +Eloquence during waning moon | Never suggest they "move on" |
| Djinn | Speak in riddles, offer fair trade | Demand literal truth, use binding words | +Cooperation during crescent | Never ask their true name |
| Golem | Be patient, use simple language | Rush them, use complex legal terms | Neutral | Never ask "what are you" |
| Vampire | Show respect for age, offer vintage | Mention sunlight, garlic cliches | +Honesty during blood moon | Never ask who they feed on |
| Kobold | Be informal, share food | Act superior, ignore their space | +Loyalty during new moon | Never enter their den uninvited |
| Siren | Listen actively, be vulnerable | Cover ears, resist their song | +Compulsion during full moon | Never ask them to be silent |
| Phoenix | Discuss cycles, accept impermanence | Express fear of death, ask for favors | +Clarity during solar flare events | Never ask them to remember their past life |

(12 additional species follow similar profiles, revealed through gameplay.)

The interrogation system uses a **branching dialogue tree** with 3-5 depth levels. Each node presents 3 choices: a neutral probe, a trust-building approach, and a risk option (high reward if it matches the creature's profile, high penalty if it violates a taboo). The player can exit an interrogation at any time and return later with improved disposition if they've gathered new evidence or learned new taboos from the Bestiary.

**2. Lunar Calendar System**
The bazaar runs on a 7-day supernatural calendar where each day has a distinct lunar phase:

| Day | Phase | Effect |
|-----|-------|--------|
| 1 | Waxing Crescent | Goblin prices +15%, Banshees reluctant to speak |
| 2 | First Quarter | Baseline -- no modifiers, best day for initial investigations |
| 3 | Waxing Gibbous | Spectral residue evidence lasts 1 extra night |
| 4 | Full Moon | Ghosts speak freely; goblins lie compulsively; selkies grow restless |
| 5 | Waning Gibbous | Wraith eloquence increased; tribunal leans toward dead law |
| 6 | Last Quarter | Evidence board connections glow brighter (easier to verify) |
| 7 | New Moon | Goblin paranoia peaks; golems move faster; djinn at their most cooperative |

The player can choose when to investigate, when to interrogate, and when to present at tribunal -- timing is a strategic resource. Rushing to tribunal on Day 5 when the dead-law judge is empowered may backfire if the evidence favors living-law arguments. Waiting for Day 6 to verify connections means risking evidence decay.

**3. Tribunal Rhetoric**
The tribunal showdown uses a **card-based rhetoric system**. The player builds a "case deck" of 10 cards drawn from:
- Evidence cards (1 per verified connection, showing the connection and its strength)
- Witness cards (1 per cooperative witness, showing their credibility score)
- Precedent cards (unlocked by studying bazaar law in the Codex; allow citing historical cases)
- Rhetoric cards (gained through reputation; include "Logical Appeal," "Emotional Plea," "Supernatural Citation," "Cross-Examination")

The rival prosecutor plays their own deck. The tribunal is a turn-based debate where each side plays one card per turn. The judges respond differently to each card type -- the Living judge favors logic and material evidence, the Dead judge favors witness testimony and emotional weight, and the In-Between judge favors precedent and supernatural law. The player must read the judges' reactions and adapt their card play to secure a majority.

### Difficulty Progression Table

| Case | Wards | Evidence Nodes | Correct Connections | Red Herrings | Species in Case | New Mechanics Introduced |
|------|-------|---------------|--------------------:|-------------:|----------------:|-------------------------|
| 1 | 1 | 6 | 3 | 0 | 2 (Banshee, Goblin) | Crime scene scanning, basic interrogation, evidence board basics |
| 2 | 1 | 8 | 4 | 1 | 3 (+Selkie) | Taboo system, lunar calendar awareness |
| 3 | 1-2 | 8 | 5 | 1 | 3 (+Wraith) | Evidence decay, preservation mechanic |
| 4 | 2 | 10 | 6 | 1 | 4 (+Djinn) | Tribunal rhetoric cards, precedent research |
| 5 | 2 | 10 | 7 | 2 | 4 | Multiple competing theories required |
| 6 | 2-3 | 12 | 8 | 2 | 5 (+Golem) | Cross-case evidence linking |
| 7 | 3 | 12 | 9 | 2 | 5 | Rival prosecutor escalates with counter-theories |
| 8 | 3-4 | 14 | 10 | 2 | 6 (+Vampire) | Tribunal can reject insufficient cases |
| 9 | 4-5 | 14 | 11 | 3 | 6 | Evidence can be planted by suspects |
| 10 | 4-5 | 16 | 12 | 3 | 7 (+Kobold) | Multi-scene crimes (2 crime scenes per case) |
| 11 | 5 | 16 | 13 | 3 | 7 | Player can be framed; must clear own name |
| 12 | 6 | 18 | 14 | 3 | 8 (+Siren, Phoenix) | Grand conspiracy linking all previous cases |

---

## World Design

### Map Structure

The bazaar is organized as a **hierarchical hub** with 6 wards stacked vertically, connected by enchanted escalators and spectral elevators. Each ward has a distinct architectural identity:

```
                        ┌─────────────────────┐
                        │   WARD 6: THE SPIRE  │
                        │   Tribunal Hall      │
                        │   3 stalls (law firms)│
                        │   Art: Cathedral Gothic│
                        │   meets Art Deco     │
                        ├─────────────────────┤
                        │   WARD 5: HIGH ARCANE│
                        │   Banshee prophecy halls│
                        │   Djinn consultation tents│
                        │   8 stalls           │
                        │   Art: Silk drapes,  │
                        │   floating lanterns  │
                        ├─────────────────────┤
                        │   WARD 4: MERCHANT ROW│
                        │   Goblin pawn shops  │
                        │   Vampire antiquaries │
                        │   10 stalls          │
                        │   Art: Neon sigils,  │
                        │   iron girders, fog  │
                        ├─────────────────────┤
                        │   WARD 3: THE TRENCHES│
                        │   Kobold warrens     │
                        │   Golem workshops    │
                        │   9 stalls           │
                        │   Art: Underground,  │
                        │   steampunk pipes    │
                        ├─────────────────────┤
                        │   WARD 2: MIDWAY     │
                        │   Selkie import docks│
                        │   Phoenix crematorium│
                        │   9 stalls           │
                        │   Art: Canal-side,   │
                        │   bioluminescent     │
                        ├─────────────────────┤
                        │   WARD 1: GROUND FLOOR│
                        │   Player's office    │
                        │   Siren tavern       │
                        │   General market     │
                        │   8 stalls           │
                        │   Art: Noir alley,   │
                        │   rain-slicked stone │
                        └─────────────────────┘
```

### Art Direction Pillars

1. **Noir-Fantasy Fusion** -- High-contrast lighting (deep shadows cut by neon sigil-glow), rain-slicked cobblestone rendered in 2.5D isometric perspective, fog as a narrative device (thicker fog = older, more dangerous secrets).

2. **Vertical Commerce** -- The bazaar is stacked, not spread. Iron catwalks, rope bridges, and enchanted escalators connect stalls at different heights. Merchants hang signs that glow with species-specific runes. The verticality reinforces the social hierarchy: the cheap stalls are below, the powerful are above.

3. **Living Marketplace** -- Stalls are not static. Merchants shout, haggle, argue. Background NPCs conduct their own supernatural commerce. The bazaar has a day/night cycle (different from the lunar calendar) that shifts ambient activity: bustling during "day" (spectral noon), eerily quiet during "night" (the witching hour, when only the bravest merchants stay open).

4. **Evidence as Light** -- Magical evidence glows. The crime scenes are darker than the surrounding bazaar, and the player's Spectral Lens is a literal light source. Correct connections on the evidence board produce warm amber glow; incorrect connections produce cold blue shimmer. Light is the visual language of truth.

### Visual and Audio Progression

| Case Range | Visual Palette | Audio Palette | Ambient Mood |
|------------|---------------|---------------|--------------|
| 1-3 | Amber, warm gold, cream | Jazz trio (piano, bass, brushes), soft rain | Comfortable noir -- the player is learning the rules |
| 4-6 | Teal, copper, deep green | Adding spectral choir undertones, distant bells | Uneasy alliance -- the bazaar's politics deepen |
| 7-9 | Indigo, rust, cold silver | Industrial percussion, dissonant strings | Threatening -- the conspiracy emerges, allies become suspects |
| 10-12 | Deep violet, bone white, spectral cyan | Full orchestra with electronic distortion, heartbeat bass | Existential dread -- the case challenges the player's moral foundation |

---

## Narrative

### Tone Spectrum (7-Axis)

| Axis | Position (1-7) | Description |
|------|:--------------:|-------------|
| Humor vs. Gravity | 4 | Balanced: dry wit in interrogations, gravitas in tribunal |
| Hope vs. Despair | 3 | Leaning hopeful: justice is achievable but costly |
| Order vs. Chaos | 5 | Leaning chaotic: the bazaar resists neat resolutions |
| Rational vs. Mystical | 4 | Balanced: deduction works, but so does reading bones |
| Intimacy vs. Epic | 3 | Leaning intimate: personal stakes over world-saving |
| Fast vs. Contemplative | 6 | Leaning contemplative: thinking is the gameplay |
| Light vs. Dark | 5 | Leaning dark: noir aesthetics, morally gray outcomes |

### 8-Point Story Spine

**1. Equilibrium**
The player, Detective Maren Voss, is the only mortal licensed by the Spectral Tribunal to investigate crimes in the bazaar. She works from a cramped office on Ward 1, taking minor cases -- stolen trinkets, petty fraud between goblin merchants. She is tolerated by the bazaar's creatures but not trusted. The bazaar operates in uneasy peace under the Tribunal's three-judge system.

**2. Inciting Incident (Case 1)**
A banshee prophecy merchant is found murdered in her stall on Ward 5 -- the first killing in the bazaar in 200 years. The Tribunal summons Maren. The crime scene reveals spectral residue from an unknown species, something not recorded in any bestiary. The player investigates, interrogates witnesses, and discovers the killer is a goblin merchant with a 300-year grudge. But during the tribunal, the goblin claims he was framed by a "smiling man" -- a figure no other witness can confirm.

**3. First Complication (Cases 2-3)**
Two more cases follow, each seemingly unrelated: a selkie's stolen pelt, a wraith's desecrated grave. In both, a witness mentions the "smiling man." Maren's evidence board begins showing cross-case connections -- the same rare spectral residue, the same pattern of evidence planted to mislead. The bazaar's creatures grow uneasy. Some refuse to speak. The Tribunal pressures Maren to close cases quickly, regardless of the smiling man.

**4. Rising Action (Cases 4-6)**
The cases escalate. A djinn's binding contract is broken, unleashing minor chaos across Ward 4. A vampire antiquarian is found with a soul-jar containing someone else's memories. Maren discovers the smiling man is real -- he is a **Fetch**, a mirror-dwelling entity that can impersonate any creature. The Fetch is systematically destabilizing the bazaar's trade networks to collapse the Tribunal's authority. Maren realizes her license was granted not because she was qualified, but because the Tribunal needed a mortal investigator who would be legally powerless to stop a supernatural conspiracy.

**5. Midpoint Reversal (Case 6)**
Maren presents her Fetch theory to the Tribunal. The Dead-law judge dismisses it as mortal paranoia. The Living-law judge is sympathetic but outvoted. The In-Between judge -- the swing vote -- reveals they have been secretly communicating with the Fetch. The Tribunal is compromised. Maren is stripped of her license and banished from the bazaar. The player loses access to Wards 3-6. Only the creatures Maren befriended in earlier cases can help her now.

**6. Crisis (Cases 7-9)**
Operating illegally, Maren relies on creature allies to smuggle her into the lower wards. Cases 7-9 are "underground" investigations -- crime scenes she accesses through secret passages, witnesses who risk Tribunal punishment to speak with her. The cases reveal the Fetch's goal: it wants to shatter the boundary between the bazaar and the living world, creating a permanent merger where supernatural commerce overtakes mortal cities. The evidence points to a specific ritual site beneath Ward 6. But to present this case, Maren needs to reconvene the Tribunal -- which requires proving the In-Between judge's corruption.

**7. Climax (Cases 10-11)**
Case 10 is a multi-scene investigation across all 6 wards. Case 11 is the frame-up: the Fetch impersonates Maren and commits a crime, turning the bazaar against her. The player must clear their own name using evidence from every previous case, calling every creature ally they've built across the game. This is the evidence board's ultimate test -- a 25-node conspiracy map linking 11 cases. The tribunal is reconvened with a replacement In-Between judge (selected based on the player's creature alliances throughout the game).

**8. Resolution (Case 12)**
The final case is the raid on the ritual site. The player investigates the Fetch's lair, confronts it in a tribunal showdown where the Fetch serves as its own defense attorney, and presents the full conspiracy. The verdict determines the ending:
- **Full Conviction** (gold/platinum case rating): The Fetch is banished. The bazaar's boundary is reinforced. Maren is offered permanent residency -- she can stay as an equal citizen, not just a licensed visitor.
- **Partial Conviction** (silver): The Fetch is contained but not destroyed. The bazaar is damaged but rebuilding. Maren keeps her license but the Tribunal's authority is weakened.
- **Mistrial** (bronze): The Fetch escapes. The bazaar enters a state of cold war. Maren remains but must watch the shadows for the smiling man's return.

### Key Characters

| Character | Role | Theme | Cases Active | Fragment Count (collectible lore) |
|-----------|------|-------|:------------:|:--------------------------------:|
| Maren Voss | Player character / Detective | Mortal perseverance in an immortal world | 1-12 | 0 (player discovers her backstory through environment) |
| Grimjaw | Goblin pawnbroker, Ward 4 | Commerce as identity; survival through cunning | 1-12 | 12 fragments (centuries of goblin history) |
| Lady Aisling | Banshee prophecy merchant, Ward 5 | Grief as commodity; the weight of knowing the future | 1, 4, 7, 10, 12 | 8 fragments (prophecies that came true) |
| Corvus | Wraith informer, Ward 3 | Unfinished business; the inability to let go | 2, 5, 8, 11 | 10 fragments (memories of the living world) |
| Zephyr-ith | Djinn legal consultant, Ward 5 | Freedom vs. obligation; the nature of contracts | 3, 6, 9, 12 | 7 fragments (wish history across millennia) |
| The Fetch | Antagonist, mirror-dwelling shapeshifter | Identity as illusion; the danger of being unseen | Referenced 1-5, active 6-12 | 15 fragments (mirror-glimpses of its true form) |
| Magister Thorn | In-Between Tribunal Judge, Ward 6 | Compromise as corruption; the cost of neutrality | 1-6 (ally), 6-9 (antagonist), 10-12 (absent) | 5 fragments (correspondence with the Fetch) |
| Rek | Kobold runner, Ward 3 | Loyalty tested by survival; found family | 4, 7, 9, 11, 12 | 9 fragments (kobold oral tradition) |
| Selene | Selkie dockworker, Ward 2 | Belonging vs. freedom; the cost of dual identity | 2, 5, 8, 12 | 6 fragments (songs of the sea) |
| Ashworth | Phoenix crematorium operator, Ward 2 | Cyclical existence; wisdom through repeated death | 3, 6, 10, 12 | 11 fragments (memories of past lives) |
| Valdris | Vampire antiquarian, Ward 4 | The weight of accumulated time; beauty as survival | 5, 8, 11 | 8 fragments (art collected across centuries) |

Total collectible fragments: 91, distributed across the bazaar as hidden lore objects. Collecting all fragments for a character unlocks an extended epilogue scene for that character in the finale.

---

## Player Personas

### P-003: Hiroshi Tanaka -- "The RPG Addict"

**Why this game fits:**
Hiroshi treats every game as a mastery project. Banshee's Bazaar offers 22 creature species to master, 91 lore fragments to collect, a 12-case campaign with platinum ratings to chase, and a Bestiary Codex that functions as a completion tracker. The evidence board's skill ceiling -- building single high-coherence theories across 18 nodes with cross-case links -- provides the kind of deep system mastery Hiroshi craves.

**Predicted experience:**
Hiroshi will obsess over the evidence board, treating it like a build optimizer. He will theorycraft optimal interrogation approaches for each species and share them on Discord. He will replay cases to achieve platinum ratings, experiment with different creature alliances to see all endings, and complete every fragment in the Bestiary. He will skip nothing. He will be frustrated if any achievement is locked behind a single narrative choice that requires replaying the entire game rather than a specific case.

### P-006: Eleanor Vance -- "The Loyal Strategist"

**Why this game fits:**
Eleanor wants systems she can master over months. The lunar calendar is a strategic layer she can plan around. The interrogation disposition matrices reward patience and observation -- exactly the skills she honed over decades of Civilization play. The premium model with no microtransactions aligns perfectly with her fixed-income, anti-predatory-design values. The contemplative pace respects her 2-3 hour play sessions.

**Predicted experience:**
Eleanor will play methodically, one case per session, taking notes on paper alongside the in-game journal. She will study the lunar calendar and plan her tribunal timing days in advance. She will be deeply engaged by the moral ambiguity of the verdicts -- she treats every decision as a ethical puzzle, not just a mechanical one. She will form strong attachments to specific creatures (likely the banshees and the phoenix) and play to protect them even when it hurts her case rating. She will recommend the game to her bridge group.

### P-008: David Park -- "The Achievement Hunter"

**Why this game fits:**
David needs fair, completable achievement systems. Banshee's Bazaar's rating system (bronze through spectral platinum) per case provides clear completion targets. The 91 lore fragments are trackable collectibles. The Bestiary Codex completion is a natural achievement. The episodic DLC structure means new achievements arrive in predictable batches. No RNG-based achievements, no time-limited events.

**Predicted experience:**
David will spreadsheet his progress across all 12 cases, tracking rating, fragments, and bestiary entries. He will optimize for spectral platinum on every case, using the evidence board's coherence score as his metric. He will buy all DLC on day one for the achievements. He will be frustrated if the cross-case evidence mechanic requires replaying earlier cases -- he expects his first-run decisions to be "correctable" without full replays. He will play 1-2 cases per week, rotating Banshee's Bazaar with 4 other games.

### P-011: Maria Rodriguez -- "The Commuter Gamer"

**Why this game fits:**
Maria needs offline-capable games with session-friendly length. Banshee's Bazaar on Nintendo Switch is a natural fit. The game autosaves at every scene transition, so she can pause mid-interrogation on the train. A single crime scene investigation fits her 30-45 minute commute window. The premium model means no ads or energy systems interrupting her sessions. The narrative is engaging enough to look forward to but not so action-heavy that she needs to maintain reflexes.

**Predicted experience:**
Maria will play exclusively during her commute on Switch. She will complete one case per week, playing one "phase" (investigation, interrogation, board, tribunal) per trip. She will be absorbed by the noir-fantasy atmosphere -- the Art Deco visuals and jazz soundtrack will be her daily escape from the Buenos Aires Metro. She will not chase achievements or platinum ratings; she plays for the story and the atmosphere. She will be frustrated if the evidence board requires precise mouse/pointer control that is awkward on Switch touchscreen. She will recommend it to one coworker who also commutes.

---

## User Stories

### Exploration

1. As a player (P-003), I want to freely explore each ward of the bazaar between cases so that I can discover hidden lore fragments and understand the world's geography.

2. As a player (P-006), I want to revisit previous crime scenes after completing a case so that I can notice details I missed and strengthen my cross-case understanding.

3. As a player (P-011), I want to explore at my own pace without timed pressure so that I can enjoy the atmosphere during my commute without stress.

4. As a player (P-008), I want each ward to have a lore fragment tracker visible on the map so that I can systematically clear each area without missing collectibles.

5. As a player (P-003), I want to discover hidden stalls that only appear under specific lunar phases so that mastering the calendar feels rewarding.

### Core Mechanics (Evidence and Investigation)

6. As a player (P-006), I want the evidence board to clearly show which connections are verified vs. unverified so that I can evaluate my theories without guessing.

7. As a player (P-008), I want the game to display my case coherence score in real time so that I know exactly how close I am to platinum rating thresholds.

8. As a player (P-003), I want cross-case evidence linking to highlight patterns across multiple investigations so that I feel the conspiracy unraveling through my own deductions.

9. As a player (P-006), I want the Spectral Lens cooldown to be visible and predictable so that I can plan my scanning strategy rather than guessing when it will recharge.

10. As a player (P-011), I want evidence gathering to be pausable at any point so that I can stop mid-scene when my commute ends without losing progress.

11. As a player (P-008), I want red herrings to be identifiable through logical deduction rather than random guessing so that achieving platinum feels skill-based.

12. As a player (P-003), I want the evidence board to support undo/redo of connections so that I can experiment with theories without permanent commitment.

### Narrative

13. As a player (P-006), I want the story to present genuine moral dilemmas where no verdict feels completely right so that the narrative challenges my thinking.

14. As a player (P-003), I want my creature alliances to produce visible narrative consequences in later cases so that my choices feel meaningful across the campaign.

15. As a player (P-011), I want each case to have a satisfying self-contained arc so that I feel narrative closure even if weeks pass between cases.

16. As a player (P-008), I want the fragment collectibles to reward me with meaningful character backstory, not just checklist items, so that completionism feels narratively justified.

17. As a player (P-006), I want the Fetch antagonist's motivations to be understandable, not purely evil, so that the final tribunal feels like a genuine ethical confrontation.

18. As a player (P-003), I want multiple endings that reflect my specific alliance choices across all 12 cases so that replaying the game produces meaningfully different stories.

### Interrogation

19. As a player (P-006), I want the Bestiary Codex to provide actionable intelligence about each species' taboos and preferences so that I can strategize before entering an interrogation.

20. As a player (P-008), I want the disposition matrix to show numerical values so that I can optimize my interrogation approach with precision.

21. As a player (P-011), I want interrogation dialogue to autosave at every branching point so that I can resume mid-conversation in my next session.

22. As a player (P-003), I want the lunar calendar to visibly affect interrogation outcomes so that I can optimize my questioning timing.

23. As a player (P-006), I want the option to re-interview witnesses after gathering new evidence so that I can refine my approach based on new information.

### Tribunal

24. As a player (P-003), I want the tribunal rhetoric card system to have clear strategic depth so that I can build optimal case decks.

25. As a player (P-006), I want each judge's preferences to be legible through their reactions so that I can adapt my presentation based on feedback.

26. As a player (P-008), I want the verdict outcome to be transparently scored so that I understand exactly what determined my rating.

27. As a player (P-011), I want tribunal sequences to be saveable and resumable so that a 25-minute courtroom sequence does not force me to choose between finishing late or replaying.

### Progression

28. As a player (P-003), I want the detective rank system to unlock genuinely new mechanics, not just harder versions of the same thing, so that progression feels like growth.

29. As a player (P-008), I want each case's rating to contribute to an overall campaign score so that I have a single mastery metric across all 12 cases.

30. As a player (P-006), I want the bazaar to physically change based on my verdicts so that my decisions leave a visible mark on the world.

### Accessibility

31. As a player (P-011), I want full offline mode support on Switch so that I can play during my subway commute without internet.

32. As a player (P-011), I want the evidence board to work with both touchscreen and controller so that Switch play feels natural.

33. As a player (P-006), I want text size options for all dialogue and evidence descriptions so that reading is comfortable during extended sessions.

34. As a player (P-003), I want the game to support both Japanese and English text so that I can play in my native language.

35. As a player (P-008), I want the evidence board to have a "snap to grid" option so that organizing nodes is precise and efficient.

---

## Monetization

### Revenue Model: Premium Base + Episodic DLC

**Why this model fits this game:**

Banshee's Bazaar is a narrative experience with a defined beginning, middle, and end. The player base (story-driven explorers, strategy enthusiasts, completionists) values owning their experience and resists microtransactions. The 12-case structure naturally supports episodic DLC -- each case is a self-contained story with connective tissue. The target audience (PC, Switch, PS5) expects premium pricing for narrative adventures of this scope. F2P monetization would undermine the noir atmosphere with energy systems and would compromise the evidence board's purity (selling "hint threads" would destroy the deduction gameplay).

**Base Game ($24.99):**
- Cases 1-8 (the core story arc through the midpoint reversal and into the crisis)
- 6 wards, 32 stalls, 15 creature species
- Full evidence board, interrogation, and tribunal mechanics
- 60 lore fragments
- Estimated playtime: 30-40 hours

**DLC Case Pack 1 -- "The Smiling Shadow" ($7.99):**
- Cases 9-10 (frame-up and multi-ward investigation)
- Wards 5-6 expanded with new stalls
- 3 new creature species (Vampire, Kobold, Siren)
- 16 new lore fragments
- Estimated playtime: 10-14 hours

**DLC Case Pack 2 -- "The Final Verdict" ($7.99):**
- Cases 11-12 (clearing Maren's name and the grand conspiracy)
- Phoenix species introduction
- Ritual site location (new environment beneath Ward 6)
- 15 new lore fragments
- 3 endings
- Estimated playtime: 10-15 hours

**Complete Edition ($34.99, available at launch of DLC Pack 2):**
- Base + both DLC packs

### Revenue Projections

| Scenario | Base Units (Year 1) | DLC Attach Rate | Total Revenue (Year 1) | Notes |
|----------|-------------------:|:---------------:|----------------------:|-------|
| Modest | 8,000 | 35% | $251,940 | Niche audience, word-of-mouth only |
| Expected | 22,000 | 50% | $769,800 | Moderate marketing, positive Steam reviews |
| Strong | 55,000 | 60% | $1,980,000 | Featured on Switch eShop, strong press coverage |
| Breakout | 120,000 | 65% | $4,393,800 | Viral moment, GOTY contender in narrative category |

Revenue calculated at: base units x $24.99 + (base units x attach rate x $15.98 DLC bundle).

---

## Production Plan

### Team

| Role | Count | Phase | Monthly Cost | Duration |
|------|:-----:|-------|-------------:|----------|
| Creative Director | 1 | Full project | $9,500 | 18 months |
| Narrative Designer | 1 | Full project | $7,500 | 18 months |
| Game Designer (Systems) | 1 | Full project | $7,000 | 18 months |
| Lead Programmer | 1 | Full project | $8,500 | 18 months |
| UI/UX Programmer | 1 | Full project | $7,000 | 18 months |
| Gameplay Programmer | 1 | Months 4-16 | $6,500 | 13 months |
| 2D Artist / Art Director | 1 | Full project | $7,500 | 18 months |
| Environment Artist | 2 | Months 3-14 | $6,000 ea. | 12 months |
| Character Artist | 1 | Months 2-14 | $6,500 | 13 months |
| Animator | 1 | Months 5-16 | $6,000 | 12 months |
| Composer | 1 | Months 6-14 | $5,000 | 9 months |
| Sound Designer | 1 | Months 8-16 | $5,500 | 9 months |
| QA Lead | 1 | Months 10-18 | $5,000 | 9 months |
| QA Tester | 2 | Months 13-18 | $3,500 ea. | 6 months |
| Producer | 1 | Full project | $7,000 | 18 months |
| Community Manager | 1 | Months 12-18 | $4,500 | 7 months |

**Peak team size:** 16 people (months 8-14)
**Total estimated payroll:** $1,340,000

### Timeline

| Month | Milestone | Deliverable |
|:-----:|-----------|-------------|
| 1 | Pre-production | Game design document finalized, art style guide complete, Unity project scaffolded, first creature species designed |
| 2 | Prototype | Evidence board mechanic playable with 6 nodes, interrogation prototype with 1 species (Banshee), basic crime scene scanning |
| 3 | Vertical Slice | Case 1 fully playable from investigation through tribunal, Ward 1 art complete, Spectral Lens functional |
| 4 | Production Start | Cases 2-3 in development, lunar calendar system implemented, tribunal card rhetoric system prototyped |
| 5 | Core Systems | Evidence decay, preservation, disposition matrices for 5 species, evidence board thread budget system |
| 6 | Content Wave 1 | Cases 1-4 content complete, Wards 1-2 art complete, Bestiary Codex system implemented |
| 7 | Content Wave 2 | Cases 5-6 (including midpoint reversal), Ward 3 art, cross-case evidence linking system |
| 8 | Audio Integration | Jazz soundtrack recorded, ambient bazaar soundscapes, spectral sound effects, voice direction for 4 key NPCs |
| 9 | Content Wave 3 | Cases 7-8 content complete, Wards 4-5 art, tribunal escalation mechanics |
| 10 | Alpha | All 8 base game cases playable end-to-end, Ward 6 art, internal QA begins |
| 11 | Alpha Iteration | Bug fixes, case balance (coherence scoring tuned), interrogation branch auditing for dead ends |
| 12 | DLC Pack 1 | Cases 9-10 content, Switch port begins, community outreach starts |
| 13 | DLC Pack 1 Complete | Cases 9-10 playable, QA for DLC content, Switch build submitted for lot check |
| 14 | DLC Pack 2 | Cases 11-12 content, all 3 endings implemented, final creature species integrated |
| 15 | Beta | Full game playable, external QA, accessibility testing, localization for Japanese begins |
| 16 | Certification | Platform certification (PS5 TRC, Switch lot check), final audio mix, achievement/trophy integration |
| 17 | Gold | Base game master, day-one patch preparation, marketing push (trailers, press demos) |
| 18 | Launch | Base game launch on PC/Switch/PS5, DLC Pack 1 available, DLC Pack 2 follows 6 weeks post-launch |

### Budget Breakdown

| Category | Amount | Percentage |
|----------|-------:|:----------:|
| Payroll | $1,340,000 | 62.0% |
| Art outsourcing (props, textures) | $180,000 | 8.3% |
| Audio (studio recording, musicians) | $95,000 | 4.4% |
| Tools and licenses (Unity, FMOD, etc.) | $45,000 | 2.1% |
| Platform fees (dev kits, certification) | $60,000 | 2.8% |
| Marketing (trailer, press, events) | $200,000 | 9.3% |
| QA outsourcing (external test house) | $55,000 | 2.5% |
| Localization (JP, plus EU languages) | $70,000 | 3.2% |
| Operations (office, cloud, misc) | $80,000 | 3.7% |
| **Total** | **$2,125,000** | **100.0%** |

Note: Contingency is absorbed into the individual line items at 10-15% each rather than a separate pool, ensuring every category can absorb overages. The payroll figure already includes a 12% buffer for contract extensions.

Break-even at 85,000 base units ($24.99 x 85,000 = $2,124,150 before platform cut). After Steam/Sony/Nintendo's 30% cut, break-even is approximately 121,000 base units. At the "expected" projection of 22,000 units in Year 1, the game does not break even in Year 1 -- it requires sustained long-tail sales over 18-24 months, which is realistic for narrative games with strong reviews. The DLC revenue accelerates the timeline.

---

## Technical Requirements

### Platform Specifications

**PC (Steam) -- Minimum:**

| Component | Specification |
|-----------|---------------|
| OS | Windows 10 64-bit |
| Processor | Intel i5-4590 / AMD FX-8350 |
| Memory | 8 GB RAM |
| Graphics | NVIDIA GTX 970 / AMD RX 480 (VRAM 4 GB) |
| Storage | 18 GB SSD |
| DirectX | Version 12 |
| Input | Keyboard + Mouse (primary), Xbox controller supported |

**PC (Steam) -- Recommended:**

| Component | Specification |
|-----------|---------------|
| OS | Windows 11 64-bit |
| Processor | Intel i7-8700 / AMD Ryzen 5 3600X |
| Memory | 16 GB RAM |
| Graphics | NVIDIA RTX 2060 / AMD RX 5700 (VRAM 6 GB) |
| Storage | 18 GB SSD |
| DirectX | Version 12 |
| Input | Keyboard + Mouse or controller |

**Nintendo Switch:**

| Target | Specification |
|--------|---------------|
| Resolution | Docked: 1080p / Portable: 720p |
| Frame rate | 30 FPS (docked and portable) |
| Storage | 14 GB (compressed assets, lower-res textures) |
| Input | Joy-Con, Pro Controller, touchscreen (evidence board) |
| Features | Full offline play, cloud save support |

**PlayStation 5:**

| Target | Specification |
|--------|---------------|
| Resolution | 4K (dynamic, lowest 1800p) |
| Frame rate | 60 FPS |
| Storage | 18 GB SSD |
| Input | DualSense (haptic feedback for Spectral Lens scanning) |
| Features | Activity Cards for case progress tracking, Game Help integration |

### Key Technical Challenges

| Challenge | Risk | Mitigation |
|-----------|:----:|------------|
| Evidence board node-link system performance with 25+ nodes on Switch | Medium | Implement spatial partitioning for node rendering; cap visible connections at 30 with scroll; use object pooling for thread rendering |
| Dialogue branching combinatorics (6 species x 4 disposition axes x 3 depth levels) | High | Build a data-driven dialogue authoring tool; use Tag-based disposition checks rather than hard-coded branches; automated branch coverage testing in QA |
| Save game compatibility across DLC additions | Medium | Version-stamp all save files; include forward-compatible placeholder slots for DLC content; test with DLC installed and uninstalled |
| Art asset memory budget for 6 wards x 47 stalls on Switch | High | Use shared material atlases per ward; stream stall assets on entry; reduce texture resolution to 512x512 for portable mode; implement aggressive LOD for background stalls |
| Cross-case evidence linking (referencing data from previous save states) | Medium | Store case evidence summaries in a persistent ledger separate from save state; access the ledger rather than replaying previous saves |
| Switch touchscreen precision for evidence board node dragging | Low | Implement magnetic snap-to-grid with generous hitboxes (32px minimum); add a zoom mode for fine positioning; support button-based node selection as alternative |

---

*This document represents the complete game design for Banshee's Bazaar. All numbers, mechanics, and systems are specified at implementation-ready detail. No section requires external reference or additional design work to begin prototyping.*
