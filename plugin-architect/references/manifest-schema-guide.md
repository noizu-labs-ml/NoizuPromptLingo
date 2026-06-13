# Manifest Schema Guide

Designing the plugin manifest — the declarative file that tells the host application everything it needs to know about a plugin before loading its code.

## Purpose of the Manifest

The manifest serves four audiences:

| Audience | Uses the manifest to... |
|----------|------------------------|
| **Host runtime** | Discover, validate, load, and activate the plugin |
| **Registry/marketplace** | Index, search, display, and distribute the plugin |
| **Plugin author** | Declare capabilities, dependencies, and entry points |
| **Admin/user** | Understand what the plugin does before installing it |

## Minimal Schema

Every plugin manifest needs at least these fields:

```yaml
# Required
name: my-plugin                    # Unique identifier (kebab-case)
version: 1.0.0                     # Semver
main: ./dist/index.js              # Entry point relative to plugin root

# Strongly recommended
displayName: My Plugin             # Human-readable name
description: Does something useful # One-line description
```

## Full Schema Template

```yaml
# === Identity ===
name: my-plugin
version: 1.0.0
displayName: My Plugin
description: A short description of what this plugin does
author:
  name: Author Name
  email: author@example.com
  url: https://example.com
license: MIT
repository: https://github.com/org/plugin
keywords: [utility, integration]
categories: [productivity, developer-tools]

# === Entry Points ===
main: ./dist/index.js              # Primary entry (CommonJS or ESM)
types: ./dist/index.d.ts           # TypeScript declarations
browser: ./dist/browser.js         # Browser-specific entry (if applicable)

# === Extension Points ===
extensionPoints:
  hooks:
    - name: beforeSave
      description: Called before a document is saved
    - name: afterRender
      description: Called after a page renders
  slots:
    - name: sidebar
      description: Adds a widget to the sidebar
  services:
    - name: storage
      interface: StorageProvider
      description: Custom storage backend
  events:
    subscriptions:
      - document:saved
      - user:login
    publications:
      - my-plugin:custom-event

# === Capabilities ===
capabilities:
  required:
    - read:documents
    - write:sidebar-content
  optional:
    - read:analytics-data
    - network:outbound

# === Dependencies ===
dependencies:
  host: ">=2.0.0"                  # Host API version constraint
  plugins:
    base-theme: "^1.0.0"           # Required plugin dependencies
  optionalPlugins:
    analytics-core: "^2.0.0"       # Optional — enhanced if present

# === Lifecycle ===
lifecycle:
  activationEvents:
    - onStartup                    # Activate immediately
    - onCommand:myPlugin.run       # Activate on command
    - onFileOpen:*.md              # Activate on file type
  deactivation:
    policy: graceful               # graceful | immediate
    timeout: 5000                  # ms to wait for cleanup
  healthCheck:
    interval: 30000                # ms between health pings
    timeout: 5000                  # ms before marking unhealthy

# === Configuration ===
configuration:
  title: My Plugin Settings
  properties:
    my-plugin.enabled:
      type: boolean
      default: true
      description: Enable or disable the plugin
    my-plugin.apiKey:
      type: string
      secret: true
      description: API key for external service

# === Metadata ===
engines:
  node: ">=18.0.0"                # Runtime requirements
  host: ">=2.0.0 <4.0.0"
icon: ./assets/icon.png
gallery:
  - ./assets/screenshot-1.png
  - ./assets/screenshot-2.png
```

## Format Choice

| Format | Pros | Cons | Best For |
|--------|------|------|----------|
| **JSON** | Universal parsing, schema validation (JSON Schema) | Verbose, no comments | npm-style ecosystems |
| **YAML** | Readable, comments, multi-line strings | Whitespace-sensitive, parsing edge cases | DevOps-adjacent tools |
| **TOML** | Readable, typed values, sections | Less universal, learning curve | Rust/Go ecosystems |
| **package.json fields** | No extra file, familiar to JS devs | Mixes plugin metadata with package metadata | JS/TS plugin systems |

**Recommendation:** Use the format your target developers already use. JS ecosystem → JSON or package.json fields. DevOps → YAML. Rust → TOML.

## Validation

Validate manifests at two points:

### 1. At Discovery (before loading code)

```typescript
function validateManifest(raw: unknown): PluginManifest {
  // Schema validation (JSON Schema, Zod, etc.)
  const parsed = manifestSchema.parse(raw);

  // Semantic validation
  if (parsed.capabilities.required.length === 0 && parsed.extensionPoints.hooks.length > 0) {
    warnings.push(`Plugin "${parsed.name}" registers hooks but requests no capabilities`);
  }

  // Version constraint checking
  if (!semver.validRange(parsed.dependencies.host)) {
    throw new InvalidManifestError(`Invalid host version constraint: ${parsed.dependencies.host}`);
  }

  return parsed;
}
```

### 2. At Activation (after loading code)

Verify that the loaded code actually exports what the manifest claims:
- Declared hooks have matching exported functions
- Declared services implement the expected interface
- Declared slots export valid components

## Evolution

The manifest schema itself needs versioning:

```yaml
# Manifest declares its own schema version
$schema: plugin-manifest-v2

# Host checks
if (manifest.$schema === 'plugin-manifest-v1') {
  manifest = migrateV1toV2(manifest);
}
```

Add new optional fields freely. Required field additions or field removals are breaking changes to the manifest schema — bump the schema version.
