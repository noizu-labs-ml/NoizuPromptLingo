# US-214: Area of Effect Abilities

**Persona:** Dave — MUD veteran sysadmin, sighted, deep systems focused
**Priority:** P1
**Epic:** Advanced Combat & Tactics

## Story
As Dave, I want AoE abilities to affect enemies based on actual spatial zones computed by the physics engine so that positioning truly matters, and I can predict and optimize AoE placement without needing a visual grid.

## Acceptance Criteria
- [ ] AoE abilities specify zone shape and size in ability description: "15-foot radius sphere", "30-foot cone", "10-foot line" — consistent vocabulary throughout
- [ ] Before confirming an AoE action, system announces predicted targets: "This will hit: Orc Captain, Goblin Scout x2, Bandit Archer. 2 allies are outside the zone." — computed by physics engine
- [ ] Zone origin specified by targeting: choose an enemy (AoE centered on them), a direction (cone), or a relative position keyword (near/far/left/right of current position)
- [ ] Physics engine computes actual targets accounting for 3D positions, obstacles, and cover; results may differ from rough estimates
- [ ] AoE results batched into a single narration entry: "Your Fireball detonates — the Orc Captain takes 45 fire damage, both Goblin Scouts take 38, the Bandit Archer at the edge takes 19 (partial coverage)"
- [ ] Persistent AoE zones (fire walls, poison clouds) announced on creation with duration, then mentioned at round start if active: "The poison cloud still fills the eastern alcove — 3 rounds remaining"
- [ ] Friendly fire from AoE explicitly warned in targeting preview; confirmation required if any allies are in zone
- [ ] AoE ability menu entries include range and zone size as structured accessible text; Dave can review without entering targeting mode

## Notes
Dave's sysadmin instinct is to understand systems completely before using them — he wants to know exactly how AoE targeting works, what the zone looks like, and who it will hit before committing. The pre-targeting preview is the critical feature: it's the equivalent of the visual targeting circle that sighted players in graphical games rely on. The physics engine must be able to do a "preview computation" (dry run) before the actual action executes. Persistent zone narration at round start is important for tactical planning — knowing the poison cloud is still active helps Dave decide whether to push enemies toward it. The batched result narration prevents SR flooding while still conveying all outcomes; ordering by damage (highest to lowest) or by position (nearest to farthest) gives Dave the analytical summary he wants. Zone position keywords (near/far/left/right) must be consistent with the position vocabulary used in the position summary (US-206) so the spatial model feels unified. Dave will likely abuse AoE to cluster enemies — the system should reward good positioning rather than fighting it.
