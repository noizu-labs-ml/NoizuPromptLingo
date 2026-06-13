# US-145: Container Items

**Persona:** Lena — Tabletop RPG player (38, sighted, editorial, short sessions)
**Priority:** P1
**Epic:** Item Framework & Equipment

## Story
As Lena, I want to use bags and pouches to organize my inventory into logical categories so that I can quickly find what I need during a short session without navigating a disorganized flat item list.

## Acceptance Criteria
- [ ] Container types: belt pouch (8 slots, 2kg capacity), small sack (16 slots, 10kg capacity), traveler's pack (24 slots, 25kg capacity), enchanted bag (variable, purchased/crafted); containers themselves occupy one inventory slot
- [ ] Container items enforce their own slot and weight limits independently from the outer inventory; attempting to exceed either fails with a narrated message: "The pouch is full — you cannot fit another vial."
- [ ] Nested inventory navigation via commands: `open [container]` lists contents; `put [item] in [container]` moves an item; `take [item] from [container]` retrieves an item; `close [container]` returns focus to outer inventory
- [ ] Items inside containers still contribute their weight to total carried weight; the container's own weight also counts — total weight is recursive
- [ ] Container contents are not visible to other players without explicit `show inventory` sharing; containers provide light organizational privacy
- [ ] Short session optimization: Lena can assign a container a label: `label [container] "herbs and alchemy"` — label appears in the container list and in the `open` prompt
- [ ] Screen reader navigation: `inventory` command shows the top-level list with containers appearing as collapsible entries: "belt pouch (4/8 slots, 1.2kg) — [expand]"; expanding reads the contents as a sublist
- [ ] Container stacking: identical empty containers stack (2× empty belt pouch) but containers with contents do not stack

## Notes
The label feature (AC-6) is specifically for Lena's short-session workflow: she wants to label a pouch "session loot" at the start of a dungeon run, dump all dungeon finds into it, and then sort at leisure after the session. The label turns an amorphous bag into a named organizational system.

Nested inventory navigation via commands (AC-3) must produce clean, predictable output for screen reader users. When `open pouch` is issued, the ARIA live region should announce the container name and item count before listing contents: "Belt pouch — 4 items:" followed by the contents. This mirrors how desktop screen readers handle tree structures.

The weight recursion (AC-4) is the technically tricky part: the inventory weight system must perform a depth-first sum of all items, including items inside containers inside containers. Enforce a maximum nesting depth (default: 2 levels — a bag inside a bag, not a bag inside a bag inside a bag) to prevent pathological nesting.

Container privacy (AC-5) is a quality-of-life feature, not a security feature: it just means `look at [player]` descriptions don't enumerate every item in their bags. A skilled thief character class should be able to `peek [container]` on a target with appropriate skill roll — this is a later game feature but the privacy model should anticipate it.

Lena's short sessions mean she will often log off with an open container. Session state should preserve which containers are "open" so that on login, her inventory context is restored.
