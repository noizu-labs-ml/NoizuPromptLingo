from __future__ import annotations

from pathlib import Path

import yaml

from direnv_config.resolve import resolve_active


def _write_layer(config_dir: Path, name: str, data: dict) -> None:
    config_dir.mkdir(parents=True, exist_ok=True)
    (config_dir / f"{name}.yaml").write_text(yaml.dump(data, default_flow_style=False))


def test_merges_base_and_local(tmp_path: Path):
    config_dir = tmp_path / "myapp"
    _write_layer(config_dir, "base", {"host": "localhost", "port": 3000})
    _write_layer(config_dir, "local", {"port": 4000, "debug": True})

    result = resolve_active(tmp_path, "myapp")
    assert result["host"] == "localhost"
    assert result["port"] == 4000
    assert result["debug"] is True


def test_respects_dc_env_layer(tmp_path: Path, monkeypatch):
    config_dir = tmp_path / "myapp"
    _write_layer(config_dir, "base", {"env": "default"})
    _write_layer(config_dir, "staging", {"env": "staging"})

    monkeypatch.setenv("DC_ENV", "staging")
    result = resolve_active(tmp_path, "myapp")
    assert result["env"] == "staging"


def test_skips_missing_layers(tmp_path: Path):
    config_dir = tmp_path / "myapp"
    _write_layer(config_dir, "base", {"only": "base"})
    # no local, no env, no secrets

    result = resolve_active(tmp_path, "myapp")
    assert result == {"only": "base"}


def test_writes_active_file(tmp_path: Path):
    config_dir = tmp_path / "myapp"
    _write_layer(config_dir, "base", {"key": "value"})

    resolve_active(tmp_path, "myapp")

    active_file = config_dir / ".active"
    assert active_file.exists()
    data = yaml.safe_load(active_file.read_text())
    assert data == {"key": "value"}


def test_returns_merged_value(tmp_path: Path):
    config_dir = tmp_path / "myapp"
    _write_layer(config_dir, "base", {"a": 1})
    _write_layer(config_dir, "local", {"b": 2})

    result = resolve_active(tmp_path, "myapp")
    assert result == {"a": 1, "b": 2}
