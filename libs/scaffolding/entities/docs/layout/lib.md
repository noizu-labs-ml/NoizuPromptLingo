# lib/noizu_labs_entities/ — Detailed Layout

```
noizu_labs_entities/
├── behaviours/
│   ├── acl/
│   │   ├── exception.ex            # ACL exception definition
│   │   └── protocol.ex             # ACL protocol for access control checks
│   ├── entity_repo/
│   │   └── behaviour.ex            # EntityRepo behaviour (CRUD contract)
│   ├── json/
│   │   ├── exception.ex            # JSON encoding exception
│   │   └── protocol.ex             # JSON protocol for entity serialization
│   └── uid.ex                      # UID provider behaviour
│
├── entity/
│   ├── fields/
│   │   ├── behaviour.ex            # Field behaviour contract
│   │   ├── derived_field.ex        # Computed/derived field support
│   │   ├── extended.uuid_reference.ex  # Extended UUID reference field
│   │   ├── path.ex                 # Path-based field access
│   │   ├── reference_behavior.ex   # Reference field behaviour
│   │   ├── reference.ex            # Entity reference field
│   │   ├── time_stamp.ex           # Timestamp field helpers
│   │   └── uuid_reference.ex       # UUID reference field
│   ├── identifiers/
│   │   ├── atom_identifier.ex      # Atom-based entity identifiers
│   │   ├── dual_ref_identifier.ex  # Dual-reference identifiers
│   │   ├── exception.ex            # Identifier exceptions
│   │   ├── integer_identifier.ex   # Integer identifiers
│   │   ├── ref_identifier.ex       # Ref-based identifiers
│   │   └── uuid_identifier.ex      # UUID identifiers
│   ├── macros/
│   │   ├── acl.ex                  # ACL DSL macros
│   │   └── json.ex                 # JSON DSL macros
│   ├── meta/
│   │   ├── acl.ex                  # ACL metadata extraction
│   │   ├── field.ex                # Field metadata extraction
│   │   ├── identifier.ex           # Identifier metadata extraction
│   │   ├── json.ex                 # JSON metadata extraction
│   │   └── persistence.ex          # Persistence metadata extraction
│   ├── store/
│   │   ├── amnesia/                # Amnesia DB store protocols
│   │   ├── dummy/                  # Dummy/test store protocols
│   │   ├── ecto/                   # Ecto store protocols + behaviour
│   │   ├── mnesia/                 # Mnesia store protocols
│   │   └── redis/                  # Redis store protocols + behaviour
│   ├── macros.ex                   # Core entity definition macros
│   └── meta.ex                     # Core entity metadata module
│
├── error/
│   └── common.ex                   # Shared error types (PendingFeature, etc.)
│
├── repo/
│   ├── macros.ex                   # Repo definition macros
│   └── meta.ex                     # Repo metadata module
│
├── entity.ex                       # Entity module — use Noizu.Entity
└── repo.ex                         # Repo module — use Noizu.Repo
```

## Store Adapters

Each store adapter under `entity/store/` follows the same pattern:

| File | Purpose |
|------|---------|
| `entity_protocol.ex` | Protocol implementation for entity-level persistence |
| `entity.field_protocol.ex` | Protocol implementation for field-level persistence |
| `behaviour.ex` | Behaviour definition (Ecto and Redis only) |
| `exception.ex` | Store-specific exceptions (Ecto only) |
