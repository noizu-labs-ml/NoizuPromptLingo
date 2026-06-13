# Worked Example: Mobile RPG — "Void Architect"

End-to-end game design walkthrough from concept through soft launch, using the game-design skill's methodology.

## Concept Brief

**Title**: Void Architect
**Core Fantasy**: Build your own dimensional sanctuary by harvesting ancient amulets and defending against specters, watching your void expand into a thriving otherworldly civilization.
**Genre**: Building & Crafting / Strategy Simulation
**Platform**: Mobile (iOS + Android), cross-platform with PC
**Rating**: E for Mild Fantasy Violence

## Step 1: Genre & Platform Selection

**Analysis**: The concept combines building mechanics (like Minecraft/ Terraria) with tower defense and collection. Mobile-first because:
- Building/crafting games thrive on mobile (touch-friendly)
- Short session loops fit mobile play patterns
- F2P monetization model aligns with building game economics

**Decision**: Mobile primary, PC secondary via cross-platform. Unity engine for cross-platform support.

## Step 2: Core Loop Design

```
Explore Void → Harvest Amulets → Craft Structures → Defend vs Specters → Expand Void → (repeat)
     ↑                                                            |
     └─────────────── Rewards & Resources ────────────────────────┘
```

### Session Flow (10-15 min target)

```
0:00-0:30  Collect offline earnings (amulets generated while away)
0:30-2:00  Check defenses, repair any damage from specter attacks
2:00-5:00  Explore new void territory, harvest fresh amulets
5:00-8:00  Craft new structures from harvested amulets
8:00-10:00 Optimize layout, connect defense network
10:00-12:00 Defend against scheduled specter wave
12:00-13:00 Collect wave rewards, check daily quests
13:00-14:00 Set up next session's activities (queue crafting, assign defenders)
14:00      Session end — next specter wave in 4 hours (return hook)
```

## Step 3: Meta Progression

### Progression Tree

```
Void Level 1-10:  Basic structures, 3 amulet types, 2 specter types
Void Level 11-20: Shadow structures unlock, 6 amulet types, 4 specter types
Void Level 21-30: Crimson defense matrix, 10 amulet types, 6 specter types
Void Level 31-40: Void expansion mechanics, 15 amulet types, boss specters
Void Level 41-50: Interdimensional trade, 20+ amulet types, raid specters
Void Level 50+:   Endgame void sculpting, competitive void rankings
```

### Unlock Cadence

| Level | Unlocks | Purpose |
|-------|---------|---------|
| 1 | Basic harvesting, building | Core mechanics |
| 3 | Defense structures | Introduce combat |
| 5 | Amulet crafting | Depth in building |
| 8 | Shadow structures | New mechanic layer |
| 10 | Guild system | Social integration |
| 15 | Void expansion | Territory control |
| 20 | Crimson defense matrix | Advanced combat |
| 25 | Specter research | Collection depth |
| 30 | Interdimensional trade | Economy expansion |
| 40 | Competitive void rankings | Endgame goal |

## Step 4: Monetization Design

### Model: Hybrid (IAP + Ads + Battle Pass)

| Revenue Stream | % of Revenue | Details |
|---------------|-------------|---------|
| IAP (currencies + bundles) | 50% | Amulets, speed-ups, exclusive structures |
| Battle Pass | 30% | Seasonal void expansion content |
| Rewarded Ads | 15% | Double offline earnings, bonus amulets |
| Special Offers | 5% | Limited-time bundles |

### IAP Catalog

| Item | Price | Value | Target Audience |
|------|-------|-------|-----------------|
| Starter Pack (one-time) | $0.99 | 500 gems + rare amulet | All new players |
| Bag of Gems | $4.99 | 500 gems | Regular spenders |
| Chest of Gems | $9.99 | 1,200 gems (20% bonus) | Mid-spenders |
| Void Expansion Bundle | $19.99 | 3,000 gems + exclusive structure | Committed players |
| Cosmic Vault | $49.99 | 8,000 gems + legendary amulet | Whales |
| Remove Ads | $4.99 | Permanent ad removal | Ad-sensitive players |

### Battle Pass Structure

| Parameter | Value |
|-----------|-------|
| Name | Void Season Pass |
| Duration | 45 days |
| Tiers | 50 |
| Price | $9.99 |
| Free track | 15 tiers (basic rewards) |
| Premium track | 50 tiers (exclusive structures, amulets, cosmetics) |
| Value perception | 5x purchase price in premium rewards |

## Step 5: Engagement & Retention

### Retention Strategy

| Timing | Mechanic | Psychology |
|--------|----------|-----------|
| D0 | Power fantasy: start with powerful amulet | Taste of endgame |
| D1 | "Your first shadow structure finishes in 8 hours!" | Return hook |
| D1-D7 | 7-day login streak with escalating rewards | Loss aversion |
| D7 | Guild unlock + first guild event | Social obligation |
| D14 | First competitive void ranking | Status competition |
| D30 | Season pass launch | FOMO + novelty |
| D60+ | Community void challenges (shared goals) | Autonomy + purpose |

### Viral Mechanics

| Mechanic | K-Factor Target | Implementation |
|----------|----------------|---------------|
| Guild co-op | 0.3-0.5 | Build together, specter raids require 4 players |
| Void sharing | 0.1-0.3 | Share screenshot of void layout |
| Referral bonus | 0.2-0.5 | Both get exclusive amulet when friend installs |
| Gifting | 0.1-0.3 | Send amulets to friends, they need to install to claim |

**Target K-factor**: 0.5-0.8 (strong organic growth)

## Step 6: Narrative Design

### Story Spine

1. **Equilibrium**: The void is empty, silent, waiting
2. **Inciting incident**: You discover the first amulet — a memory fragment of a destroyed civilization
3. **Complication**: The specter that destroyed that civilization is drawn to the amulet
4. **Rising action**: Each new amulet you claim attracts stronger specters
5. **Midpoint reversal**: You learn YOU are the architect who created the void — and the specters
6. **Crisis**: The void begins collapsing; all your collected civilizations' memories are at risk
7. **Climax**: Confront the prime specter (your own creation) to stabilize the void
8. **Resolution**: The void is stabilized, but now you must rebuild all the civilizations you accidentally destroyed

### Lore Integration

- Each amulet has a memory fragment (text description of the civilization it came from)
- Specter types correspond to different fallen civilizations
- Building with amulets tells their story through environmental design
- Codex unlocks as you collect amulets — completionist driver

## Step 7: Production Plan

### Team & Timeline

| Role | Count | Phase | Duration |
|------|-------|-------|----------|
| Game Designer | 1 | All | 12 months |
| Unity Developer | 2 | All | 12 months |
| Backend Developer | 1 | Phase 2+ | 10 months |
| 2D Artist | 1 | All | 12 months |
| 3D Artist | 1 | Phase 2+ | 8 months |
| UI Designer | 1 | Phase 1-2 | 6 months |
| QA | 1 | Phase 3+ | 4 months |

### Milestones

| Month | Milestone | Deliverable |
|-------|-----------|------------|
| 1-2 | Pre-production | GDD complete, prototype playable |
| 3-5 | Alpha | Core loop + building + combat functional |
| 6-8 | Beta | All features, art replacing placeholders |
| 9 | Content complete | All content, economy balanced |
| 10-11 | Soft launch | Philippines + Canada, KPI monitoring |
| 12 | Worldwide launch | All territories, live ops begin |

### Budget: $350K (12-month development)

| Category | Amount | % |
|----------|--------|---|
| Personnel (8 people avg) | $240K | 69% |
| Software & tools | $15K | 4% |
| Art outsourcing | $25K | 7% |
| Backend infrastructure | $15K | 4% |
| Marketing (soft launch) | $30K | 9% |
| Contingency | $25K | 7% |

## Step 8: Soft Launch Plan

### Test Markets

| Market | Duration | Installs | Focus |
|--------|----------|----------|-------|
| Philippines | Weeks 1-4 | 5,000 | Technical, basic retention |
| Canada | Weeks 4-8 | 10,000 | Behavioral, monetization |
| Australia | Weeks 8-10 | 5,000 | Western validation |

### KPI Targets

| KPI | Soft Launch Target | Worldwide Target |
|-----|-------------------|-----------------|
| D1 Retention | 35% | 40% |
| D7 Retention | 12% | 18% |
| D30 Retention | 5% | 8% |
| Conversion rate | 2% | 3.5% |
| ARPU (daily) | $0.05 | $0.10 |
| LTV (90-day) | $1.50 | $3.00 |
| CPI (Canada) | <$2.00 | <$1.50 |

### A/B Test Plan

| Test | Variable | Duration | Success Metric |
|------|----------|----------|---------------|
| Tutorial | Long vs short | 2 weeks | D1 retention |
| First IAP | $0.99 vs $4.99 | 2 weeks | Conversion |
| Economy pacing | Fast vs slow earn | 2 weeks | D7 retention + ARPU |
| Specter frequency | Every 4h vs 6h | 2 weeks | Session frequency |

## Results & Lessons

This worked example demonstrates the full game-design skill workflow:

1. **Concept brief** captures the core fantasy and scope
2. **Core/meta loop design** creates the engagement engine
3. **Monetization architecture** layers revenue without compromising fun
4. **Engagement strategy** builds retention through psychology
5. **Narrative design** integrates story into gameplay
6. **Production plan** scopes the project realistically
7. **Soft launch plan** de-risks the worldwide launch

The key insight: Void Architect's unique angle (amulets-as-resources with embedded civilization memories) creates a natural narrative-economic loop where collecting drives story and story drives collection. This dual motivation (gameplay + narrative) is the strongest retention driver.
