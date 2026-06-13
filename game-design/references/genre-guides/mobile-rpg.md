# Mobile RPG Genre Guide

Design patterns for mobile RPGs including gacha, hero collection, idle RPGs, and action RPGs.

## Sub-Genre Overview

| Sub-Genre | Core Loop | Session Length | Monetization | Top Performers |
|-----------|-----------|---------------|-------------|----------------|
| **Gacha RPG** | Collect → Build team → Battle → Repeat | 10-20 min | Gacha + IAP | Genshin Impact, FGO |
| **Hero Collector** | Collect heroes → Level up → Auto-battle | 5-15 min | Hero gacha + battle pass | AFK Arena, Raid: SL |
| **Idle RPG** | Set team → Wait → Collect → Upgrade | 3-10 min | IAP + ads + battle pass | Idle Heroes, Ulala |
| **Action RPG** | Dungeon → Loot → Craft → Repeat | 15-30 min | IAP + cosmetics | Diablo Immortal |
| **Turn-based RPG** | Strategize → Battle → Level → Repeat | 10-20 min | Gacha + battle pass | Epic Seven, Summoners War |

## Gacha System Design

### Gacha Types

| Type | Description | Player Sentiment | Revenue | Regulatory Risk |
|------|-------------|-----------------|---------|----------------|
| **Character gacha** | Pull for playable characters | High excitement | Very High | High |
| **Weapon gacha** | Pull for equipment | Medium excitement | High | Medium |
| **Skin gacha** | Pull for cosmetics | Low excitement | Medium | Low |
| **Resource gacha** | Pull for materials | Lowest excitement | Low | Low |

### Gacha Economy Design

```yaml
gacha_economy:
  currency:
    free_pulls_per_week: 5-10        # F2P players get some pulls
    paid_pull_cost: $1.50-$3.00      # Per pull equivalent
    premium_10_pull: $15-$30         # 10-pull at slight discount

  rates:
    common: 70-80%                   # Filler
    uncommon: 15-20%                 # Useful but not exciting
    rare: 5-8%                       # Strong, desirable
    legendary: 1-2%                  # Chase item
    mythic: 0.1-0.5%                 # Ultra-rare, whale bait

  pity_system:
    soft_pity: 50-70 pulls           # Rates begin increasing
    hard_pity: 90-120 pulls          # Guaranteed top-tier item
    pity_carries_over: true          # Between banners (retention driver)

  banner_structure:
    standard_banner: "Always available, rotating pool"
    limited_banner: "2-4 weeks, exclusive character"
    rate_up_banner: "Specific character at higher rate"
    step_up_banner: "Progressive rewards at pull milestones"
```

### Pity System Best Practices

- **Always have pity** — No pity = predatory, damages trust
- **Soft pity > hard pity** — Increasing rates feel rewarding, hard pity is a safety net
- **Pity should carry over** — Between banners of the same type
- **Pity should be transparent** — Show pull count and next guarantee

## Progression Design

### Character Progression

| System | Depth | Player Investment | Whale Monetization |
|--------|-------|------------------|-------------------|
| Level | Linear | Time | XP boosters |
| Evolution / Ascension | Gated | Resources | Resource packs |
| Skill upgrades | Strategic | Dupes + resources | Duplicate characters |
| Equipment / Gear | Deep | Grinding + luck | Gear packs, enhancement mats |
| Constellation / Potential | Very deep | Duplicate pulls | Gacha dupes |
| Awakening / Rebirth | Reset-based | Heavy investment | Reset materials |

### Team Building

| Team Size | Strategic Depth | Content Complexity |
|-----------|----------------|-------------------|
| 3 heroes | Low | Simple synergy |
| 4 heroes | Medium | Role balance |
| 5 heroes | High | Full composition |
| 6 heroes | Very High | Formation matters |

### Content Pacing

```
Week 1: Story chapters 1-5, basic team building
Week 2: Chapters 6-10, first evolution, guild unlock
Month 1: Chapters 11-20, team synergy, first event
Month 2: Ascension unlocks, hard mode, PvP
Month 3: Endgame content, raids, first limited banner
Month 6: Full meta established, competitive play
```

## Idle RPG Specific Patterns

### Offline Progression

| Parameter | Recommended | Notes |
|-----------|------------|-------|
| Max offline time | 12-24 hours | Cap to encourage daily login |
| Offline efficiency | 50-70% of active | Active play should feel superior |
| Offline rewards | Currency + XP + materials | Not character-specific drops |
| Notification trigger | When offline cap reached | "Your resources are full!" |

### Auto-Battle Design

| Feature | Implementation | Purpose |
|---------|---------------|---------|
| Speed multiplier | 1x, 2x, 4x, 8x | Player convenience |
| Auto-sweep | Instant clear for completed stages | Respect player time |
| Quick battle | Simulate battle, give results | For repetitive farming |
| Auto-repeat | Loop stage until stopped | AFK farming |

## Battle Pass for RPGs

### Structure

| Tier | Free Track | Premium Track | Notes |
|------|-----------|--------------|-------|
| 1-10 | Currency, XP books | Premium currency | Hook with early value |
| 11-30 | Materials, gear | Characters, skins | Core value zone |
| 31-50 | Rare materials | Exclusive character | Whale incentive |
| 51-80 | Legendary materials | Exclusive weapon | Completionist target |
| 81-100 | Mythic materials | Mythic skin | Ultra-completionist |

### Season Content

| Season Duration | 30-45 days | Short enough for urgency |
| Season Character | 1 new limited character | Drives battle pass purchase |
| Season Story | Mini story arc | Narrative engagement |
| Season Event | Exclusive game mode | Fresh gameplay |
