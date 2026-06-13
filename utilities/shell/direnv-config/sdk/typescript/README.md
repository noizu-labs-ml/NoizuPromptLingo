# @noizu/direnv-config

TypeScript/Node.js SDK for [direnv-config](https://github.com/noizu/direnv-config) (dc) -- read and write YAML-backed directory configuration from Node.js applications.

## Install

```bash
npm install @noizu/direnv-config
```

## Quick Start

```typescript
import { DcClient } from '@noizu/direnv-config';

const dc = new DcClient();

// Read a value
const dbHost = await dc.getString('database', 'host');
const dbPort = await dc.getInt('database', 'port');
const debug = await dc.getBool('app', 'debug');

// Read an entire config
const config = await dc.get('database');

// Write a value
await dc.set('database', 'host', 'localhost');

// Delete a value
await dc.unset('database', ['host']);

// List all configs in the current store
const configs = await dc.listConfigs();

// Watch for changes
const watcher = dc.watch((version) => {
  console.log(`Config changed, new version: ${version}`);
});

// Stop watching
watcher.dispose();
```

### Backends

The SDK supports two backends:

- **`native`** (default) -- reads and writes YAML files directly via Node.js
- **`cli`** -- shells out to the `dc` binary

```typescript
// Use the CLI backend
const dc = new DcClient({ mode: 'cli' });

// Point to a specific store directory
const dc = new DcClient({ stateDir: '/path/to/.dc-state' });
```

## API

| Method | Returns | Description |
|--------|---------|-------------|
| `get(config, path?)` | `unknown` | Read a value (or entire config if no path) |
| `getOrThrow(config, path?)` | `unknown` | Read a value, throw if missing |
| `getString(config, path)` | `string \| null` | Read as string |
| `getInt(config, path)` | `number \| null` | Read as integer |
| `getBool(config, path)` | `boolean \| null` | Read as boolean |
| `set(config, key, value, opts?)` | `void` | Write a value |
| `unset(config, keys, opts?)` | `void` | Delete key(s) |
| `listConfigs()` | `string[]` | List available configs |
| `version()` | `number` | Current store version |
| `hasChanged(since)` | `boolean` | Check if version changed |
| `watch(callback, intervalMs?)` | `{ dispose() }` | Watch for changes |
| `bump()` | `number` | Manually bump the version |

## Full Documentation

See the [direnv-config repository](https://github.com/noizu/direnv-config) for full documentation on the `dc` tool, YAML store format, and layer system.

## License

MIT
