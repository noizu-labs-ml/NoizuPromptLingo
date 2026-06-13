# Worked Example: Signup Form A/B Test

End-to-end walkthrough of "Does a shorter signup form increase conversions?"

## Phase 1: Question Formation

**Raw question:** "Our signup conversion sucks. Should we simplify the form?"

**Scoping:**
- Current form: 6 fields (name, email, password, company, role, team size)
- Conversion rate: 12% of visitors who see the form complete it
- Traffic: ~2,000 form views/week
- Context: B2B SaaS, free trial signup

**Structured question:** "Does reducing the signup form from 6 fields to 3 fields (name, email, password) increase form completion rate for organic traffic visitors?"

**Prior art:** Industry data suggests each additional form field reduces completion by 5-10%. But our fields collect qualifying data — removing them might increase signups but decrease lead quality.

## Phase 2: Hypothesis Formation

**H1:** Reducing the signup form from 6 fields to 3 fields will increase form completion rate by at least 20% (from 12% to 14.4%+) within 4 weeks.

**H0:** There is no meaningful difference in form completion rate between the 6-field and 3-field forms (difference < 20% relative).

**Variables:**
- **IV:** Number of form fields (6 vs 3)
- **DV:** Form completion rate (submissions / form views)
- **Controlled:** Page design, CTA text, traffic source mix, pricing page
- **Confounds:** Seasonal traffic variation, marketing campaigns, lead quality impact

**Success criteria:**
- Primary: Completion rate lift ≥ 20% relative, p < 0.05
- Secondary: No decrease in trial-to-paid conversion within 30 days of signup
- Guardrail: Lead qualification rate doesn't drop below 60%

## Phase 3: Experiment Design

**Method:** A/B test (two-group, randomized)

**Sample size calculation:**
- Baseline: 12% completion rate
- MDE: 20% relative lift (12% → 14.4%)
- Power: 80%, α = 0.05
- Required: ~3,800 per group → ~7,600 total
- At 2,000 views/week: ~4 weeks

**Protocol:**
- 50/50 random split by visitor cookie
- Run for 4 full weeks (no peeking)
- Control: current 6-field form
- Treatment: 3-field form (name, email, password)
- Additional fields collected post-signup in onboarding

**Stopping rules:**
- Success: p < 0.05 at end of 4 weeks with lift ≥ 20%
- Fail: p > 0.05 at end of 4 weeks
- Abort: Either variant drops below 5% completion (system issue)

## Phase 4: Data Collection

**Instrumentation:** Analytics event on form view + form submit, with variant tag.

**Collection log:**
- Week 1: Control n=1,012, Treatment n=998. No anomalies.
- Week 2: Control n=1,045, Treatment n=1,038. Marketing launched email campaign — traffic spike but evenly distributed.
- Week 3: Control n=987, Treatment n=1,001. Normal.
- Week 4: Control n=1,056, Treatment n=1,042. Normal.

**Final:** Control n=4,100, Treatment n=4,079. No deviations from protocol.

## Phase 5: Analysis

**Descriptive statistics:**

| Metric | Control (6-field) | Treatment (3-field) |
|--------|-------------------|---------------------|
| Form views | 4,100 | 4,079 |
| Completions | 498 | 702 |
| Completion rate | 12.1% | 17.2% |
| Relative lift | — | +42.1% |

**Hypothesis test:**
- Chi-squared test: χ² = 43.2, p < 0.001
- 95% CI for lift: [30.8%, 54.2%]
- Cohen's h = 0.15 (small-medium effect)

**H1 supported.** The 3-field form significantly outperforms the 6-field form (42% lift, well above the 20% threshold).

**Secondary metrics (30-day follow-up):**

| Metric | Control | Treatment | Change |
|--------|---------|-----------|--------|
| Trial-to-paid conversion | 8.2% | 7.1% | -13.4% |
| Lead qualification rate | 72% | 61% | -15.3% |
| Revenue per form view | $0.80 | $0.98 | +22.5% |

**Interpretation:** More signups, slightly lower quality, but net positive on revenue per form view. The guardrail metric (qualification rate) is at 61% — just above the 60% threshold.

**Bias check:**
- ✅ No peeking (pre-committed to 4 weeks)
- ✅ Random assignment (cookie-based)
- ⚠️ Email campaign in week 2 (but evenly distributed)
- ✅ No protocol changes during the test

## Phase 6: Publication

**Format:** Decision memo (for product team)

---

### Decision: Adopt 3-Field Signup Form

**Date:** 2025-04-15 | **Confidence:** High | **Experiment:** EXP-2025-003

#### Recommendation

Ship the 3-field signup form. Collect company/role/team-size during onboarding instead.

#### Key Evidence

| Finding | Data | Implication |
|---------|------|------------|
| 42% more signups | 17.2% vs 12.1%, p < 0.001 | Significantly more users enter the funnel |
| 13% lower trial-to-paid | 7.1% vs 8.2% | Some quality dilution from easier signups |
| 22% higher revenue/view | $0.98 vs $0.80 | Net positive — more signups outweigh quality drop |

#### Caveats

- Lead qualification rate is at 61%, barely above our 60% guardrail. Monitor closely.
- If sales team is capacity-constrained, more low-quality leads may be counterproductive.
- 30-day follow-up may not capture full lifecycle — consider 90-day check.

#### Next Steps

- [ ] Ship 3-field form to 100% of traffic
- [ ] Build onboarding flow to collect qualifying data post-signup
- [ ] Set up 90-day revenue monitor to validate long-term impact
- [ ] Alert sales team to expected change in lead profile

---

## KB Integration

**Finding preserved as:**
- KB entry: "Reducing B2B signup form fields increases conversion but dilutes lead quality"
- Tags: conversion-optimization, form-design, B2B-SaaS
- Confidence: High
- Applicability: B2B free trial signups with qualifying fields
