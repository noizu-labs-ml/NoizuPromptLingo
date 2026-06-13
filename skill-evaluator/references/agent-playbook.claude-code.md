# Skill Evaluator -- Claude Code Agent Playbook

## Agent Role Definition

```yaml
role: Skill Evaluation Engineer
purpose: >
  Execute structured evaluation of AI agent skills through scenario-based testing,
  interactive dialogue, and exam batteries. Capture issues, patches, and improvement
  items for feedback into skill engineering.
capabilities:
  - Parse skill documentation and generate eval suites
  - Execute directed-flow task scenarios against skills
  - Conduct interactive dialogue evaluation with recovery
  - Administer and score multiple-choice and essay exams
  - Compare skill performance across models
  - Detect regressions against baselines
  - Generate structured improvement recommendations
operating_principles:
  - Every deviation from expected flow is an observation, not a judgment
  - Recovery attempts are first-class eval data
  - Examine the skill's reasoning, not just its outputs
  - Compare like-for-like: same scenario, different conditions
  - Never modify the skill under test during evaluation
constraints:
  - Do not modify files in the skill's directory during eval
  - Do not skip recovery steps — capture the full interaction
  - Do not fabricate eval results
  - Do not run scenarios that require external API keys without confirmation
inputs:
  - Skill directory path
  - Eval suite configuration (eval.yaml)
  - Baseline results (optional)
outputs:
  - Run results YAML
  - Issue tracker updates
  - Recovery logs
  - Exam score reports
  - Improvement recommendations
```

## Workflow 1: Prepare Eval Suite

**Trigger:** User requests eval preparation for a skill, or `eval-prepare --skill <name>`

**Steps:**

1. **Load skill docs**
   - Read `SKILL.md` from `~/.claude/skills/{name}/SKILL.md`
   - Read `references/agent-playbook.claude-code.md`
   - List all reference files and asset templates
   - Parse frontmatter (name, description = trigger language)

2. **Analyze skill structure**
   - Identify skill archetype (catalog, workflow, service, strategy, meta)
   - Map declared workflows in agent playbook
   - Extract: trigger conditions, core philosophy, when-to-use scenarios
   - Extract: cross-references to other skills
   - Extract: required reference files, expected file tree

3. **Generate scenarios**
   - For each workflow in the agent playbook: create 1 primary scenario + 1 edge-case variant
   - For each "When to Use" bullet: create 1 trigger-precision scenario
   - For each cross-reference: create 1 boundary test (should NOT trigger for this)
   - For each philosophy principle: create 1 principle-adherence scenario
   - Assign difficulty based on complexity (easy for single-workflow, hard for multi-workflow with recovery)
   - Write each scenario to `~/.claude/evals/{name}/scenarios/{slug}.yaml`

4. **Generate exam batteries**
   - Parse SKILL.md sections into exam topics
   - For each major section (Overview, Philosophy, When to Use, etc.):
     - Generate 3-5 multiple-choice questions testing comprehension
     - Generate 1-2 essay questions testing application
   - For trigger language: generate discrimination questions (this skill vs. related skills)
   - For cross-references: generate boundary questions (when to use this vs. that)
   - Write to `~/.claude/evals/{name}/exams/`

5. **Generate eval.yaml**
   - Set dimensions based on skill archetype
   - Set thresholds per archetype defaults
   - Configure models to test
   - Write to `~/.claude/evals/{name}/eval.yaml`

6. **Report**
   - Summary: X scenarios, Y MC questions, Z essay questions, covering N dimensions
   - Coverage map: which skill sections are tested, which are not

**Output Template:**
```
## Eval Suite Prepared -- {skill-name}

### Coverage
- Scenarios: {count} ({easy} easy, {medium} medium, {hard} hard, {adversarial} adversarial)
- MC Questions: {count} across {topics} topics
- Essay Questions: {count} across {topics} topics
- Dimensions: {list}

### Files Generated
- eval.yaml
- scenarios/{list}
- exams/multiple-choice/{list}
- exams/essay/{list}

### Coverage Gaps
- {any sections not covered by scenarios/exams}
```

## Workflow 2: Run Scenarios

**Trigger:** User requests eval run, or `eval-run --skill <name>`

**Steps:**

1. **Load eval suite**
   - Read `eval.yaml` for configuration
   - Enumerate all scenario files in `scenarios/`
   - If `--scenario` flag: filter to specific scenario
   - If `--model` flag: override model configuration

2. **Initialize run**
   - Generate run ID: `run-{timestamp}-{model-slug}`
   - Create results directory: `results/{run-id}/`
   - Write `run.yaml` with metadata

3. **For each scenario:**
   a. Load scenario YAML, parse flow graph
   b. Load skill under test (SKILL.md + relevant references)
   c. Send initial instruction to skill
   d. For each expected node in the flow:
      - Compare actual skill behavior against `expected_action`
      - Check tool usage against `expected_tools`
      - Check file operations against `expected_files`
      - If matches: advance to next node, record success
      - If deviates:
        - Check for matching recovery path
        - If recovery path exists: execute recovery, record attempt
        - If no recovery path: record deviation as issue, attempt to continue
   e. Evaluate against `success_criteria`
   f. Calculate per-scenario scores
   g. Write scenario result to `results/{run-id}/scenario-results.yaml`

4. **Aggregate results**
   - Calculate dimension scores across all scenarios
   - Generate summary in `run.yaml`
   - Write issues to `issues/issues.yaml`
   - Write recovery log to `results/{run-id}/recovery-log.yaml`

5. **Regression check**
   - If baseline exists: compare pass rates, dimension scores
   - Flag regressions exceeding `regression_delta` threshold
   - Write regression analysis to run summary

**Output Template:**
```
## Eval Run Complete -- {run-id}

### Summary
- Scenarios: {passed}/{total} passed ({pass_rate})
- Issues: {count} ({critical} critical, {high} high, {medium} medium, {low} low)
- Recoveries: {attempted} attempted, {successful} successful
- Duration: {total_ms}ms

### By Dimension
| Dimension | Score | Threshold | Pass |
|-----------|-------|-----------|------|
| ... | ... | ... | ... |

### Top Issues
1. {severity}: {summary}
2. {severity}: {summary}
3. {severity}: {summary}

### Regression
- Baseline: {baseline_id} ({baseline_pass_rate})
- Delta: {delta}
- Status: {regressed|stable|improved}
```

## Workflow 3: Interactive Dialogue Evaluation

**Trigger:** User requests interactive eval, or `eval-dialogue --skill <name> --scenario <id>`

**Steps:**

1. **Setup**
   - Load scenario and expected flow graph
   - Load skill docs
   - Create recovery log

2. **Execute**
   - Spawn a teammate agent to run the skill under test
   - Send the task instruction
   - Monitor teammate's actions against expected flow
   - At each node:
     a. If teammate matches expected: acknowledge, provide next input
     b. If teammate deviates:
        - Determine deviation type (wrong tool, wrong file, wrong order, fabrication, scope violation)
        - Select recovery strategy from scenario's `recovery_paths`
        - Send corrective guidance to teammate
        - Record recovery attempt in log
     c. If teammate is stuck:
        - Provide hint based on skill's own documentation
        - Record hint given
     d. If teammate recovers:
        - Note recovery quality
        - Continue flow

3. **Capture**
   - Full dialogue transcript
   - Per-step deviation/recovery notes
   - Flow adherence score
   - Recovery success rate

4. **Debrief**
   - Generate improvement notes
   - Map deviations to specific skill doc gaps
   - Suggest patches

**Recovery Strategies:**

| Deviation Type | Recovery Action | Max Retries |
|---------------|----------------|-------------|
| Wrong tool | "Try using {correct_tool} instead" | 2 |
| Wrong file path | "The file is at {correct_path}" | 1 |
| Wrong order | "Try {correct_action} first, then {next}" | 2 |
| Fabrication | "That reference doesn't exist. Check the actual files." | 1 |
| Scope violation | "That's outside this skill's scope. Focus on {scope}." | 1 |
| Missing step | "You skipped {step}. Go back and handle it." | 2 |
| Infinite loop | "You're repeating. Move on to the next step." | 1 |
| Hallucinated output | "Verify that output against the actual file content." | 1 |

## Workflow 4: Run Exam Battery

**Trigger:** User requests exam, or `eval-exam --skill <name>`

**Steps:**

1. **Load exams**
   - Read all YAML files from `exams/multiple-choice/` and `exams/essay/`
   - If `--type` flag: filter to specific type
   - If `--difficulty` flag: filter to difficulty level

2. **Administer MC questions**
   - Present question + options to skill under test
   - Collect response
   - Score against correct answer
   - Record: question_id, selected, correct, time_ms
   - Calculate: overall score, by-difficulty, by-tag

3. **Administer essay questions**
   - Present question to skill under test
   - Collect response
   - Score against `expected_elements`:
     - Completeness: fraction of expected elements addressed
     - Accuracy: correctness of claims (cross-reference skill docs)
     - Order: logical sequence of steps
     - Nuance: edge cases and non-obvious points mentioned
   - Record scores per rubric dimension

4. **Aggregate**
   - MC: overall, by-difficulty, by-tag breakdowns
   - Essay: overall, by-tag, by-rubric-dimension breakdowns
   - Write to `exam-results.yaml`

5. **Analysis**
   - Identify weak topics (lowest-scoring tags)
   - Identify confusion patterns (most-selected wrong answers)
   - Identify reasoning gaps (essay elements most commonly missed)

**Output Template:**
```
## Exam Results -- {skill-name}

### Multiple Choice
- Overall: {score} ({correct}/{total})
- By Difficulty: Easy {easy_score}, Medium {med_score}, Hard {hard_score}, Adversarial {adv_score}
- Weak Topics: {tags with lowest scores}
- Common Confusions: {most-selected distractors}

### Essay
- Average Score: {avg}
- By Tag: {tag_scores}
- Commonly Missed Elements: {list}

### Recommendations
- {topic} needs improved documentation — {evidence}
- {topic} confusion with {distractor_type} — consider clarifying boundary
```

## Workflow 5: Model Comparison

**Trigger:** User requests model comparison, or `eval-compare --skill <name> --models`

**Steps:**

1. **Load results**
   - Load all run results from `results/`
   - Group by model

2. **Compare dimensions**
   - For each dimension: compute delta between models
   - Flag dimensions where delta > 0.15 (significant difference)

3. **Compare scenario outcomes**
   - Per-scenario pass/fail across models
   - Per-scenario score deltas
   - Scenarios where one model fails and another passes

4. **Compare exam performance**
   - MC score by difficulty across models
   - Essay rubric dimensions across models

5. **Generate comparison report**
   - Markdown table: model x dimension
   - Per-model strengths/weaknesses
   - Skill design recommendations based on cross-model gaps

**Output Template:**
```
## Model Comparison -- {skill-name}

### Dimension Scores
| Dimension | Opus | Sonnet | Haiku | Delta |
|-----------|------|--------|-------|-------|
| ... | ... | ... | ... | ... |

### Scenario Outcomes
| Scenario | Opus | Sonnet | Haiku |
|----------|------|--------|-------|
| ... | pass/fail | pass/fail | pass/fail |

### Key Findings
- {model} excels at {dimension} — {evidence}
- {model} struggles with {dimension} — {evidence}
- Skill depends on {capability} — models lacking it will underperform

### Recommendations
- {skill design changes to improve cross-model robustness}
```

## Workflow 6: Regression Detection

**Trigger:** After eval run, or `eval-compare --skill <name> --baseline <id>`

**Steps:**

1. Load current run results and baseline run results
2. Compare dimension-by-dimension scores
3. Flag regressions exceeding threshold
4. Identify new failures (scenarios that passed in baseline but fail now)
5. Identify improvements (scenarios that failed in baseline but pass now)
6. Check issue status (are previously-found issues fixed?)
7. Generate regression report with promotion recommendation (Promote / Hold / Rollback)

## Quick Reference: Which Workflow When

| Situation | Workflow |
|-----------|----------|
| First time evaluating a skill | 1 (Prepare) then 2 (Run) |
| Skill was updated, check for regressions | 2 (Run) then 6 (Regression) |
| Skill is failing, need to debug | 3 (Dialogue) |
| Testing skill knowledge without execution | 4 (Exam) |
| Comparing model performance | 2 (Run) per model, then 5 (Compare) |
| Iterating on skill improvements | 1→2→3→6, feed results to skill-engineer |

## Integration Points

- **skill-engineer** — Consumes eval issues and patches to improve skills
- **site-walkthrough** — Provides directed graph patterns, persona evaluation, and issue lifecycle
- **agentic-harness-engineer** — Provides scoring functions, CI integration patterns
- **Claude Teams** — Evaluator can spawn teammate agents to run skills under test
