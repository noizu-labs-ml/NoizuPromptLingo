defmodule NoizuPromptLingua.AclTestSchema do
  @moduledoc """
  Idempotently ensures the Liquibase 081 ACL tables (acl_groups,
  acl_group_members, acl_rules) exist on the test DB so the ACL suites are
  self-contained on top of whatever Liquibase state the test DB has.
  Mirrors `MarketingSignupTestSchema` / `OAuthTestSchema`.
  """
  alias NoizuPromptLingua.Repo

  def ensure! do
    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS acl_groups (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        name varchar(255) NOT NULL,
        description text,
        ref jsonb,
        status varchar(16) NOT NULL DEFAULT 'active'
          CHECK (status IN ('active', 'archived')),
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        inserted_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE UNIQUE INDEX IF NOT EXISTS idx_acl_groups_name ON acl_groups (name)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_acl_groups_ref ON acl_groups ((ref->>'type'), (ref->>'id'))",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS acl_group_members (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        group_id uuid NOT NULL REFERENCES acl_groups(id) ON DELETE CASCADE,
        member_ref jsonb NOT NULL,
        expires_at timestamptz,
        inserted_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now(),
        CONSTRAINT uq_acl_group_members_group_member UNIQUE (group_id, member_ref)
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_acl_group_members_group ON acl_group_members (group_id)",
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE INDEX IF NOT EXISTS idx_acl_group_members_member
        ON acl_group_members ((member_ref->>'type'), (member_ref->>'id'))
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE TABLE IF NOT EXISTS acl_rules (
        id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
        subject_ref jsonb NOT NULL,
        resource_ref jsonb NOT NULL,
        action varchar(255) NOT NULL,
        effect varchar(16) NOT NULL
          CHECK (effect IN ('allow', 'deny')),
        scope varchar(255),
        priority integer NOT NULL DEFAULT 0,
        status varchar(16) NOT NULL DEFAULT 'active'
          CHECK (status IN ('active', 'archived')),
        metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
        inserted_at timestamptz NOT NULL DEFAULT now(),
        updated_at timestamptz NOT NULL DEFAULT now()
      )
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE INDEX IF NOT EXISTS idx_acl_rules_subject
        ON acl_rules ((subject_ref->>'type'), (subject_ref->>'id'))
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      """
      CREATE INDEX IF NOT EXISTS idx_acl_rules_resource
        ON acl_rules ((resource_ref->>'type'), (resource_ref->>'id'))
      """,
      []
    )

    Ecto.Adapters.SQL.query!(
      Repo,
      "CREATE INDEX IF NOT EXISTS idx_acl_rules_action ON acl_rules (action)",
      []
    )
  end
end
