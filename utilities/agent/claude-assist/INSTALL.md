# Installation & Running

## Prerequisites

- **Node.js** >= 18
- **pnpm** >= 8 — install via `npm install -g pnpm` or `corepack enable`

## Install

```bash
cd projects/claude-assist
pnpm install
```

This installs all workspace dependencies across the four packages (`api`, `cli`, `web`, `shared`).

## Development

### Run everything

Open separate terminals (or use a multiplexer):

```bash
# Terminal 1 — API server (Hono on tsx, auto-reloads)
pnpm dev:api

# Terminal 2 — Web UI (Vite, hot reload)
pnpm dev:web

# Terminal 3 — CLI (Ink, auto-reloads)
pnpm dev:cli
```

### Run a single package

```bash
pnpm --filter @claude-assist/api dev
pnpm --filter @claude-assist/web dev
pnpm --filter @claude-assist/cli dev
```

## Build

```bash
pnpm build          # Build all packages
```

Or individually:

```bash
pnpm --filter @claude-assist/api build
pnpm --filter @claude-assist/web build
pnpm --filter @claude-assist/cli build
```

## Test

```bash
pnpm test           # Run tests across all packages
```

Or individually:

```bash
pnpm --filter @claude-assist/api test
pnpm --filter @claude-assist/web test
pnpm --filter @claude-assist/cli test
```

The web package also supports watch mode:

```bash
pnpm --filter @claude-assist/web test:watch
```

## Type Checking

```bash
pnpm typecheck      # Type-check all packages (tsc --noEmit)
```

## Clean

```bash
pnpm clean          # Remove dist/ directories from all packages
```

## Packages

| Package | Path | Description |
|---------|------|-------------|
| `@claude-assist/api` | `packages/api/` | TypeScript API server (Hono + tsx) |
| `@claude-assist/cli` | `packages/cli/` | Interactive CLI (Ink — React for terminals) |
| `@claude-assist/web` | `packages/web/` | React frontend (Vite + Tailwind) |
| `@claude-assist/shared` | `packages/shared/` | Shared types and utilities |

## CLI Usage

After building, run the CLI directly:

```bash
npx tsx packages/cli/bin.ts
```

Or link it locally:

```bash
pnpm --filter @claude-assist/cli link --global
claude-assist
```
