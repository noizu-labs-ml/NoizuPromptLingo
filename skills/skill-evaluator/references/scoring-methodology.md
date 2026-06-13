# Scoring Methodology

## Dimension Scoring

Each eval dimension is scored on a 0.0–1.0 scale, weighted, and aggregated into an overall score.

### Dimensions

| Dimension | Weight | What It Measures | Scoring Method |
|-----------|--------|------------------|----------------|
| `task_accuracy` | 0.25 | Does the skill produce correct output? | Output validation against success_criteria |
| `flow_adherence` | 0.25 | Does the skill follow the expected directed graph? | Node-by-node comparison of actual vs expected |
| `recovery_ability` | 0.15 | Can the skill recover from unexpected states? | Recovery success rate × recovery quality |
| `edge_case_handling` | 0.15 | Does the skill handle boundary conditions? | Pass rate on hard/adversarial scenarios |
| `instruction_following` | 0.10 | Does the skill follow its stated methodology? | Cross-reference actual behavior against agent playbook |
| `self_containment` | 0.05 | Does the skill work without external dependencies? | Pass rate on isolation scenarios |
| `cross_reference` | 0.05 | Are cross-references accurate? | Link/reference validity checks |

### Per-Scenario Scoring

For each scenario, four sub-scores are calculated:

```yaml
scoring:
  flow_adherence: 0.4   # Nodes matched / total nodes
  task_accuracy: 0.3    # Success criteria met / total criteria
  recovery_score: 0.2   # Successful recoveries / recovery attempts (0 if none needed)
  efficiency: 0.1       # Expected tool calls / actual tool calls (capped at 1.0)
```

#### Flow Adherence Calculation

```
flow_score = matched_nodes / total_expected_nodes
```

A node is "matched" if:
- The skill performed the `expected_action` (or a semantically equivalent action)
- The skill used tools from `expected_tools`
- The skill accessed files matching `expected_files` (if specified)

Partial matches are allowed:
- Correct action, wrong tool: 0.5
- Correct tool, wrong target file: 0.5
- Correct action, correct tool, correct file: 1.0

#### Task Accuracy Calculation

For each `success_criteria`:
- `all_of`: Each must be true. Score = fraction that are true.
- `any_of`: At least one must be true. Score = 1.0 if any true, 0.0 if none.
- `none_of`: None must be true. Score = 1.0 if none true, 0.0 if any true.

```
accuracy = (all_of_score × 0.5 + any_of_score × 0.3 + none_of_score × 0.2)
```

#### Recovery Score Calculation

```
recovery_score = successful_recoveries / max(recovery_attempts, 1)
```

If no recoveries were needed (skill never deviated), recovery_score = 1.0 (perfect flow = perfect recovery by default).

Recovery quality adjustment:
- Skill recovered on first attempt: ×1.0
- Skill recovered after hint: ×0.7
- Skill recovered but with degraded output: ×0.5

#### Efficiency Calculation

```
efficiency = min(expected_tool_calls / actual_tool_calls, 1.0)
```

A skill that makes 10 tool calls when 5 were expected scores 0.5. A skill that makes 5 calls when 5 were expected scores 1.0.

### Exam Scoring

#### Multiple Choice

```
mc_score = correct_answers / total_questions
```

Breakdowns:
- By difficulty: `correct_at_difficulty / total_at_difficulty`
- By tag: `correct_at_tag / total_at_tag`
- By probe: average score across questions probing that capability

#### Essay

For each question, score each rubric dimension independently:

```
completeness = elements_addressed / total_elements
accuracy = correct_claims / total_claims_made
order = correctly_ordered_pairs / total_adjacent_pairs
nuance = nuance_points_captured / nuance_points_available (0 if none)
```

Weighted essay score:
```
essay_score = completeness × rubric.completeness
            + accuracy × rubric.accuracy
            + order × rubric.order
            + nuance × rubric.nuance
```

### Overall Run Score

```
overall = (task_accuracy × 0.25)
        + (flow_adherence × 0.25)
        + (recovery_ability × 0.15)
        + (edge_case_handling × 0.15)
        + (instruction_following × 0.10)
        + (self_containment × 0.05)
        + (cross_reference × 0.05)

exam_bonus = (mc_score × 0.6 + essay_score × 0.4) × 0.15
final = overall × 0.85 + exam_bonus
```

The exam battery contributes up to 15% of the final score, ensuring that knowledge gaps visible in exams but not caught by scenarios are still reflected.

## Thresholds

| Metric | Pass | Target | Fail |
|--------|------|--------|------|
| Overall score | 0.70 | 0.85 | <0.70 |
| Task accuracy | 0.80 | 0.90 | <0.70 |
| Flow adherence | 0.75 | 0.90 | <0.65 |
| Recovery ability | 0.60 | 0.80 | <0.50 |
| Edge case handling | 0.60 | 0.80 | <0.50 |
| MC exam score | 0.75 | 0.90 | <0.65 |
| Essay exam score | 0.65 | 0.80 | <0.55 |

## Regression Detection

A regression is flagged when:
- Any dimension score decreases by more than `regression_delta` (default: 0.05) from baseline
- A previously-passing scenario now fails
- A previously-fixed issue recurs

Regression severity:
- **Critical**: Dimension drops below pass threshold
- **Major**: Dimension drops by >0.10
- **Minor**: Dimension drops by 0.05–0.10
- **Noise**: Dimension drops by <0.05 (within statistical noise)

## Promotion Decision

Based on overall score and regression analysis:

| Condition | Decision |
|-----------|----------|
| Overall ≥ target, no regressions | **Promote** — Skill is ready |
| Overall ≥ pass, minor regressions only | **Conditional** — Promote with known issues |
| Overall ≥ pass, major/critical regressions | **Hold** — Fix regressions first |
| Overall < pass | **Fail** — Significant work needed |
| Safety boundary violations | **Block** — Must fix before any promotion |
