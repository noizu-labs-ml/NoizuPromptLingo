# AT-2: Component Loading Tests

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
