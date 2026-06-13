from __future__ import annotations

import hashlib

from direnv_config.store import path_to_hash


def test_path_hash_simple():
    assert path_to_hash("/Users/keith/Github/k8/projects") == "Users-keith-Github-k8-projects"


def test_path_hash_root():
    assert path_to_hash("/") == ""


def test_path_hash_single_segment():
    assert path_to_hash("/tmp") == "tmp"


def test_path_hash_no_leading_slash():
    assert path_to_hash("relative/path") == "relative-path"


def test_path_hash_truncation():
    segments = "/".join(["abcdefghij"] * 20)
    full_path = f"/{segments}"
    result = path_to_hash(full_path)

    stripped = full_path.lstrip("/")
    name = stripped.replace("/", "-")
    expected_digest = hashlib.sha256(full_path.encode()).hexdigest()[:8]
    expected = f"{name[:200]}-{expected_digest}"

    assert result == expected
    assert len(result) == 209
    assert result[200] == "-"
    assert all(c in "0123456789abcdef" for c in result[201:])


def test_path_hash_short_stays_intact():
    assert path_to_hash("/a/b/c") == "a-b-c"
