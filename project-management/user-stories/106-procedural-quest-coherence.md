# US-106: Procedural Quest Coherence

**Persona:** Jamie — Interactive fiction enthusiast (26, sighted, narrative quality)
**Priority:** P0
**Epic:** LLM & AI Systems

## Story
As Jamie, I want AI-generated quests to maintain internal coherence across all steps, sessions, and my choices so that the story holds together like a well-edited novel — NPCs I was sent to find are actually findable, motivations remain consistent, and the ending feels earned rather than arbitrary.

## Acceptance Criteria
- [ ] Quest state machine enforced by a coherence validator that checks each generated step against the established quest facts (entities, locations, motivations, MacGuffins) before committing the step to the quest log
- [ ] Quest fact registry stores canonical facts per quest instance: named entities, claimed locations, stated motivations, promised rewards — validator flags and rejects AI outputs that contradict any canonical fact
- [ ] Branching player choices are recorded as quest state transitions; subsequent AI generation receives the full choice history so NPC reactions and world acknowledgments remain consistent
- [ ] Quest generation spans a dedicated long-context prompt containing the full quest outline, fact registry, player choices to date, and current world state — never a stateless one-shot generation
- [ ] When AI output would violate coherence (detected contradiction), the system regenerates with an explicit constraint appended to the prompt ("The informant's name is Vasek — do not change this"); maximum 3 retries before falling back to template completion
- [ ] Cross-session continuity: quest state persisted to PostgreSQL at every step; on login, quest context is rehydrated from DB before any generation call
- [ ] Quest timeline validated for causal consistency: if Step 3 requires an item introduced in Step 2, validator confirms Step 2 was completed before generating Step 3 content
- [ ] QA tooling allows narrative designers to simulate quest playthrough with inspection of coherence validator decisions and contradiction detection logs

## Notes
Quest coherence is the hardest AI quality problem in the system. The core insight: treat each quest as a mini-knowledge-base that AI must be constrained to extend, not rewrite.

Implementation: `BladeOfEternity.Quest.CoherenceValidator` — a pure functional module that takes a `QuestFact` registry struct and a proposed `QuestStep` struct, returns `{:ok, step}` or `{:error, contradiction, field}`. Called synchronously in the quest generation pipeline before any DB write.

`QuestFact` registry is an Elixir struct with typed fields: `entities :: [%{name, role, location}]`, `locations :: [%{name, description, accessible}]`, `macguffins :: [%{name, described_as, last_seen}]`, `motivation :: String.t()`, `promised_reward :: %{type, amount}`. Populated from the initial quest generation and updated (append-only) at each validated step.

Fact registry serialized to JSON and stored in `quest_instances.fact_registry` (PostgreSQL JSONB column). Also injected into the generation prompt as a "CANON FACTS — DO NOT CONTRADICT" block, formatted as a numbered list for clear LLM instruction.

Contradiction detection rules implemented as pattern matches: entity name mismatch (fuzzy match with Levenshtein distance threshold), location reachability check (AGE graph query confirming location exists and is connected to player's region), motivation flip detection (embedding cosine similarity between new motivation statement and canonical one — flagged if similarity < 0.7).

Regeneration loop in `BladeOfEternity.AI.QuestGenerator.generate_step/3`: try → validate → if contradiction, append constraint to prompt and retry, up to 3 times, then escalate to template fallback which generates a coherent-but-generic step using fact registry values directly.

Cross-session rehydration: on quest context load, `QuestContextAssembler` issues PostgreSQL query for quest state + fact registry + choice history, assembles into `QuestContext` struct, stores in player's ETS session data. Context is ready before any generation call in that session.
