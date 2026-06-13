# Recovery Protocol

## Overview

During interactive dialogue evaluation, the evaluator monitors the skill under test against the expected flow graph. When the skill deviates, the evaluator follows this protocol to attempt recovery, capture data, and continue the evaluation.

## Recovery Lifecycle

```
Detect Deviation → Classify Type → Select Strategy → Execute Recovery → Record Outcome → Continue or Fail
```

## Deviation Classification

| Type | Signal | Severity | Example |
|------|--------|----------|---------|
| `wrong_tool` | Skill uses Tool X instead of expected Tool Y | Medium | Uses Bash for file read instead of Read |
| `wrong_file` | Skill accesses wrong path | Medium | Reads `references/foo.md` instead of `references/bar.md` |
| `wrong_order` | Skill performs actions in wrong sequence | Medium | Generates scaffold before selecting archetype |
| `skipped_step` | Skill omits an expected node | High | Jumps from discovery directly to scaffold |
| `fabrication` | Skill claims something exists that doesn't | Critical | References a file that was never created |
| `scope_violation` | Skill operates outside its declared scope | High | Attempts to run code instead of just generating it |
| `infinite_loop` | Skill repeats the same action | High | Re-reads the same file 3+ times |
| `hallucinated_output` | Skill produces output not grounded in its docs | Critical | Invents a workflow not in the agent playbook |
| `stuck` | Skill stops making progress | Medium | Asks the same clarifying question repeatedly |
| `misinterpretation` | Skill misunderstands the task | Medium | Treats an eval instruction as a real user request |

## Recovery Strategies

### Strategy 1: Direct Correction
Best for: `wrong_tool`, `wrong_file`

```
Evaluator: "You used {actual_tool} but this step calls for {expected_tool}. Try again."
```

Max retries: 2. If skill still fails after 2 corrections, record as failed recovery.

### Strategy 2: Hint-Based Recovery
Best for: `wrong_order`, `skipped_step`

```
Evaluator: "Before {current_action}, you should {expected_previous_action}. Consider going back to that step."
```

Max retries: 2. Hint gets progressively more specific on each retry.

### Strategy 3: Scope Redirection
Best for: `scope_violation`

```
Evaluator: "That's outside this skill's scope. The skill's domain is {scope}. Focus on {relevant_action}."
```

Max retries: 1. Scope violations are binary — the skill either respects its boundaries or doesn't.

### Strategy 4: Reality Check
Best for: `fabrication`, `hallucinated_output`

```
Evaluator: "Verify that claim. The file at {path} — does it actually exist? Check with the Read tool."
```

Max retries: 1. Fabrication is a critical issue; recovery is about capturing data, not fixing the skill.

### Strategy 5: Loop Breaking
Best for: `infinite_loop`, `stuck`

```
Evaluator: "You've repeated {action} {count} times. Move on to {next_step}."
```

Max retries: 1. After one attempt to break the loop, fail the scenario.

### Strategy 6: Re-Framing
Best for: `misinterpretation`

```
Evaluator: "To clarify, this is an evaluation scenario. The task is: {original_instruction}. Focus on {specific_step}."
```

Max retries: 1.

## Recording Recovery Data

Every recovery attempt is recorded:

```yaml
recovery_log:
  - timestamp: 2025-01-15T10:35:00Z
    scenario: basic-workflow
    node: step-3
    deviation_type: wrong_tool
    expected: "Read tool to access references/file.md"
    actual: "Bash tool with cat command"
    strategy: direct_correction
    evaluator_message: "Use the Read tool instead of cat."
    skill_response: "Corrected to use Read tool"
    outcome: recovered
    retries_used: 1
    quality_adjustment: 0.7  # Recovered after one correction

  - timestamp: 2025-01-15T10:42:00Z
    scenario: basic-workflow
    node: step-5
    deviation_type: fabrication
    expected: "Reference to existing file references/guide.md"
    actual: "Claimed references/guide.md contains section X (file doesn't have section X)"
    strategy: reality_check
    evaluator_message: "Check the actual content of references/guide.md."
    skill_response: "Confirmed section X is not present, adjusted output"
    outcome: recovered_with_degradation
    retries_used: 1
    quality_adjustment: 0.5  # Recovered but output quality degraded
```

## Recovery Metrics

| Metric | Formula | Good | Acceptable | Poor |
|--------|---------|------|------------|------|
| Recovery rate | successful / attempted | >0.80 | 0.60-0.80 | <0.60 |
| First-try rate | recovered_on_first / total_recovered | >0.70 | 0.50-0.70 | <0.50 |
| Quality retention | avg quality_adjustment of recoveries | >0.8 | 0.6-0.8 | <0.6 |
| Hints needed | avg hints per recovery | <1.0 | 1.0-2.0 | >2.0 |

## When to Abandon

Abandon the scenario (mark as failed) when:
- 3+ consecutive recovery attempts fail
- A critical deviation occurs (fabrication, scope violation) and recovery fails
- The skill is in an infinite loop after loop-breaking attempt
- Total recovery attempts for the scenario exceed 5

Capture the abandoned state:
```yaml
abandoned:
  reason: "3 consecutive failed recovery attempts"
  last_successful_node: step-2
  nodes_remaining: [step-3, step-4, done]
  partial_score: 0.40
```
