# Simulation & Tycoon Genre Guide

Design patterns for builder, manager, idle tycoon, and simulation games.

## Sub-Genre Overview

| Sub-Genre | Core Loop | Session Length | Monetization | Top Performers |
|-----------|-----------|---------------|-------------|----------------|
| **City Builder** | Build → Produce → Expand → Upgrade | 10-30 min | IAP speed-ups + premium currency | SimCity BuildIt, Township |
| **Farm/Restaurant** | Plant/Cook → Harvest/Serve → Sell → Upgrade | 10-20 min | IAP gems + energy + ads | Hay Day, Cooking Fever |
| **Idle Tycoon** | Tap/Automate → Earn → Upgrade → Prestige | 3-10 min | IAP speed-ups + ads + battle pass | Idle Miner, Adventure Communist |
| **Theme Park / Zoo** | Build attractions → Manage guests → Expand | 10-30 min | IAP + wait-time skipping | RollerCoaster Tycoon |
| **Life Sim** | Customize → Social → Progress → Decorate | 15-45 min | IAP cosmetics + expansions | Animal Crossing, Sims Mobile |

## Production Chain Design

### Resource Flow

```
Raw Materials → Processing → Products → Revenue → Reinvestment
     ↑                                                    |
     └──────────────────── Upgrade Loop ──────────────────┘
```

### Production Chain Templates

| Game Type | Chain Example | Upgrade Path |
|-----------|-------------|-------------|
| **Farm** | Seeds → Crops → Processed food → Market sell | Farm → Mill → Bakery |
| **Mining** | Ore → Smelting → Ingots → Manufacturing → Sell | Mine → Smelter → Factory |
| **Restaurant** | Ingredients → Prep → Cook → Serve → Payment | Kitchen → Dining → Marketing |
| **Theme Park** | Build ride → Attract guests → Earn tickets → Build more | Rides → Concessions → Hotels |
| **Space** | Mine asteroids → Refine → Build ships → Trade → Expand | Miner → Refinery → Shipyard |

### Production Balancing

| Parameter | Early Game | Mid Game | Late Game |
|-----------|-----------|----------|-----------|
| Production time | 5-30 sec | 1-5 min | 5-30 min |
| Revenue per cycle | $10-100 | $100-10K | $10K-1M |
| Upgrade cost | $100-1K | $1K-100K | $100K-10M |
| Upgrade multiplier | 2x | 1.5x | 1.2x |
| Unlock frequency | Every 5 min | Every 30 min | Every 2 hours |

## Idle / Automation Mechanics

### Automation Progression

| Stage | Player Action | Automation Level |
|-------|--------------|-----------------|
| **Stage 1** | Manual tapping/clicking | None |
| **Stage 2** | Buy first auto-producer | Partial |
| **Stage 3** | Upgrade auto-producers | Mostly passive |
| **Stage 4** | Manager hires (fully auto) | Fully automated |
| **Stage 5** | Offline earnings cap | AFK income |
| **Stage 6** | Prestige multipliers | Idle optimization |

### Prestige System Design

| Parameter | Recommended | Notes |
|-----------|------------|-------|
| When to prestige | 1-2 hours of play | Player feels "done" with current run |
| Prestige reward | Permanent multiplier (2-10x) | Must feel meaningful |
| Prestige cost | Reset all progress | Fresh start with advantage |
| Prestige layers | 2-3 layers deep | Adds long-term depth |
| Prestige speed | Each prestige faster than last | Reward for mastery |

### Offline Earnings

| Parameter | Recommended | Notes |
|-----------|------------|-------|
| Max offline time | 4-24 hours | Encourages daily return |
| Offline efficiency | 50-80% of active | Active play is superior |
| Offline notification | "You earned $X while away!" | Positive return feeling |
| Premium offline boost | 100% offline for VIP | Monetization hook |

## Wait-Time Monetization

### Timer Design

| Action | Free Wait Time | Skip Cost (Soft) | Skip Cost (Hard) |
|--------|---------------|-----------------|-----------------|
| Build basic structure | 30 sec - 5 min | - | - |
| Build advanced structure | 1-8 hours | 500-5K gold | $0.99-$1.99 |
| Build premium structure | 12-48 hours | 10K-50K gold | $4.99-$19.99 |
| Upgrade production | 5 min - 2 hours | 200-2K gold | $0.99 |
| Research / unlock | 1-24 hours | 1K-10K gold | $1.99-$4.99 |

### Timer Psychology

| Timer Length | Player Feeling | Monetization Sweet Spot |
|-------------|---------------|----------------------|
| <1 minute | Satisfied | No skip needed |
| 1-5 minutes | Slight impatience | Small soft currency skip |
| 5-30 minutes | Impatient | Premium currency skip |
| 1-4 hours | "I'll come back later" | Drive return visit |
| 4-24 hours | Frustrated (if gated) | $0.99-$4.99 skip |
| 24+ hours | Very frustrated | $4.99-$19.99 skip |

**Design Rule**: Never gate core gameplay behind timers. Timers should affect secondary progression (upgrades, expansion), not the ability to play.

## Building & Decoration System

### Building Categories

| Category | Gameplay Function | Monetization | Player Appeal |
|----------|------------------|-------------|---------------|
| **Production** | Generates resources | Speed-ups | Functional |
| **Decoration** | Visual only, happiness boost | Premium currency | Creative expression |
| **Special** | Unique bonuses | Premium or event-locked | Collector appeal |
| **Expansion** | Unlocks buildable area | Mixed | Progression |
| **Storage** | Increases capacity | Mixed | Quality of life |

### Decoration Economy

```
Basic decorations: Earned through gameplay
  ↓
Themed decorations: Event rewards or moderate IAP
  ↓
Premium decorations: Premium currency or battle pass
  ↓
Exclusive decorations: Limited-time events, never returning
  ↓
Community decorations: Created by players (UGC)
```

## Event Design for Tycoon Games

### Event Types

| Event | Duration | Mechanic | Reward |
|-------|----------|----------|--------|
| **Production event** | 3-7 days | Produce X items for points | Exclusive decoration |
| **Collection event** | 5-10 days | Find hidden items in buildings | Premium currency |
| **Competition event** | 2-3 days | Highest revenue wins | Exclusive building |
| **Seasonal event** | 14-30 days | Multi-stage objectives | Season decoration set |
| **Community event** | 7-14 days | All players contribute | Tiered rewards for all |
| **Prestige event** | 3-5 days | Prestige for bonus multipliers | Permanent upgrade |
