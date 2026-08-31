"""Path-based uv sources must be Python projects (pyproject.toml or setup.py).

The Python ``litellm`` dependency must never be resolved from the Elixir tree
at ``repos/ex-litellm``.
"""

from __future__ import annotations

from pathlib import Path

import pytest

try:
    import tomllib
except ImportError:  # Python 3.10
    tomllib = None  # type: ignore[assignment]


PROJECT_ROOT = Path(__file__).resolve().parents[1]
PYPROJECT_TOML = PROJECT_ROOT / "pyproject.toml"
UV_LOCK = PROJECT_ROOT / "uv.lock"
EX_LITELLM = (PROJECT_ROOT / "repos" / "ex-litellm").resolve()


def _load_toml(path: Path) -> dict:
    if tomllib is None:
        pytest.skip("tomllib is required to parse packaging metadata")
    with path.open("rb") as fh:
        return tomllib.load(fh)


def _is_python_project(directory: Path) -> bool:
    return (directory / "pyproject.toml").is_file() or (directory / "setup.py").is_file()


def iter_pyproject_path_sources(data: dict) -> list[tuple[str, str]]:
    """Return (package_name, relative_path) for [tool.uv.sources] path entries."""
    sources = data.get("tool", {}).get("uv", {}).get("sources") or {}
    found: list[tuple[str, str]] = []
    if not isinstance(sources, dict):
        return found
    for name, spec in sources.items():
        if isinstance(spec, dict) and spec.get("path"):
            found.append((str(name), str(spec["path"])))
    return found


def iter_lockfile_path_sources(data: dict) -> list[tuple[str, str]]:
    """Return (package_name, relative_path) for lock entries sourced from a path."""
    found: list[tuple[str, str]] = []
    for package in data.get("package") or []:
        if not isinstance(package, dict):
            continue
        name = str(package.get("name") or "")
        source = package.get("source") or {}
        if not isinstance(source, dict):
            continue
        rel = source.get("editable") or source.get("path")
        if rel:
            found.append((name, str(rel)))
        metadata = package.get("metadata") or {}
        if not isinstance(metadata, dict):
            continue
        for req in metadata.get("requires-dist") or []:
            if not isinstance(req, dict):
                continue
            req_path = req.get("editable") or req.get("path")
            if req_path:
                found.append((str(req.get("name") or name), str(req_path)))
    return found


def path_source_errors(root: Path, sources: list[tuple[str, str]]) -> list[str]:
    """Return human-readable errors for invalid path sources.

    A path source is invalid if the directory is missing, is not a Python
    project, or maps the Python ``litellm`` package onto the Elixir gateway.
    """
    errors: list[str] = []
    for name, relpath in sources:
        target = (root / relpath).resolve()
        if name == "litellm" and target == EX_LITELLM:
            errors.append(
                f"{name} path source {relpath!r} is the Elixir tree "
                f"{EX_LITELLM}; Python litellm must not be sourced from it"
            )
            continue
        if not target.is_dir():
            errors.append(f"{name} path source {relpath!r} does not exist")
            continue
        if not _is_python_project(target):
            errors.append(
                f"{name} path source {relpath!r} is not a Python project "
                "(missing pyproject.toml and setup.py)"
            )
    return errors


def test_shipped_pyproject_path_sources_are_python_projects():
    data = _load_toml(PYPROJECT_TOML)
    errors = path_source_errors(PROJECT_ROOT, iter_pyproject_path_sources(data))
    assert errors == [], "invalid [tool.uv.sources] path entries:\n" + "\n".join(errors)


def test_shipped_lockfile_path_sources_are_python_projects():
    if not UV_LOCK.is_file():
        pytest.skip("uv.lock is not present")
    data = _load_toml(UV_LOCK)
    errors = path_source_errors(PROJECT_ROOT, iter_lockfile_path_sources(data))
    assert errors == [], "invalid uv.lock path/editable sources:\n" + "\n".join(errors)


def test_checker_rejects_ex_litellm_as_python_litellm_source():
    """The Elixir checkout exists and must fail the Python-project check."""
    assert EX_LITELLM.is_dir(), "repos/ex-litellm should exist for this assertion"
    errors = path_source_errors(
        PROJECT_ROOT, [("litellm", "repos/ex-litellm")]
    )
    assert errors, "expected repos/ex-litellm to be rejected as a litellm source"
    assert any("Elixir" in err or "not a Python project" in err for err in errors)


def test_checker_rejects_missing_python_checkout():
    errors = path_source_errors(
        PROJECT_ROOT, [("litellm", "repos/litellm")]
    )
    missing = PROJECT_ROOT / "repos" / "litellm"
    if missing.is_dir() and _is_python_project(missing):
        assert errors == []
    else:
        assert errors, "expected missing/non-Python repos/litellm to be rejected"
