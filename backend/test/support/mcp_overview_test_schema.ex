defmodule NoizuPromptLingua.McpOverviewTestSchema do
  @moduledoc """
  Idempotently ensures the `mcp_overview` (Liquibase 073) pgvector tables exist in
  the test DB so the overview suite is self-contained. Mirrors the other
  `*TestSchema` helpers. The throwaway test container ships the `vector` extension
  and a superuser role, so `CREATE EXTENSION IF NOT EXISTS vector` is a safe no-op.
  """
  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(Repo, "CREATE EXTENSION IF NOT EXISTS vector", [])

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_overviews (
        id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        scope_slug     varchar(255) NOT NULL,
        task_text      text NOT NULL,
        task_embedding vector(1536),
        overview_md    text NOT NULL,
        runner         varchar(255),
        model          varchar(255),
        verbosity      integer,
        status         varchar(20) NOT NULL DEFAULT 'generated'
                         CHECK (status IN ('generated', 'approved', 'rejected')),
        inserted_at    timestamptz NOT NULL DEFAULT now(),
        updated_at     timestamptz NOT NULL DEFAULT now()
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_mcp_overviews_scope_status ON mcp_overviews (scope_slug, status)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_tool_vectors (
        id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        scope_slug       varchar(255) NOT NULL,
        group_id         varchar(255) NOT NULL,
        tool_name        varchar(255) NOT NULL,
        verbosity        integer,
        description_hash varchar(64) NOT NULL,
        embedding        vector(1536),
        inserted_at      timestamptz NOT NULL DEFAULT now(),
        updated_at       timestamptz NOT NULL DEFAULT now()
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      DO $$
      BEGIN
        IF NOT EXISTS (
          SELECT 1 FROM pg_constraint WHERE conname = 'uq_mcp_tool_vectors_scope_tool_hash'
        ) THEN
          ALTER TABLE mcp_tool_vectors
            ADD CONSTRAINT uq_mcp_tool_vectors_scope_tool_hash
            UNIQUE (scope_slug, tool_name, description_hash);
        END IF;
      END $$
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_mcp_tool_vectors_scope ON mcp_tool_vectors (scope_slug)",
      []
    )

    :ok
  end
end
