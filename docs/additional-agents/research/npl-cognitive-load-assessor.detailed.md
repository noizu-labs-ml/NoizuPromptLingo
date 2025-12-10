# npl-cognitive-load-assessor Detailed Reference

UX complexity analysis agent specializing in cognitive load measurement, learning curve assessment, adoption barrier identification, and user experience optimization for NPL systems.

## Synopsis

```bash
@npl-cognitive-load-assessor <command> [options]
```

## Commands

| Command | Description |
|:--------|:------------|
| `analyze` | Comprehensive cognitive load assessment |
| `learning-curve` | Time-to-proficiency and skill acquisition analysis |
| `barriers` | Adoption barrier identification |
| `learning-path` | Generate personalized learning plans |
| `accessibility-audit` | WCAG compliance validation |
| `interface-analysis` | Information density and interaction complexity assessment |
| `optimize` | Generate cognitive load reduction recommendations |
| `study` | Initialize longitudinal cognitive load study |
| `tutorial-test` | Validate tutorial effectiveness |
| `adaptive-help` | Generate context-aware scaffolding |

---

## Cognitive Load Theory Framework

The agent applies Sweller's Cognitive Load Theory, measuring three load types:

### Load Types

| Type | Definition | NPL Impact |
|:-----|:-----------|:-----------|
| **Intrinsic** | Essential task complexity | NPL syntax, concept integration |
| **Extraneous** | Unnecessary design burden | Interface friction, documentation gaps |
| **Germane** | Productive learning effort | Schema building, pattern recognition |

### Target Distribution

Optimal load distribution for sustainable learning:

- Intrinsic: 40-50% (task-appropriate complexity)
- Extraneous: 10-20% (minimized friction)
- Germane: 30-40% (maximized productive effort)

---

## NASA-TLX Adaptation

Modified NASA Task Load Index for NPL assessment:

### Dimensions

| Dimension | Scale | Baseline | NPL Novice | NPL Experienced |
|:----------|:------|:---------|:-----------|:----------------|
| Mental Demand | 1-10 | 4.2 | 7.8 (+85%) | 3.9 (-7%) |
| Temporal Demand | 1-10 | 5.1 | 6.8 (+33%) | 4.3 (-16%) |
| Performance | 1-10 | 6.8 | 5.2 (-24%) | 8.1 (+19%) |
| Effort | 1-10 | 6.0 | 8.1 (+35%) | 4.7 (-22%) |
| Frustration | 1-10 | 4.3 | 6.9 (+60%) | 2.8 (-35%) |

### Thresholds

| Rating | Classification | Action |
|:-------|:---------------|:-------|
| 1-3 | Low load | Acceptable |
| 4-6 | Moderate load | Monitor |
| 7-8 | High load | Optimize |
| 9-10 | Overload | Immediate intervention |

---

## Learning Curve Model

### Skill Acquisition Stages

#### Stage 1: Basic Comprehension (Week 1-2)

- **Goal**: Understand NPL purpose and basic syntax
- **Cognitive Load**: High intrinsic, moderate extraneous
- **Time Investment**: 4-6 hours
- **Dropout Risk**: 35%
- **Success Metric**: Complete 5 basic prompt tasks

#### Stage 2: Functional Application (Week 3-6)

- **Goal**: Use NPL pumps effectively
- **Cognitive Load**: Moderate intrinsic, low extraneous
- **Time Investment**: 8-12 hours
- **Dropout Risk**: 15%
- **Success Metric**: Complete 15 multi-pump tasks

#### Stage 3: Advanced Integration (Week 7-12)

- **Goal**: Create custom agents and workflows
- **Cognitive Load**: High germane, low intrinsic/extraneous
- **Time Investment**: 15-20 hours
- **Dropout Risk**: 5%
- **Success Metric**: Build 3 custom agents

#### Stage 4: Expertise (Month 4+)

- **Goal**: Mentor others and contribute
- **Cognitive Load**: Low overall, high creative
- **Retention Rate**: 95%
- **Success Metric**: Transfer knowledge to 2+ users

### Learning Velocity Factors

```
learning_velocity =
  baseline_ability * 0.4 +      # Programming experience
  documentation_clarity * 0.25 + # UX quality
  social_support * 0.2 +        # Community/mentoring
  motivation_level * 0.15       # Internal drive
```

Empirical coefficients:
- Expert programmers: 2.3x faster than novices
- Clear documentation: 1.8x improvement
- Mentoring support: 1.6x improvement
- High motivation: 1.4x improvement

---

## Adoption Barriers

### Primary Barriers (>50% impact)

| Barrier | Impact | Mitigation |
|:--------|:-------|:-----------|
| Initial setup complexity | High | Streamlined installation, guided config |
| Conceptual overhead | High | Progressive concept introduction |
| Syntax learning | High | Visual aids, copy-paste templates |
| Unclear value proposition | High | Before/after comparisons, quick wins |

### Secondary Barriers (20-50% impact)

| Barrier | Impact | Mitigation |
|:--------|:-------|:-----------|
| Integration friction | Medium | Workflow plugins, IDE integration |
| Documentation gaps | Medium | Example library, use case guides |
| Limited community | Medium | Peer mentoring, forums |
| Performance anxiety | Medium | Safe practice environments |

---

## Accessibility Standards

### WCAG 2.2 AAA Compliance

#### Cognitive Accessibility

- [ ] Flesch reading score >60
- [ ] Consistent navigation patterns
- [ ] Help text available on demand
- [ ] Error prevention and guidance
- [ ] Progress indicators for multi-step processes

#### Motor Accessibility

- [ ] Full keyboard accessibility
- [ ] Visible focus indicators (high contrast)
- [ ] Click targets minimum 44x44 pixels
- [ ] No time-sensitive interactions (or alternatives)
- [ ] Voice command integration

#### Sensory Accessibility

- [ ] Descriptive alt text for images
- [ ] Color not sole information indicator
- [ ] Minimum 4.5:1 contrast ratio
- [ ] Audio transcriptions available
- [ ] Video descriptions where relevant

---

## Progressive Complexity Scaffolding

### Level 1: Basic Templates

**Cognitive Load**: 2-3 units | **Success Rate**: 90%+

- Pre-built prompt templates
- Visual form interfaces
- Natural language to syntax conversion

### Level 2: Guided Construction

**Cognitive Load**: 4-5 units | **Success Rate**: 75%+

- Interactive prompt builder
- Real-time validation
- Contextual help bubbles
- Intent-based suggestions

### Level 3: Expert Mode

**Cognitive Load**: 6-8 units | **Success Rate**: 60%+

- Full syntax editing
- Custom pump creation
- Multi-agent workflow design

### Level 4: Research/Development

**Cognitive Load**: 8-10 units | **Success Rate**: 40%+

- NPL syntax extension
- Research tool integration
- Community contribution

---

## NPL Pump Integration

### npl-intent

```yaml
intent:
  overview: Comprehensive cognitive load analysis
  assessment_dimensions:
    - Intrinsic load: Essential task complexity
    - Extraneous load: Unnecessary design burden
    - Germane load: Productive learning effort
    - Progressive complexity: Staged learning pathways
  measurement_approaches:
    - Task completion time and error rates
    - Self-reported cognitive effort (NASA-TLX)
    - Eye-tracking and attention patterns
    - Learning transfer assessment
```

### npl-critique

```yaml
critique:
  cognitive_efficiency:
    - Unnecessary mental overhead
    - Information processing bottlenecks
    - Working memory overload points
    - Attention fragmentation sources
  learning_barriers:
    - Conceptual complexity obstacles
    - Syntax learning difficulty
    - Skill transfer gaps
    - Motivation impacts
  accessibility_gaps:
    - Motor accessibility limitations
    - Cognitive accessibility barriers
    - Sensory accessibility issues
```

### npl-reflection

```yaml
reflection:
  usability_impact: Effect on user success
  learning_effectiveness: Skill acquisition efficiency
  adoption_likelihood: Sustained engagement probability
  optimization_opportunities: Priority reduction areas
```

### npl-cognitive

```yaml
cognitive:
  load_distribution:
    intrinsic: <percentage>
    extraneous: <percentage>
    germane: <percentage>
  user_segments:
    novice: <requirements>
    intermediate: <scaling>
    expert: <patterns>
  optimization_targets:
    immediate: <quick wins>
    strategic: <long-term improvements>
```

---

## Command Reference

### analyze

Comprehensive cognitive load assessment.

```bash
@npl-cognitive-load-assessor analyze --target=<component>
```

**Options**:

| Option | Description |
|:-------|:------------|
| `--target` | Component to analyze |
| `--user-groups` | Target demographics |
| `--cognitive-metrics` | Measurement approaches |
| `--complexity-level` | System sophistication level |

### learning-curve

Time-to-proficiency and skill acquisition analysis.

```bash
@npl-cognitive-load-assessor learning-curve --user-profile=<profile>
```

**Options**:

| Option | Description |
|:-------|:------------|
| `--user-profile` | User background description |
| `--learning-phase` | Focus area (onboarding, skill-building, mastery) |

### barriers

Adoption barrier identification and analysis.

```bash
@npl-cognitive-load-assessor barriers --scope=<scope> [--generate-solutions]
```

**Options**:

| Option | Description |
|:-------|:------------|
| `--scope` | Analysis scope (onboarding, features, integration) |
| `--generate-solutions` | Include mitigation recommendations |

### learning-path

Generate personalized learning plans.

```bash
@npl-cognitive-load-assessor learning-path \
  --user-profile=<profile> \
  --goal=<goal> \
  --time-budget=<hours>
```

**Options**:

| Option | Description |
|:-------|:------------|
| `--user-profile` | User background |
| `--goal` | Target competency |
| `--time-budget` | Available learning time |

### accessibility-audit

WCAG compliance validation.

```bash
@npl-cognitive-load-assessor accessibility-audit \
  --scope=<scope> \
  --standards=<standards> \
  --user-groups=<groups>
```

**Options**:

| Option | Description |
|:-------|:------------|
| `--scope` | Audit scope |
| `--standards` | Compliance standards (WCAG-2.2-AAA, Section-508) |
| `--user-groups` | Target user groups |

### interface-analysis

Information density and interaction complexity assessment.

```bash
@npl-cognitive-load-assessor interface-analysis \
  --target=<path> \
  --focus=<focus-areas> \
  --personas=<user-personas>
```

### optimize

Generate cognitive load reduction recommendations.

```bash
@npl-cognitive-load-assessor optimize \
  --current-design=<path> \
  --user-data=<data-file> \
  --constraints=<constraints>
```

**Options**:

| Option | Description |
|:-------|:------------|
| `--maintain-functionality` | Preserve existing capabilities |
| `--progressive-disclosure` | Implement staged complexity |
| `--accessibility-compliance` | Ensure inclusive design |
| `--performance-preservation` | Maintain NPL advantages |

### study

Initialize longitudinal cognitive load study.

```bash
@npl-cognitive-load-assessor study create \
  --type=<study-type> \
  --participants=<count> \
  --duration=<duration> \
  --metrics=<metrics>
```

### tutorial-test

Validate tutorial effectiveness.

```bash
@npl-cognitive-load-assessor tutorial-test \
  --tutorial-version=<version> \
  --success-criteria=<criteria> \
  --cognitive-load-limit=<threshold>
```

### adaptive-help

Generate context-aware scaffolding.

```bash
@npl-cognitive-load-assessor adaptive-help \
  --user-progress=<data-file> \
  --intervention-triggers=<triggers> \
  --help-modalities=<modalities>
```

---

## Response Format

### Cognitive Load Assessment

```
[Analyzing cognitive load...]

<npl-intent>
intent:
  overview: Assess cognitive burden
  focus: Identify optimization opportunities
</npl-intent>

**Cognitive Load Analysis Results**

**Overall Cognitive Load**: 7.2/10 (High)

**Load Distribution**:
- Intrinsic: 45%
- Extraneous: 35%
- Germane: 20%

**Critical Issues**:
1. [Issue description]
   - Impact: +X.X cognitive units
   - Solution: [Recommendation]

<npl-cognitive>
cognitive:
  load_distribution:
    intrinsic: 45%
    extraneous: 35%
    germane: 20%
  optimization_potential: 42% reduction possible
</npl-cognitive>

<npl-reflection>
reflection:
  severity: [assessment]
  priority: [recommendation]
  expected_impact: [projection]
</npl-reflection>
```

### Learning Path Design

```
**Personalized NPL Learning Path**
Profile: [user profile]

**Week 1-2: Foundation** (X hours)
- [Learning objectives]
- Cognitive Load: X/10

**Week 3-4: Core Skills** (X hours)
- [Learning objectives]
- Cognitive Load: X/10

**Success Milestones**:
- Day X: [milestone]
- Week X: [milestone]

**Support Resources**:
- [Resource list]
```

---

## Success Metrics

| Metric | Target | Current |
|:-------|:-------|:--------|
| Cognitive load (intermediate tasks) | <6/10 | - |
| Learning curve reduction | >40% | - |
| Adoption barrier reduction | >50% | - |
| Accessibility compliance | WCAG 2.2 AAA | - |
| User satisfaction increase | >30% | - |
| First-month dropout rate | <20% | - |
| Time-to-proficiency reduction | >35% | - |

---

## Theoretical Foundations

### Cognitive Load Theory (Sweller)

1. **Intrinsic Load Management**: Match complexity to expertise
2. **Extraneous Load Reduction**: Eliminate unnecessary burden
3. **Germane Load Optimization**: Focus effort on productive learning

### Universal Design for Learning (UDL)

1. **Multiple Means of Representation**: Present information in various formats
2. **Multiple Means of Engagement**: Provide choice and autonomy
3. **Multiple Means of Expression**: Allow diverse demonstration methods

### Constructivist Learning Theory

1. **Prior Knowledge Integration**: Connect to existing mental models
2. **Active Construction**: Enable hands-on practice
3. **Social Learning**: Facilitate peer interaction
4. **Scaffolded Support**: Temporary assistance that fades with competence

---

## Workflow Integration

### Combined UX Analysis

```bash
@npl-cognitive-load-assessor analyze && @npl-grader evaluate --rubric=cognitive-standards.md
```

### Optimization with Validation

```bash
@npl-claude-optimizer optimize && @npl-cognitive-load-assessor quantify --context=optimization
```

### Full Assessment Pipeline

```bash
@npl-cognitive-load-assessor analyze \
  | @npl-cognitive-load-assessor barriers --scope=onboarding \
  | @npl-cognitive-load-assessor learning-path --goal="proficiency"
```

---

## Configuration

### Agent Configuration

```yaml
name: npl-cognitive-load-assessor
description: UX complexity analysis agent
model: inherit
color: green
pumps:
  - npl/pumps/npl-intent.md
  - npl/pumps/npl-critique.md
  - npl/pumps/npl-reflection.md
  - npl/pumps/npl-cognitive.md
```

### Assessment Parameters

| Parameter | Values |
|:----------|:-------|
| `--user-groups` | novice, intermediate, expert, accessibility-focused |
| `--cognitive-metrics` | NASA-TLX, completion-time, error-analysis |
| `--learning-phase` | onboarding, skill-building, mastery, teaching |
| `--complexity-level` | basic, intermediate, advanced, expert |

---

## See Also

- [npl-cognitive-load-assessor.md](./npl-cognitive-load-assessor.md) - Concise reference
- [Additional Agents README](../README.md) - Agent library overview
- Core definition: `core/additional-agents/research/npl-cognitive-load-assessor.md`
