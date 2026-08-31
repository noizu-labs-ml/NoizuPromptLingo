defmodule NoizuPromptLingua.Repo.Migrations.OAuthClientToolsets do
  use Ecto.Migration

  @moduledoc """
  W8: per-OAuth-client MCP toolset narrowing (`oauth_clients.toolset_config`),
  captured by the consent screen. Shape-identical to `mcp_api_keys.toolset_config`
  (Ecto migration 20260831000000 twin); only blocked entries are stored.

  `IF NOT EXISTS` keeps this safe if a prod Liquibase changeset (074-series
  oauth tables live in the chart, not this repo) later adds the same column.
  """

  def up do
    execute("""
    ALTER TABLE oauth_clients
      ADD COLUMN IF NOT EXISTS toolset_config JSONB NOT NULL DEFAULT '{}'::jsonb
    """)
  end

  def down do
    execute("ALTER TABLE oauth_clients DROP COLUMN IF EXISTS toolset_config")
  end
end
