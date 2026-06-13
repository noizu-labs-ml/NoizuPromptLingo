"""Tests for US-086: programmatic agent spec loading.

Covers:
- Agent.List MCP tool dispatches via catalog
- Agent.Load returns body for a real agent (tmp_path fixture)
- Agent.Load with unknown name returns error status dict
- EXPECTED_MCP_TOOL_NAMES includes both new entries
"""

from __future__ import annotations

import pytest
from pathlib import Path


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _write_agent(tmp_path: Path, slug: str, fm: str, body: str) -> Path:
    """Write a minimal agent .md file and return its path."""
    md = tmp_path / f"{slug}.md"
    md.write_text(f"---\n{fm}\n---\n{body}")
    return md


# ---------------------------------------------------------------------------
# catalog.list_agents
# ---------------------------------------------------------------------------

class TestListAgents:
    @pytest.mark.asyncio
    async def test_list_returns_metadata_no_body(self, tmp_path):
        """list_agents returns dicts without a 'body' key."""
        _write_agent(
            tmp_path,
            "my-agent",
            "name: my-agent\ndescription: A test agent\nmodel: sonnet",
            "# My Agent\n\nDoes stuff.",
        )
        from npl_mcp.agents.catalog import list_agents
        agents = await list_agents(agents_dir=tmp_path)
        assert len(agents) == 1
        assert agents[0]["name"] == "my-agent"
        assert agents[0]["description"] == "A test agent"
        assert agents[0]["model"] == "sonnet"
        assert "body" not in agents[0]
        assert agents[0]["body_length"] > 0

    @pytest.mark.asyncio
    async def test_list_empty_dir(self, tmp_path):
        """list_agents on empty directory returns empty list."""
        from npl_mcp.agents.catalog import list_agents
        result = await list_agents(agents_dir=tmp_path)
        assert result == []

    @pytest.mark.asyncio
    async def test_list_missing_dir(self, tmp_path):
        """list_agents on non-existent directory returns empty list."""
        from npl_mcp.agents.catalog import list_agents
        result = await list_agents(agents_dir=tmp_path / "does_not_exist")
        assert result == []

    @pytest.mark.asyncio
    async def test_list_multiple_agents(self, tmp_path):
        """list_agents returns one entry per .md file."""
        _write_agent(tmp_path, "agent-a", "name: agent-a", "# A")
        _write_agent(tmp_path, "agent-b", "name: agent-b", "# B")
        from npl_mcp.agents.catalog import list_agents
        agents = await list_agents(agents_dir=tmp_path)
        names = [a["name"] for a in agents]
        assert "agent-a" in names
        assert "agent-b" in names
        assert len(agents) == 2

    @pytest.mark.asyncio
    async def test_list_metadata_fields(self, tmp_path):
        """list_agents entries include all expected metadata fields."""
        _write_agent(
            tmp_path,
            "full-agent",
            # frontmatter uses 'allowed-tools' (hyphen) per catalog convention
            "name: full-agent\nmodel: opus\nallowed-tools:\n  - Read\n  - Edit",
            "body here",
        )
        from npl_mcp.agents.catalog import list_agents
        agents = await list_agents(agents_dir=tmp_path)
        assert len(agents) == 1
        a = agents[0]
        for field in ("name", "display_name", "description", "model", "allowed_tools", "kind", "path", "body_length"):
            assert field in a, f"missing field: {field}"
        assert a["allowed_tools"] == ["Read", "Edit"]
        # kind is inferred from stem; 'full-agent' → 'utility'
        assert a["kind"] == "utility"


# ---------------------------------------------------------------------------
# catalog.get_agent
# ---------------------------------------------------------------------------

class TestGetAgent:
    @pytest.mark.asyncio
    async def test_get_returns_body(self, tmp_path):
        """get_agent returns the full spec including markdown body."""
        _write_agent(
            tmp_path,
            "npl-tasker",
            "name: npl-tasker\ndescription: Fast task executor\nmodel: sonnet",
            "# Tasker Agent\n\nDoes tasks.",
        )
        from npl_mcp.agents.catalog import get_agent
        result = await get_agent("npl-tasker", agents_dir=tmp_path)
        assert result is not None
        assert result["name"] == "npl-tasker"
        assert "body" in result
        assert "# Tasker Agent" in result["body"]
        assert result["body_length"] == len(result["body"])

    @pytest.mark.asyncio
    async def test_get_unknown_returns_none(self, tmp_path):
        """get_agent returns None for unknown agent names."""
        _write_agent(tmp_path, "real-agent", "name: real-agent", "body")
        from npl_mcp.agents.catalog import get_agent
        result = await get_agent("does-not-exist", agents_dir=tmp_path)
        assert result is None

    @pytest.mark.asyncio
    async def test_get_matches_by_filename_stem(self, tmp_path):
        """get_agent matches by filename stem, returning frontmatter display_name."""
        # file is named 'my-agent.md'; lookup key is the stem
        _write_agent(
            tmp_path,
            "my-agent",
            "name: My Display Agent\nmodel: haiku",
            "body text",
        )
        from npl_mcp.agents.catalog import get_agent
        result = await get_agent("my-agent", agents_dir=tmp_path)
        assert result is not None
        assert result["name"] == "my-agent"
        assert result["display_name"] == "My Display Agent"


# ---------------------------------------------------------------------------
# MCP tool — Agent.List
# ---------------------------------------------------------------------------

class TestAgentListMCPTool:
    @pytest.mark.asyncio
    async def test_agent_list_tool_registered(self, _mcp_app):
        """Agent.List is registered with FastMCP."""
        tool = await _mcp_app.get_tool("Agent.List")
        assert tool is not None
        assert tool.name == "Agent.List"

    @pytest.mark.asyncio
    async def test_agent_list_tool_category(self, _mcp_app):
        """Agent.List is categorised under 'Agents'."""
        from npl_mcp.meta_tools.catalog import _MCP_TOOL_CATEGORIES
        assert _MCP_TOOL_CATEGORIES.get("Agent.List") == "Agents"

    @pytest.mark.asyncio
    async def test_agent_list_returns_real_agents(self, _mcp_app):
        """Agent.List tool returns at least the real project agents."""
        tool = await _mcp_app.get_tool("Agent.List")
        import json
        result = await tool.run({})
        # FastMCP wraps list results as JSON text
        data = json.loads(result.content[0].text)
        assert isinstance(data, list)
        # The real agents/ directory has multiple agents
        assert len(data) >= 1
        # Each entry should have 'name' and 'description'
        for entry in data:
            assert "name" in entry
            assert "description" in entry
            assert "body" not in entry  # listing excludes body


# ---------------------------------------------------------------------------
# MCP tool — Agent.Load
# ---------------------------------------------------------------------------

class TestAgentLoadMCPTool:
    @pytest.mark.asyncio
    async def test_agent_load_tool_registered(self, _mcp_app):
        """Agent.Load is registered with FastMCP."""
        tool = await _mcp_app.get_tool("Agent.Load")
        assert tool is not None
        assert tool.name == "Agent.Load"

    @pytest.mark.asyncio
    async def test_agent_load_returns_body_for_real_agent(self, _mcp_app):
        """Agent.Load returns a body for a known real agent."""
        tool = await _mcp_app.get_tool("Agent.Load")
        import json
        result = await tool.run({"name": "npl-tasker-fast"})
        data = json.loads(result.content[0].text)
        assert "status" not in data or data.get("status") != "error", (
            f"Expected agent data, got error: {data}"
        )
        assert "body" in data
        assert len(data["body"]) > 0
        assert data["name"] == "npl-tasker-fast"

    @pytest.mark.asyncio
    async def test_agent_load_unknown_returns_error(self, _mcp_app):
        """Agent.Load returns error dict for unknown agent name."""
        tool = await _mcp_app.get_tool("Agent.Load")
        import json
        result = await tool.run({"name": "nonexistent-agent-xyz"})
        data = json.loads(result.content[0].text)
        assert data["status"] == "error"
        assert "nonexistent-agent-xyz" in data["message"]

    @pytest.mark.asyncio
    async def test_agent_load_category(self, _mcp_app):
        """Agent.Load is categorised under 'Agents'."""
        from npl_mcp.meta_tools.catalog import _MCP_TOOL_CATEGORIES
        assert _MCP_TOOL_CATEGORIES.get("Agent.Load") == "Agents"


# ---------------------------------------------------------------------------
# EXPECTED_MCP_TOOL_NAMES sanity check
# ---------------------------------------------------------------------------

class TestExpectedToolNames:
    @pytest.mark.asyncio
    async def test_agent_tools_in_expected_names(self, _mcp_app):
        """Agent.List and Agent.Load are included in the registered MCP tool set."""
        tools = await _mcp_app.list_tools()
        names = {t.name for t in tools}
        assert "Agent.List" in names
        assert "Agent.Load" in names
