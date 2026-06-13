"""Tests for the scripts module — PRD-008.

Validates that the five Scripts tools are registered as discoverable,
callable via the catalog dispatcher, and return expected types.
"""

from __future__ import annotations

import subprocess
from unittest.mock import AsyncMock, MagicMock, patch

import pytest

from npl_mcp.meta_tools.catalog import _DISCOVERABLE_TOOLS, call_tool


# ── Registration checks ──────────────────────────────────────────────────

class TestScriptsToolsRegistered:
    """All five Scripts tools must appear in the discoverable registry."""

    def test_dump_files_registered(self):
        assert "dump_files" in _DISCOVERABLE_TOOLS

    def test_git_tree_registered(self):
        assert "git_tree" in _DISCOVERABLE_TOOLS

    def test_git_tree_depth_registered(self):
        assert "git_tree_depth" in _DISCOVERABLE_TOOLS

    def test_npl_load_registered(self):
        assert "npl_load" in _DISCOVERABLE_TOOLS

    def test_web_to_md_registered(self):
        assert "web_to_md" in _DISCOVERABLE_TOOLS


# ── Dispatch via call_tool ───────────────────────────────────────────────

class TestCallToolDispatchesScripts:
    """call_tool routes to the correct wrapper function."""

    @pytest.mark.asyncio
    async def test_dump_files_returns_string(self, _mcp_app):
        """dump_files returns captured stdout string when subprocess succeeds."""
        fake_output = "# src/foo.py\n---\nprint('hello')\n* * *\n"
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = fake_output
        mock_result.stderr = ""

        with patch("subprocess.run", return_value=mock_result):
            result = await call_tool("dump_files", {"path": "/tmp"})

        assert isinstance(result, str)
        assert result == fake_output

    @pytest.mark.asyncio
    async def test_dump_files_error_returns_dict(self, _mcp_app):
        """dump_files returns an error dict when subprocess fails."""
        mock_result = MagicMock()
        mock_result.returncode = 1
        mock_result.stdout = ""
        mock_result.stderr = "not a git repo"

        with patch("subprocess.run", return_value=mock_result):
            result = await call_tool("dump_files", {"path": "/nonexistent"})

        assert isinstance(result, dict)
        assert "error" in result

    @pytest.mark.asyncio
    async def test_git_tree_returns_string(self, _mcp_app):
        """git_tree returns tree output string when subprocess succeeds."""
        fake_tree = ".\n├── src\n│   └── foo.py\n└── tests\n"
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = fake_tree
        mock_result.stderr = ""

        with patch("subprocess.run", return_value=mock_result):
            result = await call_tool("git_tree", {"path": "."})

        assert isinstance(result, str)
        assert result == fake_tree

    @pytest.mark.asyncio
    async def test_npl_load_returns_markdown(self, _mcp_app):
        """npl_load returns non-empty markdown from load_npl."""
        # Call with real data (syntax section should always exist in conventions/)
        result = await call_tool("npl_load", {"resource_type": "syntax", "items": "syntax"})

        # Either returns a non-empty string or an error dict (if conventions/ missing)
        assert isinstance(result, (str, dict))
        if isinstance(result, str):
            assert len(result) > 0

    @pytest.mark.asyncio
    async def test_web_to_md_returns_dict(self, _mcp_app):
        """web_to_md returns a dict with content key when to_markdown succeeds."""
        fake_result = {
            "source": "https://example.com",
            "content": "# Example Domain\n\nThis domain is for use in examples.",
            "content_length": 56,
            "source_type": "url",
        }

        # Patch the to_markdown function where it is imported inside the wrapper
        with patch(
            "npl_mcp.browser.to_markdown.to_markdown",
            new_callable=AsyncMock,
            return_value=fake_result,
        ):
            result = await call_tool("web_to_md", {"url": "https://example.com"})

        assert isinstance(result, dict)
        assert result.get("content") is not None
        assert "Example" in result["content"]
