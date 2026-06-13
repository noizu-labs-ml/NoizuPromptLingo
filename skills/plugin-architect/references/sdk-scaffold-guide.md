# SDK Scaffold Guide

Building the developer experience layer — the tools, templates, and documentation that plugin authors use to create, test, and ship plugins.

## SDK Components

| Component | Purpose | Priority |
|-----------|---------|----------|
| **Project template** | Scaffold a new plugin project | Critical |
| **Type stubs** | IDE completions for all extension points | Critical |
| **Test harness** | Run plugins against mock host | High |
| **Example plugins** | Reference implementations | High |
| **CLI tool** | Create, validate, package, publish | High |
| **Dev server** | Hot-reload during development | Medium |
| **Linter/validator** | Static checks for common mistakes | Medium |
| **Documentation** | Getting started, API ref, patterns | High |

## Project Template

The scaffold command generates a ready-to-develop plugin project.

### Template Structure

```
my-plugin/
├── plugin.yaml              # Manifest
├── src/
│   └── index.ts             # Entry point with typed exports
├── test/
│   ├── plugin.test.ts       # Plugin-specific tests
│   └── harness.ts           # Test harness configuration
├── package.json             # Dependencies (includes SDK as dev dep)
├── tsconfig.json            # TypeScript config
├── README.md                # Plugin documentation template
└── .gitignore
```

### Entry Point Template

```typescript
import type { PluginContext, PluginExports } from '@host/plugin-sdk';

export function activate(context: PluginContext): PluginExports {
  // Register hooks
  context.hooks.register('beforeSave', async (data) => {
    // Transform data
    return data;
  });

  // Register slots (UI extensions)
  context.slots.register('sidebar', {
    render: () => '<div>My Plugin Widget</div>',
  });

  // Return cleanup/API
  return {
    deactivate() {
      // Cleanup resources
    },
  };
}
```

### Manifest Template

```yaml
name: "{{pluginName}}"
version: "0.1.0"
displayName: "{{displayName}}"
description: "{{description}}"
main: "./dist/index.js"
types: "./dist/index.d.ts"

extensionPoints:
  hooks: []
  slots: []
  services: []

capabilities:
  required: []
  optional: []

dependencies:
  host: ">=1.0.0"

lifecycle:
  activationEvents:
    - onStartup
```

## Type Stubs

Export comprehensive type definitions for every extension point.

### Type Package Structure

```
@host/plugin-sdk/
├── index.d.ts               # Main exports
├── hooks.d.ts               # Hook type definitions
├── events.d.ts              # Event type definitions
├── slots.d.ts               # Slot/UI type definitions
├── services.d.ts            # Service provider interfaces
├── context.d.ts             # PluginContext type
└── capabilities.d.ts        # Capability type definitions
```

### Context Type

```typescript
export interface PluginContext {
  /** Plugin identity */
  readonly pluginId: string;
  readonly pluginVersion: string;

  /** Hook registration */
  readonly hooks: HookRegistry;

  /** Event system */
  readonly events: EventBus;

  /** UI slot registration */
  readonly slots: SlotRegistry;

  /** Service provider registration */
  readonly services: ServiceRegistry;

  /** Plugin-scoped storage */
  readonly storage: PluginStorage;

  /** Plugin-scoped logging */
  readonly logger: Logger;

  /** Host capability detection */
  supports(capability: string): boolean;

  /** Plugin configuration (from manifest + user settings) */
  readonly config: Readonly<Record<string, unknown>>;
}
```

## Test Harness

Let plugin authors test without running the full host application.

### Harness API

```typescript
import { createTestHarness } from '@host/plugin-test-harness';

const harness = createTestHarness({
  // Provide mock data for the host context
  mockData: {
    documents: [{ id: '1', title: 'Test Doc', content: 'Hello' }],
    users: [{ id: 'u1', name: 'Test User' }],
  },
  // Grant capabilities the plugin needs
  capabilities: ['read:documents', 'write:sidebar-content'],
  // Provide plugin configuration
  config: { apiKey: 'test-key' },
});

// Load and activate the plugin
const plugin = await harness.loadPlugin('./src/index.ts');

// Invoke hooks and inspect results
const result = await harness.invokeHook('beforeSave', testDocument);
expect(result.metadata.processed).toBe(true);

// Check registered slots
const sidebar = harness.getSlot('sidebar');
expect(sidebar).toBeDefined();

// Check events emitted
const events = harness.getEmittedEvents('my-plugin:processed');
expect(events).toHaveLength(1);

// Cleanup
await harness.deactivate();
```

### What the Harness Mocks

| Host Component | Mock Behavior |
|---------------|---------------|
| **Hook registry** | Records registrations, allows manual invocation |
| **Event bus** | Records emissions, allows manual dispatch |
| **Slot registry** | Records registrations, renders to string |
| **Service registry** | Records registrations, provides test implementations |
| **Storage** | In-memory key-value store |
| **Logger** | Captures log output for assertions |
| **Capabilities** | Configurable grant/deny per test |

## CLI Tool

```bash
# Scaffold a new plugin
host-plugin create my-plugin

# Validate manifest
host-plugin validate

# Run tests with harness
host-plugin test

# Build for distribution
host-plugin build

# Package for publishing
host-plugin pack

# Publish to registry
host-plugin publish

# Run in dev mode with hot reload
host-plugin dev
```

## Example Plugins

Ship 2-3 example plugins covering the most common patterns:

### Example 1: Simple Hook Plugin

```
examples/word-counter/
├── plugin.yaml
├── src/index.ts          # Registers a single hook
└── test/plugin.test.ts
```

### Example 2: UI Extension Plugin

```
examples/sidebar-widget/
├── plugin.yaml
├── src/
│   ├── index.ts          # Registers sidebar slot
│   └── widget.tsx        # React component
└── test/plugin.test.ts
```

### Example 3: Service Provider Plugin

```
examples/s3-storage/
├── plugin.yaml
├── src/
│   ├── index.ts          # Registers storage service
│   └── s3-provider.ts    # S3 implementation
└── test/
    ├── plugin.test.ts
    └── s3-mock.ts
```

## Documentation Structure

```
docs/
├── getting-started.md        # 5-minute quickstart
├── architecture.md           # How the plugin system works
├── extension-points/         # One file per extension point
│   ├── hooks.md
│   ├── events.md
│   ├── slots.md
│   └── services.md
├── api-reference/            # Generated from type stubs
│   ├── context.md
│   ├── hooks.md
│   └── ...
├── guides/
│   ├── testing.md
│   ├── publishing.md
│   ├── migration-v1-to-v2.md
│   └── best-practices.md
└── changelog.md
```

### Getting Started Template

```markdown
# Getting Started

## Prerequisites
- Node.js >= 18
- Host Application >= 2.0

## Create Your First Plugin

\`\`\`bash
npx @host/plugin-cli create my-first-plugin
cd my-first-plugin
npm install
\`\`\`

## Develop

\`\`\`bash
npm run dev    # Start with hot reload
\`\`\`

## Test

\`\`\`bash
npm test       # Run against test harness
\`\`\`

## Publish

\`\`\`bash
npm run build
npx @host/plugin-cli publish
\`\`\`
```
