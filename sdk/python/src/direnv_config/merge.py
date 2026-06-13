from __future__ import annotations

from typing import Any


def _is_tombstone(val: Any) -> bool:
    """Check if a value is a tombstone marker ({_dc_pruned: True})."""
    return isinstance(val, dict) and val.get("_dc_pruned") is True


def _strip_tombstones(val: Any) -> Any:
    """Recursively remove tombstone markers from a value."""
    if _is_tombstone(val):
        return None
    if isinstance(val, dict):
        cleaned: dict[str, Any] = {}
        for k, v in val.items():
            stripped = _strip_tombstones(v)
            if stripped is not None or not _is_tombstone(v):
                cleaned[k] = stripped
        return cleaned
    if isinstance(val, list):
        return [_strip_tombstones(item) for item in val]
    return val


def deep_merge(base: Any, overlay: Any) -> Any:
    """Merge overlay into base.

    - dicts: merge key-by-key recursively, overlay wins on conflict
    - lists/scalars: overlay replaces base entirely
    - Tombstone ({_dc_pruned: True}): strips entire subtree
    """
    if _is_tombstone(overlay):
        return None

    if isinstance(base, dict) and isinstance(overlay, dict):
        result = dict(base)
        for key, value in overlay.items():
            if _is_tombstone(value):
                result.pop(key, None)
            elif key in result:
                result[key] = deep_merge(result[key], value)
            else:
                result[key] = value
        return result

    # lists and scalars: overlay replaces base
    return overlay


def deep_merge_multi(layers: list[Any]) -> Any:
    """Fold layers left-to-right with deep_merge. Strip tombstones from result."""
    if not layers:
        return None
    if len(layers) == 1:
        return _strip_tombstones(layers[0])

    result = layers[0]
    for layer in layers[1:]:
        result = deep_merge(result, layer)
    return _strip_tombstones(result)
