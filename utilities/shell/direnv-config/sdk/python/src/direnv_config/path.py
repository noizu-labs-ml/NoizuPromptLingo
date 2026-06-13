from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Union


@dataclass(frozen=True)
class Key:
    name: str


@dataclass(frozen=True)
class Index:
    value: int


@dataclass(frozen=True)
class Wildcard:
    pass


@dataclass(frozen=True)
class Length:
    pass


Segment = Union[Key, Index, Wildcard, Length]


def parse_path(path: str) -> list[Segment]:
    if not path:
        return []

    segments: list[Segment] = []

    for token in path.split("."):
        if token == "length" and segments:
            segments.append(Length())
            continue

        bracket_pos = token.find("[")
        if bracket_pos != -1:
            key_part = token[:bracket_pos]
            if key_part:
                segments.append(Key(key_part))

            rest = token[bracket_pos:]
            while rest:
                open_pos = rest.find("[")
                if open_pos == -1:
                    break
                close_pos = rest.find("]")
                inner = rest[open_pos + 1 : close_pos]
                if inner == "*":
                    segments.append(Wildcard())
                else:
                    segments.append(Index(int(inner)))
                rest = rest[close_pos + 1 :]
        else:
            segments.append(Key(token))

    return segments


def _resolve_index(idx: int, length: int) -> int | None:
    resolved = length + idx if idx < 0 else idx
    if resolved < 0 or resolved >= length:
        return None
    return resolved


def _get_segments(current: Any, segments: list[Segment]) -> Any | None:
    if not segments:
        return current

    seg = segments[0]
    rest = segments[1:]

    if isinstance(seg, Key):
        if not isinstance(current, dict):
            return None
        child = current.get(seg.name)
        if child is None and seg.name not in current:
            return None
        return _get_segments(child, rest)

    if isinstance(seg, Index):
        if not isinstance(current, list):
            return None
        resolved = _resolve_index(seg.value, len(current))
        if resolved is None:
            return None
        return _get_segments(current[resolved], rest)

    if isinstance(seg, Wildcard):
        if not isinstance(current, list):
            return None
        collected = []
        for elem in current:
            result = _get_segments(elem, rest)
            if result is not None:
                collected.append(result)
        return collected

    if isinstance(seg, Length):
        if rest:
            return None
        if isinstance(current, (list, dict)):
            return len(current)
        return None

    return None


def get_path(root: Any, path: str) -> Any | None:
    segments = parse_path(path)
    return _get_segments(root, segments)


def set_path(root: Any, path: str, value: Any) -> Any:
    """Walk/create intermediate containers and set the value at the given path."""
    segments = parse_path(path)
    if not segments:
        return value

    if root is None:
        root = {} if isinstance(segments[0], Key) else []

    current = root
    for i, seg in enumerate(segments[:-1]):
        next_seg = segments[i + 1]
        # Determine what container the *next* segment needs
        next_container: type = dict if isinstance(next_seg, Key) else list

        if isinstance(seg, Key):
            if not isinstance(current, dict):
                raise TypeError(f"expected dict at segment {seg.name!r}, got {type(current).__name__}")
            child = current.get(seg.name)
            if child is None or not isinstance(child, (dict, list)):
                current[seg.name] = next_container()
            current = current[seg.name]

        elif isinstance(seg, Index):
            if not isinstance(current, list):
                raise TypeError(f"expected list at index {seg.value}, got {type(current).__name__}")
            idx = seg.value
            if idx < 0:
                resolved = len(current) + idx
                if resolved < 0:
                    raise IndexError(f"negative index {idx} out of range for list of length {len(current)}")
                idx = resolved
            # Extend list if index is beyond current length
            while len(current) <= idx:
                current.append(None)
            child = current[idx]
            if child is None or not isinstance(child, (dict, list)):
                current[idx] = next_container()
            current = current[idx]

        elif isinstance(seg, (Wildcard, Length)):
            raise ValueError(f"cannot use {type(seg).__name__} segment in set_path")

    # Apply the final segment
    last = segments[-1]
    if isinstance(last, Key):
        if not isinstance(current, dict):
            raise TypeError(f"expected dict at segment {last.name!r}, got {type(current).__name__}")
        current[last.name] = value

    elif isinstance(last, Index):
        if not isinstance(current, list):
            raise TypeError(f"expected list at index {last.value}, got {type(current).__name__}")
        idx = last.value
        if idx < 0:
            resolved = len(current) + idx
            if resolved < 0:
                raise IndexError(f"negative index {idx} out of range for list of length {len(current)}")
            idx = resolved
        while len(current) <= idx:
            current.append(None)
        current[idx] = value

    elif isinstance(last, (Wildcard, Length)):
        raise ValueError(f"cannot use {type(last).__name__} segment in set_path")

    return root


def delete_path(root: Any, path: str) -> bool:
    """Walk to parent and delete the key/index. Returns True if found and removed."""
    segments = parse_path(path)
    if not segments:
        return False

    # Walk to the parent of the final segment
    current = root
    for seg in segments[:-1]:
        if isinstance(seg, Key):
            if not isinstance(current, dict) or seg.name not in current:
                return False
            current = current[seg.name]
        elif isinstance(seg, Index):
            if not isinstance(current, list):
                return False
            resolved = _resolve_index(seg.value, len(current))
            if resolved is None:
                return False
            current = current[resolved]
        else:
            return False

    last = segments[-1]
    if isinstance(last, Key):
        if not isinstance(current, dict) or last.name not in current:
            return False
        del current[last.name]
        return True

    if isinstance(last, Index):
        if not isinstance(current, list):
            return False
        resolved = _resolve_index(last.value, len(current))
        if resolved is None:
            return False
        current.pop(resolved)
        return True

    return False
