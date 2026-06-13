# noizu/direnv-config

PHP SDK for [direnv-config](https://github.com/noizu/direnv-config) (dc) — read and write YAML-backed directory configuration from PHP.

## Installation

```bash
composer require noizu/direnv-config
```

Requires PHP 8.1+.

## Quick Start

```php
use Noizu\DirenvConfig\DcClient;

// Create a client (uses native YAML backend by default)
$dc = new DcClient();

// Read a full config as an associative array
$config = $dc->get('my-app');

// Read a specific path within a config
$dbHost = $dc->getString('my-app', 'database.host');
$dbPort = $dc->getInt('my-app', 'database.port');
$debug  = $dc->getBool('my-app', 'debug');

// Throws DcException if the value is missing
$secret = $dc->getOrThrow('my-app', 'api.secret');

// Write a value (defaults to 'local' layer)
$dc->set('my-app', 'database.host', 'localhost');

// Write to a specific layer
$dc->set('my-app', 'database.host', 'db.prod.internal', layer: 'prod');

// Remove keys
$dc->unset('my-app', ['deprecated.key']);

// List all available configs in the current store
$configs = $dc->listConfigs();

// Version tracking for change detection
$version = $dc->version();
// ... later ...
if ($dc->hasChanged($version)) {
    // config was updated
}
```

### Backend Modes

The client supports two backends:

- **`native`** (default) — reads and merges YAML layer files directly in PHP. No external dependencies beyond `symfony/yaml`.
- **`cli`** — shells out to the `dc` binary. Useful when you need exact parity with the CLI tool.

```php
// Use the CLI backend
$dc = new DcClient(mode: 'cli');

// Point to a specific directory's store
$dc = new DcClient(directory: '/path/to/project');
```

## Full Documentation

See the [main direnv-config repository](https://github.com/noizu/direnv-config) for full documentation on the `dc` tool, YAML layer system, and configuration format.

## License

MIT - see [LICENSE](LICENSE) for details.
