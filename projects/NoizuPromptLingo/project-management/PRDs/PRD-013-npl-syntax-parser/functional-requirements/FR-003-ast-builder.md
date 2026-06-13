# FR-003: AST Builder

**Status**: Draft

## Description

The AST builder constructs structured Abstract Syntax Tree representation of parsed NPL documents, preserving all structural information and metadata.

## Interface

```python
@dataclass
class NPLDocument:
    """AST root for parsed NPL document."""
    frontmatter: dict | None
    sections: list[Section]
    agents: list[AgentDefinition]
    elements: list[SyntaxElement]

@dataclass
class Section:
    """Document section."""
    heading: str
    level: int
    content: list[ContentBlock]
    subsections: list[Section]

@dataclass
class SyntaxElement:
    """Parsed syntax element."""
    element_type: str
    category: str
    content: str
    line_start: int
    line_end: int
    column_start: int
    column_end: int
    metadata: dict

@dataclass
class AgentDefinition:
    """Parsed agent definition."""
    id: str
    name: str
    version: str
    capabilities: list[Capability]
    prompts: dict[str, str]
    configuration: dict
```

## Behavior

- **Given** tokenized NPL document
- **When** AST builder processes tokens
- **Then** returns hierarchical NPLDocument with nested sections

- **Given** document with agent definition
- **When** AST includes AgentDefinition node
- **Then** all agent metadata is extracted and structured

- **Given** syntax element at specific location
- **When** AST includes SyntaxElement
- **Then** line_start/line_end/column_start/column_end are accurate

## Edge Cases

- **Empty sections**: Section with no content creates empty content list
- **Deeply nested sections**: Supports arbitrary nesting depth
- **Complex agent definitions**: Handles all agent schema variations
- **Metadata preservation**: All original formatting preserved in metadata

## Related User Stories

- US-087: AST Representation for Programmatic Analysis
- US-082: Extract Metadata from Agent Definition Files
- US-083: IDE Integration for NPL Syntax Highlighting

## Test Coverage

Expected test count: 15-20 tests
Target coverage: 100% for AST construction
