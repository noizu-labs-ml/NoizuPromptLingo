defmodule NoizuPromptLingua.Repo.Migrations.McpEndpointTemplates do
  use Ecto.Migration

  @moduledoc """
  Multiple personal/org custom MCP endpoints plus a marked default.

  Prod Helm has Liquibase gated off, so 076 never applies there — Ecto.Migrator
  does. IF NOT EXISTS / DROP IF EXISTS keeps this safe if Liquibase later runs
  the same ALTERs.
  """

  def up do
    execute("""
    ALTER TABLE mcp_custom_scopes
      ADD COLUMN IF NOT EXISTS is_default boolean NOT NULL DEFAULT false
    """)

    execute("""
    ALTER TABLE mcp_custom_scopes
      ADD COLUMN IF NOT EXISTS source_template_slug text
    """)

    execute("""
    UPDATE mcp_custom_scopes
       SET is_default = true
     WHERE user_id IS NOT NULL
    """)

    execute("""
    UPDATE mcp_custom_scopes
       SET source_template_slug = 'tobor'
     WHERE user_id IS NOT NULL
       AND source_template_slug IS NULL
    """)

    execute("DROP INDEX IF EXISTS uq_mcp_custom_scopes_user_default")

    execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_user_default
      ON mcp_custom_scopes (user_id)
      WHERE user_id IS NOT NULL AND is_default = true
    """)

    execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_org_default
      ON mcp_custom_scopes (organization_id)
      WHERE organization_id IS NOT NULL AND user_id IS NULL AND is_default = true
    """)
  end

  def down do
    execute("DROP INDEX IF EXISTS uq_mcp_custom_scopes_org_default")
    execute("DROP INDEX IF EXISTS uq_mcp_custom_scopes_user_default")

    execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_user_default
      ON mcp_custom_scopes (user_id)
      WHERE user_id IS NOT NULL
    """)

    execute("ALTER TABLE mcp_custom_scopes DROP COLUMN IF EXISTS source_template_slug")
    execute("ALTER TABLE mcp_custom_scopes DROP COLUMN IF EXISTS is_default")
  end
end
