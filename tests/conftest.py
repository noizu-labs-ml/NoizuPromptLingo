"""Shared test fixtures for NPL MCP test suite."""

import pytest

from npl_mcp.meta_tools.catalog import invalidate_catalog
from npl_mcp.meta_tools import inference_cache


@pytest.fixture(scope="session")
def _mcp_app():
    """Create the MCP app once per test session to register all tools."""
    from npl_mcp.launcher import create_app
    return create_app()


@pytest.fixture(autouse=True)
def _clear_caches(_mcp_app):
    """Clear inference cache and invalidate catalog cache before each test."""
    inference_cache.cache_clear()
    invalidate_catalog()
    yield
    inference_cache.cache_clear()
    invalidate_catalog()
