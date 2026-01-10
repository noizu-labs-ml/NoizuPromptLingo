# PRD: NPL Itemized Element Registry

## Overview

Transform NPL-v2's markdown documentation into a structured YAML database enabling programmatic detection, selective loading, and granular control of prompt conventions.

## Problem Statement

### Current State
NPL-v2 documentation exists as interconnected markdown files organized hierarchically:
- Main files (`syntax.md`, `fences.md`, etc.) contain core element definitions
- Subdirectories contain extended documentation for less common elements
- Loading is all-or-nothing per category

### Pain Points

1. **Over-provisioning**: Models receive full documentation for elements they don't use
2. **No programmatic detection**: Cannot automatically identify which elements a prompt uses
3. **Inflexible loading**: Cannot selectively load only needed elements or examples
4. **Context waste**: Extended documentation loaded even when basic awareness suffices

### Impact
- Wasted context tokens on unused element documentation
- Reduced model performance from information overload
- No ability to optimize prompts based on actual element usage

## Solution

A YAML-based element registry with:
- Hierarchical detection patterns (fast pre-filter → regex validation)
- Tiered examples (primary for essential aspects, supplemental for edge cases)
- Filterable metadata for selective loading
- Context-aware parsing for nested structures

## Requirements

### Functional Requirements

#### FR-1: Element Detection
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-1.1 | Each element has detection patterns for programmatic identification | P0 |
| FR-1.2 | Detection uses hierarchical approach: string pre-filter then regex | P0 |
| FR-1.3 | Regex patterns include named capture groups for extraction | P1 |
| FR-1.4 | Alternative patterns supported for syntax variations | P1 |
| FR-1.5 | Context-aware parsing tracks nested element relationships | P2 |

#### FR-2: Metadata Structure
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-2.1 | Each element has name, category, and type classification | P0 |
| FR-2.2 | Descriptions include: concise summary, purpose, usage guidance | P0 |
| FR-2.3 | Complexity score (1-5) enables filtering by difficulty | P1 |
| FR-2.4 | Related elements tracked for dependency resolution | P2 |

#### FR-3: Example System
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-3.1 | Primary examples array covers distinct essential aspects | P0 |
| FR-3.2 | Supplemental examples array for advanced/edge cases | P0 |
| FR-3.3 | Each example has: name, labels[], brief, description, input, explanation. Expected output uses YAML chat thread format in input field. | P0 |
| FR-3.4 | Examples filterable by label/type for selective loading | P1 |

#### FR-4: Selective Loading
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-4.1 | Filter by category (syntax, fences, directives, etc.) | P0 |
| FR-4.2 | Filter by type (core, extended, emoji, structured) | P0 |
| FR-4.3 | Filter by complexity level | P1 |
| FR-4.4 | Load only primary examples vs all examples | P1 |
| FR-4.5 | Load element existence only (no examples/extended info) | P1 |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-1 | Detection pattern execution | <10ms per element |
| NFR-2 | Full prompt scan (typical) | <100ms |
| NFR-3 | YAML file size per category | <50KB |
| NFR-4 | Human readability | Maintainable without tooling |

## Data Model

### Element Schema

```yaml
elements:
  - name: string                    # Unique identifier
    labels: string[]                # Categorization tags (e.g., ["core", "common", "template"])
    category: enum                  # syntax|fences|directives|prefixes|pumps|sections|formatting|instructing
    type: enum                      # core|extended|emoji|structured|special
    emoji: string?                  # For emoji-based elements

    metadata:
      brief: string                 # Short description (5-10 words)
      description: string           # Full description (1-2 sentences)
      purpose: string               # Why it exists
      usage: string                 # When to use it
      complexity: int               # 1-5 scale
      precedence: int?              # For special sections
      scope: string?                # Element scope (line, block, prompt)

    # Syntax shown to LLMs - how to use the element
    syntax:
      template: string              # Basic syntax pattern for LLM consumption
      template_notes: string?       # Notes on using the syntax
      features:                     # Optional feature variations
        - name: string              # Feature name (e.g., "with-size", "with-qualifier")
          template: string          # Syntax when feature is active
          template_notes: string?

    # Detection patterns for scanning tools - NOT shown to LLMs
    detection:
      pre_filter: string[]          # Fast string matches
      pattern: string               # Full regex pattern
      type: "regex"
      flags: string[]?              # multiline, dotall, etc.
      groups: string[]              # Named capture groups
      alternatives: pattern[]?      # Variant patterns

    examples:
      primary: example[]            # Essential aspects (multiple)
      supplemental: example[]       # Advanced cases

    extended:
      variations: variation[]?      # Syntax variants
      related: string[]?            # Related element names
      conflicts: string[]?          # Incompatible elements
      size_indicators: map?         # For elements with size modifiers

    context:
      can_contain: string[]?        # Nested element types
      parse_nested: boolean?        # Whether to parse contents
```

### Example Schema

```yaml
example:
  name: string                      # Unique identifier for the example
  labels: string[]                  # Categorization tags (e.g., ["basic", "template", "technical"])
  brief: string                     # Short description (5-10 words)
  description: string               # Full description of what this example demonstrates
  input: string                     # Example syntax/usage (see format below)
  explanation: string               # Why/how it works

# Input format for examples WITH expected assistant output:
# Use YAML chat thread format inside example fence
input: |
  ````example
  ```yaml
  - role: system
    message: "<prompt with NPL syntax>"
  - role: assistant
    message: "<expected response>"
  ```
  ````

# Input format for examples WITHOUT expected output:
# Plain syntax demonstration
input: "🎯 Remember to validate all inputs."

# Conditional example (for elements with features)
conditional_example:
  switch:
    - case: string                  # Feature condition (e.g., "with-size AND with-qualifier")
      example: example              # Example to use when condition matches
    - case: string
      example: example
```

### Category Schema

```yaml
category:
  name: string
  description: string
  complexity: enum                  # foundational|intermediate|advanced
  frequency: enum                   # high|medium|low
```

## Detection Strategy

### Hierarchical Detection

```
Level 1: Pre-filter (String Match)
├── Fast substring check
├── Eliminates non-matches quickly
└── Example: "[...]" for fill-in elements

Level 2: Regex Validation
├── Full pattern with capture groups
├── Extracts components
└── Example: \[\.\.\.(?:\|([^\]]*))?\]

Level 3: Context Parsing (Optional)
├── Tracks parent-child relationships
├── Resolves nested elements
└── Example: fill-in inside example fence
```

### Extension Pattern for Modifiers

Size indicators use extension patterns attached to base detection:

```yaml
# Base pattern detects [...]
# Extension captures size modifiers like [...2p], [...5w]
base: "\\[\\.\\.\\.\\]"
extension: "(?:\\|(\\d+)([pwlsgirt]))?"
combined: "\\[\\.\\.\\.(?:\\|(\\d+)([pwlsgirt]))?\\]"
```

## File Organization

```
npl-v2/
├── syntax.yaml             # Core syntax elements (highlight, placeholder, fill-in, etc.)
├── fences.yaml             # Fence types (example, note, diagram, artifact, etc.)
├── directives.yaml         # Emoji directives (📅, 📂, 🆔, etc.)
├── prefixes.yaml           # Response mode prefixes (🗣️❓, 📊, 💡, etc.)
├── pumps.yaml              # Thinking patterns (cot, reflection, intent, panel, etc.)
├── sections.yaml           # Special sections (agent, runtime-flags, secure-prompt)
├── formatting.yaml         # Output patterns (input-syntax, output-example, template)
├── instructing.yaml        # Control structures (handlebars, alg, annotation)
│
├── registry.yaml           # Master index referencing all category files
│
└── *.md                    # Original markdown docs (kept for reference)
```

Each category YAML file is self-contained with all elements for that category. This flat structure simplifies loading and avoids deep nesting.

## Usage Scenarios

### Scenario 1: Prompt Analysis
```
Input: User prompt containing various NPL elements
Process:
  1. Run pre-filters across all elements
  2. Validate matches with full regex
  3. Build element dependency graph
Output: List of detected elements with extraction data
```

### Scenario 2: Minimal Loading
```
Input: Detected elements list
Process:
  1. Load only matched elements
  2. Include primary examples only
  3. Skip extended documentation
Output: Minimal YAML subset for context
```

### Scenario 3: Existence-Only Mode
```
Input: Category filter (e.g., "all")
Process:
  1. Load element names and descriptions only
  2. Skip examples and extended info
  3. Model knows elements exist without full docs
Output: Lightweight awareness context
```

## Migration Plan

### Phase 1: Schema Definition
- Define YAML schema structures
- Document detection pattern format
- Establish example categorization rules

### Phase 2: Core Element Migration
1. Syntax elements (most common)
2. Fence types (structural)
3. Directives (emoji patterns)
4. Prefixes (response modes)

### Phase 3: Extended Element Migration
5. Pumps (thinking patterns)
6. Special sections (high precedence)
7. Formatting patterns
8. Instructing patterns

### Phase 4: Validation
- Test detection patterns against source examples
- Verify all markdown content represented
- Performance benchmarks

## Success Criteria

| Metric | Target |
|--------|--------|
| Element coverage | 100% of markdown elements represented |
| Detection accuracy | 100% of source examples matched by patterns |
| Loading reduction | 50%+ context savings with selective loading |
| Maintainability | Updates require only YAML edits |

## Out of Scope

- Automated migration tooling (manual migration)
- Runtime prompt rewriting
- Version migration between NPL versions
- Dynamic element generation

## Appendix: Element Categories

| Category | Count | Complexity | Examples |
|----------|-------|------------|----------|
| syntax | ~15 | foundational | highlight, placeholder, fill-in |
| fences | ~10 | intermediate | example, note, diagram, artifact |
| directives | ~8 | advanced | 📅, 📂, 🆔, ➤ |
| prefixes | ~15 | intermediate | 🗣️❓, 📊, 💡, ❓ |
| pumps | ~10 | advanced | cot, reflection, intent, panel |
| sections | ~5 | advanced | agent, runtime-flags, secure-prompt |
| formatting | ~6 | intermediate | input-syntax, output-example, template |
| instructing | ~8 | advanced | handlebars, alg, annotation |
