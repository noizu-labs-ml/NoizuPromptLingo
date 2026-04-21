"""Tests for the agents catalog module (US-221)."""

from __future__ import annotations

import textwrap
from pathlib import Path

import pytest
from fastapi import FastAPI
from fastapi.testclient import TestClient


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _write_agent(tmp_path: Path, stem: str, frontmatter: str, body: str) -> None:
    """Write a synthetic agent .md file to tmp_path."""
    content = f"---\n{frontmatter}\n---\n{body}"
    (tmp_path / f"{stem}.md").write_text(content, encoding="utf-8")


def _make_client() -> TestClient:
    from npl_mcp.api.router import router
    app = FastAPI()
    app.include_router(router)
    return TestClient(app)


# ---------------------------------------------------------------------------
# catalog.list_agents tests
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_list_agents_empty(tmp_path: Path):
    """list_agents returns [] when directory has no .md files."""
    from npl_mcp.agents.catalog import list_agents

    result = await list_agents(agents_dir=tmp_path)
    assert result == []


@pytest.mark.asyncio
async def test_list_agents_parses_frontmatter(tmp_path: Path):
    """list_agents extracts name, description, model, kind from frontmatter."""
    from npl_mcp.agents.catalog import list_agents

    _write_agent(
        tmp_path,
        stem="npl-tdd-coder",
        frontmatter=textwrap.dedent("""\
            name: npl-tdd-coder
            description: Writes code to satisfy failing tests.
            model: sonnet
        """),
        body="# TDD Coder\n\nSome body text here.",
    )

    agents = await list_agents(agents_dir=tmp_path)
    assert len(agents) == 1

    a = agents[0]
    assert a["name"] == "npl-tdd-coder"
    assert a["display_name"] == "npl-tdd-coder"
    assert "Writes code" in a["description"]
    assert a["model"] == "sonnet"
    assert a["kind"] == "pipeline"          # npl-tdd-* → pipeline
    assert a["path"] == "agents/npl-tdd-coder.md"
    assert a["body_length"] > 0
    assert "body" not in a                  # lightweight listing — no body


@pytest.mark.asyncio
async def test_list_agents_two_files_sorted(tmp_path: Path):
    """list_agents sorts alphabetically and infers kind correctly."""
    from npl_mcp.agents.catalog import list_agents

    _write_agent(
        tmp_path,
        stem="npl-tasker-fast",
        frontmatter="name: npl-tasker-fast\ndescription: Fast tasker.\n",
        body="Fast tasker body.",
    )
    _write_agent(
        tmp_path,
        stem="npl-winnower",
        frontmatter="name: npl-winnower\ndescription: Winnower agent.\n",
        body="Winnower body.",
    )

    agents = await list_agents(agents_dir=tmp_path)
    assert len(agents) == 2

    names = [a["name"] for a in agents]
    assert names == sorted(names), "Agents should be sorted alphabetically"

    kinds = {a["name"]: a["kind"] for a in agents}
    assert kinds["npl-tasker-fast"] == "executor"
    assert kinds["npl-winnower"] == "utility"


# ---------------------------------------------------------------------------
# catalog.get_agent tests
# ---------------------------------------------------------------------------

@pytest.mark.asyncio
async def test_get_agent_returns_body(tmp_path: Path):
    """get_agent returns the full markdown body for a known agent."""
    from npl_mcp.agents.catalog import get_agent

    body_text = "# My Agent\n\nThis is the body.\n"
    _write_agent(
        tmp_path,
        stem="npl-technical-writer",
        frontmatter="name: npl-technical-writer\ndescription: Writes docs.\nmodel: opus\n",
        body=body_text,
    )

    result = await get_agent("npl-technical-writer", agents_dir=tmp_path)
    assert result is not None
    assert result["name"] == "npl-technical-writer"
    assert result["body"] == body_text
    assert result["model"] == "opus"
    assert result["kind"] == "utility"


@pytest.mark.asyncio
async def test_get_agent_missing_returns_none(tmp_path: Path):
    """get_agent returns None for an agent slug that does not exist."""
    from npl_mcp.agents.catalog import get_agent

    result = await get_agent("npl-nonexistent", agents_dir=tmp_path)
    assert result is None


# ---------------------------------------------------------------------------
# REST endpoint tests  GET /api/agents  and  GET /api/agents/{name}
# ---------------------------------------------------------------------------

def test_rest_agents_list_returns_200(tmp_path: Path, monkeypatch):
    """GET /api/agents returns 200 with a list of agent metadata."""
    import npl_mcp.agents.catalog as cat_mod

    monkeypatch.setattr(cat_mod, "_AGENTS_DIR", tmp_path)

    _write_agent(
        tmp_path,
        stem="npl-idea-to-spec",
        frontmatter="name: npl-idea-to-spec\ndescription: Idea to spec agent.\n",
        body="Spec body.",
    )

    client = _make_client()
    resp = client.get("/api/agents")
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert len(data) == 1
    assert data[0]["name"] == "npl-idea-to-spec"
    assert data[0]["kind"] == "pipeline"
    assert "body" not in data[0]


def test_rest_agents_get_returns_body(tmp_path: Path, monkeypatch):
    """GET /api/agents/{name} returns 200 with agent body."""
    import npl_mcp.agents.catalog as cat_mod

    monkeypatch.setattr(cat_mod, "_AGENTS_DIR", tmp_path)

    _write_agent(
        tmp_path,
        stem="npl-tdd-tester",
        frontmatter="name: npl-tdd-tester\ndescription: Writes tests.\nmodel: haiku\n",
        body="# TDD Tester\n\nFull body here.",
    )

    client = _make_client()
    resp = client.get("/api/agents/npl-tdd-tester")
    assert resp.status_code == 200
    data = resp.json()
    assert data["name"] == "npl-tdd-tester"
    assert "body" in data
    assert "Full body here" in data["body"]


def test_rest_agents_get_404(tmp_path: Path, monkeypatch):
    """GET /api/agents/{name} returns 404 for unknown agent."""
    import npl_mcp.agents.catalog as cat_mod

    monkeypatch.setattr(cat_mod, "_AGENTS_DIR", tmp_path)

    client = _make_client()
    resp = client.get("/api/agents/npl-does-not-exist")
    assert resp.status_code == 404
