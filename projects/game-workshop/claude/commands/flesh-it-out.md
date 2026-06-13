# Flesh It Out

Pick a random game concept from `idea-log/` and expand it into a full game design document.

## Instructions

### Step 1: Pick and Move

1. Pick a random `.md` file from `idea-log/` (use `ls idea-log/ | sort -R | head -1`)
2. Read the selected file
3. Create a directory under `flesh/` using the file's slug (filename without `.md`)
4. Move the file into the new directory and rename it to `README.md`

```
idea-log/whispering-grottos.md → flesh/whispering-grottos/README.md
```

### Step 2: Read Project Context

Read these files for persona references and domain context:

- `project-management/personas/index.yaml` — Persona library index
- The top 3-4 most relevant persona files based on the game's genre, platform, and audience (check tags in the index)
- `mad-libs-bank.yaml` — If the game concept references any template elements, understand the vocabulary
- `game-premises.yaml` — Genre context for the concept's category

### Step 3: Flesh Out the README.md

Rewrite `flesh/{slug}/README.md` as a comprehensive game design document. Preserve the original concept's core idea, title, and tone — then expand significantly using the **game-design** skill's methodology.

The expanded document must include ALL of these sections:

#### Required Sections

1. **Title & Genre** — Preserve original title. Add engine choice, platform targets, monetization model, and rating.

2. **Vision Statement** — One paragraph: what the game is, how it feels, why it exists.

3. **Core Loop** — The minute-to-minute gameplay cycle as a diagram + detailed breakdown. Specify target session length. Every step must be actionable (what does the player DO?).

4. **Meta Loop** — Session-to-session progression. What carries between sessions? What are the progression axes (what grows, and how does growth feel)?

5. **Game Mechanics** — Deep dive into every system:
   - Primary mechanic with full detail (not just "crafting system" — what are the inputs, outputs, constraints, edge cases, skill ceiling?)
   - Secondary mechanics that interact with the primary
   - Difficulty progression table showing how complexity escalates across chapters/levels
   - No failure states or harsh punishment unless the genre demands it — prefer mastery layers

6. **World Design** — Map structure (hierarchical or interconnected), art direction pillars, visual/audio progression. Include a concrete table or diagram showing how the world changes as the player progresses.

7. **Narrative** — Full 8-point story spine (equilibrium → inciting incident → first complication → rising action → midpoint reversal → crisis → climax → resolution). Define tone on the 7-axis spectrum. If spirits/characters exist: table of all characters with themes and fragment counts.

8. **Player Personas** — Select 3-4 personas from `project-management/personas/` that fit this game. For each persona:
   - Why this game fits them
   - Their predicted experience (how they'll play, what they'll love, what they'll skip)
   - Reference by persona ID and name
   - Do NOT create new personas — use existing ones only

9. **User Stories** — Write 25-35 user stories organized by category (exploration, core mechanics, narrative, progression, accessibility, social). Each story follows `As a [persona], I want [goal] so that [benefit]`. Tag stories with persona IDs where relevant. Prioritize stories that serve the primary personas.

10. **Monetization** — Revenue model with justification. If premium: pricing, DLC roadmap, revenue projections (4 scenarios from modest to breakout). If F2P: IAP catalog with price points, battle pass structure, ad strategy, KPI targets. Always include a "why this model fits this game" rationale.

11. **Production Plan** — Team table (role, count, phase, cost). Timeline with monthly milestones. Budget breakdown by category. Be realistic — match scope to team size.

12. **Technical Requirements** — Platform-specific specs (min/rec for PC, per-console targets). Key technical challenges with mitigation strategies.

### Quality Standards

- **Preserve the original concept's soul** — Don't change the core idea, just expand it
- **Every table must have real data** — No placeholder rows or "TBD" cells
- **Personas must come from the existing library** — Reference by ID (P-001 through P-020)
- **User stories must be specific and testable** — Not "the game should be fun"
- **Numbers must be realistic** — Budget, timeline, team size must be internally consistent
- **Mechanics must be playable in the reader's head** — Enough detail that a developer could prototype from the description alone
- **The document should stand alone** — No "see above" or cross-references to external docs that aren't included

### Writing Style

- Use tables over prose for structured data (mechanics, specs, schedules, budgets)
- Use code fences for diagrams and loops
- Use headers liberally — the document should be scannable
- Write in present tense ("the player explores" not "the player will explore")
- Be specific: "47 herbs in 6 families" not "many herbs"
- Be opinionated: make design decisions, don't present options without recommending one
