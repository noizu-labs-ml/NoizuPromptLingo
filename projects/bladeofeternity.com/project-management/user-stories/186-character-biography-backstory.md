# US-186: Character Biography & Backstory

**Persona:** Jamie — Interactive fiction enthusiast focused on narrative quality
**Priority:** P1
**Epic:** Character Progression & Classes

## Story
As Jamie, I want to write or AI-generate a character backstory that the game's LLM integrates into NPC interactions so that my character feels like a specific person with history rather than a blank stat sheet.

## Acceptance Criteria
- [ ] Character creation includes an optional biography step: free-text field (500-word limit) for manual entry, or an AI-assisted generation flow with guided prompts (origin region, formative event, motivation, secret)
- [ ] AI generation produces a 150-250 word backstory based on guided prompts; player may edit the result before saving; SR reads generated text in full before confirmation
- [ ] Backstory stored server-side and passed to the LLM narrative engine as context; NPCs may reference backstory details in dialogue when contextually appropriate (e.g., NPC from backstory origin region speaks with familiarity)
- [ ] Backstory references in NPC dialogue clearly woven into narrative, not surfaced as "[BACKSTORY REFERENCE]" markers; quality gate: at least 3 distinct backstory elements must be referenceable by LLM
- [ ] Biography viewable on character profile page; player controls visibility: private (self only), friends only, or public
- [ ] Biography editable at any time via character profile settings; edits re-submitted to LLM context within 15 minutes of save
- [ ] SR-accessible text editor for biography with full keyboard support; character count announced on focus and updates as player types
- [ ] Other players may view public biographies via the inspection panel (US-196) with SR-readable biography section

## Notes
This feature is Jamie's primary hook — narrative immersion through personal history. The LLM integration is the differentiator from other RPGs: your backstory isn't decoration, it's data the world reads. Quality of NPC backstory references must be high; shallow references ("Oh, you're from the north?") feel like template-filling. Deep references require the LLM to actually understand and synthesize backstory content — prompt engineering and context window management are non-trivial here. Privacy settings respect Carol's concerns (US-199) about her child's public profile. The AI generation flow must be usable by Elena (16, VoiceOver) without barriers — all guided prompt fields must be SR-accessible. Enforce content moderation on biography text before storage: run against the same content policy as chat messages.
