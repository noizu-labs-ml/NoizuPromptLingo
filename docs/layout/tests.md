# Test Suite Layout

```
tests/
├── assets/                             # Test fixture files (markdown, HTML, PDF)
├── test_asset_filter_nihilism.py       # Null/empty filter edge cases
├── test_db_personas.py                 # Database-backed persona tool tests
├── test_db_projects.py                 # Database-backed project tool tests
├── test_db_stories.py                  # Database-backed story tool tests
├── test_download.py                    # Download tool tests
├── test_heading_filter.py              # Heading path filter tests
├── test_instruction_embeddings.py      # Instruction vector embedding tests
├── test_instructions.py               # Instruction CRUD tests
├── test_markdown_cache.py              # Cache behavior tests
├── test_markdown_converter.py          # Markdown conversion tests
├── test_markdown_viewer.py             # Markdown viewer + filter tests
├── test_markdown_viewer_assets.py      # Asset-based viewer tests
├── test_mcp_server.py                  # SSE client tests (require live server)
├── test_meta_tools.py                  # Meta tool catalog/search/definition/help tests
├── test_npl_loading.py                 # NPL YAML loader tests
├── test_ping.py                        # Ping tool tests
├── test_pm_mcp_tools.py               # PM tools (PRD/story/persona) tests
├── test_projects.py                    # Project management tests
├── test_rest.py                        # REST client tool tests
├── test_screenshot.py                  # Screenshot tool tests
├── test_secrets.py                     # Secret management tool tests
├── test_to_markdown.py                 # ToMarkdown tool tests
├── test_to_markdown_strip.py           # Jina markdown stripping tests
├── test_tool_registry.py              # Tool registry mapping tests
└── test_tool_sessions.py              # Tool session lifecycle tests
```

## Notes

- Run with `uv run -m pytest tests/`
- `test_mcp_server.py` requires a running server — use `--ignore` for CI
- 25 test files covering markdown, NPL, PM tools, meta tools, browser, instructions, sessions
