# US-083: Adaptive Tutorial First-Time Experience

**Persona:** Carol — Sighted parent of blind daughter (14) and sighted son (12)
**Priority:** P0
**Epic:** Onboarding

## Story
As Carol, I want my children to each receive a tutorial tailored to their input method and accessibility needs so that both can learn the game independently without one child being disadvantaged.

## Acceptance Criteria
- [ ] Tutorial detects active accessibility technology (screen reader, switch access, touch) and adapts instructions accordingly
- [ ] Screen reader users receive text-first instructions; sighted users receive visual callout highlights plus text
- [ ] Tutorial can be paused at any step and resumed from the same point in a later session
- [ ] All tutorial prompts use plain language at approximately an 8th-grade reading level
- [ ] Tutorial is skippable for experienced players, with a confirmation prompt before skipping
- [ ] A "replay tutorial" option is accessible from the settings menu at any time
- [ ] Tutorial completion state is saved per character, not per account

## Notes
Two children on one account (or sibling accounts) should not see tutorial re-triggered. Consider an explicit "Are you new to text MUDs?" branching question at the start rather than relying solely on AT detection.
