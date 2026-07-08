ExUnit.start()

# Apply the memory-engine schema (Liquibase 045–050) to the test DB so the memory suite is
# self-contained.
NoizuPromptLingua.MemoryTestSchema.ensure!()

# Ensure the chat-room slug column + unique index (Liquibase 052) exist on the test DB so the
# chat suite is self-contained. Idempotent.
NoizuPromptLingua.ChatTestSchema.ensure!()

# Ensure ticket_queues carries the 038-boards columns + partial unique slug indexes on the test
# DB so the boards/queues suite is self-contained (the shared instance lagged 038). Idempotent.
NoizuPromptLingua.BoardTestSchema.ensure!()

# Ensure the 040-assets tables (asset_entries / asset_outputs / asset_entry_history) exist on the
# test DB so the assets suite is self-contained (the shared instance lagged 040). Idempotent.
NoizuPromptLingua.AssetTestSchema.ensure!()

# Ensure the ADR-015 / Liquibase 053 'lead' role tier exists on the test DB (role_name_enum
# value + group row) so the authz role-rank sync guard matches. Idempotent.
NoizuPromptLingua.AuthzTestSchema.ensure!()

# Ensure the Liquibase 055 human-key schema (key_prefix cols, tickets number/key, the
# ticket_number_counters table + partial uniques) exists on the test DB. Idempotent.
NoizuPromptLingua.TicketTestSchema.ensure!()

# Ensure the Liquibase 059-061 marketing tables (customer personas/segments, ticket_entity_links,
# competitors/keywords/market_reports, campaigns/ad_groups/ad_copies/domain_names/landing_pages)
# exist on the test DB so the customers/market/campaigns suites are self-contained. Idempotent.
NoizuPromptLingua.MarketingTestSchema.ensure!()

# Ensure the custom MCP include scope table exists for custom gateway/catalog tests.
NoizuPromptLingua.MCPCustomScopeTestSchema.ensure!()

# Ensure the Unicode Codex reference tables exist for Unicode domain/controller/MCP tests.
NoizuPromptLingua.UnicodeCodexTestSchema.ensure!()

# Memory tests are Weaviate-primary: use the deterministic (feature-hash) embedder for reproducible
# vectors with no OpenAI, and an ephemeral, isolated class on the cluster Weaviate. Inter-test
# isolation comes from each test's randomly-generated organization_id (scope filter).
Application.put_env(
  :noizu_prompt_lingua,
  :embeddings,
  Keyword.merge(Application.get_env(:noizu_prompt_lingua, :embeddings, []),
    provider: :deterministic
  )
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
