ExUnit.start()

# Apply the memory-engine schema (Liquibase 045–050) to the test DB so the memory suite is
# self-contained.
NoizuPromptLingua.MemoryTestSchema.ensure!()

# Memory tests are Weaviate-primary: use the deterministic (feature-hash) embedder for reproducible
# vectors with no OpenAI, and an ephemeral, isolated class on the cluster Weaviate. Inter-test
# isolation comes from each test's randomly-generated organization_id (scope filter).
Application.put_env(
  :noizu_prompt_lingua,
  :embeddings,
  Keyword.merge(Application.get_env(:noizu_prompt_lingua, :embeddings, []), provider: :deterministic)
)

Application.put_env(
  :noizu_prompt_lingua,
  :memory_weaviate,
  Keyword.merge(Application.get_env(:noizu_prompt_lingua, :memory_weaviate, []),
    enabled: true,
    class: "NplMemoryItest"
  )
)

# Fresh ephemeral class per suite run (best-effort; needs WEAVIATE_API_KEY + network).
NoizuPromptLingua.Domains.Memory.VectorStore.delete_class()
NoizuPromptLingua.Domains.Memory.VectorStore.ensure_class()

Ecto.Adapters.SQL.Sandbox.mode(NoizuPromptLingua.Repo, :manual)
