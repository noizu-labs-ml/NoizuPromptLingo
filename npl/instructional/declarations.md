# Declarations
<!-- labels: [block, framework, version-control] -->

Framework version boundaries and rule establishment for NPL (Noizu Prompt Lingua).

```syntax
⌜NPL@version⌝
...
⌞NPL@version⌟
```

<!-- instructional: conceptual-explanation | level: 0 | labels: [framework, definition] -->
## Purpose

Establishes framework version boundaries, operational context, and core rules for NPL prompt engineering. Declaration blocks create immutable boundaries that define version-specific behaviors, compatibility requirements, and framework constraints.

<!-- instructional: usage-guideline | level: 0 | labels: [framework, guidance] -->
## Usage

Use declarations to:
- Establish framework version and rule boundaries
- Define compatibility requirements between versions
- Create operational contexts for agents and prompts
- Set framework-level constraints and capabilities

## Examples

### Basic Framework Declaration
<!-- level: 0 -->
```example
⌜NPL@1.0⌝
# Core NPL Framework Rules
Framework-specific rules and guidelines.

[... framework definitions ...]

⌞NPL@1.0⌟
```

### Framework Extension Declaration
<!-- level: 1 -->
```example
⌜extend:NPL@1.0⌝
# Extension to Core Framework
Additional rules enhancing NPL@1.0 capabilities.

[... enhancement definitions ...]

⌞extend:NPL@1.0⌟
```

### Agent Declaration
<!-- level: 0 -->
```example
⌜agent-name|type|NPL@1.0⌝
# Agent Name
Description of agent and primary function.

[... behavioral specifications ...]

⌞agent-name⌟
```

### Agent Extension
<!-- level: 1 -->
```example
⌜extend:sports-news-agent|service|NPL@1.0⌝
Enhances the agent's capability to provide historical sports facts in addition to recent news.

## Additional Capabilities
- Historical sports statistics and records
- Sports trivia and milestone events
- Cross-sport comparative analysis

⌞extend:sports-news-agent⌟
```

<!-- instructional: quick-reference | level: 0 | labels: [framework, definition] -->
## Declaration Types

| Type | Syntax | Purpose | Scope |
|------|--------|---------|-------|
| Framework | `⌜NPL@version⌝...⌞NPL@version⌟` | Core version and rule establishment | Global boundaries |
| Extension | `⌜extend:NPL@version⌝...⌞extend:NPL@version⌟` | Extend/modify framework capabilities | Additive enhancements |
| Agent | `⌜agent-name\|type\|NPL@version⌝...⌞agent-name⌟` | Define agent behaviors | Agent-specific boundaries |
| Agent Extension | `⌜extend:agent-name\|type\|NPL@version⌝...⌞extend:agent-name⌟` | Enhance agent definitions | Agent behavior modifications |

<!-- instructional: usage-guideline | level: 1 | labels: [version-control, precedence] -->
## Version Control Rules

### Version Boundaries
- Declarations create immutable version boundaries
- Version-specific behaviors are encapsulated within declaration blocks
- Cross-version compatibility must be explicitly defined

### Precedence Rules
1. **Agent-level declarations** override framework-level rules
2. **Extension declarations** modify base framework behaviors
3. **Later declarations** in processing order take precedence
4. **Explicit version references** (`@with NPL@version`) enforce version constraints

### Compatibility Requirements
- Agents must declare compatible framework versions
- Extensions must specify target framework versions
- Version mismatches should trigger compatibility warnings

<!-- instructional: conceptual-explanation | level: 1 | labels: [framework, scope, inheritance] -->
## Framework Boundaries

### Operational Scope
- Declarations establish operational context for all contained elements
- Framework boundaries define available syntax elements and behaviors
- Version-specific capabilities are constrained by declaration scope

### Rule Inheritance
- Child elements inherit framework rules from containing declarations
- Agent declarations inherit from framework declarations
- Extensions inherit from base framework unless explicitly overridden

### Constraint Enforcement
- Declaration blocks enforce version-specific constraints
- Invalid syntax for declared version should be rejected
- Framework boundaries prevent access to unavailable features

<!-- instructional: best-practice | level: 1 | labels: [implementation, guidance] -->
## Implementation Guidelines

### Declaration Placement
- Framework declarations should appear at document beginning
- Agent declarations should precede agent usage
- Extensions should follow base framework declarations

### Version Management
- Use semantic versioning for framework versions
- Maintain backward compatibility within major versions
- Document breaking changes between versions

### Error Handling
- Validate version compatibility during processing
- Provide clear error messages for version conflicts
- Gracefully handle missing or invalid declarations

---

<!--
  AGENT-FOCUSED INSTRUCTIONAL CONTENT
  The following sections detail agent behaviors and patterns.
-->

<!-- instructional: conceptual-explanation | level: 0 | labels: [agent, definition] -->
## Agent Types

| Type | Pattern | Purpose | Examples |
|------|---------|---------|----------|
| Service | `agent-name\|service\|NPL@version` | Task-specific functionality | search agents, translation services |
| Tool | `agent-name\|tool\|NPL@version` | Emulate tool behavior/interfaces | calculators, converters, validators |
| Person | `agent-name\|person\|NPL@version` | Role-playing, expertise simulation | subject matter experts, advisors |

<!-- instructional: conceptual-explanation | level: 1 | labels: [agent, communication] -->
## Agent Capabilities

### Communication Patterns

**Direct Messaging**
```syntax
@{agent-name} perform specific task
```

**Alias Declaration**
```syntax
🙋 agent-alias short-name
```
After declaration, agent responds to: `@short-name` or `@agent-alias`

**Response Modes**
Agents can operate in different modes using prompt prefixes:
- `👪➤` - Conversational interaction mode
- `❓➤` - Question-answering mode
- `📄➤` - Summarization mode

<!-- instructional: conceptual-explanation | level: 1 | labels: [agent, reasoning, pumps] -->
### Behavioral Specifications

**Intent Blocks**
```format
<npl-intent>
intent:
  overview: <brief description of intent>
  steps:
    - <step 1>
    - <step 2>
    - <step 3>
</npl-intent>
```

**Chain of Thought Processing**
```format
<npl-cot>
thought_process:
  - thought: "Initial thought about the problem."
    understanding: "Understanding of the problem."
    theory_of_mind: "Insight into the question's intent."
    plan: "Planned approach to the problem."
    rationale: "Rationale for the chosen plan."
    execution:
      - process: "Execution of the plan."
        reflection: "Reflection on progress."
        correction: "Adjustments based on reflection."
  outcome: "Conclusion of the problem-solving process."
</npl-cot>
<npl-conclusion>
"Final solution or answer to the problem."
</npl-conclusion>
```

**Reflection Blocks**
```format
<npl-reflect>
reflection:
  overview: |
    <assess response>
  observations:
    - <emoji> <observation 1>
    - <emoji> <observation 2>
    - <emoji> <observation 3>
</npl-reflect>
```

<!-- instructional: usage-guideline | level: 1 | labels: [agent, runtime, configuration] -->
### Runtime Configuration

**Runtime Flags**
```syntax
⌜🏳️
🏳️verbose_output = true                    // Global flag
🏳️@agent-name.debug_mode = true           // Agent-specific flag
⌟
```

**Flag Precedence** (highest to lowest):
1. Response-level flags
2. Agent-level flags
3. NPL-level flags
4. Global flags

**Simulated Mood**
```format
<npl-mood agent="@{agent}" mood="😀">
The agent is content with the successful completion of the task.
</npl-mood>
```

<!-- instructional: lifecycle | level: 1 | labels: [agent, lifecycle, framework] -->
## Agent Lifecycle

### Initialization
1. **Declaration Processing**: Parse agent definition and type
2. **Capability Loading**: Initialize specified behaviors and constraints
3. **Context Establishment**: Set operational parameters and scope
4. **Alias Registration**: Register declared aliases for communication

### Active Operation
1. **Message Routing**: Process direct messages and commands
2. **Context Maintenance**: Preserve state across interactions
3. **Behavior Execution**: Apply defined response patterns
4. **Self-Assessment**: Generate reflection blocks as configured

### Extension and Modification
1. **Runtime Updates**: Apply flag-based behavior modifications
2. **Extension Loading**: Process extension declarations
3. **Capability Enhancement**: Integrate additional behaviors
4. **Constraint Updates**: Modify operational boundaries

<!-- instructional: best-practice | level: 1 | labels: [agent, constraints, boundaries] -->
## Agent Constraints

### Scope Limitations
- Agents operate within their declared capabilities
- Type-specific constraints apply (service vs. tool vs. person)
- Version compatibility requirements must be maintained

### Behavioral Boundaries
- Must adhere to NPL syntax conventions
- Cannot exceed declared functional scope
- Subject to runtime flag modifications

### Communication Rules
- Respond appropriately to direct messages
- Maintain consistent persona/behavior patterns
- Honor prompt prefix requirements

<!-- instructional: integration-pattern | level: 2 | labels: [agent, integration, advanced] -->
## Integration Patterns

### Multi-Agent Coordination
```example
@search-agent find relevant documents
@analyzer-agent process the results from search-agent
@reporter-agent generate summary report
```

### Template Integration
```syntax
⟪⇐: user-template | with executive data⟫
```

### Directive Processing
```syntax
⟪📅: (name:left, role:right, dept:center) | executive team roster⟫
```

<!-- instructional: best-practice | level: 1 | labels: [agent, guidance, quality] -->
## Best Practices

### Definition Guidelines
- Provide clear, concise agent descriptions
- Specify exact capabilities and limitations
- Include relevant behavioral patterns
- Document expected input/output formats

### Communication Design
- Establish consistent response patterns
- Define appropriate interaction modes
- Consider error handling and edge cases
- Plan for extension and modification

### Lifecycle Management
- Design for maintainable state management
- Consider resource utilization patterns
- Plan upgrade and migration strategies
- Document operational dependencies

