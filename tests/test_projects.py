"""Tests for npl_mcp.tool_sessions.projects."""

import uuid
from unittest.mock import AsyncMock, patch

import pytest
import shortuuid

from npl_mcp.tool_sessions.projects import NPL_NAMESPACE, project_uuid, upsert_project


class TestProjectUuid:
    def test_deterministic(self):
        """Same name always produces the same UUID."""
        a = project_uuid("my-project")
        b = project_uuid("my-project")
        assert a == b

    def test_different_names_produce_different_uuids(self):
        """Different names produce different UUIDs."""
        a = project_uuid("alpha")
        b = project_uuid("beta")
        assert a != b

    def test_includes_npl_prefix(self):
        """The hash input is 'npl/{name}', not just '{name}'."""
        direct = uuid.uuid5(NPL_NAMESPACE, "npl/foo")
        assert project_uuid("foo") == direct

    def test_legacy_uuid_matches_migration(self):
        """The legacy project UUID must match the hardcoded migration value."""
        expected = uuid.UUID("abde7a0e-fe09-5a67-8e95-dd30da1862a2")
        assert project_uuid("legacy") == expected

    def test_returns_uuid_object(self):
        result = project_uuid("test")
        assert isinstance(result, uuid.UUID)

    def test_empty_name_still_produces_uuid(self):
        """Empty string is technically valid for uuid5 — callers validate."""
        result = project_uuid("")
        assert isinstance(result, uuid.UUID)


class TestUpsertProject:
    @patch("npl_mcp.tool_sessions.projects.get_pool")
    async def test_upsert_new_project(self, mock_get_pool):
        pool = AsyncMock()
        mock_get_pool.return_value = pool

        result = await upsert_project("test-proj")
        assert result == project_uuid("test-proj")
        pool.execute.assert_called_once()
        call_args = pool.execute.call_args[0]
        assert call_args[1] == project_uuid("test-proj")
        assert call_args[2] == "test-proj"

    @patch("npl_mcp.tool_sessions.projects.get_pool")
    async def test_upsert_existing_project(self, mock_get_pool):
        """ON CONFLICT path — still returns the same UUID."""
        pool = AsyncMock()
        mock_get_pool.return_value = pool

        result = await upsert_project("existing-proj")
        assert result == project_uuid("existing-proj")
        pool.execute.assert_called_once()
        # SQL should contain ON CONFLICT
        sql = pool.execute.call_args[0][0]
        assert "ON CONFLICT" in sql
