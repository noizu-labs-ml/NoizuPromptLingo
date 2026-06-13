# US-179: Skill Tree System

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P0
**Epic:** Character Progression & Classes

## Story
As Tyler, I want a branching skill tree for my class where I invest skill points earned on level-up so that I can customize my playstyle and feel genuine ownership over my character's development path.

## Acceptance Criteria
- [ ] Each base class has a dedicated skill tree with minimum three branches (e.g., Warrior: Offense, Defense, Leadership), each branch containing 5-8 skills across three tiers
- [ ] Skill tree navigable by keyboard: arrow keys traverse nodes, Enter invests a point, Escape backs out; focus order follows logical prerequisite chains
- [ ] SR announces each node on focus: skill name, tier, point cost, prerequisite status ("requires Blade Mastery I"), current level (0/3), and full effect description
- [ ] Prerequisite skills visually and semantically indicated: locked skills announced as "locked — requires {prerequisite} at rank {N}" with no silent unavailability
- [ ] Skill point balance displayed persistently in tree view and announced on entry: "3 unspent skill points available"
- [ ] Investment confirmation required for each point spent; confirmation dialog reads skill name, new rank, and effect change before committing
- [ ] Skill point refund available at in-game cost (gold or special item); refund resets all points in one branch or full tree with separate confirmation
- [ ] Skill tree state persisted server-side; client renders from server state to prevent desync between sessions

## Notes
The accessible tree navigation is the hardest UX problem in this epic. Visual skill trees are inherently spatial — they communicate hierarchy and branching through layout. For SR users, we must translate that spatial understanding into a sequential traversal that preserves logical structure. Recommended implementation: expose the tree as a nested list with ARIA `role="tree"` and `role="treeitem"`, using `aria-expanded` for branches and `aria-disabled` for locked nodes. The announcement cadence on node focus must be complete but not verbose — players will traverse many nodes. Consider a "brief" mode announcing only name and availability, with a detail key (e.g., Space) for full description. Tyler will min-max; Dave will explore everything; Elena just wants to feel powerful. All three paths through the tree must feel rewarding.
