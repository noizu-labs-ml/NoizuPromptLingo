# US-113: Procedural Lore Generation

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial typography, short sessions)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Lena, I want the world to be full of discoverable lore — books on shelves, inscriptions on walls, legends told by bards — that feel like they belong to a coherent world with deep history, and that I can revisit in short sessions without worrying that something contradicts what I read last time.

## Acceptance Criteria
- [ ] AI generates discoverable lore artifacts (books, inscriptions, tablets, legends, overheard tales) that are internally consistent with established world canon stored in the lore graph
- [ ] Lore graph maintained in Apache AGE: canon facts, historical events, place names, deity names, faction history — all lore generation constrained to extend (not contradict) this graph
- [ ] Each generated lore artifact is stored permanently in the lore database after first generation; subsequent reads retrieve cached text — no regeneration on re-discovery
- [ ] Lore canon validator runs on all generated artifacts before storage: checks entity names, dates, and faction relationships against canon facts, flags contradictions for human review
- [ ] Lore artifacts are categorized by type (book, inscription, legend, rumor) and presented with appropriate formatting: books use a distinct ARIA region styled as "reading mode", inscriptions are brief and mysterious, legends have a storytelling cadence
- [ ] Lore discovery tracked per player in PostgreSQL: players can READ JOURNAL to review all discovered lore with entry titles and discovery locations, navigable by ARIA heading structure
- [ ] New canon facts extracted from human-authored content are added to the lore graph via an ingestion pipeline; AI-generated facts that pass validation are marked as "derived canon" and also added to extend the graph for future generation
- [ ] Lore generation frequency tunable per zone: ancient ruins generate inscriptions on most surfaces; towns have occasional books; wilderness has rare carved stones or travelers' tales

## Notes
Lore graph in AGE: `(:LoreEntity {name, type, description})` — entity types: Person, Place, Event, Deity, Faction, Artifact. `(:LoreEvent {name, date_approximate, description})-[:INVOLVES]->(:LoreEntity)`. `(:LoreFact {content, source, canon_level})` — canon levels: `authored` (human-written), `derived` (AI-generated and validated), `speculative` (AI-generated, unvalidated).

Canon validator (`BladeOfEternity.Lore.CanonValidator`) implements Cypher queries to check: entity names in generated text against AGE nodes (fuzzy match with Levenshtein distance ≤ 2 allowed for variant spellings), date claims against LoreEvent nodes, faction relationships against existing edges. Contradiction detection is conservative — flagged artifacts go to admin review queue, not auto-rejected, since apparent contradictions may be valid in-world mysteries.

Lore generation prompt includes: the lore entity's context (location type, zone history, nearby faction), a summary of top 20 canon facts retrieved from AGE (relevant to zone), lore artifact type instructions (length, tone, perspective), and the narrative voice spec (US-110). For inscriptions: max 40 words, archaic register, first-person plural ("We who built these halls...").

"Reading mode" ARIA region: on READ [book/inscription], frontend renders a modal-style region with `role="document"` containing the lore text, accessible via SR virtual cursor. A "Close reading" action (Escape or explicit command) returns focus to main narrative region. This matches how document reading works in real screen reader usage.

Lore journal implemented as a PostgreSQL `lore_discoveries` table: `{player_id, lore_artifact_id, discovered_at, location_name}`. READ JOURNAL command queries this table, returns sorted list by discovery date with lore titles and locations as ARIA heading navigation (h3 per entry).

Derived canon ingestion: after lore artifact passes validation, `LoreCanonIngester` extracts named entities and claimed facts from the text using an extraction LLM call, creates AGE nodes/edges tagged `canon_level: derived`. Future generation queries now include these derived facts, allowing lore to build on itself coherently across regions and time.

Zone frequency configuration in `zone_config.yaml` per zone: `lore_density: high/medium/low/none`. High-density zones (ancient ruins) generate lore on 80% of EXAMINE actions on surfaces; low-density (wilderness) on 10%. Generated and cached, so density refers to artifact presence, not generation frequency.
