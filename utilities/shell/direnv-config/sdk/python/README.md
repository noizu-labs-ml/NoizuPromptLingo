# noizu-direnv-config

Python SDK for [direnv-config (dc)](https://github.com/noizu/direnv-config) — read and write YAML-backed directory configuration.

## Install

```bash
pip install noizu-direnv-config
```

## Quick Start

```python
from direnv_config import DcClient

# Auto-detect the nearest .dc store
dc = DcClient()

# Read a value
db_host = dc.get("database", "host")
db_port = dc.get_int("database", "port")
debug = dc.get_bool("app", "debug")

# Read an entire config namespace
database_config = dc.get("database")

# Write a value (to the local layer by default)
dc.set("app", "debug", "true")

# Write to a specific layer
dc.set("database", "host", "localhost", layer="local")

# Remove keys
dc.unset("app", ["stale_key", "old_setting"])

# List available config namespaces
configs = dc.list_configs()

# Watch for changes
watcher = dc.watch(lambda version: print(f"config changed: v{version}"))
watcher.start()
# ... later ...
watcher.stop()
```

### Backend Modes

The client supports two backends:

- **`native`** (default) — reads/writes YAML files directly; no external dependencies
- **`cli`** — shells out to the `dc` binary; useful when you need full CLI compatibility

```python
dc = DcClient(mode="cli", dc_binary="/usr/local/bin/dc")
```

## Full Documentation

See the [direnv-config repository](https://github.com/noizu/direnv-config) for full documentation, CLI usage, and configuration format.

## License

MIT — see [LICENSE](./LICENSE).
