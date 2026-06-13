# Viral Mechanics

Engineering organic user acquisition through social mechanics, referral systems, and user-generated content.

## Viral Coefficient (K-Factor)

The fundamental metric of organic growth:

```
K = Average invitations per user × Conversion rate of those invitations

K > 1.0 = Exponential growth (each user brings >1 new user)
K = 0.5-1.0 = Strong organic growth
K = 0.1-0.5 = Moderate organic growth
K < 0.1 = Minimal organic growth
```

### K-Factor by Mechanic Type

| Mechanic | Invitations/User | Conv. Rate | K-Factor | Complexity |
|----------|-----------------|------------|----------|-----------|
| Direct referral (rewarded) | 2-5 | 10-20% | 0.2-1.0 | Low |
| Co-op requirement | 1-3 | 30-50% | 0.3-1.5 | Medium |
| Social sharing (score/result) | 3-10 | 2-5% | 0.06-0.5 | Low |
| UGC level sharing | 5-20 | 1-3% | 0.05-0.6 | High |
| Asymmetric multiplayer | 2-5 | 20-40% | 0.4-2.0 | High |
| Guild/social obligation | 1-4 | 25-40% | 0.25-1.6 | Medium |
| Gifting | 2-6 | 15-30% | 0.3-1.8 | Low |
| Spectating/esports | 3-10 | 1-5% | 0.03-0.5 | Medium |

## Viral Mechanism Design Patterns

### Pattern 1: Rewarded Referral

The classic "invite friends, get rewards" system.

**Design Parameters**:

| Parameter | Recommended | Notes |
|-----------|------------|-------|
| Inviter reward | Premium currency, exclusive item | Must be meaningful |
| Invitee reward | Starter bonus, beginner pack | Reduces friction to install |
| Referral limit | 5-10 per month | Prevents abuse |
| Fraud prevention | Device fingerprint, IP limits | Essential |
| Reward timing | Instant on invitee's first action | Immediate gratification |
| Escalation | Better rewards at 1/3/5 referrals | Milestone motivation |

**Example Structure**:
```
Invite 1 friend: 100 gems
Invite 3 friends: 500 gems + exclusive skin
Invite 5 friends: 1500 gems + exclusive hero
Invite 10 friends: 3000 gems + legendary hero
```

### Pattern 2: Social Co-op Gate

Gameplay requires or is significantly better with other players.

**Variants**:
- **Hard gate**: Must have friend to progress (raid, co-op level)
- **Soft gate**: Better rewards with friends, solo possible
- **Time gate**: Event requires group completion within time limit
- **Contribution gate**: Everyone must contribute (no carrying)

**Design Rules**:
- Never hard-gate core progression (alienates solo players)
- Co-op rewards must feel worth the social friction
- Matchmaking fallback for players without friends
- Guild system as social safety net

### Pattern 3: Score/Result Sharing

Players share their achievements, scores, or creations.

**Design Elements**:
- Shareable screenshot with game branding
- "Challenge me" link that opens the game
- Leaderboard position as shareable badge
- Custom replay/share button at moment of achievement

**Best Practices**:
- Make sharing feel like bragging, not advertising
- Include the game's brand/identity in shared content
- Deep link directly to the relevant game state
- Pre-populate share text with personality

### Pattern 4: User-Generated Content (UGC)

Players create and share content that markets the game.

**UGC Types**:

| Type | Viral Potential | Development Cost | Example |
|------|----------------|-----------------|---------|
| Custom levels | High | High | Super Mario Maker, Roblox |
| Character builds | Medium | Low | RPG build sharing |
| Replay videos | High | Medium | Fortnite replays |
| Screenshots | Low | Low | Any game |
| Mods | Very High | Very High | Skyrim, Minecraft |
| Streamer content | Very High | Low (tools only) | Twitch integration |

**UGC Design Principles**:
- Creation tools must be accessible (low floor, high ceiling)
- Curation system to surface quality content
- Creator attribution and recognition
- In-game rewards for popular creations
- Report/moderation system for safety

### Pattern 5: Asymmetric Multiplayer

Non-players can participate without installing the game.

**Examples**:
- **Wordle**: Share results as emoji grid, no account needed
- **Among Us**: Stream + chat creates viral moments
- **Jackbox**: One device, many players via phone browser
- **Twitch Plays**: Chat controls the game

**Design Elements**:
- Zero-friction entry (no install, no account for spectators)
- Shareable output that's entertaining on its own
- Social media native format (emoji, image, short video)

## Social System Architecture

### Guild/Clan System

| Feature | Casual | Mid-Core | Hardcore |
|---------|--------|----------|----------|
| Max members | 15-30 | 30-50 | 50-100 |
| Guild level | No | Yes | Yes |
| Guild wars | No | Optional | Required |
| Guild chat | Basic | Moderated | Rich (voice, roles) |
| Guild rewards | Minimal | Moderate | Substantial |
| Guild leader tools | Basic | Kick/promote | Full admin suite |

### Social Feature Rollout

| Player Level | Unlock | Purpose |
|-------------|--------|---------|
| Tutorial complete | Friend list | Basic social |
| Level 5 | Add friends | Connection building |
| Level 10 | Visit friends | Asynchronous interaction |
| Level 15 | Guild unlock | Group identity |
| Level 20 | Guild wars | Cooperative competition |
| Level 30 | Guild creation | Leadership investment |

## Influencer & Streamer Strategy

### Game Design for Streamers

Games that stream well have specific design properties:

| Property | Description | Implementation |
|----------|-------------|---------------|
| Spectacle moments | Visually impressive events | Ultimate abilities, boss kills, rare drops |
| Narrative moments | Stories that emerge from play | Random encounters, player interactions |
| High emotion | Tension, surprise, triumph | Close matches, clutch plays, fails |
| Audience interaction | Viewers can affect the game | Chat voting, gifted subs, raids |
| Shareable clips | Easy capture and share | Auto-clip, replay system |
| Regular drops | Predictable reward moments | Gacha pulls, loot box openings |

### Streamer Partnership Tiers

| Tier | Reach | Compensation | Support |
|------|-------|-------------|---------|
| Nano (1K-10K) | Niche community | Game codes, in-game items | Self-serve press kit |
| Micro (10K-100K) | Dedicated audience | Game codes + $100-500 | Custom referral code |
| Macro (100K-1M) | Broad reach | $500-5K + rev share | Dedicated contact, early access |
| Mega (1M+) | Mass market | $5K-50K+ | Full partnership, co-creation |

## Viral Growth Timeline

```
Pre-Launch (T-30 to T-0)
├── Influencer seeding
├── Beta community building
├── Press kit distribution
└── Social media presence

Launch (T-0 to T+7)
├── Streamer activation
├── Referral system live
├── Press coverage push
├── Social sharing features active
└── Community management active

Growth Phase (T+7 to T+30)
├── UGC tools promotion
├── Community events
├── Influencer partnerships
├── Viral mechanic optimization (A/B test)
└── Cross-promotion with other games

Sustain Phase (T+30+)
├── Regular content updates
├── Community-driven events
├── Esports/competitive scene
├── Mod support (if applicable)
└── Cross-platform virality
```

## Measuring Viral Growth

### Key Metrics

| Metric | Formula | Target |
|--------|---------|--------|
| K-factor | invitations × conversion | >0.5 for growth |
| Organic install rate | organic installs / total installs | >30% |
| Social actions/session | shares + invites + gifts per session | >0.1 |
| UGC creation rate | content created / DAU | >1% |
| Referral conversion | referred installs / referral clicks | >15% |
| Social DAU lift | DAU with social features vs without | >30% |

### Virality A/B Tests

| Test | Variable | Metric |
|------|----------|--------|
| Referral reward size | 100 vs 200 gems per referral | Referral rate |
| Share prompt timing | End of match vs mid-match | Share rate |
| Share format | Screenshot vs video vs text | Click-through rate |
| Social feature gating | Level 5 vs level 10 unlock | Social engagement |
| Guild recommendation | Auto-suggest vs manual search | Guild join rate |
