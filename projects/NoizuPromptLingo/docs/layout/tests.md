# Test Suite Layout

```
tests/
├── assets/                             # Test fixture files (markdown, HTML, PDF, nihilism)
├── conftest.py                         # Shared fixtures (_mcp_app session scope, cache clearing)
│
├── test_agents_module.py               # agents/ module unit tests
├── test_agents_tools.py                # Agent tool integration tests
├── test_artifacts.py                   # Artifact CRUD + revision tests
├── test_asset_filter_nihilism.py       # Null/empty filter edge cases
├── test_catalog_migration.py           # Tool catalog migration tests
├── test_db_personas.py                 # Database-backed persona tool tests
├── test_db_projects.py                 # Database-backed project tool tests
├── test_db_stories.py                  # Database-backed story tool tests
├── test_download.py                    # Download tool tests
├── test_generic_sessions.py            # Generic session lifecycle tests
├── test_heading_filter.py              # Heading path filter tests
├── test_instruction_embeddings.py      # Instruction vector embedding tests
├── test_instructions.py                # Instruction CRUD tests
├── test_launcher_logging.py            # Launcher log output tests
├── test_markdown_cache.py              # Cache behavior tests
├── test_markdown_converter.py          # Markdown conversion tests
├── test_markdown_viewer.py             # Markdown viewer + filter tests
├── test_markdown_viewer_assets.py      # Asset-based viewer tests
├── test_mcp_server.py                  # SSE client tests (require live server)
├── test_meta_tools.py                  # Meta tool catalog/search/definition/help tests
├── test_metrics.py                     # Metrics collection tests
├── test_minimal_mcp.py                 # Minimal MCP server smoke tests
├── test_npl_loading.py                 # NPL YAML loader tests
├── test_orchestration.py               # Multi-agent orchestration tests
├── test_ping.py                        # Ping tool tests
├── test_pm_mcp_tools.py                # PM tools (PRD/story/persona) tests
├── test_projects.py                    # Project management tests
├── test_rest_api.py                    # REST API endpoint tests
├── test_rest.py                        # REST client tool tests
├── test_screenshot.py                  # Screenshot tool tests
├── test_scripts_module.py              # scripts/ module tests
├── test_secrets.py                     # Secret management tool tests
├── test_skills_validator.py            # Skill validation tool tests
├── test_structured_logging.py          # Structured logging tests
├── test_tasks.py                       # Task CRUD and status transition tests
├── test_tmlanguage.py                  # NPL TextMate grammar tests
├── test_to_markdown_strip.py           # Jina markdown stripping tests
├── test_to_markdown.py                 # ToMarkdown tool tests
├── test_tool_registry.py               # Tool registry mapping tests
└── test_tool_sessions.py               # Tool session lifecycle tests
```

## Notes

- Run with `uv run -m pytest tests/`
- `test_mcp_server.py` requires a running server — use `--ignore` for CI
- 40 test files covering markdown, NPL, PM tools, meta tools, browser, instructions, sessions, orchestration, structured logging, and more
