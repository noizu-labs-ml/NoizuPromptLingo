# AT-006: Markdown Agent Definition Parsing

**Category**: Unit
**Related FR**: FR-009
**Status**: Not Started

## Description

Validates that agent definitions can be parsed from markdown files with YAML frontmatter.

## Test Implementation

```python
def test_parse_markdown_agent_file():
    """Test parsing agent definition from markdown."""
    # Setup: Create markdown file with frontmatter
    agent_file = Path("test_agent.md")
    agent_file.write_text("""---
agent:
  id: test-agent
  version: 1.0.0
  name: Test Agent
  category: core
  prompts:
    system: "You are a test agent"
---

# Test Agent

## Capabilities

### Test Capability
Performs test operations.
""")

    # Action: Parse file
    definition = parse_agent_file(agent_file)

    # Assert: Metadata extracted
    assert definition.id == "test-agent"
    assert definition.version == "1.0.0"
    assert definition.name == "Test Agent"
    assert definition.category == "core"
    assert "You are a test agent" in definition.prompts.system
    assert definition.body  # Markdown body preserved

def test_parse_invalid_frontmatter():
    """Test error handling for invalid YAML."""
    agent_file = Path("invalid_agent.md")
    agent_file.write_text("""---
agent:
  id: test
  invalid: [unclosed
---
""")

    with pytest.raises(ParseError):
        parse_agent_file(agent_file)
```

## Acceptance Criteria

- [ ] YAML frontmatter extracted correctly
- [ ] Markdown body preserved
- [ ] Invalid YAML raises ParseError
- [ ] Missing frontmatter raises ParseError
- [ ] All fields parsed with correct types

## Coverage

Covers:
- Successful parsing
- YAML extraction
- Markdown body handling
- Error conditions
- Edge cases (empty body, multiple documents)
