# direnv-config SDK Libraries

Client libraries for [direnv-config (`dc`)](../README.md) in five languages. Each SDK reads and writes YAML-backed configuration from `dc` stores, providing idiomatic access to config values from application code.

## SDKs

| Language | Package | Registry | Install |
|----------|---------|----------|---------|
| Rust | `direnv-config` | [crates.io](https://crates.io/crates/direnv-config) | `cargo add direnv-config` |
| TypeScript | `@noizu/direnv-config` | [npm](https://www.npmjs.com/package/@noizu/direnv-config) | `npm install @noizu/direnv-config` |
| Python | `noizu-direnv-config` | [PyPI](https://pypi.org/project/noizu-direnv-config) | `pip install noizu-direnv-config` |
| Elixir | `:direnv_config` | [Hex](https://hex.pm/packages/direnv_config) | `{:direnv_config, "~> 0.1.0"}` in `mix.exs` |
| PHP | `noizu/direnv-config` | [Packagist](https://packagist.org/packages/noizu/direnv-config) | `composer require noizu/direnv-config` |

## Quick Start

All five SDKs share the same API surface — read and write:

### Rust

```rust
use direnv_config::DcClient;

let dc = DcClient::new(None)?;

// Read
let name = dc.get_string("cluster", "name")?;
let min = dc.get_int("cluster", "node_pool.min")?;

// Write
dc.set("cluster", "node_pool.min", "4", None, false)?;
dc.unset("cluster", &["deprecated_key"], None, false)?;
```

### TypeScript

```typescript
import { DcClient } from '@noizu/direnv-config';

const dc = new DcClient({ directory: '/path/to/project' });

// Read
const name = await dc.getString('cluster', 'name');
const hosts = await dc.get('app', 'endpoints[*].host');

// Write
await dc.set('cluster', 'node_pool.min', '4');
await dc.unset('cluster', ['deprecated_key']);
```

### Python

```python
from direnv_config import DcClient

dc = DcClient(directory='/path/to/project')

# Read
name = dc.get_string('cluster', 'name')
hosts = dc.get('app', 'endpoints[*].host')

# Write
dc.set('cluster', 'node_pool.min', '4')
dc.unset('cluster', ['deprecated_key'])
```

### Elixir

```elixir
client = DirenvConfig.Client.new(directory: "/path/to/project")

# Read
{:ok, name} = DirenvConfig.Client.get_string(client, "cluster", "name")
{:ok, hosts} = DirenvConfig.Client.get(client, "app", "endpoints[*].host")

# Write
:ok = DirenvConfig.Client.set(client, "cluster", "node_pool.min", "4")
:ok = DirenvConfig.Client.unset(client, "cluster", ["deprecated_key"])
```

### PHP

```php
use Noizu\DirenvConfig\DcClient;

$dc = new DcClient(directory: '/path/to/project');

// Read
$name = $dc->getString('cluster', 'name');
$hosts = $dc->get('app', 'endpoints[*].host');

// Write
$dc->set('cluster', 'node_pool.min', '4');
$dc->unset('cluster', ['deprecated_key']);
```

## Backends

Each SDK supports two backends:

- **Native** (default) -- reads/writes YAML files directly in the dc store. Fast, no subprocess overhead.
- **CLI** -- shells out to the `dc` binary. Supports parent-chain resolution and stays in sync with CLI behavior.

```typescript
const dc = new DcClient({ mode: 'cli', dcBinary: '/usr/local/bin/dc' });
```

## Write Operations

| Method | Description |
|--------|-------------|
| `set(config, key, value, layer?, noBump?)` | Set a value at a path expression in a layer file |
| `unset(config, keys, layer?, noBump?)` | Remove keys from a layer file |
| `bump()` | Increment the store version counter |

Writes target the `local` layer by default. The active file is automatically re-resolved after each write.

## Path Expressions

All SDKs support the same path expression syntax for both reads and writes:

| Expression | Description | Example |
|-----------|-------------|---------|
| `key` | Map key | `name` |
| `a.b.c` | Nested keys | `node_pool.min` |
| `a[0]` | Array index | `endpoints[0].host` |
| `a[-1]` | Negative index | `endpoints[-1].host` |
| `a[*].b` | Wildcard (collect, read-only) | `endpoints[*].host` |
| `a.length` | Count (read-only) | `endpoints.length` |
| `a[0][1]` | Chained brackets | `matrix[0][1]` |

## Version Watching

SDKs can poll the store's `.version` file to detect config changes (IPC):

```typescript
const watcher = dc.watch((version) => {
  console.log(`Config updated to version ${version}`);
}, 1000);

// Later: watcher.dispose();
```

## Contract Tests

The `contract-tests/` directory contains shared fixtures and `expectations.yaml` defining ~30 test cases that every SDK must pass, ensuring behavioral parity across all five implementations.

## Running Tests

```bash
# Rust
cd sdk/rust && cargo test

# TypeScript
cd sdk/typescript && npm test

# Python
cd sdk/python && pip install -e ".[dev]" && pytest

# Elixir
cd sdk/elixir && mix deps.get && mix test

# PHP
cd sdk/php && composer install && vendor/bin/phpunit
```

## Publishing

SDKs are published to their respective registries. Automated publishing is triggered by pushing an `sdk-v*` tag.

### Manual Publishing

```bash
# Rust → crates.io
cd sdk/rust && cargo publish

# TypeScript → npm
cd sdk/typescript && npm run build && npm publish --access public

# Python → PyPI
cd sdk/python && python -m build && twine upload dist/*

# Elixir → Hex.pm
cd sdk/elixir && mix hex.publish

# PHP → Packagist (auto-updates via GitHub webhook)
```

### Required Secrets (GitHub Actions)

| Secret | Registry | How to Get |
|--------|----------|-----------|
| `CARGO_REGISTRY_TOKEN` | crates.io | [API Tokens](https://crates.io/settings/tokens) |
| `NPM_TOKEN` | npm | `npm token create` or [Access Tokens](https://www.npmjs.com/settings/~/tokens) |
| `HEX_API_KEY` | Hex.pm | `mix hex.user key generate` |
| PyPI | PyPI | Uses [Trusted Publisher](https://docs.pypi.org/trusted-publishers/) (OIDC, no secret needed) |
| Packagist | Packagist | Auto-updates via [GitHub webhook](https://packagist.org/about#how-to-update-packages) |
