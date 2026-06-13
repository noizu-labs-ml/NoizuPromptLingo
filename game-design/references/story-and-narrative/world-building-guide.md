# World-Building Guide

Creating rich, consistent game worlds that serve as the foundation for narrative and gameplay.

## The World-Building Stack

```
┌─────────────────────────────┐
│     PLAYER EXPERIENCE       │  ← What the player sees/feels
├─────────────────────────────┤
│     NARRATIVE LAYER         │  ← Stories told in the world
├─────────────────────────────┤
│     CULTURAL LAYER          │  ← Societies, beliefs, conflicts
├─────────────────────────────┤
│     SYSTEMS LAYER           │  ← Magic, technology, economy
├─────────────────────────────┤
│     PHYSICAL LAYER          │  ← Geography, climate, resources
├─────────────────────────────┤
│     COSMOLOGICAL LAYER      │  ← How the universe works
└─────────────────────────────┘
```

Build from bottom up, but the player experiences from top down. Every bottom layer must justify something in the top layer.

## Physical World Design

### Geography for Gameplay

| Terrain Type | Gameplay Affordance | Narrative Flavor |
|-------------|--------------------|-----------------| |
| Mountains | Vertical traversal, chokepoints, isolation | Ancient, unyielding, hermit kingdoms |
| Forests | Stealth, foraging, mystery, exploration | Wild, enchanted, hiding secrets |
| Oceans | Naval combat, islands, exploration | Mysterious, dangerous, freedom |
| Deserts | Survival, scarcity, hidden oases | Harsh, ancient, buried history |
| Swamps | Poison, ambush, decay | Corrupt, forgotten, decomposing |
| Cities | Social, political, trade, intrigue | Power, conflict, opportunity |
| Ruins | Exploration, loot, danger, history | Lost glory, forgotten knowledge |
| Underground | Mining, darkness, hidden civilizations | Primordial, claustrophobic, treasure |

### Resource Design

Resources should serve both gameplay (crafting, economy) and narrative (conflict, power).

| Resource Type | Gameplay Role | Narrative Role |
|--------------|-------------|----------------|
| Common materials | Basic crafting | Everyday life, trade |
| Rare materials | Premium crafting | Status, wealth, greed |
| Magical materials | Special abilities | Power, corruption, sacrifice |
| Food/water | Survival | Community, culture, scarcity |
| Information | Quests, secrets | Espionage, knowledge as power |
| Land/territory | Control, building | Sovereignty, belonging |

## Culture & Faction Design

### Faction Creation Template

For each faction, define:

```yaml
faction:
  name: ""
  type: ""  # nation, guild, cult, corporation, species, etc.
  scale: "" # local, regional, continental, global, cosmic

  identity:
    philosophy: ""      # Core belief in one sentence
    values: []          # 3-5 core values
    taboos: []          # 3-5 forbidden actions/beliefs
    aesthetic: ""       # Visual identity (colors, symbols, architecture)

  power:
    source: ""          # What gives them power? (military, trade, knowledge, magic)
    structure: ""       # How is power organized? (hierarchical, democratic, theocratic)
    military: ""        # Military strength and style
    economy: ""         # How they sustain themselves

  relationships:
    allies: []          # Allied factions and why
    enemies: []         # Enemy factions and why
    neutral: []         # Neutral/uneasy relationships
    internal_tension: "" # What divides them internally?

  secrets:
    public_knowledge: ""   # What everyone knows
    rumored: ""           # What some suspect
    hidden: ""            # What only leaders know
    deepest_secret: ""    # What could destroy them if revealed
```

### Faction Conflict Matrix

Create a 2D grid of all factions. For each intersection, define:

| Relationship | Description | Gameplay Impact |
|-------------|-------------|-----------------|
| **Alliance** | Formal cooperation | Shared quests, trade routes |
| **Cold war** | Tension without combat | Espionage, proxy conflicts |
| **Active war** | Open hostilities | PvP, territory battles |
| **Trade** | Economic cooperation | Markets, resource exchange |
| **Subjugation** | One dominates another | Resistance quests, rebellion |
| **Unknown** | No relationship yet | Discovery, exploration |

## Magic / Technology Systems

### Magic System Design

| Aspect | Questions to Answer |
|--------|-------------------|
| **Source** | Where does magic come from? (divine, natural, learned, innate, bargained) |
| **Cost** | What does using magic cost? (energy, material, health, time, sanity) |
| **Limits** | What can't magic do? (death, time, creation, mind control) |
| **Culture** | How does society view magic? (revered, feared, regulated, banned) |
| **Progression** | How do practitioners grow stronger? (study, practice, sacrifice, experience) |
| **Specialization** | Are there schools/types? (elements, schools, domains, affinities) |

### Technology Level Considerations

| Era | Warfare | Communication | Travel | Medicine |
|-----|---------|--------------|--------|----------|
| Stone | Melee, thrown | Smoke, drums | Foot | Herbal |
| Bronze | Bronze weapons | Messengers | Horse, chariot | Primitive surgery |
| Iron | Iron weapons, formations | Written messages | Horse, ship | Herbal + surgery |
| Medieval | Steel, siege | Couriers, pigeons | Horse, ship | Monastery medicine |
| Renaissance | Gunpowder, pikes | Printing press | Sailing ships | Anatomy, alchemy |
| Industrial | Rifles, artillery | Telegraph | Train, steamship | Modern medicine begins |
| Modern | Automatic weapons, air | Phone, radio | Car, plane | Antibiotics, surgery |
| Future | Energy weapons, mechs | Instant digital | Space, teleportation | Genetic engineering |

## Tone & Atmosphere

### Tone Mapping

Define your world's position on these spectrums:

```
HOPEFUL ←————————————→ GRIM
SERIOUS ←————————————→ WHIMSICAL
SIMPLE  ←————————————→ COMPLEX
GROUND  ←————————————→ FANTASTICAL
STATIC  ←————————————→ DYNAMIC
```

Every element of the world should reinforce the chosen tone position. Inconsistency in tone is jarring.

### Atmosphere Through Sensory Design

| Sense | Implementation | Example |
|-------|---------------|---------|
| Visual | Art style, color palette, lighting | Dark stone corridors lit by bioluminescent fungi |
| Audio | Music, ambient sounds, SFX | Dripping water, distant echoing footsteps |
| Narrative | Descriptive text, dialogue style | NPCs speak in hushed, reverent tones |
| Mechanical | Game systems that reinforce mood | Permadeath in a horror game reinforces dread |
| UI | Interface design matches world | Skeuomorphic journal for a medieval game |

## World Bible Template

```markdown
# [World Name] — World Bible

## Overview
One paragraph: what is this world, what makes it unique, what's the central tension?

## Cosmology
- How did the world come to be?
- What are the fundamental laws (physics, magic, technology)?
- What happens after death?
- What is the nature of the divine (if any)?

## Geography
- Major continents/regions
- Climate and biomes
- Key landmarks and their significance
- Travel routes and distances

## History (Timeline)
- Age 1: [Foundation events]
- Age 2: [Major conflicts]
- Age 3: [Recent history]
- Present: [Current state of the world]

## Cultures & Factions
[One section per major faction using the template above]

## Power Systems
- Magic/Technology: [Rules, costs, limits]
- Politics: [How power is gained and held]
- Economy: [What has value and why]

## Daily Life
- What does a typical day look like for common people?
- What do people eat, wear, believe?
- What do they fear, hope for, dream about?

## Conflicts
- What are the active tensions in the world?
- What are people fighting about?
- What threatens the status quo?

## Secrets
- What don't the inhabitants know?
- What hidden forces are at work?
- What would change everything if revealed?

## Player's Place
- Where does the player enter this world?
- What unique capability does the player have?
- What is the player's central dramatic question?
```

## Consistency Checking

### Common World-Building Pitfalls

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| Kitchen-sink syndrome | Everything exists, no cohesion | Pick a tone and cut what doesn't fit |
| History dumping | Players don't care about ancient lore | Reveal history through gameplay |
| Static world | World doesn't react to player actions | Design world state changes based on player choices |
| Generic fantasy | Indistinguishable from every other fantasy world | Find one unique angle and amplify it |
| Tone inconsistency | Whimsical goblin merchants in grimdark horror | Establish tone rules and enforce them |
| Over-detailed | 50-page world bible, 5-minute game | Detail only what the player will experience |
