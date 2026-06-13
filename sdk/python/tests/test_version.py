from __future__ import annotations

from pathlib import Path

from direnv_config.version import bump_version, read_version


def test_bump_from_zero(tmp_path: Path):
    assert read_version(tmp_path) == 0
    result = bump_version(tmp_path)
    assert result == 1
    assert read_version(tmp_path) == 1


def test_bump_increments_existing(tmp_path: Path):
    (tmp_path / ".version").write_text("5")
    result = bump_version(tmp_path)
    assert result == 6
    assert read_version(tmp_path) == 6


def test_sequential_bumps(tmp_path: Path):
    bump_version(tmp_path)
    bump_version(tmp_path)
    result = bump_version(tmp_path)
    assert result == 3
    assert read_version(tmp_path) == 3
