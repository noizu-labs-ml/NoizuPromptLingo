# US-048: Emergent Quest Generation

**Persona:** Tyler — Sighted MMO Refugee / Player Agency Seeker
**Priority:** P0
**Epic:** Quest & Narrative

## Story
As Tyler, I want quests to emerge from the world's state and NPC needs — not from a pre-authored quest log — so that my choices feel like they matter and the content never feels like a theme park ride I'm just running through.

## Acceptance Criteria
- [ ] Quests are generated from NPC goal states, world events, and player history — not pre-scripted quest scripts
- [ ] Quest hooks are presented in-world through NPC dialogue or environmental discovery, never as a pop-up UI
- [ ] Each generated quest has: a hook (why the player was approached), stakes (what happens if they succeed/fail/ignore), and at least two resolution paths
- [ ] Quest state (active, completed, failed, abandoned) persists and affects future NPC behavior and world state
- [ ] Players can be in multiple quests simultaneously with no artificial cap
- [ ] `quests` command lists active quest hooks with brief context (not walkthroughs)
- [ ] Failing or abandoning a quest has consequences visible in the world (NPC attitude shift, world state change)
- [ ] Quest generation avoids repetition — the system tracks recently-generated quest types per area and diversifies

## Notes
- Tyler burned out on WoW-style questing; the explicit rejection of "go here, kill X, return" structures is a design pillar
- Quest generation is AI-driven, seeded with: NPC persona + goal, world state snapshot, player character profile
- Quest descriptions accessible to blind players via `quests` must convey stakes without visual iconography
- Resolution path tracking must be robust — partial completions (player resolves one aspect but not another) must be supported
- Economic shift world events (US-055) are a primary driver of NPC-generated quests (merchant needs courier, debt collector needs enforcer)
