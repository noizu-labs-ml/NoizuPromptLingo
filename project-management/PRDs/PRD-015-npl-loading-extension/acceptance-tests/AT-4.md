# AT-4: Cross-Section Expression Tests

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
