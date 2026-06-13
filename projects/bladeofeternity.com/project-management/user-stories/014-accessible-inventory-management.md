# US-014: Accessible Inventory Management

**Persona:** Marcus — Blind power gamer (NVDA + Firefox)
**Priority:** P1
**Epic:** Core Accessibility / Screen Reader

## Story
As Marcus, I want to browse, equip, drop, and compare inventory items using only my keyboard and screen reader so that item management does not require visual scanning of a grid layout.

## Acceptance Criteria
- [ ] Inventory is presented as a `role="grid"` or navigable `<table>` with columns: Name, Type, Rarity, Stats Summary, Equipped status
- [ ] Each row is actionable — Enter or Space opens an item context menu (Equip / Drop / Inspect / Compare)
- [ ] Item context menus follow the APG menu pattern: arrow keys to navigate options, Enter to select, Escape to close
- [ ] "Compare" mode reads the stat delta aloud: "Shadowblade: +45 attack, -12 defense versus equipped Ironedge"
- [ ] Item rarity is conveyed via text, not color alone (e.g., "Rare — Shadowblade" not just a colored label)
- [ ] Inventory can be sorted by column via keyboard; sort direction is announced: "Sorted by Rarity, descending"
- [ ] A search/filter input above the inventory filters the grid in real time; result count announced: "12 items match"
- [ ] Drag-and-drop hotbar assignment has a keyboard alternative: select item, press Alt+1 through Alt+9 to assign to hotbar slot

## Notes
Grid navigation (arrow keys move between cells) must not conflict with screen reader arrow key behavior — the grid must be in application mode. Ensure `aria-rowcount`, `aria-colcount`, `aria-rowindex`, and `aria-colindex` are set for virtual scroll windows if the inventory is large. Rarity-by-color is the single most common accessible gaming failure — enforce text-only rarity from day one.
