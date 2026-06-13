# packages/cli — Interactive TUI Client

Ink-based terminal UI for browsing and searching conversations from the command line.

```
cli/
├── src/
│   ├── commands/               # CLI subcommands (Ink components)
│   │   ├── index.tsx           #   Default/help command
│   │   ├── list.tsx            #   List conversations
│   │   ├── search.tsx          #   Search conversations
│   │   └── show.tsx            #   Display a single conversation
│   ├── __tests__/              # Unit tests
│   └── app.tsx                 # Root Ink application component
├── bin.ts                      # CLI entry point (hashbang)
├── package.json
└── tsconfig.json
```
