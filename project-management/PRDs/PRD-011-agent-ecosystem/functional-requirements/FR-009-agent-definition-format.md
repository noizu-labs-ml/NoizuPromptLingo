# FR-009: Markdown-Based Agent Definition Format

**Status**: Draft

## Description

The system must parse agent definitions from markdown files with YAML frontmatter, supporting both metadata and descriptive content.

## Interface

```python
def parse_agent_file(path: Path) -> AgentDefinition:
    """Parse agent definition from markdown file.

    Args:
        path: Path to agent definition file

    Returns:
        Parsed agent definition

    Raises:
        ParseError: If YAML frontmatter is invalid
        ValidationError: If required fields are missing
    """
```

## Behavior

- **Given** a markdown file with YAML frontmatter
- **When** parsed
- **Then** YAML metadata is extracted and validated, markdown body is preserved

**Expected Format**:
```markdown
---
agent:
  id: agent-name
  version: 1.0.0
  category: core
  ...
---

# Agent Name

## System Prompt

You are Agent Name...

## Capabilities

### Capability 1
...
```

## Edge Cases

- **Missing frontmatter delimiter**: Parse error
- **Invalid YAML syntax**: Parse error with line number
- **Empty markdown body**: Allowed, use only frontmatter
- **Multiple YAML documents**: Use first document only

## Related User Stories

- US-005: Agent Capability Documentation

## Test Coverage

Expected test count: 8 tests
Target coverage: 100% for this FR
