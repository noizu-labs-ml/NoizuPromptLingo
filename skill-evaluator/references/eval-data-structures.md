# Eval Data Structures Reference

## Overview

This reference provides complete schema documentation for all YAML types used by the skill-evaluator. All data lives under `~/.claude/evals/{skill-name}/`.

## Directory Layout

```
~/.claude/evals/{skill-name}/
├── eval.yaml                          # Suite configuration
├── scenarios/
│   └── {scenario-name}.yaml           # Task scenarios with flow graphs
├── exams/
│   ├── multiple-choice/
│   │   └── {topic}.yaml               # MC question batteries
│   └── essay/
│       └── {topic}.yaml               # Essay questions
├── flows/
│   └── {scenario-name}.md             # Generated Mermaid diagrams
├── results/
│   └── {run-id}/
│       ├── run.yaml                   # Run metadata + summary
│       ├── scenario-results.yaml      # Per-scenario outcomes
│       ├── exam-results.yaml          # Per-exam scores
│       ├── issues.yaml                # Issues found during run
│       ├── recovery-log.yaml          # Recovery attempts
│       └── notes.md                   # Free-form evaluator notes
├── baselines/
│   └── baseline.yaml                  # Reference run for regression
└── issues/
    ├── issues.yaml                    # Cross-run issue tracker
    └── patches/
        └── {patch-id}.yaml            # Suggested skill patches
```

## eval.yaml

```yaml
skill: string                    # kebab-case skill name
version: string                  # Semver
description: string              # One-line description
author: string                   # Evaluator name
created: date                    # YYYY-MM-DD
last_run: datetime | null        # ISO 8601 or null

dimensions:                      # Evaluation dimensions (subset or all)
  - task_accuracy
  - flow_adherence
  - recovery_ability
  - edge_case_handling
  - instruction_following
  - self_containment
  - cross_reference

thresholds:                      # Pass thresholds per dimension
  min_pass_rate: float           # 0.0-1.0, overall minimum
  task_accuracy: float
  flow_adherence: float
  recovery_ability: float
  regression_delta: float        # Max allowed negative change

models_to_test:                  # Models to benchmark
  - model: string                # Model identifier
    temperature: float           # Sampling temperature
    max_tokens: int              # Optional: max response tokens
    system_prompt_override: string | null  # Optional: override system prompt
```

## Scenario YAML

```yaml
scenario: string                  # kebab-case scenario name
description: string               # What this scenario tests
difficulty: enum                  # easy | medium | hard | adversarial
tags: [string]                    # Categorization tags

preconditions:                    # Required setup
  files_required:
    - path: string                # File path (relative to skill dir)
      must_exist: boolean         # Whether file must exist
  context: string                 # Setup context description

task:
  instruction: string             # Exact instruction to give the skill
  expected_tools: [string]        # Tools the skill should use

flow:
  nodes:                          # Directed graph nodes
    - id: string                  # Unique node identifier
      type: enum                  # trigger | action | decision | observe | terminal
      expected_action: string     # What the skill should do at this node
      expected_tools: [string]    # Required at this node
      expected_files: [string]    # Files the skill should access
      expected_content: string    # Content to verify (observe nodes)
      branches:                   # For decision nodes
        - condition: string
          target: string          # Node ID
      validation:                 # For action/terminal nodes
        files_created: [string]
        content_contains: [string]
        content_not_contains: [string]
      success_criteria: [string]  # For terminal nodes
      on_success: string          # Node ID
      on_failure: string          # Node ID or recovery path ID

  recovery_paths:                 # What to try when skill deviates
    - id: string
      trigger: string             # Condition that activates this path
      evaluator_action: string    # What the evaluator should do
      expected_skill_response: string
      max_retries: int

  variables:                      # Substitution variables
    key: value

success_criteria:                 # Overall pass/fail conditions
  all_of: [string]                # All must be true
  any_of: [string]                # At least one must be true
  none_of: [string]               # None must be true

scoring:                          # Per-scenario scoring weights
  flow_adherence: float           # Default: 0.4
  task_accuracy: float            # Default: 0.3
  recovery_score: float           # Default: 0.2
  efficiency: float               # Default: 0.1
```

## Multiple-Choice Exam YAML

```yaml
exam: string                      # Topic name
type: multiple-choice
skill_under_test: string
difficulty_distribution:
  easy: float                     # Fraction (should sum to 1.0)
  medium: float
  hard: float
  adversarial: float

questions:
  - id: string                    # Unique question ID (e.g., mc-001)
    question: string              # The question text
    difficulty: enum              # easy | medium | hard | adversarial
    options:
      - id: string                # Option letter (a, b, c, d)
        text: string              # Option text
        correct: boolean          # Is this the correct answer
        distractor_type: enum     # close_confusion | wrong_domain | fabricated |
                                  # over_generalized | under_generalized | inverted_logic
    explanation: string           # Why the correct answer is correct
    tags: [string]                # Topic tags
    probes: [string]              # What capability this probes
```

## Essay Exam YAML

```yaml
exam: string
type: essay
skill_under_test: string

questions:
  - id: string
    question: string
    difficulty: enum
    expected_elements: [string]   # Things the response should contain
    scoring_rubric:
      completeness: float         # 0.0-1.0 weight
      accuracy: float
      order: float
      nuance: float
      reasoning_quality: float    # Optional, for ambiguity questions
      practicality: float         # Optional, for decision questions
    max_response_length: int      # Word limit
    tags: [string]
```

## Issues YAML

```yaml
issues:
  - id: string                    # ISS-NNN format
    found: date
    run_id: string
    scenario: string
    step: string
    severity: enum                # critical | high | medium | low
    category: enum                # flow-deviation | output-error | recovery-failure |
                                  # fabrication | scope-violation
    summary: string
    detail: string
    expected: string
    actual: string
    recovery_attempted: boolean
    recovery_outcome: string
    model: string
    recommendation: string
    suggested_patch:
      file: string
      type: enum                  # content-update | structural | new-file | reference-fix
      description: string
    status: enum                  # open | fixed | wontfix | deferred | verified
    fixed_in: string | null
```

## Run Results YAML

```yaml
run:
  id: string                      # run-{timestamp}-{model-slug}
  skill: string
  skill_version: string
  model: string
  temperature: float
  timestamp: datetime             # ISO 8601
  evaluator: string
  baseline_id: string | null

summary:
  scenarios_run: int
  scenarios_passed: int
  scenarios_failed: int
  pass_rate: float
  exam_score_avg: float
  issues_found: int
  regressions_detected: int

dimensions:
  task_accuracy: float
  flow_adherence: float
  recovery_ability: float
  edge_case_handling: float
  instruction_following: float
  self_containment: float
  cross_reference: float

scenario_results:
  - scenario: string
    passed: boolean
    score: float
    steps_completed: string       # "N/M" format
    recoveries_needed: int
    recoveries_successful: int
    duration_ms: int
    failure_detail: string | null

exam_results:
  multiple_choice:
    total: int
    correct: int
    score: float
    by_difficulty:
      easy: float
      medium: float
      hard: float
      adversarial: float
    by_tag: {}
  essay:
    total: int
    avg_score: float
    by_tag: {}

regression:
  baseline_run: string | null
  baseline_pass_rate: float
  delta: float
  regressions: [string]
  improvements: [string]
  is_significant: boolean
```

## Recovery Log YAML

```yaml
recovery_log:
  - timestamp: datetime
    scenario: string
    node: string
    deviation_type: enum          # wrong_tool | wrong_file | wrong_order | skipped_step |
                                  # fabrication | scope_violation | infinite_loop |
                                  # hallucinated_output | stuck | misinterpretation
    expected: string
    actual: string
    strategy: enum                # direct_correction | hint_based | scope_redirect |
                                  # reality_check | loop_breaking | re_framing
    evaluator_message: string
    skill_response: string
    outcome: enum                 # recovered | recovered_with_degradation | failed
    retries_used: int
    quality_adjustment: float     # 0.0-1.0
```

## Patch YAML

```yaml
patch:
  id: string                      # PATCH-NNN format
  source_issue: string            # ISS-NNN that triggered this patch
  skill: string
  file: string                    # File to modify
  type: enum                      # content-update | structural | new-file | reference-fix
  description: string             # What to change
  priority: enum                  # P0 | P1 | P2
  status: enum                    # proposed | applied | rejected | superseded
  applied_in: string | null       # Commit or version where applied
```
