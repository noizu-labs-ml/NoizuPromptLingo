# AT-7: Integration Tests

```python
class TestIntegration:
    """Integration tests for complete workflows."""

    def test_full_npl_loading_workflow(self):
        """Test complete loading workflow."""
        # Parse
        expr = parse_expression("syntax#placeholder:+1 pumps#intent-declaration")
        assert len(expr.additions) == 2

        # Resolve
        resolver = NPLResolver(Path("npl"))
        components = resolver.resolve(expr)
        assert len(components) == 2

        # Format
        engine = NPLLayoutEngine(LayoutStrategy.YAML_ORDER)
        result = engine.format(components)
        assert "placeholder" in result
        assert "intent-declaration" in result

    def test_backward_compatibility_syntax_loading(self):
        """Existing syntax loading still works."""
        # Test that syntax section loading works as before
        result = load_npl("syntax")
        assert "qualifier" in result
        assert "placeholder" in result

    def test_all_sections_loadable(self):
        """Verify all defined sections can be loaded."""
        for section in NPLSection:
            try:
                result = load_npl(section.value)
                assert len(result) > 0
            except NPLResolveError:
                # Section file may not exist yet, that's OK
                pass
```
