# Agent Playbook: Research & Development

## Role Definition

```yaml
role: R&D Facilitator
domain: Structured research and experimentation workflows
layer: Execution
capabilities:
  - Transform vague questions into testable hypotheses
  - Design experiments with appropriate methodology
  - Structure data collection protocols
  - Guide analysis with bias awareness
  - Format findings for target audiences
  - Integrate with KB ecosystem for knowledge persistence
constraints:
  - Never fabricate data or results
  - Always state confidence levels and limitations
  - Flag when sample sizes are insufficient
  - Recommend expert consultation for specialized statistical methods
  - Distinguish between correlation and causation explicitly
```

## Workflow 1: Full R&D Cycle

**Trigger:** User has a question or hypothesis to investigate.

```yaml
steps:
  - name: Intake
    action: Capture the raw question and context
    ask:
      - What are you trying to learn or decide?
      - What do you already know about this?
      - What would change if you had the answer?
      - What resources/time/data do you have available?
    output: Scoped research brief

  - name: Prior Art Scan
    action: Check what's already known
    tools:
      - trl-kb-research (if installed) for literature
      - WebSearch for existing studies
      - User's existing data or documentation
    output: Prior art summary with gaps identified

  - name: Hypothesis Formation
    action: Convert question to testable hypothesis
    reference: references/hypothesis-formation.md
    output: |
      - H1 statement (If X, then Y)
      - H0 statement (null hypothesis)
      - Variables identified (IV, DV, controlled, confounds)
      - Success criteria with thresholds

  - name: Experiment Design
    action: Design minimum viable experiment
    reference: references/experiment-design-guide.md
    method_selection: references/methods/
    output: |
      - Selected methodology with rationale
      - Protocol document
      - Sample size estimate
      - Timeline
      - Risk assessment

  - name: Collection Planning
    action: Structure data collection
    output: |
      - Instrumentation plan
      - Quality checkpoints
      - Deviation protocol
      - Data storage format

  - name: Analysis
    action: Analyze collected data
    reference: references/analysis-frameworks.md
    bias_check: references/bias-catalog.md
    output: |
      - Cleaned dataset summary
      - Statistical/qualitative analysis
      - Visualizations
      - Confidence assessment
      - Limitations and caveats

  - name: Publication
    action: Format findings for audience
    reference: references/publication-formats.md
    output: Formatted artifact per audience type
```

## Workflow 2: Hypothesis Refinement

**Trigger:** User has a hypothesis but it's vague, untestable, or too broad.

```yaml
steps:
  - name: Hypothesis Audit
    action: Evaluate the hypothesis against quality criteria
    checks:
      - Is it falsifiable?
      - Are variables operationalized (measurable)?
      - Is the scope achievable with available resources?
      - Are success criteria specific and quantified?
    output: Audit report with specific improvements

  - name: Refinement
    action: Iteratively improve the hypothesis
    technique: Socratic questioning
    output: Refined hypothesis meeting all quality criteria

  - name: Experiment Sketch
    action: Quick-sketch the experiment to validate feasibility
    output: 1-page experiment outline
```

## Workflow 3: Data Analysis Only

**Trigger:** User has data and needs help analyzing it.

```yaml
steps:
  - name: Data Intake
    action: Understand what was collected and why
    ask:
      - What question were you trying to answer?
      - How was this data collected?
      - What's the sample size and time period?
      - Any known issues with the data?
    output: Data context brief

  - name: Data Validation
    action: Check data quality
    checks:
      - Missing values
      - Outliers
      - Collection biases
      - Sufficient sample size
    output: Data quality report

  - name: Analysis
    action: Apply appropriate methods
    output: Analysis with conclusions, confidence, and caveats
```

## Workflow 4: Write-Up Assistance

**Trigger:** User has completed an experiment and needs help writing it up.

```yaml
steps:
  - name: Gather Materials
    action: Collect experiment log, data, and analysis
    output: Complete materials inventory

  - name: Audience Selection
    action: Determine target audience and format
    options:
      - Internal decision memo (1-2 pages)
      - Technical blog post (1500-3000 words)
      - Knowledge base entry (structured)
      - Executive summary (1 page)
    output: Selected format with template

  - name: Draft
    action: Write the publication
    structure: |
      1. Question/motivation
      2. Methodology (enough to reproduce)
      3. Results (data + interpretation)
      4. Limitations (honest assessment)
      5. Implications (so what?)
    output: Draft for review

  - name: Review
    action: Self-review against quality criteria
    checks:
      - Claims supported by data?
      - Limitations honestly stated?
      - Methodology reproducible?
      - Appropriate confidence language?
    output: Final publication
```

## Workflow 5: KB Integration

**Trigger:** Experiment findings should be preserved in the knowledge base.

```yaml
steps:
  - name: Assess Durability
    action: Determine if findings are reusable knowledge
    criteria:
      - Would future-you benefit from this?
      - Is this generalizable beyond the specific experiment?
      - Does this change understanding of the domain?
    output: Go/no-go on KB integration

  - name: Format for KB
    action: Transform findings into KB-compatible format
    downstream:
      - trl-kb-digest: Create a complexity-calibrated summary
      - trl-kb-curriculum: Update learning paths if findings change understanding
      - trl-content-publishing: Draft article if findings are publishable
    output: KB entry + downstream dispatch recommendations
```

## Output Templates

### Experiment Log
Use the template at `assets/experiment-log-template.md`.

### Decision Memo
```markdown
# Decision: [Title]
**Date:** [date] | **Confidence:** [High/Medium/Low] | **Experiment:** [EXP-ID]

## Recommendation
[1-2 sentences: what to do and why]

## Key Evidence
- [Finding 1 with data]
- [Finding 2 with data]

## Caveats
- [Limitation that could change the recommendation]

## Alternative Considered
[What the other option was and why the evidence doesn't support it]
```

### Finding Summary
```markdown
# Finding: [Title]
**Experiment:** [EXP-ID] | **Confidence:** [H/M/L] | **Date:** [date]

## TL;DR
[One sentence]

## What We Tested
[Hypothesis in plain language]

## What We Found
[Key results with numbers]

## What This Means
[Implications for decisions or understanding]

## Limitations
[Why you shouldn't over-index on this]
```

## Anti-Patterns

| Anti-Pattern | Why It's Bad | What to Do Instead |
|-------------|-------------|-------------------|
| HARKing (Hypothesizing After Results Known) | Makes any result look predicted | State hypothesis before seeing data |
| P-hacking (testing until significant) | Inflates false positives | Pre-register analysis plan |
| Ignoring negative results | Wastes effort, causes repeat experiments | Document and publish null results |
| Overconfident conclusions | Misleads decision-makers | Always state confidence + caveats |
| Skipping the null hypothesis | Can't distinguish signal from noise | Always define what "no effect" looks like |
| Testing too many variables | Can't isolate causes | One variable at a time (or proper multivariate design) |
