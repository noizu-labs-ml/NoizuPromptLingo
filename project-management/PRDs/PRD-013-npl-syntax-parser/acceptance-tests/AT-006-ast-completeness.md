# AT-006: AST Preserves All Structural Information

**Category**: Unit
**Related FR**: FR-003
**Status**: Not Started

## Description

Validates that the AST representation preserves all structural information from the original document.

## Test Implementation

```python
def test_ast_preserves_structure():
    """Test that AST contains all original document structure."""
    # Setup: Document with known structure
    doc_content = """
---
title: Test Document
version: 1.0
---

# Main Section

⟪🧠cot⟫ Think step by step

## Subsection

```python
def example():
    pass
```

@gopher-scout analyze this
"""

    # Action: Parse to AST
    parser = NPLParser()
    ast = parser.parse(doc_content)

    # Assert: Frontmatter preserved
    assert ast.frontmatter is not None
    assert ast.frontmatter["title"] == "Test Document"

    # Assert: Sections hierarchy preserved
    assert len(ast.sections) == 1
    assert ast.sections[0].heading == "Main Section"
    assert len(ast.sections[0].subsections) == 1

    # Assert: All syntax elements captured
    elements = ast.elements
    assert any(e.element_type == "chain-of-thought" for e in elements)
    assert any(e.element_type == "code-fence" for e in elements)
    assert any(e.element_type == "agent-invoke" for e in elements)

    # Assert: Position information accurate
    for element in elements:
        assert element.line_start > 0
        assert element.line_end >= element.line_start
        assert element.column_start >= 0

def test_ast_serialization():
    """Test that AST can be serialized and deserialized."""
    # Setup: Parse document
    parser = NPLParser()
    ast = parser.parse_file(Path("fixtures/valid/agent.md"))

    # Action: Serialize to JSON
    import json
    json_str = json.dumps(ast.to_dict())

    # Action: Deserialize
    data = json.loads(json_str)
    reconstructed = NPLDocument.from_dict(data)

    # Assert: Structure preserved
    assert reconstructed.frontmatter == ast.frontmatter
    assert len(reconstructed.sections) == len(ast.sections)
    assert len(reconstructed.elements) == len(ast.elements)
```

## Acceptance Criteria

- [ ] Frontmatter preserved in AST
- [ ] Section hierarchy preserved
- [ ] All syntax elements captured with metadata
- [ ] Position information accurate (line/column)
- [ ] AST serializable to JSON/YAML
- [ ] AST deserializable without data loss

## Coverage

Covers:
- AST completeness
- Structure preservation
- Serialization/deserialization
- Position tracking
