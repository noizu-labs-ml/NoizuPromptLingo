defmodule NoizuPromptLingua.Repo.Migrations.SsoClaimCodeAndScopePackaging do
  use Ecto.Migration

  @moduledoc """
  Prod Helm has Liquibase gated off, so 025 (session claim_code) and 071
  (mcp_custom_scopes kind/org/project) never applied. Ecto.Migrator does run
  in releases — these IF NOT EXISTS statements close that gap without
  conflicting if Liquibase later runs the same ALTERs.
  """

  def up do
    execute("""
    ALTER TABLE user_sessions
      ADD COLUMN IF NOT EXISTS claim_code varchar(255),
      ADD COLUMN IF NOT EXISTS claim_code_expires_at timestamptz
    """)

    execute("""
    CREATE INDEX IF NOT EXISTS idx_user_sessions_claim_code
      ON user_sessions (claim_code)
      WHERE claim_code IS NOT NULL
    """)

    execute("""
    ALTER TABLE mcp_custom_scopes
      ADD COLUMN IF NOT EXISTS kind varchar(20) NOT NULL DEFAULT 'custom',
      ADD COLUMN IF NOT EXISTS organization_id uuid,
      ADD COLUMN IF NOT EXISTS project_id uuid
    """)

    execute("CREATE INDEX IF NOT EXISTS idx_mcp_custom_scopes_kind ON mcp_custom_scopes (kind)")

    execute("""
    CREATE INDEX IF NOT EXISTS idx_mcp_custom_scopes_organization_id
      ON mcp_custom_scopes (organization_id)
    """)

    execute("""
    CREATE INDEX IF NOT EXISTS idx_mcp_custom_scopes_project_id
      ON mcp_custom_scopes (project_id)
    """)
  end

  def down do
    execute("DROP INDEX IF EXISTS idx_mcp_custom_scopes_project_id")
    execute("DROP INDEX IF EXISTS idx_mcp_custom_scopes_organization_id")
    execute("DROP INDEX IF EXISTS idx_mcp_custom_scopes_kind")
    execute("DROP INDEX IF EXISTS idx_user_sessions_claim_code")
  end
end
