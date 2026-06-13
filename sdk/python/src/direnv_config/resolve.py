from __future__ import annotations

import os
from pathlib import Path
from typing import Any

import yaml

from direnv_config.merge import deep_merge_multi


def resolve_active(store_path: Path, name: str) -> Any:
    """Merge config layers and write the result to .active.

    Layer merge order: base.yaml -> {DC_ENV}.yaml -> local.yaml -> secrets.yaml
    """
    config_dir = store_path / name
    config_dir.mkdir(parents=True, exist_ok=True)

    dc_env = os.environ.get("DC_ENV", "dev")

    layer_names = ["base", dc_env, "local", "secrets"]
    layers: list[Any] = []

    for layer_name in layer_names:
        layer_file = config_dir / f"{layer_name}.yaml"
        if layer_file.exists():
            contents = layer_file.read_text()
            data = yaml.safe_load(contents)
            if data is not None:
                layers.append(data)

    merged = deep_merge_multi(layers)

    active_file = config_dir / ".active"
    if merged is not None:
        active_file.write_text(yaml.dump(merged, default_flow_style=False))
    else:
        active_file.write_text("")

    return merged
