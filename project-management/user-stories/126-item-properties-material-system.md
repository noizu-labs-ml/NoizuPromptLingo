# US-126: Item Properties Material System

**Persona:** Dave — MUD veteran sysadmin (45, sighted, deep systems)
**Priority:** P0
**Epic:** Item Framework & Equipment

## Story
As Dave, I want every item to carry structured material properties so that the physics engine, crafting system, and combat narration can all derive realistic, consistent outcomes from the same underlying data.

## Acceptance Criteria
- [ ] Each item stores a `material` field from a canonical enum: iron, steel, bronze, leather, bone, crystal, wood, cloth, stone, and extensible admin-defined types
- [ ] Material records include: density (kg/L), hardness (Mohs-equivalent), flammability (0–100), conductivity (electrical/thermal), acoustic signature (brittle/resonant/dull), and base durability modifier
- [ ] Physics engine consumes material data: steel-on-stone sparks, wood splinters on critical hits, crystal shatters if hardness threshold exceeded, leather deforms silently
- [ ] Combat narration pulls material-specific prose templates: "your iron blade grinds against the stone golem" vs "your crystal dagger shatters against the stone golem's hide"
- [ ] Crafting system uses material properties to compute recipe viability, required tools (you cannot hammer crystal), and output quality modifiers
- [ ] Admin can define new materials via config without code deploy; new material YAML validated on load and rejected with clear error if required fields missing
- [ ] Item inspection command returns full material breakdown in both terse (combat-speed) and verbose (examine) modes
- [ ] Material interactions are logged to the physics event stream for downstream consumers (sound engine, narrative engine, analytics)

## Notes
Material data should live in a separate `materials` table/config, not embedded in each item record, so updating iron properties retroactively affects all iron items. Items store a `material_id` foreign key.

Physics interaction matrix: a lookup table mapping (material_A, material_B, interaction_type) → (effect_set). This matrix is the contract between the physics engine and the narrative engine. Both read from it; neither writes to it at runtime.

Flammability interacts with the environmental physics system: a wooden item near a fire source accrues heat over time and may auto-ignite if threshold crossed, generating ARIA live region announcement.

Crystal as a material presents interesting design space: highest damage multiplier against unarmored targets, shatters on critical failure or versus hard materials. Should feel like a high-risk/high-reward choice Dave can theorycraft around.

Acoustic signature feeds into the stealth system — dragging bone armor across stone is loud; leather is quiet. This property is consumed by the spatial/kinetic physics engines.

For screen reader users, material is always announced in the item short-description (e.g., "iron longsword") so no additional navigation is required to know what something is made of.
