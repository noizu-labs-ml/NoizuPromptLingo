# Noizu Frameworks Integration Checklist

Use this checklist when adding Noizu libraries to a new Elixir project.

## Foundation

- [ ] Add `noizu_labs_core` to mix.exs deps
- [ ] Verify `use Noizu.Core` imports correctly
- [ ] Test ERP: `Noizu.EntityReference.Protocol.id/1` works on your types

## Entity Layer (if using entities)

- [ ] Add `noizu_labs_entities` to mix.exs deps
- [ ] Define at least one entity with `use Noizu.Entity` + `def_entity`
- [ ] Define matching repo with `use Noizu.Repo` + `def_repo`
- [ ] Set up `@persistence` (ecto_store or dummy_store)
- [ ] Set `@vsn` and `@sref` on each entity
- [ ] Create Ecto schema and migration for persistence layer
- [ ] Verify ERP auto-implementation: `Protocol.ref(entity)` returns valid ref
- [ ] Add `jason_encoder()` if JSON serialization needed

## GenAI (if using LLM providers)

- [ ] Add `genai` (and `genai_core`) to mix.exs deps
- [ ] Configure at least one provider in config.exs (api_key)
- [ ] Verify Finch pool starts (GenAI.Application supervisor)
- [ ] Test basic thread: `Thread.new() |> with_model() |> with_message() |> run()`
- [ ] Test tool use if needed

## Local Inference (if using ExLLama)

- [ ] Add `ex_llama` to mix.exs deps
- [ ] Verify C/C++ toolchain available (elixir_make)
- [ ] Place GGUF model file in priv/ directory
- [ ] Test: `ExLLama.load_model/1` + `ExLLama.chat_completion/3`

## Weaviate (if using vector search)

- [ ] Add `noizu_weaviate` to mix.exs deps
- [ ] Configure endpoint and API key
- [ ] Define at least one class with `use Noizu.Weaviate.Class`
- [ ] Test CRUD via `Noizu.Weaviate.Api.Objects`
- [ ] Test GraphQL query via `Noizu.Weaviate.GraphQL.Get`

## Services (if using worker pools)

- [ ] Add `noizu_labs_services` to mix.exs deps
- [ ] Define pool module with `use Noizu.Service`
- [ ] Define worker module
- [ ] Add pool spec to application supervisor
- [ ] Test `s_call!` and `s_cast!`

## Utilities (as needed)

- [ ] **FragmentedKeys**: Add dep, set default cache handler, test key generation + invalidation
- [ ] **SmartToken**: Add dep, run migration, test token create + authorize flow
- [ ] **SeedHelper**: Add dep, run migration, add seeds to priv/repo/seeds.exs
- [ ] **GitHub client**: Add dep, configure api_key/owner/repo
- [ ] **SendGrid**: Add dep, configure api_key, test email send
