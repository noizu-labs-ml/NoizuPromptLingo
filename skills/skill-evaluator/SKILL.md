---
name: trl-skill-evaluator
description: >
  Evaluate AI agent skills through structured task scenarios, directed-flow task execution,
  interactive dialogue with the skill under test, and comprehensive exam/quiz batteries.
  Use this skill when evaluating skill quality, testing skills across models or fine-tunes,
  generating exam questions for skills, running task-based evals, comparing skill performance,
  diagnosing skill failures, creating eval datasets for skills, or building regression suites
  for skill quality. Triggers: skill eval, skill test, skill quiz, skill exam, evaluate skill,
  skill regression, skill benchmark, model comparison, skill scoring, eval suite, task flow
  test, directed graph eval, scenario test, skill audit.
---

# Skill Evaluator

## Overview

- **Task-scenario execution** — Digests YAML + Markdown + directed-graph folders describing tasks to attempt with a skill, runs them, and evaluates outcomes against expected results
- **Interactive dialogue** — Talks back and forth with another team member (or sub-agent) running the skill under test, using expected flow graphs to recover from bad/unexpected outcomes mid-execution
- **Exam & quiz generation** — Creates multiple-choice and essay exam batteries probing how a skill handles specific situations, used to evaluate performance across models and fine-tunes
- **Improvement note-taking** — Captures failure patterns, patches, and improvement items as structured YAML issues during and after evaluation runs
- **Regression tracking** — Baseline comparison across runs, detecting regressions and improvements with diff reports
- **Model benchmarking** — Compare the same skill's performance across different models, temperatures, and configurations

## Core Philosophy

1. **Skills are testable software** — A skill is a prompt program; it deserves the same rigor as code: test suites, regression detection, and CI gating
2. **Flows are contracts** — The directed graph of expected actions is a behavioral contract; deviations are bugs, not personality
3. **Recovery is part of evaluation** — How a skill recovers from unexpected state is as important as how it handles the happy path
4. **Exams probe understanding, not recall** — Multiple-choice and essay questions test whether a skill's reasoning matches its stated methodology, not whether it parrots its docs
5. **Many models, one truth** — The same eval suite run across models reveals where skill design depends on specific model capabilities vs. where it's robust

## When to Use This Skill

- **Evaluating a skill before release** — Run the full eval suite against a new or updated skill
- **Comparing model performance** — Benchmark how the same skill performs on Opus vs. Sonnet vs. Haiku vs. third-party models
- **Diagnosing skill failures** — Interactive debugging session where the evaluator guides the skill through a task and captures where it goes wrong
- **Creating eval datasets** — Author task scenarios, exam questions, and quiz batteries for any skill in the ecosystem
- **Regression testing** — Re-run evals after skill updates and compare against baselines
- **Skill improvement iteration** — Structured capture of issues, patches, and improvement items feeding back into skill-engineer

## Eval Registry Format

All eval data lives under `~/.claude/evals/{skill-name}/`:

```
~/.claude/evals/{skill-name}/
  eval.yaml                    # Eval suite metadata
  scenarios/
    {scenario-name}.yaml       # Task scenario with directed flow graph
  exams/
    multiple-choice/
      {topic}.yaml             # Multiple-choice question batteries
    essay/
      {topic}.yaml             # Essay / free-response questions
  flows/
    {scenario-name}.md         # Generated Mermaid flow diagrams
  results/
    {run-id}/
      run.yaml                 # Run metadata (model, config, timestamp)
      scenario-results.yaml    # Per-scenario pass/fail with details
      exam-results.yaml        # Per-exam scores
      issues.yaml              # Issues found during run
      recovery-log.yaml        # Recovery actions taken
      notes.md                 # Free-form evaluator notes
  baselines/
    baseline.yaml              # Reference run for regression detection
  issues/
    issues.yaml                # Cross-run issue tracker
    patches/
      {patch-id}.yaml          # Suggested skill patches
```

### eval.yaml Schema

```yaml
skill: skill-name
version: "1.0"
description: One-line description of this eval suite
author: evaluator-name
created: 2025-01-01
last_run: null

dimensions:
  - task_accuracy          # Does the skill complete the task correctly?
  - flow_adherence         # Does it follow the expected directed graph?
  - recovery_ability       # Can it recover from unexpected states?
  - edge_case_handling    # Does it handle boundary conditions?
  - instruction_following  # Does it follow its own stated methodology?
  - self_containment       # Does it work without external dependencies?
  - cross_reference        # Are cross-references accurate?

thresholds:
  min_pass_rate: 0.80
  task_accuracy: 0.85
  flow_adherence: 0.80
  recovery_ability: 0.70
  regression_delta: -0.05

models_to_test:
  - model: claude-opus-4-7
    temperature: 0.3
  - model: claude-sonnet-4-6
    temperature: 0.3
  - model: claude-haiku-4-5
    temperature: 0.3
```

### Scenario YAML Schema

```yaml
scenario: scenario-name
description: What this scenario tests
difficulty: easy | medium | hard | adversarial
tags: [tag1, tag2]

preconditions:
  files_required:
    - path: references/some-file.md
      must_exist: true
  context: "Any setup context the skill needs"

task:
  instruction: "The exact instruction to give the skill"
  expected_tools: [tool1, tool2]  # Tools the skill should use

flow:
  # Directed graph of expected execution
  nodes:
    - id: start
      type: trigger
      action: "Skill receives instruction"

    - id: step-1
      type: action
      expected_action: "Read reference file X"
      expected_tools: [Read]
      expected_files: ["references/some-file.md"]
      on_success: step-2
      on_failure: recover-1

    - id: step-2
      type: action
      expected_action: "Generate scaffold"
      expected_tools: [Write]
      validation:
        files_created: ["output/file.md"]
        content_contains: ["required-section"]
      on_success: step-3
      on_failure: recover-2

    - id: step-3
      type: terminal
      expected_action: "Report completion"
      success_criteria:
        - "All required files created"
        - "Content passes quality checks"

  # Recovery paths — what the evaluator should try
  recovery_paths:
    - id: recover-1
      trigger: "File not found"
      evaluator_action: "Tell skill the file is at alternate path"
      expected_skill_response: "Skill adapts and reads from alternate path"
      max_retries: 2

    - id: recover-2
      trigger: "Write failed"
      evaluator_action: "Ask skill to retry with corrected content"
      expected_skill_response: "Skill identifies error and corrects"
      max_retries: 3

  # Variables that can be substituted in the flow
  variables:
    skill_path: "~/.claude/skills/{skill-name}"
    output_dir: "/tmp/eval-output"

success_criteria:
  all_of:
    - "All terminal nodes reached"
    - "No unresolved recovery paths"
  any_of:
    - "Output matches expected structure"
    - "Output passes quality rubric score >= 7.0"
  none_of:
    - "Skill reports error without attempting recovery"
    - "Skill fabricates references to non-existent files"

scoring:
  flow_adherence: 0.4     # Did it follow the directed graph?
  task_accuracy: 0.3      # Was the output correct?
  recovery_score: 0.2     # How well did it recover?
  efficiency: 0.1         # Tool calls vs expected
```

### Exam YAML Schema (Multiple Choice)

```yaml
exam: topic-name
type: multiple-choice
skill_under_test: skill-name
difficulty_distribution:
  easy: 0.30
  medium: 0.45
  hard: 0.20
  adversarial: 0.05

questions:
  - id: mc-001
    question: "When should this skill be triggered over a related skill?"
    difficulty: easy
    options:
      - id: a
        text: "Option A text"
        correct: true
      - id: b
        text: "Option B text"
        correct: false
        distractor_type: close_confusion  # Almost right but missing nuance
      - id: c
        text: "Option C text"
        correct: false
        distractor_type: wrong_domain     # Right idea, wrong skill
      - id: d
        text: "Option D text"
        correct: false
        distractor_type: fabricated       # Plausible but wrong
    explanation: "Why A is correct and others are wrong"
    tags: [trigger-precision, scope-boundary]
    probes: [understanding, discrimination]

  - id: mc-002
    question: "Given this scenario, what should the skill do first?"
    difficulty: medium
    # ... same structure
```

### Exam YAML Schema (Essay)

```yaml
exam: topic-name
type: essay
skill_under_test: skill-name

questions:
  - id: es-001
    question: "Describe the step-by-step process for handling [specific scenario]."
    difficulty: medium
    expected_elements:
      - "Mention of preconditions check"
      - "Reference to specific reference file"
      - "Error handling for [specific case]"
      - "Output validation step"
    scoring_rubric:
      completeness: 0.40   # Covers all expected elements
      accuracy: 0.30       # Steps are correct per skill docs
      order: 0.15          # Steps are in logical order
      nuance: 0.15         # Catches edge cases or non-obvious points
    max_response_length: 500
    tags: [process, methodology]

  - id: es-002
    question: "A user invokes the skill with [ambiguous request]. How should the skill resolve this?"
    difficulty: hard
    expected_elements:
      - "Identify the ambiguity"
      - "Present assumptions as choices"
      - "Recommend a default path"
    scoring_rubric:
      completeness: 0.35
      accuracy: 0.30
      reasoning_quality: 0.20  # How well the ambiguity is analyzed
      practicality: 0.15       # Is the resolution actionable?
    max_response_length: 800
    tags: [ambiguity, decision-making]
```

### Issues YAML Schema

```yaml
issues:
  - id: ISS-001
    found: 2025-01-15
    run_id: run-20250115-opus
    scenario: scenario-name
    step: step-2
    severity: critical | high | medium | low
    category: flow-deviation | output-error | recovery-failure | fabrication | scope-violation
    summary: "One-line summary"
    detail: "Extended description of what went wrong"
    expected: "What should have happened"
    actual: "What actually happened"
    recovery_attempted: true | false
    recovery_outcome: "Description of recovery attempt"
    model: claude-opus-4-7
    recommendation: "Suggested fix"
    suggested_patch:
      file: "path/to/file"
      type: content-update | structural | new-file | reference-fix
      description: "What to change"
    status: open | fixed | wontfix | deferred | verified
    fixed_in: null
```

### Run Results YAML Schema

```yaml
run:
  id: run-20250115-opus
  skill: skill-name
  skill_version: "1.0"
  model: claude-opus-4-7
  temperature: 0.3
  timestamp: 2025-01-15T10:30:00Z
  evaluator: claude-opus-4-7
  baseline_id: baseline-001

summary:
  scenarios_run: 5
  scenarios_passed: 4
  scenarios_failed: 1
  pass_rate: 0.80
  exam_score_avg: 0.85
  issues_found: 3
  regressions_detected: 0

dimensions:
  task_accuracy: 0.85
  flow_adherence: 0.90
  recovery_ability: 0.75
  edge_case_handling: 0.80
  instruction_following: 0.90
  self_containment: 0.95
  cross_reference: 0.85

scenario_results:
  - scenario: basic-workflow
    passed: true
    score: 0.92
    steps_completed: 5/5
    recoveries_needed: 0
    duration_ms: 45000

  - scenario: edge-case-missing-ref
    passed: false
    score: 0.55
    steps_completed: 3/5
    recoveries_needed: 2
    recoveries_successful: 1
    duration_ms: 78000
    failure_detail: "Skill fabricated reference content instead of reporting missing file"

exam_results:
  multiple_choice:
    total: 20
    correct: 17
    score: 0.85
    by_difficulty:
      easy: 0.95
      medium: 0.82
      hard: 0.75
      adversarial: 0.40
  essay:
    total: 5
    avg_score: 0.78
    by_tag:
      process: 0.85
      ambiguity: 0.65
      edge_case: 0.70

regression:
  baseline_run: baseline-001
  baseline_pass_rate: 0.85
  delta: -0.05
  regressions: []
  improvements:
    - "Edge case handling improved from 0.70 to 0.80"
  is_significant: false
```

## Evaluation Modes

### Mode 1: Autonomous Scenario Execution

The evaluator runs scenarios autonomously, executing the skill's workflow and comparing against expected flow graphs.

```
eval-prepare --skill <name>              # Generate eval suite from skill docs
eval-run --skill <name>                  # Run all scenarios
eval-run --skill <name> --scenario <id>  # Run specific scenario
eval-run --skill <name> --model <model>  # Run against specific model
eval-run --skill <name> --exam-only      # Run only exam battery
```

### Mode 2: Interactive Dialogue Evaluation

The evaluator acts as a team lead, sending instructions to a teammate running the skill under test. Uses expected flow to guide, recover, and take notes.

```
eval-dialogue --skill <name> --scenario <id>   # Interactive eval session
eval-dialogue --skill <name> --recover         # Resume from failure point
```

### Mode 3: Exam Battery

Multiple-choice and essay exams testing the skill's knowledge and reasoning without full execution.

```
eval-exam --skill <name>                      # Run full exam battery
eval-exam --skill <name> --type multiple-choice
eval-exam --skill <name> --type essay
eval-exam --skill <name> --difficulty hard
eval-exam --skill <name> --compare-models     # Same exam, multiple models
```

### Mode 4: Regression & Comparison

Compare runs across time or models.

```
eval-compare --skill <name> --baseline <id>   # Compare against baseline
eval-compare --skill <name> --models          # Compare across models
eval-trend --skill <name>                     # Show trend over time
eval-baseline --skill <name> --set <run-id>   # Set new baseline
```

## Workflow

| Phase | Activity | Output |
|-------|----------|--------|
| 1. Prepare | Parse skill docs, generate scenarios & exams | `eval.yaml`, `scenarios/`, `exams/` |
| 2. Execute | Run scenarios against skill, dialogue with skill runner | `results/{run-id}/` |
| 3. Examine | Administer exam batteries | `exam-results.yaml` |
| 4. Analyze | Score results, detect regressions | `run.yaml` summary |
| 5. Report | Generate report with issues and patches | `notes.md`, `issues/` |
| 6. Iterate | Feed improvement items back to skill-engineer | `patches/` |

## Quick Start Guides

### Evaluate an Existing Skill
1. `eval-prepare --skill <name>` — scans skill docs and generates eval suite
2. Review generated scenarios and exams in `~/.claude/evals/<name>/`
3. `eval-run --skill <name>` — execute all scenarios
4. `eval-exam --skill <name>` — run exam battery
5. Review results in `~/.claude/evals/<name>/results/latest/`

### Interactive Debug Session
1. Identify failing scenario from previous run
2. `eval-dialogue --skill <name> --scenario <id> --recover`
3. Evaluator walks through flow with skill runner, capturing recovery attempts
4. Notes captured to `recovery-log.yaml`

### Model Comparison
1. `eval-run --skill <name> --model claude-opus-4-7`
2. `eval-run --skill <name> --model claude-sonnet-4-6`
3. `eval-compare --skill <name> --models`
4. Review dimension-by-dimension comparison

### Create Custom Exam Battery
1. Create `~/.claude/evals/<name>/exams/multiple-choice/<topic>.yaml`
2. Follow the Exam YAML Schema above
3. `eval-exam --skill <name> --exam <topic>`

## Reference Guide

| Task | Read |
|------|------|
| Understanding eval data structures | `references/eval-data-structures.md` |
| Scenario authoring guide | `references/scenario-authoring.md` |
| Exam question design | `references/exam-design.md` |
| Recovery protocol | `references/recovery-protocol.md` |
| Scoring methodology | `references/scoring-methodology.md` |
| Model comparison guide | `references/model-comparison.md` |
| Agent execution workflows | `references/agent-playbook.claude-code.md` |
| Full worked example | `references/worked-example-skill-eval.md` |

## Related Skills

- **trl-skill-engineer** — Build and improve skills based on eval feedback
- **trl-site-walkthrough** — Directed graph flows, persona-driven evaluation, and issue tracking patterns
- **trl-agentic-harness-engineer** — Eval framework patterns, scoring functions, and CI integration

## Bundled Resources

### References

- [eval-data-structures.md](references/eval-data-structures.md) — Complete schema reference for all YAML types
- [scenario-authoring.md](references/scenario-authoring.md) — How to write effective task scenarios with flow graphs
- [exam-design.md](references/exam-design.md) — Multiple-choice and essay question design patterns
- [recovery-protocol.md](references/recovery-protocol.md) — Interactive recovery: when and how to intervene
- [scoring-methodology.md](references/scoring-methodology.md) — Dimension weights, scoring functions, thresholds
- [model-comparison.md](references/model-comparison.md) — Cross-model benchmarking methodology
- [agent-playbook.claude-code.md](references/agent-playbook.claude-code.md) — Agent-executable workflows
- [worked-example-skill-eval.md](references/worked-example-skill-eval.md) — Full walkthrough: evaluating a skill end-to-end

### Assets

- [eval-yaml-template.yaml](assets/eval-yaml-template.yaml) — Starter eval.yaml
- [scenario-yaml-template.yaml](assets/scenario-yaml-template.yaml) — Starter scenario with flow graph
- [multiple-choice-template.yaml](assets/multiple-choice-template.yaml) — Starter MC question battery
- [essay-template.yaml](assets/essay-template.yaml) — Starter essay question battery
- [issues-yaml-template.yaml](assets/issues-yaml-template.yaml) — Issue tracker template
- [run-results-template.yaml](assets/run-results-template.yaml) — Run results template
- [eval-scorecard.md](assets/eval-scorecard.md) — Human-readable scorecard for recording results
- [project-tracker.md](assets/project-tracker.md) — Eval suite project tracker
