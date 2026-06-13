# AT-3: Priority Filtering Tests

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
