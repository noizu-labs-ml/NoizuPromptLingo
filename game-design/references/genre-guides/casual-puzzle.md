# Casual Puzzle Genre Guide

Design patterns for match-3, merge, hidden object, and physics puzzle games.

## Sub-Genre Overview

| Sub-Genre | Core Loop | Session Length | Monetization | Top Performers |
|-----------|-----------|---------------|-------------|----------------|
| **Match-3** | Match → Clear board → Progress → Repeat | 3-8 min | IAP lives + boosters + ads | Candy Crush, Toon Blast |
| **Merge** | Merge → Create items → Fulfill orders → Repeat | 5-15 min | IAP energy + generators + ads | Merge Mansion, Merge Dragons |
| **Hidden Object** | Find objects → Solve puzzle → Progress → Repeat | 5-15 min | IAP hints + energy + ads | June's Journey, Manor Matters |
| **Physics Puzzle** | Solve physics → Clear level → Progress → Repeat | 2-5 min | IAP solutions + ads | Angry Birds, Cut the Rope |
| **Word Puzzle** | Form words → Clear board → Progress → Repeat | 3-10 min | IAP hints + ads | Wordscapes, NYT Crossword |

## Match-3 Design Patterns

### Board Mechanics

| Mechanic | Description | Strategic Depth | Example |
|----------|-------------|----------------|---------|
| **Swap** | Swap adjacent pieces to match 3+ | Medium | Candy Crush |
| **Tap/Click** | Tap groups of same-color | Low | Toon Blast |
| **Shoot** | Aim and shoot piece into board | Medium | Bubble Witch |
| **Draw line** | Connect same-color pieces | Medium | Best Fiends |
| **Slide** | Slide row/column to align | Medium | Fishdom |

### Special Piece Progression

| Match | Special Created | Effect | Strategic Value |
|-------|----------------|--------|-----------------|
| Match 4 | Striped piece | Clears row or column | Medium |
| Match 5 (L/T shape) | Wrapped piece | Explodes area | High |
| Match 5 (straight) | Color bomb | Clears all of one color | Very High |
| Special + Special | Combo effect | Combined area clear | Devastating |

### Level Design for Match-3

| Level Type | Win Condition | Frustration | Retention |
|-----------|--------------|-------------|-----------|
| **Score target** | Reach score within moves | Low | High |
| **Clear blocks** | Remove all special tiles | Medium | Medium |
| **Collect items** | Bring items to bottom | Medium | High |
| **Defeat enemy** | Match adjacent to enemy | Medium | Medium |
| **Boss level** | Multiple phases, escalating | High | Medium |
| **Time attack** | Score target within time | Low | Low (anxiety) |

### Difficulty Curve

```
Levels 1-20:   Very Easy (teach mechanics, hook player)
Levels 21-50:  Easy (introduce special pieces, combinations)
Levels 51-100: Medium (introduce blockers, combination levels)
Levels 101-200: Moderate-Hard (complex objectives, multiple mechanics)
Levels 201-500: Hard (new mechanics, true challenge)
Levels 501+:    Expert (combination mastery required)
```

**Difficulty Pulsing**: Alternate easy and hard levels. After a frustrating level, give 1-2 easy wins before the next challenge. Players who just failed need a win to stay engaged.

## Lives / Energy System

### Match-3 Lives Model

| Parameter | Recommended | Notes |
|-----------|------------|-------|
| Max lives | 5 | Standard across most match-3 |
| Life regen | 1 per 30 minutes | 2.5 hours for full refills |
| Life from friends | Unlimited (1 per friend) | Social viral driver |
| Life IAP cost | $0.99 for 5, $1.99 for 20 | Frustration-based purchase |
| Infinite lives reward | 1-2 hours from events | Retention incentive |

### Alternative: Energy Model (Merge Games)

| Parameter | Recommended | Notes |
|-----------|------------|-------|
| Max energy | 100-200 | Higher than lives |
| Energy regen | 1 per 1-2 minutes | Faster regen than lives |
| Energy per action | 5-20 | Varies by action |
| Full regen time | 1-3 hours | Drives session timing |

## Booster / Power-Up Design

| Booster | Effect | Price (Soft Currency) | Price (Hard Currency) |
|---------|--------|----------------------|----------------------|
| +5 Moves | Adds 5 moves to level | 900 gold | $0.99 |
| Pre-level booster | Starts level with special piece | Free (earned) | - |
| Color bomb | Place a color bomb anywhere | - | $1.99 |
| Shuffle | Rearranges board | 500 gold | - |
| Hammer | Removes one piece | 300 gold | - |
| Unlimited lives (2h) | No life loss for 2 hours | Event reward | $2.99 |

## Meta-Game Design

### Meta-Layer Options

| Meta Type | Description | Engagement Impact | Example |
|-----------|-------------|-------------------|---------|
| **Home building** | Decorate home with level rewards | High | Homescapes |
| **Garden building** | Design garden, unlock areas | High | Gardenscapes |
| **Story progression** | Uncover story between levels | High | June's Journey |
| **Character collection** | Unlock characters through levels | Medium | Best Fiends |
| **Pet raising** | Feed and grow pets | Medium | Various |
| **Competitive** | Leaderboards, tournaments | Medium | Candy Crush |

### Meta-Reward Cadence

```
After every level: Stars/tokens (currency)
After 2-3 levels: Story beat or meta-choice
After 5-10 levels: Area/chapter unlock
After 15-20 levels: New mechanic introduction
After 50 levels: Major story event or area
```

## Ad Strategy for Puzzle Games

| Placement | Ad Type | Frequency | Revenue | Retention Impact |
|-----------|---------|-----------|---------|-----------------|
| Between levels | Interstitial | Every 2-3 levels | High | Moderate negative |
| Continue? | Rewarded (extra moves) | On failure | High | Positive |
| Daily bonus | Rewarded | 1x daily | Medium | Positive |
| Booster unlock | Rewarded | Opt-in | Medium | Positive |
| Double rewards | Rewarded | After level win | High | Neutral |

**Revenue Mix Target**: 50-60% IAP, 30-40% ads, 10% other
