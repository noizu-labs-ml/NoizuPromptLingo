# npl-conversion - Detailed Reference

Growth and retention optimization agent for developer-focused products. Analyzes user behavior, designs viral mechanics, optimizes conversion funnels, and develops data-driven retention strategies.

## Table of Contents

- [Capabilities](#capabilities)
- [Conversion Framework](#conversion-framework)
- [Developer Psychology](#developer-psychology)
- [Funnel Analysis](#funnel-analysis)
- [Viral Growth Mechanics](#viral-growth-mechanics)
- [Retention Optimization](#retention-optimization)
- [A/B Testing Framework](#ab-testing-framework)
- [Metrics Dashboard](#metrics-dashboard)
- [Usage Examples](#usage-examples)
- [Integration Patterns](#integration-patterns)
- [Templates](#templates)
- [Best Practices](#best-practices)
- [Anti-Patterns](#anti-patterns)
- [Configuration](#configuration)

---

## Capabilities

### Core Functions

| Function | Description |
|:---------|:------------|
| Funnel Analysis | Identify conversion bottlenecks across user journey stages |
| Viral Loop Design | Create referral systems and sharing mechanics |
| Retention Strategy | Build engagement loops and habit formation frameworks |
| A/B Test Planning | Design experiments with statistical significance |
| Metric Tracking | Monitor leading/lagging indicators across funnel |
| Behavior Analysis | Map developer decision patterns and motivations |

### Supported Conversion Types

- `trial-to-paid` - Free trial to paid subscription
- `signup-to-activation` - Registration to first value delivery
- `activation-to-retention` - Initial use to habitual engagement
- `user-to-advocate` - Active user to referral source
- `oss-contributor` - User to open-source contributor

---

## Conversion Framework

The agent operates on a product-led growth model with six optimization points:

```
Traffic Sources --> Landing Experience --> Value Demonstration
      ^                    |                      |
      |                    v                      v
 Viral Growth <-- Advocacy <-- Habit Formation <-- Trial/Evaluation
                                    ^                    |
                                    |                    v
                                Expansion <-- First Value Delivered
```

### Optimization Points

1. **Traffic Quality** - Source effectiveness and intent alignment
2. **Landing Conversion** - Message clarity and friction reduction
3. **Trial Activation** - Time-to-value and onboarding completion
4. **Value Delivery** - Success moment identification and measurement
5. **Retention Loops** - Engagement mechanics and habit triggers
6. **Viral Mechanics** - Sharing triggers and referral attribution

---

## Developer Psychology

### Evaluation Behavior Patterns

Developers differ from general consumers in conversion behavior:

| Behavior | Impact on Conversion |
|:---------|:--------------------|
| Extended trials | Requires longer evaluation windows (14-30 days typical) |
| Feature deep-dives | Technical documentation drives conversion |
| Integration testing | Real-world workflow compatibility assessment |
| Peer consultation | Team and community input influences decisions |

### Decision Factors (Priority Order)

1. **Technical Capabilities** - Feature depth, customization options
2. **Integration Ease** - Workflow compatibility, setup simplicity
3. **Performance Impact** - Speed, reliability, resource efficiency
4. **Community Trust** - Peer recommendations, transparent development

### Optimization Implications

- Lead with code examples, not marketing claims
- Provide sandbox environments for evaluation
- Surface peer testimonials from recognized developers
- Document migration paths from competitor tools

---

## Funnel Analysis

### Standard Developer Funnel Stages

```yaml
stages:
  awareness:
    metrics: [unique_visitors, traffic_source, search_intent]
    benchmark: varies by channel

  consideration:
    metrics: [docs_pageviews, github_stars, time_on_site]
    benchmark: 3+ pages/session

  trial:
    metrics: [signups, trial_starts, api_key_generation]
    benchmark: 5-15% of visitors

  activation:
    metrics: [first_api_call, tutorial_complete, integration_done]
    benchmark: 40-60% of trials

  conversion:
    metrics: [paid_upgrade, plan_selection, billing_complete]
    benchmark: 15-25% of activated

  retention:
    metrics: [day7_active, day30_active, monthly_active]
    benchmark: 70% day7, 40% day30

  expansion:
    metrics: [seat_additions, plan_upgrades, feature_upsells]
    benchmark: 10-20% annual expansion

  advocacy:
    metrics: [referrals, reviews, community_contributions]
    benchmark: 5-10% refer within 90 days
```

### Bottleneck Identification

The agent analyzes drop-off points using:

1. **Cohort analysis** - Compare behavior across user segments
2. **Session recording analysis** - Identify friction in UI flows
3. **Survey integration** - Capture qualitative feedback at exit points
4. **Event sequencing** - Map common paths vs. churning paths

---

## Viral Growth Mechanics

### Viral Loop Types

#### 1. Value-Based Sharing
Users share when product delivers clear value.

```yaml
trigger: success_moment  # e.g., "first deployment complete"
mechanism: one_click_share
recipient_value: working_template_or_example
attribution: referrer_credit_in_product
```

#### 2. Collaborative Features
Product requires sharing for full functionality.

```yaml
trigger: team_workflow
mechanism: invite_collaborators
recipient_value: immediate_access_to_shared_work
attribution: workspace_owner_credit
```

#### 3. Content Distribution
User-generated content promotes product.

```yaml
trigger: template_creation
mechanism: public_gallery_or_marketplace
recipient_value: time_saved_using_template
attribution: creator_profile_and_stats
```

### Viral Coefficient Calculation

```
K = invitations_per_user * conversion_rate_of_invited

K > 1: Viral growth (each user brings >1 new user)
K = 0.5-1: Sustainable with paid acquisition
K < 0.5: Heavy acquisition dependency
```

### Developer-Specific Incentives

| Incentive Type | Example | Effectiveness |
|:---------------|:--------|:-------------|
| Extended features | Extra API calls, advanced features | High |
| Community recognition | Contributor badge, leaderboard | Medium-High |
| Early access | Beta features, roadmap input | High |
| Swag/credits | Branded items, cloud credits | Medium |
| Discounts | Price reduction for referee | Low (developers skeptical) |

---

## Retention Optimization

### Habit Formation Framework (Hook Model)

```yaml
trigger:
  external: [email_digest, slack_notification, github_integration]
  internal: [workflow_need, problem_solving, curiosity]

action:
  target_behavior: daily_use_of_core_feature
  friction_reduction: [saved_preferences, keyboard_shortcuts, cli_aliases]

variable_reward:
  types: [new_content, community_activity, feature_updates]
  schedule: random_reinforcement

investment:
  user_commits: [custom_config, integrations, templates]
  increases_value: stored_data_and_customization
```

### Retention Cohort Benchmarks

| Timeframe | Target | Action if Below |
|:----------|:-------|:----------------|
| Day 1 | 60-80% | Review onboarding flow |
| Day 7 | 40-60% | Check activation metrics |
| Day 30 | 25-40% | Evaluate value delivery |
| Day 90 | 15-25% | Assess habit formation |

### Churn Prevention Signals

Early warning indicators requiring intervention:

- **Engagement drop** - 50% reduction in weekly activity
- **Feature abandonment** - Core feature unused 14+ days
- **Support pattern** - Multiple unresolved tickets
- **Performance issues** - Error rate spike or latency increase

### Intervention Strategies

| Signal | Automated Response | Human Response |
|:-------|:-------------------|:---------------|
| Engagement drop | Re-engagement email with new features | None initially |
| Feature abandonment | In-app tooltip with help resources | CSM outreach (enterprise) |
| Support issues | Proactive troubleshooting guide | Priority support escalation |
| Performance issues | Status notification + workaround | Engineering investigation |

---

## A/B Testing Framework

### Test Design Process

1. **Hypothesis formation** - State expected outcome and reasoning
2. **Sample size calculation** - Determine required users for statistical power
3. **Duration planning** - Account for weekly cycles and decision windows
4. **Implementation** - Feature flags or split testing infrastructure
5. **Analysis** - Statistical significance and segment breakdown
6. **Decision** - Ship, iterate, or discard

### Developer-Specific Considerations

| Factor | Adjustment |
|:-------|:-----------|
| Longer evaluation periods | Run tests 2-4 weeks minimum |
| Smaller user bases | Accept lower statistical power (70-80%) |
| Technical audience | Avoid dark patterns, maintain trust |
| Feature complexity | Test one variable at a time |

### Test Categories

```yaml
landing_page:
  - headline_messaging
  - value_proposition_ordering
  - social_proof_placement
  - cta_copy_and_placement

onboarding:
  - tutorial_length_and_depth
  - progressive_disclosure_timing
  - integration_ordering
  - success_milestone_definition

pricing:
  - tier_structure
  - feature_gating
  - trial_length
  - upgrade_prompts

retention:
  - email_cadence_and_content
  - in_product_prompts
  - feature_discovery_timing
  - community_integration_points
```

---

## Metrics Dashboard

### Primary Metrics (AARRR Framework)

| Stage | Metric | Calculation |
|:------|:-------|:------------|
| Acquisition | Visitor quality | (developers / total visitors) * 100 |
| Activation | Time to first value | median(first_success - signup_time) |
| Retention | Week-over-week active | (active_week_n / active_week_n-1) * 100 |
| Revenue | Trial conversion rate | (paid_upgrades / trial_starts) * 100 |
| Referral | Viral coefficient | invites_sent * invite_conversion_rate |

### Leading vs. Lagging Indicators

**Leading indicators** (predictive):
- Tutorial completion rate
- API call volume (first 7 days)
- Documentation page depth
- Integration count
- Support ticket sentiment

**Lagging indicators** (outcomes):
- Monthly recurring revenue
- Churn rate
- Net promoter score
- Lifetime value

### Segment Analysis Dimensions

- **Company size**: Solo, startup, SMB, enterprise
- **Role**: Developer, DevOps, architect, manager
- **Use case**: Specific problem being solved
- **Acquisition source**: Organic, paid, referral, content
- **Geography**: Region-specific behavior patterns

---

## Usage Examples

### Analyze Conversion Funnel

```bash
# Full funnel analysis with segment focus
@npl-conversion analyze funnel \
  --stage="trial-to-paid" \
  --timeframe="last-90-days" \
  --segment="developers"

# Identify specific bottleneck
@npl-conversion diagnose dropoff \
  --stage="signup-to-activation" \
  --threshold="50%"
```

### Design Viral Mechanics

```bash
# Create sharing loop for template feature
@npl-conversion create viral-loop \
  --trigger="template-creation" \
  --reward="community-recognition" \
  --measurement-plan

# Design referral program
@npl-conversion design referral-program \
  --incentive-type="extended-features" \
  --attribution-window="30-days"
```

### Optimize Retention

```bash
# Address day-7 drop-off
@npl-conversion design retention \
  --focus="day-7-drop-off" \
  --intervention="onboarding"

# Build engagement loop
@npl-conversion create engagement-loop \
  --trigger="daily-workflow" \
  --reward-type="variable"
```

### Plan A/B Tests

```bash
# Design statistically valid experiment
@npl-conversion plan experiment \
  --hypothesis="simplified-onboarding-increases-activation" \
  --statistical-power="80%" \
  --duration

# Multi-variant test
@npl-conversion plan multivariate-test \
  --variants="headline,cta,social-proof" \
  --traffic-allocation="25-25-25-25"
```

---

## Integration Patterns

### With npl-marketing-copy

Conversion data informs copy optimization:

```bash
# Identify friction points, then optimize copy
@npl-conversion identify friction-points > barriers.md
@npl-marketing-copy optimize landing-page.md --context=barriers.md
```

### With npl-community

Community engagement drives viral mechanics:

```bash
# Design viral loops with community integration
@npl-conversion design viral-loops --community-engagement
@npl-community implement sharing-features --conversion-triggers
```

### With npl-grader

Evaluate optimization strategies:

```bash
# Grade test plan quality
@npl-conversion plan experiment --hypothesis="..." > test-plan.md
@npl-grader evaluate test-plan.md --rubric="experiment-design"
```

### With npl-user-researcher

Behavior analysis informs conversion strategy:

```bash
# User research feeds funnel analysis
@npl-user-researcher analyze behavior-patterns > user-segments.md
@npl-conversion optimize funnel --segments=user-segments.md
```

---

## Templates

### Funnel Analysis Report

```markdown
# Conversion Funnel Analysis: {{funnel_name}}

## Current Performance
| Stage | Rate | Benchmark | Gap |
|:------|:-----|:----------|:----|
| {{stage}} | {{rate}}% | {{benchmark}}% | {{gap}}% |

## Bottleneck Analysis
### {{bottleneck_stage}}
- **Drop-off**: {{dropoff_rate}}%
- **Hypothesis**: {{hypothesis}}
- **Evidence**: {{supporting_data}}
- **Impact**: {{potential_uplift}}% conversion increase

## Recommendations
1. {{recommendation_1}}
2. {{recommendation_2}}

## Test Plan
- **Test**: {{test_name}}
- **Duration**: {{duration}}
- **Success metric**: {{metric}} > {{target}}
```

### Viral Loop Design

```markdown
# Viral Growth Mechanic: {{loop_name}}

## Trigger
- **Event**: {{trigger_event}}
- **User state**: {{user_state}}

## Sharing Mechanism
- **Action**: {{sharing_action}}
- **Friction**: {{friction_level}}

## Recipient Value
- **Immediate benefit**: {{recipient_benefit}}
- **Conversion path**: {{conversion_funnel}}

## Attribution
- **Tracking**: {{tracking_method}}
- **Reward**: {{referrer_reward}}

## Metrics
- **K-factor target**: {{k_factor}}
- **Measurement**: {{measurement_approach}}
```

### Retention Strategy

```markdown
# Retention Strategy: {{cohort_focus}}

## Target Cohort
- **Definition**: {{cohort_definition}}
- **Current retention**: {{current_rate}}%
- **Target retention**: {{target_rate}}%

## Engagement Loop
- **Trigger**: {{trigger}}
- **Action**: {{desired_action}}
- **Reward**: {{reward_type}}
- **Investment**: {{user_investment}}

## Interventions
| Signal | Threshold | Action |
|:-------|:----------|:-------|
| {{signal}} | {{threshold}} | {{intervention}} |

## Success Metrics
- **Primary**: {{primary_metric}}
- **Leading indicators**: {{leading_indicators}}
```

---

## Best Practices

### Data-Driven Optimization

- Measure before optimizing; establish baselines
- Test hypotheses with statistical rigor
- Segment analysis reveals hidden patterns
- Focus on leading indicators for faster iteration

### Developer Audience Alignment

- Technical accuracy maintains credibility
- Authentic value over growth hacks
- Peer validation carries weight
- Long-term relationships over quick conversions

### Testing Discipline

- One variable per test when possible
- Adequate sample sizes (use calculators)
- Run tests for full evaluation cycles
- Document learnings regardless of outcome

### Sustainable Growth

- Retention before acquisition
- Organic growth compounds over time
- Community trust is fragile; protect it
- Expansion revenue from satisfied users

---

## Anti-Patterns

| Anti-Pattern | Problem | Alternative |
|:-------------|:--------|:------------|
| Vanity metrics | Track numbers that don't correlate with success | Action-oriented metrics tied to revenue |
| Dark patterns | Manipulative tactics destroy trust | Value-first growth through user success |
| Short-term optimization | Sacrifices retention for quick conversions | Sustainable growth focus |
| One-size-fits-all | Ignores segment differences | Personalized optimization by segment |
| Premature optimization | Optimizing before product-market fit | Focus on activation and retention first |
| Over-testing | Too many concurrent tests pollute data | Prioritize high-impact tests |

---

## Configuration

### Environment Variables

```bash
# House style customization
HOUSE_STYLE_CONVERSION="/path/to/conversion-style.md"
HOUSE_STYLE_CONVERSION_ADDENDUM="/path/to/overrides.md"
```

### Template Loading

The agent loads context in this order:

1. Core NPL framework (`npl.md`)
2. NPL pumps (intent, critique, rubric, panel-inline-feedback, mood)
3. Conversion type template (if specified)
4. House style (environment, then defaults)

### Style Guide Locations

Default search paths for `conversion-style.md`:

1. `$HOUSE_STYLE_CONVERSION` (environment)
2. `~/.claude/npl-m/house-style/`
3. `.claude/npl-m/house-style/`
4. Path hierarchy from project to target

---

## See Also

- [npl-marketing-copy](./npl-marketing-copy.md) - Technical copywriting
- [npl-community](./npl-community.md) - Community engagement
- [npl-positioning](./npl-positioning.md) - Product positioning
- [Marketing Agents Overview](./README.md) - Category documentation
- Core definition: `core/additional-agents/marketing/npl-conversion.md`
