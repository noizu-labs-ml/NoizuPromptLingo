# Bias Catalog

Common cognitive and methodological biases that threaten R&D validity, with detection strategies and mitigations.

## Cognitive Biases (Researcher)

| Bias | Description | Detection | Mitigation |
|------|-------------|-----------|-----------|
| **Confirmation bias** | Seeking/favoring evidence that supports your hypothesis | Catching yourself ignoring contradictory data | Pre-register hypothesis; have someone else review |
| **Anchoring** | Over-weighting the first data point or estimate | Your "initial guess" strongly influences your final answer | Use multiple independent estimates |
| **Availability heuristic** | Judging likelihood by how easily examples come to mind | Vivid anecdotes driving conclusions over data | Insist on systematic data, not stories |
| **Sunk cost fallacy** | Continuing because of prior investment | Reluctance to abandon a flawed experiment | Pre-define stopping rules; honor them |
| **Dunning-Kruger** | Overconfidence in unfamiliar domains | Feeling certain about a topic you just learned | Consult domain experts; state your experience level |
| **Hindsight bias** | "I knew it all along" after seeing results | Rewriting your pre-experiment expectations | Document predictions before seeing data |
| **Narrative fallacy** | Creating coherent stories from random data | Compelling explanation with weak evidence | Check: would the opposite story also fit? |

## Methodological Biases (Design)

| Bias | Description | Detection | Mitigation |
|------|-------------|-----------|-----------|
| **Selection bias** | Non-random group assignment | Groups differ on key characteristics | Random assignment; check balance |
| **Survivorship bias** | Analyzing only what survived/succeeded | Missing data from failures/dropouts | Track and report attrition |
| **Observer bias** | Experimenter expectations influence measurement | Subjective measurements correlate with expectations | Blind measurement; objective metrics |
| **Sampling bias** | Sample doesn't represent population | Convenience sampling, self-selection | Define population explicitly; check representativeness |
| **Publication bias** | Only positive results get reported | Drawer full of null results | Report null results; pre-register studies |
| **Measurement bias** | Tool systematically skews results | Consistent over/under-measurement | Calibrate instruments; use multiple measures |
| **Temporal bias** | Timing of measurement affects results | Novelty effects, seasonality | Sufficient duration; control for time |

## Statistical Biases (Analysis)

| Bias | Description | Detection | Mitigation |
|------|-------------|-----------|-----------|
| **p-hacking** | Testing multiple hypotheses until one is significant | Many tests, only significant ones reported | Pre-register analysis plan |
| **HARKing** | Hypothesizing After Results are Known | "Hypothesis" perfectly matches results | Write hypothesis before seeing data |
| **Simpson's paradox** | Trend reverses when data is aggregated/disaggregated | Aggregate and subgroup analyses conflict | Always check subgroups |
| **Base rate neglect** | Ignoring prior probability | Rare events seem more common than they are | Always consider base rates |
| **Regression to mean** | Extreme values naturally move toward average | Selecting groups based on extreme performance | Don't select on the dependent variable |
| **Ecological fallacy** | Applying group-level findings to individuals | Group average doesn't predict individual behavior | Match analysis level to conclusion level |

## Bias Pre-Mortem

Before starting an experiment, run a bias pre-mortem:

1. **List your expectations** — What do you *want* to find? (This is your confirmation bias vector)
2. **Name your expertise gaps** — What don't you know about this domain? (Dunning-Kruger check)
3. **Check your sample** — Who's missing? Who self-selected? (Selection/sampling bias)
4. **Examine your metrics** — Could they systematically over/under-count? (Measurement bias)
5. **Plan for null results** — What will you do if H0 is not rejected? (Publication bias prevention)
6. **Identify the story you'll tell** — Is there an equally plausible opposite story? (Narrative fallacy)

## Quick Reference: The Top 5

If you only check for five biases, check these:

1. **Confirmation bias** — Are you looking for evidence that proves you right?
2. **Selection bias** — Is your sample representative?
3. **Survivorship bias** — What data are you missing?
4. **p-hacking** — Did you pre-register your analysis?
5. **Confounding** — Is there a third variable explaining both your IV and DV?
