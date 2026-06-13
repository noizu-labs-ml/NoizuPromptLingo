# Project Layout

```
queue-populator/
├── docs/                       # Documentation
│   ├── PROJ-LAYOUT.md          #   This file — project structure map
│   └── PROJ-LAYOUT.summary.md  #   Quick-reference tree for tools/agents
└── README.md                   # Project overview, routing logic, entry format
```

## Status

This project is **not started** — no source code exists yet. The README defines the intended design:

- **CLI channel**: `q "..."` command for routing user input to queue files
- **Routing targets**: `~/personal-development/queue/*.jsonl` files
- **Input types**: questions, reminders, ideas, study items, flashcard requests

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Design spec — channels, routing logic, entry format |
