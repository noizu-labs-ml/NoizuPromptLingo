"""
Entry point for run-litellm-proxy: launches litellm with prisma schema setup.

Since litellm[proxy] is a dependency of run-claude, no separate venv is needed.
This module handles prisma schema patching and then execs litellm.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path


def _get_state_dir() -> Path:
    xdg = os.environ.get("XDG_STATE_HOME")
    if xdg:
        return Path(xdg) / "run-claude"
    return Path.home() / ".local" / "state" / "run-claude"


def _get_config_dir() -> Path:
    home = os.environ.get("RUN_CLAUDE_HOME")
    if home:
        return Path(home)
    xdg = os.environ.get("XDG_CONFIG_HOME")
    if xdg:
        return Path(xdg) / "run-claude"
    return Path.home() / ".config" / "run-claude"


def _verify_deps() -> Path:
    """Verify litellm is importable. Returns litellm package path or exits."""
    try:
        import litellm
        return Path(litellm.__path__[0])
    except ImportError:
        print("FATAL: litellm not installed in this environment.", file=sys.stderr)
        print("  This usually means 'uv tool install .' needs to be re-run.", file=sys.stderr)
        print("  Fix: cd <run-claude-project> && make refresh", file=sys.stderr)
        sys.exit(1)


def _find_prisma_schema(litellm_path: Path) -> Path:
    """Find litellm's prisma schema file or exit."""
    candidates = [
        litellm_path / "proxy" / "schema.prisma",
        litellm_path / "proxy" / "prisma" / "schema.prisma",
        litellm_path / "schema.prisma",
    ]
    for p in candidates:
        if p.exists():
            return p

    print("FATAL: Could not find litellm prisma schema.", file=sys.stderr)
    print(f"  Searched in: {litellm_path}", file=sys.stderr)
    sys.exit(1)


def _get_python_version() -> str:
    return f"{sys.version_info.major}.{sys.version_info.minor}"


def _setup_prisma(litellm_path: Path) -> None:
    """Patch and generate prisma schema with correct output path."""
    schema_src = _find_prisma_schema(litellm_path)
    litellm_home = Path.home() / ".local" / "share" / "litellm"
    litellm_home.mkdir(parents=True, exist_ok=True)
    local_schema = litellm_home / "schema2.prisma"

    venv_prefix = Path(sys.prefix)
    py_ver = _get_python_version()
    prisma_output = venv_prefix / "lib" / f"python{py_ver}" / "site-packages" / "prisma"

    content = schema_src.read_text()
    patched = content.replace(
        "generator client {",
        f'generator client {{\n  output = "{prisma_output}"',
        1,
    )
    local_schema.write_text(patched)

    env = os.environ.copy()
    venv_bin = str(Path(sys.prefix) / "bin")
    env["PATH"] = venv_bin + os.pathsep + env.get("PATH", "")

    result = subprocess.run(
        [sys.executable, "-m", "prisma", "generate", f"--schema={local_schema}"],
        capture_output=True,
        text=True,
        env=env,
    )
    if result.returncode != 0:
        print(f"Warning: prisma generate failed: {result.stderr}", file=sys.stderr)


def _load_env() -> None:
    """Source .envrc-style env file."""
    env_file = _get_config_dir() / ".envrc"
    if not env_file.exists():
        env_file = _get_config_dir() / ".env"
    if not env_file.exists():
        return

    for line in env_file.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if line.startswith("export "):
            line = line[7:]
        if "=" in line:
            key, _, value = line.partition("=")
            key = key.strip()
            value = value.strip().strip('"').strip("'")
            if key and key not in os.environ:
                os.environ[key] = value


def main() -> None:
    _load_env()

    litellm_path = _verify_deps()

    try:
        import prisma  # noqa: F401
    except ImportError:
        print("FATAL: prisma not installed.", file=sys.stderr)
        print("  Fix: cd <run-claude-project> && make refresh", file=sys.stderr)
        sys.exit(1)

    _setup_prisma(litellm_path)

    litellm_bin = Path(sys.prefix) / "bin" / "litellm"
    if not litellm_bin.exists():
        litellm_bin_str = shutil.which("litellm")
        if litellm_bin_str is None:
            print("FATAL: litellm binary not found on PATH or in venv.", file=sys.stderr)
            sys.exit(1)
        litellm_bin = Path(litellm_bin_str)

    os.environ.setdefault("HTTPX_LOG_LEVEL", "debug")
    os.environ.setdefault("LITELLM_LOG", "DEBUG")

    os.execv(str(litellm_bin), [str(litellm_bin)] + sys.argv[1:])


if __name__ == "__main__":
    main()
