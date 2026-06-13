# US-189: Title System

**Persona:** Tyler — MMO refugee seeking deep growth systems
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Tyler, I want to earn titles displayed with my character name — such as "Marcus the Unbroken" — from achievements, quests, and reputation milestones so that my in-game accomplishments have visible, persistent social expression.

## Acceptance Criteria
- [ ] Titles earned from three sources: achievement completion (e.g., "the Unbroken" from surviving 100 combat near-deaths), quest lines (e.g., "Champion of Ashveil" from completing the city questline), and reputation standing (e.g., "Merchant's Friend" from Honored with Merchant League)
- [ ] Title selection accessible via character profile settings: keyboard-navigable list of all earned titles with unlock source displayed; SR reads each title as "the Unbroken — earned from achievement: Brushed by Death"
- [ ] Active title displayed in all player-facing contexts: chat messages, inspection panel, combat log attribution, clan roster; format: "{CharacterName} {Title}" (e.g., "Marcus the Unbroken")
- [ ] Title unlock triggers polite ARIA announcement with title and source: "New title earned: the Unbroken — awarded for surviving 100 near-death combat encounters."
- [ ] Players may choose to display no title; "None" is a valid selection in the title picker; SR announces untitled characters by name only
- [ ] Title count displayed in character sheet and inspection panel; SR reads "17 titles earned" as a summary stat
- [ ] Specialization and prestige class names available as title prefixes (US-181, US-183); these are distinct from earned suffix titles and may be combined (e.g., "Guardian Marcus the Unbroken")
- [ ] Titles searchable in player search and inspection context; players may filter clan roster by title for social organization

## Notes
Titles are the most visible prestige signal in a text-based game — they appear in every social context. Tyler wants a title that communicates "I have done difficult things" at a glance (or, for SR users, at a listen). The combination of prefix (class/specialization) and suffix (earned title) creates a name that reads like a medieval epithet — "Guardian Marcus the Unbroken" tells other players everything they need to know about his identity and accomplishments. The unlock source displayed in the title list gives Tyler a personal roadmap — he can see titles he doesn't have yet and understand what he needs to do to earn them. Raj (content creator) will use distinctive title combinations as part of his streaming persona identity.
