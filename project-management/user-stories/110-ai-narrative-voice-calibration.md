# US-110: AI Narrative Voice Calibration

**Persona:** Jamie — Interactive fiction enthusiast (26, sighted, narrative quality)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Jamie, I want every piece of AI-generated prose in the game to share a consistent, distinctive narrative voice — second-person, sensory-rich, precise — so that the writing feels authored rather than generated, and no room description or NPC line breaks the immersion by sounding like it came from a different game.

## Acceptance Criteria
- [ ] All generation domain prompt templates include the canonical narrative voice specification: second-person present tense, sensory priority order (touch/temperature → sound → smell → sight), sentence length variation (short punchy then longer flowing), no adverb clusters, no passive constructions for action
- [ ] Voice calibration maintained via a set of 12 curated few-shot examples drawn from "Night at Mordoon" heritage content, included in every generation prompt's system section
- [ ] Voice consistency score computed for each LLM response using a lightweight classifier (fine-tuned or prompted) that scores second-person adherence, sensory density, and sentence rhythm — logged per domain (US-125)
- [ ] Generation domains with voice consistency score below 0.75 over a 24-hour window trigger admin alert for prompt review
- [ ] Narrative voice spec and few-shot examples managed through the template registry (US-107) so voice can be evolved without code changes
- [ ] Room, item, combat, quest, and ambient generation domains each have 3 domain-specific voice examples in addition to the 12 shared examples, calibrating for domain-appropriate length and focus
- [ ] Voice constraint violations (passive voice, second-person slip to third, adverb cluster) detectable via rule-based post-processing and logged for prompt engineering feedback
- [ ] New generation domains (future features) must pass a voice calibration review with 5 example outputs reviewed by narrative designer before going to production

## Notes
The "Night at Mordoon" heritage content is the canonical voice reference — the game's founding text. A curated set of 12 passages (2-4 sentences each) selected to cover: room entry, NPC first impression, combat moment, item discovery, environmental weather, time-of-day transition, emotion/dread, wonder/beauty, mundane detail made strange, social tension, physical exertion, aftermath/quiet. These 12 passages appear in the `narrative_voice` prompt template block included by all domain templates.

Voice spec (stored in template registry as `voice_spec` shared block):
```
- Second person present tense ("You push open the door. Cold air meets your face.")
- Sensory hierarchy: physical sensation first when relevant, then sound, smell, sight last
- Sentence rhythm: vary 3-7 word short sentences with 12-20 word longer ones
- No "very", "really", "quite", "just" as adverbs
- No passive voice for physical actions
- Avoid: "you see", "you notice", "you feel" — show instead
- Dialogue attribution: "says", "asks", "replies" — no said-bookisms
```

Voice consistency scorer: a prompted evaluation using a lightweight LLM call (or the same model with a scoring prompt) that returns `{second_person: bool, sensory_present: bool, no_adverb_clusters: bool, rhythm_varied: bool, score: float}`. Runs async on 20% of production outputs, 100% in staging. Results written to `ai_quality_log` table.

Rule-based violation detection via `BladeOfEternity.AI.VoiceValidator` — compiled regex checks for: third-person pronouns in player-directed text, adverb cluster patterns (`\b(very|really|quite|just|so)\s+\w+ly\b`), passive constructions (`\bwas\s+\w+ed\b`, `\bwere\s+\w+ed\b`). Violations logged to Telemetry counter per domain.

Domain-specific few-shot examples stored as separate template blocks: `voice_examples_room`, `voice_examples_combat`, etc. Combined in template EEx: `<%= render_block(:voice_base_examples) %>\n<%= render_block(:voice_examples, domain) %>`.

Voice calibration review process: new domain templates require PR with 5 sample outputs, narrative designer sign-off in PR review, and voice consistency score ≥ 0.80 on test suite before merge.
