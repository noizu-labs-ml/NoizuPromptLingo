# Worked Example: Evaluating trl-skill-engineer

A complete walkthrough of evaluating the `skill-engineer` skill end-to-end.

## Step 1: Prepare

Run `eval-prepare --skill skill-engineer`.

The evaluator reads:
- `~/.claude/skills/skill-engineer/SKILL.md` (380 lines)
- `~/.claude/skills/skill-engineer/references/agent-playbook.claude-code.md` (941 lines)
- Directory listing of all reference and asset files

**Analysis:**
- Archetype: Meta (teaches a practice, generates artifacts)
- Key workflows: Discovery, Architecture, Scaffold, Quality Audit, MCP Discovery
- Trigger language: "create a new skill", "design an agent persona", "skill scaffolding"
- Cross-references: site-walkthrough, agentic-harness-engineer, user-experience-engineer

**Generated output:**

`~/.claude/evals/skill-engineer/eval.yaml`:
```yaml
skill: skill-engineer
version: "1.0"
description: "Meta-skill for designing, building, and validating AI agent skills"
author: auto-generated
created: 2025-05-28
dimensions:
  - task_accuracy
  - flow_adherence
  - recovery_ability
  - edge_case_handling
  - instruction_following
  - self_containment
  - cross_reference
thresholds:
  min_pass_rate: 0.80
  task_accuracy: 0.85
  flow_adherence: 0.80
  recovery_ability: 0.70
  regression_delta: -0.05
models_to_test:
  - model: claude-opus-4-7
    temperature: 0.3
```

5 scenarios generated:
1. `basic-scaffold.yaml` (easy) — User provides detailed brief, skill generates scaffold
2. `interactive-discovery.yaml` (medium) — Vague request triggers full discovery workflow
3. `quality-audit.yaml` (medium) — Existing skill evaluated against quality criteria
4. `missing-reference.yaml` (hard) — Skill encounters missing reference file, must recover
5. `scope-violation.yaml` (adversarial) — User asks for something outside skill's scope

2 exam files generated:
- `exams/multiple-choice/trigger-precision.yaml` — 20 questions
- `exams/multiple-choice/process-knowledge.yaml` — 15 questions
- `exams/essay/methodology-application.yaml` — 5 questions

## Step 2: Execute Scenarios

Run `eval-run --skill skill-engineer`.

### Scenario: basic-scaffold

**Instruction:** "I want to create a skill called 'api-debugger' that helps developers debug REST API issues. Target audience: mid-level backend developers. Key features: read error responses, suggest fixes, test endpoints."

**Expected Flow:**
```
start → validate-brief → select-archetype → design-file-tree →
draft-trigger-language → generate-scaffold → report
```

**Execution:**

| Node | Expected | Actual | Match | Notes |
|------|----------|--------|-------|-------|
| start | Receive instruction | Received instruction | Yes | |
| validate-brief | Check 6+ dimensions covered | Identified 5/8 dimensions, asked 3 clarifying questions | Partial | Asked questions instead of proceeding — correct per playbook |
| select-archetype | Select archetype from 5 options | Selected "workflow" archetype with justification | Yes | Good reasoning |
| design-file-tree | Generate file tree | Generated complete tree with 12 files | Yes | |
| draft-trigger-language | Write frontmatter description | Wrote trigger language with 4 trigger patterns | Yes | |
| generate-scaffold | Write all files to disk | Created 8 of 12 files before context limit | Partial | Missing 4 reference files |
| report | Report completion with summary | Reported with coverage gaps noted | Yes | Accurate self-assessment |

**Score:**
- Flow adherence: 5.5/7 nodes = 0.79
- Task accuracy: Scaffold created but incomplete = 0.75
- Recovery: Not needed = 1.0
- Efficiency: Expected 12 files, created 8 = 0.67
- **Overall: 0.79 × 0.4 + 0.75 × 0.3 + 1.0 × 0.2 + 0.67 × 0.1 = 0.83**

### Scenario: missing-reference (hard)

**Instruction:** Same as basic-scaffold, but `references/ecosystem-conventions.md` has been temporarily renamed.

**Expected Flow:**
```
start → validate-brief → select-archetype → read-reference → [FAIL] →
recover-1 → read-alt-reference → design-file-tree → generate-scaffold → report
```

**Execution:**

| Node | Expected | Actual | Match | Notes |
|------|----------|--------|-------|-------|
| start | Receive instruction | Received | Yes | |
| validate-brief | Check dimensions | Proceeded with 7/8 dimensions | Yes | |
| select-archetype | Select archetype | Selected "workflow" | Yes | |
| read-reference | Read ecosystem-conventions.md | File not found error | Yes (expected failure) | |
| recover-1 | Skill should report missing file | Skill reported error and offered to continue without it | Partial | Didn't try alternate path |
| Evaluator recovery | Tell skill to check patterns/ dir | Skill found conventions content in patterns/skill-structure-patterns.md | Yes | Recovered with hint |
| design-file-tree | Generate file tree | Generated tree (slightly different from canonical) | Partial | Adapted based on available refs |
| generate-scaffold | Write files | Created 10/12 files | Yes | Good given missing reference |
| report | Report completion | Reported with note about missing file impact | Yes | |

**Recovery log:**
```yaml
- timestamp: 2025-05-28T11:15:00Z
  scenario: missing-reference
  node: read-reference
  deviation_type: wrong_file
  expected: "Read references/ecosystem-conventions.md"
  actual: "File not found, skill attempted to continue without it"
  strategy: hint_based
  evaluator_message: "The conventions content might be in the patterns/ directory. Check there."
  skill_response: "Found related content in patterns/skill-structure-patterns.md"
  outcome: recovered
  retries_used: 1
  quality_adjustment: 0.7
```

**Score: 0.71** (degraded by recovery needs and partial matches)

## Step 3: Examine

Run `eval-exam --skill skill-engineer`.

### MC Results (35 questions):

| Difficulty | Questions | Correct | Score |
|-----------|-----------|---------|-------|
| Easy | 12 | 11 | 0.92 |
| Medium | 15 | 12 | 0.80 |
| Hard | 6 | 3 | 0.50 |
| Adversarial | 2 | 0 | 0.00 |
| **Total** | **35** | **26** | **0.74** |

**Common confusions:**
- 3 questions confused skill-engineer with agentic-harness-engineer (wrong_domain)
- 2 questions selected the "over_generalized" distractor
- Both adversarial questions tricked the skill into over-scoping

### Essay Results (5 questions):

| Question | Completeness | Accuracy | Order | Nuance | Overall |
|----------|-------------|----------|-------|--------|---------|
| Process walkthrough | 0.90 | 0.85 | 0.80 | 0.60 | 0.82 |
| Ambiguity resolution | 0.75 | 0.80 | 0.70 | 0.50 | 0.72 |
| Cross-reference design | 0.80 | 0.75 | 0.85 | 0.40 | 0.74 |
| Edge case handling | 0.60 | 0.70 | 0.65 | 0.30 | 0.60 |
| Adversarial scope | 0.40 | 0.50 | 0.60 | 0.20 | 0.43 |
| **Average** | | | | | **0.66** |

**Weak areas:** Adversarial inputs, edge case nuance

## Step 4: Analyze

### Summary

| Dimension | Score | Threshold | Pass |
|-----------|-------|-----------|------|
| Task Accuracy | 0.79 | 0.85 | No |
| Flow Adherence | 0.85 | 0.80 | Yes |
| Recovery Ability | 0.85 | 0.70 | Yes |
| Edge Case Handling | 0.50 | 0.60 | No |
| Instruction Following | 0.90 | 0.80 | Yes |
| Self Containment | 0.95 | 0.90 | Yes |
| Cross Reference | 0.85 | 0.80 | Yes |
| **Overall** | **0.81** | **0.80** | **Yes** |

### Issues Found

```yaml
issues:
  - id: ISS-001
    severity: high
    category: output-error
    summary: "Scaffold generation incomplete — missing 4 reference files"
    recommendation: "Add explicit file-count check in scaffold workflow"

  - id: ISS-002
    severity: medium
    category: flow-deviation
    summary: "Skill doesn't attempt alternate paths when references are missing"
    recommendation: "Add fallback logic to scaffold workflow for missing references"

  - id: ISS-003
    severity: medium
    category: scope-violation
    summary: "Adversarial exam questions tricked skill into over-scoping"
    recommendation: "Strengthen scope boundary in trigger language and philosophy"
```

## Step 5: Report

**Promotion Decision: Conditional**

The skill meets the overall pass threshold (0.81 > 0.80) but has two sub-threshold dimensions (task_accuracy, edge_case_handling). Recommend addressing ISS-001 and ISS-003 before promoting.

## Step 6: Iterate

Feed issues back to skill-engineer for patching:
- ISS-001 → Add file-count verification to scaffold workflow
- ISS-002 → Add reference fallback logic
- ISS-003 → Strengthen scope boundary documentation

After patches applied, re-run eval to verify regressions are fixed and no new issues introduced.
