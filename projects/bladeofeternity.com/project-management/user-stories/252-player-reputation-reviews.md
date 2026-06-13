# US-252: Player Reputation & Reviews

**Persona:** Tyler — Competitive player who wants social accountability and meritocracy in the community
**Priority:** P1
**Epic:** Advanced Social & Governance

## Story
As Tyler, I want to rate and review players I've interacted with so that trustworthy traders and skilled teammates get recognized and bad actors accumulate a visible track record, making the community self-regulating.

## Acceptance Criteria
- [ ] Reviews are submitted via `/review [player] [category] [1-5 stars] "[text]"`; categories: Trader (commerce interactions), Fighter (combat/party performance), Crafter (crafting quality), Roleplayer (narrative contribution), Community (general citizenship); text field: 140 chars max
- [ ] Review eligibility gating: reviewer must have interacted with the target in the relevant context within the past 30 days (trade, shared party, crafting commission, shared event); system validates interaction history before allowing review; prevents reviewing strangers
- [ ] Player profile displays reputation section: overall score (weighted average across categories), total reviews count, category breakdown (each category as a star rating with review count); all displayed as text: "Trader: 4.2 stars (23 reviews)"
- [ ] Review browsing via `/profile [player] reviews`: paginates reviews as a numbered list; each entry reads: reviewer name, category, star rating, text, date; navigable by arrow keys in screen reader
- [ ] Anti-abuse systems: players can only review a specific player once per 30-day period per category; mass reviewing is rate-limited; a player receiving a suspicious cluster of 1-star reviews within 24 hours triggers auto-flagging for GM review; flagged review clusters are suspended pending review
- [ ] Response system: reviewed players can post one public reply per review (100 chars); reply appears below the original review when browsing; no reply-to-reply threading — keeps it simple and avoids argument spirals
- [ ] Reputation threshold effects: players with overall rating below 2.0 stars (minimum 10 reviews) receive a "Notorious" flag visible to others; players above 4.5 stars (minimum 20 reviews) receive a "Distinguished" badge; both badges appear in profile header and whisper/chat name display
- [ ] Review anonymization option: reviewer may choose to post anonymously; anonymous reviews show "Verified [Category] Partner" as author; anonymity cannot be removed after posting; GMs retain ability to identify anonymous reviewers in abuse investigations

## Notes
The interaction validation gate is the most important anti-abuse measure. Without it, clan members would mass-review each other into Distinguished status and mass-review enemies into Notorious. By requiring a verified interaction in the relevant category, the system ensures reviews are grounded in actual experience.

The "Notorious" flag at 2.0 stars is significant — it warns traders, party-seekers, and event organizers that this player has a track record of negative interactions. The flag threshold (minimum 10 reviews) prevents a player from being tanked by a small coordinated group. The "Distinguished" badge creates positive incentive: players who consistently trade fairly, fight well, and contribute positively earn visible recognition.

Anonymous reviews are a double-edged sword. They allow honest feedback from players who fear retaliation, but they also enable cowardly abuse. The design choice to allow anonymization is justified by the validation gate — if you can only review someone you've genuinely interacted with, an anonymous negative review is at minimum from a real interaction. The GM de-anonymization power is the safety valve.

Tyler's concern is meritocracy. He doesn't want the leaderboard dominated by players with the most friends. The category system helps: you can have high Trader reputation but low Fighter reputation, which means your peer assessment is multidimensional. A clan of friends can't easily inflate each other's Fighter scores without actually fighting together.

Screen reader display: the profile reputation section must be a proper list, not a visual star-graphic. Five-star ratings rendered as ★★★★☆ are often read as individual characters by screen readers. The text format "4.2 out of 5 stars" is the correct approach. Category breakdowns should each be a list item: "Trader reputation: 4.2 out of 5 stars, 23 reviews."

Consider a "reputation milestone" notification when a player's rating crosses a threshold: "Your Trader reputation has reached 4.5 stars and you have been awarded the Distinguished badge." This creates a reward moment for positive behavior.
