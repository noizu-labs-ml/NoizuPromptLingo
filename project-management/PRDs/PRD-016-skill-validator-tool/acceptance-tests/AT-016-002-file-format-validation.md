# AT-016-002: File Format Validation

**Category**: Unit
**Related FR**: FR-016-002
**Status**: Not Started

## Description

Validates that file format validators correctly parse and validate YAML, Parquet, and Markdown files.

## Test Implementation

```python
def test_yaml_validation_valid():
    """Test YAML validator accepts valid YAML files."""
    yaml_content = """
    examples:
      - id: ex-001
        title: "Example"
        file: example.md
    """
    result = validate_yaml_file("test.yaml", yaml_content)
    assert result.is_valid

def test_parquet_validation_columns():
    """Test Parquet validator checks required columns."""
    df = pd.DataFrame({
        "prompt": ["test prompt"],
        "response": ["test response"],
        "metadata": ['{"key": "value"}']
    })
    df.to_parquet("test.parquet")
    result = validate_parquet_file("test.parquet", ["prompt", "response", "metadata"])
    assert result.is_valid
    assert result.row_count == 1

def test_markdown_validation_sections():
    """Test Markdown validator checks required sections."""
    md_content = """
    # Title
    ## Overview
    ## When to Use
    ## Process
    """
    result = validate_markdown_file("test.md", md_content)
    assert result.has_section("Overview")
    assert result.has_section("Process")
```

## Acceptance Criteria

- [ ] YAML files parsed and validated against schema
- [ ] Parquet files validated for required columns
- [ ] Markdown files checked for required sections
- [ ] Clear error messages for format issues
