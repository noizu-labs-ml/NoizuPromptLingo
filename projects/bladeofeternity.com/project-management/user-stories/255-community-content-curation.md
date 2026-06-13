# US-255: Community Content Curation

**Persona:** Carol — Parent who wants a safe, quality-controlled community environment for her child
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Carol, I want player-created guides and tips to be curated through a quality and safety filter so that my child is learning from vetted community knowledge rather than encountering harmful or misleading content when seeking help.

## Acceptance Criteria
- [ ] Players can submit guides via `/guide submit [title] [category]` followed by body text entry (2000 char max); categories: Combat, Crafting, Exploration, Social, Accessibility, New Player, Lore; all categories accessible via screen reader list navigation
- [ ] Submitted guides enter a moderation queue before appearing in the public browser; moderation checks: content policy compliance (no personal info, no harassment, no real-world political content), accuracy review (spot-checked by senior moderators or trusted community reviewers), and formatting validation
- [ ] Community voting: published guides display a thumbs-up/thumbs-down rating; `/guide rate [id] [up|down]` casts a vote; vote totals visible as text on guide listing: "Helpful: 47 / Not helpful: 3"; voting requires minimum account age (7 days) to prevent vote manipulation
- [ ] Guide browsing via `/guide browse [category]` presents guides as a numbered list sorted by net rating; each entry: guide number, title, author, rating summary, date published; full guide readable via `/guide read [id]`
- [ ] Trusted Contributor status: players with 5+ guides rated above 90% helpful are elevated to Trusted Contributor; their future submissions bypass the moderation queue and go live within 1 hour pending automated content policy check only; status visible on their contributor profile
- [ ] Accessibility guides category receives mandatory accessibility review — a moderator with screen reader experience must sign off before publication; this ensures guides written about accessibility are accurate for the players who need them most
- [ ] Parents linked to junior accounts (via family settings) receive notifications when their child bookmarks or rates a guide; parents can flag guides for additional review via a family safety report, distinct from the standard abuse report
- [ ] Guide versioning: authors can update guides; updated guides are re-reviewed if changes exceed 20% of original content; version history browsable via `/guide history [id]` with date of each version; approved updates go live within the review SLA

## Notes
Carol's concern is both safety and quality. A guide that teaches her child incorrect mechanics is frustrating; a guide that contains inappropriate content is dangerous. The two-gate system (moderation queue + community rating) addresses both: moderation catches safety issues, community rating surfaces quality.

The moderation queue SLA should be published: "Guides are reviewed within 48 hours." This manages expectations and creates accountability. Automated content policy checks (profanity filters, PII detection patterns) can handle the first pass; human moderators handle the substantive review. The accuracy check for gameplay guides is lightweight at V1 — moderators check for obvious errors (e.g., "to craft a sword, you need 10 iron and 5 wood" when the actual recipe is different) not comprehensive correctness.

The Trusted Contributor pathway is a well-established pattern (Wikipedia, Stack Overflow) that scales moderation by distributing trust. The thresholds (5 guides, 90% helpful) should be tuned based on early data — if the bar is too low, the queue bypass is gamed; too high and good contributors wait forever.

The accessibility guides category is Carol's most important concern for her blind child. A guide that says "look to your left and you'll see..." is useless and potentially harmful for Elena or Marcus. The mandatory accessibility review for this category is the right call — it requires additional resourcing but ensures the category is trustworthy.

Family safety reporting should be low-friction: a single command from a parent account, no lengthy form. The report creates a priority moderation ticket. Parents should receive acknowledgment within 24 hours: "Your report has been received and is under review."

Guide discovery is a second-order problem: a library of 500 guides is worthless if players can't find what they need. Full-text search (`/guide search [keyword]`) across guide titles and bodies is essential. Search should rank by recency within the same relevance tier, so a highly rated but outdated guide doesn't crowd out a newer more accurate one. Consider a "Staff Picks" weekly feature surfaced in the New Player onboarding flow — editorially selected guides curated by the community team.
