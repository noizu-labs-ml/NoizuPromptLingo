# Project Layout Summary — doc-pointers

Elixir MCP/library for UUIDv5 → 4-glyph doc-pointer tokens
(`Portfolio/Apps/Developer/doc-pointers`).

```
doc-pointers/
├── mix.exs · mix.lock · README.md
├── lib/
│   ├── doc_pointers.ex                 # public generate API
│   ├── doc_pointers/
│   │   ├── application.ex              # OTP + Store root
│   │   ├── uuid5.ex · hieroglyph.ex · pointer.ex
│   │   ├── store.ex                    # YAML GenServer + submodule split
│   │   ├── mcp.ex                      # MCP server registry
│   │   └── mcp/                        # writes gate, runtime, tools
│   └── mix/tasks/                      # mcp.stdio (preferred), mcp.server (loopback)
├── test/                               # uuid5, hieroglyph, store, generate, MCP, golden
└── docs/
    ├── PROJ-LAYOUT.md · PROJ-LAYOUT.summary.md
```

Runtime data (at target root): `.meta/pointers.yaml` (+ optional legacy
`docs/doc-pointer-db.json` import).

See [PROJ-LAYOUT.md](PROJ-LAYOUT.md) for annotated tree and setup.
