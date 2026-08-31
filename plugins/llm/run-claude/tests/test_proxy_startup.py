"""Focused tests for fail-fast proxy startup behavior."""

from __future__ import annotations

from unittest.mock import Mock

from run_claude import proxy


def _base_startup_mocks(monkeypatch):
    # These tests exercise the legacy Python litellm-proxy startup path (DB
    # migration + schema). The unified go-litellm gateway is the default now, so
    # force legacy mode here.
    monkeypatch.setattr(proxy, "use_unified_gateway", lambda: False)
    monkeypatch.setattr(proxy, "is_proxy_running", lambda: False)
    monkeypatch.setattr(proxy, "health_check", lambda *args, **kwargs: False)
    monkeypatch.setattr(proxy, "is_infrastructure_installed", lambda: True)
    monkeypatch.setattr(proxy, "is_db_container_running", lambda: True)
    monkeypatch.setattr(proxy, "is_db_container_healthy", lambda: True)


def test_start_proxy_stops_when_migration_fails(monkeypatch, capsys):
    _base_startup_mocks(monkeypatch)
    monkeypatch.setattr(proxy, "_db_schema_exists", lambda debug=False: False)
    monkeypatch.setattr(proxy, "run_prisma_migrate", lambda debug=False: False)
    launch = Mock()
    monkeypatch.setattr(proxy, "_launch_proxy_process", launch)

    assert proxy.start_proxy(empty_config=True) is False
    launch.assert_not_called()
    assert "migration failed" in capsys.readouterr().err.lower()


def test_start_proxy_stops_when_running_database_never_becomes_healthy(
    monkeypatch, capsys
):
    _base_startup_mocks(monkeypatch)
    monkeypatch.setattr(proxy, "is_db_container_healthy", lambda: False)
    monkeypatch.setattr(proxy, "wait_for_db_healthy", lambda **kwargs: False)
    schema_check = Mock()
    monkeypatch.setattr(proxy, "_db_schema_exists", schema_check)

    assert proxy.start_proxy(empty_config=True) is False
    schema_check.assert_not_called()
    assert "did not become healthy" in capsys.readouterr().err.lower()


def test_start_proxy_verifies_schema_after_migration(monkeypatch, capsys):
    _base_startup_mocks(monkeypatch)
    schema_checks = iter([False, False])
    monkeypatch.setattr(
        proxy, "_db_schema_exists", lambda debug=False: next(schema_checks)
    )
    monkeypatch.setattr(proxy, "run_prisma_migrate", lambda debug=False: True)
    launch = Mock()
    monkeypatch.setattr(proxy, "_launch_proxy_process", launch)

    assert proxy.start_proxy(empty_config=True) is False
    launch.assert_not_called()
    assert "schema is still missing" in capsys.readouterr().err.lower()
