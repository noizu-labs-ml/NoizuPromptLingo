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

# Ensure the Liquibase 077 marketing-signup tables (marketing_signups,
# marketing_settings) exist for the public landing capture suite. Idempotent.
NoizuPromptLingua.MarketingSignupTestSchema.ensure!()

# Ensure the custom MCP include scope table exists for custom gateway/catalog tests.
NoizuPromptLingua.MCPCustomScopeTestSchema.ensure!()

# Ensure the Liquibase 083 mcp_tool_sets table exists for the tool-sets suites.
NoizuPromptLingua.McpToolSetTestSchema.ensure!()

# Ensure the N2b provider record store (npl_mcp_toolset_store) exists for the
# toolset provider/conformance suites — NPL-owned storage; the lib's
# noizu_mcp_* tables are NOT created here (zero-writes guard owns that proof).
NoizuPromptLingua.ProviderStoreTestSchema.ensure!()

# The lib's persistence conformance battery (AP-8) lives in the dep's
# test/support, which consumers never compile — load it from the RESOLVED
# path-dep checkout when present so the ported suite can `use` it. A hex
# noizu_mcp (post-flip) simply leaves the battery unavailable.
case Mix.Project.deps_paths()[:noizu_mcp] do
  nil ->
    :ok

  lib_path ->
    battery = Path.join(lib_path, "test/support/persistence_conformance_case.ex")

    if File.exists?(battery), do: Code.compile_file(battery)
end

# Ensure the W4 MCP entity tables (Liquibase 019: mcp_prompts, mcp_prompt_versions,
# mcp_resources, mcp_resource_templates) exist for the mcp-entities suites. Idempotent.
NoizuPromptLingua.McpEntitiesTestSchema.ensure!()

# SSO hand-off columns (Liquibase 025) — Helm Liquibase is gated off in prod;
# tests must not assume the column exists.
try do
  Ecto.Adapters.SQL.query!(
    NoizuPromptLingua.Repo,
    """
    ALTER TABLE user_sessions
      ADD COLUMN IF NOT EXISTS claim_code varchar(255),
      ADD COLUMN IF NOT EXISTS claim_code_expires_at timestamptz
    """,
    []
  )
rescue
  _ -> :ok
end

# Ensure the Unicode Codex reference tables exist for Unicode domain/controller/MCP tests.
NoizuPromptLingua.UnicodeCodexTestSchema.ensure!()

# Ensure the sessions model/runner columns (Liquibase 072) exist for the sessions suite.
NoizuPromptLingua.SessionTestSchema.ensure!()

# Ensure the mcp_overview (Liquibase 073) pgvector tables exist for the overview suite.
NoizuPromptLingua.McpOverviewTestSchema.ensure!()

# Ensure OAuth AS tables (Liquibase 074) exist for OAuth suite.
NoizuPromptLingua.OAuthTestSchema.ensure!()

# Ensure ACL/group tables (Liquibase 081) exist for the ACL suite.
NoizuPromptLingua.AclTestSchema.ensure!()

# Overview generation uses the deterministic (network-free) adapter in tests; the real
# LLM adapter (Generator.LLM) is the runtime default. Embeddings already run deterministic
# (set below), so the whole mcp_overview flow is offline in the suite.
Application.put_env(
  :noizu_prompt_lingua,
  :mcp_overview,
  Keyword.merge(Application.get_env(:noizu_prompt_lingua, :mcp_overview, []),
    generator: NoizuPromptLingua.Domains.MCPOverview.Generator.Stub
  )
)

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

# W4 cutover: route the TRP client at the in-memory stub transport. base_url/key
# are set so Config.configured?/0 is true; the stub never touches the network.
Application.put_env(:noizu_prompt_lingua, :trp,
  base_url: "http://trp.test",
  shared_key: "trp_sk_test"
)

Application.put_env(:noizu_prompt_lingua, :trp_transport, NoizuPromptLingua.TRP.TestStub)
NoizuPromptLingua.TRP.TestStub.reset()
