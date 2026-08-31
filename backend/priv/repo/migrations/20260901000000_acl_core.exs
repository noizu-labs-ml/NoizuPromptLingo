defmodule NoizuPromptLingua.Repo.Migrations.AclCore do
  use Ecto.Migration

  @moduledoc """
  ACL/group library tables (Liquibase 081-acl-core twin). Prod Helm has
  Liquibase gated off, so Ecto.Migrator applies these. IF NOT EXISTS keeps this
  safe if Liquibase later runs 081 on the same database.
  """

  def up do
    execute("""
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
    """)

    execute("CREATE UNIQUE INDEX IF NOT EXISTS idx_acl_groups_name ON acl_groups (name)")
    execute("CREATE INDEX IF NOT EXISTS idx_acl_groups_ref ON acl_groups ((ref->>'type'), (ref->>'id'))")

    execute("""
    CREATE TABLE IF NOT EXISTS acl_group_members (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      group_id uuid NOT NULL REFERENCES acl_groups(id) ON DELETE CASCADE,
      member_ref jsonb NOT NULL,
      expires_at timestamptz,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now(),
      CONSTRAINT uq_acl_group_members_group_member UNIQUE (group_id, member_ref)
    )
    """)

    execute("CREATE INDEX IF NOT EXISTS idx_acl_group_members_group ON acl_group_members (group_id)")

    execute("""
    CREATE INDEX IF NOT EXISTS idx_acl_group_members_member
      ON acl_group_members ((member_ref->>'type'), (member_ref->>'id'))
    """)

    execute("""
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
    """)

    execute("""
    CREATE INDEX IF NOT EXISTS idx_acl_rules_subject
      ON acl_rules ((subject_ref->>'type'), (subject_ref->>'id'))
    """)

    execute("""
    CREATE INDEX IF NOT EXISTS idx_acl_rules_resource
      ON acl_rules ((resource_ref->>'type'), (resource_ref->>'id'))
    """)

    execute("CREATE INDEX IF NOT EXISTS idx_acl_rules_action ON acl_rules (action)")
  end

  def down do
    execute("DROP TABLE IF EXISTS acl_rules")
    execute("DROP TABLE IF EXISTS acl_group_members")
    execute("DROP TABLE IF EXISTS acl_groups")
  end
end
