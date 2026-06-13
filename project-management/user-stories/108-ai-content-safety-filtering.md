# US-108: AI Content Safety Filtering

**Persona:** Carol — Parent of blind child (42, sighted, safety/onboarding)
**Priority:** P0
**Epic:** LLM & AI Systems

## Story
As Carol, I want all AI-generated content to be filtered through a safety pipeline before it reaches my child so that the game's dynamic narrative never produces content beyond the age rating I've configured — violence thresholds, language, and thematic darkness all stay within the bounds I've set, regardless of how the AI generates.

## Acceptance Criteria
- [ ] All AI-generated content passes through a pre-delivery safety filter before ARIA injection or text display; no AI output reaches the client unfiltered
- [ ] Safety filter supports four configurable content tiers: Family (E10+), Teen (T), Mature (M), Unrestricted — each with defined thresholds for violence intensity, language severity, thematic darkness, and sexual content (zero-tolerance across all tiers)
- [ ] Filtering implemented as two-pass pipeline: (1) rule-based pattern matching for prohibited terms and explicit content (fast, synchronous), (2) LLM-based contextual review for violence intensity and thematic darkness (async, sampled at 10% of content in production)
- [ ] Content tier stored on player account and enforced server-side; client-side tier setting is display-only — server rejects tier changes not confirmed via parental PIN (for accounts flagged as child accounts)
- [ ] Filtered content replaced with sanitized alternative: generated via a secondary "sanitize" prompt call using the same context but with tier-appropriate constraints in the system prompt, delivered within 500ms
- [ ] Content safety violations logged with: player_id, content hash, violation category, tier attempted, tier actual — retained 90 days for abuse investigation
- [ ] Parents receive weekly digest email of content tier usage statistics for child accounts: domains accessed, any sanitization events, session durations
- [ ] Integration tests cover all four tiers with representative violent, dark, and language-heavy content samples, verifying correct blocking and sanitized replacement

## Notes
Content safety is a zero-defect requirement — a single inappropriate content delivery to a child account is a critical incident. The architecture must be conservative: prefer false positives (unnecessary sanitization) over false negatives (inappropriate content delivered).

Rule-based pass implemented as `BladeOfEternity.AI.Safety.PatternFilter` — compiled regex match against a curated prohibited term list per tier. Term lists stored in `priv/safety/` as line-delimited files, loaded into ETS at startup. Pattern match completes in <1ms. Match triggers immediate replacement request; no logging of matched content (privacy).

LLM contextual review uses a dedicated safety-review prompt template (separate from content generation, in TemplateRegistry). Prompt classifies content as `{violence_level: 1-5, language_level: 1-5, darkness_level: 1-5}` with brief justification. Review runs async — flagged content is buffered, review fires as Task, result compared to tier thresholds, replacement injected if threshold exceeded.

The 10% sampling rate is a production default; configurable to 100% for child-flagged accounts. Account flagging: parental PIN set at onboarding (US for parental controls) marks account as `child_account: true`; child accounts automatically use 100% contextual review + most restrictive pattern filter regardless of configured tier.

Sanitization replacement generation uses the same context assembled for the original generation (US-101) with an additional system prompt instruction: "This content is for a Family-rated audience. Describe violence abstractly (opponents are 'defeated', wounds described as fatigue). Avoid themes of hopelessness, death of innocents, or body horror." Sanitized content is cached separately from original to avoid serving original on future identical requests.

Parental PIN workflow: parent sets PIN at account creation, stored bcrypt-hashed in `accounts` table. Tier-change requests for child accounts require PIN challenge via WebSocket before processing. Three failed PIN attempts lock tier changes for 1 hour with email notification to parent account.
