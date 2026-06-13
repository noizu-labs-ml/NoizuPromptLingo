from __future__ import annotations

from pathlib import Path
from typing import Any, Callable, Literal

from direnv_config.cli import CliBackend
from direnv_config.native import NativeBackend
from direnv_config.store import find_current_store, state_dir, store_path
from direnv_config.version import DcWatcher, read_version


class DcClient:
    def __init__(
        self,
        mode: Literal["native", "cli"] = "native",
        directory: str | None = None,
        state_dir_override: str | None = None,
        dc_binary: str = "dc",
    ) -> None:
        if directory is not None:
            self._store = store_path(directory)
        else:
            self._store = find_current_store()

        if mode == "cli":
            self._backend = CliBackend(self._store, dc_binary)
        else:
            self._backend = NativeBackend(self._store)  # type: ignore[assignment]

    def get(self, config: str, path: str | None = None) -> Any:
        return self._backend.get(config, path)

    def get_or_raise(self, config: str, path: str | None = None) -> Any:
        result = self._backend.get(config, path)
        if result is None:
            target = f"{config}.{path}" if path else config
            raise KeyError(f"config value not found: {target}")
        return result

    def get_string(self, config: str, path: str) -> str | None:
        value = self.get(config, path)
        if value is None:
            return None
        return str(value)

    def get_int(self, config: str, path: str) -> int | None:
        value = self.get(config, path)
        if value is None:
            return None
        return int(value)

    def get_bool(self, config: str, path: str) -> bool | None:
        value = self.get(config, path)
        if value is None:
            return None
        if isinstance(value, bool):
            return value
        if isinstance(value, str):
            return value.lower() in ("true", "yes", "1")
        return bool(value)

    def list_configs(self) -> list[str]:
        return self._backend.list_configs()

    def version(self) -> int:
        return read_version(self._store)

    def has_changed(self, since: int) -> bool:
        return read_version(self._store) != since

    def set(
        self,
        config: str,
        key: str,
        value: str,
        *,
        layer: str | None = None,
        no_bump: bool = False,
    ) -> None:
        self._backend.set(config, key, value, layer=layer or "local", no_bump=no_bump)

    def unset(
        self,
        config: str,
        keys: list[str],
        *,
        layer: str | None = None,
        no_bump: bool = False,
    ) -> None:
        self._backend.unset(config, keys, layer=layer or "local", no_bump=no_bump)

    def bump(self) -> int:
        return self._backend.bump()

    def watch(
        self,
        callback: Callable[[int], None],
        interval_ms: int = 1000,
    ) -> DcWatcher:
        return DcWatcher(self._store, callback, interval_ms)
