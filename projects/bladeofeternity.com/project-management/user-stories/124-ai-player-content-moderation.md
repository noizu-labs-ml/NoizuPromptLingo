# US-124: AI Player Content Moderation

**Persona:** Priya — Accessibility advocate (31, sighted, cross-SR testing)
**Priority:** P0
**Epic:** LLM & AI Systems

## Story
As Priya, I want player-created content to go through meaningful moderation before becoming visible to the community so that a game built on accessibility and inclusion doesn't become a vehicle for harassment, slurs, or content that would drive away the disabled players it was built for.

## Acceptance Criteria
- [ ] All player-created text content (clan descriptions, housing descriptions, player bios, forum posts, item naming) is submitted to the moderation pipeline before becoming publicly visible — no direct publish-to-live
- [ ] Moderation pipeline is two-pass: (1) rule-based pattern matching for prohibited terms, slurs, and known harmful content patterns (synchronous, <100ms); (2) LLM contextual moderation for nuanced policy violations — harassment, coded hate speech, inappropriate sexual content (async, <3 seconds)
- [ ] Moderation result categories: `approved`, `approved_with_warning` (borderline content, player flagged for monitoring), `pending_review` (ambiguous, sent to human queue), `rejected` (clear violation, content blocked)
- [ ] Rejected content returns player-facing explanation of the category of violation (not the specific trigger word/phrase — avoids gaming the system) and an appeals link
- [ ] Human moderation queue: `pending_review` items appear in a moderation dashboard with content, player history, and AI moderator reasoning — moderators can approve, reject, or escalate; target review time <24 hours
- [ ] Appeals process: players can submit one appeal per rejection with optional explanation; appeals enter a priority human review queue, reviewed by senior moderator, decision is final
- [ ] Moderation decisions logged: content hash (not raw content after decision), player_id, decision, AI moderator reasoning, human override if any, timestamps — retained 1 year for abuse pattern analysis
- [ ] False positive rate monitored: if approved appeal rate exceeds 20%, moderation prompt reviewed and recalibrated; Priya (or similar QA role) runs cross-SR testing to verify moderation UI is accessible to screen reader users

## Notes
Player content moderation implemented as `BladeOfEternity.Moderation.Pipeline` — called from all content submission handlers before write to public-visible tables. Synchronous rule-based pass must complete before returning; LLM pass runs as async Task with content held in `pending_moderation` state.

Rule-based pass: `BladeOfEternity.Moderation.PatternFilter` — same infrastructure as content safety filter (US-108) but with distinct term lists targeting player-authored content: slurs (comprehensive list from research sources), harassment patterns, PII formats (emails, phone numbers, real names in certain contexts). Match → immediate reject or flag depending on severity tier.

LLM moderation prompt: specialized template in registry (US-107) — system prompt establishes the game's community standards (accessibility-first, inclusive community, no harassment, no discrimination, no adult content). User prompt provides the player text with context (content type, player's history summary). Response is structured JSON: `{decision, category, reasoning, confidence}`. Confidence < 0.7 triggers `pending_review` regardless of decision.

Player history factored into LLM moderation: `moderation_history` summary injected into prompt — "This player has had 2 prior violations (harassment, minor language violation) in the past 30 days." History influences confidence threshold: players with prior violations have confidence threshold raised to 0.85 before `approved` is returned.

Human review dashboard: Phoenix LiveView at `/admin/moderation` — shows pending queue sorted by `pending_since` (oldest first), content preview, AI reasoning, player history. Moderator actions: Approve, Reject (with category selection), Escalate (moves to senior queue). Actions logged, content updated in `player_content` table, player notified via game system message.

Content state machine: `player_content` table has `moderation_status` enum: `pending` (submitted, awaiting LLM pass), `pending_review` (awaiting human), `approved`, `approved_warned`, `rejected`. Content only joins public queries when status is `approved` or `approved_warned`. Rejected content stored for appeals period (30 days) then purged.

Appeals: `content_appeals` table — `{content_id, player_id, appeal_text, submitted_at, reviewed_by, decision, decided_at}`. Appeal submission: player clicks appeal link (accessible keyboard action), enters optional explanation in a textarea, submits. One appeal per content item enforced at DB level (unique constraint on content_id). Senior moderator queue: same dashboard filtered by `escalated: true`.

Screen reader accessibility of moderation UI for Priya's testing: moderation outcome messages use ARIA live regions for async results. Appeal form uses standard accessible form patterns: labeled inputs, error messages associated via `aria-describedby`, success confirmation via live region. Priya's cross-SR testing matrix: NVDA+Firefox, JAWS+Chrome, VoiceOver+Safari on moderation submission and outcome flows.
