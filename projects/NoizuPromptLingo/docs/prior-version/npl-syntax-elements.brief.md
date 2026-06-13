# NPL Syntax Elements

**Type**: Reference Documentation
**Category**: Core Framework
**Status**: Comprehensive Mapping

## Purpose

The NPL Syntax Elements YAML file serves as the comprehensive catalog of all 155+ distinct syntax elements within the Noizu Prompt Lingo (NPL) framework. This reference documentation maps syntax patterns across core elements, directives, prefixes, special sections, fences, pumps, instructing elements, and formatting constructs. It enables systematic understanding of NPL's multi-layered syntax system and provides regex patterns for parsing and validation.

The file consolidates syntax definitions scattered across multiple NPL documentation files, creating a single source of truth for syntax element specifications, types, descriptions, and pattern matching.

## Key Capabilities

- **Complete syntax mapping** - Documents all 155+ syntax elements across 8 major categories
- **Regex pattern library** - Provides validated regex patterns for parsing each syntax element
- **Multi-file source tracking** - Maps each element back to its canonical definition file
- **Type classification** - Organizes elements by functional type (emphasis, placeholder, directive, fence, etc.)
- **Hierarchical structure** - Groups elements into logical categories for systematic reference
- **Cross-reference support** - Enables tool builders to validate NPL document syntax

## Usage & Integration

- **Triggered by**: NPL parser implementations, syntax validators, IDE extensions
- **Outputs to**: Syntax highlighting tools, linters, documentation generators
- **Complements**: Core NPL framework documentation (`npl/*.md`), agent definitions, formatting guides

## Core Operations

### Syntax Categories

```yaml
# Core syntax (emphasis, placeholders, content generation)
- highlight: `term`
- attention: 🎯 instruction
- placeholder-angle: <term>
- in-fill-qualified: [...|context]

# Directives (table, temporal, template, interactive)
- directive-explicit: ⟪➤: instruction | qualifier⟫
- directive-template: ⟪⇐: template | context⟫

# Prefixes (response mode indicators)
- prefix-conversational: 👪➤ content
- prefix-code-generation: 🖥️➤ content

# Special sections (declarations, flags, templates)
- framework-declaration: ⌜NPL@version⌝...⌞NPL@version⌟
- runtime-flags: ⌜🏳️...⌟
```

### Element Structure

Each element entry contains:
```yaml
- name: "element-identifier"
  type: "functional-category"
  file: "source-definition-file"
  description: "purpose and usage"
  regex: "parsing-pattern"
```

### Primary Categories

| Category | Element Count | Purpose |
|----------|---------------|---------|
| Core Syntax | 20+ | Basic emphasis, placeholders, content generation |
| Directives | 8 | Command structures for structured outputs |
| Prefixes | 15+ | Response mode indicators (visual, audio, code) |
| Special Sections | 6 | Framework declarations and security blocks |
| Fences | 20+ | Code blocks, examples, templates, algorithms |
| Pumps | 12 | Planning and thinking patterns (CoT, reflection, panels) |
| Instructing | 40+ | Algorithms, templates, proofs, symbolic logic |
| Formatting | 15+ | Templates, input/output syntax, control flow |

## Integration Points

- **Upstream dependencies**: NPL core framework (`npl/*.md`), syntax definitions
- **Downstream consumers**: Syntax parsers, validators, IDE plugins, documentation tools
- **Related utilities**: `npl-load syntax`, syntax analyzers, NPL-FIM visualization agent

## Limitations & Constraints

- **Regex patterns** - Some patterns may require context-aware parsing beyond regex capabilities
- **Source file references** - References point to `npl/*.md` files; file paths must be resolved relative to NPL framework root
- **Pattern overlaps** - Some syntax elements share similar patterns (e.g., handlebars vs placeholders)
- **Version tracking** - No explicit versioning per element; versioning managed at framework level

## Success Indicators

- Comprehensive coverage of all documented NPL syntax elements
- Valid regex patterns that successfully match intended syntax
- Clear mapping between elements and source documentation files
- Consistent type classification across all 155+ elements

---
**Generated from**: worktrees/main/docs/npl-syntax-elements.yaml
**Word count**: 485
