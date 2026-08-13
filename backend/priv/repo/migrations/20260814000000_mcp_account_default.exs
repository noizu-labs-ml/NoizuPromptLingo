defmodule NoizuPromptLingua.Repo.Migrations.McpAccountDefault do
  use Ecto.Migration

  @moduledoc """
  Per-account default-mcp custom endpoint. Prod Helm has Liquibase gated off,
  so 075 never applies there — Ecto.Migrator does. IF NOT EXISTS keeps this
  safe if Liquibase later runs the same ALTERs.
  """

  def up do
    execute("""
    ALTER TABLE mcp_custom_scopes
      ADD COLUMN IF NOT EXISTS user_id uuid
    """)

    execute("""
    CREATE INDEX IF NOT EXISTS idx_mcp_custom_scopes_user_id
      ON mcp_custom_scopes (user_id)
    """)

    execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_user_default
      ON mcp_custom_scopes (user_id)
      WHERE user_id IS NOT NULL
    """)
  end

  def down do
    execute("DROP INDEX IF EXISTS uq_mcp_custom_scopes_user_default")
    execute("DROP INDEX IF EXISTS idx_mcp_custom_scopes_user_id")
    execute("ALTER TABLE mcp_custom_scopes DROP COLUMN IF EXISTS user_id")
  end
end
