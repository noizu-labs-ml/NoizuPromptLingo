# Retention Patterns

Behavioral psychology-driven patterns for designing player engagement systems that respect the player's time while maximizing long-term retention.

## Core Retention Metrics

| Metric | Definition | Good (Mobile) | Great (Mobile) | Good (PC) | Great (PC) |
|--------|-----------|--------------|----------------|-----------|------------|
| D1 Retention | Returns day after install | 35% | 50%+ | 40% | 60%+ |
| D7 Retention | Returns after 1 week | 15% | 25%+ | 20% | 35%+ |
| D30 Retention | Returns after 1 month | 5% | 10%+ | 10% | 20%+ |
| Session length | Average play session | 5-15 min | 15-30 min | 30-60 min | 60-120 min |
| Sessions/day | Average daily sessions | 2-3 | 4-6 | 1-2 | 2-3 |
| DAU/MAU | Stickiness ratio | 15% | 25%+ | 20% | 35%+ |

## Psychological Foundations

### Zeigarnik Effect
People remember uncompleted tasks better than completed ones.
**Application**: Show progress bars, "next unlock" previews, half-completed collections.

### Endowed Progress Effect
People are more likely to complete a task if they feel they've already started.
**Application**: Give players 2/10 stamps on their loyalty card. Start collections with one item.

### Loss Aversion
People feel losses 2x more strongly than equivalent gains.
**Application**: Streak systems (lose streak = loss), expiring resources, limited-time events.

### Sunk Cost Fallacy
People continue investing because of prior investment.
**Application**: Login streaks, collection completion, progression investment. Use ethically.

### Variable Ratio Schedule
Unpredictable rewards create the strongest reinforcement.
**Application**: Loot boxes, random drops, gacha pulls. Most addictive schedule — use with caution.

### Endowment Effect
People value things more once they own them.
**Application**: Free trial heroes, time-limited ownership, "rent before you buy."

## Retention Design by Day

### Day 0 (Tutorial Phase)
**Goal**: Hook the player in first 3 minutes. Show the fantasy immediately.

| Tactic | Implementation | Psychology |
|--------|---------------|-----------|
| Power fantasy intro | Start powerful, lose it, quest to regain | Taste of endgame, set aspiration |
| Clear next step | Always show what to do next | Reduce friction, build momentum |
| First reward in 30s | Give meaningful reward early | Establish reward cadence |
| Tutorial skip | Let experienced players skip | Respect player autonomy |
| End with cliffhanger | End tutorial mid-story beat | Zeigarnik effect |

### Day 1 (Return Hook)
**Goal**: Give the player a reason to come back tomorrow.

| Tactic | Implementation | Psychology |
|--------|---------------|-----------|
| Next-day reward | "Come back tomorrow for 500 gems!" | Anticipation, commitment |
| Half-finished quest | Quest requiring 2 sessions | Zeigarnik effect |
| Building in progress | "Your castle finishes in 8 hours" | Completion drive |
| Daily login bonus | Day 1 of 7-day login calendar | Endowed progress (1/7 done) |
| New feature unlock | "Tomorrow: unlock the Arena!" | Curiosity, anticipation |

### Day 2-7 (Habit Formation)
**Goal**: Establish daily play as a habit.

| Tactic | Implementation | Psychology |
|--------|---------------|-----------|
| 7-day login streak | Escalating rewards, streak break = reset | Loss aversion |
| Daily quests | 3-5 quick tasks with reward | Routine building |
| Energy system | Depletes daily, encourages return | Scarcity, scheduling |
| Social introduction | Guild invites, friend features | Social proof |
| Weekly event | Time-limited event with exclusive rewards | FOMO |

### Day 7-30 (Investment Phase)
**Goal**: Deepen investment through social systems and progression.

| Tactic | Implementation | Psychology |
|--------|---------------|-----------|
| Guild system | Join/create guilds with shared goals | Social obligation |
| PvP unlock | Competitive play with rankings | Status, competition |
| Collection system | Heroes, cards, items to collect | Completion drive |
| Season pass | Seasonal progression track | Sunk cost, FOMO |
| Story chapters | Episodic content unlocks | Narrative investment |

### Day 30+ (Retention & Live Ops)
**Goal**: Maintain engagement through content updates and community.

| Tactic | Implementation | Psychology |
|--------|---------------|-----------|
| Live events | Limited-time challenges, story events | FOMO, novelty |
| New content drops | Characters, levels, game modes | Novelty seeking |
| Community features | Leaderboards, tournaments, UGC | Autonomy, mastery |
| Prestige system | Reset with permanent bonuses | Fresh start, mastery |
| Anniversary events | Annual celebrations with exclusive rewards | Loyalty reward |

## Session Design

### Session Length Targets

| Platform | Target Session | Session Range | Sessions/Day |
|----------|---------------|---------------|-------------|
| Mobile (casual) | 3-5 min | 1-10 min | 4-8 |
| Mobile (mid-core) | 10-15 min | 5-30 min | 2-4 |
| Mobile (hardcore) | 15-30 min | 10-60 min | 2-3 |
| PC/Console | 30-60 min | 15-120 min | 1-2 |

### Session Pacing

```
Session Start (0:00)
├── Quick win / reward pickup (0:00-0:30) ← Login bonus, energy collect
├── Core loop engagement (0:30-5:00) ← Main gameplay
├── Mid-session reward (5:00-5:30) ← Level up, chest unlock
├── Social interaction (5:30-6:00) ← Guild check, friend battle
├── Extended engagement (6:00-12:00) ← Event, ranked match
├── Session-end hook (12:00-13:00) ← "Next unlock in 2 hours" notification
└── Session End
```

### Energy System Design

| Parameter | Casual | Mid-Core | Hardcore |
|-----------|--------|----------|----------|
| Max energy | 30-50 | 50-100 | 100-200 |
| Regen rate | 1/5min | 1/3min | 1/1min |
| Full regen time | 2-4 hours | 2-3 hours | 1-2 hours |
| Energy per session | 10-20 | 20-40 | 40-80 |
| Sessions to deplete | 2-3 | 2-3 | 2-3 |
| IAP refill cost | $0.99 | $1.99 | $4.99 |

**Design Principle**: Energy should feel like it guides pacing, not gates fun. Players should run out 80% of the time they play, not 20%.

## Streak Systems

### Daily Login Streaks

| Streak Day | Reward | Escalation |
|-----------|--------|-----------|
| Day 1 | Small soft currency | Baseline |
| Day 2 | Slightly more | +20% |
| Day 3 | XP boost | New reward type |
| Day 4 | Medium soft currency | +50% from day 1 |
| Day 5 | Cosmetic item | New reward type |
| Day 6 | Large soft currency | +100% from day 1 |
| Day 7 | Premium currency or hero | Jackpot reward |

**Streak Protection**: Allow 1 miss per week (grace day) or purchasable streak preservation.

### Activity Streaks

| Streak Type | Duration | Miss Policy | Reward |
|-------------|----------|-------------|--------|
| Login streak | Daily | Reset on miss (1 grace/week) | Escalating daily |
| Quest streak | Weekly | Miss = reset | Weekly chest |
| Win streak | Per session | Loss = reset | Multiplier bonus |
| Season streak | Monthly | No miss allowed | Season exclusive |

## Push Notification Strategy

| Timing | Content | Goal |
|--------|---------|------|
| Tutorial complete | "Your hero leveled up! Come claim your reward." | D1 return |
| Energy full | "Your energy is full! Don't let it go to waste." | Session start |
| Construction done | "Your castle is ready! Come see it." | Return trigger |
| Event start | "New event: Dragon Festival starts NOW!" | Urgency |
| Streak at risk | "You'll lose your 6-day streak! Log in before midnight." | Loss aversion |
| Social | "Your guild needs you! Battle starts in 1 hour." | Social obligation |
| Reward expiration | "Your daily reward expires in 2 hours!" | Urgency |

**Push Notification Rules**:
- Max 2 per day for casual, 1 per day for hardcore
- Always provide actionable value, never just "come play"
- Timezone-aware scheduling based on player's active hours
- A/B test notification copy and timing
- Easy opt-out (required by app stores)
