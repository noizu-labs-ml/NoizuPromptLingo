# Hypothesis Formation

From vague question to testable, falsifiable hypothesis.

## The Hypothesis Quality Ladder

Most R&D projects start with a vague hunch and need to climb through several levels of refinement:

| Level | Example | Problem |
|-------|---------|---------|
| 0: Vague hunch | "I think our signup flow is bad" | Not actionable |
| 1: Question | "Why is our signup conversion low?" | Not testable |
| 2: Directional | "Shorter forms get more signups" | No specifics |
| 3: Testable | "Reducing the signup form from 6 fields to 3 will increase completion rate by >15%" | Testable and falsifiable |

**Goal: Always reach Level 3 before designing an experiment.**

## The PICOS Framework

Adapted from clinical research, PICOS gives structure to any hypothesis:

| Element | Question | Example |
|---------|----------|---------|
| **P**opulation | Who/what are you studying? | New visitors from organic search |
| **I**ntervention | What change are you testing? | 3-field signup form |
| **C**omparison | What's the control? | Current 6-field form |
| **O**utcome | What do you measure? | Form completion rate |
| **S**tudy design | How will you test? | A/B test, 50/50 split |

## Operationalization

The gap between a concept and a measurement. Every variable in your hypothesis needs to be operationalized.

**Bad:** "User satisfaction will improve"
- How do you measure "satisfaction"? Survey? NPS? Retention? Session duration?

**Good:** "30-day retention rate will increase by >5 percentage points"
- Specific metric, specific threshold, specific timeframe

### Operationalization Checklist

For each variable, answer:
1. **What specific metric represents this concept?**
2. **How is that metric collected?** (instrumentation, survey, observation)
3. **What unit is it measured in?**
4. **Over what time period?**
5. **What precision is meaningful?** (0.1% vs 1% vs 10%)

## Falsifiability Check

A hypothesis is falsifiable if you can describe what result would disprove it.

| Hypothesis | Falsifiable? | Why/Why Not |
|-----------|-------------|-------------|
| "Our product is good" | No | No measurable criteria |
| "Users prefer dark mode" | Barely | No threshold, no population |
| "60%+ of power users (>5 sessions/week) will choose dark mode when offered" | Yes | Clear metric, population, threshold |

**The null hypothesis test:** Can you write H0 (null hypothesis) that is the logical negation? If not, the hypothesis isn't specific enough.

## Common Hypothesis Patterns

### Comparative
> "Users who see [variant A] will [metric] [more/less] than users who see [variant B] by at least [threshold]"

### Causal
> "Implementing [change] will cause [metric] to [direction] by [amount] within [timeframe]"

### Threshold
> "[Metric] for [population] is currently [above/below] [value]"

### Correlation
> "[Metric A] and [Metric B] are [positively/negatively] correlated with r > [threshold] in [population]"

## Red Flags in Hypotheses

| Red Flag | Problem | Fix |
|----------|---------|-----|
| "will improve" | No threshold | Add specific target |
| "users" (unqualified) | Which users? | Define the population |
| "better" / "worse" | Subjective | Operationalize with metrics |
| Multiple IVs | Can't isolate cause | Test one thing at a time |
| No timeframe | When do you check? | Add measurement window |
| No null hypothesis | Can't falsify | Write H0 explicitly |

## Hypothesis Refinement Protocol

1. **Write it down** — even if it's bad. Level 0 is fine to start.
2. **PICOS check** — fill in all five elements
3. **Operationalize** — replace every abstract concept with a measurable metric
4. **Falsifiability check** — write H0
5. **Feasibility check** — can you actually measure this with available resources?
6. **Scope check** — is this the smallest hypothesis that answers the question?
7. **Assumption audit** — what are you assuming that could be wrong?
