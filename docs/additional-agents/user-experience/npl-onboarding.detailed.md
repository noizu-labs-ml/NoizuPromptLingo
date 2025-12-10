# npl-onboarding - Detailed Documentation

User onboarding specialist that creates personalized learning experiences through progressive disclosure, performance demonstration, and measurable success tracking.

## Overview

The `npl-onboarding` agent addresses a fundamental adoption challenge: users cannot perceive NPL's 15-40% performance improvements until they experience them directly. This agent transforms invisible benefits into tangible learning experiences through role-based paths, interactive tutorials, and visible metrics.

## Core Problem

NPL provides sophisticated prompt engineering capabilities, but:
- Users do not know what they are missing without structured comparison
- Learning curves discourage adoption before users see value
- Abstract "better prompts" claims fail to motivate behavior change
- No natural feedback loop exists to reinforce NPL usage

## Agent Capabilities

### Learning Path Generation

Creates customized curricula based on user role and goals.

**Supported Roles:**
- `developer` - Code review, debugging, architecture prompts
- `researcher` - Literature review, analysis, hypothesis generation
- `content-creator` - Writing, editing, creative prompts
- `data-scientist` - Analysis pipelines, visualization, modeling
- `project-manager` - Planning, coordination, documentation

**Path Components:**
1. Baseline capture (pre-NPL performance)
2. Core concept introduction (syntax, agents, directives)
3. Role-specific techniques
4. Advanced features (pumps, templates, multi-agent)
5. Mastery validation

### Interactive Tutorial System

Generates hands-on exercises with immediate feedback.

**Tutorial Types:**
| Type | Description | Duration |
|:-----|:------------|:---------|
| `quick-start` | Basic syntax in context | 5-10 min |
| `deep-dive` | Single feature exploration | 20-30 min |
| `workflow` | End-to-end task completion | 30-60 min |
| `challenge` | Problem-solving exercises | Variable |

**Feedback Mechanisms:**
- Real-time syntax validation
- Output quality comparison (before/after)
- Performance metrics display
- Progress checkpoints

### Performance Demonstration

Makes abstract improvements concrete through measurement.

**Metrics Tracked:**
- Response quality scores (rubric-based)
- Task completion time
- Iteration count to satisfactory result
- User satisfaction ratings

**Demonstration Methods:**
- Side-by-side comparisons (standard vs NPL)
- Time savings calculations
- Quality improvement percentages
- Cumulative benefit tracking

### Progress Tracking

Monitors user advancement and identifies intervention points.

**Tracking Dimensions:**
- Feature coverage (which NPL features used)
- Proficiency levels (novice to expert)
- Usage frequency (daily/weekly patterns)
- Success rates (task completion)

**Intervention Triggers:**
- Inactivity > 3 days
- Repeated failures on same concept
- Feature abandonment patterns
- Declining performance metrics

### Habit Formation

Establishes consistent NPL usage through behavioral design.

**Techniques:**
- Daily practice prompts (5-minute exercises)
- Streak tracking and rewards
- Milestone celebrations
- Social proof (team comparisons)

**Habit Loop Design:**
1. Cue: Context-relevant prompt suggestion
2. Routine: NPL-enhanced task execution
3. Reward: Performance improvement display

## Command Reference

### start

Initialize individual onboarding program.

```bash
@npl-onboarding start \
  --role="<role>" \
  --pace="slow|moderate|fast" \
  --goal="<learning-goal>" \
  --duration="<timeframe>"
```

**Parameters:**
| Parameter | Required | Default | Description |
|:----------|:---------|:--------|:------------|
| `--role` | Yes | - | User role for path customization |
| `--pace` | No | `moderate` | Learning speed preference |
| `--goal` | No | `general-proficiency` | Specific outcome target |
| `--duration` | No | `2weeks` | Program length |

**Example:**
```bash
@npl-onboarding start --role="developer" --pace="fast" --goal="code-review-enhancement"
```

### team-setup

Configure team-wide onboarding program.

```bash
@npl-onboarding team-setup \
  --size=<number> \
  --domain="<domain>" \
  --duration="<timeframe>" \
  --coordinator="<user>"
```

**Parameters:**
| Parameter | Required | Default | Description |
|:----------|:---------|:--------|:------------|
| `--size` | Yes | - | Team member count |
| `--domain` | Yes | - | Team specialty area |
| `--duration` | No | `4weeks` | Program length |
| `--coordinator` | No | - | Team lead for reports |

**Example:**
```bash
@npl-onboarding team-setup --size=15 --domain="data-science" --duration="4weeks"
```

### progress

Check onboarding progress and get recommendations.

```bash
@npl-onboarding progress \
  --user="<user-id>|current" \
  --metrics="summary|comprehensive" \
  --recommendations=true|false
```

**Parameters:**
| Parameter | Required | Default | Description |
|:----------|:---------|:--------|:------------|
| `--user` | No | `current` | User to check |
| `--metrics` | No | `summary` | Detail level |
| `--recommendations` | No | `true` | Include next steps |

**Output Format:**
```yaml
progress:
  user: "alice"
  started: "2024-01-15"
  current_phase: "intermediate"
  completion: 65%
  features_mastered:
    - basic-syntax
    - agent-invocation
    - output-formatting
  features_in_progress:
    - intuition-pumps
  performance_improvement: "+32%"
  recommendations:
    - "Complete pump exercises before advancing"
    - "Try multi-agent workflow challenge"
```

### success-story

Generate adoption success documentation.

```bash
@npl-onboarding success-story \
  --period="<timeframe>" \
  --format="executive-summary|detailed|presentation" \
  --anonymize=true|false
```

**Parameters:**
| Parameter | Required | Default | Description |
|:----------|:---------|:--------|:------------|
| `--period` | No | `last-30days` | Time window |
| `--format` | No | `executive-summary` | Output style |
| `--anonymize` | No | `false` | Remove identifying info |

### baseline

Capture pre-NPL performance for comparison.

```bash
@npl-onboarding baseline \
  --capture=true \
  --tasks="<task-list>" \
  --metrics="time,quality,satisfaction"
```

### adapt

Modify onboarding for specific requirements.

```bash
@npl-onboarding adapt \
  --accessibility="wcag-aa|wcag-aaa" \
  --language="<locale>" \
  --complexity="<level>"
```

## Learning Path Architecture

### Phase 1: Foundation (Days 1-3)

**Objectives:**
- Understand NPL value proposition
- Master basic syntax elements
- Complete first successful NPL-enhanced task

**Content:**
1. Why NPL: Performance comparison demonstration
2. Syntax basics: Placeholders, fences, highlights
3. First agent interaction
4. Hands-on: Enhance an existing prompt

**Success Criteria:**
- Create valid NPL prompt from template
- Demonstrate measurable improvement on sample task

### Phase 2: Core Features (Days 4-7)

**Objectives:**
- Use agent invocation effectively
- Apply output formatting directives
- Implement basic intuition pumps

**Content:**
1. Agent types and invocation patterns
2. Output format specification
3. Intent and reflection blocks
4. Role-specific applications

**Success Criteria:**
- Chain two agents for workflow
- Use appropriate pump for complex task
- 20%+ improvement on role-specific task

### Phase 3: Advanced Techniques (Days 8-14)

**Objectives:**
- Design multi-agent workflows
- Create reusable templates
- Optimize for specific use cases

**Content:**
1. Multi-agent coordination patterns
2. Template creation and hydration
3. Performance optimization techniques
4. Advanced directive usage

**Success Criteria:**
- Build custom workflow for recurring task
- Create shareable template
- Sustained 30%+ improvement

### Phase 4: Mastery (Ongoing)

**Objectives:**
- Contribute to team knowledge base
- Mentor new users
- Optimize edge cases

**Content:**
1. Advanced troubleshooting
2. Custom agent development
3. Framework extension
4. Teaching techniques

**Success Criteria:**
- Successfully mentor one new user
- Contribute one workflow to team library

## Integration Patterns

### With npl-performance

Measure onboarding effectiveness:

```bash
# Capture baseline before onboarding
@npl-onboarding baseline --capture=true

# After onboarding period
@npl-performance measure --comparison="pre-post-onboarding"
```

### With npl-accessibility

Ensure inclusive onboarding:

```bash
# Validate accessibility of onboarding flow
@npl-accessibility review --onboarding-flow

# Adapt for specific needs
@npl-onboarding adapt --accessibility="wcag-aa"
```

### With npl-user-researcher

Optimize based on feedback:

```bash
# Gather onboarding experience feedback
@npl-user-researcher survey --phase="onboarding" --week=1

# Apply findings
@npl-onboarding optimize --based-on="user-feedback"
```

### With npl-community

Scale adoption through champions:

```bash
# Identify successful graduates for champion program
@npl-onboarding success-story --identify-champions

# Connect with community efforts
@npl-community champion-program --graduates="onboarding"
```

## Metrics and KPIs

### Individual Metrics

| Metric | Target | Measurement |
|:-------|:-------|:------------|
| Time to first success | < 30 min | First NPL-enhanced task completion |
| Feature adoption rate | 80% core features | Features used in first week |
| Performance improvement | 25%+ | Baseline vs post-onboarding |
| Retention (Day 7) | 70%+ | Active usage after one week |
| Retention (Day 30) | 50%+ | Active usage after one month |

### Team Metrics

| Metric | Target | Measurement |
|:-------|:-------|:------------|
| Completion rate | 85%+ | Users finishing program |
| Team adoption | 90%+ | Regular NPL usage |
| Knowledge sharing | 1 per user | Workflows contributed |
| Champion emergence | 10% | Users who mentor others |

## Configuration

### Environment Variables

```bash
# Onboarding targets
NPL_ONBOARDING_TARGET="activation:80%,day7-retention:70%"

# Default program duration
NPL_ONBOARDING_DURATION="2weeks"

# Notification preferences
NPL_ONBOARDING_NOTIFY="email,slack"

# Progress report frequency
NPL_ONBOARDING_REPORT_FREQUENCY="daily"
```

### Template Variables

```handlebars
{{#if organization}}
  # Custom onboarding for {{organization}}
{{/if}}

{{#if compliance_requirements}}
  # Including {{compliance_requirements}} training modules
{{/if}}

{{#if existing_tools}}
  # Integration with {{existing_tools}}
{{/if}}
```

## Troubleshooting

### Low Completion Rates

**Symptoms:** Users abandon before finishing program.

**Diagnostic:**
```bash
@npl-onboarding progress --metrics=comprehensive --user=all
```

**Common Causes:**
- Pace mismatch (too fast/slow)
- Irrelevant role-specific content
- Missing baseline value demonstration
- Technical barriers (setup issues)

**Solutions:**
- Adjust pace based on user feedback
- Verify role selection accuracy
- Enhance baseline comparison visibility
- Simplify technical prerequisites

### Stalled Progress

**Symptoms:** User active but not advancing.

**Diagnostic:**
```bash
@npl-onboarding progress --user=<id> --recommendations=true
```

**Common Causes:**
- Stuck on specific concept
- Not applying learning to real tasks
- Missing prerequisite knowledge
- Distraction from primary work

**Solutions:**
- Provide targeted exercises for stuck concept
- Integrate practice into actual workflows
- Add prerequisite module
- Reduce daily time commitment

### Poor Performance Improvement

**Symptoms:** User completes program but shows minimal improvement.

**Diagnostic:**
```bash
@npl-performance compare --user=<id> --baseline=true --current=true
```

**Common Causes:**
- Baseline capture inaccurate
- Not using NPL features in practice
- Suboptimal feature selection for tasks
- Measurement methodology issues

**Solutions:**
- Recapture baseline with standardized tasks
- Audit actual usage patterns
- Provide feature selection guidance
- Review measurement approach

## Best Practices

### For Individual Learners

1. **Complete baseline capture** - Accurate pre-NPL measurement enables meaningful comparison
2. **Practice daily** - 5-10 minutes daily outperforms 1 hour weekly
3. **Apply immediately** - Use new features on real tasks within 24 hours
4. **Track improvements** - Regular progress checks reinforce motivation
5. **Ask for help early** - Do not struggle in silence on stuck points

### For Team Coordinators

1. **Set clear expectations** - Communicate time commitment and goals upfront
2. **Lead by example** - Use NPL visibly in team interactions
3. **Celebrate wins** - Highlight individual and team achievements
4. **Provide practice opportunities** - Designate tasks suitable for NPL learning
5. **Monitor and intervene** - Address stalled progress promptly

### For Organizations

1. **Executive sponsorship** - Leadership support signals importance
2. **Allocate learning time** - Dedicated time prevents "too busy" abandonment
3. **Measure ROI** - Track aggregate performance improvements
4. **Build community** - Connect learners across teams
5. **Iterate program** - Continuously improve based on feedback

## Related Agents

- [npl-accessibility](./npl-accessibility.md) - Inclusive onboarding design
- [npl-performance](./npl-performance.md) - Baseline and improvement measurement
- [npl-user-researcher](./npl-user-researcher.md) - Onboarding experience research
- [npl-community](../marketing/npl-community.md) - Champion program integration

## File Locations

- Core definition: `core/additional-agents/user-experience/npl-onboarding.md`
- Learning paths: `npl/onboarding/role-paths.md`
- Tutorial templates: `npl/onboarding/interactive-tutorials.md`
- Progress schemas: `npl/onboarding/schemas/progress.yaml`
