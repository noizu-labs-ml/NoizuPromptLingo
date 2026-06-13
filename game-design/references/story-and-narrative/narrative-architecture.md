# Narrative Architecture

Story design systems for games — from linear narratives to emergent storytelling, structured to serve gameplay rather than interrupt it.

## Narrative Types

| Type | Description | Best For | Complexity | Example |
|------|-------------|----------|-----------|---------|
| **Linear** | Fixed story, no branching | Action, platformer, narrative | Low | Uncharted, Celeste |
| **Branching** | Player choices split story | RPG, adventure | High | Baldur's Gate, Witcher |
| **Parallel** | Multiple perspectives converge | Strategy, ensemble RPG | High | Fire Emblem, Octopath |
| **Emergent** | Story arises from systems | Sandbox, simulation | Very High | Dwarf Fortress, RimWorld |
| **Environmental** | World tells the story | Exploration, soulslike | Medium | Dark Souls, Hollow Knight |
| **Episodic** | Chapters released over time | Adventure, narrative | Medium | Life is Strange, Telltale |
| **Systemic** | Rules generate narrative moments | Open world, RPG | Very High | Breath of the Wild, Divinity |

## Story Spine

Every game narrative needs a spine — the irreducible story structure.

### The 8-Point Spine

```
1. STATE OF EQUILIBRIUM
   The world as it is before the story begins.
   What does "normal" look like for this world/character?

2. INCITING INCIDENT
   The event that shatters equilibrium.
   What forces the protagonist into action?

3. FIRST COMPLICATION
   The initial obstacle that reveals the true scope.
   What makes the player realize this is bigger than expected?

4. RISING ACTION (3-5 beats)
   Escalating challenges that deepen investment.
   Each beat raises stakes and reveals character.

5. MIDPOINT REVERSAL
   A fundamental shift in understanding or direction.
   The player/protagonist learns something that changes everything.

6. CRISIS POINT
   The lowest moment — all seems lost.
   Maximum emotional investment, maximum risk.

7. CLIMAX
   The final confrontation that resolves the central question.
   Player skill meets narrative payoff.

8. RESOLUTION
   The new equilibrium — how has the world changed?
   Player actions are reflected in the outcome.
```

## Branching Narrative Design

### Branching Structures

| Structure | Description | Content Multiplier | Example |
|-----------|-------------|-------------------|---------|
| **Time cave** | Every choice creates new content | 2^n (exponential) | Early Telltale |
| **Branch and bottleneck** | Branches converge at key points | 2-3x | Mass Effect |
| **Parallel quests** | Independent storylines | 1.5-2x | Skyrim |
| **Flowchart** | Complex interconnections | 3-5x | Visual novels |
| **State-based** | World state drives narrative | 2-4x | Disco Elysium |

### Branching Best Practices

1. **Convergence over divergence** — Branches should converge regularly to avoid content explosion
2. **Illusion of choice** — Some branches feel different but reach the same outcome (done well, not lazily)
3. **Meaningful consequences** — When choices converge, the path taken must feel like it mattered
4. **State tracking** — Track player choices as world state variables, not narrative flags
5. **Late-game payoff** — Early choices should echo in late-game moments

### Decision Point Design

```yaml
decision_point:
  context: "The village chief reveals he's been poisoning the water supply"
  player_choice:
    - option: "Expose him to the village"
      consequences:
        immediate: "Village revolts, chief is exiled"
        delayed: "Village loses leadership, struggles with raids"
        endgame: "Village survivors join your cause as allies"

    - option: "Blackmail him into serving you"
      consequences:
        immediate: "Chief becomes your spy in the region"
        delayed: "Chief's guilt manifests as betrayal risk"
        endgame: "Chief's betrayal costs you a key battle"

    - option: "Kill him secretly"
      consequences:
        immediate: "Village assumes he fled, power vacuum"
        delayed: "Rumors spread, village distrusts outsiders"
        endgame: "Village never trusts you, neutral faction"
```

## Lore-Through-Play

The best game narratives are discovered, not told.

### Environmental Storytelling

| Technique | Implementation | Example |
|-----------|---------------|---------|
| Item descriptions | Every item has lore text | Dark Souls weapons |
| Environmental detail | Scene tells a story | Abandoned campfire, scattered journals |
| Architecture | Building design reveals culture | Elven vs dwarven architecture |
| NPC behavior | Characters act out stories | NPCs having conversations, routines |
| Map design | Geography tells history | Battlefield scars, ancient ruins |
| Collectibles | Lore fragments as rewards | Audio logs, journal pages |

### Narrative Integration Patterns

| Pattern | Description | When to Use |
|---------|-------------|-------------|
| **Cutscene reward** | Story moment as reward for gameplay | After boss fights, level completion |
| **Mid-action dialogue** | Story delivered during gameplay | Shooters, action games |
| **Dialogue choice** | Player participates in story | RPGs, adventure games |
| **Codex/journal** | Optional deep lore | All games, for completionists |
| **World events** | Story happens through gameplay | MMOs, live service games |
| ** emergent moments** | Systems create story beats | Sandbox, simulation games |

### Dialogue System Design

| System | Description | Best For | Complexity |
|--------|-------------|----------|-----------|
| **Keyword** | Player selects topics | Classic RPGs | Low |
| **Tree** | Branching conversation options | Narrative RPGs | Medium |
| **Wheel** | Limited options with tone indicators | Action RPGs | Low-Medium |
| **Free input** | Player types natural language | AI-driven games | Very High |
| **Bark system** | NPCs bark contextual lines | Action, shooters | Low |
| **Visual novel** | Full text with choices | Story games | High |

### Dialogue Writing Rules

1. **Show, don't tell** — "I'll kill you for what you did" > "I am angry at you"
2. **Character voice** — Every character has distinct vocabulary, rhythm, and subtext
3. **Subtext** — Characters rarely say exactly what they mean
4. **Brevity** — Players skip long dialogue; keep it punchy
5. **Purpose** — Every line either advances plot, reveals character, or provides gameplay information
6. **Player agency** — Give players meaningful choices, not just "listen more" vs "skip"

## World-Building for Games

### The 7-Layer World Model

```
Layer 1: PHYSICAL WORLD
  Geography, climate, biomes, resources, hazards
  "What does the world look like?"

Layer 2: HISTORY
  Timeline, major events, ages, catastrophes, golden eras
  "What happened before the game starts?"

Layer 3: CULTURES & FACTIONS
  Peoples, nations, organizations, religions, guilds
  "Who lives here and what do they believe?"

Layer 4: POWER STRUCTURES
  Governments, economies, military, magic systems, technology
  "How does power work in this world?"

Layer 5: CONFLICTS
  Active tensions, cold wars, rivalries, resource disputes
  "What are people fighting about?"

Layer 6: SECRETS
  Hidden truths, conspiracies, ancient threats, lost knowledge
  "What don't the inhabitants know?"

Layer 7: PLAYER ROLE
  Where the player fits, their unique capability, their destiny
  "Why does this story need THIS protagonist?"
```

### Faction Design Template

```yaml
faction:
  name: "The Chronomancer's Guild"
  type: "Mystical organization"
  philosophy: "Time is a resource to be managed, not a river to be floated upon"
  goals:
    - "Preserve temporal stability across all known timelines"
    - "Prevent paradox events that could collapse reality"
    - "Maintain monopoly on temporal magic"
  resources:
    - "Temporal artifacts (amulets, tomes, hourglasses)"
    - "Knowledge of future events (limited, probabilistic)"
    - "Network of time-locked sanctuaries"
  conflicts:
    - vs_faction: "The Unbound" → "Want to tear down temporal restrictions"
    - internal: "Conservatives vs Reformers on sharing time magic"
    - vs_world: "Nations want access to temporal intelligence"
  visual_identity: "Amber/gold robes, hourglass symbols, crystalline architecture"
  npc_archetypes:
    - "Elder chronomancer (wise, cryptic, regretful)"
    - "Apprentice (eager, impulsive, time-curious)"
    - "Temporal warden (stern, dutiful, paranoid about paradoxes)"
```

### Tone Consistency

| Tone | Description | Visual Palette | Narrative Style |
|------|-------------|---------------|-----------------|
| **Epic** | Grand, world-spanning stakes | Gold, crimson, deep blue | Mythic, operatic |
| **Grimdark** | Harsh, unforgiving world | Black, rust, desaturated | Brutal, cynical |
| **Whimsical** | Playful, lighthearted | Pastels, bright, saturated | Humorous, warm |
| **Mysterious** | Unknown, discovering secrets | Purple, teal, fog | Cryptic, revealing |
| **Hopeful** | Optimistic, triumphant | Warm, sunrise colors | Inspiring, earnest |
| **Melancholic** | Bittersweet, reflective | Faded, autumnal | Poetic, nostalgic |

## Narrative Scope Estimation

| Component | Lines per Hour | Hours of Content | Total Lines | VO Budget Estimate |
|-----------|---------------|-----------------|-------------|-------------------|
| Main story | 200-300 | 8-20 hours | 2,000-6,000 | $20K-$60K |
| Side quests | 100-200 per quest | 5-15 hours | 500-3,000 | $5K-$30K |
| NPC barks | 5-10 per NPC | Ambient | 200-1,000 | $2K-$10K |
| Item descriptions | 2-5 per item | Passive | 500-2,500 | N/A (text only) |
| Codex entries | 100-300 per entry | Optional | 1,000-5,000 | N/A (text only) |
| **Total** | - | 15-40 hours | 4,000-17,500 | $27K-$100K |
