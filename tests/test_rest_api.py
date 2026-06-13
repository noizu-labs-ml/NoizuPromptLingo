"""Tests for the read-only JSON REST API endpoints in /api/*.

Uses FastAPI's TestClient with mocked DB pool and catalog.
"""

from __future__ import annotations

import uuid
from unittest.mock import AsyncMock, MagicMock, patch

import pytest
from fastapi.testclient import TestClient

# ---------------------------------------------------------------------------
# App factory (import after patching so catalog is warm)
# ---------------------------------------------------------------------------

def _make_client() -> TestClient:
    """Create a TestClient for the REST API router only (no MCP/SSE)."""
    from fastapi import FastAPI
    from npl_mcp.api.router import router
    app = FastAPI()
    app.include_router(router)
    return TestClient(app)


# ---------------------------------------------------------------------------
# Shared canned data
# ---------------------------------------------------------------------------

_TOOL_UUID = uuid.uuid4()
_PROJECT_UUID = uuid.uuid4()
_SESSION_UUID = uuid.uuid4()
_PARENT_UUID = uuid.uuid4()
_PERSONA_UUID = uuid.uuid4()
_STORY_UUID = uuid.uuid4()
_INSTRUCTION_UUID = uuid.uuid4()

import shortuuid
_PROJECT_SHORT = shortuuid.encode(_PROJECT_UUID)
_SESSION_SHORT = shortuuid.encode(_SESSION_UUID)
_INSTRUCTION_SHORT = shortuuid.encode(_INSTRUCTION_UUID)


def _make_mock_pool(rows_map: dict | None = None) -> MagicMock:
    """Build a mock asyncpg pool that returns canned data."""
    pool = MagicMock()
    rows_map = rows_map or {}

    async def mock_fetch(sql, *args, **kwargs):
        # Return canned rows keyed by rough SQL prefix
        for key, rows in rows_map.items():
            if key in sql:
                return rows
        return []

    async def mock_fetchrow(sql, *args, **kwargs):
        for key, rows in rows_map.items():
            if key in sql:
                if isinstance(rows, list) and rows:
                    return rows[0]
                return rows
        return None

    async def mock_fetchval(sql, *args, **kwargs):
        for key, val in rows_map.items():
            if key in sql:
                if isinstance(val, list) and val:
                    return val[0]
                return val
        return None

    pool.fetch = mock_fetch
    pool.fetchrow = mock_fetchrow
    pool.fetchval = mock_fetchval
    return pool


# ---------------------------------------------------------------------------
# Catalog tests
# ---------------------------------------------------------------------------

class TestCatalogList:
    @patch("npl_mcp.meta_tools.catalog.build_catalog", new_callable=AsyncMock)
    def test_returns_list(self, mock_build):
        """Catalog list returns serialisable tool entries."""
        mock_build.return_value = [
            {"name": "Ping", "category": "Browser", "description": "Ping a URL",
             "parameters": [], "tags": {"browser"}},
        ]
        client = _make_client()
        r = client.get("/api/catalog")
        assert r.status_code == 200
        data = r.json()
        assert isinstance(data, list)
        assert data[0]["name"] == "Ping"
        # tags must be a sorted list, not a set
        assert isinstance(data[0]["tags"], list)

    @patch("npl_mcp.meta_tools.catalog.build_catalog", new_callable=AsyncMock)
    def test_returns_126_tools(self, mock_build):
        """Endpoint correctly passes through 126-tool catalog."""
        tools = [
            {"name": f"Tool{i}", "category": "Cat", "description": f"Desc {i}",
             "parameters": [], "tags": set()}
            for i in range(126)
        ]
        mock_build.return_value = tools
        client = _make_client()
        r = client.get("/api/catalog")
        assert r.status_code == 200
        assert len(r.json()) == 126


class TestCatalogSearch:
    @patch("npl_mcp.meta_tools.catalog.build_catalog", new_callable=AsyncMock)
    def test_search_ping_returns_ping(self, mock_build):
        """Search for 'ping' returns the Ping tool."""
        mock_build.return_value = [
            {"name": "Ping", "category": "Browser", "description": "Ping a URL",
             "parameters": [], "tags": {"browser"}},
            {"name": "ToMarkdown", "category": "Browser", "description": "Convert HTML",
             "parameters": [], "tags": {"browser"}},
        ]
        client = _make_client()
        r = client.get("/api/catalog/search?q=ping")
        assert r.status_code == 200
        names = [t["name"] for t in r.json()]
        assert "Ping" in names
        assert "ToMarkdown" not in names

    @patch("npl_mcp.meta_tools.catalog.build_catalog", new_callable=AsyncMock)
    def test_search_no_results(self, mock_build):
        mock_build.return_value = [
            {"name": "Ping", "category": "Browser", "description": "Ping a URL",
             "parameters": [], "tags": {"browser"}},
        ]
        client = _make_client()
        r = client.get("/api/catalog/search?q=zzznomatch")
        assert r.status_code == 200
        assert r.json() == []


class TestCatalogTool:
    @patch("npl_mcp.meta_tools.catalog.get_tool_by_name", new_callable=AsyncMock)
    def test_get_existing_tool(self, mock_get):
        mock_get.return_value = {
            "name": "Ping", "category": "Browser", "description": "Ping a URL",
            "parameters": [], "tags": {"browser"},
        }
        client = _make_client()
        r = client.get("/api/catalog/tool/Ping")
        assert r.status_code == 200
        assert r.json()["name"] == "Ping"

    @patch("npl_mcp.meta_tools.catalog.get_tool_by_name", new_callable=AsyncMock)
    def test_get_missing_tool_returns_404(self, mock_get):
        mock_get.return_value = None
        client = _make_client()
        r = client.get("/api/catalog/tool/NoSuchTool")
        assert r.status_code == 404


# ---------------------------------------------------------------------------
# Sessions tests
# ---------------------------------------------------------------------------

def _session_row():
    import datetime
    row = MagicMock()
    row.__getitem__ = lambda self, k: {
        "id": _SESSION_UUID,
        "agent": "TestAgent",
        "brief": "A brief",
        "task": "some-task",
        "project_id": _PROJECT_UUID,
        "parent_id": None,
        "notes": None,
        "created_at": datetime.datetime(2024, 1, 1, tzinfo=datetime.timezone.utc),
        "updated_at": datetime.datetime(2024, 1, 2, tzinfo=datetime.timezone.utc),
        "project_name": "myproject",
    }[k]
    return row


class TestSessionsList:
    def test_empty_sessions(self):
        """Sessions list returns empty list when DB has none."""
        pool = MagicMock()
        pool.fetch = AsyncMock(return_value=[])
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/sessions")
        assert r.status_code == 200
        assert r.json() == []

    def test_sessions_with_rows(self):
        """Sessions list returns rows when DB has data."""
        row = _session_row()
        pool = MagicMock()
        pool.fetch = AsyncMock(return_value=[row])
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/sessions")
        assert r.status_code == 200
        data = r.json()
        assert len(data) == 1
        assert data[0]["agent"] == "TestAgent"
        assert data[0]["project"] == "myproject"


class TestSessionsAppendNotes:
    def test_append_rejects_empty_note(self):
        """POST /api/sessions/{uuid}/notes with empty note returns 400."""
        client = _make_client()
        r = client.post(f"/api/sessions/{_SESSION_SHORT}/notes", json={"note": ""})
        assert r.status_code == 400

    def test_append_to_missing_session_returns_404(self):
        """POST /api/sessions/{uuid}/notes returns 404 for unknown session."""
        with patch(
            "npl_mcp.tool_sessions.tool_sessions.append_session_notes",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "uuid": _SESSION_SHORT},
        ):
            client = _make_client()
            r = client.post(
                f"/api/sessions/{_SESSION_SHORT}/notes",
                json={"note": "hello"},
            )
        assert r.status_code == 404

    def test_append_success_returns_session(self):
        """POST /api/sessions/{uuid}/notes returns 200 with updated session."""
        with patch(
            "npl_mcp.tool_sessions.tool_sessions.append_session_notes",
            new_callable=AsyncMock,
            return_value={
                "status": "ok",
                "action": "appended",
                "uuid": _SESSION_SHORT,
                "agent": "TestAgent",
                "brief": "A brief",
                "task": "some-task",
                "project": "myproject",
                "parent": None,
                "notes": "new note",
                "created_at": "2024-01-01T00:00:00+00:00",
                "updated_at": "2024-01-02T00:00:00+00:00",
            },
        ):
            client = _make_client()
            r = client.post(
                f"/api/sessions/{_SESSION_SHORT}/notes",
                json={"note": "new note"},
            )
        assert r.status_code == 200
        data = r.json()
        assert data["uuid"] == _SESSION_SHORT
        assert data["notes"] == "new note"
        assert data["action"] == "appended"

    def test_append_noop_when_substring_already_present(self):
        """Substring dedup — same note passed twice yields action=noop."""
        with patch(
            "npl_mcp.tool_sessions.tool_sessions.append_session_notes",
            new_callable=AsyncMock,
            return_value={
                "status": "ok",
                "action": "noop",
                "uuid": _SESSION_SHORT,
                "agent": "TestAgent",
                "brief": "A brief",
                "task": "some-task",
                "project": "myproject",
                "parent": None,
                "notes": "already here\nwith more",
                "created_at": "2024-01-01T00:00:00+00:00",
                "updated_at": "2024-01-02T00:00:00+00:00",
            },
        ):
            client = _make_client()
            r = client.post(
                f"/api/sessions/{_SESSION_SHORT}/notes",
                json={"note": "already here"},
            )
        assert r.status_code == 200
        assert r.json()["action"] == "noop"


class TestSessionsGet:
    def test_session_not_found_returns_404(self):
        """GET /api/sessions/{uuid} returns 404 for unknown UUID."""
        pool = MagicMock()
        pool.fetchrow = AsyncMock(return_value=None)
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get(f"/api/sessions/{_SESSION_SHORT}")
        assert r.status_code == 404

    def test_session_found(self):
        """GET /api/sessions/{uuid} returns session data."""
        row = _session_row()
        pool = MagicMock()
        pool.fetchrow = AsyncMock(return_value=row)
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get(f"/api/sessions/{_SESSION_SHORT}")
        assert r.status_code == 200
        assert r.json()["agent"] == "TestAgent"


# ---------------------------------------------------------------------------
# Instructions tests
# ---------------------------------------------------------------------------

class TestInstructionsList:
    def test_instructions_empty(self):
        """Instructions list returns empty list when DB has none."""
        pool = MagicMock()
        pool.fetch = AsyncMock(return_value=[])
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/instructions")
        assert r.status_code == 200
        assert r.json() == []

    def test_instructions_with_mode_all(self):
        """Instructions list with mode=all returns rows."""
        import datetime

        row = MagicMock()
        row.__getitem__ = lambda self, k: {
            "id": _INSTRUCTION_UUID,
            "title": "Test Instruction",
            "description": "A test",
            "tags": ["foo"],
            "active_version": 1,
            "session_id": None,
            "updated_at": datetime.datetime(2024, 3, 1, tzinfo=datetime.timezone.utc),
        }[k]
        row.keys = lambda: ["id", "title", "description", "tags", "active_version", "session_id", "updated_at"]

        pool = MagicMock()
        pool.fetch = AsyncMock(return_value=[row])
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/instructions?mode=all")
        assert r.status_code == 200
        data = r.json()
        assert len(data) == 1
        assert data[0]["title"] == "Test Instruction"


# ---------------------------------------------------------------------------
# Projects tests
# ---------------------------------------------------------------------------

def _project_row(with_counts: bool = True):
    import datetime
    d = {
        "id": _PROJECT_UUID,
        "name": "myproject",
        "title": "My Project",
        "description": "Desc",
        "created_at": datetime.datetime(2024, 1, 1, tzinfo=datetime.timezone.utc),
    }
    if with_counts:
        d["persona_count"] = 3
        d["story_count"] = 7
    row = MagicMock()
    row.__getitem__ = lambda self, k: d[k]
    row.get = lambda k, default=None: d.get(k, default)
    return row


class TestProjectsList:
    def test_projects_list(self):
        """Projects list returns projects with counts."""
        row = _project_row(with_counts=True)
        pool = MagicMock()
        pool.fetch = AsyncMock(return_value=[row])
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/projects")
        assert r.status_code == 200
        data = r.json()
        assert len(data) == 1
        assert data[0]["name"] == "myproject"
        assert data[0]["persona_count"] == 3
        assert data[0]["story_count"] == 7


class TestProjectPersonas:
    def test_personas_for_project(self):
        """GET /api/projects/{id}/personas returns persona list."""
        import datetime, json as _json

        persona_row = MagicMock()
        persona_row.__getitem__ = lambda self, k: {
            "id": _PERSONA_UUID,
            "project_id": _PROJECT_UUID,
            "name": "Alice",
            "role": "user",
            "description": "A user persona",
            "goals": "achieve things",
            "pain_points": "friction",
            "behaviors": "browses a lot",
            "physical_description": None,
            "persona_image": None,
            "demographics": None,
            "created_by": None,
            "created_at": datetime.datetime(2024, 1, 1, tzinfo=datetime.timezone.utc),
            "updated_at": datetime.datetime(2024, 1, 2, tzinfo=datetime.timezone.utc),
        }[k]

        pool = MagicMock()
        pool.fetchval = AsyncMock(return_value=_PROJECT_UUID)  # project exists
        pool.fetch = AsyncMock(return_value=[persona_row])
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get(f"/api/projects/{_PROJECT_SHORT}/personas")
        assert r.status_code == 200
        data = r.json()
        assert len(data) == 1
        assert data[0]["name"] == "Alice"


class TestProjectStories:
    def test_stories_for_project(self):
        """GET /api/projects/{id}/stories returns story list."""
        import datetime

        story_row = MagicMock()
        story_row.__getitem__ = lambda self, k: {
            "id": _STORY_UUID,
            "project_id": _PROJECT_UUID,
            "persona_ids": [],
            "title": "As a user, I want to log in",
            "story_text": "...",
            "description": "Login feature",
            "priority": "high",
            "status": "draft",
            "story_points": 3,
            "tags": [],
            "created_by": None,
            "created_at": datetime.datetime(2024, 1, 1, tzinfo=datetime.timezone.utc),
            "updated_at": datetime.datetime(2024, 1, 2, tzinfo=datetime.timezone.utc),
        }[k]

        pool = MagicMock()
        pool.fetchval = AsyncMock(return_value=_PROJECT_UUID)  # project exists
        pool.fetch = AsyncMock(return_value=[story_row])
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get(f"/api/projects/{_PROJECT_SHORT}/stories")
        assert r.status_code == 200
        data = r.json()
        assert len(data) == 1
        assert data[0]["title"] == "As a user, I want to log in"
        assert data[0]["priority"] == "high"


# ---------------------------------------------------------------------------
# PRD endpoints
# ---------------------------------------------------------------------------

class TestPRDsList:
    def test_prds_list_returns_list(self):
        """GET /api/prds returns a list of PRD summaries from the real PRD directory."""
        client = _make_client()
        r = client.get("/api/prds")
        assert r.status_code == 200
        data = r.json()
        assert isinstance(data, list)
        # Verify at least some PRDs are found (real project-management/PRDs/ directory)
        assert len(data) > 0
        first = data[0]
        assert "id" in first
        assert "number" in first
        assert "title" in first
        assert "has_frs" in first
        assert "has_ats" in first
        assert "path" in first

    def test_prds_sorted_by_number(self):
        """GET /api/prds returns PRDs sorted ascending by number."""
        client = _make_client()
        r = client.get("/api/prds")
        assert r.status_code == 200
        data = r.json()
        numbers = [p["number"] for p in data]
        assert numbers == sorted(numbers)

    def test_prds_list_has_prd_001(self):
        """PRD-001 (database infrastructure) is included in the list."""
        client = _make_client()
        r = client.get("/api/prds")
        assert r.status_code == 200
        ids = [p["id"] for p in r.json()]
        assert "PRD-001-database-infrastructure" in ids


class TestPRDsGet:
    def test_prds_get_existing(self):
        """GET /api/prds/{id} returns detail for a known PRD directory."""
        client = _make_client()
        r = client.get("/api/prds/PRD-001-database-infrastructure")
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == "PRD-001-database-infrastructure"
        assert data["number"] == 1
        assert "body" in data
        assert isinstance(data["body"], str)
        assert len(data["body"]) > 0
        assert "functional_requirements" in data
        assert "acceptance_tests" in data

    def test_prds_get_not_found(self):
        """GET /api/prds/{id} returns 404 for unknown PRD."""
        client = _make_client()
        r = client.get("/api/prds/PRD-999-does-not-exist")
        assert r.status_code == 404

    def test_prds_get_standalone_md(self):
        """GET /api/prds/{id} works for a standalone .md PRD."""
        client = _make_client()
        # PRD-005 exists as both a dir and .md; dir takes precedence — try PRD-015 standalone
        r = client.get("/api/prds/PRD-015-npl-loading-extension")
        # Either the directory or the .md is found — should be 200
        assert r.status_code == 200
        data = r.json()
        assert data["number"] == 15


class TestPRDsFRs:
    def test_frs_for_prd_001(self):
        """GET /api/prds/{id}/functional-requirements returns FR docs for PRD-001."""
        client = _make_client()
        r = client.get("/api/prds/PRD-001-database-infrastructure/functional-requirements")
        assert r.status_code == 200
        data = r.json()
        assert isinstance(data, list)
        assert len(data) > 0
        fr = data[0]
        assert "id" in fr
        assert "title" in fr
        assert "body" in fr

    def test_frs_not_found_prd(self):
        """GET /api/prds/{id}/functional-requirements returns 404 for missing PRD."""
        client = _make_client()
        r = client.get("/api/prds/PRD-999-no-such/functional-requirements")
        assert r.status_code == 404


# ---------------------------------------------------------------------------
# Unknown endpoint
# ---------------------------------------------------------------------------

class TestUnknownEndpoint:
    def test_unknown_route_returns_404(self):
        """Requests to unknown /api/* paths return 404."""
        client = _make_client()
        r = client.get("/api/nonexistent/path")
        assert r.status_code == 404


# ---------------------------------------------------------------------------
# Project file tree / file reader tests  (US-025)
# ---------------------------------------------------------------------------

class TestProjectTree:
    def test_default_path_returns_tree(self, tmp_path):
        """GET /api/project/tree returns a directory node with children."""
        import npl_mcp.api.router as router_mod

        original_root = router_mod._REPO_ROOT
        try:
            # Point the router at a tmp directory with known contents
            (tmp_path / "src").mkdir()
            (tmp_path / "README.md").write_text("hello")
            router_mod._REPO_ROOT = tmp_path

            client = _make_client()
            r = client.get("/api/project/tree?path=.&depth=2")
            assert r.status_code == 200
            data = r.json()
            assert data["kind"] == "directory"
            assert "children" in data
            names = [c["name"] for c in data["children"]]
            assert "src" in names
            assert "README.md" in names
        finally:
            router_mod._REPO_ROOT = original_root

    def test_dotdot_path_returns_400(self):
        """GET /api/project/tree with '..' in path returns 400."""
        client = _make_client()
        r = client.get("/api/project/tree?path=../etc")
        assert r.status_code == 400

    def test_file_returns_content(self, tmp_path):
        """GET /api/project/file returns text content and metadata."""
        import npl_mcp.api.router as router_mod

        original_root = router_mod._REPO_ROOT
        try:
            (tmp_path / "hello.txt").write_text("hello world")
            router_mod._REPO_ROOT = tmp_path

            client = _make_client()
            r = client.get("/api/project/file?path=hello.txt")
            assert r.status_code == 200
            data = r.json()
            assert data["content"] == "hello world"
            assert data["size"] == 11
            assert data["path"] == "hello.txt"
            assert data.get("truncated") is False
        finally:
            router_mod._REPO_ROOT = original_root

    def test_file_rejects_out_of_repo_path(self):
        """GET /api/project/file with escaping path returns 400."""
        client = _make_client()
        r = client.get("/api/project/file?path=../../etc/passwd")
        assert r.status_code == 400


# ---------------------------------------------------------------------------
# NPL elements tests (US-223)
# ---------------------------------------------------------------------------

class TestNPLElements:
    def test_returns_list(self, tmp_path):
        """GET /api/npl/elements returns a list of component dicts."""
        import yaml as _yaml
        from npl_mcp.api import router as router_mod

        # Write a minimal conventions YAML (not named npl.yaml)
        conv = {
            "name": "syntax",
            "title": "Syntax",
            "components": [
                {
                    "name": "placeholder",
                    "priority": 0,
                    "friendly-name": "Placeholder",
                    "brief": "A substitution token.",
                    "labels": ["core", "required"],
                },
                {
                    "name": "in-fill",
                    "priority": 1,
                    "friendly-name": "In-Fill",
                    "brief": "LLM-generated content.",
                    "labels": ["core"],
                },
            ],
        }
        conv_file = tmp_path / "syntax.yaml"
        conv_file.write_text(_yaml.dump(conv))

        # Also write npl.yaml which should be skipped
        npl_meta = {"name": "npl", "components": [{"name": "should-not-appear", "priority": 0, "brief": "x"}]}
        (tmp_path / "npl.yaml").write_text(_yaml.dump(npl_meta))

        original = router_mod._CONVENTIONS_DIR
        try:
            router_mod._CONVENTIONS_DIR = tmp_path
            client = _make_client()
            r = client.get("/api/npl/elements")
            assert r.status_code == 200
            data = r.json()
            assert isinstance(data, list)
            names = [e["name"] for e in data]
            assert "placeholder" in names
            assert "in-fill" in names
            assert "should-not-appear" not in names
        finally:
            router_mod._CONVENTIONS_DIR = original

    def test_response_shape(self, tmp_path):
        """Each element has required fields."""
        import yaml as _yaml
        from npl_mcp.api import router as router_mod

        conv = {
            "name": "directives",
            "components": [
                {
                    "name": "agent",
                    "priority": 0,
                    "friendly-name": "Agent",
                    "brief": "Define an agent.",
                    "labels": ["core"],
                },
            ],
        }
        (tmp_path / "directives.yaml").write_text(_yaml.dump(conv))
        original = router_mod._CONVENTIONS_DIR
        try:
            router_mod._CONVENTIONS_DIR = tmp_path
            client = _make_client()
            r = client.get("/api/npl/elements")
            assert r.status_code == 200
            data = r.json()
            assert len(data) == 1
            elem = data[0]
            for field in ("section", "name", "slug", "friendly_name", "brief", "priority", "tags"):
                assert field in elem, f"missing field: {field}"
            assert elem["section"] == "directives"
            assert elem["priority"] == 0
            assert isinstance(elem["tags"], list)
        finally:
            router_mod._CONVENTIONS_DIR = original

    def test_sorted_by_section_priority_name(self, tmp_path):
        """Elements are sorted section → priority → name."""
        import yaml as _yaml
        from npl_mcp.api import router as router_mod

        conv_b = {
            "name": "beta",
            "components": [
                {"name": "z-comp", "priority": 1, "brief": "z"},
                {"name": "a-comp", "priority": 0, "brief": "a"},
            ],
        }
        conv_a = {
            "name": "alpha",
            "components": [
                {"name": "only", "priority": 5, "brief": "only"},
            ],
        }
        (tmp_path / "beta.yaml").write_text(_yaml.dump(conv_b))
        (tmp_path / "alpha.yaml").write_text(_yaml.dump(conv_a))
        original = router_mod._CONVENTIONS_DIR
        try:
            router_mod._CONVENTIONS_DIR = tmp_path
            client = _make_client()
            r = client.get("/api/npl/elements")
            assert r.status_code == 200
            data = r.json()
            sections = [e["section"] for e in data]
            # alpha comes before beta
            assert sections.index("alpha") < sections.index("beta")
            # within beta, priority 0 (a-comp) before priority 1 (z-comp)
            beta_names = [e["name"] for e in data if e["section"] == "beta"]
            assert beta_names == ["a-comp", "z-comp"]
        finally:
            router_mod._CONVENTIONS_DIR = original


# ---------------------------------------------------------------------------
# Docs endpoints tests (US-047)
# ---------------------------------------------------------------------------

class TestDocsEndpoints:
    def test_schema_returns_content(self, tmp_path):
        """GET /api/docs/schema returns content of PROJ-SCHEMA.md."""
        from npl_mcp.api import router as router_mod

        docs_dir = tmp_path / "docs"
        docs_dir.mkdir()
        schema_md = docs_dir / "PROJ-SCHEMA.md"
        schema_md.write_text("# Schema\nSome schema content here.")

        original_docs = router_mod._ALLOWED_DOCS
        original_root = router_mod._DOCS_REPO_ROOT
        try:
            router_mod._DOCS_REPO_ROOT = tmp_path
            router_mod._ALLOWED_DOCS = {
                "schema": schema_md,
                "arch": docs_dir / "PROJ-ARCH.md",
                "layout": docs_dir / "PROJ-LAYOUT.md",
                "status": docs_dir / "STATUS.md",
            }
            client = _make_client()
            r = client.get("/api/docs/schema")
            assert r.status_code == 200
            data = r.json()
            assert "content" in data
            assert "Schema" in data["content"]
            assert "path" in data
        finally:
            router_mod._ALLOWED_DOCS = original_docs
            router_mod._DOCS_REPO_ROOT = original_root

    def test_missing_doc_returns_404(self, tmp_path):
        """GET /api/docs/arch returns 404 if file doesn't exist."""
        from npl_mcp.api import router as router_mod
        from pathlib import Path

        docs_dir = tmp_path / "docs"
        docs_dir.mkdir()
        # arch file does NOT exist

        original_docs = router_mod._ALLOWED_DOCS
        try:
            router_mod._ALLOWED_DOCS = {
                "schema": docs_dir / "PROJ-SCHEMA.md",
                "arch": docs_dir / "PROJ-ARCH.md",  # missing
                "layout": docs_dir / "PROJ-LAYOUT.md",
                "status": docs_dir / "STATUS.md",
            }
            client = _make_client()
            r = client.get("/api/docs/arch")
            assert r.status_code == 404
        finally:
            router_mod._ALLOWED_DOCS = original_docs

    def test_layout_endpoint_exists(self, tmp_path):
        """GET /api/docs/layout returns 200 when file present."""
        from npl_mcp.api import router as router_mod

        docs_dir = tmp_path / "docs"
        docs_dir.mkdir()
        layout_md = docs_dir / "PROJ-LAYOUT.md"
        layout_text = "# Layout\nDirectory structure."
        layout_md.write_text(layout_text)

        original_docs = router_mod._ALLOWED_DOCS
        original_root = router_mod._DOCS_REPO_ROOT
        try:
            router_mod._DOCS_REPO_ROOT = tmp_path
            router_mod._ALLOWED_DOCS = {
                "schema": docs_dir / "PROJ-SCHEMA.md",
                "arch": docs_dir / "PROJ-ARCH.md",
                "layout": layout_md,
                "status": docs_dir / "STATUS.md",
            }
            client = _make_client()
            r = client.get("/api/docs/layout")
            assert r.status_code == 200
            data = r.json()
            assert "Layout" in data["content"]
            assert data["size"] == len(layout_text)
        finally:
            router_mod._ALLOWED_DOCS = original_docs
            router_mod._DOCS_REPO_ROOT = original_root


# ---------------------------------------------------------------------------
# Story PATCH endpoint tests (US-231)
# ---------------------------------------------------------------------------

import datetime as _dt

_STORY_UPDATED_AT = _dt.datetime(2024, 6, 1, 12, 0, 0, tzinfo=_dt.timezone.utc)


def _story_get_ok(story_uuid: uuid.UUID, **overrides):
    """Return a canned story dict as story_get would return it."""
    base = {
        "status": "ok",
        "uuid": shortuuid.encode(story_uuid),
        "project_id": shortuuid.encode(_PROJECT_UUID),
        "persona_ids": [],
        "title": "As a user, I want to log in",
        "story_text": "...",
        "description": "Login feature",
        "priority": "medium",
        "story_points": 3,
        "tags": [],
        "created_at": "2024-01-01T00:00:00+00:00",
        "updated_at": _STORY_UPDATED_AT.isoformat(),
    }
    base.update(overrides)
    return base


def _story_row(story_uuid: uuid.UUID, **overrides):
    """Build a dict representing a DB row for a user story."""
    import datetime as _dt

    base = {
        "id": story_uuid,
        "project_id": _PROJECT_UUID,
        "persona_ids": [],
        "title": "As a user, I want to log in",
        "story_text": "So I can use my account",
        "description": "Login feature",
        "priority": "medium",
        "status": "ready",
        "story_points": 3,
        "acceptance_criteria": None,
        "tags": ["auth"],
        "created_by": None,
        "created_at": _dt.datetime(2024, 1, 1, tzinfo=_dt.timezone.utc),
        "updated_at": _STORY_UPDATED_AT,
    }
    base.update(overrides)
    return base


class TestStoriesGet:
    def test_story_not_found_returns_404(self):
        """GET /api/stories/{id} returns 404 when story does not exist."""
        story_uuid = uuid.uuid4()
        story_short = shortuuid.encode(story_uuid)

        pool = MagicMock()
        pool.fetchrow = AsyncMock(return_value=None)
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get(f"/api/stories/{story_short}")

        assert r.status_code == 404

    def test_story_invalid_id_returns_404(self):
        """GET /api/stories/{id} returns 404 for malformed IDs."""
        pool = MagicMock()
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/stories/not-a-valid-id!!!")
        assert r.status_code == 404

    def test_story_found_returns_dto(self):
        """GET /api/stories/{id} returns the story with preserved status field."""
        story_uuid = uuid.uuid4()
        story_short = shortuuid.encode(story_uuid)
        row = _story_row(story_uuid, status="in_progress", tags=["backend", "auth"])

        pool = MagicMock()
        pool.fetchrow = AsyncMock(return_value=row)
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get(f"/api/stories/{story_short}")

        assert r.status_code == 200
        data = r.json()
        assert data["id"] == story_short
        assert data["status"] == "in_progress"  # NOT clobbered to "ok"
        assert data["title"] == "As a user, I want to log in"
        assert data["tags"] == ["backend", "auth"]
        assert data["priority"] == "medium"
        assert data["story_points"] == 3
        assert data["acceptance_criteria"] == []

    def test_story_with_acceptance_criteria(self):
        """Acceptance criteria JSON strings are decoded into the response."""
        import json as _json

        story_uuid = uuid.uuid4()
        story_short = shortuuid.encode(story_uuid)
        criteria = [{"text": "Given X When Y Then Z", "status": "pending"}]
        row = _story_row(story_uuid, acceptance_criteria=_json.dumps(criteria))

        pool = MagicMock()
        pool.fetchrow = AsyncMock(return_value=row)
        with patch("npl_mcp.storage.pool.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get(f"/api/stories/{story_short}")

        assert r.status_code == 200
        assert r.json()["acceptance_criteria"] == criteria


class TestStoriesPatch:
    def test_patch_status_only_returns_200_with_updated_story(self):
        """PATCH /api/stories/{id} with status only updates and returns the story."""
        story_uuid = uuid.uuid4()
        story_short = shortuuid.encode(story_uuid)
        updated = _story_get_ok(story_uuid, status="ready")

        with patch(
            "npl_mcp.pm_tools.db_stories.story_update",
            new_callable=AsyncMock,
            return_value={"uuid": story_short, "status": "ok"},
        ), patch(
            "npl_mcp.pm_tools.db_stories.story_get",
            new_callable=AsyncMock,
            return_value=updated,
        ):
            client = _make_client()
            r = client.patch(f"/api/stories/{story_short}", json={"status": "ready"})

        assert r.status_code == 200
        data = r.json()
        assert data["status"] == "ready"
        assert data["id"] == story_short

    def test_patch_multiple_fields_all_applied(self):
        """PATCH /api/stories/{id} with multiple fields applies all of them."""
        story_uuid = uuid.uuid4()
        story_short = shortuuid.encode(story_uuid)
        updated = _story_get_ok(
            story_uuid,
            status="in_progress",
            priority="high",
            story_points=5,
            tags=["backend"],
            title="Updated title",
        )

        with patch(
            "npl_mcp.pm_tools.db_stories.story_update",
            new_callable=AsyncMock,
            return_value={"uuid": story_short, "status": "ok"},
        ), patch(
            "npl_mcp.pm_tools.db_stories.story_get",
            new_callable=AsyncMock,
            return_value=updated,
        ):
            client = _make_client()
            r = client.patch(
                f"/api/stories/{story_short}",
                json={
                    "status": "in_progress",
                    "priority": "high",
                    "story_points": 5,
                    "tags": ["backend"],
                    "title": "Updated title",
                },
            )

        assert r.status_code == 200
        data = r.json()
        assert data["status"] == "in_progress"
        assert data["priority"] == "high"
        assert data["story_points"] == 5
        assert data["tags"] == ["backend"]
        assert data["title"] == "Updated title"

    def test_patch_unknown_story_id_returns_404(self):
        """PATCH /api/stories/{id} returns 404 when story does not exist."""
        story_uuid = uuid.uuid4()
        story_short = shortuuid.encode(story_uuid)

        with patch(
            "npl_mcp.pm_tools.db_stories.story_update",
            new_callable=AsyncMock,
            return_value={"uuid": story_short, "status": "not_found"},
        ):
            client = _make_client()
            r = client.patch(f"/api/stories/{story_short}", json={"status": "done"})

        assert r.status_code == 404


# ---------------------------------------------------------------------------
# Tasks endpoints (PRD-005 MVP)
# ---------------------------------------------------------------------------

def _task_module_result(**overrides):
    """Shape a dict the way npl_mcp.tasks.tasks returns it."""
    base = {
        "status": "ok",
        "id": 42,
        "title": "Ship tier-C tasks",
        "description": "MVP scope",
        "task_status": "pending",
        "priority": 1,
        "assigned_to": None,
        "notes": None,
        "created_at": "2026-04-21T12:00:00+00:00",
        "updated_at": "2026-04-21T12:00:00+00:00",
    }
    base.update(overrides)
    return base


class TestTasksList:
    def test_empty_list(self):
        with patch(
            "npl_mcp.tasks.task_list",
            new_callable=AsyncMock,
            return_value={"status": "ok", "tasks": [], "count": 0},
        ):
            client = _make_client()
            r = client.get("/api/tasks")
        assert r.status_code == 200
        data = r.json()
        assert data["tasks"] == []
        assert data["count"] == 0

    def test_list_with_filters(self):
        tasks = [_task_module_result(id=1, task_status="in_progress", assigned_to="alice")]
        with patch(
            "npl_mcp.tasks.task_list",
            new_callable=AsyncMock,
            return_value={"status": "ok", "tasks": tasks, "count": 1},
        ) as mocked:
            client = _make_client()
            r = client.get("/api/tasks?status=in_progress&assigned_to=alice&limit=50")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["tasks"][0]["status"] == "in_progress"
        assert data["tasks"][0]["assigned_to"] == "alice"
        mocked.assert_awaited_once()
        call_kwargs = mocked.await_args.kwargs
        assert call_kwargs["status"] == "in_progress"
        assert call_kwargs["assigned_to"] == "alice"
        assert call_kwargs["limit"] == 50

    def test_list_module_error_bubbles_as_400(self):
        with patch(
            "npl_mcp.tasks.task_list",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "Invalid status 'widget'."},
        ):
            client = _make_client()
            r = client.get("/api/tasks?status=widget")
        # FastAPI's Query validator won't reject — status is free-form str — so
        # this relies on the module's own validation returning status="error".
        assert r.status_code == 400


class TestTasksCreate:
    def test_create_success_returns_task_dto(self):
        returned = _task_module_result(id=7, title="Write PRD")
        with patch(
            "npl_mcp.tasks.task_create",
            new_callable=AsyncMock,
            return_value=returned,
        ) as mocked:
            client = _make_client()
            r = client.post("/api/tasks", json={"title": "Write PRD"})
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 7
        assert data["title"] == "Write PRD"
        assert data["status"] == "pending"
        mocked.assert_awaited_once()
        assert mocked.await_args.kwargs["title"] == "Write PRD"

    def test_create_empty_title_returns_400(self):
        with patch(
            "npl_mcp.tasks.task_create",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "title must be a non-empty string."},
        ):
            client = _make_client()
            r = client.post("/api/tasks", json={"title": ""})
        assert r.status_code == 400
        assert "title" in r.json()["detail"].lower()

    def test_create_passes_all_optional_fields(self):
        returned = _task_module_result(
            id=3, title="Config linter",
            task_status="in_progress", priority=2, assigned_to="bob",
            description="Tune eslint rules", notes="started today",
        )
        with patch(
            "npl_mcp.tasks.task_create",
            new_callable=AsyncMock,
            return_value=returned,
        ) as mocked:
            client = _make_client()
            r = client.post("/api/tasks", json={
                "title": "Config linter",
                "description": "Tune eslint rules",
                "status": "in_progress",
                "priority": 2,
                "assigned_to": "bob",
                "notes": "started today",
            })
        assert r.status_code == 200
        assert mocked.await_args.kwargs["priority"] == 2
        assert mocked.await_args.kwargs["assigned_to"] == "bob"
        assert mocked.await_args.kwargs["status"] == "in_progress"


class TestTasksGet:
    def test_get_found(self):
        with patch(
            "npl_mcp.tasks.task_get",
            new_callable=AsyncMock,
            return_value=_task_module_result(id=42, title="Found task"),
        ):
            client = _make_client()
            r = client.get("/api/tasks/42")
        assert r.status_code == 200
        assert r.json()["title"] == "Found task"

    def test_get_not_found(self):
        with patch(
            "npl_mcp.tasks.task_get",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "id": 999},
        ):
            client = _make_client()
            r = client.get("/api/tasks/999")
        assert r.status_code == 404


class TestTasksUpdateStatus:
    def test_update_success(self):
        with patch(
            "npl_mcp.tasks.task_update_status",
            new_callable=AsyncMock,
            return_value=_task_module_result(
                id=1, task_status="done", notes="completed today",
            ),
        ) as mocked:
            client = _make_client()
            r = client.patch("/api/tasks/1/status", json={
                "status": "done",
                "notes": "completed today",
            })
        assert r.status_code == 200
        data = r.json()
        assert data["status"] == "done"
        assert data["notes"] == "completed today"
        assert mocked.await_args.kwargs["status"] == "done"
        assert mocked.await_args.kwargs["notes"] == "completed today"

    def test_update_invalid_status_returns_400(self):
        with patch(
            "npl_mcp.tasks.task_update_status",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "Invalid status 'widget'."},
        ):
            client = _make_client()
            r = client.patch("/api/tasks/1/status", json={"status": "widget"})
        assert r.status_code == 400

    def test_update_missing_task_returns_404(self):
        with patch(
            "npl_mcp.tasks.task_update_status",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "id": 999},
        ):
            client = _make_client()
            r = client.patch("/api/tasks/999/status", json={"status": "done"})
        assert r.status_code == 404


# ---------------------------------------------------------------------------
# Work sessions endpoints (generic sessions, PRD-004 MVP)
# ---------------------------------------------------------------------------

_WSESSION_UUID = uuid.uuid4()
_WSESSION_SHORT = shortuuid.encode(_WSESSION_UUID)


def _work_session_module(**overrides):
    base = {
        "status": "ok",
        "uuid": _WSESSION_SHORT,
        "title": "Sprint 12",
        "session_status": "active",
        "description": "Sprint tracking.",
        "created_by": None,
        "created_at": "2026-04-21T12:00:00+00:00",
        "updated_at": "2026-04-21T12:00:00+00:00",
    }
    base.update(overrides)
    return base


class TestWorkSessionsList:
    def test_empty(self):
        with patch(
            "npl_mcp.sessions.session_list",
            new_callable=AsyncMock,
            return_value={"status": "ok", "sessions": [], "count": 0},
        ):
            client = _make_client()
            r = client.get("/api/work-sessions")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_list_with_filter(self):
        with patch(
            "npl_mcp.sessions.session_list",
            new_callable=AsyncMock,
            return_value={
                "status": "ok",
                "sessions": [_work_session_module(session_status="active")],
                "count": 1,
            },
        ) as mocked:
            client = _make_client()
            r = client.get("/api/work-sessions?status=active&limit=20")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["sessions"][0]["status"] == "active"
        assert mocked.await_args.kwargs["status"] == "active"
        assert mocked.await_args.kwargs["limit"] == 20


class TestWorkSessionsCreate:
    def test_create_success(self):
        with patch(
            "npl_mcp.sessions.session_create",
            new_callable=AsyncMock,
            return_value=_work_session_module(title="Sprint 13"),
        ) as mocked:
            client = _make_client()
            r = client.post("/api/work-sessions", json={"title": "Sprint 13"})
        assert r.status_code == 200
        data = r.json()
        assert data["title"] == "Sprint 13"
        assert data["status"] == "active"
        assert mocked.await_args.kwargs["title"] == "Sprint 13"

    def test_create_invalid_status_returns_400(self):
        with patch(
            "npl_mcp.sessions.session_create",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "Invalid status 'widget'."},
        ):
            client = _make_client()
            r = client.post("/api/work-sessions", json={"status": "widget"})
        assert r.status_code == 400


class TestWorkSessionsGet:
    def test_get_found(self):
        with patch(
            "npl_mcp.sessions.session_get",
            new_callable=AsyncMock,
            return_value=_work_session_module(),
        ):
            client = _make_client()
            r = client.get(f"/api/work-sessions/{_WSESSION_SHORT}")
        assert r.status_code == 200
        assert r.json()["uuid"] == _WSESSION_SHORT

    def test_get_not_found(self):
        with patch(
            "npl_mcp.sessions.session_get",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "uuid": "abc"},
        ):
            client = _make_client()
            r = client.get(f"/api/work-sessions/{_WSESSION_SHORT}")
        assert r.status_code == 404


class TestWorkSessionsUpdate:
    def test_update_success(self):
        with patch(
            "npl_mcp.sessions.session_update",
            new_callable=AsyncMock,
            return_value=_work_session_module(title="Renamed", session_status="paused"),
        ) as mocked:
            client = _make_client()
            r = client.patch(
                f"/api/work-sessions/{_WSESSION_SHORT}",
                json={"title": "Renamed", "status": "paused"},
            )
        assert r.status_code == 200
        data = r.json()
        assert data["title"] == "Renamed"
        assert data["status"] == "paused"
        assert mocked.await_args.kwargs["title"] == "Renamed"
        assert mocked.await_args.kwargs["status"] == "paused"

    def test_update_no_fields_returns_400(self):
        with patch(
            "npl_mcp.sessions.session_update",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "At least one of title/status/description required."},
        ):
            client = _make_client()
            r = client.patch(f"/api/work-sessions/{_WSESSION_SHORT}", json={})
        assert r.status_code == 400

    def test_update_not_found(self):
        with patch(
            "npl_mcp.sessions.session_update",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "uuid": _WSESSION_SHORT},
        ):
            client = _make_client()
            r = client.patch(
                f"/api/work-sessions/{_WSESSION_SHORT}",
                json={"title": "X"},
            )
        assert r.status_code == 404


# ---------------------------------------------------------------------------
# Artifacts endpoints (PRD-002 MVP)
# ---------------------------------------------------------------------------

def _artifact_module_head(**overrides):
    base = {
        "status": "ok",
        "id": 7,
        "title": "Draft PRD",
        "kind": "markdown",
        "description": "Initial draft",
        "created_by": "npl-prd-editor",
        "latest_revision": 1,
        "created_at": "2026-04-21T12:00:00+00:00",
        "updated_at": "2026-04-21T12:00:00+00:00",
    }
    base.update(overrides)
    return base


def _artifact_module_full(**overrides):
    base = _artifact_module_head(**overrides)
    base.setdefault("revision", {
        "id": 101,
        "artifact_id": base["id"],
        "revision": 1,
        "content": "# Draft\n\nBody.",
        "notes": None,
        "created_by": "npl-prd-editor",
        "created_at": "2026-04-21T12:00:00+00:00",
    })
    return base


class TestArtifactsList:
    def test_empty(self):
        with patch(
            "npl_mcp.artifacts.artifact_list",
            new_callable=AsyncMock,
            return_value={"status": "ok", "artifacts": [], "count": 0},
        ):
            client = _make_client()
            r = client.get("/api/artifacts")
        assert r.status_code == 200
        assert r.json()["count"] == 0

    def test_with_kind_filter(self):
        arts = [_artifact_module_head(id=1, kind="json")]
        with patch(
            "npl_mcp.artifacts.artifact_list",
            new_callable=AsyncMock,
            return_value={"status": "ok", "artifacts": arts, "count": 1},
        ) as mocked:
            client = _make_client()
            r = client.get("/api/artifacts?kind=json&limit=10")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 1
        assert data["artifacts"][0]["kind"] == "json"
        assert mocked.await_args.kwargs["kind"] == "json"
        assert mocked.await_args.kwargs["limit"] == 10

    def test_module_error_bubbles_as_400(self):
        with patch(
            "npl_mcp.artifacts.artifact_list",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "Invalid kind 'widget'."},
        ):
            client = _make_client()
            r = client.get("/api/artifacts?kind=widget")
        assert r.status_code == 400


class TestArtifactsCreate:
    def test_create_returns_full_dto(self):
        with patch(
            "npl_mcp.artifacts.artifact_create",
            new_callable=AsyncMock,
            return_value=_artifact_module_full(id=9, title="Spec"),
        ) as mocked:
            client = _make_client()
            r = client.post("/api/artifacts", json={
                "title": "Spec",
                "content": "# Draft\n\nBody.",
                "kind": "markdown",
            })
        assert r.status_code == 200
        data = r.json()
        assert data["id"] == 9
        assert data["revision"]["revision"] == 1
        assert data["revision"]["content"].startswith("# Draft")
        assert mocked.await_args.kwargs["title"] == "Spec"

    def test_create_empty_title_returns_400(self):
        with patch(
            "npl_mcp.artifacts.artifact_create",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "title must be a non-empty string."},
        ):
            client = _make_client()
            r = client.post("/api/artifacts", json={"title": "", "content": "x"})
        assert r.status_code == 400


class TestArtifactsGet:
    def test_get_latest(self):
        with patch(
            "npl_mcp.artifacts.artifact_get",
            new_callable=AsyncMock,
            return_value=_artifact_module_full(id=7, latest_revision=3),
        ) as mocked:
            client = _make_client()
            r = client.get("/api/artifacts/7")
        assert r.status_code == 200
        assert r.json()["id"] == 7
        assert mocked.await_args.kwargs["revision"] is None

    def test_get_specific_revision(self):
        full = _artifact_module_full(id=7, latest_revision=3)
        full["revision"]["revision"] = 2
        with patch(
            "npl_mcp.artifacts.artifact_get",
            new_callable=AsyncMock,
            return_value=full,
        ) as mocked:
            client = _make_client()
            r = client.get("/api/artifacts/7?revision=2")
        assert r.status_code == 200
        assert r.json()["revision"]["revision"] == 2
        assert mocked.await_args.kwargs["revision"] == 2

    def test_not_found(self):
        with patch(
            "npl_mcp.artifacts.artifact_get",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "id": 999},
        ):
            client = _make_client()
            r = client.get("/api/artifacts/999")
        assert r.status_code == 404

    def test_missing_revision_returns_400(self):
        with patch(
            "npl_mcp.artifacts.artifact_get",
            new_callable=AsyncMock,
            return_value={"status": "error", "message": "Revision 99 not found for artifact 7."},
        ):
            client = _make_client()
            r = client.get("/api/artifacts/7?revision=99")
        assert r.status_code == 400


class TestArtifactsRevisions:
    def test_list_revisions(self):
        with patch(
            "npl_mcp.artifacts.artifact_list_revisions",
            new_callable=AsyncMock,
            return_value={
                "status": "ok",
                "artifact_id": 7,
                "revisions": [
                    {"id": 100, "artifact_id": 7, "revision": 1, "notes": None,
                     "created_by": "u", "created_at": "2026-01-01T00:00:00+00:00"},
                    {"id": 101, "artifact_id": 7, "revision": 2, "notes": "tweak",
                     "created_by": "u", "created_at": "2026-01-02T00:00:00+00:00"},
                ],
                "count": 2,
            },
        ):
            client = _make_client()
            r = client.get("/api/artifacts/7/revisions")
        assert r.status_code == 200
        data = r.json()
        assert data["count"] == 2
        assert data["revisions"][1]["notes"] == "tweak"

    def test_list_revisions_not_found(self):
        with patch(
            "npl_mcp.artifacts.artifact_list_revisions",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "id": 999},
        ):
            client = _make_client()
            r = client.get("/api/artifacts/999/revisions")
        assert r.status_code == 404

    def test_add_revision(self):
        full = _artifact_module_full(id=7, latest_revision=2)
        full["revision"]["revision"] = 2
        full["revision"]["content"] = "updated body"
        with patch(
            "npl_mcp.artifacts.artifact_add_revision",
            new_callable=AsyncMock,
            return_value=full,
        ) as mocked:
            client = _make_client()
            r = client.post("/api/artifacts/7/revisions", json={
                "content": "updated body",
                "notes": "refinement",
            })
        assert r.status_code == 200
        data = r.json()
        assert data["latest_revision"] == 2
        assert data["revision"]["revision"] == 2
        assert mocked.await_args.kwargs["content"] == "updated body"
        assert mocked.await_args.kwargs["notes"] == "refinement"

    def test_add_revision_not_found(self):
        with patch(
            "npl_mcp.artifacts.artifact_add_revision",
            new_callable=AsyncMock,
            return_value={"status": "not_found", "id": 999},
        ):
            client = _make_client()
            r = client.post("/api/artifacts/999/revisions", json={"content": "x"})
        assert r.status_code == 404


# ---------------------------------------------------------------------------
# Tool error log tests  (US-049)
# ---------------------------------------------------------------------------

def _make_acquire_pool(rows: list) -> MagicMock:
    """Build a pool mock whose acquire() context manager returns a conn with fetch()."""
    from contextlib import asynccontextmanager

    conn = MagicMock()
    conn.fetch = AsyncMock(return_value=rows)
    pool = MagicMock()

    @asynccontextmanager
    async def _acquire():
        yield conn

    pool.acquire = _acquire
    return pool


class TestErrorLog:
    def test_errors_empty_list(self):
        """GET /api/errors returns an empty list when DB has no errors."""
        pool = _make_acquire_pool([])
        with patch("npl_mcp.storage.error_log.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/errors")
        assert r.status_code == 200
        assert r.json() == []

    def test_errors_limit_clamp(self):
        """GET /api/errors?limit=9999 is rejected (> 200 max)."""
        pool = _make_acquire_pool([])
        with patch("npl_mcp.storage.error_log.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/errors?limit=9999")
        # FastAPI query validator should reject > 200 with 422
        assert r.status_code == 422

    def test_errors_db_unavailable_returns_503(self):
        """GET /api/errors returns 503 when the DB pool raises."""
        with patch(
            "npl_mcp.storage.error_log.get_pool",
            new_callable=AsyncMock,
            side_effect=RuntimeError("DB is down"),
        ):
            client = _make_client()
            r = client.get("/api/errors")
        assert r.status_code == 503

    def test_errors_returns_recent_errors(self):
        """GET /api/errors returns rows from npl_tool_errors."""
        import datetime

        created = datetime.datetime(2026, 4, 21, 12, 0, 0, tzinfo=datetime.timezone.utc)
        row = MagicMock()
        row.__getitem__ = lambda self, key: {
            "id": 1,
            "tool_name": "Ping",
            "error_type": "ConnectionError",
            "error_message": "Connection refused",
            "session_id": None,
            "stack_excerpt": "Traceback...",
            "created_at": created,
        }[key]

        pool = _make_acquire_pool([row])
        with patch("npl_mcp.storage.error_log.get_pool", new_callable=AsyncMock, return_value=pool):
            client = _make_client()
            r = client.get("/api/errors?limit=10")

        assert r.status_code == 200
        data = r.json()
        assert len(data) == 1
        assert data[0]["tool_name"] == "Ping"
        assert data[0]["error_type"] == "ConnectionError"
        assert data[0]["error_message"] == "Connection refused"
        assert data[0]["session_id"] is None
        assert data[0]["created_at"].endswith("Z")


# ---------------------------------------------------------------------------
# NPL Coverage endpoint tests (US-205)
# ---------------------------------------------------------------------------

class TestNPLCoverage:
    def _write_conv(self, tmp_path, fname, data):
        import yaml as _yaml
        (tmp_path / fname).write_text(_yaml.dump(data))

    def test_coverage_returns_200_with_expected_keys(self, tmp_path):
        """GET /api/npl/coverage returns 200 and all top-level keys."""
        from npl_mcp.api import router as router_mod

        self._write_conv(tmp_path, "syntax.yaml", {
            "name": "syntax",
            "components": [
                {
                    "name": "placeholder",
                    "brief": "A token",
                    "description": "Used for value substitution.",
                    "syntax": [{"pattern": "{var}"}],
                    "examples": [{"name": "basic", "thread": []}],
                },
                {
                    "name": "in-fill",
                    "brief": "",
                    "description": "",
                    "syntax": [],
                    "examples": [],
                },
            ],
        })
        # npl.yaml should be skipped
        self._write_conv(tmp_path, "npl.yaml", {"name": "npl", "components": []})

        original = router_mod._CONVENTIONS_DIR
        try:
            router_mod._CONVENTIONS_DIR = tmp_path
            client = _make_client()
            r = client.get("/api/npl/coverage")
        finally:
            router_mod._CONVENTIONS_DIR = original

        assert r.status_code == 200
        data = r.json()
        for key in ("total_sections", "total_components", "complete_components",
                    "coverage_percent", "by_section"):
            assert key in data, f"missing key: {key}"
        assert data["total_sections"] == 1
        assert data["total_components"] == 2
        assert data["complete_components"] == 1
        assert data["coverage_percent"] == 50

    def test_coverage_section_entries_have_required_fields(self, tmp_path):
        """Each section entry in by_section has all required fields."""
        from npl_mcp.api import router as router_mod

        self._write_conv(tmp_path, "pumps.yaml", {
            "name": "pumps",
            "components": [
                {
                    "name": "chain-of-thought",
                    "brief": "Step-by-step reasoning.",
                    "description": "Guides the model to reason step by step.",
                    "syntax": [{"pattern": "<npl-cot>...</npl-cot>"}],
                    "examples": [{"name": "basic", "thread": []}],
                },
                {
                    "name": "mood",
                    "brief": "Affective state.",
                    "description": "",
                    "syntax": [],
                    "examples": [],
                },
            ],
        })

        original = router_mod._CONVENTIONS_DIR
        try:
            router_mod._CONVENTIONS_DIR = tmp_path
            client = _make_client()
            r = client.get("/api/npl/coverage")
        finally:
            router_mod._CONVENTIONS_DIR = original

        assert r.status_code == 200
        data = r.json()
        assert len(data["by_section"]) == 1
        sec = data["by_section"][0]
        for field in ("section", "total", "complete", "coverage_percent", "missing"):
            assert field in sec, f"missing field: {field}"
        assert sec["section"] == "pumps"
        assert sec["total"] == 2
        assert sec["complete"] == 1
        assert "mood" in sec["missing"]

    def test_coverage_percent_within_0_100(self, tmp_path):
        """coverage_percent and each section's coverage_percent are in [0, 100]."""
        from npl_mcp.api import router as router_mod

        self._write_conv(tmp_path, "syntax.yaml", {
            "name": "syntax",
            "components": [
                {
                    "name": "a",
                    "brief": "brief a",
                    "description": "desc a",
                    "syntax": [{"pattern": "x"}],
                    "examples": [{"name": "e", "thread": []}],
                },
                {
                    "name": "b",
                    "brief": "",
                    "description": "",
                    "syntax": [],
                    "examples": [],
                },
            ],
        })

        original = router_mod._CONVENTIONS_DIR
        try:
            router_mod._CONVENTIONS_DIR = tmp_path
            client = _make_client()
            r = client.get("/api/npl/coverage")
        finally:
            router_mod._CONVENTIONS_DIR = original

        assert r.status_code == 200
        data = r.json()
        assert 0 <= data["coverage_percent"] <= 100
        for sec in data["by_section"]:
            assert 0 <= sec["coverage_percent"] <= 100


# ---------------------------------------------------------------------------
# Browser / ToMarkdown tests (US-096)
# ---------------------------------------------------------------------------

class TestBrowserToMarkdown:
    @patch("npl_mcp.browser.to_markdown.to_markdown", new_callable=AsyncMock)
    def test_valid_url_returns_markdown(self, mock_tm):
        """POST /api/browser/to-markdown with a valid URL returns markdown payload."""
        mock_tm.return_value = {
            "source": "https://example.com",
            "content": "# Hello\n\nWorld",
            "content_length": 16,
        }
        client = _make_client()
        r = client.post(
            "/api/browser/to-markdown",
            json={"source": "https://example.com"},
        )
        assert r.status_code == 200
        data = r.json()
        assert data["markdown"] == "# Hello\n\nWorld"
        assert data["source"] == "https://example.com"
        assert data["char_count"] == 16

    def test_empty_source_returns_400(self):
        """POST with empty source returns HTTP 400."""
        client = _make_client()
        r = client.post(
            "/api/browser/to-markdown",
            json={"source": ""},
        )
        assert r.status_code == 400

    @patch("npl_mcp.browser.to_markdown.to_markdown", new_callable=AsyncMock)
    def test_to_markdown_exception_returns_500(self, mock_tm):
        """When to_markdown raises, the endpoint returns HTTP 500 with the error message."""
        mock_tm.side_effect = RuntimeError("fetch failed: connection refused")
        client = _make_client()
        r = client.post(
            "/api/browser/to-markdown",
            json={"source": "https://example.com"},
        )
        assert r.status_code == 500
        assert "fetch failed" in r.json()["detail"]
