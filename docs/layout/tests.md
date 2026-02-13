# Test Suite Layout

```
tests/
├── assets/                             # Test fixture files (markdown, etc.)
├── test_markdown_converter.py          # Markdown conversion tests
├── test_markdown_viewer.py             # Markdown viewer + filter tests
├── test_markdown_viewer_assets.py      # Asset-based viewer tests
├── test_markdown_cache.py              # Cache behavior tests
├── test_heading_filter.py              # Heading path filter tests
├── test_asset_filter_nihilism.py       # Null/empty filter edge cases
├── test_npl_loading.py                 # NPL YAML loader tests
├── test_pm_mcp_tools.py               # PM tools (PRD/story/persona) tests
├── test_meta_tools.py                  # Meta tool catalog/search tests
└── test_mcp_server.py                  # SSE client tests (require live server)
```

## Notes

- Run with `mise run test` or `uv run -m pytest tests/`
- `test_mcp_server.py` requires a running server — use `--ignore` for CI
- 619+ tests passing as of last count
