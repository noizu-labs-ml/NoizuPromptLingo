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

    :ok
  end
end
