# PRD-012: NPL Advanced Loading Extension

**Version**: 1.0
**Status**: Draft
**Author**: npl-prd-editor
**Created**: 2026-02-02
**Updated**: 2026-02-02

---

## Overview

Extend the NPL loading mechanism beyond the current syntax section to support all NPL sections: directives, fences, pumps, formatting, prefixes, special-sections, and declarations. This enables users and agents to load specific NPL components using expressive query syntax with priority filtering, cross-section combinations, and flexible layout strategies.

### Goals

1. Enable loading of any NPL section using consistent expression syntax
2. Support priority filtering across all sections
3. Enable cross-section expressions with additions and subtractions
4. Maintain backward compatibility with existing syntax section loading
5. Achieve 80%+ test coverage for all new code

### Non-Goals

- Modifying the underlying YAML schema of NPL sections
- Creating new layout strategies (use existing: yaml-order, classic, grouped)
- Building a full NPL parser (covered by PRD-013)

---

## User Stories

### US-001: Load Directives Section with Priority Filtering

| Field | Value |
|-------|-------|
| ID | US-001 |
| Title | Load Directives Section with Priority Filtering |
| Priority | High |
| Story Points | 5 |
| Related Personas | P-001 (AI Agent), P-003 (Vibe Coder) |

**Description**: As a user, I want to load NPL directives using expressions like `directive#table-formatting:+2` to get the table-formatting directive with priority 0-2 examples.

**Acceptance Criteria**:
- AC-1.1: Can load entire directive section: `directive`
- AC-1.2: Can load specific directive: `directive#table-formatting`
- AC-1.3: Can filter by priority: `directive#interactive-element:+3`
- AC-1.4: Supports all directive identifiers (table-formatting, diagram-visualization, temporal-control, template-integration, interactive-element, identifier-management, explanatory-note, section-reference, explicit-instruction, todo-task)
- AC-1.5: Invalid directive names return clear error messages

---

### US-002: Load Fences Section with All Layout Strategies

| Field | Value |
|-------|-------|
| ID | US-002 |
| Title | Load Fences Section with All Layout Strategies |
| Priority | High |
| Story Points | 3 |
| Related Personas | P-003 (Vibe Coder) |

**Description**: As a documentation generator, I want to load fence definitions with all three layout strategies (yaml-order, classic, grouped).

**Acceptance Criteria**:
- AC-2.1: Can load all fences: `fences`
- AC-2.2: Works with yaml-order layout (preserves YAML definition order)
- AC-2.3: Works with classic layout (with fence categories if defined)
- AC-2.4: Works with grouped layout (grouped by type/category)
- AC-2.5: Output is valid markdown
- AC-2.6: Layout strategy is configurable per request

---

### US-003: Load Pumps Section with Complex Expressions

| Field | Value |
|-------|-------|
| ID | US-003 |
| Title | Load Pumps Section with Complex Expressions |
| Priority | Medium |
| Story Points | 5 |
| Related Personas | P-001 (AI Agent), Prompt Engineer |

**Description**: As a prompt engineer, I want to load reasoning pumps with expressions like `pumps#intent-declaration:+2+pumps#critical-analysis:+1`.

**Acceptance Criteria**:
- AC-3.1: Can load all pumps: `pumps`
- AC-3.2: Can load specific pump: `pumps#chain-of-thought`
- AC-3.3: Can combine multiple pumps with `+`: `pumps#intent-declaration+chain-of-thought`
- AC-3.4: Can subtract pumps: `pumps -pumps#tangential-exploration`
- AC-3.5: Priority filtering works correctly: `pumps#self-assessment:+1`
- AC-3.6: Pump identifiers match slugs: intent-declaration, chain-of-thought, self-assessment, tangential-exploration, critical-analysis, evaluation-framework, emotional-context

---

### US-004: Cross-Section Loading with Additions and Subtractions

| Field | Value |
|-------|-------|
| ID | US-004 |
| Title | Cross-Section Loading with Additions and Subtractions |
| Priority | Medium |
| Story Points | 4 |
| Related Personas | P-003 (Vibe Coder) |

**Description**: As a system builder, I want to load across multiple sections with complex expressions like `syntax directive -syntax#literal-string`.

**Acceptance Criteria**:
- AC-4.1: Can mix sections: `syntax directive`
- AC-4.2: Can subtract from sections: `syntax -syntax#literal-string`
- AC-4.3: Can mix specific and section loads: `syntax#placeholder pumps#intent-declaration`
- AC-4.4: All validation works correctly (invalid sections, invalid components)
- AC-4.5: Clear error messages for invalid expressions
- AC-4.6: Order of operations: load full sections first, then apply additions, then subtractions

---

### US-005: Generate Coverage Reports for All Loaded Components

| Field | Value |
|-------|-------|
| ID | US-005 |
| Title | Generate Coverage Reports for All Loaded Components |
| Priority | High |
| Story Points | 2 |
| Related Personas | P-003 (Vibe Coder) |

**Description**: As a QA engineer, I want to verify test coverage for all extended loading functionality.

**Acceptance Criteria**:
- AC-5.1: All new code has >= 80% coverage
- AC-5.2: Coverage reports generated by `mise run test-coverage`
- AC-5.3: Critical paths (parser, resolver, filter) have 100% coverage
- AC-5.4: Report shows gaps and uncovered branches
- AC-5.5: No regression in existing test coverage

---

## Functional Requirements

### FR-1: Expression Parser Extension

**Description**: Extend the NPL expression parser to recognize all section types.

**Interface**:
```python
from dataclasses import dataclass
from enum import Enum
from typing import List, Optional

class NPLSection(Enum):
    """All loadable NPL sections."""
    SYNTAX = "syntax"
    DECLARATIONS = "declarations"
    DIRECTIVES = "directives"
    PREFIXES = "prefixes"
    PROMPT_SECTIONS = "prompt-sections"
    SPECIAL_SECTIONS = "special-sections"
    PUMPS = "pumps"
    FENCES = "fences"

@dataclass
class NPLComponent:
    """A parsed NPL component reference."""
    section: NPLSection
    component: Optional[str]  # None means entire section
    priority_max: Optional[int]  # None means all priorities

@dataclass
class NPLExpression:
    """A parsed NPL loading expression."""
    additions: List[NPLComponent]
    subtractions: List[NPLComponent]

def parse_expression(expr: str) -> NPLExpression:
    """Parse an NPL loading expression.

    Examples:
        - "syntax" -> load entire syntax section
        - "syntax#placeholder" -> load specific component
        - "syntax#placeholder:+2" -> load with priority filter
        - "syntax directive" -> load multiple sections
        - "syntax -syntax#literal" -> load with subtraction

    Raises:
        NPLParseError: If expression is invalid
    """
```

**Behavior**:
- Given expression `"directive"`
- When parsed
- Then returns NPLExpression with additions=[NPLComponent(DIRECTIVES, None, None)]

- Given expression `"directive#table-formatting:+2"`
- When parsed
- Then returns NPLExpression with additions=[NPLComponent(DIRECTIVES, "table-formatting", 2)]

- Given expression `"syntax pumps -syntax#omission"`
- When parsed
- Then returns NPLExpression with:
  - additions=[NPLComponent(SYNTAX, None, None), NPLComponent(PUMPS, None, None)]
  - subtractions=[NPLComponent(SYNTAX, "omission", None)]

**Edge Cases**:
- Empty expression: raise NPLParseError("Empty expression")
- Invalid section: raise NPLParseError("Unknown section: xyz")
- Invalid component: raise NPLParseError("Unknown component 'foo' in section 'syntax'")
- Invalid priority format: raise NPLParseError("Invalid priority format: +abc")

---

### FR-2: Section Resolver

**Description**: Resolve NPL components to their YAML definitions.

**Interface**:
```python
from typing import Dict, Any, List
from pathlib import Path

@dataclass
class ResolvedComponent:
    """A resolved NPL component with its data."""
    section: NPLSection
    name: str
    slug: str
    brief: str
    description: str
    syntax: List[Dict[str, Any]]
    examples: List[Dict[str, Any]]
    labels: List[str]
    require: List[str]
    priority_filtered: bool  # True if examples were filtered by priority

class NPLResolver:
    """Resolves NPL expressions to component data."""

    def __init__(self, npl_dir: Path):
        """Initialize resolver with path to NPL YAML files."""

    def resolve(self, expression: NPLExpression) -> List[ResolvedComponent]:
        """Resolve expression to list of components.

        Applies additions first, then subtractions.
        Validates all component references exist.

        Raises:
            NPLResolveError: If component not found
        """

    def get_section_components(self, section: NPLSection) -> List[str]:
        """Get list of component slugs in a section."""

    def validate_component(self, section: NPLSection, component: str) -> bool:
        """Check if component exists in section."""
```

**Behavior**:
- Given expression references `directive#table-formatting`
- When resolved
- Then returns ResolvedComponent with table-formatting data from directives.yaml

- Given expression has priority filter `:+2`
- When resolved
- Then examples with priority > 2 are excluded

- Given expression has subtraction `-syntax#literal-string`
- When resolved
- Then literal-string component is excluded from results

**Edge Cases**:
- Missing YAML file: raise NPLResolveError("Section file not found: directives.yaml")
- Component not in section: raise NPLResolveError("Component 'foo' not found in directives")
- Malformed YAML: raise NPLResolveError("Invalid YAML in directives.yaml: ...")

---

### FR-3: Priority Filter

**Description**: Filter component examples by priority level.

**Interface**:
```python
from typing import List, Dict, Any

def filter_by_priority(
    examples: List[Dict[str, Any]],
    max_priority: int
) -> List[Dict[str, Any]]:
    """Filter examples to include only those with priority <= max_priority.

    Examples without priority field are treated as priority 0.

    Args:
        examples: List of example dictionaries with optional 'priority' field
        max_priority: Maximum priority to include (inclusive)

    Returns:
        Filtered list of examples
    """
```

**Behavior**:
- Given examples with priorities [0, 1, 2, 3]
- When filtered with max_priority=2
- Then returns examples with priorities [0, 1, 2]

- Given examples without priority field
- When filtered with any max_priority >= 0
- Then those examples are included (treated as priority 0)

**Edge Cases**:
- Empty examples list: return empty list
- Negative max_priority: return empty list
- All examples filtered out: return empty list with warning

---

### FR-4: Layout Strategies

**Description**: Format resolved components using configurable layout strategies.

**Interface**:
```python
from enum import Enum
from typing import List

class LayoutStrategy(Enum):
    """Available layout strategies for output formatting."""
    YAML_ORDER = "yaml-order"      # Preserve YAML definition order
    CLASSIC = "classic"            # Category-based organization
    GROUPED = "grouped"            # Group by type/labels

class NPLLayoutEngine:
    """Formats resolved components into markdown output."""

    def __init__(self, strategy: LayoutStrategy = LayoutStrategy.YAML_ORDER):
        """Initialize with layout strategy."""

    def format(self, components: List[ResolvedComponent]) -> str:
        """Format components into markdown string.

        Returns:
            Markdown formatted string with all components
        """

    def format_component(self, component: ResolvedComponent) -> str:
        """Format a single component to markdown."""

    def format_examples(self, examples: List[Dict[str, Any]]) -> str:
        """Format component examples to markdown."""
```

**Behavior**:
- Given YAML_ORDER strategy
- When formatting components
- Then components appear in their YAML definition order

- Given CLASSIC strategy
- When formatting components
- Then components are organized by their category/labels

- Given GROUPED strategy
- When formatting components
- Then components are grouped by type (e.g., all pumps together)

**Edge Cases**:
- Empty component list: return empty string
- Component with no examples: format syntax/description only
- Mixed sections with GROUPED: group by section type

---

### FR-5: Unified Loading API

**Description**: Provide a single entry point for NPL loading.

**Interface**:
```python
from pathlib import Path
from typing import Optional

def load_npl(
    expression: str,
    npl_dir: Path = Path("npl"),
    layout: LayoutStrategy = LayoutStrategy.YAML_ORDER,
    include_instructional: bool = False
) -> str:
    """Load NPL components based on expression.

    Args:
        expression: NPL loading expression (e.g., "syntax#placeholder:+2")
        npl_dir: Path to NPL YAML files directory
        layout: Layout strategy for output formatting
        include_instructional: Include instructional/notes sections

    Returns:
        Markdown formatted NPL content

    Raises:
        NPLParseError: Invalid expression syntax
        NPLResolveError: Component not found
        NPLLoadError: General loading error
    """
```

**Behavior**:
- Given valid expression `"directive#table-formatting:+1"`
- When load_npl called
- Then returns markdown with table-formatting directive, priority 0-1 examples only

- Given cross-section expression `"syntax pumps"`
- When load_npl called
- Then returns markdown with all syntax components followed by all pumps

---

## Non-Functional Requirements

| ID | Requirement | Metric | Target |
|----|-------------|--------|--------|
| NFR-1 | Test coverage for new code | Line coverage | >= 80% |
| NFR-2 | Critical path coverage | Branch coverage | 100% |
| NFR-3 | Parse expression performance | Time | < 10ms |
| NFR-4 | Resolve expression performance | Time | < 100ms for full section |
| NFR-5 | Backward compatibility | Existing tests | All pass |
| NFR-6 | Error message quality | Contains context | Always |

---

## Error Handling

| Error Condition | Error Type | User Message |
|-----------------|------------|--------------|
| Empty expression | NPLParseError | "Expression cannot be empty" |
| Unknown section | NPLParseError | "Unknown section: '{section}'. Valid sections: syntax, directives, pumps, ..." |
| Unknown component | NPLResolveError | "Component '{component}' not found in section '{section}'" |
| Invalid priority | NPLParseError | "Invalid priority format: '{value}'. Use :+N where N is a number" |
| Missing YAML file | NPLResolveError | "Section file not found: {path}" |
| YAML parse error | NPLResolveError | "Invalid YAML in {file}: {details}" |
| Subtraction of non-loaded | NPLResolveError | "Cannot subtract '{component}' - not in loaded set" |

---

## Acceptance Tests

The following tests should be created by npl-tdd-tester:

### AT-1: Section Loading Tests

```python
class TestSectionLoading:
    """Test loading each NPL section."""

    def test_load_syntax_section(self):
        """Load entire syntax section."""
        result = load_npl("syntax")
        assert "qualifier" in result
        assert "placeholder" in result
        assert "in-fill" in result

    def test_load_directives_section(self):
        """Load entire directives section."""
        result = load_npl("directives")
        assert "table-formatting" in result
        assert "diagram-visualization" in result

    def test_load_pumps_section(self):
        """Load entire pumps section."""
        result = load_npl("pumps")
        assert "intent-declaration" in result
        assert "chain-of-thought" in result

    def test_load_fences_section(self):
        """Load fences section (if exists)."""
        # Test once fences.yaml is defined

    def test_load_prefixes_section(self):
        """Load entire prefixes section."""
        result = load_npl("prefixes")
        # Verify prefix components

    def test_load_special_sections_section(self):
        """Load special-sections."""
        result = load_npl("special-sections")
        # Verify special section components

    def test_load_declarations_section(self):
        """Load declarations section."""
        result = load_npl("declarations")
        # Verify declaration components
```

### AT-2: Component Loading Tests

```python
class TestComponentLoading:
    """Test loading specific components."""

    def test_load_specific_syntax_component(self):
        """Load specific syntax component by slug."""
        result = load_npl("syntax#placeholder")
        assert "placeholder" in result
        assert "qualifier" not in result  # Other components excluded

    def test_load_specific_directive(self):
        """Load specific directive."""
        result = load_npl("directives#table-formatting")
        assert "table-formatting" in result
        assert "diagram-visualization" not in result

    def test_load_specific_pump(self):
        """Load specific pump."""
        result = load_npl("pumps#chain-of-thought")
        assert "chain-of-thought" in result
        assert "self-assessment" not in result
```

### AT-3: Priority Filtering Tests

```python
class TestPriorityFiltering:
    """Test priority filtering per section."""

    def test_priority_filter_syntax(self):
        """Filter syntax examples by priority."""
        result = load_npl("syntax#qualifier:+0")
        assert "priority: 0" in result or "basic-qualifier" in result
        # Priority 1, 2 examples should be excluded

    def test_priority_filter_directive(self):
        """Filter directive examples by priority."""
        result = load_npl("directives#table-formatting:+1")
        # Should include priority 0, 1 examples only

    def test_priority_filter_pumps(self):
        """Filter pump examples by priority."""
        result = load_npl("pumps#chain-of-thought:+0")
        # Should include only priority 0 examples

    def test_priority_filter_preserves_component_info(self):
        """Filtering doesn't remove component description."""
        result = load_npl("syntax#placeholder:+0")
        assert "placeholder" in result
        assert "Mark locations where" in result  # Description preserved
```

### AT-4: Cross-Section Expression Tests

```python
class TestCrossSectionExpressions:
    """Test cross-section expressions with + and -."""

    def test_add_multiple_sections(self):
        """Combine multiple sections."""
        result = load_npl("syntax directives")
        assert "placeholder" in result
        assert "table-formatting" in result

    def test_add_specific_components_across_sections(self):
        """Combine specific components from different sections."""
        result = load_npl("syntax#placeholder pumps#intent-declaration")
        assert "placeholder" in result
        assert "intent-declaration" in result
        assert "qualifier" not in result

    def test_subtract_component_from_section(self):
        """Subtract specific component from loaded section."""
        result = load_npl("syntax -syntax#literal-string")
        assert "placeholder" in result
        assert "literal-string" not in result

    def test_complex_expression(self):
        """Complex expression with multiple operations."""
        result = load_npl("syntax directives#table-formatting:+1 -syntax#omission")
        assert "placeholder" in result
        assert "table-formatting" in result
        assert "omission" not in result

    def test_subtract_nonexistent_warns(self):
        """Subtracting non-loaded component produces warning."""
        # Should not error, but may log warning
        result = load_npl("syntax#placeholder -syntax#in-fill")
        assert "placeholder" in result
```

### AT-5: Layout Strategy Tests

```python
class TestLayoutStrategies:
    """Test layout strategies with all content types."""

    def test_yaml_order_layout(self):
        """YAML order preserves definition order."""
        result = load_npl("syntax", layout=LayoutStrategy.YAML_ORDER)
        # Verify components appear in YAML file order

    def test_classic_layout(self):
        """Classic layout organizes by category."""
        result = load_npl("directives", layout=LayoutStrategy.CLASSIC)
        # Verify category-based organization

    def test_grouped_layout(self):
        """Grouped layout groups by type."""
        result = load_npl("syntax pumps", layout=LayoutStrategy.GROUPED)
        # Verify grouping (all syntax together, all pumps together)

    def test_layout_produces_valid_markdown(self):
        """All layouts produce valid markdown."""
        for strategy in LayoutStrategy:
            result = load_npl("syntax", layout=strategy)
            # Basic markdown validity checks
            assert "##" in result or "#" in result  # Has headings
```

### AT-6: Error Handling Tests

```python
class TestErrorHandling:
    """Test error handling for invalid inputs."""

    def test_empty_expression_error(self):
        """Empty expression raises clear error."""
        with pytest.raises(NPLParseError, match="empty"):
            load_npl("")

    def test_unknown_section_error(self):
        """Unknown section name raises clear error."""
        with pytest.raises(NPLParseError, match="Unknown section"):
            load_npl("foobar")

    def test_unknown_component_error(self):
        """Unknown component raises clear error."""
        with pytest.raises(NPLResolveError, match="not found"):
            load_npl("syntax#nonexistent")

    def test_invalid_priority_format_error(self):
        """Invalid priority format raises clear error."""
        with pytest.raises(NPLParseError, match="priority"):
            load_npl("syntax#placeholder:+abc")

    def test_negative_priority_error(self):
        """Negative priority raises clear error."""
        with pytest.raises(NPLParseError, match="priority"):
            load_npl("syntax#placeholder:-1")

    def test_error_messages_include_context(self):
        """Error messages include helpful context."""
        try:
            load_npl("syntax#nonexistent")
        except NPLResolveError as e:
            assert "syntax" in str(e)
            assert "nonexistent" in str(e)
```

### AT-7: Integration Tests

```python
class TestIntegration:
    """Integration tests for complete workflows."""

    def test_full_npl_loading_workflow(self):
        """Test complete loading workflow."""
        # Parse
        expr = parse_expression("syntax#placeholder:+1 pumps#intent-declaration")
        assert len(expr.additions) == 2

        # Resolve
        resolver = NPLResolver(Path("npl"))
        components = resolver.resolve(expr)
        assert len(components) == 2

        # Format
        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format(components)
        assert "placeholder" in result
        assert "intent-declaration" in result

    def test_backward_compatibility_syntax_loading(self):
        """Existing syntax loading still works."""
        # Test that syntax section loading works as before
        result = load_npl("syntax")
        assert "qualifier" in result
        assert "placeholder" in result

    def test_all_sections_loadable(self):
        """Verify all defined sections can be loaded."""
        for section in NPLSection:
            try:
                result = load_npl(section.value)
                assert len(result) > 0
            except NPLResolveError:
                # Section file may not exist yet, that's OK
                pass
```

---

## Success Criteria

1. **All 5 user stories fully implemented** with all acceptance criteria passing
2. **Test coverage >= 80%** for all new code (measured by `mise run test-coverage`)
3. **Critical paths have 100% coverage**: parser, resolver, priority filter
4. **All existing tests still pass** (no regressions)
5. **Cross-section expressions work correctly** for all combinations
6. **Error messages are clear and actionable** with context
7. **Performance meets targets**: parse < 10ms, resolve < 100ms

---

## Implementation Notes

### Directory Structure

```
src/npl_mcp/npl/
    __init__.py
    parser.py          # Expression parser (FR-1)
    resolver.py        # Section resolver (FR-2)
    filters.py         # Priority filter (FR-3)
    layout.py          # Layout strategies (FR-4)
    loader.py          # Unified API (FR-5)
    exceptions.py      # Custom exceptions

tests/npl/
    test_parser.py
    test_resolver.py
    test_filters.py
    test_layout.py
    test_loader.py
    test_integration.py
```

### Expression Grammar

```
expression      := term (WS term)*
term            := addition | subtraction
addition        := section_ref
subtraction     := '-' section_ref
section_ref     := section ('#' component)? (':' priority)?
section         := 'syntax' | 'directives' | 'pumps' | 'prefixes' |
                   'special-sections' | 'declarations' | 'prompt-sections' | 'fences'
component       := SLUG
priority        := '+' NUMBER
SLUG            := [a-z][a-z0-9-]*
NUMBER          := [0-9]+
WS              := ' '+
```

### NPL Section Files

| Section | File | Components Field |
|---------|------|------------------|
| syntax | syntax.yaml | components |
| directives | directives.yaml | components |
| pumps | pumps.yaml | components |
| prefixes | prefixes.yaml | components |
| special-sections | special-sections.yaml | components |
| declarations | declarations.yaml | components |
| prompt-sections | prompt-sections.yaml | components |
| fences | fences.yaml | components (if exists) |

---

## Out of Scope

- Creating new NPL sections (schema changes)
- Building visual UI for expression building
- Real-time validation/autocomplete
- NPL syntax parsing/AST (see PRD-013)
- MCP tool integration (future PRD)

---

## Dependencies

- Existing NPL YAML files in `npl/` directory
- PyYAML for YAML parsing
- pytest for testing
- pytest-cov for coverage reporting

---

## Open Questions

- [ ] Q1: Should `fences` section be created if it doesn't exist?
- [ ] Q2: Should `include_instructional` flag be supported for sections that have instructional content?
- [ ] Q3: Should we support regex patterns in component selection (e.g., `syntax#*fill*`)?

---

## References

- User Stories: `/project-management/user-stories/advanced-loading-extension.yaml`
- Architecture: `/docs/PROJ-ARCH.md`
- NPL Syntax YAML: `/npl/syntax.yaml`
- NPL Directives YAML: `/npl/directives.yaml`
- NPL Pumps YAML: `/npl/pumps.yaml`
- Existing PRD: `PRD-013-npl-syntax-parser.md`
