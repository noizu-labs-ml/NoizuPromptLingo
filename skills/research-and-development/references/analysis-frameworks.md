# Analysis Frameworks

Methods for analyzing experiment data and interpreting results.

## Analysis Selection Guide

| Data Type | Question | Method |
|-----------|----------|--------|
| Two proportions | "Is conversion rate A > B?" | Chi-squared test, Fisher's exact |
| Two means | "Is response time A < B?" | t-test (paired or independent) |
| Multiple groups | "Which variant is best?" | ANOVA + post-hoc |
| Correlation | "Do X and Y move together?" | Pearson/Spearman correlation |
| Time series | "Did something change at time T?" | Interrupted time series, changepoint detection |
| Categorical | "Is there an association between X and Y?" | Chi-squared test of independence |
| Qualitative | "What themes emerge from interviews?" | Thematic analysis, affinity mapping |

## The Analysis Protocol

### Step 1: Data Validation

Before any analysis, verify the dataset:

- [ ] **Completeness** — Expected number of records? Missing values?
- [ ] **Integrity** — Duplicates? Impossible values? Truncated data?
- [ ] **Balance** — Groups roughly equal size? Expected distribution?
- [ ] **Contamination** — Any evidence of cross-group bleed?
- [ ] **Timeframe** — Data covers the planned collection period?

### Step 2: Descriptive Statistics

Before testing hypotheses, understand the data:

- Central tendency (mean, median, mode)
- Spread (standard deviation, IQR, range)
- Distribution shape (normal? skewed? bimodal?)
- Outliers (how many? are they real?)

### Step 3: Hypothesis Testing

Apply the pre-registered analysis plan:

1. State H0 and H1
2. Choose significance level (typically α = 0.05)
3. Calculate the test statistic
4. Determine p-value
5. **Report effect size** (not just p-value)
6. State conclusion in plain language

### Step 4: Effect Size Interpretation

| Effect Size | Metric | Small | Medium | Large |
|------------|--------|-------|--------|-------|
| Cohen's d | Mean difference | 0.2 | 0.5 | 0.8 |
| Relative lift | Percentage change | <5% | 5-20% | >20% |
| Correlation r | Linear relationship | 0.1 | 0.3 | 0.5 |
| Odds ratio | Binary outcome | 1.5 | 2.5 | 4.0 |

**A statistically significant but tiny effect may not be practically significant.**

### Step 5: Confidence Assessment

Rate overall confidence in the conclusions:

| Confidence | Criteria |
|-----------|---------|
| **High** | Large effect, adequate sample, no confounds, replicates prior work |
| **Medium** | Moderate effect or small sample, minor confounds identified |
| **Low** | Small effect, small sample, significant confounds, or novel finding |
| **Inconclusive** | Insufficient data, major confounds, or contradictory results |

## Visualization Guidelines

| Data Type | Visualization | When to Use |
|-----------|--------------|-------------|
| Two-group comparison | Bar chart with error bars | A/B test results |
| Distribution | Histogram or box plot | Understanding spread |
| Time series | Line chart | Before/after or trends |
| Correlation | Scatter plot | Relationship between variables |
| Proportions | Stacked bar or pie | Categorical composition |
| Multiple metrics | Small multiples | Comparing many dimensions |

### Visualization Anti-Patterns

- Truncated Y-axis (exaggerates differences)
- Pie charts for >5 categories (use bar chart)
- 3D charts (always worse than 2D)
- Dual Y-axes (misleading scale relationships)
- Showing only means without spread (hides variability)

## Common Analysis Mistakes

| Mistake | Why It's Wrong | What to Do |
|---------|---------------|-----------|
| p-hacking | Testing until you get p < 0.05 | Pre-register your analysis plan |
| Multiple comparisons | Testing many hypotheses inflates false positives | Bonferroni or FDR correction |
| Confusing correlation/causation | Observational data can't prove causation | Use causal language only for experiments |
| Ignoring effect size | p = 0.001 doesn't mean the effect matters | Always report and interpret effect size |
| Cherry-picking results | Only reporting what confirms hypothesis | Report all pre-registered analyses |
| Survivorship bias | Only analyzing successes | Include failures in the analysis |

## Qualitative Analysis

For non-numerical data (interviews, open-ended surveys, observations):

### Thematic Analysis Steps

1. **Familiarization** — Read all data, note initial impressions
2. **Initial coding** — Tag interesting segments with short labels
3. **Theme search** — Group codes into candidate themes
4. **Theme review** — Check themes against the data (do they hold up?)
5. **Theme definition** — Name and describe each theme precisely
6. **Write-up** — Narrative with representative quotes

### Quality Criteria for Qualitative Analysis

- **Credibility** — Would participants recognize the findings?
- **Transferability** — Is context described well enough to judge applicability?
- **Dependability** — Would another analyst reach similar conclusions?
- **Confirmability** — Can the trail from data to conclusions be followed?
