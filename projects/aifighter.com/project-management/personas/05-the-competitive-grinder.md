# Persona 05: The Competitive Grinder

**Name:** Yuki Tanaka
**Age:** 22
**Location:** Tokyo, Japan (plays on US server)
**Occupation:** Part-time convenience store clerk, aspiring esports content creator
**Device:** iPhone 15, streams via iPad
**Income:** ~$18K/year

---

## Profile

Yuki plays mobile games 4-6 hours per day. She's been top 100 in Clash Royale, top 500 in TFT Mobile, and is looking for the next game where she can establish herself as an early competitive authority. She found AI Fighter through a tech YouTuber's preview and immediately recognized the competitive potential — a game where skill expression is in the design phase, not the execution phase, is novel and streamable.

She treats games as a career path. If she can reach top-10 in AI Fighter's first season, she'll have content, clout, and potentially sponsorship opportunities. She'll push the game's systems harder than anyone — exploiting edge cases, optimizing graphs to mathematical precision, and documenting everything for her growing audience.

---

## Goals

- Reach and maintain top-10 on the ranked ladder
- Discover optimal strategies before the meta settles and publish them as content
- Build a following around AI Fighter competitive play (YouTube, Twitch, TikTok)
- Win sponsored tournaments if/when they exist

## Frustrations

- Balance patches that invalidate weeks of optimization without warning
- Matchmaking that doesn't properly separate skill tiers (stomping or getting stomped isn't content)
- Slow match resolution — async is fine, but if it takes 30 minutes to get a result, she can't stream it effectively
- Lack of stats, leaderboards, or competitive infrastructure (no API for tracking rankings over time)

## Behaviors

- Plays 15-25 sessions per day across multiple fighter slots
- Maintains spreadsheets tracking win rates per graph configuration per opponent archetype
- Tests edge cases: "What happens if I set aggression to 1.0 and risk tolerance to 0.0?"
- Reports bugs aggressively — she finds them because she pushes boundaries
- Buys the Fighter Pass immediately for extra fighter slots (her primary monetization driver is slot count)
- Will spend $20-40/month during active seasons

---

## Key Scenarios

1. **First session:** Completes onboarding in 3 minutes, immediately builds a custom graph from blank canvas, runs 50 training generations against each sparring archetype, enters ranked within the hour
2. **Week 1:** Has tested 12+ graph configurations. Has found that a specific perception→decision wiring pattern beats the "Brawler" template 80% of the time. Posts a video titled "The graph everyone is sleeping on"
3. **Season 1 end:** Top-25 on the ladder. Has 3K YouTube subscribers from AI Fighter content. Discovered and reported 2 exploitable bugs. Frustrated that there's no "spectator mode" for her streams yet — she has to screen-record replays

---

## Design Implications

- Multiple fighter slots are the key monetization vector for competitive players — 1 free slot is insufficient for serious play
- Match resolution speed matters: even async, results should be available within 1-2 minutes
- Detailed stats APIs or export tools enable the content creator ecosystem that markets the game for free
- Balance change communication needs a preview/PBE system — top players invest heavily in graph designs that balance patches can destroy
- Anti-smurf mechanisms in matchmaking prevent top players from farming content against beginners
- Replay export in a streamable format (MP4 with decision overlay baked in) enables content creation
