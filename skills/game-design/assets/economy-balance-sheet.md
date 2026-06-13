# Economy Balance Sheet Template

Track currency sources, sinks, and flow rates for game economy balancing.

```markdown
# [Game Title] — Economy Balance Sheet

## Currency Definitions

| Currency | Type | Source | Primary Use | IAP Exchange |
|----------|------|--------|------------|-------------|
| Gold | Soft | Gameplay | Common upgrades | Not purchasable |
| Gems | Hard | IAP + rare drops | Premium items | $0.99 = 100 |
| Guild Tokens | Social | Guild activities | Guild shop items | Not purchasable |
| Event Tokens | Time-limited | Events | Event shop items | Not purchasable |

## Sources (Currency In) — Per Session

| Source | Gold | Gems | Other | Frequency | Notes |
|--------|------|------|-------|-----------|-------|
| Level completion | 100-500 | - | - | Per level | Scales with level |
| Daily quest | 500 | 5 | - | 3/day | Quick tasks |
| Weekly quest | 2000 | 20 | - | 1/week | Longer tasks |
| Login bonus | 200-1000 | 5-50 | - | Daily | Escalating streak |
| IAP purchase | - | 100-10000 | - | Variable | See IAP catalog |
| Event reward | 1000 | 10 | Tokens | Per event | Time-limited |
| Ad watch | 100 | 2 | - | 3/day | Opt-in |
| Guild activity | 200 | - | 10 Guild Tokens | Per contribution | Social |
| Achievement | 500-5000 | 10-100 | - | One-time | Milestones |

**Total per session (avg F2P)**: ~1500 Gold, ~15 Gems, ~5 Guild Tokens
**Total per session (avg Payer)**: ~1500 Gold, ~115 Gems, ~5 Guild Tokens

## Sinks (Currency Out) — Per Session

| Sink | Gold | Gems | Other | Frequency | Notes |
|------|------|------|-------|-----------|-------|
| Character upgrade | 500-5000 | - | - | Per level | Escalating |
| Equipment enhancement | 200-2000 | - | - | Per upgrade | RNG component |
| Character summon (gacha) | - | 150-300 | - | Per pull | 10-pull discount |
| Shop purchase | 100-1000 | 50-500 | - | Variable | Rotating stock |
| Energy refill | - | 50 | - | When depleted | 2-3x daily |
| Guild donation | 200-500 | - | - | Daily | Social obligation |
| Cosmetics | - | 200-2000 | - | Occasional | Skins, emotes |
| Speed-up | 100-500 | 10-50 | - | Occasional | Skip wait timers |

**Total per session (avg F2P)**: ~1200 Gold, ~100 Gems (saving for pulls), ~200 Guild Tokens
**Total per session (avg Payer)**: ~2000 Gold, ~300 Gems, ~200 Guild Tokens

## Balance Check

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Gold net per session | +200 to +500 | +300 | ✅ Healthy |
| Gems net per session (F2P) | Slightly negative | -85 | ✅ Drives IAP |
| Gems net per session (Payer) | Slightly negative | -185 | ✅ Drives more IAP |
| Guild tokens net per session | Slightly positive | +10-50 | ✅ Slow accumulation |
| Time to first gacha pull | ~10 sessions | 10 sessions | ✅ On target |
| Time to earn free 10-pull | ~20 sessions | 20 sessions | ✅ On target |

## Inflation Monitor (Monthly)

| Month | Gold Supply | Gold Sinks | Net Gold | Gems Supply | Gems Sinks | Net Gems |
|-------|-----------|-----------|----------|-------------|-----------|----------|
| M1 | | | | | | |
| M2 | | | | | | |
| M3 | | | | | | |
```
