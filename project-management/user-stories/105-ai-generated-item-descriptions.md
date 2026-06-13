# US-105: AI-Generated Item Descriptions

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial typography, short sessions)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Lena, I want every significant item to have a unique, lore-rich description that reflects its actual history — who made it, what battles it survived, what enchantments were laid into it — so that finding a sword feels like holding a story, not reading a stat block.

## Acceptance Criteria
- [ ] Every item with rarity Common+ receives an AI-generated description on first EXAMINE, covering physical appearance, sensory details, provenance, and any notable history encoded in item metadata
- [ ] Item descriptions are generated once and cached permanently in the item record (PostgreSQL `items.description` column); subsequent EXAMINE calls retrieve cached text with zero LLM latency
- [ ] Description prompt injected with item's full metadata: name, type, material, enchantments, crafter NPC (if any, retrieved from AGE graph), battles survived (kill-count events from physics log), current condition
- [ ] Descriptions are second-person sensory-rich prose matching the game's narrative voice (US-110), 60–120 words: optimized for screen reader read-aloud duration (under 30 seconds at default NVDA speed)
- [ ] Legendary and Artifact tier items receive extended descriptions (150–250 words) with an additional "Lore" section revealed only after player has owned the item for 1+ in-game days (progressive disclosure)
- [ ] Item description regeneration can be triggered by significant events: item reforged, enchantment added, owner dies with it equipped — regeneration appends to existing description rather than replacing
- [ ] Batch pre-generation job runs nightly for all shop inventory items so players never wait on first EXAMINE of vendor stock
- [ ] Description quality flagging: players can flag descriptions as poor quality via EXAMINE [item] FEEDBACK; flagged items queued for regeneration with human review note

## Notes
Item description generation handled by `BladeOfEternity.AI.ItemDescriber` — a GenServer that queues description requests, batches them (up to 20 items per LLM call using structured output with item arrays), and writes results back to PostgreSQL.

Item metadata assembled from multiple sources: `items` table (base stats, material, rarity), `item_events` log (battles, deaths, transfers), AGE graph query for crafter NPC and ownership chain. All assembled into a structured JSON context block injected into the generation prompt.

Prompt template (from registry US-107) for items includes: system prompt establishing narrative voice, item metadata block, instruction for sensory-first prose (touch before sight, smell if applicable), word count constraint, and few-shot examples from "Night at Mordoon" heritage content.

Progressive disclosure for Legendary items: description stored in two fields `description_surface` and `description_lore`. Frontend sends both in the EXAMINE response; client-side JS exposes lore section only after ownership check (resolved via Phoenix Channel message). Screen reader receives full text; sighted UI uses a "Reveal Lore" button.

Regeneration on events handled via `BladeOfEternity.Items.EventHandler` which subscribes to `item_events` PubSub. On reforge/enchant/owner-death events, it schedules a regeneration request with `append: true` flag. The appender generates a single new paragraph ("After the Battle of Ashwood Ford, the blade carries a notch above the fuller...") prepended to history section.

Nightly batch job implemented as Oban worker (`BladeOfEternity.Workers.ItemDescriptionBatch`), scoped to shop inventory items with null description. Runs at 3 AM UTC with concurrency 5 to avoid LLM cost spikes.
