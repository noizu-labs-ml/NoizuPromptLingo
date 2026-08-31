# packages/cli — Interactive TUI Client

Ink-based terminal UI for browsing, searching, and editing conversations from the command line. Launches full interactive mode by default; also exposes one-shot subcommands.

```
cli/
├── src/
│   ├── commands/               # One-shot CLI subcommands
│   │   ├── index.tsx           #   Rebuild search index / help
│   │   ├── list.tsx            #   List conversations
│   │   ├── recent.ts           #   Recent conversations (time window; no API required)
│   │   ├── search.tsx          #   Search conversations
│   │   └── show.tsx            #   Display a single conversation
│   ├── interactive/            # Full-screen interactive TUI application
│   │   ├── components/         #   Reusable widgets (Layout, Sidebar, dialogs, lists, pagination)
│   │   ├── context/            #   React contexts (Focus, Harness, Router)
│   │   ├── hooks/              #   useApi, useScroll, useTerminalSize, useDebouncedValue
│   │   ├── pages/              #   Route pages (Explore, Thread, Datasets, Projects, Prompts,
│   │   │                       #     Tags, Edit, Convert, ContinueSession, SafetyWatch, Settings, StyleGuide)
│   │   ├── services/           #   sessionWorkflow — continue-session orchestration
│   │   └── InteractiveApp.tsx  #   Interactive mode root
│   ├── __tests__/              # Unit tests
│   ├── app.tsx                 # Root Ink application component
│   └── interface-selection.ts  # Chooses interactive vs subcommand mode
├── bin.ts                      # CLI entry point (hashbang)
├── package.json
└── tsconfig.json
```
