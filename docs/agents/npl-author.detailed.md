# npl-author - Detailed Documentation

NPL prompt authoring agent for creating, revising, and enhancing NPL-compliant agent definitions and prompts.

## Overview

The `npl-author` agent analyzes existing prompts and generates new ones using NPL syntax patterns. It selects appropriate `npl_load()` components, applies enhancement patterns, validates compliance, and outputs production-ready definitions.

**Agent Type**: Service
**NPL Version**: 1.0
**Recommended Model**: opus

## Capabilities

### Prompt Analysis
- Extract core purpose and requirements from existing prompts
- Identify missing NPL components and syntax patterns
- Measure NPL syntax density (high >80%, medium 40-80%, low <40%)
- Evaluate semantic marker coverage

### Generation
- Create new agent, service, persona, and tool definitions
- Generate inline NPL digests for resource-constrained environments
- Build test suites for prompt validation

### Enhancement
- Apply semantic boundaries and attention anchors
- Integrate reasoning pumps (intent, critique, reflection, tangent)
- Add structured output formatting
- Optimize information hierarchy for LLM processing

### Validation
- Check NPL compliance against checklist
- Verify agent boundary markers
- Validate `npl_load()` directives
- Confirm current directive syntax patterns

## Commands

### revise

Enhance an existing prompt with NPL patterns.

```bash
@npl-author revise <file.md> [options]
```

**Options**:
- `--enhance-pumps` - Add reasoning components (intent, critique, reflection)
- `--add-validation` - Include NPL compliance checklist
- `--target-density=<low|medium|high>` - Set NPL syntax density target

**Example**:
```bash
@npl-author revise existing-agent.md --enhance-pumps --add-validation
```

### generate

Create a new NPL-compliant definition from scratch.

```bash
@npl-author generate --type=<type> --name=<name> [options]
```

**Types**:
- `agent` - General-purpose agent with defined capabilities
- `service` - Task-oriented agent for specific functions
- `persona` - Character-driven agent with personality traits
- `tool` - Specialized agent for computational tasks
- `template` - Reusable prompt pattern with variable substitution

**Options**:
- `--capabilities=<list>` - Comma-separated capability keywords
- `--behaviors=<description>` - Behavioral description for personas

**Examples**:
```bash
@npl-author generate --type=service --name=data-processor --capabilities="csv,json,api"
@npl-author generate --type=persona --name=virtual-cat --behaviors="interactive pet simulation"
```

### enhance

Upgrade a basic prompt with NPL syntax integration.

```bash
@npl-author enhance <file.md> [options]
```

**Options**:
- `--target-density=<low|medium|high>` - NPL syntax density level
- `--add-metadata` - Publish supporting data to `.npl/meta/`

**Example**:
```bash
@npl-author enhance basic-prompt.md --target-density=high --add-metadata
```

## NPL Component Directory

Reference for selecting `npl_load()` components based on prompt requirements.

### Core Files

| Component | Bytes | Purpose |
|:----------|------:|:--------|
| `agent` | 6815 | Agent declaration syntax, boundaries, lifecycle |
| `syntax` | 5460 | Core syntax elements (placeholders, in-fill, qualifiers) |
| `fences` | 3912 | Code fence types (example, note, diagram, format) |
| `formatting` | 6237 | Output templates, input/output syntax patterns |
| `directive` | 3229 | Behavior control patterns |
| `prefix` | 3454 | Response mode indicators |
| `planning` | 6870 | Combined reasoning patterns overview |
| `special-section` | 3953 | Runtime flags, secure prompts, named templates |
| `pumps` | 5984 | Reasoning components overview |

### Reasoning Components (pumps.*)

| Component | Bytes | Purpose |
|:----------|------:|:--------|
| `pumps.intent` | 1896 | Transparent decision-making documentation |
| `pumps.cot` | 4235 | Chain-of-thought problem decomposition |
| `pumps.reflection` | 4031 | Self-assessment and improvement |
| `pumps.critique` | 7802 | Critical analysis frameworks |
| `pumps.tangent` | 4812 | Alternative perspective exploration |
| `pumps.panel` | 6205 | Multi-perspective analysis |
| `pumps.panel.group-chat` | 10449 | Informal multi-participant discussions |
| `pumps.panel.inline-feedback` | 7813 | Real-time embedded commentary |
| `pumps.panel.reviewer-feedback` | 11433 | Formal structured assessment |
| `pumps.mood` | 6324 | Simulated emotional state indicators |
| `pumps.rubric` | 9190 | Structured evaluation criteria |

### Formatting Components (formatting.*)

| Component | Bytes | Purpose |
|:----------|------:|:--------|
| `formatting.template` | 1100 | Reusable output patterns with handlebars |
| `formatting.input-syntax` | 1725 | Expected input format specifications |
| `formatting.output-syntax` | 2419 | Required output format patterns |
| `formatting.input-example` | 3525 | Sample input demonstrations |
| `formatting.output-example` | 5033 | Sample output illustrations |

### Instructing Patterns (instructing.*)

| Component | Bytes | Purpose |
|:----------|------:|:--------|
| `instructing.handlebars` | 2090 | Template control structures |
| `instructing.alg` | 3274 | Algorithm specification |
| `instructing.alg.flowchart` | 3512 | Visual algorithm flowcharts |
| `instructing.alg.javascript` | 8780 | JavaScript-specific patterns |
| `instructing.alg.python` | 6893 | Python-specific patterns |
| `instructing.alg.pseudo` | 2369 | Standardized pseudocode |
| `instructing.symbolic-logic` | 5544 | Mathematical reasoning operators |
| `instructing.annotation` | 4760 | Iterative refinement patterns |
| `instructing.formal-proof` | 7414 | Structured proof techniques |
| `instructing.second-order` | 5427 | Meta-level reasoning |

### Directive Components (directive.*)

| Component | Bytes | Purpose |
|:----------|------:|:--------|
| `directive.+` | 3048 | Bidirectional data flow |
| `directive.hourglass` | 2238 | Time-based processing controls |
| `directive.arrow` | 4821 | Flow direction and sequence markers |
| `directive.id` | 3549 | Identity and reference management |
| `directive.folder` | 4175 | Content organization patterns |
| `directive.calendar` | 2342 | Table formatting with alignments |
| `directive.book` | 3608 | Documentation annotations |
| `directive.rocket` | 3264 | Interactive behavior choreography |

### Prefix Components (prefix.*)

| Component | Bytes | Purpose |
|:----------|------:|:--------|
| `prefix.question` | 826 | Question answering mode |
| `prefix.globe` | 1104 | Machine translation tasks |
| `prefix.label` | 1954 | Text classification tasks |
| `prefix.eye` | 1173 | Named entity recognition |
| `prefix.bulb` | 2000 | Sentiment analysis mode |
| `prefix.speech` | 1048 | Conversation mode responses |
| `prefix.doc` | 1896 | Summarization tasks |
| `prefix.chart` | 1085 | Topic modeling analysis |
| `prefix.sound` | 946 | Text-to-speech conversion |
| `prefix.pen` | 1658 | Text generation mode |
| `prefix.code` | 1919 | Code generation tasks |
| `prefix.image` | 966 | Image captioning |
| `prefix.voice` | 1053 | Speech recognition |
| `prefix.riddle` | 1920 | Word riddle format |
| `prefix.lab` | 1902 | Feature extraction mode |

### Special Section Components (special-section.*)

| Component | Bytes | Purpose |
|:----------|------:|:--------|
| `special-section.agent` | 3625 | Agent declaration blocks |
| `special-section.named-template` | 4853 | Named template definitions |
| `special-section.npl-extension` | 2040 | NPL extension declarations |
| `special-section.runtime-flags` | 3467 | Runtime behavior modifiers |
| `special-section.secure-prompt` | 3923 | Immutable instruction blocks |

## Component Selection Strategy

### Simple Prompts
Use base components only:
- `agent`, `syntax`, `fences`

### Reasoning Tasks
Add planning and pump components:
- `npl_load(planning)` + specific `pumps.*` components

### Template-Heavy Prompts
Include formatting and control structures:
- `npl_load(formatting)` + `npl_load(instructing.handlebars)`

### Specialized Behavior
Add specific directive components:
- `directive.*` components as needed

### Response Modes
Include prefix components for interaction patterns:
- `prefix.*` for specific output modes

## Output Format

Standard structure for generated NPL prompts:

```
---
name: {agent-name}
description: {purpose}
model: inherit
color: {category-color}
---

npl_load({component})
: {justification for loading}

---

agent-name|type|NPL@1.0
# Agent Title
{description}

@agent-name {keywords}

<npl-intent>
intent:
  overview: "{objective}"
  key_capabilities: ["{cap1}", "{cap2}"]
  reasoning_approach: "{approach}"
</npl-intent>

## Core Functions
{function definitions}

## Process Flow
{mermaid diagram if applicable}

## Usage Examples
{bash examples}

agent-name
```

## Inline NPL Digests

For resource-constrained environments, create digest blocks containing only needed syntax elements instead of loading complete component files.

### Syntax

```xml
<npl-digest id="unique-identifier">
<title>{digest name}</title>
<brief>{purpose}</brief>
<references>
  <npl-component id="component.path">Component Name</npl-component>
</references>
<![CDATA[
{extracted rules and syntax snippets}
]]>
</npl-digest>
```

### When to Use

- Token budget constraints
- Focused functionality requiring specific patterns only
- Custom combinations from multiple components
- Performance optimization for frequently-used patterns
- Embedding NPL in larger non-NPL prompts

### Cost Comparison

| Approach | Size | Use Case |
|:---------|-----:|:---------|
| Full component loading | ~11KB | Comprehensive coverage |
| Inline digest | ~1KB | Focused functionality (89% reduction) |

**Trade-offs**:
- Digest: Significant token savings, focused content
- Full load: Comprehensive coverage, less maintenance

## Metadata Publishing

Enhanced prompts publish supporting data to `.npl/meta/`:

### File Naming

| Extension | Purpose |
|:----------|:--------|
| `.int.md` | Interstitial files (gitignored, temporary) |
| `.md` | Versioned files (committed, permanent) |
| `.int.yaml` | Temporary configuration |
| `.yaml` | Permanent configuration |

### Metadata Types

- **Agent Definitions**: Capabilities, dependencies, usage patterns
- **Persona Profiles**: Character traits, behavioral patterns
- **Process Reports**: Enhancement analysis, validation results
- **Template Variations**: Different versions for A/B testing

## NPL Compliance Checklist

Validation criteria for generated prompts:

- [ ] Agent declaration uses `agent-name|type|NPL@1.0` format
- [ ] `npl_load()` directives present for extended components
- [ ] Unicode attention anchors used where appropriate
- [ ] Clear sections with defined purposes
- [ ] Current directive patterns (`emoji: instruction`)
- [ ] Appropriate NPL reasoning components
- [ ] Usage examples and documentation

## Error Recovery

### Source Content Missing
- **Action**: Generate minimal viable prompt with standard NPL patterns
- **Fallback**: Use basic NPL agent template structure

### Conflicting NPL Syntax Versions
- **Action**: Update deprecated syntax to current standards
- **Resolution**: Prioritize NPL@1.0 syntax patterns

### Validation Failures
- **Action**: Apply common NPL syntax fixes
  - Ensure proper agent boundary markers
  - Fix malformed `npl_load()` directives
  - Update directive syntax to current patterns
- **Re-validate**: After corrections applied

## Workflow Integration

### With npl-grader

Generate and validate:
```bash
@npl-author generate --type=agent --name=reviewer && @npl-grader evaluate reviewer.md
```

### With npl-templater

Revise and extract templates:
```bash
@npl-author revise agent.md && @npl-templater extract agent.md
```

### With @writer

Generate and document:
```bash
@npl-author generate --type=service --name=api-doc && @writer generate readme
```

## Best Practices

### Component Selection
1. Start with core files (`agent`, `syntax`, `fences`) for basic prompts
2. Add reasoning pumps only when complex analysis required
3. Include formatting components for structured output
4. Use directives sparingly for specialized behavior

### Syntax Density
- **High density (>80%)**: Use for complex agent definitions requiring extensive NPL integration
- **Medium density (40-80%)**: Balanced approach for most use cases
- **Low density (<40%)**: Simple prompts where plain text suffices

### Semantic Markers
- Use `target` for critical information
- Apply `agent-name` boundaries for clear component definitions
- Include process indicators for workflow clarity

### Test Suite Generation
- Generated prompts include test tasks saved to `{prompt-agent-name}/test-suite.md`
- Test against various input scenarios
- Validate expected output patterns

## Limitations

- Cannot validate prompt effectiveness without execution
- Component byte sizes are approximate
- Inline digests require manual maintenance
- Metadata publishing requires `.npl/meta/` directory structure
- Syntax density measurement is heuristic-based

## Related Documentation

- NPL syntax reference: `npl/syntax.md`
- Agent definition patterns: `npl/agent.md`
- Reasoning pumps: `npl/pumps/`
- Core agent definition: `core/agents/npl-author.md`
