defmodule NoizuPromptLingua.ProviderStoreTestSchema do
  @moduledoc """
  Idempotently ensures the N2b provider record store (`npl_mcp_toolset_store`)
  exists in the test DB. The `NoizuPromptLingua.MCP.ToolsetProvider` stores
  host/lib-authored records (conformance toolsets, grants, consent
  negotiations) here — NPL-owned storage, never the lib's `noizu_mcp_*`
  tables (Decision 2, zero-writes).

  The production DDL ships with the flip train (N5/N6) alongside provider
  activation (FR-2B-7 deferred-activation posture); N2b is integration-branch
  only and the provider degrades per D5 when the table is absent.
  """
  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS npl_mcp_toolset_store (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        store_key varchar(32) NOT NULL,
        record_id varchar(255) NOT NULL,
        record jsonb NOT NULL,
        expires_at timestamptz,
        inserted_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT npl_mcp_toolset_store_record_key UNIQUE (store_key, record_id)
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS npl_mcp_toolset_store_store_idx ON npl_mcp_toolset_store (store_key)",
      []
    )

    :ok
  end
end
