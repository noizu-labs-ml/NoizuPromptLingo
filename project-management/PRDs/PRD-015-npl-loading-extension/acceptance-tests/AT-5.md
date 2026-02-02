# AT-5: Layout Strategy Tests

```python
class TestLayoutStrategies:
    """Test layout strategies with all content types."""

    def test_yaml_order_layout(self):
        """YAML order preserves definition order."""
        result = load_npl("syntax", layout=LayoutStrategy.YAML_ORDER)
        # Verify components appear in YAML file order

    def test_classic_layout(self):
        """Classic layout organizes by category."""
        result = load_npl("directives", layout=LayoutStrategy.CLASSIC)
        # Verify category-based organization

    def test_grouped_layout(self):
        """Grouped layout groups by type."""
        result = load_npl("syntax pumps", layout=LayoutStrategy.GROUPED)
        # Verify grouping (all syntax together, all pumps together)

    def test_layout_produces_valid_markdown(self):
        """All layouts produce valid markdown."""
        for strategy in LayoutStrategy:
            result = load_npl("syntax", layout=strategy)
            # Basic markdown validity checks
            assert "##" in result or "#" in result  # Has headings
```
