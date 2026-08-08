defmodule NoizuPromptLingua.UnicodeCodexTestSchema do
  @moduledoc """
  Idempotently ensures the Unicode Codex tables exist in the test DB.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    """
    CREATE TABLE IF NOT EXISTS unicode_elements (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      scope varchar(32) NOT NULL,
      organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
      slug varchar(255) NOT NULL,
      codepoint varchar(128),
      codepoint_int integer,
      char text,
      name varchar(255) NOT NULL,
      title varchar(512) NOT NULL,
      description text,
      meaning text,
      printable boolean NOT NULL DEFAULT true,
      visibility varchar(64) NOT NULL DEFAULT 'glyph',
      unicode_meta jsonb NOT NULL DEFAULT '{}'::jsonb,
      flags text[] NOT NULL DEFAULT '{}',
      topics text[] NOT NULL DEFAULT '{}',
      sentiments text[] NOT NULL DEFAULT '{}',
      aliases text[] NOT NULL DEFAULT '{}',
      search_terms text[] NOT NULL DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT unicode_elements_scope_check CHECK (
        (scope = 'global' AND organization_id IS NULL AND project_id IS NULL) OR
        (scope = 'organization' AND organization_id IS NOT NULL AND project_id IS NULL) OR
        (scope = 'project' AND organization_id IS NOT NULL AND project_id IS NOT NULL)
      )
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_elements_global_slug ON unicode_elements (slug) WHERE scope = 'global'",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_elements_org_slug ON unicode_elements (organization_id, slug) WHERE scope = 'organization'",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_elements_project_slug ON unicode_elements (organization_id, project_id, slug) WHERE scope = 'project'",
    "CREATE INDEX IF NOT EXISTS idx_unicode_elements_scope ON unicode_elements (scope, organization_id, project_id)",
    "CREATE INDEX IF NOT EXISTS idx_unicode_elements_flags ON unicode_elements USING gin (flags)",
    "CREATE INDEX IF NOT EXISTS idx_unicode_elements_topics ON unicode_elements USING gin (topics)",
    """
    CREATE TABLE IF NOT EXISTS unicode_special_usages (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      scope varchar(32) NOT NULL,
      organization_id uuid REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
      slug varchar(255) NOT NULL,
      name varchar(255) NOT NULL,
      title varchar(512) NOT NULL,
      description text,
      reference_links jsonb NOT NULL DEFAULT '[]'::jsonb,
      flags text[] NOT NULL DEFAULT '{}',
      topics text[] NOT NULL DEFAULT '{}',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT unicode_special_usages_scope_check CHECK (
        (scope = 'global' AND organization_id IS NULL AND project_id IS NULL) OR
        (scope = 'organization' AND organization_id IS NOT NULL AND project_id IS NULL) OR
        (scope = 'project' AND organization_id IS NOT NULL AND project_id IS NOT NULL)
      )
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_special_usages_global_slug ON unicode_special_usages (slug) WHERE scope = 'global'",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_special_usages_org_slug ON unicode_special_usages (organization_id, slug) WHERE scope = 'organization'",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_special_usages_project_slug ON unicode_special_usages (organization_id, project_id, slug) WHERE scope = 'project'",
    "CREATE INDEX IF NOT EXISTS idx_unicode_special_usages_scope ON unicode_special_usages (scope, organization_id, project_id)",
    """
    CREATE TABLE IF NOT EXISTS unicode_element_usages (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      element_id uuid NOT NULL REFERENCES unicode_elements(id) ON DELETE CASCADE,
      special_usage_id uuid NOT NULL REFERENCES unicode_special_usages(id) ON DELETE CASCADE,
      inserted_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_element_usages_unique ON unicode_element_usages (element_id, special_usage_id)",
    "CREATE INDEX IF NOT EXISTS idx_unicode_element_usages_usage ON unicode_element_usages (special_usage_id)",
    """
    CREATE TABLE IF NOT EXISTS unicode_element_relations (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      source_element_id uuid NOT NULL REFERENCES unicode_elements(id) ON DELETE CASCADE,
      target_element_id uuid NOT NULL REFERENCES unicode_elements(id) ON DELETE CASCADE,
      relation_type varchar(64) NOT NULL,
      description text,
      metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
      inserted_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_unicode_element_relations_unique ON unicode_element_relations (source_element_id, target_element_id, relation_type)",
    "CREATE INDEX IF NOT EXISTS idx_unicode_element_relations_target ON unicode_element_relations (target_element_id)",
    "CREATE INDEX IF NOT EXISTS idx_unicode_element_relations_type ON unicode_element_relations (relation_type)"
  ]

  def ensure! do
    Enum.each(@statements, &Ecto.Adapters.SQL.query!(Repo, &1, []))
    :ok
  end
end
