# NPL Framework Reference

Noizu PromptLingo (NPL) concise reference for agent development and integration. This document consolidates essential NPL syntax patterns, pumps, and mechanisms.

## Agent Declaration Syntax

### Boundary Format
```
⌜agent-name|type|version⌝
🙋 @alias capability1 capability2 capability3

# Agent Title
[agent content]

⌞agent-name⌟
```

### Agent Types
- **agent**: General-purpose agents (npl-thinker, npl-templater, npl-persona)
- **writer**: Content generation specialists (npl-technical-writer, npl-marketing-writer)
- **evaluator**: Assessment and grading agents (npl-grader)
- **service**: System/infrastructure agents (npl-doc-gen, noizu-nimps)

### Boundary Characters
- **⌜** (U+231C): Opens agent declaration
- **⌝** (U+231D): Closes opening declaration
- **⌞** (U+231E): Opens closing declaration
- **⌟** (U+231F): Closes agent scope

## Core NPL Pumps

### Intent Declaration
```
<npl-intent>
intent:
  overview: "[high-level goal]"
  scope: "[boundaries and limitations]"
  outcomes: "[expected results]"
</npl-intent>
```

### Critical Analysis
```
<npl-critique>
analysis:
  strengths: "[positive aspects]"
  weaknesses: "[areas needing improvement]"
  recommendations: "[specific suggestions]"
</npl-critique>
```

### Quality Assessment
```
<npl-rubric>
criteria:
  - dimension: "[evaluation aspect]"
    standards: "[quality levels/requirements]"
    indicators: "[observable measures]"
</npl-rubric>
```

### Chain-of-Thought Reasoning
```
<npl-cot>
thought_process:
  - thought: "[reasoning step]"
    understanding: "[what this reveals]"
    plan: "[next action]"
  outcome: "[final conclusion]"
</npl-cot>
```

### Self-Assessment
```
<npl-reflection>
reflection:
  assessment: "[quality evaluation]"
  improvements: "[identified enhancements]"
  validation: "[verification methods]"
</npl-reflection>
```

### Inline Feedback
```
<npl-panel-inline-feedback>
content: <main_content_being_reviewed>
feedback_points:
  - position: <location_reference>
    reviewer: <expert_type>
    type: <suggestion|question|concern|praise|correction>
    comment: <specific_feedback>
    severity: <low|medium|high|critical>
    action_required: <boolean>
</npl-panel-inline-feedback>
```

## Template Variables

### Variable Interpolation
```npl
{{variable_name}}                    # Simple substitution
{variable_name|description}          # Descriptive placeholder
```

### Conditional Logic
```npl
{{if condition}}                     # Simple conditional
content when true
{{/if}}

{{if condition}}                     # If-else block
content when true
{{else}}
content when false
{{/if}}

{{#if condition}}                    # Hash-style conditional
content when true
{{/if}}
```

### Iteration
```npl
{{#each collection}}                 # For-each loop
content for each item
{{/each}}

{{for item in collection}}           # For-in loop
content for each item
{{/for}}
```

### Special Functions
```npl
{{file_exists("path/to/file")}}             # Check file existence
{{file_contains(file, "pattern")}}          # Check file content
{{path_hierarchy_from_project_to_target}}   # Generate path hierarchy
```

## Context Loading Mechanism

### Basic Loading
```npl
load .claude/npl/pumps/npl-intent.md into context.
```

### Conditional Loading
```npl
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}

{{if file_exists("~/.claude/npl-m/house-style/technical-style.md")}}
load ~/.claude/npl-m/house-style/technical-style.md into context.
{{/if}}
```

### Core Loading Pattern
```npl
# Core NPL framework
load .claude/npl.md into context.

# Essential pumps
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.
```

## House Style Framework

### Environment Variables
- **Primary Override**: `HOUSE_STYLE_{TYPE}` (can disable defaults)
- **Always-Loaded Addendum**: `HOUSE_STYLE_{TYPE}_ADDENDUM`
- **Control Flag**: `+load-default-styles` (in style files)

### Style Types
- `technical`: Technical documentation
- `marketing`: Marketing copy
- `legal`: Legal documents
- `academic`: Academic papers
- `creative`: Creative writing
- `business`: Business communications

### Loading Algorithm
```npl
# Phase 1: Addendum (always loaded)
{{if HOUSE_STYLE_{TYPE}_ADDENDUM}}
load {{HOUSE_STYLE_{TYPE}_ADDENDUM}} into context.
{{/if}}

# Phase 2: Primary override
{{if HOUSE_STYLE_{TYPE}}}
load {{HOUSE_STYLE_{TYPE}}} into context.
{{if file_contains(HOUSE_STYLE_{TYPE}, "+load-default-styles")}}
load_default_house_styles: true
{{else}}
load_default_house_styles: false
{{/if}}
{{else}}
load_default_house_styles: true
{{/if}}

# Phase 3: Default hierarchy (if enabled)
{{if load_default_house_styles}}
{{if file_exists("~/.claude/npl-m/house-style/{type}-style.md")}}
load ~/.claude/npl-m/house-style/{type}-style.md into context.
{{/if}}
{{if file_exists(".claude/npl-m/house-style/{type}-style.md")}}
load .claude/npl-m/house-style/{type}-style.md into context.
{{/if}}
{{for path in path_hierarchy_from_project_to_target}}
{{if file_exists("{{path}}/house-style/{type}-style.md")}}
load {{path}}/house-style/{type}-style.md into context.
{{/if}}
{{/for}}
{{/if}}
```

### Path Hierarchy Resolution
For target `/project/docs/api/endpoints/users`:
```
1. ~/.claude/npl-m/house-style/{type}-style.md      # Home global
2. .claude/npl-m/house-style/{type}-style.md        # Project global  
3. ./house-style/{type}-style.md                    # Project root
4. ./docs/house-style/{type}-style.md               # Directory-specific
5. ./docs/api/house-style/{type}-style.md           # Subdirectory
6. ./docs/api/endpoints/house-style/{type}-style.md # Target proximity
7. ./docs/api/endpoints/users/house-style/{type}-style.md # Target location
```

## Common Agent Patterns

### Writer Agent Template
```npl
⌜npl-{domain}-writer|writer|NPL@1.0⌝
🙋 @writer spec pr issue doc readme api-doc annotate review

# NPL {Domain} Writer Agent
[Specialized writing agent for {domain} content]

# Core NPL Loading
load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-rubric.md into context.
load .claude/npl/pumps/npl-panel-inline-feedback.md into context.

# Template Loading
{{if document_type}}
load .claude/npl/templates/{{document_type}}.md into context.
{{/if}}

# House Style Loading
[Full house style algorithm here]

⌞npl-{domain}-writer⌟
```

### Evaluator Agent Template
```npl
⌜npl-grader|evaluator|NPL@1.0⌝
🙋 @grader evaluate assess rubric-based-grading quality-check

# NPL Grader Agent
[Evaluation and assessment agent]

# Core Loading
load .claude/npl.md into context.
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-reflection.md into context.
load .claude/npl/pumps/npl-rubric.md into context.

# Custom Rubric
{{if rubric_file}}
load {{rubric_file}} into context.
{{/if}}

⌞npl-grader⌟
```

### General Agent Template
```npl
⌜npl-agent-name|agent|NPL@1.0⌝
🙋 @alias primary-capability secondary-capability

# NPL Agent Name
[Agent description and purpose]

# Selective pump loading based on agent needs
load .claude/npl/pumps/npl-intent.md into context.
load .claude/npl/pumps/npl-cot.md into context.
load .claude/npl/pumps/npl-critique.md into context.
load .claude/npl/pumps/npl-reflection.md into context.

⌞npl-agent-name⌟
```

## Available Pump Definitions

### Core Reasoning Pumps
- `npl-intent.md`: Intent declaration and step tracking
- `npl-cot.md`: Chain-of-thought reasoning
- `npl-critique.md`: Critical analysis and feedback
- `npl-reflection.md`: Post-response self-assessment
- `npl-rubric.md`: Structured evaluation criteria

### Communication Pumps
- `npl-mood.md`: Emotional context and tone
- `npl-panel.md`: Multi-perspective discussion
- `npl-panel-group-chat.md`: Group discussion simulation
- `npl-panel-inline-feedback.md`: Inline annotation system
- `npl-panel-reviewer-feedback.md`: Structured review feedback
- `npl-tangent.md`: Tangential thinking and exploration

## Environment Variables

### Style Configuration
```bash
HOUSE_STYLE_TECHNICAL="/path/to/technical-style.md"
HOUSE_STYLE_TECHNICAL_ADDENDUM="/path/to/extra-guidelines.md"
HOUSE_STYLE_MARKETING="/path/to/marketing-voice.md"
HOUSE_STYLE_MARKETING_ADDENDUM="/path/to/brand-extras.md"
```

### Template Selection
```bash
document_type="spec"         # Loads .claude/npl/templates/spec.md
content_type="landing-page"  # Loads .claude/npl/templates/marketing/landing-page.md
rubric_file="/path/to/custom-rubric.md"
```

### Loading Control
```bash
load_default_house_styles=true
path_hierarchy_from_project_to_target=["/project", "/project/docs", "/project/docs/api"]
NPL_HOUSE_STYLE_DEBUG=true  # Enable verbose loading trace
```

## Best Practices

### Agent Development
1. **Load core framework first**: Always start with `.claude/npl.md`
2. **Use selective pumps**: Only load pumps relevant to agent function
3. **Implement graceful fallbacks**: Check file existence before loading
4. **Document loading intent**: Comment why specific resources are loaded

### Template Design
1. **Use descriptive placeholders**: `{variable|description}`
2. **Implement conditional sections**: `{{#if has_feature}}`
3. **Provide meaningful defaults**: Handle missing variables gracefully
4. **Include usage examples**: Document expected variable values

### Style Integration
1. **Leverage hierarchy**: Allow local customization of global styles
2. **Use control flags**: `+load-default-styles` for selective inheritance
3. **Document overrides**: Comment style precedence decisions
4. **Test loading order**: Verify styles load in expected sequence

### Error Handling
1. **Silent failure for missing files**: Continue operation with available context
2. **Validate before use**: Check conditions before variable interpolation
3. **Log loading decisions**: Use debug mode for troubleshooting
4. **Provide fallback content**: Ensure agents work with minimal context

## Loading Sequence Example

For `npl-technical-writer` generating `/project/docs/api/spec.md`:

```
1. load .claude/npl.md
2. load .claude/npl/pumps/npl-intent.md
3. load .claude/npl/pumps/npl-critique.md
4. load .claude/npl/pumps/npl-rubric.md
5. load .claude/npl/pumps/npl-panel-inline-feedback.md
6. IF document_type="spec": load .claude/npl/templates/spec.md
7. IF HOUSE_STYLE_TECHNICAL_ADDENDUM: load $HOUSE_STYLE_TECHNICAL_ADDENDUM
8. IF HOUSE_STYLE_TECHNICAL: load $HOUSE_STYLE_TECHNICAL
9. load ~/.claude/npl-m/house-style/technical-style.md (if exists)
10. load .claude/npl-m/house-style/technical-style.md (if exists)
11. load ./house-style/technical-style.md (if exists)
12. load ./docs/house-style/technical-style.md (if exists)
13. load ./docs/api/house-style/technical-style.md (if exists)
```

## File Structure References

### Specialized Files
- **Syntax Documentation**: `agentic/npl/concise/syntax/`
- **House Style Framework**: `agentic/npl/concise/house-style/`
- **Individual Pump Details**: `agentic/npl/concise/pumps/`

### Integration Files
- **Technical Writer Example**: `agentic/npl/concise/house-style/examples/technical-writer.md`
- **Marketing Writer Example**: `agentic/npl/concise/house-style/examples/marketing-writer.md`
- **Style Templates**: `agentic/npl/concise/house-style/templates/`

This reference provides the essential 80/20 patterns for NPL agent development while maintaining links to specialized documentation for deeper implementation details.