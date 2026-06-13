# Soft Launch Guide

Strategy for test-market deployment, KPI measurement, and iteration before worldwide launch.

## Soft Launch Objectives

1. **Validate product-market fit** — Do players engage and retain?
2. **Optimize monetization** — What's the optimal IAP pricing and ad placement?
3. **Stress test infrastructure** — Can servers handle load?
4. **Calibrate economy** — Is the game economy balanced at scale?
5. **Identify bugs** — What breaks with real players?

## Test Market Selection

| Market | Cost Per Install | Value | Best For |
|--------|-----------------|-------|----------|
| **Philippines** | $0.05-$0.20 | Low CPI, good retention data | Budget testing |
| **Thailand** | $0.10-$0.30 | Moderate CPI, engaged players | Southeast Asia validation |
| **Canada** | $0.50-$1.50 | US-like behavior, English | North America validation |
| **Australia** | $0.80-$2.00 | Western behavior, good CPI | English-speaking validation |
| **Brazil** | $0.10-$0.30 | Large market, Portuguese | LATAM validation |
| **UK** | $1.00-$3.00 | Premium market behavior | European validation |

**Recommended Strategy**: Start with Philippines (cheap data), then Canada (behavioral validation).

## KPI Targets by Soft Launch Phase

### Phase 1: Technical Validation (Week 1-2)

| KPI | Target | Action if Below |
|-----|--------|----------------|
| Crash rate | <1% | Fix before proceeding |
| ANR rate (Android) | <0.5% | Fix before proceeding |
| Load time | <5 seconds | Optimize |
| Server response | <200ms | Scale infrastructure |
| Session start rate | >90% | Fix onboarding |

### Phase 2: Engagement Validation (Week 2-4)

| KPI | Target | Action if Below |
|-----|--------|----------------|
| D1 Retention | >30% | Redesign tutorial/onboarding |
| D7 Retention | >10% | Add retention mechanics |
| Session length | >3 min | Improve core loop |
| Sessions/day | >2 | Add daily incentives |
| Tutorial completion | >80% | Simplify tutorial |

### Phase 3: Monetization Validation (Week 4-8)

| KPI | Target | Action if Below |
|-----|--------|----------------|
| Conversion rate | >1.5% | Adjust IAP pricing/placement |
| ARPU (daily) | >$0.03 | Economy tuning |
| ARPPU (monthly) | >$5 | Value perception adjustment |
| First purchase timing | <3 days | Improve first IAP offer |
| LTV (projected 90-day) | >$1.50 | Optimize full funnel |

### Phase 4: Scale Validation (Week 8-12)

| KPI | Target | Action if Below |
|-----|--------|----------------|
| CPI (target market) | <$2.00 | Creative optimization |
| LTV/CPI ratio | >1.5 | Monetization optimization |
| Organic/paid ratio | >30% organic | Viral mechanic improvement |
| K-factor | >0.3 | Social feature enhancement |

## A/B Test Plan

### Priority Tests (Run in Order)

| Test | Variable | Variants | Duration | Success Metric |
|------|----------|----------|----------|---------------|
| **Tutorial flow** | Long vs short tutorial | A: 5-min tutorial, B: 2-min tutorial | 1 week | D1 retention |
| **First IAP offer** | Price point | A: $0.99, B: $4.99, C: $9.99 | 2 weeks | Conversion rate |
| **Economy pacing** | Currency earn rate | A: Fast, B: Medium, C: Slow | 2 weeks | Session length, IAP conversion |
| **Ad placement** | Rewarded ad frequency | A: 1/session, B: 2/session, C: opt-in only | 2 weeks | Ad revenue, retention |
| **Battle pass** | Price vs value | A: $4.99/50 tiers, B: $9.99/100 tiers | 4 weeks | BP conversion, retention |
| **Push notifications** | Frequency & copy | A: 1/day, B: 2/day | 2 weeks | D7 retention, opt-out rate |

## Soft Launch Checklist

### Pre-Launch (Before Day 1)

- [ ] Analytics SDKs integrated (Firebase, Adjust, GameAnalytics)
- [ ] Event tracking covers all key funnels (install → tutorial → first IAP)
- [ ] Remote config system operational (for A/B tests without updates)
- [ ] Crash reporting active (Crashlytics, Sentry)
- [ ] Server monitoring dashboard operational
- [ ] Test device matrix covers top 20 devices for target platform
- [ ] App store listing published (geo-restricted)
- [ ] Legal review complete (privacy policy, terms, COPPA if applicable)

### During Soft Launch (Week 1-12)

- [ ] Daily KPI review dashboard
- [ ] Weekly playtest sessions with new players
- [ ] Bi-weekly A/B test results review
- [ ] Monthly economy balance check
- [ ] Bug triage and hotfix pipeline active
- [ ] Player feedback collection (Discord, reviews, support tickets)

### Go/No-Go Decision (Week 10-12)

**Go criteria (ALL must be met)**:
- [ ] D1 retention >35%
- [ ] D7 retention >12%
- [ ] LTV/CPI ratio >1.5
- [ ] Crash rate <0.5%
- [ ] Economy stable (no inflation/deflation detected)
- [ ] Monetization funnel converting >2%

**No-Go actions**:
- Extend soft launch with specific iteration plan
- Pivot underperforming features
- In worst case, cancel and reallocate resources

## Post-Soft-Launch Transition

### Worldwide Launch Preparation

| Timeline | Activity |
|----------|----------|
| T-4 weeks | Final economy adjustments based on soft launch data |
| T-3 weeks | Store listing optimization (ASO) |
| T-2 weeks | Press kit and influencer outreach |
| T-1 week | App store submission for all territories |
| T-0 | Worldwide launch |
| T+1 day | Monitor KPIs hourly |
| T+1 week | First hotfix if needed |
| T+2 weeks | First live event |
| T+4 weeks | First content update |

### Live Ops Cadence (Post-Launch)

| Cadence | Activity |
|---------|----------|
| Daily | KPI monitoring, bug triage |
| Weekly | Live event rotation, balance tweaks |
| Bi-weekly | A/B test results, feature iteration |
| Monthly | Content update, economy review |
| Quarterly | Major feature release, season reset |
