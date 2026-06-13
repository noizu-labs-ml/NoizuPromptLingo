# Persona 01: The Tinkerer

**Name:** Alex Chen
**Age:** 24
**Location:** Seattle, WA
**Occupation:** Software engineer (backend, 2 years experience)
**Device:** iPhone 15 Pro, also owns a gaming PC
**Income:** $95K/year

---

## Profile

Alex writes Go at work and plays mobile games during his 40-minute bus commute. He burned out on gacha mechanics after spending $200 on Genshin Impact and getting nothing memorable. He loved Zachtronics puzzles (Opus Magnum, Exapunks) but they're desktop-only and single-player. He wants a mobile game that rewards systems thinking and where spending money is never required to compete.

He watches 3Blue1Brown and Veritasium, has taken Andrew Ng's ML course on Coursera, and knows enough about neural nets to have opinions about activation functions. He'll immediately understand what the graph editor represents and will want to push it to its limits within the first week.

---

## Goals

- Design fighter graphs that express genuinely novel strategies, not meta copies
- Understand *why* his fighter lost by studying decision overlays in replays
- Reach the top ranked tier (Neural) through design skill alone
- Share interesting builds on Discord and get community recognition

## Frustrations

- Games that gate competitive viability behind time spent or money spent
- Dumbed-down "AI" that's really just stat checks with randomness
- Mobile UIs that are clunky or assume you're stupid
- Communities where meta-following is more rewarded than creativity

## Behaviors

- Plays 3-5 sessions per day, 10-15 minutes each (commute + lunch)
- Screenshots and shares unusual graph configurations on Discord
- Reads patch notes on release day and theorycrafts implications
- Will spend on cosmetics ($5-15/season) if the game earns his respect, but never on progression
- Compares his fighter's decision stats obsessively after each battle

---

## Key Scenarios

1. **First session:** Skips tutorial cinematic, reads node tooltips carefully, replaces 2 nodes in the starter template within 5 minutes, runs a test battle to see the impact
2. **Week 2:** Has built 3 different fighter graphs from scratch, is tracking win rates across different builds in a personal spreadsheet, frustrated that he only has 1 fighter slot (free tier)
3. **Month 1:** Buys the Fighter Pass for extra slots and advanced nodes. Active in the community Discord. Has posted a "counter-rushdown graph guide" that got 200 upvotes

---

## Design Implications

- The graph editor must support complex configurations (20+ nodes) without becoming unusable on mobile
- Decision overlay data needs to be detailed enough for post-mortem analysis — not just "chose DODGE" but the exact weights and inputs that led to it
- Build sharing needs to support both full transparency and partial obfuscation (Alex wants to share strategy, not be copied verbatim)
- Free tier must be genuinely competitive — Alex will churn immediately if Fighter Pass nodes are strictly better
