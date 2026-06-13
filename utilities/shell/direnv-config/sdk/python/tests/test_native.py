from __future__ import annotations

from pathlib import Path

from direnv_config.native import NativeBackend
from direnv_config.version import read_version

FIXTURES_DIR = Path(__file__).resolve().parent.parent.parent / "contract-tests" / "fixtures"


def test_simple_store_get_string():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    assert backend.get("cluster", "name") == "noizu"


def test_simple_store_get_nested():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    assert backend.get("cluster", "node_pool.instance_type") == "m5.xlarge"


def test_simple_store_get_integer():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    assert backend.get("cluster", "port") == 6443


def test_simple_store_get_boolean():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    assert backend.get("cluster", "enabled") is True


def test_simple_store_get_entire_config():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    data = backend.get("cluster")
    assert isinstance(data, dict)
    assert "name" in data
    assert "node_pool" in data


def test_simple_store_list_configs():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    configs = backend.list_configs()
    assert configs == ["cluster"]


def test_simple_store_version():
    version = read_version(FIXTURES_DIR / "simple-store")
    assert version == 3


def test_nested_store_array_index():
    backend = NativeBackend(FIXTURES_DIR / "nested-store")
    assert backend.get("app", "endpoints[0].host") == "api.example.com"


def test_nested_store_wildcard():
    backend = NativeBackend(FIXTURES_DIR / "nested-store")
    hosts = backend.get("app", "endpoints[*].host")
    assert hosts == ["api.example.com", "internal.example.com", "backup.example.com"]


def test_nested_store_length():
    backend = NativeBackend(FIXTURES_DIR / "nested-store")
    assert backend.get("app", "endpoints.length") == 3


def test_nested_store_chained_index():
    backend = NativeBackend(FIXTURES_DIR / "nested-store")
    assert backend.get("app", "matrix[0][1]") == 2


def test_nested_store_missing_path():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    assert backend.get("cluster", "nonexistent") is None


def test_nested_store_missing_config():
    backend = NativeBackend(FIXTURES_DIR / "simple-store")
    assert backend.get("nonexistent") is None


# ---------------------------------------------------------------------------
# Write method tests (use tmp_path to avoid mutating fixtures)
# ---------------------------------------------------------------------------

import yaml


def _make_store(tmp_path):
    """Create a minimal store with a base layer."""
    store = tmp_path / "store"
    store.mkdir()
    config_dir = store / "myapp"
    config_dir.mkdir()
    base = {"host": "localhost", "port": 3000}
    (config_dir / "base.yaml").write_text(yaml.dump(base, default_flow_style=False))
    # create .active so get works
    (config_dir / ".active").write_text(yaml.dump(base, default_flow_style=False))
    # create .meta
    (store / ".meta").write_text(yaml.dump({"configs": ["myapp"]}, default_flow_style=False))
    return store


def test_set_writes_to_layer_and_updates_active(tmp_path):
    store = _make_store(tmp_path)
    backend = NativeBackend(store)

    backend.set("myapp", "debug", "true")

    # Verify value is accessible
    assert backend.get("myapp", "debug") is True

    # Verify local layer was written
    local_layer = store / "myapp" / "local.yaml"
    assert local_layer.exists()
    doc = yaml.safe_load(local_layer.read_text())
    assert doc["debug"] is True

    # Verify version was bumped
    assert read_version(store) == 1


def test_set_with_no_bump(tmp_path):
    store = _make_store(tmp_path)
    backend = NativeBackend(store)

    backend.set("myapp", "key", "value", no_bump=True)

    assert backend.get("myapp", "key") == "value"
    assert read_version(store) == 0


def test_set_with_custom_layer(tmp_path):
    store = _make_store(tmp_path)
    backend = NativeBackend(store)

    backend.set("myapp", "secret_key", "s3cret", layer="secrets")

    secrets_file = store / "myapp" / "secrets.yaml"
    assert secrets_file.exists()
    doc = yaml.safe_load(secrets_file.read_text())
    assert doc["secret_key"] == "s3cret"


def test_unset_removes_key_and_updates_active(tmp_path):
    store = _make_store(tmp_path)
    backend = NativeBackend(store)

    # First set a key in local layer
    backend.set("myapp", "debug", "true")
    assert backend.get("myapp", "debug") is True

    # Now unset it
    backend.unset("myapp", ["debug"])

    local_layer = store / "myapp" / "local.yaml"
    doc = yaml.safe_load(local_layer.read_text())
    assert "debug" not in doc


def test_unset_on_missing_layer_is_noop(tmp_path):
    store = _make_store(tmp_path)
    backend = NativeBackend(store)

    # local.yaml doesn't exist yet, should not raise
    backend.unset("myapp", ["nonexistent"], layer="local")

    # Version should still be 0 since nothing happened
    assert read_version(store) == 0


def test_bump_increments_version(tmp_path):
    store = _make_store(tmp_path)
    backend = NativeBackend(store)

    v1 = backend.bump()
    assert v1 == 1
    v2 = backend.bump()
    assert v2 == 2
