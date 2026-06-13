# Noizu Framework Ecosystem — Compressed Reference

## Library Index

**00 — Architecture Overview** → See `kb/00-architecture.md`
**01–12 — Per-library deep dives** → `kb/01-noizu-labs-core.md` … `kb/12-sendgrid.md`
**13 — Integration patterns** → `kb/13-integration-patterns.md`

---

## 01 · noizu_labs_core `0.1.7`
Foundation for all Noizu libraries. Defines the **EntityReference Protocol (ERP)** — five callbacks every entity must implement: `id/1` (raw ID), `kind/1` (atom module key), `ref/1` (normalized `{Module, id}` tuple), `sref/1` (string ref, e.g. `"user:123"`), `entity/2` (full struct from ref + context). The **Context record** carries caller, timestamp, roles, and options; pre-built constructors: `Noizu.Context.restricted()`, `.admin()`, `.system()`, `.internal()`. Errors follow `{:error, {module, reason}}` tuples. Entry point: `use Noizu.Core` — imports ERP helpers, context constructors, and standard error types. No dependencies outside stdlib.
```elixir
use Noizu.Core
ctx = Noizu.Context.system()
ref = Noizu.EntityReference.ref(my_struct)
id  = Noizu.EntityReference.id(ref)
```

---

## 02 · noizu_labs_entities `0.3.1`
Entity/Repo macro layer built on top of `noizu_labs_core`. **`def_entity do … end`** generates a struct, ERP implementation, JSON encoder, and metadata. **`def_repo`** generates CRUD: `get/3`, `create/3`, `update/3`, `delete/3`, `list/3`. Field annotations: `@transient` (skip persistence), `@pii :sensitive` (mask in logs), `@restrict :admin` (ACL gate), `@json true|omit|as: :alias`. Persistence backend: `@persistence ecto_store(Schema, Repo)`. String ref prefix: `@sref "name"`. Schema version: `@vsn 1.0`. Built-in field types: `:uuid`, `:integer`, `:string`, `Noizu.Entity.TimeStamp`, `Noizu.Entity.UUIDReference`. Depends on `noizu_labs_core`.
```elixir
use Noizu.Entity
def_entity do
  @sref "user"
  @vsn 1.0
  @persistence ecto_store(MyApp.Schema.User, MyApp.Repo)
  field :name, :string
  @transient field :token, :string
end
use Noizu.Repo
```

---

## 03 · noizu_labs_services `0.1.2`
Distributed worker-pool framework. **`use Noizu.Service`** auto-generates a five-module hierarchy: `Pool`, `PoolSupervisor`, `WorkerSupervisor`, `Server`, `Worker`. Key call helpers: `s_call!/5` (sync, raises on error), `s_cast!/5` (async), `get_direct_link!/3` (pin to specific node), `wake!/3` (ensure worker is alive), `kill!/3` (tear down). Internal records: `link()`, `settings()`, `s()`, `call()`, `msg_envelope()`. Cluster coordination via `:syn` (process registry). Designed to pair with `noizu_labs_entities` — workers typically own entity lifecycles. Depends on `noizu_labs_entities`.
```elixir
use Noizu.Service
def handle_call({:get, ref}, _from, state), do: {:reply, state.entity, state}
```

---

## 04 · genai_core `0.3.0`
Provider-agnostic GenAI thread abstraction. **ThreadProtocol** methods: `with_model/2`, `with_tool/2`, `with_message/2-3`, `with_setting/2-3`, `with_safety_setting/2-3`, `execute/4`, `stream/3`, `run/2`. Thread types: `GenAI.Thread.Standard` (linear turn-by-turn), `GenAI.Thread.Session` (stateful, persists across calls). Core types: `GenAI.Message` (role + content), `GenAI.ChatCompletion` (response), `GenAI.Tool` (function schema), `GenAI.Model` (provider + model id), `GenAI.Setting.*` (temperature, top_p, max_tokens, etc.). **Graph execution** via `GenAI.Graph` — compose threads as DAG nodes for branching/parallel inference. Depends on `noizu_labs_core`.
```elixir
alias GenAI.Thread
thread = Thread.Standard.new()
  |> Thread.with_model(%GenAI.Model{provider: GenAI.Provider.Anthropic, model: "claude-opus-4-5"})
  |> Thread.with_message(:user, "Hello")
{:ok, completion} = Thread.run(thread, context)
```

---

## 05 · genai `0.3.0`
Provider implementations for `genai_core`. **Nine providers**: `GenAI.Provider.Anthropic`, `.OpenAI`, `.Gemini`, `.Mistral`, `.Groq`, `.XAI`, `.DeepSeek`, `.Ollama`, `.Zai`. Each implements `GenAI.InferenceProviderBehaviour` — required callbacks: `models/1` (list available models), `do_run/3` (execute thread). Provider config via `config :genai, :anthropic, api_key: "..."` (provider name as atom key). Add a new provider by implementing the behaviour and registering via config. Depends on `genai_core`.
```elixir
config :genai, :anthropic, api_key: System.get_env("ANTHROPIC_API_KEY")
config :genai, :openai,    api_key: System.get_env("OPENAI_API_KEY")
```

---

## 06 · genai_local
Local LLM inference bridge between `genai_core` and `ex_llama`. Provider: `GenAI.Provider.LocalLLama`. Manages a supervisor tree for session lifecycles (load → infer → unload). Config: `config :genai, :local_llama, enable: true, otp_app: :my_app`. Threads targeting `:local_llama` are routed through the local inference pipeline without code changes in calling layers. Depends on `ex_llama`.

---

## 07 · ex_llama `0.2.3`
Rustler NIF wrapping llama.cpp for local GGUF model inference. Key functions: `ExLLama.load_model/1` (path to GGUF), `ExLLama.create_session/2` (model ref + opts), `ExLLama.chat_completion/3` (session, messages, opts), `ExLLama.completion/3` (raw text). **27 chat templates** built in: Llama2, Llama3, Mistral, ChatML, Alpaca, Vicuna, Phi, Gemma, DeepSeek, Qwen, and more. Compiled via `elixir_make`; requires Rust toolchain at build time. Depends on `genai_core` + `elixir_make`.
```elixir
{:ok, model}   = ExLLama.load_model("/models/llama3.gguf")
{:ok, session} = ExLLama.create_session(model, [chat_template: :llama3])
{:ok, result}  = ExLLama.chat_completion(session, messages, [max_tokens: 512])
```

---

## 08 · elixir-weaviate
Weaviate vector DB client with schema DSL. Define a class: `use Noizu.Weaviate.Class` + `weaviate_class("ClassName") do … end`. CRUD: `Noizu.Weaviate.Api.Objects.{create, get, update, delete}`. Vector search via GraphQL DSL: `Noizu.Weaviate.GraphQL.{Get, Where, GroupBy}`. Batch import: `Noizu.Weaviate.Api.Batch`. Config: `config :noizu_weaviate, weaviate_api_key: "...", endpoint: "http://localhost:8080"`. Depends on `finch`, `jason`.
```elixir
use Noizu.Weaviate.Class
weaviate_class("Article") do
  property :title, :text
  property :body,  :text
end
{:ok, obj} = Noizu.Weaviate.Api.Objects.create(%Article{title: "Hi"}, context)
```

---

## 09 · fragmented_keys `0.1.0`
Composite cache-key invalidation without scanning. Create a tag: `FragmentedKeys.Tag.Standard.new("Name", "instance")`. Create a keyed entry: `FragmentedKeys.Key.new("KeyName", [tag1, tag2])`. Resolve to string: `FragmentedKeys.Key.get_key_str(key)` → MD5 digest of all tag generations. Invalidate a tag (bumps its generation, busting all dependent keys): `FragmentedKeys.Tag.increment(tag)`. `KeyRing` provides a template factory for namespaced key families. `CacheHandler` protocol has Memory and Redis backends. Redis backend requires optional `redix` dep.
```elixir
tag = FragmentedKeys.Tag.Standard.new("user", user_id)
key = FragmentedKeys.Key.new("profile", [tag])
cache_key = FragmentedKeys.Key.get_key_str(key)   # "abc123..."
FragmentedKeys.Tag.increment(tag)                  # invalidate
```

---

## 10 · smart_token `0.1.2`
Stateful, auditable single-use or time-limited tokens. Build with chainable DSL: `SmartToken.new(settings) |> single_use() |> validity_period(hours: 24) |> ip_whitelist("10.0.0.0/8")`. Dual-token design (token_a + token_b via ShortUUID) prevents timing attacks. Bind dynamic data: `SmartToken.bind!(token, bindings, context)`. Authorize from Plug conn: `SmartToken.authorize!(token_key, conn, context)`. Access audit trail stored per token. Depends on `noizu_labs_core`, `plug`.
```elixir
token = SmartToken.new(%{user: user_id}) |> single_use() |> validity_period(hours: 1)
key   = SmartToken.persist!(token, context)
# later:
{:ok, claims} = SmartToken.authorize!(key, conn, context)
```

---

## 11 · seed_helper `0.1.1`
Incremental, idempotent DB seeding with version tracking. Macros: `seed({"SeedName", "1.0"}) do … end` (runs once per version), `requires_seed({"Dep", "1.0"})` (ordering), `if_env(:test) do … end` (env gate). Handle store for cross-seed references: `set_handle("key", value)`, `handle("key", default)`. Session lifecycle: `SeedHelper.begin_session()` / `SeedHelper.end_session()`. Tracks completed seeds in DB to skip on re-run. Depends on `ecto_sql`.
```elixir
seed({"AdminUser", "1.0"}) do
  {:ok, user} = MyApp.User.create(%{email: "admin@example.com"}, ctx)
  set_handle("admin_user", user)
end
```

---

## 12 · elixir-github `0.1.0`
Thin GitHub REST API client. Low-level: `Noizu.Github.api_call(type, url, body, model, options)` where `type` is `:get | :post | :patch | :delete`. Responses deserialized to structs via `from_json/1`. Streaming supported via Finch. Config: `config :noizu_github, api_key: "...", owner: "myorg", repo: "myrepo"`. Depends on `finch`, `jason`.
```elixir
config :noizu_github, api_key: System.get_env("GH_TOKEN"), owner: "myorg", repo: "myrepo"
{:ok, issues} = Noizu.Github.api_call(:get, "/repos/myorg/myrepo/issues", nil, nil, [])
```

---

## 13 · sendgrid_elixir `2.0.1`
SendGrid V3 email client. Chainable email builder: `SendGrid.Email.build() |> add_to("a@b.com", "Alice") |> put_from("no-reply@app.com") |> put_subject("Hi") |> put_html("<p>Hello</p>") |> SendGrid.Mail.send()`. Phoenix template support via `put_phoenix_template/3`. Transactional and bulk sending. Config: `config :sendgrid, api_key: System.get_env("SENDGRID_API_KEY")`. Depends on `tesla`, `jason`.
```elixir
SendGrid.Email.build()
|> SendGrid.Email.add_to("user@example.com")
|> SendGrid.Email.put_from("no-reply@myapp.com")
|> SendGrid.Email.put_subject("Welcome")
|> SendGrid.Email.put_html("<h1>Hello</h1>")
|> SendGrid.Mail.send()
```

---

## Version Matrix

| Library | Version | Depends On |
|---|---|---|
| noizu_labs_core | 0.1.7 | — |
| noizu_labs_entities | 0.3.1 | noizu_labs_core |
| noizu_labs_services | 0.1.2 | noizu_labs_entities |
| genai_core | 0.3.0 | noizu_labs_core |
| genai | 0.3.0 | genai_core |
| genai_local | — | ex_llama |
| ex_llama | 0.2.3 | genai_core, elixir_make |
| elixir-weaviate | — | finch, jason |
| fragmented_keys | 0.1.0 | — (redix optional) |
| smart_token | 0.1.2 | noizu_labs_core, plug |
| seed_helper | 0.1.1 | ecto_sql |
| elixir-github | 0.1.0 | finch, jason |
| sendgrid_elixir | 2.0.1 | tesla, jason |

---

## Quick Router

| Need | Read |
|------|------|
| Define an entity | 01 + 02 |
| Call an LLM | 04 + 05 |
| Add a new provider | 05 |
| Distributed workers | 01 + 02 + 03 |
| RAG pipeline | 04 + 05 + 07 + 13 |
| Local model inference | 06 |
| Cache invalidation | 08 |
| Auth tokens | 09 |
| DB seeding | 10 |
| Architecture overview | 00 |
