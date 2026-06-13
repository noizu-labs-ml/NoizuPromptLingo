# US-053: AI Narrative Voice Consistency

**Persona:** Jamie — Sighted IF Enthusiast / Literature Grad Student
**Priority:** P0
**Epic:** World & Narrative

## Story
As Jamie, I want all AI-generated prose — room descriptions, NPC dialogue, quest hooks, travel vignettes — to share a consistent narrative voice so that the world feels authored by a single intelligence rather than stitched together from disparate generation calls.

## Acceptance Criteria
- [ ] A canonical style guide document defines: tense (present), person (second), register (literary dark fantasy, not grimdark), forbidden words/phrases list
- [ ] All generation prompts include a voice scaffold section referencing the canonical style guide
- [ ] Voice consistency is testable: a sample set of 50 generated passages scores >= 80% on a human-review rubric against the style guide
- [ ] NPC dialogue voice varies by character (a scholar speaks differently than a dockworker) but all remain within the world's register
- [ ] AI-generated text is never raw-output — all passages go through a post-processing validation step that checks for first-person drift, anachronisms, and genre violations
- [ ] Violations are logged and flagged for human review; flagged passages fall back to cached alternatives
- [ ] Style guide is version-controlled and changes require review — AI generation prompts reference a specific style guide version

## Notes
- Jamie will notice voice drift immediately — literary quality is a hard requirement for this persona
- "Forbidden words" list (initial): "suddenly", "you see", "there is/are" as sentence openers, modern slang, passive constructions as the primary sentence structure
- Register: think Ursula K. Le Guin's Earthsea, not George R.R. Martin — precise, restrained, mythic
- The style guide should be part of the repository as a living document — not embedded in prompts only
- Voice consistency also applies to system messages (error text, command feedback) — these should match the world's register where possible
