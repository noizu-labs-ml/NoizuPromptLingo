# Architecture Summary

**noizu_labs_entities** — Elixir library that adds compile-time metadata (persistence, JSON, ACL, entity referencing) to structs via a DSL.

## Core Components

- **Noizu.Entities** — Top-level `use` macro wiring Entity + Repo
- **Entity Macros** — DSL (`def_entity`, `id`, `field`, `transient`, `pii`) that registers metadata as module attributes, emits struct + `__noizu_meta__/0`
- **Entity Meta** — Runtime access to compiled metadata (fields, json, acl, persistence, sref)
- **Repo Macros** — DSL (`def_repo`) generating CRUD delegate struct with overridable before/do/after hooks
- **Repo Meta** — CRUD pipeline implementation iterating persistence layers
- **Store Adapters** — Protocol-based persistence (Ecto, Mnesia, Amnesia, Redis, Dummy) via EntityProtocol + FieldProtocol
- **Typed Fields** — TimeStamp, Reference, Path, DerivedField, UUIDReference, Extended.UUIDReference with store/lifecycle callbacks
- **Json Protocol** — ACL-aware JSON serialization with named format templates
- **ACL Protocol** — Field-level access restriction based on transient/pii/custom rules
- **Noizu.UUID** — UUID generation helper wrapping ShortUUID/elixir_uuid
- **EntityRepoBehaviour** — Application-level repo dispatching by sref string

## Key Design Decisions

- All entity config resolved at compile time into `__noizu_meta__/0`
- Protocol-based store adapters — extensible without touching core
- ACL restriction integrated into JSON serialization pipeline
- ERP (Entity Reference Protocol) with identifier-type-specific handlers
- Three-phase CRUD hooks (`before/do/after`) — all `defoverridable`

## Stack

Elixir ~> 1.14 (developed on 1.19 / OTP 28), Ecto (primary persistence), Amnesia (optional via nuamnesia), Jason, ShortUUID, inflex28, Credo, Dialyxir, noizu_labs_core ~> 0.1.8
