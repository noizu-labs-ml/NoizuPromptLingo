defmodule NoizuPromptLingua.McpToolSetTestSchema do
  @moduledoc """
  Idempotently ensures the Liquibase 083 `mcp_tool_sets` table exists in the
  test DB (self-contained suite pattern). Mirrors the 083 DDL minus FK
  constraints — the suite exercises app-level rules, not FK enforcement — and
  keeps the named unique constraint `mcp_tool_sets_org_slug_key` the changeset
  references.
  """
  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_tool_sets (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        organization_id uuid NOT NULL,
        project_id uuid,
        group_id uuid,
        slug varchar(64) NOT NULL,
        display_name varchar(200),
        description text,
        source varchar(20) NOT NULL DEFAULT 'custom',
        source_profile varchar(64),
        config jsonb NOT NULL DEFAULT '{}'::jsonb,
        settings jsonb NOT NULL DEFAULT '{}'::jsonb,
        expires_at timestamptz,
        is_active boolean NOT NULL DEFAULT true,
        inserted_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT mcp_tool_sets_org_slug_key UNIQUE (organization_id, slug),
        CONSTRAINT mcp_tool_sets_source_check CHECK (source IN ('custom', 'clone'))
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS mcp_tool_sets_org_idx ON mcp_tool_sets (organization_id)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS mcp_tool_sets_proj_idx ON mcp_tool_sets (project_id)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS mcp_tool_sets_group_idx ON mcp_tool_sets (group_id)",
      []
    )

    :ok
  end
end
