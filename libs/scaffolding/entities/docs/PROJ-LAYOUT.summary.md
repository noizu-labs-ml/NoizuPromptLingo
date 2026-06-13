# Project Layout Summary

```
entities/
├── lib/
│   ├── noizu_labs_entities/
│   │   ├── behaviours/         # ACL, JSON, EntityRepo, UID behaviours
│   │   ├── entity/             # Fields, identifiers, macros, meta, store adapters
│   │   ├── error/              # Shared errors
│   │   ├── repo/               # Repo macros and meta
│   │   ├── entity.ex
│   │   └── repo.ex
│   ├── mix/tasks/              # Mix code generator
│   ├── helpers.ex
│   └── noizu_labs_entities.ex
├── config/                     # Mix configs (base, dev, test, credo)
├── test/                       # Tests, support fixtures, test helpers
├── docs/                       # Project docs, arch decisions, layout
│   ├── arch/                   # Entity DSL, JSON/ACL, persistence design
│   └── layout/                 # Detailed directory breakdowns
├── priv/plts/                  # Dialyzer caches
├── .tool-versions
├── mix.exs
└── README.md
```
