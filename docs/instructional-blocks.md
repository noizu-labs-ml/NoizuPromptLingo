# Instructional Content Analysis for YAML Schema

Analysis of instructional content patterns found in NPL markdown files (`npl/instructional/`), identifying content types and proposing YAML schema structure for non-component instructional content.

## Problem Statement

The NPL instructional markdown files (in `npl/instructional/`) contain a mix of:
1. **Components** - Syntax definitions with examples (already well-represented in YAML)
2. **Instructional sections** - Guidance, best practices, conceptual explanations

The existing YAML schema (`syntax.yaml`, `directives.yaml`, etc.) handles components well but has no structure for instructional content.

## Current Component Schema

```yaml
name: component-name
brief: One-line description
description: |
  Multi-paragraph explanation
purpose: |
  Why this exists and when to use it
labels: [scope, function, domain...]
import: [dependencies]
examples:
  - name: example-id
    brief: Short description
    priority: 0|1|2
    purpose: What this demonstrates
    labels: [syntax patterns]
    example: |        # Priority 0 (required): raw prompt example
      Simple example text
    thread:           # Priority 1-2: conversation demonstrating usage
      - role: system|user|assistant
        message: content
```

### Priority Levels for Examples

| Priority | Importance | Format | Description |
|----------|------------|--------|-------------|
| **0** | Highest (required) | `example:` | Essential example showing raw syntax usage |
| **1** | High | `thread:` | Important system/assistant exchange demonstrating output |
| **2** | Medium | `thread:` | Supplementary multi-turn conversation with user interaction |

## What Makes Content "Instructional" vs "Component-Like"

**Instructional Content (Guidance and Teaching):**
- Provides frameworks, patterns, and best practices
- Explains how and why to use features
- Includes usage guidelines and integration patterns
- Offers conceptual overviews and design patterns
- Contains "When to Use" and "Purpose" sections

**Component-Like Content (Definitions and Specifications):**
- Defines syntax and formal structures
- Provides concrete examples/templates
- Specifies parameters and options
- Documents API-like interfaces

| Aspect | Instructional | Component |
|--------|---------------|-----------|
| Focus | How and why to use | What it is and how it works |
| Structure | Purpose → Usage → Examples → Best Practices | Syntax → Parameters → Examples |
| Audience | Developers/users making decisions | Implementers/parsers using specs |
| Embeddedness | Standalone documentation | Embedded in system specs |
| Flow | Conceptual → Practical | Formal → Concrete |

## Common Structural Patterns in Instructional Sections

The files consistently follow these patterns:

**Foundational Elements:**
- `## Purpose` - Why this feature exists
- `## Usage` - When and how to apply it
- `## Syntax` - Formal structure/notation
- `## Core Concepts/Core Components` - Main conceptual areas

**Implementation Sections:**
- `## Examples` - Concrete demonstrations
- `## Parameters` - Variables and options
- `## Integration Patterns` - How to combine with other elements
- `## Best Practices/Guidelines` - Recommended approaches
- `## Advanced Patterns/Techniques` - Complex usage scenarios

**Navigation:**
- `## See Also` - Cross-references to related documentation

## Current State

The existing YAML schema (`syntax.yaml`, `directives.yaml`, etc.) effectively captures **components**—syntax definitions with examples. However, the markdown files contain substantial **instructional content** that has no YAML representation:

| File | Components | Instructional Sections |
|------|------------|----------------------|
| `agent.md` | Agent declaration syntax | Agent types, lifecycle, best practices, integration patterns |
| `pumps.md` | Pump syntax definitions | Implementation guidelines, selection criteria |
| `instructing.md` | Control structures | Pattern complexity levels, integration guidelines, error handling |
| `declarations.md` | Declaration syntax | Version control rules, framework boundaries, implementation guidelines |
| `formatting.md` | Format syntax | Usage guidelines, selection criteria |

## Instructional Content Types Identified

### 1. Usage Guidelines (`usage-guideline`)
**When/how to apply features**

Examples from codebase:
- `declarations.md`: "Use declarations to establish framework version boundaries"
- `syntax.yaml`: "Use qualifiers when you need to guide content generation"
- `instructing.md`: "When to Use Instructing Patterns"

```yaml
- name: declaration-usage
  type: usage-guideline
  brief: When and how to use declaration blocks
  content: |
    Use declarations to:
    - Establish framework version boundaries
    - Define compatibility requirements
    - Create operational contexts for agents
```

### 2. Best Practices (`best-practice`)
**Recommended approaches and patterns**

Examples from codebase:
- `agent.md`: "Provide clear, concise agent descriptions"
- `agent.md`: "Specify exact capabilities and limitations"
- `syntax.yaml`: "Use sparingly—reserve for truly critical instructions"

```yaml
- name: agent-definition-practices
  type: best-practice
  brief: Guidelines for effective agent definitions
  content: |
    - Provide clear, concise agent descriptions
    - Specify exact capabilities and limitations
    - Include relevant behavioral patterns
    - Document expected input/output formats
```

### 3. Conceptual Explanation (`conceptual-explanation`)
**Theory and understanding**

Examples from codebase:
- `agent.md`: "Agents are simulated entities with defined behaviors..."
- `pumps.md`: "NPL pumps are cognitive tools that enable agents to demonstrate transparent reasoning"
- `instructing.md`: "Instructing patterns provide specialized syntax for controlling agent behavior"

```yaml
- name: agent-concept
  type: conceptual-explanation
  brief: Understanding what agents are in NPL
  content: |
    Agents are simulated entities with defined behaviors, capabilities,
    and response patterns designed for specific roles within the NPL
    ecosystem. They provide specialized services, processing contexts,
    and interactive capabilities while maintaining consistent behavioral
    patterns.
```

### 4. Lifecycle Documentation (`lifecycle`)
**Process flows and state transitions**

Examples from codebase:
- `agent.md`: Agent Lifecycle section (Initialization → Active Operation → Extension)

```yaml
- name: agent-lifecycle
  type: lifecycle
  brief: Agent initialization, operation, and extension phases
  priority: 1
  content: |
    ## Initialization
    1. Declaration Processing - Parse agent definition and type
    2. Capability Loading - Initialize specified behaviors
    3. Context Establishment - Set operational parameters
    4. Alias Registration - Register communication aliases

    ## Active Operation
    1. Message Routing - Process direct messages
    2. Context Maintenance - Preserve state
    3. Behavior Execution - Apply response patterns
    4. Self-Assessment - Generate reflection blocks

    ## Extension and Modification
    1. Runtime Updates - Apply flag modifications
    2. Extension Loading - Process extension declarations
    3. Capability Enhancement - Integrate new behaviors
```

### 5. Integration Patterns (`integration-pattern`)
**Combining multiple NPL elements**

Examples from codebase:
- `agent.md`: Multi-Agent Coordination, Template Integration, Directive Processing
- `instructing.md`: Template Integration, Interactive Element Choreography

```yaml
- name: multi-agent-coordination
  type: integration-pattern
  brief: Coordinating multiple agents for complex tasks
  priority: 2
  content: |
    ```example
    @search-agent find relevant documents
    @analyzer-agent process the results from search-agent
    @reporter-agent generate summary report
    ```
  related: [agent-declaration, direct-messaging]
```

### 6. Comparison (`comparison`)
**Distinguishing similar concepts**

Examples from codebase:
- `syntax.yaml`: "in-fill-vs-placeholder" example distinguishing generation from substitution
- `syntax.yaml`: "infer-vs-in-fill" example distinguishing pattern completion from generation
- `syntax.yaml`: "omission-vs-in-fill" example distinguishing meta-annotation from instruction

```yaml
- name: in-fill-placeholder-distinction
  type: comparison
  brief: When to use in-fill vs placeholder syntax
  content: |
    | Element | Purpose | Example |
    |---------|---------|---------|
    | `{term}` | Substitute known values | `{user.name}` |
    | `[...]` | Generate contextual content | `[...| summary]` |

    Use placeholders when values are predetermined; use in-fill
    when content must be created based on context.
```

### 7. Decision Guide (`decision-guide`)
**Choosing between options**

Examples from codebase:
- `instructing.md`: "Pattern Selection" section
- `pumps.md`: "Selection Criteria: Choose pumps based on task complexity"

```yaml
- name: instructing-pattern-selection
  type: decision-guide
  brief: Choosing the right instructing pattern
  content: |
    | Pattern | Use When |
    |---------|----------|
    | Handlebars | Dynamic content, conditional rendering |
    | Alg-speak | Computational and algorithmic tasks |
    | Annotation | Iterative improvement processes |
    | Symbolic logic | Mathematical and logical reasoning |
    | Formal proof | Rigorous logical verification |
```

### 8. Error Handling (`error-handling`)
**Troubleshooting and edge cases**

Examples from codebase:
- `instructing.md`: Error Handling section with verification steps
- `declarations.md`: "Gracefully handle missing or invalid declarations"

```yaml
- name: instructing-troubleshooting
  type: error-handling
  brief: Debugging instructing pattern issues
  content: |
    If instructing patterns produce unexpected results:
    1. Verify syntax correctness against pattern specifications
    2. Check for proper nesting and closure of control structures
    3. Validate data context and variable availability
    4. Load detailed pattern documentation for troubleshooting
```

### 9. Quick Reference (`quick-reference`)
**Concise summary/cheat-sheet**

Examples from codebase:
- `instructing.md`: Quick Reference section with condensed syntax
- `pumps.md`: Common Reflection Emojis list

```yaml
- name: instructing-quick-reference
  type: quick-reference
  brief: Condensed instructing syntax reference
  content: |
    **Template Control**: `{{if condition}} ... {{else}} ... {{/if}}`
    **Algorithm Spec**: Use `alg-*` fences with steps
    **Logic Operators**: `∑`, `∪`, `∩`, conditionals
    **Template Integration**: `⟪⇐: template-name | context⟫`
```

## Taxonomy of Instructional Content Types

### Tier 1: Core Categories

| Category | Purpose | Key Files | Example Content |
|----------|---------|-----------|-----------------|
| **Structural/Syntactic** | Teach formal syntax and notation | formatting.extended.md, instructing.extended.md | Placeholder systems, fence types, symbolic logic |
| **Behavioral** | Define how agents should behave | agent.md, pumps.md | Agent types, response modes, behavioral patterns |
| **Conceptual Framework** | Explain underlying concepts | instructing.extended.md, planning.md, pumps.extended.md | Handlebars, Alg-Speak, formal proofs, CoT |
| **Integration Guidance** | Show how to combine elements | agent.md, formatting.md, instructing.extended.md | Multi-agent coordination, template integration |
| **Quality & Evaluation** | Teach assessment patterns | pumps.md, pumps.extended.md | Reflection blocks, critique systems, rubrics |
| **Version & Scope Management** | Establish boundaries and rules | declarations.md, agent.md | Framework versions, precedence rules |

### Tier 2: Sub-Categories by Pedagogical Purpose

| Category | Sub-Types | Key Files |
|----------|-----------|-----------|
| **Problem-Solving Methods** | CoT, Annotation, Second-Order Logic, Formal Proof | instructing.extended.md, pumps.extended.md |
| **Output Control** | Templates, Formatting Patterns, Size Qualifiers | formatting.md, formatting.extended.md |
| **Multi-Perspective Analysis** | Panel Discussions, Group Chat, Inline Feedback | pumps.extended.md |
| **Self-Improvement** | Reflection, Critique, Annotation Cycles | pumps.md, pumps.extended.md, instructing.extended.md |
| **Reasoning Transparency** | Intent Blocks, Chain of Thought, Mood Indicators | pumps.md, pumps.extended.md, agent.md |
| **Computational Logic** | Algorithm Specification, Pseudocode, Flowcharts | instructing.extended.md |
| **Domain-Specific Algorithms** | JavaScript, Python, Language-Specific Implementations | instructing.extended.md |

### Tier 3: Pattern Complexity Levels

From `instructing.extended.md`:
- **Basic Instructions** → Simple conditionals and direct templates
- **Intermediate Control** → Nested conditionals, complex iteration
- **Advanced Orchestration** → Meta-level patterns, recursive structures

## Key Findings

1. **Hybrid Nature**: Many files (agent.md, instructing.extended.md, pumps.extended.md) blend instructional and component content, with instructional sections often serving as context for component definitions.

2. **Progressive Complexity**: Files organize from basic concepts to advanced patterns, mirroring skill progression.

3. **Principle of Locality**: Each instructional section explains related concepts together (e.g., all Handlebars control structures, all panel discussion variants).

4. **Cross-File Coherence**: The "See Also" sections create a web of related instructional resources, suggesting a carefully designed knowledge graph.

5. **Dual Structure Pattern**: Core files (instructing.extended.md, pumps.extended.md) have "base" versions (instructing.md, pumps.md) that serve as overviews, with ".extended" versions providing detailed specifications.

6. **Reasoning Pumps**: pumps.extended.md defines the largest collection of single-category instructional content—various structured thinking techniques for improving reasoning quality and transparency.

## Primary Instructional Techniques Used Across Files

- **Specification + Example Pattern**: Define format, then show concrete use
- **Scenario-Based Learning**: Examples tied to real use cases
- **Decision Trees**: "When to use X vs. Y" guidance
- **Progressive Disclosure**: Overview → intermediate → advanced
- **Multi-Format Representation**: Text, code, diagrams, structured data
- **Cross-Reference Networks**: "See Also" linking related concepts

This architecture makes NPL documentation serve both as tutorial material and formal specification simultaneously.

## Proposed Schema Options

### Option A: Separate `instructional` field at component level

```yaml
name: agent
components:
  - name: agent-declaration
    # ... existing component fields ...

instructional:
  - name: agent-lifecycle
    type: lifecycle
    brief: Agent initialization and operation flow
    content: |
      ### Initialization
      1. Declaration Processing - Parse agent definition
      2. Capability Loading - Initialize behaviors
      ...
    related: [agent-declaration, runtime-flags]
    priority: 1
```

### Option B: `guidance` sections within components

```yaml
components:
  - name: agent-declaration
    syntax: ...
    description: ...
    guidance:
      - type: best-practice
        content: "Provide clear, concise agent descriptions"
      - type: usage-guideline
        content: "Specify exact capabilities and limitations"
    examples: ...
```

### Option C: Top-level `instructional` parallel to `components`

```yaml
name: agent
brief: Agent definitions and behaviors
description: ...

components:
  - name: agent-declaration
    # ... component definition ...

instructional:
  - name: agent-types
    type: conceptual-explanation
    brief: Understanding service, tool, and person agents
    priority: 0
    content: |
      ## Agent Types

      ### Service Agent
      Provides specialized services or information processing...
    labels: [conceptual, definition]

  - name: agent-lifecycle
    type: lifecycle
    brief: Agent initialization, operation, and extension
    priority: 1
    content: |
      ## Agent Lifecycle

      ### Initialization
      1. Declaration Processing...
    labels: [lifecycle, framework]
    related: [agent-declaration, runtime-flags]

  - name: multi-agent-coordination
    type: integration-pattern
    brief: Coordinating multiple agents
    priority: 2
    content: |
      ## Multi-Agent Coordination
      ```example
      @search-agent find relevant documents
      @analyzer-agent process the results
      ```
    labels: [integration, advanced]
```

## Recommended Approach: Option C

**Rationale:**
1. **Parallel structure** - `components` and `instructional` are peers, reflecting their distinct purposes
2. **Consistent metadata** - Uses same patterns (name, brief, priority, labels) for discoverability
3. **Cross-referencing** - `related` field links instructional content to components
4. **Type taxonomy** - Explicit `type` field categorizes instructional content
5. **Content flexibility** - Full markdown in `content` field supports rich documentation

## Proposed YAML Schema

### Top-Level Structure

```yaml
name: <identifier>
brief: One-line description
description: |
  Multi-paragraph explanation

# Syntax definitions (existing)
components:
  - name: component-name
    syntax: [...]
    brief: ...
    description: ...
    examples: [...]

# NEW: Instructional content
instructional:
  - name: <identifier>
    type: <instructional-type>
    brief: <one-line summary>
    priority: 0|1|2
    content: |
      Full markdown content...
    labels: [...]
    related: [component-names]
    see-also: [other-instructional-names]
```

### Instructional Entry Schema

```yaml
instructional:
  - name: identifier           # Required: kebab-case identifier
    type: type-enum            # Required: from taxonomy
    brief: summary             # Required: one-line description
    content: |                 # Required: markdown content
      Instructional content with full markdown support.
      Can include code blocks, tables, lists.
    labels:                    # Optional: from existing label taxonomy
      - conceptual
      - definition
    related:                   # Optional: links to components
      - agent-declaration
      - runtime-flags
    see-also:                  # Optional: links to other instructional
      - agent-lifecycle
      - agent-best-practices
    examples:                  # Optional: demonstrations of the concept
      - name: example-id
        brief: Short description
        priority: 0|1|2        # 0=required, 1=high, 2=medium
        labels: [relevant-syntax]
        example: |             # Priority 0 (required): raw prompt
          Raw example text
        thread:                # Priority 1-2: conversation
          - role: system|user|assistant
            message: content
```

**Note:** Instructional entries do not have a `priority` field themselves—priority is only used within `examples` to indicate complexity level.

### Type Taxonomy

| Type | Description | Typical Example Priorities |
|------|-------------|---------------------------|
| `usage-guideline` | When and how to apply a feature | 0, 1 |
| `best-practice` | Recommended approaches | 1 |
| `conceptual-explanation` | Theory and understanding | 0 |
| `integration-pattern` | Combining multiple elements | 1, 2 |
| `lifecycle` | Process flows and state transitions | 1, 2 |
| `comparison` | Distinguishing similar concepts | 1 |
| `decision-guide` | Choosing between options | 1 |
| `error-handling` | Troubleshooting and edge cases | 1, 2 |
| `quick-reference` | Concise summary/cheat-sheet | 0 |

## Example: Complete agent.yaml

```yaml
name: agent
brief: Agent definitions and behaviors
description: |
  Comprehensive documentation for defining agents using NPL syntax, including
  capabilities, constraints, communication patterns, and lifecycle management.
purpose: |
  Agents are simulated entities with defined behaviors, capabilities, and
  response patterns designed for specific roles within the NPL ecosystem.

components:
  - name: agent-declaration
    syntax:
      - name: basic-declaration
        syntax: |
          ⌜agent-name|type|NPL@version⌝
          [___| agent content]
          ⌞agent-name⌟
    brief: Define a new agent
    description: |
      Establishes agent identity, type, and behavioral specifications.
    labels: [block, declaration]
    examples:
      - name: service-agent
        brief: Basic service agent definition
        priority: 0
        example: |
          ⌜sports-news-agent|service|NPL@1.0⌝
          # Sports News Agent
          Provides up-to-date sports news when prompted.
          ⌞sports-news-agent⌟

  # Additional components: agent-extension, direct-messaging, alias-declaration...

instructional:
  - name: agent-types-overview
    type: conceptual-explanation
    brief: Understanding service, tool, and person agents
    priority: 0
    content: |
      ## Agent Types

      ### Service Agent
      Provides specialized services or information processing:
      - **Purpose**: Task-specific functionality
      - **Pattern**: `agent-name|service|NPL@version`
      - **Examples**: search agents, translation services

      ### Tool Agent
      Simulates specific tools or utilities:
      - **Purpose**: Emulate tool behavior and interfaces
      - **Pattern**: `agent-name|tool|NPL@version`
      - **Examples**: calculators, converters

      ### Person Agent
      Simulates human-like interactions:
      - **Purpose**: Role-playing, consultation
      - **Pattern**: `agent-name|person|NPL@version`
      - **Examples**: subject matter experts, advisors
    labels: [conceptual, definition]
    related: [agent-declaration]

  - name: agent-lifecycle
    type: lifecycle
    brief: Agent initialization, operation, and extension
    priority: 1
    content: |
      ## Initialization
      1. **Declaration Processing** - Parse agent definition and type
      2. **Capability Loading** - Initialize specified behaviors
      3. **Context Establishment** - Set operational parameters
      4. **Alias Registration** - Register communication aliases

      ## Active Operation
      1. **Message Routing** - Process direct messages
      2. **Context Maintenance** - Preserve state
      3. **Behavior Execution** - Apply response patterns
      4. **Self-Assessment** - Generate reflection blocks

      ## Extension and Modification
      1. **Runtime Updates** - Apply flag modifications
      2. **Extension Loading** - Process extension declarations
      3. **Capability Enhancement** - Integrate new behaviors
    labels: [lifecycle, framework]
    related: [agent-declaration, agent-extension, runtime-flags]

  - name: agent-definition-best-practices
    type: best-practice
    brief: Guidelines for effective agent definitions
    priority: 1
    content: |
      ## Definition Guidelines
      - Provide clear, concise agent descriptions
      - Specify exact capabilities and limitations
      - Include relevant behavioral patterns
      - Document expected input/output formats

      ## Communication Design
      - Establish consistent response patterns
      - Define appropriate interaction modes
      - Consider error handling and edge cases
      - Plan for extension and modification
    labels: [guidance, quality]
    related: [agent-declaration]

  - name: multi-agent-coordination
    type: integration-pattern
    brief: Coordinating multiple agents for complex tasks
    priority: 2
    content: |
      ## Multi-Agent Coordination

      Agents can be chained for complex workflows:

      ```example
      @search-agent find relevant documents
      @analyzer-agent process the results from search-agent
      @reporter-agent generate summary report
      ```

      ## Template Integration
      Agents can utilize named templates:
      ```syntax
      ⟪⇐: user-template | with executive data⟫
      ```
    labels: [integration, advanced]
    related: [agent-declaration, direct-messaging, template-directive]
    see-also: [agent-lifecycle]
```

## Migration Strategy

### Phase 1: Prototype with agent.yaml
1. Extract instructional sections from `agent.md`
2. Validate schema completeness
3. Test loader compatibility

### Phase 2: Apply to remaining files
- `pumps.yaml` - Pump implementation guidelines
- `instructing.yaml` - Pattern selection and error handling
- `declarations.yaml` - Version control and framework rules
- `formatting.yaml` - Usage guidelines

### Phase 3: Update tooling
- Modify `npl_loader.py` to parse `instructional` sections
- Add validation for instructional type taxonomy
- Generate documentation from combined components + instructional

## Files to Create/Modify

1. **New**: `npl/instructional/agent.yaml` - Agent instructional content
2. **New**: `npl/instructional/planning.yaml` - Planning patterns
3. **New**: `npl/instructional/pumps.yaml` - Intuition pumps
4. **Update**: `tools/npl_loader.py` - Support for instructional sections

## Open Questions

1. **Priority requirement**: Should `priority` be required or optional with default?
   - **Recommendation**: Optional with default of 1 (intermediate)

2. **Prerequisites field**: Add `prerequisites` for learning paths?
   - **Recommendation**: Defer—use `see-also` for now, add prerequisites if needed

3. **Extended files**: Separate YAML or merged?
   - **Recommendation**: Merge into single YAML per topic; use `priority: 2` for advanced content
