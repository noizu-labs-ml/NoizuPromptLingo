# Project Layout

Elixir library (`noizu_labs_entities`) providing entity definition macros, persistence protocols, and repo behaviours.

```
entities/
├── lib/
│   ├── noizu_labs_entities/        # Core library → [layout/lib.md](layout/lib.md)
│   │   ├── behaviours/             #   Behaviour definitions (ACL, JSON, Repo, UID)
│   │   ├── entity/                 #   Entity system (fields, identifiers, macros, meta, store)
│   │   ├── error/                  #   Shared error definitions
│   │   ├── repo/                   #   Repo macros and metadata
│   │   ├── entity.ex               #   Entity module entry point
│   │   └── repo.ex                 #   Repo module entry point
│   ├── mix/tasks/                  #   Mix task: nz.gen.entity
│   ├── helpers.ex                  #   Shared helper functions
│   └── noizu_labs_entities.ex      #   Top-level application module
├── config/                         # Mix environment configs
│   ├── .credo.exs                  #   Credo static analysis config
│   ├── config.exs                  #   Base config
│   ├── dev.exs                     #   Dev overrides
│   └── test.exs                    #   Test overrides
├── test/                           # Test suites
│   ├── support/                    #   Test fixtures and entity stubs
│   │   ├── entities/               #   Sample entity definitions
│   │   ├── database.ex             #   Test database setup
│   │   ├── dummy.ex                #   Dummy modules for testing
│   │   ├── noizu_test.entity_repo.ex #  Test entity repo
│   │   └── uid_provider.ex         #   Test UID provider
│   ├── amnesia_entities_test.exs
│   ├── field_protocol_test.exs
│   ├── json_encoder_test.exs
│   ├── noizu_labs_entities_test.exs
│   └── test_helper.exs             #   ExUnit bootstrap
├── docs/                           # Project documentation
│   ├── arch/                       #   Architecture decision records
│   │   ├── entity-dsl.md           #   Entity DSL design
│   │   ├── json-acl.md             #   JSON/ACL encoding design
│   │   └── persistence.md          #   Persistence layer design
│   ├── layout/                     #   Detailed directory breakdowns
│   │   └── lib.md
│   ├── PROJ-ARCH.md                #   Architecture overview
│   ├── PROJ-ARCH.summary.md        #   Architecture summary
│   ├── PROJ-LAYOUT.md              #   This file
│   └── PROJ-LAYOUT.summary.md      #   Layout summary
├── priv/plts/                      # Dialyzer PLT caches
├── .tool-versions                  # asdf versions (Elixir, Erlang, Node, Java, Yarn)
├── .formatter.exs                  # Elixir code formatter config
├── .dialyzer_ignore.exs            # Dialyzer warning suppressions
├── mix.exs                         # Project definition and dependencies
├── mix.lock                        # Locked dependency versions
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
└── README.md                       # Start here
```

## Key Files Requiring Setup

| File | Action |
|------|--------|
| `.tool-versions` | Install runtimes via `asdf install` |
