from __future__ import annotations

from pathlib import Path
from typing import Any

import yaml

from direnv_config.path import delete_path, get_path, set_path
from direnv_config.resolve import resolve_active
from direnv_config.store import ensure_config, layer_path
from direnv_config.version import bump_version


class NativeBackend:
    def __init__(self, store: Path) -> None:
        self._store = store

    def get(self, config: str, path: str | None = None) -> Any:
        active_file = self._store / config / ".active"
        if not active_file.exists():
            return None
        contents = active_file.read_text()
        data = yaml.safe_load(contents)
        if path is None:
            return data
        return get_path(data, path)

    def list_configs(self) -> list[str]:
        meta_file = self._store / ".meta"
        if not meta_file.exists():
            return []
        contents = meta_file.read_text()
        meta = yaml.safe_load(contents)
        if meta is None or not isinstance(meta, dict):
            return []
        configs = meta.get("configs", [])
        if not isinstance(configs, list):
            return []
        return [str(c) for c in configs]

    def set(
        self,
        config: str,
        key: str,
        value: str,
        layer: str = "local",
        no_bump: bool = False,
    ) -> None:
        ensure_config(self._store, config)
        lp = layer_path(self._store, config, layer)

        # Read existing layer or start fresh
        if lp.exists():
            doc = yaml.safe_load(lp.read_text())
            if doc is None:
                doc = {}
        else:
            doc = {}

        # Parse the value string
        parsed_value: Any
        if value is None:
            parsed_value = value
        else:
            try:
                parsed_value = yaml.safe_load(value)
            except yaml.YAMLError:
                parsed_value = value

        doc = set_path(doc, key, parsed_value)
        lp.write_text(yaml.dump(doc, default_flow_style=False))

        resolve_active(self._store, config)

        if not no_bump:
            bump_version(self._store)

    def unset(
        self,
        config: str,
        keys: list[str],
        layer: str = "local",
        no_bump: bool = False,
    ) -> None:
        lp = layer_path(self._store, config, layer)
        if not lp.exists():
            return

        doc = yaml.safe_load(lp.read_text())
        if doc is None:
            return

        for key in keys:
            delete_path(doc, key)

        lp.write_text(yaml.dump(doc, default_flow_style=False))

        resolve_active(self._store, config)

        if not no_bump:
            bump_version(self._store)

    def bump(self) -> int:
        return bump_version(self._store)
