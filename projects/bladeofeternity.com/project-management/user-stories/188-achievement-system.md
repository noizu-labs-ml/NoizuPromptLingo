# US-188: Achievement System

**Persona:** Elena — Blind teenager using VoiceOver on iOS, social and expressive
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Elena, I want to unlock achievements for combat milestones, exploration, crafting, and social interactions that are announced when unlocked and trackable in an accessible panel so that I can celebrate my progress and share accomplishments with friends.

## Acceptance Criteria
- [ ] Achievement categories at launch: Combat (kills, boss defeats, PvP), Exploration (locations discovered, secrets found), Crafting (recipes mastered, items created), Social (friends made, clans joined, help rendered), Progression (levels reached, classes unlocked, prestige achieved)
- [ ] Achievement unlock triggers assertive ARIA announcement with full achievement name and description: "Achievement unlocked: First Blood — You have dealt your first killing blow in player combat."
- [ ] Achievement panel accessible via main menu: keyboard-navigable list organized by category with expandable category headers; SR announces category name and count on focus ("Combat: 12 of 47 unlocked")
- [ ] Each achievement in the panel reads on focus: name, unlock status, description, unlock date if earned, and progress toward incomplete achievements ("Dungeon Delver: 3 of 10 dungeons completed")
- [ ] Progress-tracked achievements update politely via ARIA as milestones are hit ("Dungeon Delver progress: 4 of 10 dungeons completed") without interrupting gameplay
- [ ] Achievement data sharable via character profile (US-200) and visible on inspection panel (US-196) as a count and recent unlock summary
- [ ] Achievements tied to title system (US-189): completing specific achievement sets unlocks associated titles with automatic notification
- [ ] Achievement panel responsive on iOS with VoiceOver: all interactions achievable via VoiceOver gestures, no hover-only interactions

## Notes
Elena's primary motivation for achievements is social — she wants to show friends what she's done and celebrate shared milestones. The iOS/VoiceOver requirement is non-negotiable here since Elena plays on her iPhone. Achievement panels in games frequently rely on hover states for progress details; every piece of information accessible via hover must also be accessible via focus. The assertive announcement on unlock is appropriate here (one of the approved assertive moments) because achievements are milestone events that users expect to interrupt flow. Progress announcements mid-activity should be polite. Achievement descriptions must be written in past tense for unlocked achievements ("You defeated...") and present tense for locked ("Defeat...") — this distinction matters for SR comprehension. Carol (parent) will also use the achievement panel to monitor her child's play patterns.
