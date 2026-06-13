from __future__ import annotations

from direnv_config.merge import deep_merge, deep_merge_multi


def test_overlay_scalar_replaces_base():
    assert deep_merge({"a": 1}, {"a": 2}) == {"a": 2}


def test_adds_new_keys():
    assert deep_merge({"a": 1}, {"b": 2}) == {"a": 1, "b": 2}


def test_recursive_map_merge():
    base = {"db": {"host": "localhost", "port": 5432}}
    overlay = {"db": {"port": 5433, "ssl": True}}
    result = deep_merge(base, overlay)
    assert result == {"db": {"host": "localhost", "port": 5433, "ssl": True}}


def test_array_overlay_replaces_base_array():
    base = {"tags": [1, 2, 3]}
    overlay = {"tags": [4, 5]}
    result = deep_merge(base, overlay)
    assert result == {"tags": [4, 5]}


def test_type_mismatch_overlay_wins():
    assert deep_merge({"a": "string"}, {"a": [1, 2]}) == {"a": [1, 2]}
    assert deep_merge({"a": [1]}, {"a": "scalar"}) == {"a": "scalar"}


def test_tombstone_strips_subtree():
    base = {"a": 1, "b": {"nested": True}}
    overlay = {"b": {"_dc_pruned": True}}
    result = deep_merge(base, overlay)
    assert "b" not in result


def test_nested_tombstone():
    base = {"a": {"b": {"c": 1, "d": 2}}}
    overlay = {"a": {"b": {"c": {"_dc_pruned": True}}}}
    result = deep_merge(base, overlay)
    assert result == {"a": {"b": {"d": 2}}}


def test_deep_merge_multi_empty_returns_none():
    assert deep_merge_multi([]) is None


def test_deep_merge_multi_single_element():
    result = deep_merge_multi([{"a": 1}])
    assert result == {"a": 1}


def test_deep_merge_multi_folds_left_to_right():
    layers = [
        {"a": 1, "b": 10},
        {"b": 20, "c": 30},
        {"c": 99},
    ]
    result = deep_merge_multi(layers)
    assert result == {"a": 1, "b": 20, "c": 99}
