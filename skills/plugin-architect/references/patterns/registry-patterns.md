# Registry Patterns

How plugins are discovered, loaded, and managed. The registry is the backbone of any plugin system — it answers "what plugins exist and how do I activate them?"

## Approach 1: Manifest-Driven

Each plugin ships a manifest file (JSON, YAML, TOML) declaring its metadata, entry points, dependencies, and capabilities.

### When to Use
- Marketplaces and curated ecosystems
- When plugins are distributed as packages (npm, PyPI, crates.io)
- When you need rich metadata (descriptions, icons, categories, permissions)

### Minimal Manifest Schema

```json
{
  "$schema": "plugin-manifest-v1",
  "name": "my-plugin",
  "version": "1.0.0",
  "displayName": "My Plugin",
  "description": "Does something useful",
  "main": "./dist/index.js",
  "extensionPoints": {
    "hooks": ["beforeSave", "afterRender"],
    "slots": ["sidebar"],
    "services": []
  },
  "capabilities": {
    "required": ["read:documents"],
    "optional": ["write:settings"]
  },
  "dependencies": {
    "host": ">=2.0.0",
    "plugins": {
      "base-theme": "^1.0.0"
    }
  },
  "lifecycle": {
    "activationEvents": ["onStartup"],
    "deactivationPolicy": "graceful"
  }
}
```

### Discovery Flow

```
1. Scan known directories for manifest files
2. Parse and validate each manifest
3. Build dependency graph
4. Check version constraints
5. Present available plugins to activation system
```

### Trade-offs
- (+) Rich metadata enables marketplace UIs, search, categorization
- (+) Validation catches errors before loading code
- (-) Manifest must be kept in sync with actual code
- (-) More ceremony for simple plugins

---

## Approach 2: Convention-Based

Plugins are discovered by directory structure and naming conventions. No explicit manifest — metadata is inferred.

### When to Use
- Internal/enterprise plugins where trust is high
- Rapid development where ceremony is unwanted
- Simple systems with few extension points

### Convention Example

```
plugins/
├── my-plugin/
│   ├── index.ts          # Entry point (convention: must export activate/deactivate)
│   └── package.json      # Optional — used for version, not discovery
├── another-plugin/
│   └── index.ts
```

### Discovery Flow

```
1. Scan plugins/ directory for subdirectories
2. Check each for index.{ts,js,py} entry point
3. Dynamically import entry point
4. Call exported activate() function
```

### Trade-offs
- (+) Zero ceremony — drop a folder, it's a plugin
- (+) Fast iteration during development
- (-) No metadata for marketplace/admin UIs
- (-) No dependency declaration — load order is implicit
- (-) No capability declaration — all plugins get full access

---

## Approach 3: Hybrid

Manifest for metadata and policies; convention for structure. Most production systems land here.

### When to Use
- When you need both discoverability and low ceremony
- When starting convention-based and adding structure over time

### Example

```
plugins/my-plugin/
├── plugin.yaml            # Manifest: metadata, deps, capabilities
├── src/
│   └── index.ts           # Entry point (convention: always src/index.ts)
└── README.md              # Convention: always present
```

The manifest declares what the plugin is; the convention dictates where files go.

---

## Approach 4: Remote Registry

A central server that hosts plugin metadata, artifacts, and trust information. Plugins are downloaded on demand.

### When to Use
- Public ecosystems (VS Code marketplace, npm, WordPress plugin directory)
- When plugins must be signed and verified
- When you need version history, download counts, reviews

### Components

| Component | Purpose |
|-----------|---------|
| **Registry API** | Search, list, resolve versions, download |
| **Artifact store** | Host plugin packages (tarballs, ZIPs) |
| **Trust layer** | Signing, verification, publisher identity |
| **Metadata index** | Search index for names, descriptions, categories |
| **Version solver** | Resolve dependency graphs across remote packages |

### API Surface (Minimal)

```
GET  /plugins                    # List/search plugins
GET  /plugins/{name}             # Plugin metadata + versions
GET  /plugins/{name}/{version}   # Specific version metadata
GET  /plugins/{name}/{version}/download  # Download artifact
POST /plugins                    # Publish (authenticated)
```

---

## Dependency Resolution

All approaches (except simple convention-based) need dependency resolution.

### Algorithm

```
Input: Set of plugin manifests with dependency declarations
Output: Ordered activation list, or error with conflict details

1. Build directed graph: plugin → depends-on → plugin
2. Detect cycles → error with cycle path
3. Check version constraints → error with conflicting constraints
4. Topological sort → activation order
5. Mark optional dependencies → warn if missing, don't block
```

### Version Constraint Syntax

| Constraint | Meaning |
|-----------|---------|
| `^1.2.3` | Compatible with 1.x.x (>=1.2.3, <2.0.0) |
| `~1.2.3` | Patch-level changes (>=1.2.3, <1.3.0) |
| `>=2.0.0` | Minimum version |
| `>=1.0.0 <3.0.0` | Range |
| `*` | Any version |

### Conflict Resolution Strategies

| Strategy | Behavior |
|----------|----------|
| **Fail fast** | Error on any conflict — user must resolve manually |
| **Newest wins** | Pick the highest version satisfying all constraints |
| **Duplicate** | Allow multiple versions (like npm node_modules) |
| **Override** | User-provided resolution map takes precedence |

---

## Storage Patterns

Where does the registry persist its state?

### Local File System

```
~/.app/plugins/
├── registry.json           # Installed plugin index
├── my-plugin/
│   ├── plugin.yaml
│   └── dist/
└── another-plugin/
    ├── plugin.yaml
    └── dist/
```

### Database

```sql
CREATE TABLE plugins (
  name TEXT PRIMARY KEY,
  version TEXT NOT NULL,
  manifest JSONB NOT NULL,
  state TEXT NOT NULL DEFAULT 'installed',  -- installed, activated, deactivated, errored
  installed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  config JSONB DEFAULT '{}'
);

CREATE TABLE plugin_dependencies (
  plugin_name TEXT REFERENCES plugins(name),
  depends_on TEXT REFERENCES plugins(name),
  version_constraint TEXT NOT NULL,
  optional BOOLEAN DEFAULT false,
  PRIMARY KEY (plugin_name, depends_on)
);
```

### Hybrid

Registry metadata in a database (fast queries), plugin artifacts on filesystem (no BLOBs in DB).
