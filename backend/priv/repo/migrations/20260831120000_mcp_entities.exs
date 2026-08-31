defmodule NoizuPromptLingua.Repo.Migrations.McpEntities do
  use Ecto.Migration

  @moduledoc """
  W4 mcp-entities: versioned MCP prompts (`mcp_prompts` + `mcp_prompt_versions`),
  resource entries (`mcp_resources`) and resource templates
  (`mcp_resource_templates`). Mirrors Liquibase changeset-019.mcp-entities;
  everything is IF NOT EXISTS so a DB that already ran Liquibase is untouched.
  """

  def up do
    execute("""
    CREATE TABLE IF NOT EXISTS mcp_prompts (
      id uuid PRIMARY KEY,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      description text,
      arguments jsonb NOT NULL DEFAULT '[]'::jsonb,
      active_version integer NOT NULL DEFAULT 1,
      organization_id uuid,
      project_id uuid,
      inserted_at timestamp(0) without time zone NOT NULL,
      updated_at timestamp(0) without time zone NOT NULL
    )
    """)

    execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_prompts_slug
      ON mcp_prompts (slug)
    """)

    execute("""
    CREATE TABLE IF NOT EXISTS mcp_prompt_versions (
      id uuid PRIMARY KEY,
      prompt_id uuid NOT NULL,
      version integer NOT NULL,
      template text NOT NULL,
      change_note text,
      inserted_at timestamp(0) without time zone NOT NULL
    )
    """)

    execute("""
    CREATE UNIQUE INDEX IF NOT EXISTS idx_mcp_prompt_versions_unique
      ON mcp_prompt_versions (prompt_id, version)
    """)

    execute("""
    CREATE TABLE IF NOT EXISTS mcp_resources (
      id uuid PRIMARY KEY,
      uri varchar(2048) NOT NULL,
      name varchar(255) NOT NULL,
      description text,
      mime_type varchar(255) NOT NULL DEFAULT 'text/plain',
      content text NOT NULL,
      organization_id uuid,
      project_id uuid,
      inserted_at timestamp(0) without time zone NOT NULL,
      updated_at timestamp(0) without time zone NOT NULL
    )
    """)

    execute("""
    CREATE INDEX IF NOT EXISTS idx_mcp_resources_uri
      ON mcp_resources (uri)
    """)

    execute("""
    CREATE TABLE IF NOT EXISTS mcp_resource_templates (
      id uuid PRIMARY KEY,
      uri_template varchar(2048) NOT NULL,
      name varchar(255) NOT NULL,
      description text,
      mime_type varchar(255) NOT NULL DEFAULT 'text/plain',
      organization_id uuid,
      project_id uuid,
      inserted_at timestamp(0) without time zone NOT NULL,
      updated_at timestamp(0) without time zone NOT NULL
    )
    """)

    execute("""
    CREATE INDEX IF NOT EXISTS idx_mcp_resource_templates_uri
      ON mcp_resource_templates (uri_template)
    """)
  end

  def down do
    execute("DROP TABLE IF EXISTS mcp_resource_templates")
    execute("DROP TABLE IF EXISTS mcp_resources")
    execute("DROP TABLE IF EXISTS mcp_prompt_versions")
    execute("DROP TABLE IF EXISTS mcp_prompts")
  end
end
