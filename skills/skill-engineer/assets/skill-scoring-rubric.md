# Skill Scoring Rubric

Quality scoring template for evaluating skills. Use after completing the quality checklist (`references/quality-checklist.md`).

---

## Skill Under Review

- **Name**: ___
- **Date**: ___
- **Reviewer**: ___
- **Version**: ___

## Scoring

Rate each criterion 1-10. Multiply by weight for weighted score.

| # | Criterion | Weight | Score (1-10) | Weighted |
|---|-----------|--------|-------------|----------|
| 1 | Trigger Precision | 15% | ___ | ___ |
| 2 | Reference Depth | 20% | ___ | ___ |
| 3 | Worked Example Quality | 20% | ___ | ___ |
| 4 | Structural Compliance | 15% | ___ | ___ |
| 5 | Cross-Reference Accuracy | 10% | ___ | ___ |
| 6 | Self-Containment | 10% | ___ | ___ |
| 7 | Agent Playbook Quality | 10% | ___ | ___ |
| | **Weighted Total** | **100%** | | **___** |

**Minimum passing: 7.0 / 10. Target: 8.5+ / 10.**

---

## Evidence

### 1. Trigger Precision (15%)

**What to evaluate**: Does the frontmatter description catch all intended use cases without false positives?

| Test Scenario | Should Match? | Does Match? | Pass? |
|--------------|--------------|-------------|-------|
| ___ | Yes | ___ | ___ |
| ___ | Yes | ___ | ___ |
| ___ | Yes | ___ | ___ |
| ___ | No | ___ | ___ |
| ___ | No | ___ | ___ |

**Scoring guide:**
- 9-10: Catches 95%+ of intended cases, zero false positives
- 7-8: Catches 80%+ of intended cases, rare false positives
- 5-6: Misses common oblique requests OR has noticeable false positives
- 3-4: Significant gaps in coverage or frequent false positives
- 1-2: Description is generic or barely functional

**Evidence notes**: ___

### 2. Reference Depth (20%)

**What to evaluate**: Do references add genuine value beyond SKILL.md? Are they substantive or padding?

| Reference File | Adds Value? | Substantive? | Notes |
|---------------|------------|-------------|-------|
| ___ | ___ | ___ | ___ |
| ___ | ___ | ___ | ___ |

**Scoring guide:**
- 9-10: Every reference is essential; comprehensive domain coverage
- 7-8: Most references add clear value; minor gaps in coverage
- 5-6: Some references feel thin or redundant
- 3-4: Multiple references are stubs or add little beyond SKILL.md
- 1-2: References are mostly placeholders

**Evidence notes**: ___

### 3. Worked Example Quality (20%)

**What to evaluate**: Is the worked example realistic, end-to-end, and non-trivial?

- [ ] Example covers a realistic scenario (not contrived)
- [ ] Example is end-to-end (input → process → output)
- [ ] Example demonstrates the skill's primary workflow
- [ ] Example includes decision points and trade-offs
- [ ] Example would help a new user understand the skill

**Scoring guide:**
- 9-10: Multiple examples covering main path and edge cases; feels like real work
- 7-8: One solid end-to-end example; realistic and instructive
- 5-6: Example exists but is incomplete or overly simplified
- 3-4: Example is a stub or too contrived to be useful
- 1-2: No worked example or completely unrealistic

**Evidence notes**: ___

### 4. Structural Compliance (15%)

**What to evaluate**: Does the skill follow the canonical format?

- [ ] All 11 required SKILL.md sections present
- [ ] YAML frontmatter valid with name + description
- [ ] Directory structure matches canonical layout
- [ ] Naming conventions followed (kebab-case, title case)
- [ ] agent-playbook.claude-code.md exists
- [ ] project-tracker.md in assets/

**Scoring guide:**
- 9-10: Perfect compliance; follows UXE exemplar formatting
- 7-8: All required elements present; minor formatting deviations
- 5-6: Missing 1-2 required sections or files
- 3-4: Missing multiple required elements
- 1-2: Skill doesn't follow the canonical format

**Evidence notes**: ___

### 5. Cross-Reference Accuracy (10%)

**What to evaluate**: Are all links valid and cross-references advisory?

- [ ] All blockquote references point to existing files
- [ ] All Bundled Resources entries point to existing files
- [ ] Cross-references are advisory (no hard dependencies)
- [ ] Related Skills descriptions are accurate

**Scoring guide:**
- 9-10: All links valid; cross-references add context; no dead links
- 7-8: All links valid; descriptions could be more specific
- 5-6: 1-2 dead links or inaccurate descriptions
- 3-4: Multiple dead links or misleading cross-references
- 1-2: Cross-references are broken or create hard dependencies

**Evidence notes**: ___

### 6. Self-Containment (10%)

**What to evaluate**: Does the skill function without other skills loaded?

- [ ] SKILL.md works standalone (Claude Teams test)
- [ ] No hard imports from other skills
- [ ] Graceful suggestions when related skills unavailable

**Scoring guide:**
- 9-10: Fully standalone; cross-refs are pure suggestions
- 7-8: Works standalone; one or two implicit assumptions
- 5-6: Mostly standalone; some content assumes other skills exist
- 3-4: Relies on other skills for core functionality
- 1-2: Breaks without other skills loaded

**Evidence notes**: ___

### 7. Agent Playbook Quality (10%)

**What to evaluate**: Is the agent playbook actionable and complete?

- [ ] Role definition has all required fields
- [ ] 3+ workflows with triggers, steps, and output templates
- [ ] Workflows cover primary use cases
- [ ] Constraints are realistic and enforceable

**Scoring guide:**
- 9-10: 5+ workflows; YAML steps are detailed and actionable; constraints are sharp
- 7-8: 3-4 workflows; solid role definition; most constraints clear
- 5-6: 2 workflows; role definition present but thin
- 3-4: 1 workflow or playbook is mostly a stub
- 1-2: No agent playbook or non-functional

**Evidence notes**: ___

---

## Summary

| Result | Criteria |
|--------|----------|
| **Ship** | Weighted total ≥ 7.0, no criterion below 5.0 |
| **Revise** | Weighted total 5.0-6.9, or any criterion below 5.0 |
| **Redesign** | Weighted total < 5.0, or 3+ criteria below 5.0 |

**Decision**: ___

**Top improvements needed**:
1. ___
2. ___
3. ___
