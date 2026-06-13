# AI and Narrative Architecture

## GenAI Integration

The backend uses the `genai` Elixir library (Noizu) for all AI-driven content generation. The AI layer sits between the simulation engine and the output pipeline — it consumes structured event data and produces prose.

## Narrative Generation Domains

### Room Descriptions
- Vary with time of day, weather, player history, and world state
- First visit vs. return visit awareness
- Reflect persistent world changes (destruction, player modifications)

### NPC Dialogue
- Context-responsive rather than scripted branches
- NPCs have goals, routines, relationships, and memories (persisted via AGE graph)
- Dialogue reflects NPC's current state, relationship with player, and recent world events

### Combat Prose
- Translates physics simulation outcomes into readable action
- Maintains consistent voice and tone across encounters
- Batches related events into coherent passages (one combat round = one narrative beat)

### Quest Narratives
- Emerge from world conditions rather than pre-authored chains
- Branch based on player choices with persistent consequences
- AI maintains narrative coherence across long quest arcs

### World Events
- AI monitors aggregate player behavior and world state
- Generates emergent events: economic shifts, NPC migrations, evolving festivals
- Events have persistent effects on the world

## Voice Consistency

The original game's writing voice (demonstrated in the "Night at Mordoon" interactive fiction) serves as the training signal. The AI maintains:

- Second-person present tense for action ("You swing your blade...")
- Rich sensory detail prioritizing non-visual senses (sound, touch, smell, temperature)
- Concise but evocative — screen reader users need information density without verbosity

## Physics-to-Prose Contract

The AI narrator never outputs raw numbers. Simulation data (force vectors, distances, collision normals) is translated to natural language:

| Simulation Data | Prose Output |
|----------------|-------------|
| `distance: 7, unit: paces, cover: partial` | "The brute is seven paces ahead, partially hidden behind a collapsed pillar" |
| `force: high, direction: ricochet, secondary_effect: fire` | "Your slingshot stone ricochets off the wall and strikes the lantern — oil splashes, and the far corner catches fire" |
| `sound_level: loud, environment: corridor, obstruction: rain` | "Rain hammers the stone above you. The hallway amplifies each drop into a roar" |
