# NPL Convention System Architecture

The NPL convention system manages the specification of Noizu Prompt Lingo — a modular prompt engineering framework. Convention definitions live in `conventions/*.yaml` as the single source of truth. Two MCP tools (`NPLSpec` and `NPLLoad`) expose this data, and `npl-docs-regen` renders the full specification to `npl/npl-full.md`.

---

## Pipeline Overview

```
conventions/*.yaml          User Input (expression or ComponentSpec)
        │                              │
        ▼                              ▼
   [YAML Files]                  [1] PARSER
   9 files total            parse_expression(expr)
        │                              │
        │                     NPLExpression
        │                   (additions, subtractions)
        │                              │
        ▼                              ▼
   [2] RESOLVER ◄──── NPLResolver.resolve(expression)
   Load YAML, lookup components, apply priority filters
        │
        ▼
   List[ResolvedComponent]
   (section, name, slug, syntax, examples, labels, require)
        │
        ▼
   [3] LAYOUT ENGINE
   NPLLayoutEngine.format(components)
        │
        ▼
   Markdown output string
```

---

## Convention YAML Format

### Directory Structure

```
conventions/
├── npl.yaml                # Framework metadata, section ordering, concepts, label taxonomy
├── syntax.yaml             # Core syntax (placeholders, qualifiers, in-fills, etc.)
├── declarations.yaml       # Framework and agent declarations
├── pumps.yaml              # Intuition pumps (reasoning techniques)
├── directives.yaml         # Specialized instruction patterns
├── prefixes.yaml           # Response mode indicators
├── prompt-sections.yaml    # Tagged semantic containers
├── special-sections.yaml   # Special container types
└── fences.yaml             # Fence/barrier conventions
```

### Root Metadata (`npl.yaml`)

```yaml
/npl:
  version: 1.0
  description: |
    Framework description...
  section_order:
    components:
      - syntax
      - declarations
      - pumps
      - ...
  concepts:
    - name: npl-declaration
      description: |
        ...
  labels:
    taxonomy:
      categories:
        - name: scope
          labels:
            - name: inline
            - name: block
        - name: function
          labels:
            - name: variable
```

### Component Structure

Each convention YAML file contains:

```yaml
name: syntax                       # Slug identifier
title: NPL Syntax Overview        # Display title
brief: Core syntax elements...    # Short description

categories:                        # Organizational groups
  - name: core-elements
    title: Core Syntax
    examples:                      # Category-level examples (cover multiple components)
      - name: combined-template
        covers: [placeholder, in-fill]
        thread:                    # Multi-turn conversation examples
          - role: system
            message: |
              ...

components:                        # Individual elements
  - name: placeholder
    priority: 0                    # Component priority (0 = always show)
    friendly-name: Placeholder
    category: core-elements
    brief: Substitution marker
    description: |
      ...
    syntax:
      - name: basic-placeholder
        syntax: '{identifier}'
        description: |
          ...
    labels: [inline, variable]
    require: [syntax.qualifier]    # Transitive dependencies
    examples:
      - name: User Name
        slug: user-name-example
        priority: 0                # Example priority
        example: |
          Hello {user.name}!
    detection:                     # Pattern detection metadata
      patterns:
        - regex: '\{[a-zA-Z_]\w*\}'
      category: pure
```

### Priority System

Two priority dimensions control output filtering:

| Dimension | Applies To | Filter Logic |
|-----------|-----------|--------------|
| Component priority | `component.priority` | Show if `priority <= max` |
| Example priority | `example.priority` | Show if `priority <= max` |

Items without a `priority` field are treated as priority 0 (always shown).

---

## Loading Pipeline

### 1. Parser (`src/npl_mcp/npl/parser.py`)

Parses expression DSL strings into structured `NPLExpression` objects.

**Grammar:**

```
expression  := term (SPACE term)*
term        := addition | subtraction
addition    := section_ref
subtraction := '-' section_ref
section_ref := section ('#' component)? (':' '+' NUMBER)?
section     := syntax | declarations | directives | prefixes |
               prompt-sections | special-sections | pumps | fences
```

**Examples:**

| Expression | Meaning |
|-----------|---------|
| `syntax` | All components in syntax section |
| `syntax#placeholder` | Just the placeholder component |
| `syntax#placeholder:+2` | Placeholder with examples up to priority 2 |
| `syntax directives` | All of both sections |
| `syntax -syntax#literal` | Syntax section minus the literal component |

**Output:** `NPLExpression(additions: List[NPLComponent], subtractions: List[NPLComponent])`

### 2. Resolver (`src/npl_mcp/npl/resolver.py`)

Loads YAML files and resolves expressions to component data.

**Algorithm:**
1. Load requested YAML file(s) from `conventions/` (cached per-resolver)
2. Look up each component by slug
3. Apply priority filter to examples
4. Collect additions, then remove subtractions
5. Return in YAML definition order (stable sort)

**Output:** `List[ResolvedComponent]` with section, name, slug, syntax, examples, labels, require fields.

### 3. Filters (`src/npl_mcp/npl/filters.py`)

Priority-based example filtering: `filter_by_priority(examples, max_priority) → List[Dict]`

### 4. Layout Engine (`src/npl_mcp/npl/layout.py`)

Formats resolved components into Markdown.

| Strategy | Behavior |
|----------|----------|
| `yaml_order` (default) | Preserve YAML definition order |
| `classic` | Group by first label (category-based) |
| `grouped` | Group by section type |

### 5. Loader (`src/npl_mcp/npl/loader.py`)

Main entry point: `load_npl(expression, npl_dir, layout, skip) → str`

Orchestrates parse → resolve → layout. The `skip` parameter converts terms to subtractions for excluding already-rendered components.

---

## Convention Formatter (`src/npl_mcp/convention_formatter.py`)

Higher-level formatter used by `NPLSpec`. Handles:

- Loading framework metadata from `npl.yaml`
- Resolving transitive dependencies from `require` fields
- Respecting `section_order` for output ordering
- Wrapping output in NPL version markers: `⌜NPL@1.0⌝ ... ⌞NPL@1.0⌟`
- Category-level example selection (greedy set cover for minimal examples)
- Concise mode (brief descriptions) and XML formatting options

---

## MCP Tool Interfaces

### NPLLoad (Expression DSL)

Quick agent-facing component retrieval:

```python
NPLLoad(expression="syntax#placeholder:+2", layout="yaml_order")
NPLLoad(expression="syntax directives -syntax#literal")
```

### NPLSpec (Full Specification)

Structured control with dependency resolution:

```python
NPLSpec(components=[], concise=True)                    # All conventions
NPLSpec(components=[{"spec": "syntax:*"}])              # All syntax
NPLSpec(components=[{"spec": "pumps:intent,poa"}])      # Specific components
NPLSpec(extension=True)                                  # Extension block
```

**ComponentSpec format:**
- `"*"` — All conventions
- `"syntax"` or `"syntax:*"` — All components in section
- `"pumps:intent,poa"` — Specific components by name

---

## Full Specification Generation

`npl/npl-full.md` is a generated artifact rendered from `conventions/*.yaml`:

```bash
uv run npl-docs-regen              # Regenerate in place
uv run npl-docs-regen --check      # CI guard (exit 1 if stale)
uv run npl-docs-regen --stdout     # Preview
uv run npl-docs-regen --concise    # Brief descriptions
uv run npl-docs-regen --xml        # XML example tags
```

Implementation in `src/npl_mcp/docs_regen.py`.

---

## Error Handling

| Phase | Exception | Cause |
|-------|-----------|-------|
| Parse | `NPLParseError` | Empty expression, unknown section, invalid format |
| Resolve | `NPLResolveError` | Component not found, YAML missing/invalid |
| Runtime | `NPLLoadError` | Wraps unexpected exceptions |

All errors include contextual messages with valid options listed.

---

## Key Design Principles

1. **YAML as source of truth** — All NPL definitions in `conventions/*.yaml`, code never hardcodes syntax
2. **Layered pipeline** — Clear separation: parse → resolve → layout
3. **Two-level priority** — Independent component and example filtering for flexible granularity
4. **Transitive dependencies** — `require` fields auto-include dependent components
5. **Multiple layouts** — Same data formatted three ways for different contexts
6. **Expression DSL** — Human-readable, agent-friendly syntax for selective loading
7. **Generated artifacts** — `npl-full.md` is always derivable from conventions; CI-guardable
