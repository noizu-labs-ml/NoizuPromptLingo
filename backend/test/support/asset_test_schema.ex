defmodule NoizuPromptLingua.AssetTestSchema do
  @moduledoc """
  Idempotently creates the Liquibase 040-assets tables (asset_entries, asset_outputs,
  asset_entry_history) + their indexes on the test DB so the assets suite is
  self-contained on top of whatever Liquibase state the test DB has. Mirrors
  `ChatTestSchema` / `BoardTestSchema` / `MemoryTestSchema`.

  The shared test instance lagged 040 entirely (assets had zero test coverage, so the
  gap was invisible until now). 040 is committed + in master, so prod already has these
  tables — this only reconciles the test DB.
  """
  alias NoizuPromptLingua.Repo

  @statements [
    """
    CREATE TABLE IF NOT EXISTS asset_entries (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      organization_id uuid NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
      project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
      slug varchar(255) NOT NULL,
      title varchar(255) NOT NULL,
      asset_type varchar(255) NOT NULL,
      status varchar(255) NOT NULL DEFAULT 'draft',
      quality varchar(255),
      prompt_yaml text NOT NULL,
      tags text[] DEFAULT '{}',
      product_targets text[] DEFAULT '{}',
      active_output_id uuid,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE UNIQUE INDEX IF NOT EXISTS idx_asset_entries_org_slug ON asset_entries (organization_id, slug)",
    "CREATE INDEX IF NOT EXISTS idx_asset_entries_asset_type ON asset_entries (asset_type)",
    "CREATE INDEX IF NOT EXISTS idx_asset_entries_status ON asset_entries (status)",
    "CREATE INDEX IF NOT EXISTS idx_asset_entries_project_id ON asset_entries (project_id)",
    "CREATE INDEX IF NOT EXISTS idx_asset_entries_tags ON asset_entries USING gin (tags)",
    """
    CREATE TABLE IF NOT EXISTS asset_outputs (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      entry_id uuid NOT NULL REFERENCES asset_entries(id) ON DELETE CASCADE,
      artifact_id uuid,
      provider varchar(255),
      model varchar(255),
      variant_number integer NOT NULL DEFAULT 1,
      eval_score double precision,
      eval_details jsonb,
      eval_status varchar(255) NOT NULL DEFAULT 'pending',
      status varchar(255) NOT NULL DEFAULT 'generated',
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE INDEX IF NOT EXISTS idx_asset_outputs_entry_id ON asset_outputs (entry_id)",
    "CREATE INDEX IF NOT EXISTS idx_asset_outputs_eval_status ON asset_outputs (eval_status)",
    """
    CREATE TABLE IF NOT EXISTS asset_entry_history (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      entry_id uuid NOT NULL REFERENCES asset_entries(id) ON DELETE CASCADE,
      action varchar(255) NOT NULL,
      actor varchar(255),
      details jsonb,
      inserted_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )
    """,
    "CREATE INDEX IF NOT EXISTS idx_asset_entry_history_entry_id ON asset_entry_history (entry_id)"
  ]

  def ensure! do
    Enum.each(@statements, fn sql -> Ecto.Adapters.SQL.query!(Repo, sql, []) end)
    :ok
  end
end
