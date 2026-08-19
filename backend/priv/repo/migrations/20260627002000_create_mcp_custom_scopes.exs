defmodule NoizuPromptLingua.Repo.Migrations.CreateMCPCustomScopes do
  use Ecto.Migration

  @moduledoc """
  Original creator of mcp_custom_scopes. Liquibase 070a now creates the same
  table on CI/fresh DBs, so this must be IF NOT EXISTS or mix test fails with
  duplicate_table after `liquibase update`.
  """

  def up do
    execute("""
    CREATE TABLE IF NOT EXISTS mcp_custom_scopes (
      id uuid PRIMARY KEY,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      description text,
      config jsonb NOT NULL DEFAULT '{}'::jsonb,
      inserted_at timestamp without time zone NOT NULL,
      updated_at timestamp without time zone NOT NULL
    )
    """)

    execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_custom_scopes_slug
      ON mcp_custom_scopes (slug)
    """)
  end

  def down do
    execute("DROP INDEX IF EXISTS uq_mcp_custom_scopes_slug")
    execute("DROP TABLE IF EXISTS mcp_custom_scopes")
  end
end
