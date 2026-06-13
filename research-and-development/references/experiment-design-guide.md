# Experiment Design Guide

From testable hypothesis to executable experiment protocol.

## Methodology Selection Matrix

| Question Type | Primary Method | Secondary | When to Escalate |
|--------------|---------------|-----------|-----------------|
| "Is A better than B?" | A/B test | Multivariate test | >3 variants |
| "Does X cause Y?" | Controlled experiment | Natural experiment | Can't control IV |
| "What's happening?" | Observational study | Survey | Need subjective data |
| "Why is X broken?" | Root cause analysis | Elimination test | Multiple suspects |
| "How much/often?" | Instrumentation | Sampling | Can't measure all |
| "What do users think?" | Survey/interview | Usability test | Need behavioral data |

> For detailed methodology guides, see the `methods/` directory.

## Experiment Protocol Template

Every experiment needs a written protocol before data collection begins. This prevents HARKing (Hypothesizing After Results are Known) and ensures reproducibility.

```markdown
## Protocol: [EXP-YYYY-NNN]

### Pre-Registration
- **Hypothesis:** [H1 statement]
- **Null hypothesis:** [H0 statement]
- **Primary metric:** [what you measure]
- **Success threshold:** [specific value]
- **Analysis plan:** [statistical test you'll use]

### Design
- **Method:** [A/B test, benchmark, survey, etc.]
- **Population:** [who/what is being studied]
- **Sample size:** [target n, with power calculation rationale]
- **Duration:** [planned collection period]
- **Assignment:** [random, stratified, convenience, etc.]

### Variables
- **Independent (manipulated):** [list]
- **Dependent (measured):** [list]
- **Controlled (held constant):** [list]
- **Confounds (known threats):** [list]

### Instrumentation
- **Data source:** [analytics, logs, surveys, etc.]
- **Collection method:** [automated, manual, hybrid]
- **Quality checks:** [validation steps during collection]

### Stopping Rules
- **Success:** [when to declare H1 supported]
- **Failure:** [when to declare H0 not rejected]
- **Abort:** [conditions that invalidate the experiment]
```

## Sample Size Considerations

Not every experiment needs formal power analysis, but every experiment needs to consider whether the sample is sufficient.

### Rules of Thumb

| Context | Minimum | Comfortable | Confident |
|---------|---------|-------------|-----------|
| A/B test (web) | 100/variant | 1000/variant | 10000/variant |
| User survey | 30 responses | 100 responses | 300+ responses |
| Performance benchmark | 10 runs | 30 runs | 100 runs |
| Usability test | 5 users | 8 users | 12 users |

### When to Do Formal Power Analysis

- When the business decision is expensive or hard to reverse
- When the expected effect size is small
- When you have limited traffic/users and need to know how long to run
- When stakeholders need statistical rigor

## Control Design

### Types of Controls

| Control Type | What It Does | When to Use |
|-------------|-------------|-------------|
| **No-treatment** | Unchanged original | Default for A/B tests |
| **Placebo** | Change that shouldn't have an effect | When novelty itself might cause change |
| **Active** | Best known alternative | When comparing against a competitor |
| **Historical** | Past performance data | When you can't run concurrent control (risky) |

### Common Control Mistakes

1. **No control at all** — "We changed X and things got better!" (Did they? Compared to what?)
2. **Historical control only** — Assumes nothing else changed (seasonality, marketing, etc.)
3. **Contaminated control** — Control group sees the treatment (bleed-through)
4. **Selection bias** — Control and treatment groups differ systematically

## Validity Threats

| Threat | Description | Mitigation |
|--------|-------------|-----------|
| **Selection bias** | Groups differ before treatment | Random assignment |
| **History** | External event affects results | Short duration, control group |
| **Maturation** | Natural change over time | Control group |
| **Testing effect** | Being measured changes behavior | Unobtrusive measures |
| **Instrumentation** | Measurement tool changes | Calibration, consistency |
| **Regression to mean** | Extreme values normalize | Don't select on the DV |
| **Attrition** | Participants drop out differently | Track and report attrition |
| **Hawthorne effect** | Attention causes change | Placebo control |

## Timeline Planning

| Phase | Typical Duration | Key Activities |
|-------|-----------------|----------------|
| Design | 1-3 days | Protocol, instrumentation setup |
| Pilot | 1-2 days | Small-scale test of instrumentation |
| Collection | Varies (1 day - 4 weeks) | Data gathering + monitoring |
| Analysis | 1-3 days | Statistical analysis + interpretation |
| Write-up | 1-2 days | Report/publication |

**Rule:** If you can't budget at least 1 day for analysis, you shouldn't run the experiment. You'll just have data you never look at.

## Pre-Flight Checklist

Before starting data collection:

- [ ] Protocol is written and won't change
- [ ] Instrumentation is tested (collect dummy data, verify it records correctly)
- [ ] Baselines are captured (what does "normal" look like right now?)
- [ ] Stopping rules are defined (when do you stop? what would abort the experiment?)
- [ ] Stakeholders are aligned (who needs to know, what will they do with results?)
- [ ] Calendar is blocked (analysis time scheduled before collection starts)
- [ ] Deviation log is ready (how to record things that go wrong)
