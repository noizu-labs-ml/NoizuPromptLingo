---
name: trl-research-and-development
description: >
  Design and execute structured R&D workflows: hypothesis formation, experiment design,
  data collection, analysis, and publication of findings. Use this skill when the user
  wants to test a hypothesis, design an experiment, run an A/B test, analyze results,
  validate an assumption with data, structure a research question, or publish findings
  — even if they don't say "R&D." Also trigger when users mention hypothesis testing,
  experimental design, control variables, data collection plan, statistical significance,
  research methodology, ablation study, or evidence-based decision making.
---

# Research and Development

Design and execute structured R&D workflows — from hypothesis formation through publication of findings.

## Overview

The Research and Development skill brings scientific method rigor to technical and product R&D. It provides:

- **Hypothesis formation** — Transform vague questions into testable, falsifiable hypotheses with clear success criteria
- **Experiment design** — Select appropriate methodology, define variables, plan controls, and estimate sample sizes
- **Data collection planning** — Structure collection protocols, instrument selection, and quality checkpoints
- **Analysis frameworks** — Apply appropriate statistical and qualitative methods, detect biases, assess significance
- **Finding synthesis** — Distill results into actionable insights with confidence levels and caveats
- **Publication pipeline** — Format findings for internal reports, blog posts, knowledge base entries, or formal articles

## Core Philosophy

**Five Principles:**

1. **Falsifiability first** — If a hypothesis can't be proven wrong, it's not a hypothesis; it's an opinion. Every experiment must have a clear failure condition
2. **Minimum viable experiment** — Design the smallest experiment that can decisively answer the question. Resist the urge to test everything at once
3. **Bias awareness** — Name your biases before you start. Confirmation bias, survivorship bias, and selection bias are the defaults, not the exceptions
4. **Reproducibility** — An experiment that can't be repeated is an anecdote. Document methodology precisely enough that someone else could replicate it
5. **Findings over outcomes** — Negative results are results. A well-executed experiment that disproves a hypothesis is more valuable than a sloppy one that "confirms" it

## When to Use This Skill

- **Testing a product hypothesis** — "Will users prefer X over Y?" → structured A/B test design
- **Validating a technical assumption** — "Is framework A faster than B for our use case?" → benchmark experiment
- **Evaluating a strategy** — "Does content publishing drive more signups than paid ads?" → comparative study
- **Investigating a problem** — "Why are conversion rates dropping?" → diagnostic experiment
- **Building an evidence base** — "What does the data say about Z?" → systematic data collection and analysis
- **Publishing findings** — "I ran an experiment and want to write it up" → finding synthesis and publication

> For discovering and evaluating source materials, see **trl-kb-research** (`references/output-formats.md`).
> For structuring findings into learning paths, see **trl-kb-curriculum** (`references/pedagogical-frameworks.md`).
> For synthesizing findings at variable complexity, see **trl-kb-digest** (SKILL.md).
> For publishing findings as articles or newsletter content, see **trl-content-publishing** (SKILL.md).
> For validating market hypotheses specifically, see **trl-market-intelligence** (`references/niche-discovery.md`).

## R&D Workflow

### Phase 1: Question Formation

Transform a vague question into a structured research question.

| Input | Output | Key Activity |
|-------|--------|-------------|
| Vague curiosity or problem | Structured research question | Scoping, literature scan, gap identification |

**Steps:**
1. Capture the raw question as stated
2. Identify what's already known (prior art, existing data, team knowledge)
3. Narrow to a specific, answerable question
4. Classify the question type (exploratory, comparative, causal, diagnostic)
5. Assess feasibility (can we actually answer this with available resources?)

### Phase 2: Hypothesis Formation

Convert the research question into testable hypotheses.

| Input | Output | Key Activity |
|-------|--------|-------------|
| Structured research question | Testable hypothesis with success criteria | Operationalization, variable identification |

**Steps:**
1. State the hypothesis in "If X, then Y" format
2. Define the null hypothesis (what does "no effect" look like?)
3. Identify independent variables (what you manipulate)
4. Identify dependent variables (what you measure)
5. Define success criteria with specific thresholds
6. State assumptions and known confounds

### Phase 3: Experiment Design

Design the experiment to test the hypothesis.

| Input | Output | Key Activity |
|-------|--------|-------------|
| Testable hypothesis | Experiment protocol document | Methodology selection, control design, sample planning |

**Methods by question type:**

| Question Type | Recommended Method | When to Use |
|--------------|-------------------|-------------|
| Comparative | A/B test, benchmark | "Is A better than B?" |
| Causal | Controlled experiment | "Does X cause Y?" |
| Exploratory | Survey, observational study | "What's happening with Z?" |
| Diagnostic | Root cause analysis, elimination | "Why is X failing?" |
| Measurement | Instrumentation, sampling | "How much/many/often?" |

> For detailed methodology guides, see [references/methods/](references/methods/).

### Phase 4: Data Collection

Execute the experiment and collect data.

| Input | Output | Key Activity |
|-------|--------|-------------|
| Experiment protocol | Raw dataset + collection log | Instrumentation, monitoring, quality checks |

**Steps:**
1. Set up instrumentation per protocol
2. Run pre-flight checks (instruments calibrated, baselines captured)
3. Execute the experiment
4. Monitor for anomalies during collection
5. Log deviations from protocol
6. Validate data quality before closing collection

### Phase 5: Analysis

Analyze the collected data against the hypothesis.

| Input | Output | Key Activity |
|-------|--------|-------------|
| Raw dataset + collection log | Analysis report with conclusions | Statistical analysis, visualization, interpretation |

**Analysis checklist:**
- [ ] Clean and validate dataset
- [ ] Check for confounding variables
- [ ] Apply appropriate statistical tests
- [ ] Visualize key relationships
- [ ] Assess effect size, not just significance
- [ ] Check for alternative explanations
- [ ] State confidence level in conclusions
- [ ] Identify limitations and caveats

### Phase 6: Publication

Package findings for the intended audience.

| Input | Output | Key Activity |
|-------|--------|-------------|
| Analysis report | Published artifact (report, post, KB entry) | Writing, formatting, peer review |

**Output formats by audience:**

| Audience | Format | Length | Emphasis |
|----------|--------|--------|----------|
| Internal team | Decision memo | 1-2 pages | Recommendation + key evidence |
| Technical blog | Article | 1500-3000 words | Methodology + findings + implications |
| Knowledge base | KB entry | Variable | Structured findings with citations |
| Stakeholders | Executive summary | 1 page | Business impact + confidence level |
| Community | Open research note | Variable | Full methodology, data, and analysis |

## Experiment Log Format

Every experiment gets a structured log that tracks it from hypothesis through findings:

```markdown
# Experiment: [EXP-YYYY-NNN] [Short Title]

## Status: [Proposed | Designing | Running | Analyzing | Complete | Abandoned]

## Research Question
[One sentence]

## Hypothesis
**H1:** [If X, then Y]
**H0:** [Null hypothesis]

## Variables
- **Independent:** [What you manipulate]
- **Dependent:** [What you measure]
- **Controlled:** [What you hold constant]
- **Confounds:** [Known threats to validity]

## Method
[Selected methodology + brief rationale]

## Success Criteria
- [Metric] [operator] [threshold] → [conclusion]

## Data Collection
- **Period:** [start] → [end]
- **Sample size:** [actual] / [planned]
- **Deviations:** [any protocol deviations]

## Results
[Key findings with data]

## Conclusions
- **H1 supported?** [Yes/No/Inconclusive]
- **Confidence:** [High/Medium/Low]
- **Effect size:** [if applicable]
- **Caveats:** [limitations]

## Next Steps
[Follow-up experiments, decisions enabled, knowledge base updates]
```

## Integration with Knowledge Base

The R&D skill connects to the KB ecosystem at multiple points:

```
trl-kb-research → [prior art scan] → R&D Question Formation
                                        ↓
                               Hypothesis → Experiment → Analysis
                                        ↓
                               Findings → trl-kb-digest [synthesis]
                                        ↓
                               trl-kb-curriculum [learning paths]
                                        ↓
                               trl-content-publishing [articles]
```

**Upstream (inputs to R&D):**
- **trl-kb-research** — Literature review and prior art discovery during question formation
- **trl-kb** — Existing knowledge that informs hypothesis design

**Downstream (outputs from R&D):**
- **trl-kb-digest** — Synthesize findings into digestible knowledge at any complexity level
- **trl-kb-curriculum** — Incorporate findings into learning paths when they change understanding
- **trl-content-publishing** — Publish findings as articles, newsletters, or tutorials

## Quick Start Guides

### I Have a Question to Investigate
1. State the question as clearly as you can
2. R&D skill scopes it → forms hypothesis → designs experiment
3. Execute data collection per protocol
4. Analyze results → publish findings
5. Feed into KB if findings are reusable knowledge

### I Already Have Data
1. Describe what you collected and why
2. R&D skill validates the dataset → runs analysis
3. Helps interpret results and assess confidence
4. Packages findings for your target audience

### I Want to Compare Options
1. State what you're comparing and your decision criteria
2. R&D skill designs a comparative experiment (A/B test, benchmark, etc.)
3. Execute → analyze → recommend with evidence

### I Need to Write Up an Experiment
1. Provide your experiment log or raw notes
2. R&D skill structures the write-up for your target audience
3. Ensures methodology, results, and limitations are clearly communicated

## Reference Guide

| Task | Read These |
|------|-----------|
| **Starting any R&D project** | `experiment-design-guide.md`, `hypothesis-formation.md` |
| **Choosing a methodology** | `methods/` directory — one file per method type |
| **Analyzing results** | `analysis-frameworks.md` |
| **Detecting bias** | `bias-catalog.md` |
| **Publishing findings** | `publication-formats.md` |
| **Running the full workflow** | `agent-playbook.claude-code.md` |
| **End-to-end example** | `worked-example-ab-test.md` |

All reference paths are relative to `references/`.

## Related Skills

- **trl-kb-research** — Resource discovery for prior art and literature review phases
- **trl-kb-curriculum** — Structure validated findings into learning paths
- **trl-kb-digest** — Synthesize findings into complexity-calibrated summaries
- **trl-kb** — Parent knowledge base skill; R&D feeds findings back into the KB
- **trl-content-publishing** — Publish findings as articles, newsletters, or tutorials
- **trl-market-intelligence** — Specialized hypothesis testing for market/niche validation
- **trl-dba-db-designer-and-tuning** — When experiments involve database performance measurement

## Bundled Resources

### References

**Foundation:**
- [hypothesis-formation.md](references/hypothesis-formation.md) — From vague question to testable hypothesis: scoping, operationalization, and falsifiability checks
- [experiment-design-guide.md](references/experiment-design-guide.md) — Methodology selection, variable control, sample sizing, and protocol documentation
- [analysis-frameworks.md](references/analysis-frameworks.md) — Statistical and qualitative analysis methods, visualization, and interpretation guidelines
- [bias-catalog.md](references/bias-catalog.md) — Common cognitive and methodological biases with detection strategies and mitigations
- [publication-formats.md](references/publication-formats.md) — Output templates for decision memos, blog posts, KB entries, and executive summaries

**Methods** (`references/methods/`):
- [ab-testing.md](references/methods/ab-testing.md) — A/B and multivariate test design, sample size calculation, and significance testing
- [benchmarking.md](references/methods/benchmarking.md) — Performance comparison methodology for technical systems
- [surveys-and-interviews.md](references/methods/surveys-and-interviews.md) — Qualitative data collection design and analysis
- [observational-studies.md](references/methods/observational-studies.md) — Structured observation protocols for exploratory research
- [root-cause-analysis.md](references/methods/root-cause-analysis.md) — Diagnostic methodology: 5 Whys, fishbone, fault tree

**Agent:**
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent role definition and execution workflows for R&D facilitation

**Worked Examples:**
- [worked-example-ab-test.md](references/worked-example-ab-test.md) — End-to-end: "Does a shorter signup form increase conversions?" from hypothesis through publication
- [worked-example-benchmark.md](references/worked-example-benchmark.md) — End-to-end: "Is SQLite faster than PostgreSQL for our read-heavy workload?" from design through analysis

### Assets

- [experiment-log-template.md](assets/experiment-log-template.md) — Fillable experiment log following the standard format
- [hypothesis-worksheet.md](assets/hypothesis-worksheet.md) — Structured worksheet for forming and refining hypotheses
- [analysis-checklist.md](assets/analysis-checklist.md) — Pre-analysis and post-analysis quality checklists
- [project-tracker.md](assets/project-tracker.md) — R&D project tracker for monitoring active experiments
