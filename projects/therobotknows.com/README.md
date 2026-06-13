# NOIZUAI-4: TheRobotKnows — Knowledge Base

**Domain:** [therobotknows.com](https://therobotknows.com)

## Elevator Pitch

**A living wiki that writes itself.** Define the seeds of your creative universe — characters, locations, rules, history — and the Knowledge Base generates consistent, cross-referenced supplementary materials: lore entries, character backstories, in-universe documents, relationship maps, and timeline events. Everything interconnected, everything internally consistent, everything browsable as a rich hyperlinked knowledge graph.

Think: World Anvil meets Notion meets an AI collaborator who has actually *read* everything you've written.

---

## Problem

### 1. World-Building Is a Consistency Nightmare

An author writes 300 pages of a fantasy novel. By chapter 12, they've mentioned a trade route that contradicts the geography from chapter 3, given two characters the same family name accidentally, and forgotten whether the magic system costs "mana" or "aether." Game masters running year-long campaigns face the same entropy — lore accretes, contradictions multiply, and the binder of notes becomes untouchable.

Consistency is the invisible labor of creative work. It doesn't make the writing *better*, but its absence makes it *worse*. And it scales nonlinearly — twice the content means four times the consistency burden.

### 2. Existing Tools Are Manual Entry

The current world-building toolchain:

| Tool | What It Does | What It Doesn't |
|---|---|---|
| **World Anvil** | Wiki-style articles, maps, timelines | You write every word yourself. No generation, no consistency checking. |
| **Campfire** | Character sheets, magic system builder | Beautiful templates, but empty until you fill them. No AI. |
| **Notion / Obsidian** | Flexible notes with linking | No structure for creative works. No consistency. No generation. |
| **Scrivener** | Long-form writing with research sidebar | Research is a dumping ground, not a knowledge graph. |
| **ChatGPT / Claude** | Can generate lore on demand | No persistence. No cross-referencing. Contradicts itself across sessions. |

The gap: **no tool connects structured world-building with AI generation *and* consistency enforcement.** You either write everything yourself (World Anvil) or get AI-generated content that forgets itself between conversations (ChatGPT).

### 3. Supporting Materials Are Where Worlds Become Real

The reader never sees the 40-page document about the Dwarven economy. The player never asks about the trade agreements between the Northern Reach and the Coastal Federation. But the author who *wrote* those documents creates a world that feels lived-in — because every decision cascades through a consistent substrate.

The problem isn't generating one piece of lore. It's generating *hundreds* of pieces that all agree with each other, that reference each other naturally, that evolve coherently as the source material changes.

---

## Solution: AI-Powered Knowledge Graph for Creative Universes

### Core Concept

The Knowledge Base is organized around three layers:

| Layer | Purpose | Examples |
|---|---|---|
| **Canon** | Source-of-truth entries authored or approved by the creator | Character profiles, core history, magic system rules, geography |
| **Generated** | AI-produced supplementary materials derived from Canon | In-universe newspaper articles, minor character backstories, cultural customs, historical events between known dates |
| **Inferred** | Relationships, timelines, and consistency checks computed across all entries | "Character A and Character B were both in the same city during the War of Stones — did they interact?" |

### How It Works

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│   Creator writes Canon ──→ AI analyzes + indexes        │
│         ↑                           │                   │
│         │                           ↓                   │
│   Creator reviews,       AI generates supporting        │
│   promotes or edits  ←── materials that reference Canon  │
│         │                           │                   │
│         ↓                           ↓                   │
│   Canon grows ──────────→ Consistency engine checks      │
│                           all entries against each other  │
│                                     │                   │
│                                     ↓                   │
│                           Flags contradictions,          │
│                           suggests connections,          │
│                           fills gaps                     │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### What Makes It Different

**It reads before it writes.** Unlike a chatbot that generates in isolation, the Knowledge Base ingests your entire canon before generating anything. A request to "write the backstory for the blacksmith in Thornwall" produces output that knows Thornwall is on the coast, that the last war disrupted iron supply chains, and that the blacksmith's apprentice was mentioned in chapter 7.

**Entries are linked, not listed.** Every generated entry contains hyperlinks to the canon it references. Click through from a character's backstory to the war they fought in to the treaty that ended it to the kingdom that signed it. The knowledge graph is the product, not a byproduct.

**Consistency is enforced, not hoped for.** The system maintains a constraint graph: timelines, locations, character relationships, factual claims. When a new entry contradicts an existing one, it flags the conflict and suggests resolutions. You decide what's true — the system keeps track.

**Canon vs. generated is always visible.** Every piece of content is tagged: did a human write this, or did the AI generate it? Generated content can be promoted to canon with one click. Nothing sneaks into your world's truth without your approval.

---

## Target Users

### Primary: Fantasy/Sci-Fi Novelists

- Writing novels or series set in invented worlds
- Already maintain a "world bible" (Google Doc, Notion, physical binder)
- Spend 30-50% of creative time on consistency and reference materials
- **Job to be done:** "I need to write 40,000 words of lore so that 200,000 words of novel feel real — and I need all 40,000 to agree with each other"

### Secondary: Tabletop RPG Game Masters

- Running long campaigns in custom or adapted settings (D&D, Pathfinder, homebrew)
- Need to improvise consistently — players ask unexpected questions about the world
- Currently use a combination of wiki tools, notes apps, and memory
- **Job to be done:** "A player just asked about the political structure of a kingdom I mentioned offhand three sessions ago — I need a coherent answer in 30 seconds"

### Tertiary: Game Developers & Narrative Designers

- Building lore databases for video games (indie to AA scale)
- Need structured content that can be exported to game engines (dialogue, codex entries, item descriptions)
- Multiple writers working on the same universe
- **Job to be done:** "We have 6 writers and 400 lore entries — how do we make sure they all tell the same story?"

### Emerging: Content Creators with Extended Universes

- Podcast fiction (Welcome to Night Vale, The Magnus Archives)
- Webcomic authors maintaining worldbuilding across 500+ pages
- YouTube worldbuilders (Artifexian, Hello Future Me)
- **Job to be done:** "My audience notices contradictions before I do"

---

## Competitive Landscape

| Tool | Strength | Gap Knowledge Base Fills |
|---|---|---|
| **World Anvil** | Rich templates, maps, timelines, large community | 100% manual entry. No AI generation, no consistency checking. |
| **Campfire** | Beautiful UI, structured character/magic system builders | Manual only. No cross-referencing, no knowledge graph. |
| **LegendKeeper** | Clean wiki + map integration, indie-friendly | Manual wiki. No generation, no consistency engine. |
| **Notion / Obsidian** | Flexible, backlinks, community templates | Generic tools — no creative writing structure, no AI, no consistency. |
| **Scrivener** | Industry-standard writing tool | Research features are a filing cabinet, not a knowledge system. |
| **NovelAI / Sudowrite** | AI writing assistance | Generates prose, not structured knowledge. No persistence across sessions. |
| **ChatGPT / Claude** | Powerful generation on demand | Stateless. Contradicts itself. No graph, no versioning, no canon/generated distinction. |

**Positioning:** Knowledge Base is not a writing tool (Scrivener), a wiki builder (World Anvil), or an AI prose generator (NovelAI). It's a **consistency-aware knowledge graph that generates structured world-building materials from your creative source material** — the reference library your universe deserves.

---

## Key Features (MVP Scope)

### 1. Universe Projects

- Create a project per creative universe (one novel, one campaign, one game)
- Project-level settings: genre, tone, naming conventions, key constraints
- Import existing materials: paste text, upload documents, link to Google Docs
- Export: Markdown, JSON, PDF, structured data for game engines

### 2. Canon Editor

- Write and manage source-of-truth entries using structured templates
- Entry types: Character, Location, Event, Faction, Object, Concept, Rule
- Rich text with inline links to other entries
- Tag system: era, region, importance level, story arc

### 3. Knowledge Graph

- Visual, navigable graph of all entries and their relationships
- Zoom from universe-level overview to neighborhood-level detail
- Filter by entry type, era, region, or custom tags
- Click any edge to see *why* two entries are related

### 4. Generation Engine

- Request generated entries: "Write a 500-word history of the Thornwall blacksmithing guild"
- AI reads all relevant canon before generating
- Generated entries arrive with source citations: "[Based on: Thornwall geography, Iron trade routes, Character: Kael]"
- Bulk generation: "Generate minor characters for every location that doesn't have any"

### 5. Consistency Checker

- Runs continuously as entries are added or modified
- Flags: timeline contradictions, geographic impossibilities, duplicate names, orphaned references
- Severity levels: error (hard contradiction), warning (possible conflict), suggestion (gap that could be filled)
- Resolution workflow: pick a side, merge entries, or mark as intentional ambiguity

### 6. Session Companion (for GMs)

- Quick-reference mode: search your entire universe from a single search bar
- "Improvise" mode: ask a question, get a canon-consistent answer generated in real time
- Session log: record what happened during play, auto-generate new entries from session notes
- Player-facing view: share selected entries with players (no spoilers)

---

## Information Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  KNOWLEDGE BASE APP STRUCTURE                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Dashboard ─────── Universe list, recent entries, alerts    │
│                    (contradictions, suggestions)             │
│                                                             │
│  Universe ──────── Overview → Graph → Entries → Timeline    │
│    ├── Entries     Entry list → Detail (read + edit)        │
│    │   └── Types   Character, Location, Event, Faction,     │
│    │               Object, Concept, Rule                    │
│    ├── Graph       Visual knowledge graph, filterable       │
│    ├── Timeline    Chronological event view, zoomable       │
│    ├── Generate    Prompt-based generation + bulk ops        │
│    └── Consistency Flags, warnings, resolution queue        │
│                                                             │
│  Session ───────── GM companion mode (search, improvise,    │
│                    session log, player view)                 │
│                                                             │
│  Templates ─────── Entry templates (built-in + custom)      │
│                                                             │
│  Settings ──────── Project config, export, sharing,         │
│                    AI model preferences, API keys            │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Primary User Flows

### Flow 1: Bootstrap a Universe from Existing Materials

```mermaid
flowchart LR
    A[Create universe project] --> B[Paste/upload existing notes]
    B --> C[AI parses and extracts entities]
    C --> D[Review extracted entries]
    D --> E{Approve as canon?}
    E -->|Yes| F[Entries added to graph]
    E -->|Edit| G[Modify and approve]
    G --> F
    F --> H[Consistency check runs]
    H --> I[Resolve any flags]
```

### Flow 2: Generate Supporting Materials

```mermaid
flowchart TD
    A[Navigate to a canon entry] --> B[Click 'Generate related']
    B --> C[Choose type: backstory, history, in-universe document, etc.]
    C --> D[AI reads all connected canon]
    D --> E[Generated entry appears with source citations]
    E --> F{Review}
    F -->|Promote to canon| G[Entry joins graph as canon]
    F -->|Edit then promote| H[Modify → promote]
    F -->|Discard| I[Regenerate or abandon]
```

### Flow 3: Catch a Contradiction

```mermaid
flowchart TD
    A[Author edits a canon entry] --> B[Consistency engine re-checks]
    B --> C{Contradiction found?}
    C -->|Yes| D[Flag appears with details]
    D --> E[Show: Entry A says X, Entry B says Y]
    E --> F{Resolution}
    F -->|Fix A| G[Edit entry A]
    F -->|Fix B| H[Edit entry B]
    F -->|Intentional| I[Mark as deliberate ambiguity]
    C -->|No| J[Graph updates cleanly]
```

### Flow 4: GM Session Companion

```mermaid
flowchart LR
    A[Open session mode] --> B[Player asks about the world]
    B --> C[Search universe from single bar]
    C --> D{Canon entry exists?}
    D -->|Yes| E[Display entry]
    D -->|No| F[Generate canon-consistent answer]
    F --> G[GM reviews before sharing]
    G --> H[Log to session notes]
    H --> I[Post-session: promote to canon?]
```

### Flow 5: Bulk World-Building Sprint

```mermaid
flowchart TD
    A[Author defines generation brief] --> B[e.g. 'Every major city needs a founding myth']
    B --> C[AI identifies cities without founding myths]
    C --> D[Generates batch of entries]
    D --> E[Author reviews queue one by one]
    E --> F[Approve / Edit / Discard each]
    F --> G[Approved entries join graph]
    G --> H[Consistency check on all new entries]
```

---

## Key Screens

### Screen 1: Dashboard

```
┌─────────────────────────────────────────────────┐
│  ◊ KNOWLEDGE BASE          library.therobotlives│
│─────────────────────────────────────────────────│
│                                                 │
│  YOUR UNIVERSES                                 │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────┐    │
│  │ The Ashward       │  │ Ironlight         │    │
│  │ Chronicles        │  │ Campaign          │    │
│  │                   │  │                   │    │
│  │ Fantasy Novel     │  │ D&D 5e Homebrew   │    │
│  │ 247 entries       │  │ 89 entries        │    │
│  │ 3 flags ⚠        │  │ 0 flags ✓        │    │
│  │ Updated 2h ago    │  │ Updated yesterday │    │
│  └──────────────────┘  └──────────────────┘    │
│                                                 │
│  ┌──────────────────┐  ┌──────────────────┐    │
│  │ Meridian           │  │                   │    │
│  │ Sector             │  │   + New Universe  │    │
│  │                   │  │                   │    │
│  │ Sci-Fi Game       │  │                   │    │
│  │ 412 entries       │  │                   │    │
│  │ 7 flags ⚠        │  │                   │    │
│  │ Updated 4d ago    │  │                   │    │
│  └──────────────────┘  └──────────────────┘    │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
│  RECENT ACTIVITY                                │
│  ● Generated: "Founding of Thornwall" — 2h ago  │
│  ⚠ Conflict: Kael's age in Ch.3 vs Ch.12       │
│  ● Promoted: "Northern Trade Routes" to canon   │
│  ● New entry: "The War of Stones" (manual)      │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Screen 2: Knowledge Graph View

```
┌─────────────────────────────────────────────────┐
│  ← Ashward Chronicles    KNOWLEDGE GRAPH   [⊞]  │
│─────────────────────────────────────────────────│
│  Filter: [All Types ▼] [All Eras ▼] [Search…]  │
│─────────────────────────────────────────────────│
│                                                 │
│           ┌──────────┐                          │
│     ╭─────│ Thornwall │─────╮                   │
│     │     └────┬─────┘     │                    │
│     │          │            │                    │
│  ┌──▼───┐  ┌──▼─────┐  ┌──▼──────────┐        │
│  │ Kael │  │ Iron   │  │ Blacksmith  │        │
│  │      │──│ Trade  │──│ Guild       │        │
│  └──┬───┘  │ Routes │  └──────┬──────┘        │
│     │      └────────┘         │                │
│     │                    ┌────▼──────┐          │
│     │              ╭─────│ War of    │          │
│     ╰──────────────╯     │ Stones    │          │
│                          └─────┬────┘          │
│                                │                │
│                          ┌─────▼────┐           │
│                          │ Treaty   │           │
│                          │ of Dusk  │           │
│                          └──────────┘           │
│                                                 │
│  Legend: ■ Canon  □ Generated  ⚠ Flagged        │
│                                                 │
│  247 entries · 583 connections · 3 conflicts     │
│─────────────────────────────────────────────────│
│  📊 Graph  📋 List  📅 Timeline  🔍 Search     │
└─────────────────────────────────────────────────┘
```

### Screen 3: Entry Detail

```
┌─────────────────────────────────────────────────┐
│  ← Entries              ■ CANON    [Edit] [···] │
│─────────────────────────────────────────────────│
│                                                 │
│  CHARACTER                                      │
│                                                 │
│  Kael Ashward                                   │
│  ─────────────────────────────                  │
│                                                 │
│  Tags: protagonist, swordsmith, Northern Reach  │
│  Era: Third Age · Region: Thornwall             │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
│                                                 │
│  Kael is the last master swordsmith of the      │
│  ⌈Thornwall⌉ ⌈Blacksmith Guild⌉, trained by   │
│  his grandfather before the ⌈War of Stones⌉    │
│  disrupted the ⌈iron trade routes⌉ from the    │
│  Northern Reach. He forges blades using a       │
│  technique called cold-singing, which...        │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
│  CONNECTIONS (7)                                │
│                                                 │
│  → Thornwall (location) — resident              │
│  → Blacksmith Guild (faction) — last master     │
│  → War of Stones (event) — survivor             │
│  → Iron Trade Routes (concept) — dependent on   │
│  → Mira Ashward (character) — daughter           │
│  → Treaty of Dusk (event) — reluctant witness   │
│  → Cold-singing (concept) — practitioner        │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
│  ⚠ 1 CONSISTENCY FLAG                           │
│  Kael's age at the War of Stones (entry says    │
│  14) conflicts with the War's date (would make  │
│  him 11 based on birth year in Ch.3).           │
│  [Resolve]                                      │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
│  [✦ Generate Related]  [↗ View in Graph]        │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Screen 4: Generation Studio

```
┌─────────────────────────────────────────────────┐
│  ← Ashward Chronicles    GENERATE              │
│─────────────────────────────────────────────────│
│                                                 │
│  What would you like to generate?               │
│  ┌─────────────────────────────────────────┐    │
│  │ Write the founding myth of Thornwall,   │    │
│  │ told as an oral history by elders of    │    │
│  │ the Blacksmith Guild.                   │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  Entry type: [Event ▼]    Length: [~800 words]  │
│  Tone: [In-universe voice ▼]                    │
│                                                 │
│  AI WILL REFERENCE:              [Edit sources] │
│  ┌─────────────────────────────────────────┐    │
│  │ ■ Thornwall (location)                  │    │
│  │ ■ Blacksmith Guild (faction)            │    │
│  │ ■ Northern Reach (region)               │    │
│  │ ■ Iron Trade Routes (concept)           │    │
│  │ □ War of Stones (event) — excluded      │    │
│  │   (post-dates founding)                 │    │
│  └─────────────────────────────────────────┘    │
│                                                 │
│  [ ✦ Generate ]                                 │
│                                                 │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
│  RECENT GENERATIONS                             │
│  □ "Northern Reach Climate Patterns" — 1h ago   │
│  ■ "Mira Ashward Backstory" — promoted          │
│  □ "Guild Hierarchy" — pending review           │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Visual Direction

### Style: Editorial (80%) + Minimal Tech (20%)

**Rationale:** The content *is* the product — lore articles, character profiles, in-universe documents. This demands the Editorial style's typography-first, content-respecting aesthetic. The Minimal Tech accent serves the functional surfaces: the knowledge graph, consistency checker, generation controls, and search. The result should feel like browsing a beautiful reference library that happens to have a powerful engine underneath.

**The metaphor:** A scholar's private library — well-organized, beautifully typeset, with an AI archivist who knows where everything is.

### Color System

```
PALETTE: "VELLUM & INK"

Light Mode (primary):
  Background:  #FAF9F6  (Warm cream — parchment-inspired)
  Surface:     #FFFFFF  (Cards and panels)
  Border:      #E8E2D9  (Warm gray, subtle)

  Text:        #1A1A1A  (Near-black, high contrast)
  Text Muted:  #6B6560  (Warm medium gray)

  Accent:      #8B4513  (Saddle brown — library/leather)
  Link:        #2D5A8E  (Scholarly blue)

  Canon:       #1A1A1A  (Ink black indicator)
  Generated:   #8B7355  (Sepia — "draft" feeling)
  Flag:        #C4432B  (Manuscript red)
  Success:     #3D7A4A  (Forest green)

Dark Mode (secondary):
  Background:  #12110F  (Deep warm black)
  Surface:     #1E1C19  (Elevated warm)
  Text:        #E8E2D9  (Cream text)
  Accent:      #C4956A  (Warm gold)
```

### Typography

```
Headings / Entry Titles:  Freight Text Pro or Lora
                          Serif, warm, authoritative
                          Signals: "This is a document worth reading"

UI / Navigation:          Inter or DM Sans
                          Geometric sans, functional
                          Signals: "This is a tool you can trust"

Entry Body Text:          Freight Text Pro or Source Serif 4
                          Comfortable reading at long lengths
                          Line height: 1.65, max-width: 65ch

Monospace accent:         JetBrains Mono
                          Used for: tags, metadata, consistency
                          flag details, structured data
```

### Visual Identity Cues

- **Book/manuscript textures** — Subtle warm tones, never stark white, evoking vellum and paper
- **Ink-style iconography** — Entry type icons drawn in a slightly hand-drawn/woodcut style
- **The knowledge graph** — Dark lines on warm background, nodes as small circles with serif labels, feeling like an illuminated manuscript's marginalia
- **Canon vs. generated distinction** — Canon entries have solid left border (ink black); generated entries have dashed left border (sepia). Subtle but always present.
- **Generous margins** — Especially on entry detail pages. Content breathes. The reading experience is the priority.
- **Minimal chrome** — Navigation is quiet. The toolbar doesn't compete with the content. Buttons are text-styled, not blocky.

### Motion Language

| Interaction | Animation | Duration |
|---|---|---|
| Entry open | Content fades up with slight vertical shift | 200ms ease-out |
| Graph node hover | Connected edges highlight, related nodes pulse subtly | 150ms |
| Generation in progress | Sepia text appears word-by-word (typewriter) | Variable |
| Promote to canon | Dashed border solidifies, sepia shifts to ink | 300ms ease-in-out |
| Consistency flag | Red dot pulses gently until addressed | 2s loop, subtle |
| Graph zoom | Smooth zoom with node labels appearing/hiding at thresholds | 250ms ease |

---

## Relationship to TheRobotLives Ecosystem

Knowledge Base lives at `library.therobotlives.com` — the knowledge/content arm of the [TheRobotLives](../therobotlives/README.md) (NOIZUAI-11) social network.

| Integration Point | Description |
|---|---|
| **Shared auth** | Single account across TheRobotLives and Knowledge Base |
| **Public universes** | Creators can publish universe entries to TRL spaces for community discussion |
| **Agent integration** | TRL-registered agents can be invited as Knowledge Base collaborators (e.g., a history-specialist agent that helps generate period-accurate lore) |
| **Resource cross-pollination** | Prompts and templates used in Knowledge Base can be shared as TRL resources |
| **Reputation** | Active Knowledge Base creators build reputation on the TRL platform |

Knowledge Base is **standalone-viable** — it doesn't require a TRL account. But the integration creates a flywheel: creators build universes → share them socially → community feedback improves the work → more creators join.

---

## Open Questions

These are genuine unknowns — flagging per the "Is this bullshit?" principle:

1. **Consistency engine depth** — How deep does the consistency checker go? Surface-level (duplicate names, date conflicts) is tractable. Deep semantic consistency ("Would this culture *plausibly* develop this technology given their geography?") requires serious reasoning and may not be reliable enough to ship. *Need to define tiers of consistency checking and ship shallow first.*

2. **Canon import fidelity** — Parsing a 300-page manuscript into structured entities is a hard NLP problem. How much manual cleanup is acceptable? If import quality is poor, the bootstrapping experience fails. *Would benefit from testing with real manuscripts across genres before committing to an import-first onboarding flow.*

3. **Generation quality bar** — Generated lore needs to *feel* like the author's voice, not generic fantasy boilerplate. Style transfer is possible but fragile. *Users will likely need to provide writing samples or style guides. How much onboarding friction is too much?*

4. **Graph visualization performance** — A universe with 500+ entries and 2000+ edges is a nontrivial graph rendering problem. Force-directed layouts get slow. *Need to evaluate: Canvas vs. WebGL vs. SVG? What's the upper bound on entries before the graph becomes unusable?*

5. **Multiplayer consistency** — The game dev use case (multiple writers, one universe) introduces merge conflicts for *lore*. What happens when two writers create contradictory entries simultaneously? *Git-style conflict resolution for narrative content is unexplored territory.*

6. **Pricing vs. AI costs** — Every generation request costs inference. Heavy users (game devs with large universes) could burn through margins quickly. *Need to model: how many generations per session does a typical GM/author need? What's the cost ceiling?*

---

## Monetization Angle

| Tier | Includes | Price Signal |
|---|---|---|
| **Free** | 1 universe, 50 entries, basic generation (10/day), consistency checking, manual entry only | Free (onboarding + retention) |
| **Creator** | 3 universes, unlimited entries, 100 generations/day, bulk generation, import/export, graph view | $14-19/mo |
| **Studio** | Unlimited universes, unlimited generations, multiplayer (3 collaborators), API export, session companion, priority generation | $39-49/mo |
| **Team** | Everything in Studio + 10 collaborators, shared template library, admin controls, export to game engine formats | $99-149/mo |

**Revenue accelerators:**

- **Template marketplace** — Sell/share universe templates (e.g., "Medieval European Fantasy starter" with 50 pre-built entries and relationships, "Hard Sci-Fi Solar System" with physics-accurate planetary data)
- **TRL integration premium** — Publishing to TheRobotLives spaces and inviting TRL agents requires Creator tier or above
- **Custom model fine-tuning** — For Studio/Team users: fine-tune generation on your specific writing style (expensive but high-value for professional authors)

---

## Technical Considerations

| Layer | Direction |
|---|---|
| **Knowledge graph storage** | Neo4j or similar graph database for entity-relationship storage. Entries as nodes, relationships as typed edges with metadata. |
| **Full-text + semantic search** | Hybrid: Postgres full-text for exact queries, vector embeddings (pgvector or Pinecone) for semantic search across entries |
| **Generation engine** | Claude API for generation with full canon context injected via RAG. Chunking strategy critical for large universes — need smart context selection, not "dump everything." |
| **Consistency engine** | Rule-based layer (timeline math, name deduplication) + LLM-based layer (semantic contradiction detection). Rules run on every edit; LLM checks run async. |
| **Graph visualization** | D3.js force-directed graph or Cytoscape.js. WebGL renderer for large graphs (500+ nodes). |
| **Frontend** | Next.js App Router. Rich text editor (Tiptap or ProseMirror) for entry authoring. |
| **Auth** | Shared with TheRobotLives (OAuth: GitHub, Google). Standalone mode available. |
| **Export formats** | Markdown, JSON, PDF (styled with Editorial typography), Twine (for interactive fiction), custom game engine schemas |

---

## MVP Scope

### In Scope (v0.1)

- [ ] Single universe project
- [ ] Manual entry creation with 7 entry types (Character, Location, Event, Faction, Object, Concept, Rule)
- [ ] Basic linking between entries (manual + auto-suggested)
- [ ] Knowledge graph visualization (force-directed, filterable)
- [ ] AI generation from single-entry context (not yet full-universe RAG)
- [ ] Canon/generated distinction with promote-to-canon flow
- [ ] Basic consistency checking (timeline conflicts, duplicate names)
- [ ] Search across entries (full-text)
- [ ] Export to Markdown

### Out of Scope (v0.2+)

- Full-universe RAG for generation (requires chunking strategy)
- Bulk generation
- Manuscript import/parsing
- Session companion mode
- Multiplayer / collaborators
- Semantic search
- Template marketplace
- TRL integration
- Game engine export formats
- Deep semantic consistency checking

---

## Status

Concept / Pre-development

**Next steps:**

1. Validate the core thesis: build a prototype that stores 20 entries in a graph DB, runs basic consistency checks, and generates one entry with full context of the other 20
2. Test generation quality: does a generated entry that has read 20 canon entries *feel* consistent and useful, or does it feel like generic AI slop?
3. Test graph visualization: render 100+ entries with D3.js force-directed layout — is it usable, or does it need WebGL?
4. If (1) and (2) work: build the entry editor and graph UI as a Next.js app
5. If (3) works at scale: proceed to import/parsing features
