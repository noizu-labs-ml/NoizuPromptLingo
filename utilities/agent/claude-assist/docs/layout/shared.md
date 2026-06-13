# packages/shared — Shared Types and Parsers

Common type definitions, JSONL parsers, and utilities shared across api, cli, and web packages.

```
shared/
├── src/
│   ├── parsers/                # Conversation file parsers
│   │   └── index.ts            #   JSONL parsing logic
│   ├── types/                  # TypeScript type definitions
│   │   └── index.ts            #   Conversation, message, search result types
│   ├── api-launcher.ts         # API server auto-launch helper
│   ├── __tests__/              # Unit tests
│   └── index.ts                # Package entry point (re-exports)
├── package.json
└── tsconfig.json
```
