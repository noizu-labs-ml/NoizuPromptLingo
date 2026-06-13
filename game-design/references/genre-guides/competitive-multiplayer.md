# Competitive Multiplayer Genre Guide

Design patterns for MOBA, battle royale, shooter, and esports-focused games.

## Sub-Genre Overview

| Sub-Genre | Core Loop | Session Length | Monetization | Top Performers |
|-----------|-----------|---------------|-------------|----------------|
| **MOBA** | Draft → Lane → Teamfight → Destroy base | 20-45 min | Skins + battle pass | League, Mobile Legends |
| **Battle Royale** | Drop → Loot → Survive → Be last standing | 15-25 min | Cosmetics + battle pass | Fortnite, PUBG Mobile |
| **Tactical Shooter** | Buy round → Attack/Defend → Win rounds | 30-60 min | Skins + battle pass | Valorant, CS2 |
| **Hero Shooter** | Pick hero → Fight → Objective → Win | 10-20 min | Heroes + skins + BP | Overwatch, Apex |
| **Fighting** | Pick fighter → 1v1 → Win rounds | 3-10 min | Characters + skins | Street Fighter, Smash |

## Competitive Design Principles

### Fairness First

| Principle | Implementation | Why |
|-----------|---------------|-----|
| No pay-to-win | Paid items are cosmetic or convenience only | Competitive integrity drives retention |
| Skill-based matchmaking (SBMM) | Match by skill rating, not arbitrary | Fair matches = player satisfaction |
| Server authority | Server validates all player actions | Prevents cheating |
| Anti-cheat | Kernel-level or behavioral detection | Trust in system |
| Latency compensation | Favor the shooter, lag compensation | Fair across connection quality |

### Monetization Without P2W

| Model | Revenue Potential | Player Sentiment |
|-------|------------------|-----------------|
| **Cosmetics only** | Medium-High | Very Positive |
| **Battle pass** | High | Positive |
| **Character unlock (grindable)** | Medium | Neutral-Positive |
| **Battle pass + cosmetics** | Very High | Positive |
| **Gacha cosmetics** | High | Mixed |

### Skill Rating Systems

| System | Description | Best For |
|--------|-------------|----------|
| **Elo** | Simple win/loss rating | 1v1 games |
| **MMR + visible rank** | Hidden MMR, visible tiers | Team games |
| **Glicko** | Elo with rating deviation | Chess, 1v1 |
| **TrueSkill** | Bayesian, handles team games | Xbox, team games |
| **Custom tiers** | Bronze → Silver → Gold → Platinum → Diamond → Master → Grandmaster | Most competitive |

### Rank Distribution Targets

| Rank | % of Players | Emotional Goal |
|------|-------------|---------------|
| Bronze | 10% | "I just started, room to grow" |
| Silver | 25% | "I'm getting the hang of it" |
| Gold | 30% | "I'm average, which is fine" |
| Platinum | 20% | "I'm above average, proud" |
| Diamond | 10% | "I'm really good at this" |
| Master | 4% | "I'm exceptional" |
| Grandmaster | 1% | "I'm among the best" |

## Match Design

### Match Flow (Shooter/MOBA)

```
Pre-Match
├── Queue (skill-based)
├── Loading screen (tips + enemy info)
├── Draft/Select phase (pick character/hero)
├── Loadout/customize (if applicable)
└── Ready check

Match
├── Early game (first 5 min) — setup, positioning
├── Mid game (5-15 min) — objectives, teamfights
├── Late game (15+ min) — high stakes, climax
└── Resolution (win/lose, MVP, stats)

Post-Match
├── Results screen (stats, progression)
├── Rewards (XP, currency, rank change)
├── Social (honor/report, friend requests)
└── Re-entry (queue again or stop)
```

### Map Design Principles

| Principle | Description | Implementation |
|-----------|-------------|---------------|
| **Symmetry** | Balanced for both sides | Mirror or rotational symmetry |
| **Chokepoints** | Create natural conflict zones | Narrow passages between areas |
| **Sightlines** | Control visual information | Walls, cover, elevation changes |
| **Spawn safety** | Protected spawn areas | Safe zones, spawn protection |
| **Objective placement** | Drive movement and conflict | Central or contested areas |
| **Verticality** | 3D gameplay depth | Elevation, jumping, flying |
| **Callouts** | Named locations | Consistent naming for team communication |

## Live Ops for Competitive

### Season Structure

```
Season Duration: 60-90 days

Week 1: Season start, new content, rank reset
Weeks 2-4: Meta stabilizes, balance patch if needed
Weeks 5-8: Mid-season event, limited-time mode
Weeks 9-11: End-season push, exclusive rewards
Week 12: Season end, rewards distributed, brief off-season
```

### Balance Patch Strategy

| Frequency | Scope | Communication |
|-----------|-------|---------------|
| Weekly | Minor number tweaks | Patch notes |
| Bi-weekly | Moderate adjustments | Dev blog |
| Monthly | Significant changes | Video breakdown |
| Seasonal | Major meta shifts | Full reveal stream |

### Esports Integration

| Feature | Implementation | Community Value |
|---------|---------------|-----------------|
| Spectator mode | Free camera, player POV | Content creation |
| Replay system | Full match replay with controls | Learning, content |
| Tournament mode | Custom lobbies, draft, admin tools | Community events |
| Leaderboards | Regional, global, friend | Competition |
| Pro scene support | Prize pools, partner program | Aspirational |
