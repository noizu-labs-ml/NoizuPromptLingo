# AT-1: Section Loading Tests

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
