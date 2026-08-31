defmodule NoizuPromptLingua.Repo.Migrations.McpKeyToolsets do
  use Ecto.Migration

  @moduledoc """
  Per-key MCP toolset config on mcp_api_keys (Liquibase changeset
  080a-mcp-key-toolsets twin). Prod Helm has Liquibase gated off, so 080 never
  applies there — Ecto.Migrator does. IF NOT EXISTS keeps this safe if
  Liquibase later runs the same ALTER.
  """

  def up do
    execute("""
    ALTER TABLE mcp_api_keys
      ADD COLUMN IF NOT EXISTS toolset_config JSONB NOT NULL DEFAULT '{}'::jsonb
    """)
  end

  def down do
    execute("ALTER TABLE mcp_api_keys DROP COLUMN IF EXISTS toolset_config")
  end
end
