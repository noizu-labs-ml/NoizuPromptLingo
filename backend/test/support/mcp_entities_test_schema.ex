defmodule NoizuPromptLingua.McpEntitiesTestSchema do
  @moduledoc """
  Idempotently ensures the W4 MCP entity tables (Liquibase 019: mcp_prompts,
  mcp_prompt_versions, mcp_resources, mcp_resource_templates) exist in the test
  DB so the mcp-entities suites are self-contained.
  """

  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_prompts (
        id uuid PRIMARY KEY,
        slug varchar(255) NOT NULL,
        name varchar(255) NOT NULL,
        description text,
        arguments jsonb NOT NULL DEFAULT '[]',
        active_version integer NOT NULL DEFAULT 1,
        organization_id uuid,
        project_id uuid,
        inserted_at timestamp(0) NOT NULL,
        updated_at timestamp(0) NOT NULL
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE UNIQUE INDEX IF NOT EXISTS uq_mcp_prompts_slug ON mcp_prompts (slug)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_prompt_versions (
        id uuid PRIMARY KEY,
        prompt_id uuid NOT NULL,
        version integer NOT NULL,
        template text NOT NULL,
        change_note text,
        inserted_at timestamp(0) NOT NULL
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE UNIQUE INDEX IF NOT EXISTS idx_mcp_prompt_versions_unique
        ON mcp_prompt_versions (prompt_id, version)
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_resources (
        id uuid PRIMARY KEY,
        uri varchar(2048) NOT NULL,
        name varchar(255) NOT NULL,
        description text,
        mime_type varchar(255) NOT NULL DEFAULT 'text/plain',
        content text NOT NULL,
        organization_id uuid,
        project_id uuid,
        inserted_at timestamp(0) NOT NULL,
        updated_at timestamp(0) NOT NULL
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_mcp_resources_uri ON mcp_resources (uri)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS mcp_resource_templates (
        id uuid PRIMARY KEY,
        uri_template varchar(2048) NOT NULL,
        name varchar(255) NOT NULL,
        description text,
        mime_type varchar(255) NOT NULL DEFAULT 'text/plain',
        organization_id uuid,
        project_id uuid,
        inserted_at timestamp(0) NOT NULL,
        updated_at timestamp(0) NOT NULL
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE INDEX IF NOT EXISTS idx_mcp_resource_templates_uri
        ON mcp_resource_templates (uri_template)
      """,
      []
    )

    :ok
  end
end
