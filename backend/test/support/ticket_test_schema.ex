defmodule NoizuPromptLingua.TicketTestSchema do
  @moduledoc """
  Idempotently brings the human-key schema (Liquibase 055) onto the test DB: the
  projects/organizations key_prefix columns, the tickets number/key columns, the
  ticket_number_counters table, and all the partial unique indexes. Mirrors the other
  *TestSchema helpers — the shared test instance lags the latest changelogs, and tickets
  had no human-key coverage. 055 is committed + in master, so prod has it; this only
  reconciles the test DB.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    "ALTER TABLE projects ADD COLUMN IF NOT EXISTS key_prefix varchar(16)",
    "ALTER TABLE organizations ADD COLUMN IF NOT EXISTS key_prefix varchar(16)",
    "ALTER TABLE tickets ADD COLUMN IF NOT EXISTS number integer",
    "ALTER TABLE tickets ADD COLUMN IF NOT EXISTS key varchar(64)",
    """
    CREATE TABLE IF NOT EXISTS ticket_number_counters (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
      last_number integer NOT NULL DEFAULT 0,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_tnc_proj ON ticket_number_counters (organization_id, project_id) WHERE project_id IS NOT NULL",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_tnc_org ON ticket_number_counters (organization_id) WHERE project_id IS NULL",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_tickets_proj_number ON tickets (organization_id, project_id, number) WHERE project_id IS NOT NULL AND number IS NOT NULL",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_tickets_org_number ON tickets (organization_id, number) WHERE project_id IS NULL AND number IS NOT NULL",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_tickets_org_key ON tickets (organization_id, key) WHERE key IS NOT NULL",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_projects_org_key_prefix ON projects (organization_id, key_prefix) WHERE key_prefix IS NOT NULL",
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_organizations_key_prefix ON organizations (key_prefix) WHERE key_prefix IS NOT NULL"
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
