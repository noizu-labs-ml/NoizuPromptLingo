# US-128: Item Durability Degradation

**Persona:** Tyler — MMO refugee (22, sighted, growth/clans)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Tyler, I want my equipment to visibly degrade through use so that gear maintenance becomes a meaningful economic pressure and the condition of my weapons tells the story of my battles.

## Acceptance Criteria
- [ ] Each item has a `durability` integer (current) and `max_durability` integer; both stored in item record and updated on relevant events
- [ ] Weapons lose durability on each attack (base rate by material: crystal degrades fastest, steel slowest); armor loses durability on each hit received, scaled by damage dealt
- [ ] Five prose condition bands trigger at defined thresholds and update the item's short description automatically:
  - 100–81%: "your blade gleams, honed to a perfect edge"
  - 80–61%: "your blade carries the honest scars of battle"
  - 60–41%: "nicks line the edge of your blade"
  - 40–21%: "your blade is badly notched and struggles to hold an edge"
  - 20–0%: "the blade is nearly spent — one hard blow may shatter it"
- [ ] At 25% durability a warning is delivered via ARIA live region (polite) once per session per item: "Warning: your iron longsword is badly worn."
- [ ] At 0% durability the item becomes unusable; attempting to use it narrates: "Your blade shatters under the strain — the hilt alone remains in your hand."
- [ ] Broken items can be repaired (see US-129) but not used; they persist in inventory as broken objects
- [ ] Durability degradation rate is configurable per item type via admin config; special materials can have non-linear degradation curves

## Notes
Condition bands should use the item's material in the prose. A leather vest degrading should say "the stitching begins to fray" not "nicks line the edge." The LLM narrative engine should select from material-appropriate condition templates.

Tyler comes from MMOs where gear degradation is often punishing but creates an ongoing gold sink and repair economy. The goal is meaningful pressure without frustration — the warning at 25% gives players time to act.

At 0% durability, the item should not be silently removed from the inventory. Players need to know their broken sword is in their bag so they can repair it. The broken state is persistent.

Shields and armor degrading on hits means active tanks will consume repair materials fastest — this is intentional economic design. Pure DPS characters face less degradation pressure but are still affected by weapon wear.

For the shatter event at 0%, the physics engine should generate a break event that can propagate to the environment: crystal items that shatter might spray fragments that deal minor AoE damage or create difficult terrain.
