# Publication Formats

Templates and guidelines for formatting R&D findings for different audiences.

## Format Selection

| Audience | Format | Length | Tone | Emphasis |
|----------|--------|--------|------|----------|
| Decision-maker | Decision memo | 1-2 pages | Direct, confident | Recommendation + key evidence |
| Technical team | Technical report | 3-10 pages | Precise, detailed | Methodology + reproducibility |
| Blog readers | Article | 1500-3000 words | Accessible, narrative | Story + insights + takeaways |
| Knowledge base | KB entry | Variable | Structured, reference | Reusable findings + citations |
| Stakeholders | Executive summary | 1 page | Polished, high-level | Impact + confidence |
| Research community | Open research note | Variable | Rigorous, transparent | Full data + methodology |

## Decision Memo Template

For when the experiment was designed to inform a specific decision.

```markdown
# Decision: [Title]

**Date:** [date]
**Experiment:** [EXP-ID]
**Confidence:** [High / Medium / Low]
**Decision owner:** [who decides]

## Recommendation

[1-2 sentences. What to do and why. Lead with the action.]

## Key Evidence

| Finding | Data | Implication |
|---------|------|------------|
| [finding 1] | [metric + value] | [so what] |
| [finding 2] | [metric + value] | [so what] |
| [finding 3] | [metric + value] | [so what] |

## Caveats

- [Limitation that could change the recommendation]
- [Assumption that, if wrong, would change the answer]

## Alternative Considered

[What the other option was. Why the data doesn't support it.
Be fair — steelman the alternative.]

## Next Steps

- [ ] [Action item with owner]
- [ ] [Follow-up measurement with date]
```

## Technical Report Template

For when methodology and reproducibility matter.

```markdown
# [Title]: Technical Report

**Experiment:** [EXP-ID]
**Author:** [name]
**Date:** [date]
**Status:** [Draft / Review / Final]

## Abstract

[3-5 sentences: question, method, key finding, implication]

## Background

[Why this question matters. What was already known. What gap this fills.]

## Methodology

### Design
[Experiment type, duration, population]

### Variables
[IV, DV, controls, confounds]

### Data Collection
[Instruments, sample size, collection period]

### Analysis Plan
[Pre-registered statistical tests]

## Results

### Descriptive Statistics
[Summary stats, distributions, visualizations]

### Hypothesis Tests
[Test results with effect sizes and confidence intervals]

### Exploratory Findings
[Unexpected patterns — clearly labeled as exploratory]

## Discussion

### Interpretation
[What the results mean in context]

### Limitations
[Validity threats, sample issues, measurement concerns]

### Comparison to Prior Work
[How this relates to what was already known]

## Conclusions

[1-3 sentences: definitive statement of findings with confidence level]

## Appendix

[Raw data tables, additional visualizations, protocol document]
```

## Blog Article Template

For when you want to share findings with a broader audience.

```markdown
# [Engaging Title — Focus on the Insight]

[Hook: 1-2 sentences that make the reader care]

## The Question

[What we wanted to know and why it matters.
Frame it as a problem the reader might have.]

## What We Did

[Methodology in plain language. Enough detail to be credible,
not so much that non-technical readers bounce.]

## What We Found

[Key results with simple visualizations.
Lead with the most surprising or impactful finding.]

### [Sub-finding 1]
[Detail + evidence]

### [Sub-finding 2]
[Detail + evidence]

## What This Means

[Practical implications. What should the reader do differently?]

## Caveats

[Honest limitations — builds credibility.
"Here's what we can't conclude from this..."]

## TL;DR

- [Bullet 1: most important finding]
- [Bullet 2: practical implication]
- [Bullet 3: what to watch for / next steps]
```

## KB Entry Template

For preserving findings as reusable knowledge.

```markdown
# Finding: [Title]

**Source:** [EXP-ID] | **Date:** [date] | **Confidence:** [H/M/L]
**Tags:** [relevant topics]

## Summary

[2-3 sentences: what was found and why it matters]

## Evidence

| Metric | Value | Context |
|--------|-------|---------|
| [metric] | [value] | [what "normal" looks like] |

## Applicability

- **Applies when:** [conditions under which this finding holds]
- **Does NOT apply when:** [conditions that would invalidate it]
- **Superseded by:** [link to newer experiment if applicable]

## Methodology Note

[One paragraph: how this was determined, enough to assess credibility]

## Related

- [Link to full experiment report]
- [Link to related KB entries]
- [Link to follow-up experiments]
```

## Writing Quality Checklist

Before publishing any format:

- [ ] **Claims match data** — Every assertion is supported by specific evidence
- [ ] **Confidence is stated** — Reader knows how certain you are
- [ ] **Limitations are honest** — Not buried or minimized
- [ ] **Alternative explanations acknowledged** — You've considered why you might be wrong
- [ ] **Language precision** — "Correlated with" not "caused by" (unless it's a true experiment)
- [ ] **Reproducible** — Reader could replicate with the information provided
- [ ] **Audience-appropriate** — Technical depth matches the audience
- [ ] **Actionable** — Reader knows what to do with this information
