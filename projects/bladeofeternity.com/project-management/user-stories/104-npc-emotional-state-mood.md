# US-104: NPC Emotional State and Mood System

**Persona:** Jamie — Interactive fiction enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Jamie, I want NPCs to have authentic emotional states that shift based on how I treat them, what happens in the world, and the passage of time so that the social fabric of the game feels alive and consequential — a merchant I've cheated is cold and guarded; a guard whose family I saved speaks with genuine warmth.

## Acceptance Criteria
- [ ] Each NPC has an emotional state vector covering: calm, angry, fearful, joyful, suspicious, grieving, hopeful — stored as weighted floats in the AGE NPC node, summing to 1.0
- [ ] Emotional state shifts in response to defined triggers: player actions (gift, threat, deception, betrayal), world events (war declaration, plague, festival), time decay (emotions fade toward baseline over 24 real hours)
- [ ] AI dialogue prompt includes current emotional state vector and translates it to prose tone instructions: "The blacksmith is guarded and suspicious. Short sentences. Reluctant to share information. Not hostile but watchful."
- [ ] Mood visibly affects mechanical outcomes: suspicious NPCs add 20% to trade prices; fearful NPCs refuse quests; joyful NPCs offer bonus hints; angry NPCs require a persuasion check before conversation proceeds
- [ ] Players can read emotional subtext via EXAMINE NPC, returning an accessible description: "Aldric's jaw is set. His eyes track the room. Something weighs on him." (Not a direct label — inferred from descriptors)
- [ ] World events propagate emotional shifts via PubSub: when war is declared, all soldier-type NPCs gain fearful/determined blend; merchants gain anxious; civilians gain fearful
- [ ] Emotional state history stored in AGE as timestamped log (max 30 entries); emotional volatility score computed and factored into dialogue prompt (volatile NPCs described as unpredictable)
- [ ] Admin tooling shows current emotional state for any NPC and allows manual override for QA and narrative scripting

## Notes
Emotional state vector stored on AGE NPC node as a JSON property `{calm: 0.4, angry: 0.1, fearful: 0.2, ...}`. Baseline vector defined per NPC archetype (inn-keeper baseline skews calm/joyful; dungeon guard skews suspicious/calm). State updates are atomic AGE transactions — no partial writes.

Emotion engine implemented as `BladeOfEternity.NPC.EmotionEngine` GenServer per NPC cluster (not per NPC — NPCs sharing a zone share a supervision tree for efficiency). Handles `trigger_emotion/3` calls: `{npc_id, trigger_type, intensity}`. Applies delta to current vector, normalizes, persists.

Time decay implemented via scheduled `EmotionDecay` job running every game-hour (configurable real-time ratio). Decay rate per emotion: anger decays fastest (half-life 4 hours), grief decays slowest (half-life 72 hours). Decay pulls toward archetype baseline, not absolute zero.

World event propagation uses Phoenix PubSub topic `world_events:{zone_id}`. `EmotionEngine` subscribes and applies broadcast triggers using a predefined world-event-to-emotion mapping table in application config.

Dialogue prompt injection formats emotional state as a "Tone" section in the system prompt, after character description and before knowledge constraints. Example: "TONE: Mirella is 60% grieving, 30% hopeful, 10% fearful. Her speech should carry the weight of loss with a thread of desperate optimism. She does not weep openly but pauses often."

Mechanical outcome checks implemented in `BladeOfEternity.NPC.InteractionGate` — checked before any trade, quest, or information exchange. Results surfaced to player via narrative description rather than game-mechanical UI language.
