defmodule NoizuPromptLingua.MCPCustomScopeTestSchema do
  @moduledoc """
  Idempotently ensures the custom MCP scope table exists in the test DB.
  """
  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_custom_scopes (
        id uuid PRIMARY KEY,
        slug text NOT NULL,
        name text NOT NULL,
        description text,
        config jsonb NOT NULL DEFAULT '{}',
        inserted_at timestamp(0) without time zone NOT NULL,
        updated_at timestamp(0) without time zone NOT NULL
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_slug ON mcp_custom_scopes (slug)",
      []
    )

    # Liquibase 071 columns (packaging). Added without FK constraints here — the
    # suite exercises the app-level rules, not FK enforcement — but idempotent so
    # a DB already carrying 071 is untouched.
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      ALTER TABLE mcp_custom_scopes
        ADD COLUMN IF NOT EXISTS kind varchar(20) NOT NULL DEFAULT 'custom',
        ADD COLUMN IF NOT EXISTS organization_id uuid,
        ADD COLUMN IF NOT EXISTS project_id uuid,
        ADD COLUMN IF NOT EXISTS user_id uuid,
        ADD COLUMN IF NOT EXISTS is_default boolean NOT NULL DEFAULT false,
        ADD COLUMN IF NOT EXISTS source_template_slug text
      """,
      []
    )

    Ecto.Adapters.SQL.query!(Repo, "DROP INDEX IF EXISTS uq_mcp_custom_scopes_user_default", [])

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_user_default
        ON mcp_custom_scopes (user_id)
        WHERE user_id IS NOT NULL AND is_default = true
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_org_default
        ON mcp_custom_scopes (organization_id)
        WHERE organization_id IS NOT NULL AND user_id IS NULL AND is_default = true
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      UPDATE mcp_custom_scopes
         SET is_default = true
       WHERE user_id IS NOT NULL
         AND is_default = false
         AND NOT EXISTS (
           SELECT 1 FROM mcp_custom_scopes other
            WHERE other.user_id = mcp_custom_scopes.user_id
              AND other.is_default = true
         )
      """,
      []
    )

    :ok
  end
end
