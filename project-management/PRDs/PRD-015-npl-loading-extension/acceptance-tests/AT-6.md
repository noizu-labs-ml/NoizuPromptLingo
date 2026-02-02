# AT-6: Error Handling Tests

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
