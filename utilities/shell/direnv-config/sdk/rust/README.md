# direnv-config

[![Crates.io](https://img.shields.io/crates/v/direnv-config.svg)](https://crates.io/crates/direnv-config)
[![MIT licensed](https://img.shields.io/crates/l/direnv-config.svg)](./LICENSE)
[![docs.rs](https://docs.rs/direnv-config/badge.svg)](https://docs.rs/direnv-config)

Rust SDK for [direnv-config (dc)](https://github.com/noizu/direnv-config) — read and write YAML-backed directory configuration from Rust.

## Install

```sh
cargo add direnv-config
```

## Quick start

```rust
use direnv_config::{DcClient, DcClientOptions, DcMode};

// Auto-discover the dc store from the current directory
let client = DcClient::new(None)?;

// Read values
let host = client.get_string("myapp", "db.host")?;
let port = client.get_int("myapp", "db.port")?;
let debug = client.get_bool("myapp", "debug")?;

// Write a value to the local layer
client.set("myapp", "db.port", "5433", None, false)?;

// Write to a named layer
client.set("myapp", "cache.ttl", "300", Some("staging"), false)?;

// Remove keys
client.unset("myapp", &["old.key"], None, false)?;

// Check for changes (useful for watch loops)
let v = client.version();
// ... later ...
if client.has_changed(v) {
    println!("config was updated");
}
```

## Backends

| Mode | Description |
|------|-------------|
| `DcMode::Native` (default) | Reads/writes YAML files directly on the filesystem |
| `DcMode::Cli` | Shells out to the `dc` binary for all operations |

```rust
use direnv_config::{DcClient, DcClientOptions, DcMode};

let client = DcClient::new(Some(DcClientOptions {
    mode: DcMode::Cli,
    dc_binary: "dc".to_string(),
    ..Default::default()
}))?;
```

## Full documentation

See the [direnv-config repository](https://github.com/noizu/direnv-config) for complete documentation on the dc system, layer semantics, and CLI usage.

## License

MIT — see [LICENSE](./LICENSE).
