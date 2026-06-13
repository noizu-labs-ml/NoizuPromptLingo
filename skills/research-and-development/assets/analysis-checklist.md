# Analysis Checklist

Quality gates for before, during, and after data analysis.

---

## Pre-Analysis Checklist

Complete before touching the data:

- [ ] **Analysis plan is pre-registered** — You know which test you'll run before seeing results
- [ ] **Success criteria are defined** — You know what "enough" looks like
- [ ] **Data collection is complete** — No more data coming in
- [ ] **Hypothesis is documented** — H1 and H0 written before analysis

---

## Data Validation Checklist

- [ ] **Expected record count?** — Matches planned sample size (±5%)
- [ ] **Missing values cataloged?** — How many, which fields, any pattern?
- [ ] **Duplicates checked?** — Unique records where expected
- [ ] **Impossible values?** — Negative durations, future dates, out-of-range scores
- [ ] **Distribution reasonable?** — No unexpected spikes or gaps
- [ ] **Groups balanced?** — Treatment and control roughly equal size
- [ ] **Timeframe correct?** — Data covers the planned collection period
- [ ] **Known anomalies documented?** — External events, outages, protocol deviations

---

## During Analysis Checklist

- [ ] **Descriptive statistics first** — Mean, median, spread, distribution before hypothesis testing
- [ ] **Visualized the data** — Looked at charts, not just numbers
- [ ] **Using pre-registered test** — Not searching for a test that gives a good p-value
- [ ] **Effect size calculated** — Not just p-value
- [ ] **Confidence interval reported** — Not just point estimate
- [ ] **Multiple comparison correction** — If testing multiple hypotheses (Bonferroni, FDR)
- [ ] **Checked for confounds** — Any third variable explaining the relationship?
- [ ] **Checked subgroups** — Does the effect hold across segments? (Simpson's paradox)

---

## Post-Analysis Checklist

- [ ] **Conclusions match the data** — Not overclaiming or underclaiming
- [ ] **Confidence level stated** — High/Medium/Low with justification
- [ ] **Limitations listed** — Honest, not buried
- [ ] **Alternative explanations considered** — At least one rival hypothesis addressed
- [ ] **Causal language appropriate** — "Correlated with" for observational, "caused" only for true experiments
- [ ] **Practical significance assessed** — Is the effect size meaningful, not just statistically significant?
- [ ] **Reproducibility** — Could someone replicate this analysis from your documentation?
- [ ] **Next steps identified** — Follow-up experiments, decisions enabled, KB updates

---

## Bias Self-Check

Before finalizing, honestly assess:

- [ ] **Did I look for confirming evidence more than disconfirming?** (Confirmation bias)
- [ ] **Did I change my analysis plan after seeing the data?** (p-hacking risk)
- [ ] **Am I ignoring an inconvenient finding?** (Cherry-picking)
- [ ] **Does my conclusion feel "too clean"?** (Narrative fallacy)
- [ ] **Would I publish this if the result were negative?** (Publication bias)
