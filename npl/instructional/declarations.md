# Declarations
<!-- labels: [block, framework, version-control] -->

Framework version boundaries and rule establishment for NPL (Noizu Prompt Lingua).

## NPL Conventions Declaration

```syntax
⌜NPL@version⌝
[___]
⌞NPL@version⌟
```

<!-- instructional: conceptual-explanation | level: 0 | labels: [framework, definition] -->
### Purpose

Establishes framework version boundaries, operational context, and core rules for NPL prompt engineering. Declaration blocks create immutable boundaries that define version-specific behaviors, compatibility requirements, and framework constraints.

<!-- instructional: usage-guideline | level: 0 | labels: [framework, guidance] -->
### Usage

Use declarations to:
- Establish framework version and rule boundaries
- Define compatibility requirements between versions
- Create operational contexts for agents and prompts
- Set framework-level constraints and capabilities

### Examples

#### Basic Framework Declaration
<!-- level: 0 -->
```example
⌜NPL@1.0⌝
# Core NPL Framework Rules
[___|Framework-specific rules and guidelines.]

⌞NPL@1.0⌟
```

#### Framework Extension Declaration
<!-- level: 1 -->
```example
⌜extend:NPL@1.0⌝
# Extension to Core Framework
[___|Additional rules enhancing NPL@1.0 capabilities.]

⌞extend:NPL@1.0⌟
```

#### Agent Declaration
<!-- level: 0 -->
```example
⌜agent-name|type|NPL@1.0⌝
# Agent Name
Description of agent and primary function.

[___|behavioral specifications]

⌞agent-name⌟
```

#### Agent Extension
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

# Instructional Notes

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


<!-- instructional: conceptual-explanation | level: 1 | labels: [agent, communication] -->
## Agent Capabilities

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

### Simulated Mood

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
## Best Practices For Declaration Prompts

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