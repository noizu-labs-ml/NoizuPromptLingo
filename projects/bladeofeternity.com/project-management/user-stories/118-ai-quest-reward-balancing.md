# US-118: AI Quest Reward Balancing

**Persona:** Tyler — MMO refugee (22, sighted, growth/agency/clans)
**Priority:** P1
**Epic:** LLM & AI Systems

## Story
As Tyler, I want quest rewards to feel fair and proportional — not laughably low, not game-breakingly high — so that the economy stays interesting and my progression feels earned rather than arbitrary, even when the quest itself was AI-generated on the fly.

## Acceptance Criteria
- [ ] All AI-generated quest rewards pass through a reward validator before commitment: proposed reward (gold, XP, items) checked against an economy model parameterized by quest difficulty, player level, quest type, and current market state
- [ ] Reward calculator defines expected value ranges per `{quest_tier, player_level_bracket}` combination: AI-proposed rewards outside ±25% of expected value are adjusted to the nearest boundary before acceptance
- [ ] Item rewards validated against item rarity schedule: a tier-1 quest cannot reward a Legendary item; item rarity ceiling per quest tier defined in economy config
- [ ] XP reward formula accounts for party size: solo quest XP ≠ party quest XP — formula normalizes per-player XP so party play is advantageous but not exploitable
- [ ] Economy model monitors inflation signals: if average player gold holdings have increased 20%+ week-over-week, reward calculator applies a deflation coefficient to gold rewards until holdings stabilize
- [ ] Reward validation decisions logged: proposed reward, adjusted reward, adjustment reason, economy state snapshot at validation time — queryable for economy balance analysis
- [ ] Narrative designers can view a reward distribution dashboard: histogram of rewards by quest tier, outlier flagging, economy trend graphs — for ongoing balance calibration
- [ ] Players cannot exploit reward generation through quest manipulation: reward committed at quest acceptance, not completion — completion triggers reward delivery, not regeneration

## Notes
Reward validator implemented as `BladeOfEternity.Economy.RewardValidator` — pure functional module. `validate/2` takes `{proposed_reward, quest_context}`, returns `{:ok, reward}` or `{:adjusted, adjusted_reward, reason}`. Called in quest acceptance pipeline before writing to `quest_instances` table.

Economy model: `BladeOfEternity.Economy.Model` — reads current economy state from an ETS cache updated every 5 minutes by a background job querying `economy_snapshots` table. Economy state: `{avg_player_gold_by_level_bracket, item_market_prices, recent_inflation_index}`.

Reward value calculation uses a utility function: `expected_gold(quest_tier, player_level) = base_gold(tier) * level_coefficient(player_level) * inflation_adjustment`. Parameters in `economy_config.yaml`. Expected ranges:
- Tier 1 (fetch/deliver): 10–50 gold, 100–500 XP, Common item (10% chance)
- Tier 2 (combat/investigation): 50–200 gold, 500–2000 XP, Uncommon item (30% chance)
- Tier 3 (dungeon/multi-step): 200–1000 gold, 2000–10000 XP, Rare item (50% chance)
- Tier 4 (epic/faction): 1000–5000 gold, 10000–50000 XP, Epic item (30% chance)

Item rarity ceiling enforced via simple lookup: `max_rarity_for_tier = %{1 => :uncommon, 2 => :rare, 3 => :epic, 4 => :legendary}`. If AI proposes a Legendary item for a tier-1 quest, the item slot is replaced with the highest-rarity item within the ceiling, or a gold equivalent if no appropriate item is available.

Inflation detection: weekly Oban job (`BladeOfEternity.Workers.EconomySnapshot`) queries current avg gold holdings by player level bracket, compares to 7-day prior snapshot, computes inflation index. If index > 1.2 (20% growth), sets `inflation_adjustment` to 0.85 in economy state; if index < 0.9 (deflation), sets to 1.10. Adjustment logged and visible in reward distribution dashboard.

Reward commitment: quest acceptance handler calls `validate`, stores `committed_reward` in `quest_instances`. Completion handler reads committed reward, not proposed reward. This prevents a player from abandoning and re-accepting quests to fish for better rewards.

Dashboard: Phoenix LiveView at `/admin/economy` showing reward distribution histograms (Chart.js), economy timeline (gold holdings by week), inflation index trend, top-10 outlier rewards (proposed vs. committed), and current reward range tables per tier.
