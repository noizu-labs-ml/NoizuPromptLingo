# Monetization Design

Comprehensive guide to designing ethical, effective game monetization systems across all models.

## Revenue Models

### Free-to-Play (F2P) + In-App Purchases

The dominant mobile model. Revenue comes from a small percentage of players (2-5% conversion) spending on virtual goods.

**Strengths**: Massive audience, high LTV potential, data-driven optimization
**Weaknesses**: Requires scale (1M+ downloads for meaningful revenue), constant content updates, player trust management

**IAP Categories**:

| Category | Description | Repeatable? | Example |
|----------|-------------|-------------|---------|
| Consumable | Used once, repurchase needed | Yes | Gems, energy, revives |
| Durable | Permanent unlock | No | Characters, levels, modes |
| Cosmetic | Visual only, no gameplay impact | No | Skins, emotes, trails |
| Subscription | Recurring access/bonus | Monthly | VIP pass, daily gem pack |
| Bundle | Curated package of items | Limited | Starter pack, holiday bundle |

**Pricing Psychology**:

| Price Point | Perception | Best For |
|-------------|-----------|----------|
| $0.99 | Impulse buy | Starter packs, single items |
| $4.99 | Small treat | Character unlock, cosmetic set |
| $9.99 | Considered purchase | Battle pass, mid-tier bundle |
| $19.99 | Significant investment | Premium bundle, season+pass |
| $49.99 | Major purchase | Whale-targeted mega bundle |
| $99.99 | Maximum price (iOS/Android cap) | Ultimate pack, anniversary |

### Battle Pass / Season Pass

Tiered reward system tied to seasonal play. Players earn rewards by completing challenges and gaining XP.

**Design Parameters**:

| Parameter | Recommended Range | Notes |
|-----------|------------------|-------|
| Tier count | 50-100 | 50 for casual, 100 for competitive |
| Season duration | 30-90 days | 30 days = high urgency, 90 = casual |
| Free vs paid tiers | 20-30% free | Enough to demonstrate value |
| Premium price | $4.99-$14.99 | Lower for mobile, higher for PC |
| Premium value | 3-5x purchase price | Perceived value drives conversion |
| Catch-up mechanics | Yes | Daily XP bonuses, tier purchasing |
| Tier completion time | 60-100 hours | Spread across season duration |

**Battle Pass Conversion Strategy**:
1. Free track shows premium rewards grayed out — endowed progress effect
2. Mid-season discount or bonus tier — re-engages churned buyers
3. End-of-season urgency — limited-time final push
4. Next season preview — continuity incentive

### Ad Monetization

Revenue from showing advertisements to players. Most effective for casual and hypercasual games.

| Ad Type | Revenue/1000 | Best Placement | Player Sentiment |
|---------|-------------|----------------|-----------------|
| Rewarded video | $10-50 | Opt-in after failure, for bonus | Positive (player chooses) |
| Interstitial | $5-20 | Between levels/matches | Neutral-negative |
| Banner | $0.50-2 | Persistent UI element | Negative |
| Native/playable | $15-40 | As content (mini-game) | Neutral-positive |
| Offerwall | $20-80 | Dedicated screen | Neutral |

**Rewarded Ad Best Practices**:
- Always opt-in, never forced
- Reward must be meaningful (not trivial)
- Place at natural breakpoints (death, level complete)
- Cap at 1-2 per session to avoid fatigue
- Never gate core progression behind ads

### Premium (Paid Upfront)

Single purchase for full game access. Common on PC/console, rare on mobile.

| Price Tier | Platform | Expected Volume | Revenue Profile |
|-----------|----------|----------------|-----------------|
| $0.99-$4.99 | Mobile | High | Low per-unit |
| $9.99-$19.99 | PC indie | Medium | Moderate |
| $29.99-$39.99 | PC AA | Lower | Good |
| $59.99-$69.99 | Console AAA | High (if marketed) | Strong front-load |

**Premium Best Practices**:
- Free demo / first chapter free to drive conversion
- DLC roadmap announced pre-launch for LTV extension
- No microtransactions in premium games (player expectation)
- Steam sales strategy: 25% off at 3 months, 50% at 6 months

### Hybrid Models

Combining multiple revenue streams for diversified income.

| Hybrid | Example | Revenue Mix |
|--------|---------|-------------|
| Premium + DLC | Monster Hunter, Hades | 70% premium / 30% DLC |
| F2P + IAP + Battle Pass | Fortnite, Genshin Impact | 40% IAP / 40% BP / 20% other |
| F2P + IAP + Ads | Most mobile games | 60% IAP / 30% ads / 10% other |
| Premium + Cosmetics | Overwatch, Valorant | 80% premium / 20% cosmetics |
| Subscription + IAP | MMO model | 60% sub / 40% IAP |

## Economy Design

### Currency Systems

| Currency Type | Source | Purpose | Design Rule |
|--------------|--------|---------|-------------|
| **Soft currency** (gold, coins) | Gameplay, daily rewards | Common upgrades, basic items | Plentiful but never enough |
| **Hard currency** (gems, diamonds) | IAP, rare gameplay drops | Premium items, acceleration | Scarce, high perceived value |
| **Social currency** (friend points, guild tokens) | Social actions | Social-specific rewards | Encourages viral behavior |
| **Event currency** (season tokens) | Time-limited activities | Event-specific rewards | Creates urgency and FOMO |
| **Premium currency** (real money) | IAP only | Everything above | Transparent exchange rates |

### Source/Sink Balance

A healthy economy maintains equilibrium between currency entering (sources) and leaving (sinks).

```
Sources (Currency In)          Sinks (Currency Out)
─────────────────────          ────────────────────
Level completion rewards  →    Character upgrades
Daily login bonuses      →    Equipment enhancement
Quest rewards            →    Shop purchases
Event rewards            →    Crafting costs
IAP purchases            →    Guild donations
Achievement bonuses      →    Cosmetics
Ad rewards               →    Progression gates
```

**Balance Rules**:
- **Early game**: Sources slightly outpace sinks (feeling of abundance, hooking players)
- **Mid game**: Sources and sinks roughly balanced (sustainable progression)
- **Late game**: Sinks slightly outpace sources (drives IAP consideration)
- **Endgame**: Sinks significantly outpace sources (whale-sustained economy)

### Inflation Control

| Problem | Symptom | Solution |
|---------|---------|----------|
| Currency inflation | Everything feels cheap, nothing to save for | Introduce new sink (prestige system) |
| Currency deflation | Progression feels impossible, F2P stuck | Increase source rates, add catch-up events |
| Power creep | New content invalidates old investment | Horizontal progression (sidegrades), legacy bonuses |
| Wealth gap | Whale/F2P divide too large | F2P progression path, social rewards, power caps |

## Pricing Psychology

### Anchoring

Present the expensive option first to make the target option feel like a deal.

```
$99.99  Ultimate Pack (5000 gems + 5 heroes)
$49.99  Mega Bundle (2500 gems + 2 heroes)     ← Most will choose this
$9.99   Starter Pack (500 gems + 1 hero)       ← Feels cheap by comparison
```

### Decoy Pricing

Add a third option that makes the target option clearly superior.

```
$9.99   1000 gems                              ← Bad value (decoy)
$19.99  2500 gems + 1 hero                     ← Best value (target)
$49.99  5000 gems + 3 heroes                   ← Premium option
```

### Scarcity and Urgency

| Tactic | Implementation | Duration |
|--------|---------------|----------|
| Flash sale | 50% off for 24 hours | 24-48 hours |
| First purchase bonus | 2x value on first IAP ever | One-time |
| Limited quantity | "Only 1000 available" | Until sold out |
| Season exclusive | Only available this season | 30-90 days |
| Login streak reward | Consecutive daily login bonus | Rolling |

## Regulatory Compliance

### Loot Box / Gacha Laws

| Region | Status | Requirements |
|--------|--------|-------------|
| **EU** | Regulated | Must disclose drop rates, some countries ban for minors |
| **China** | Banned for minors | Must disclose all probabilities, limit spending |
| **Japan** | Self-regulated | Industry self-policing, probability disclosure |
| **South Korea** | Banned for minors | Age verification required |
| **UK** | Under review | Likely regulation coming |
| **US** | State-level | California, Washington considering legislation |

### COPPA (Children's Online Privacy Protection Act)

If targeting under-13:
- No behavioral advertising
- No social features without parental consent
- No personalized push notifications
- Limited data collection
- App Store "Kids" category requires compliance

### App Store / Play Store Policies

| Policy | iOS | Android |
|--------|-----|---------|
| Max IAP price | $999.99 | $999.99 |
| Loot box disclosure | Required | Required |
| Subscription trial | 1-90 days | 1-90 days |
| Refund window | 14 days (EU), request-based | 48 hours automatic |
| Review process | 24-48 hours | 1-3 hours |

## LTV Calculation

```
LTV = ARPU × Average Lifespan × Viral Multiplier

Where:
  ARPU = (Total Revenue / Total Players) per time period
  Average Lifespan = 1 / Churn Rate (e.g., 5% daily churn = 20 day lifespan)
  Viral Multiplier = 1 + K-factor (e.g., K=0.5 → multiplier = 1.5)
```

**LTV Benchmarks by Genre** (90-day, US market):

| Genre | LTV (Good) | LTV (Great) |
|-------|-----------|-------------|
| Hypercasual | $0.30-$0.50 | $0.80+ |
| Casual puzzle | $1.00-$2.00 | $5.00+ |
| Mid-core RPG | $3.00-$5.00 | $15.00+ |
| Mid-core strategy | $2.00-$4.00 | $10.00+ |
| Hardcore / competitive | $5.00-$10.00 | $30.00+ |
| Gacha / collection | $5.00-$15.00 | $50.00+ |
