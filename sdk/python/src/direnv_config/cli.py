from __future__ import annotations

import subprocess
from pathlib import Path
from typing import Any

import yaml

from direnv_config.native import NativeBackend


class CliBackend:
    def __init__(self, store: Path, dc_binary: str = "dc") -> None:
        self._store = store
        self._dc_binary = dc_binary
        self._native = NativeBackend(store)

    def get(self, config: str, path: str | None = None) -> Any:
        cmd = [self._dc_binary, "get", config]
        if path is not None:
            cmd.append(path)
        cmd.append("--raw")
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        if result.returncode != 0:
            return None
        output = result.stdout.strip()
        if not output:
            return None
        return yaml.safe_load(output)

    def list_configs(self) -> list[str]:
        return self._native.list_configs()

    def set(
        self,
        config: str,
        key: str,
        value: str,
        layer: str = "local",
        no_bump: bool = False,
    ) -> None:
        cmd = [self._dc_binary, "set", config, key, value]
        if layer != "local":
            cmd.extend(["--layer", layer])
        if no_bump:
            cmd.append("--no-bump")
        subprocess.run(cmd, check=True)

    def unset(
        self,
        config: str,
        keys: list[str],
        layer: str = "local",
        no_bump: bool = False,
    ) -> None:
        cmd = [self._dc_binary, "unset", config, *keys]
        if layer != "local":
            cmd.extend(["--layer", layer])
        if no_bump:
            cmd.append("--no-bump")
        subprocess.run(cmd, check=True)

    def bump(self) -> int:
        result = subprocess.run(
            [self._dc_binary, "bump"],
            capture_output=True,
            text=True,
            check=True,
        )
        # Parse version from stderr output (e.g., "version: 42")
        for line in result.stderr.splitlines():
            stripped = line.strip()
            if stripped.startswith("version:"):
                return int(stripped.split(":", 1)[1].strip())
        # Fallback: try stdout
        for line in result.stdout.splitlines():
            stripped = line.strip()
            if stripped.startswith("version:"):
                return int(stripped.split(":", 1)[1].strip())
        return 0
